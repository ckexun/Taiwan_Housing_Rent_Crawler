source("global.R")

server <- function(input, output, session) {
  filtered_data <- reactive({
    data <- house_data %>% filter(坪數 >= input$min_area)
    if (input$type_select != "全部") {
      data <- data %>% filter(建物型態 == input$type_select)
    }
    data
  })
  
  observeEvent(input$go_filter, {
    output$taoyuan_map <- renderLeaflet({
      house_sample <- filtered_data() %>%
        filter(!is.na(經度), !is.na(緯度)) %>%
        slice_sample(n = min(nrow(.), 300))
      leaflet() %>%
        addTiles() %>%
        addMarkers(data = house_sample,
                   lng = ~經度, lat = ~緯度,
                   icon = house_icon,
                   popup = ~paste("租金:", 租金, "<br>地址:", 地址)) %>%
        addMarkers(data = gov_data,
                   lng = ~地理座標_WGS84_經度,
                   lat = ~地理座標_WGS84_緯度,
                   icon = gov_icon,
                   popup = ~paste("據點:", 地政服務據點, "<br>地址:", 地址))
    })
    
    output$circle_dist <- renderPlotly({
      data <- filtered_data()
      plot_ly(data = data, x = ~經度, y = ~緯度,
              text = ~paste("距離:", round(距離最近服務據點), "m"),
              marker = list(size = ~距離最近服務據點 / 100,
                            color = ~距離最近服務據點,
                            colorscale = "Viridis", showscale = TRUE),
              type = "scatter", mode = "markers") %>%
        layout(title = "租屋地點與服務據點距離散點圖",
               xaxis = list(title = "經度"), yaxis = list(title = "緯度"))
    })
    
    output$d3 <- renderPlotly({
      data <- filtered_data()
      plot_ly(data = data, x = ~經度, y = ~緯度, z = ~距離最近服務據點,
              type = "scatter3d", mode = "markers",
              color = ~租金,
              marker = list(size = 3, colorscale = 'Viridis', showscale = TRUE),
              text = ~paste("租金:", 租金, "元<br>距離:", round(距離最近服務據點), "m")) %>%
        layout(scene = list(xaxis = list(title = "經度"),
                            yaxis = list(title = "緯度"),
                            zaxis = list(title = "距離服務據點(m)")),
               title = "租屋 3D 地理分佈圖")
    })
    
    output$boxPlot <- renderPlotly({
      data <- filtered_data()
      plot_ly(data, y = ~距離最近服務據點, color = ~建物型態, type = "box") %>%
        layout(title = "不同建物型態與服務據點距離分佈",
               yaxis = list(title = "距離(m)"))
    })
    
    output$rent_pie <- renderPlotly({
      data <- filtered_data()
      bins <- cut(data$租金, breaks = c(0, 5000, 10000, 15000, 20000, 25000, Inf),
                  right = FALSE, labels = c("0~5000", "5001~10000", "10001~15000",
                                            "15001~20000", "20001~25000", "25000以上"))
      rent_count <- as.data.frame(table(bins))
      plot_ly(rent_count, labels = ~bins, values = ~Freq, type = 'pie') %>%
        layout(title = "租金分布圓餅圖")
    })
    
    output$rent_table <- renderTable({
      data <- filtered_data()
      bins <- cut(data$租金, breaks = c(0, 5000, 10000, 15000, 20000, 25000, Inf),
                  right = FALSE, labels = c("0~5000", "5001~10000", "10001~15000",
                                            "15001~20000", "20001~25000", "25000以上"))
      data$區間 <- bins
      data %>% group_by(區間) %>% summarise(數量 = n()) %>% arrange(區間)
    })
    
    output$ppp_bar <- renderPlotly({
      data <- filtered_data()
      avg_rent <- data %>%
        group_by(建物型態) %>%
        summarise(平均每坪租金 = mean(每坪租金, na.rm = TRUE)) %>%
        arrange(desc(平均每坪租金))
      n_colors <- nrow(avg_rent)
      colors <- colorRampPalette(RColorBrewer::brewer.pal(8, "Dark2"))(n_colors)
      plot_ly(avg_rent, x = ~建物型態, y = ~平均每坪租金, type = "bar",
              text = ~round(平均每坪租金, 1), textposition = 'auto',
              marker = list(color = colors)) %>%
        layout(title = "各建物型態平均每坪租金",
               xaxis = list(title = "建物型態"),
               yaxis = list(title = "平均每坪租金(元)"))
    })
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("filtered_summary_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- filtered_data()[, c("地址", "租金", "坪數", "每坪租金", "距離最近服務據點")]
      write.csv(data, file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  )
}
