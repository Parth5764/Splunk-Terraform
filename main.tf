resource "splunk_saved_searches" "athena_error_in_citrix_ping" {
  name        = "Athena Error in citrix ping"
  search      = <<EOT
index=production_ath_services OR index=productionjp_ath_services | eval StartTime='-7m' | eval EndTime='now'
EOT
  description = "This should indicate a problem with an Athena service in PRODUCTION. Check the search result to see the exception."
  disabled = false
  actions = "email, slack, pagerduty"
  cron_schedule = "*/7 * * * *"
  action_email_to = "workspaceadmins@citrix.com"
  action_email_subject = "Athena Error in citrix ping"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = ">>> *PRODUCTION*: https://accounts.cloud.com/citrix/ping reported a problem!"
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/f43b76cc5258471796a205c42f8648aa/enqueue"
}
resource "splunk_saved_searches" "internal_athena_error_in_citrix_ping" {
  name        = "Internal Athena Error in citrix ping"
  search      = <<EOT
index=production_ath_services | eval StartTime='-7m' | eval EndTime='now'
EOT
  description = "This should indicate a problem with an Athena service in PRODUCTION INTERNAL. Check the search result to see the exception and contact Athena devs."
  disabled = false
  actions = "email, slack, pagerduty"
  cron_schedule = "*/7 * * * *"
  action_email_to = "workspaceadmins@citrix.com"
  action_email_subject = "Internal Athena Error in citrix ping"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = ">>> *PRODUCTION INTERNAL*: https://accounts-internal.cloud.com/citrix/ping reported a problem!"
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/710ee052b75c480ac00421cc14d4fa3d/enqueue"
}
