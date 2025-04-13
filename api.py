import requests
import csv

# 內政部的不動產交易實價查詢服務網
url = 'https://lvr.land.moi.gov.tw/SERVICE/QueryPrice/3df773fc32ccb0de997751e9cae2bd09?q=VTJGc2RHVmtYMTlFbXlOaUhnZnNuYjgyM1lGaWVkMDZCLzJsb3BadnBtUis0S3BmU1JtckJZQm9PTjV6dUd1c0tkUDZ1S1ZFZkJqZFQxYWplSGZkRjI4cE8vRCtDZC9ieGxBam5GeTk1ZXduTWd6bHA5S0xSK0ZlR2NoSjRIbE9haUdZQ2hrTXk4NW1meHdwUzRUR0JJTDFXazhaUjYyZFpyMTdrQ0k3WWxYak9qNXd5bjJuZjAzM3I0QmhJUDlxaG5KandST3dOcjlDWTVIY1RSSmdFdWU5azZBTWhkcURvOWVpR0NoeHhnZkhXdzRkM013OUFFWi9WZXJTK2ZnK3hJc0JpZmJVb2ZZZGJsck1ESStKNnFQbm4rL3FsU25BbUYxWEhjTENOMkpKdUlxeGdSUDAxQlUyeTduSDVBT0ZMR2xWNThZRGJpdFBnRndSNTduWEJhUnl5dWtYbVZsQmZicXYrNDdPUm4xMHZEb3VCLzhBcFFsanN3Q0xld0tuMS8zUE9ONnF0KzBFM1ZHZmRGNE9ZenV1eVNrWmR1aFBhSDJ6dWFHOHFQRjZPV1VqUVFSOEk4QzZaOTNOQXpUaTF1ZDBtZHJISWFPMDZ6d0NYM2RsZkVyVU5IeXRnTWMrd3ViM0F6bFVRZDJMckRpckkzaXg1Rm45UEhDYUFHenJaUU93QzR0M0xIS2hzKzBZMUFWNzR0N2pZRXdudThaTUtnQzNLOG9TTHRJbS9La0JwOHltRC9vM1EwSkpoOUNFa1R6TCtDSHU0cS82a2NtTHRSWm81c1U5SUVHdTVNZnhTaTBPYmhyQzBiU2pWUllkdVBNaWNHOWFHb040R1F4b3Z4SVUyOUlHRmY4T2Z4UW0xZU5SYzZ1b01tUlZOOHJ0R3ptN2V3cDNGbzVzQUZRc0R0cVM4eTV5ZnNFREQ5ME5LTDFVa2NyUXRFTDJOTnZkdHBuS3FZdVBLcnkvemszaTJjVzdza1JxYTB6dEFhd3grblFPSzBxM0Q4VUVYSFp1TGRuRFhrSDQzKzAvVWNZaUdvS3B6K2tRVjZKbkpSNEZKbEJWTUlWVk1VWT0='



response = requests.get(url)
# 會轉為python list
data = response.json()

# 對應的content
fields = {"a":"地址",
      "b":"建物型態",
      "e":"訂約日期",
      "f":"樓別/樓高",
      "fn":"家具",
      "lat":"緯度",
      "lon":"經度",
      "note":"備註",
      "tp":"租金",
      "s":"總面積(坪)",
      "rtype":"出租型態",
      "v":"房型",
      "rperiod":"租賃期間",
      "g":"屋齡",
      "pu":"主要用途"}

contents = list(fields.values())


with open("api.csv", "w", newline="", encoding="utf-8-sig") as f:
    writer = csv.writer(f)
    writer.writerow(contents)
    for d in data:
        writer.writerow([d.get(k, "") for k in fields])

print("Saved as api.csv")

