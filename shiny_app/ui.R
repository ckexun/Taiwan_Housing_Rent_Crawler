ui <- dashboardPage(
  skin = "yellow",
  dashboardHeader(title = "中壢區租屋資料統計分析"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("地圖與距離分析", tabName = "map_tab"),
      menuItem("租金統計圖表", tabName = "stat_tab"),
      menuItem("租屋分析", tabName = "analyze_tab"),
      menuItem("坪數與建物型態分析", tabName = "building_tab"),
      selectInput("type_select", "選擇建物型態：(套用所有圖表)", choices = c("全部", unique(house_data$建物型態))),
      sliderInput("min_area", "最小坪數(套用所有圖表)", min = 0, max = 100, value = 40),
      actionButton("go_filter", "更新查詢"),
      downloadButton("downloadData", "下載分析結果")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map_tab",
              fluidRow(
                box(title = "地圖(更新分布需要等一下)", width = 12, leafletOutput("taoyuan_map", height = 400)),
                box(title = "租屋點與服務據點距離分佈", width = 12, plotlyOutput("circle_dist", height = 300))
              )
      ),
      tabItem(tabName = "stat_tab",
              fluidRow(
                box(title = "租金分布圓餅圖", width = 6, plotlyOutput("rent_pie")),
                box(title = "租金分佈表格", width = 6, tableOutput("rent_table"))
              )
      ),
      tabItem(tabName = "analyze_tab",
              fluidRow(
                box(title = "租屋地點與服務據點距離 BoxPlot", width = 6, plotlyOutput("boxPlot")),
                box(title = "租屋點 3D 地理分布", width = 6, plotlyOutput("d3"))
              )
      ),
      tabItem(tabName = "building_tab",
              fluidRow(
                box(title = "建物型態平均每坪租金", width = 12, plotlyOutput("ppp_bar"))
              )
      )
    )
  )
)
