import requests

headers = {
    "AccountKey": "xEh4xOy6SK2WlgFabWlmfg==",
    "accept": "application/json"
}

params = {
    "BusStopCode": "83139"  # Example stop: Opp Bishan MRT
}

url = "https://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2"

response = requests.get(url, headers=headers, params=params)

print(response.status_code)
print(response.json())
