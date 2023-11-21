from jinja2 import Environment, FileSystemLoader
import json

def generate_terraform_template(saved_search_name, saved_search_query, saved_search_description, saved_search_disabled, enabled_actions, cron_schedule, actions, action_email_to, action_email_subject, action_slack_param_channel, action_slack_param_message, action_pagerduty_integration_url):
    # Step 1: Create Jinja2 Environment
    template_dir = ''
    loader = FileSystemLoader(template_dir)
    env = Environment(loader=loader)

    # Step 2: Load Jinja2 Template
    template = env.get_template('alert.jinja2')

    # Step 3: Render Template with Values fetched from alert's json
    resource_name = saved_search_name.lower().replace(" ", "_")
    variables = {
        'resource_name': resource_name,
        'saved_search_name': saved_search_name,
        'saved_search_query': saved_search_query,
        'saved_search_description': saved_search_description,
        'saved_search_disabled': saved_search_disabled,
        'enabled_actions': enabled_actions,
        'cron_schedule': cron_schedule,
        'actions': actions,
        'action_email_to': action_email_to,
        'action_email_subject': action_email_subject,
        'action_slack_param_channel': action_slack_param_channel,
        'action_slack_param_message': action_slack_param_message,
        'action_pagerduty_integration_url': action_pagerduty_integration_url
    }
    output = template.render(variables)

    with open('main.tf', 'a') as f:
        f.write(output)
        f.write('\n')


with open('splunk_demo.json', 'r') as splunk_json:
    json_data = json.load(splunk_json)

# Delete old content of main.tf
with open('main.tf', 'w') as f:
    f.write('')

for alert in json_data:
    name = alert["Name"]
    description = alert["Description"]
    search_string = alert["Properties"]["Search"]
    search = search_string.replace('"', '\\"')
    indices = alert["Properties"]["Indices"]
    start_time = alert["Properties"]["StartTime"]
    end_time = alert["Properties"]["EndTime"]

    indices = set(indices)

    # Replaced "append index" with "index=... OR index=..." (Feel free to change the query as I don't have much idea about this)
    for index in indices:
        print(index)
        search += f" index={index} OR"
    search = search.rsplit('OR', 1)[0].strip()

    search += f" | eval StartTime='{start_time}' | eval EndTime='{end_time}'"

    disabled = alert["Properties"]["Disabled"]
    disabled = str(disabled).lower()
    cron_schedule = alert["Properties"]["CronExpression"]
    actions = ""
    action_email_to = ""
    action_email_subject = ""
    action_slack_param_channel = ""
    action_slack_param_message = ""
    action_pagerduty_integration_url = ""

    actions_list = []
    if "Emails" in alert["Properties"]:
        actions_list.append("email")
        action_email_to_list = alert["Properties"]["Emails"]
        action_email_to = ''.join(action_email_to_list)
        action_email_subject = alert["Name"]
    if "SlackChannel" in alert["Properties"]:
        actions_list.append("slack")
        action_slack_param_channel = alert["Properties"]["SlackChannel"]["Channel"]
        action_slack_param_message = alert["Properties"]["SlackChannel"]["Message"]
    if "PagerDuty" in alert["Properties"]:
        actions_list.append("pagerduty")
        action_pagerduty_integration_url = alert["Properties"]["PagerDuty"]
    actions = ', '.join(actions_list)
    generate_terraform_template(name, search, description, disabled, actions, cron_schedule, actions, action_email_to, action_email_subject, action_slack_param_channel, action_slack_param_message, action_pagerduty_integration_url)



# Make sure tf is valid - DONE - Attaching Screen Shot in mail for it
# find a way to add all keys in json to a set to find out if any key is missing then print it - creating it in print_keys.py
