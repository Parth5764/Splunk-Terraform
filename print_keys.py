import json

# Printing all keys in splunk.json
with open('splunk.json', 'r') as splunk_json:
    splunk_json_data = json.load(splunk_json)

all_keys = set()
for entry in splunk_json_data:
    all_keys.update(entry.keys())

print("List of Keys of main block")
print("List of keys:", list(all_keys))

properties_keys = set()

# Iterate through each dictionary in the list
for entry in splunk_json_data:
    # Check if the "Properties" key is present in the current dictionary
    if 'Properties' in entry:
        # Update the set with keys from the "Properties" block
        properties_keys.update(entry['Properties'].keys())

print("List of Keys of properties block")
print("List of keys:", list(properties_keys))