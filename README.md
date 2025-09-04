# Taiwan Housing Rent Crawler
>Update time: 2025-08-13

An integrated housing rental data crawler for Taiwan, combining the private platform Rakuya (樂屋網) and the official Ministry of the Interior (MOI) Real Estate Transaction API to collect and analyze daily market data.

Rakuya info: [https://raw.githubusercontent.com/ckexun/Taiwan_Housing_Rent_Crawler/refs/heads/main/static.json](https://raw.githubusercontent.com/ckexun/Taiwan_Housing_Rent_Crawler/refs/heads/main/static.json)
MOI Real Estate Transaction info: [https://raw.githubusercontent.com/ckexun/Taiwan_Housing_Rent_Crawler/refs/heads/main/api.csv](https://raw.githubusercontent.com/ckexun/Taiwan_Housing_Rent_Crawler/refs/heads/main/api.csv)

---

## Environment
![Python Badge](https://img.shields.io/badge/Python-3.12.9-blue) ![R Badge](https://img.shields.io/badge/R-4.4.1-blue)


---

## Project Goal

To build a robust, automated rental housing data pipeline by integrating both **private listing platforms** and **government open data**. The structured and auto-updating dataset aims to support:

- Daily market trend analysis
- Price monitoring and alerts
- Research and data-driven rental decisions

---

## Crawler Overview

### 1️⃣ Rakuya Static Web Crawler

- **Libraries used**: `requests`, `BeautifulSoup`
- **Data collected**:
  - Listing titles and links
  - Addresses (City, District)
  - Price, size (ping), floor, layout
- **Output format**:
  - `static.json`: Hierarchically structured JSON by city and district

### 2️⃣ MOI Real Transaction API Crawler

- **API endpoint**: [https://lvr.land.moi.gov.tw/](https://lvr.land.moi.gov.tw/)
- **Data collected** (e.g., Zhongli District):
  - Area size, total floor, building type
  - Rent amount, address, lease term
- **Output format**:
  - `api.csv`: Clean tabular format for direct use in analysis

---

## Methods & Tools

### Data Sources

- Private Platform: [https://www.rakuya.com.tw/](https://www.rakuya.com.tw/)
- Government API: [https://lvr.land.moi.gov.tw/](https://lvr.land.moi.gov.tw/)

### Implementation

1. **Static Web Crawler**: Scrapes Rakuya rental listings using `requests` and `BeautifulSoup`.
2. **API Fetcher**: Calls the MOI Real Price Registration API to fetch government-backed rental data.
3. **GitHub Actions Scheduler**: Automates data updates every morning at 8 AM.
4. **Data Analysis (with Pandas)**: Cleans and summarizes rental statistics including average rent, layout distribution, etc.
