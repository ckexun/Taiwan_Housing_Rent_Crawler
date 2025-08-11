options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("geosphere", quietly = TRUE)) {
  install.packages("geosphere", repos = "https://cloud.r-project.org")
}


library(shiny)
library(dplyr)
library(plotly)
library(leaflet)
library(geosphere)
library(shinydashboard)
library(ggplot2)
library(DT)
library(readr)
library(jsonlite)

USE_GITHUB_RAW <- TRUE
owner  <- "ckexun"
repo   <- "Taiwan_Housing_Rent_Crawler"
branch <- "main"

api_csv_url <- sprintf("https://raw.githubusercontent.com/%s/%s/%s/api.csv", owner, repo, branch)
gov_csv_url <- sprintf("https://raw.githubusercontent.com/ckexun/Taiwan_Housing_Rent_Crawler/refs/heads/main/shiny_app/data/%E6%A1%83%E5%9C%92%E5%B8%82%E5%90%84%E5%9C%B0%E6%89%80%E5%8F%8A%E5%B7%A5%E4%BD%9C%E7%AB%99%E6%9C%8D%E5%8B%99%E6%93%9A%E9%BB%9E.csv")
committee_csv_url <- sprintf("https://raw.githubusercontent.com/ckexun/Taiwan_Housing_Rent_Crawler/refs/heads/main/shiny_app/data/%E6%A1%83%E5%9C%92%E5%B8%82%E5%85%AC%E5%AF%93%E5%A4%A7%E5%BB%88%E7%AE%A1%E7%90%86%E5%A7%94%E5%93%A1%E6%9C%83%E6%B8%85%E5%86%8A(%E4%B8%AD%E5%A3%A2%E5%8D%80_)v2.csv")

read_utf8_csv <- function(path_or_url) {
  readr::read_csv(path_or_url, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))
}

if (USE_GITHUB_RAW) {
  house_data     <- read_utf8_csv(api_csv_url)
  gov_data       <- read_utf8_csv(gov_csv_url)
  committee_data <- read_utf8_csv(committee_csv_url)
} else {
  house_data     <- read_utf8_csv("api.csv")
  gov_data       <- read_utf8_csv("data/桃園市各地所及工作站服務據點.csv")
  committee_data <- read_utf8_csv("data/桃園市公寓大廈管理委員會清冊(中壢區_)v2.csv")
}

house_data$租金 <- gsub("[$,]", "", house_data$租金)
house_data$租金 <- as.numeric(house_data$租金)
house_data <- house_data[!is.na(house_data$租金), ]
house_data <- house_data[!is.na(house_data$經度) & !is.na(house_data$緯度), ]
gov_data <- gov_data[!is.na(gov_data$地理座標_WGS84_經度) & !is.na(gov_data$地理座標_WGS84_緯度), ]

# 處理坪數欄位
house_data$總面積.坪. <- gsub("[^0-9.]", "", house_data$總面積.坪.)
house_data$坪數 <- as.numeric(house_data$總面積.坪.)
house_data$每坪租金 <- house_data$租金 / house_data$坪數

# 計算距離
calc_dist <- function(house_df, gov_df) {
  apply(house_df, 1, function(row) {
    house_coord <- c(as.numeric(row["經度"]), as.numeric(row["緯度"]))
    gov_coords <- cbind(gov_df$地理座標_WGS84_經度, gov_df$地理座標_WGS84_緯度)
    min(distHaversine(house_coord, gov_coords))
  })
}

house_data$距離最近服務據點 <- calc_dist(house_data, gov_data)

# icon 設定
house_icon <- makeIcon("house.png", iconWidth = 30, iconHeight = 30)
gov_icon <- makeIcon("goverment.png", iconWidth = 30, iconHeight = 30)