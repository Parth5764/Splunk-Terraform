# Creates folder according to regions from splunk.json file

import json


with open('splunk.json', 'r') as splunk_json:
    json_data = json.load(splunk_json)
    # print(json_data)

for alert in json_data:
    print(alert["Filter"]["Regions"])