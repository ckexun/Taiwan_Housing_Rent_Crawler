import requests
from bs4 import BeautifulSoup
import re
import time
import json
import random

def get_CIDandZIPCODE(url="https://www.rakuya.com.tw/" ):
    headers = {"User-Agent": random.choice(user_agents)}
    response = requests.get(url, headers=headers) # 隨機使用agent，以免被擋
    soup = BeautifulSoup(response.text, "html.parser")

    # 找City ID(data-cid attribute)
    city_tags = soup.find_all("a", attrs={"data-cid": True})

    # 存成dict格式以便後續選擇
    city_dict = {}
    for city_tag in city_tags:
        name = city_tag.text.strip()
        cid = city_tag["data-cid"]
        city_dict[name] = cid

    # print(city_dict)

    city_area_dict = {}
    # 找City Area ID(data-zipcode attribute)
    dl_list = soup.find_all("dl", attrs={"data-cid": True})
    for dl in dl_list:
        cid = dl["data-cid"]
        city_area_dict[cid] = {}
        dd_tags = dl.find_all("dd")
        for dd in dd_tags:
            a_tag = dd.find("a")
            if a_tag:
                zipcode = a_tag.get("data-zipcode")
                name = a_tag.text.strip()
                if zipcode and name:
                    city_area_dict[cid][name] = zipcode
    # print(city_area_dict)
    return city_dict, city_area_dict

def CrawlByCities(citys=["桃園市"]):
  for city in citys:
    if city not in results:
      results[city] = {}
    areas = city_area_dict[city_dict[city]]
    print(city, end=': ')
    for area in areas:
      print(area, end=', ')
    print()
    # areas = ["平鎮區", "龍潭區", "楊梅區", "新屋區", "觀音區", "桃園區", "龜山區", "八德區", "大溪區", "復興區", "大園區", "蘆竹區"]
    CrawlByAreas(city, areas)

def get_pages(params):
  url = "https://www.rakuya.com.tw/rent/rent_search"
  headers = {"User-Agent": random.choice(user_agents)}
  response = requests.get(url, params=params, headers=headers)
  # print(response.url)
  soup = BeautifulSoup(response.text, "html.parser")
  pages_tag = soup.find('p', attrs={"class":"pages"})
  # print(pages_tag.text)
  page = 0
  if not pages_tag:
    return page

  match = re.search(r"/\s*(\d+)\s*頁", pages_tag.text)
  if match:
      page = int(match.group(1))
  return page

def CrawlByAreas(city="桃園市", areas=["中壢區"]):
  for area in areas:
    if area not in results[city]:
      results[city][area] = []
    params = {
    "search":"city",   # 透過縣市搜尋的方式
    "city":city_dict[city],
    "zipcode":city_area_dict[city_dict[city]][area],
    "usecode":"7,8,9,10", # 字串即可，自動編碼成 %2C(整層住家 獨立套房 分租套房 雅房)
    "sort":21,       # 更新時間(由近到遠)
    "upd":1        # 可能為更新時間篩選?
    }
    page = get_pages(params)
    print(f"Pages of {area}: {page}")

    for i in range(1, page+1):
      params["page"] = i
      CrawlByPage(params, city, area)
      time.sleep(random.uniform(2, 5)) # 以免被forbidden(隨機更像人類)

def CrawlByPage(params, city="桃園市", area="中壢區"):
  # 參考URL: https://www.rakuya.com.tw/rent/rent_search?search=city&city=4&zipcode=320&usecode=7%2C8%2C9%2C10&sort=21&upd=1
  url = "https://www.rakuya.com.tw/rent/rent_search"
  headers = {"User-Agent": random.choice(user_agents)}
  response = requests.get(url, params=params, headers=headers)
  # print(response.url)
  # print(response.status_code)
  soup = BeautifulSoup(response.text, "html.parser")

  info = {}
  try:
    contentlist_tag = soup.find("div", attrs={"class": "content type-list clearfix"})
    items = contentlist_tag.find_all("div", class_="obj-info")
    # print(len(items))
  except Exception as e:
    print(f"Error: {e}")
    return

  for item in items:
    title_tag = item.select_one("div.obj-title a")
    title = title_tag.text.strip()
    link = title_tag["href"]

    address = item.select_one("p.obj-address").text.strip()
    price = item.select_one("li.obj-price span").text.strip()
    type_info = item.select("li.clearfix span")

    room_type = type_info[0].text.strip() if len(type_info) > 0 else ""
    layout = type_info[1].text.strip() if len(type_info) > 1 else ""
    size = type_info[2].text.strip() if len(type_info) > 2 else ""
    floor = type_info[3].text.strip() if len(type_info) > 3 else ""

    update_time = item.select_one("span.sub06-c b")
    view_count = len(item.select("span.obj-update b")[-1].text.strip()[:-1]) if len(item.select("span.obj-update b"))>1 else 0   # 剛上傳房屋資訊沒有b tag

    # 房屋info
    info = {
        "title": title,
        "link": link,
        "address": address,
        "price": price,
        "room_type": room_type,
        "layout": layout,
        "size": size,
        "floor": floor,
        "update_time": update_time.text.strip() if update_time else "",  # ""表剛上傳
        "view_count": view_count,
    }
    results[city][area].append(info)

if __name__ == "__main__":
  user_agents = [
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
      "Mozilla/5.0 (X11; Linux x86_64)",
      "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)",
  ]
  city_dict, city_area_dict = get_CIDandZIPCODE()
  if not city_dict:
     print("For bandwidth, please try again later.")
     exit(0)
  results = {}
  citys = ["桃園市"]
  CrawlByCities(citys)
     
  with open("static.json", "w", encoding="utf-8-sig") as f:
      json.dump(results, f, ensure_ascii=False, indent=2)

  print("Saved as static.json")


