from jinja2 import Environment, FileSystemLoader
import json
import re
import os

def generate_terraform_template(file, parent_directory, count, saved_search_name, saved_search_query, saved_search_description, saved_search_disabled, enabled_actions, cron_schedule, actions, action_email_to, action_email_subject, action_slack_param_channel, action_slack_param_message, action_pagerduty_integration_url, action_email_message_report, action_pagerduty_custom_details):
    # Step 1: Create Jinja2 Environment
    template_dir = ''
    loader = FileSystemLoader(template_dir)
    env = Environment(loader=loader)

    # Step 2: Load Jinja2 Template
    template = env.get_template('alert.jinja2')
    provider_template = env.get_template('provider.jinja2')

    # Step 3: Render Template with Values fetched from alert's json
    resource_name = saved_search_name.lower().replace(" ", "_")
    resource_name = re.sub(r'[^a-zA-Z0-9_]', '', resource_name)
    resource_name = re.sub(r'_+', '_', resource_name) + "_" + str(count)
    variables = {
        'resource_name': resource_name,
        'saved_search_name': saved_search_name + "_" + str(count),
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
        'action_pagerduty_integration_url': action_pagerduty_integration_url,
        'action_email_message_report': action_email_message_report,
        'action_pagerduty_custom_details': action_pagerduty_custom_details
    }
    output = template.render(variables)

    with open(f'{parent_directory}/main.tf', 'a') as f:
        f.write(output)
        f.write('\n')

    provider_output = provider_template.render()
    with open(f'{parent_directory}/provider.tf', 'w') as f:
        f.write(provider_output)
        f.write('\n')

def create_alerts(file, parent_directory):
    with open(file, 'r') as splunk_json:
        try:
            json_data = json.load(splunk_json)
        except:
            print(f"Cannot load {file}")
            return

    count = 1
    for alert in json_data:
        if alert["Type"] != "Splunk":
            continue
        name = alert["Name"]
        description = alert["Description"]
        search_string = alert["Properties"]["Search"]
        search = search_string.replace('"', '\\"')
        start_time = alert["Properties"]["StartTime"]
        end_time = alert["Properties"]["EndTime"]
        
        cron_schedule = alert["Properties"]["CronExpression"]
        actions = ""
        action_email_to = ""
        action_email_subject = ""
        action_slack_param_channel = ""
        action_slack_param_message = ""
        action_pagerduty_integration_url = ""
        action_email_message_report = ""
        action_pagerduty_custom_details = ""

        indices = ""
        if "Indices" in alert["Properties"]:
            indices = alert["Properties"]["Indices"]
            indices = set(indices)

            # Replaced "append index" with "index=... OR index=..." (Feel free to change the query as I don't have much idea about this)
            for index in indices:
                print(index)
                search += f" index={index} OR"
            search = search.rsplit('OR', 1)[0].strip()

            search += f" | eval StartTime='{start_time}' | eval EndTime='{end_time}'"

        disabled = "False"
        if "Disabled" in alert["Properties"]:
            disabled = alert["Properties"]["Disabled"]
        disabled = str(disabled).lower()

        actions_list = []
        if "Emails" in alert["Properties"]:
            actions_list.append("email")
            action_email_to_list = alert["Properties"]["Emails"]
            action_email_to = ''.join(action_email_to_list)
            action_email_subject = alert["Name"]
            if "MailContentCustom" in alert["Properties"]:
                action_email_message_report = alert["Properties"]["MailContentCustom"]
        if "SlackChannel" in alert["Properties"]:
            actions_list.append("slack")
            action_slack_param_channel = alert["Properties"]["SlackChannel"]["Channel"]
            action_slack_param_message = alert["Properties"]["SlackChannel"]["Message"]
        if "PagerDuty" in alert["Properties"]:
            actions_list.append("pagerduty")
            action_pagerduty_integration_url = alert["Properties"]["PagerDuty"]
            if "PagerDutyDetailsCustom" in alert["Properties"]:
                action_pagerduty_custom_details = alert["Properties"]["PagerDutyDetailsCustom"]
        actions = ', '.join(actions_list)
        generate_terraform_template(file, parent_directory, count, name, search, description, disabled, actions, cron_schedule, actions, action_email_to, action_email_subject, action_slack_param_channel, action_slack_param_message, action_pagerduty_integration_url, action_email_message_report, action_pagerduty_custom_details)
        count += 1


def main():
    repository_list = ['alertpolicies-master@2d416e49170', 'alertpolicies-master@5b7298481de']
    for directory in repository_list:
        for root, _, files in os.walk(directory):
            for file in files:
                if file == 'main.tf':
                    file_path = os.path.join(root, file)
                    with open(file_path, 'w') as main_tf_file:
                        main_tf_file.truncate(0)
                        print(f"Cleared content of {file_path}")
    
    for directory in repository_list:
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith('.json'):
                    file_path = os.path.join(root, file)
                    parent_dir_path = os.path.dirname(file_path)
                    create_alerts(file_path, parent_dir_path)


if __name__ == '__main__':
    main()
