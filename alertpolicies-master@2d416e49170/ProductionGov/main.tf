
resource "splunk_saved_searches" "athena_gov_error_in_citrix_ping_1" {
  name                     = "Athena GOV Error in citrix ping_1"
  search                   = <<EOT
"ServiceName=* \"Ping target service call failed\" ctxathp-*
| stats count
| search count > 1 index=productiongov_ath_services | eval StartTime='-7m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This should indicate a problem with an Athena service in PRODUCTION GOV. Check the search result to see the exception."
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV Error in citrix ping"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: https://accounts.cloud.us/citrix/ping reported a problem!"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/f43b76cc5258471796a205c42f8648aa/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_high_response_time_2" {
  name                     = "Athena GOV High Response Time_2"
  search                   = <<EOT
"sourcetype=ath:services EventType=Performance Method=MigratingAuthenticator.AuthenticateAsync Duration 
| eval DurationSecs = Duration/1000
| stats avg(DurationSecs) as AvgDurationSecs
| search AvgDurationSecs >= 5
| rename AvgDurationSecs as \"Athena Average Response Time (seconds)\" index=productiongov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered whenever response time is greater than expected. Check Athena status (e.g. response time and throughput) in AppInsights. SOP: https://info.citrite.net/x/1RNmX"
EOT
  disabled                 = false
  actions                  = "email, pagerduty"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV High Response Time"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/f43b76cc5258471796a205c42f8648aa/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_invalid_creds_spike_3" {
  name                     = "Athena GOV Invalid Creds Spike_3"
  search                   = <<EOT
"sourcetype=\"ath:services\" ServiceName=Authentication Username=*  The username or password you provided is not correct
| stats dc(Username) index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert requested to be created when we receive X amount of invalid credentials within Athena. This can signal a DOS attack or errors within Athena."
EOT
  disabled                 = false
  actions                  = "email"
  cron_schedule            = "0 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV Invalid Creds Spike"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_abnormal_getcustomers_call_4" {
  name                     = "Athena GOV Abnormal GetCustomers Call_4"
  search                   = <<EOT
"sourcetype=ath:services Method=PrincipalsController.GetCustomers
| bin _time span=3m
| stats count as CallCount by _time, ClientName
| streamstats window=18 avg(\"CallCount\") as
 avg stdev(\"CallCount\") as stdev count by ClientName
| eval upperBound=avg+2*stdev
| eval isOutlier=if('number' > upperBound, 1, 0)
| fields \"ClientName\", \"upperBound\", \"count\" \"isOutlier\", \"CallCount\"
| sort - _time, ClientName
| streamstats window=2 avg(isOutlier) as Ovalue
| search count=18 AND Ovalue=1 index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert for Athena Abnormal GetCustomers Call Count SOP: https://info.citrite.net/display/CWC/Excessive+Athena+Key+Usage"
EOT
  disabled                 = false
  actions                  = "email"
  cron_schedule            = "*/59 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV Abnormal GetCustomers Call"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_abnormal_getprincipalbyaliases_5" {
  name                     = "Athena GOV Abnormal GetPrincipalByAliases_5"
  search                   = <<EOT
"sourcetype=ath:services Method=PrincipalsController.GetPrincipalsByAliases CallerIp=\"*\"
| bin _time span=3m
| stats count as CallCount by _time, ClientName, CallerIp
| streamstats window=18 avg(\"CallCount\") as
 avg stdev(\"CallCount\") as stdev count by ClientName
| eval upperBound=avg+2*stdev
| eval isOutlier=if(CallCount > upperBound, 1, 0)
| fields \"ClientName\", \"upperBound\", \"count\" \"isOutlier\", \"CallCount\", \"CallerIp\"
| sort - _time, ClientName
| streamstats window=2 avg(isOutlier) as Ovalue
| search count=18 AND Ovalue=1 index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert for Athena Abnormal GetPrincipalByAliases Call Count Call SOP: https://info.citrite.net/display/CWC/Excessive+Athena+Key+Usage"
EOT
  disabled                 = false
  actions                  = "email"
  cron_schedule            = "*/59 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV Abnormal GetPrincipalByAliases"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_abnormal_getprincipallockstatus_call_6" {
  name                     = "Athena GOV Abnormal GetPrincipalLockStatus Call_6"
  search                   = <<EOT
"sourcetype=ath:services Method=PrincipalsController.GetPrincipalLockStatus
| bin _time span=3m
| stats count as CallCount by _time, ClientName
| streamstats window=18 avg(\"CallCount\") as
 avg stdev(\"CallCount\") as stdev count by ClientName
| eval upperBound=avg+2*stdev
| eval isOutlier=if('number' > upperBound, 1, 0)
| fields \"ClientName\", \"upperBound\", \"count\" \"isOutlier\", \"CallCount\"
| sort - _time, ClientName
| streamstats window=2 avg(isOutlier) as Ovalue
| search count=18 AND Ovalue=1 index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert for Athena Abnormal GetPrincipalLockStatus Call Count SOP: https://info.citrite.net/display/CWC/Excessive+Athena+Key+Usage"
EOT
  disabled                 = false
  actions                  = "email"
  cron_schedule            = "*/59 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV Abnormal GetPrincipalLockStatus Call"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_abnormal_getprincipalsbyemail_call_7" {
  name                     = "Athena GOV Abnormal GetPrincipalsByEmail Call_7"
  search                   = <<EOT
"sourcetype=ath:services Method=PrincipalsController.GetPrincipalsByEmail CallerIp=\"*\"
| bin _time span=3m
| stats count as CallCount by _time, ClientName, CallerIp
| streamstats window=18 avg(\"CallCount\") as
 avg stdev(\"CallCount\") as stdev count by ClientName
| eval upperBound=avg+2*stdev
| eval isOutlier=if(CallCount > upperBound, 1, 0)
| fields \"ClientName\", \"upperBound\", \"count\" \"isOutlier\", \"CallCount\", \"CallerIp\"
| sort - _time, ClientName
| streamstats window=2 avg(isOutlier) as Ovalue
| search count=18 AND Ovalue=1 index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert for Athena Abnormal GetPrincipalsByEmail Call Count SOP: https://info.citrite.net/display/CWC/Excessive+Athena+Key+Usage"
EOT
  disabled                 = false
  actions                  = "email"
  cron_schedule            = "*/59 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV Abnormal GetPrincipalsByEmail Call"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_data_volume_monitor_8" {
  name                     = "GOV Data Volume Monitor_8"
  search                   = <<EOT
"type=Usage idx=productiongov_cc_services OR idx=productiongov_ath_* OR idx=productiongov_csgops_* 
| stats sum(eval(b/1024/1024/1024)) AS volume_GB by idx 
| stats sum(volume_GB) as TotalVolume
| where TotalVolume>50 index=_internal | eval StartTime='-1d' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alerts DevOps @ 9am when aggregate data volume exceeds 50GB over the last 24 hours."
EOT
  disabled                 = false
  actions                  = "email"
  cron_schedule            = "0 9 * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "GOV Data Volume Monitor"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_sts_response_exception_9" {
  name                     = "GOV STS Response Exception_9"
  search                   = <<EOT
"\"Authentication against STS resulted in HttpResponseException.\" \"cloud.com\"
|dedup alias
|table alias index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Identify STS Failures. Engage GTS Apps Support Team immediately. +1 (954)-267-2302 - WebOps Oncall number and Slack Channel: #it-apps-support"
EOT
  disabled                 = false
  actions                  = "email, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "GOV STS Response Exception"
  action_slack_param_channel = ""
  action_slack_param_message = <<EOT
""
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/a6479c7a2ce24497b7155138378f46f9/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_mfa_login_attempt_exceptions_10" {
  name                     = "GOV MFA Login Attempt Exceptions_10"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=MultiFactorAuth EventType=Error Method=\"LoginController.Attempt\" ExceptionMessage* Message* index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when MFA login attempt fails. Check the exceptions and try to find what is going wrong and reach out to MFA devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: MFA login attempt exceptions in last 15 minutes: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_mfa_login_attempt_radius_authentication_error_11" {
  name                     = "GOV MFA Login Attempt Radius Authentication Error_11"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=MultiFactorAuth EventType=Error Method=\"ResponseMappingHelpers.ToAuthenticationResponseModel\" Message=\"Invalid authentication response received from Radius.\" index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when Radius service returns invalid authentication response. Check the exceptions and try to find what is going wrong and reach out to MFA devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: MFA login attempt Radius authentication errors in last 15 minutes: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_mfa_federated_user_filter_errors_12" {
  name                     = "GOV MFA Federated User Filter Errors_12"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=MultiFactorAuth EventType=Error Method=\"FederatedUserValidator.*\" Message* index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when federated user filter fails. Check the error message and try to find what is going wrong and reach out to MFA devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: MFA federated user filter errors in last 15 minutes: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "radius_gov_packet_sending_errors_13" {
  name                     = "Radius GOV Packet Sending Errors_13"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=Radius EventType=Error Method=\"RadiusClient.SendPacketAsync\" Message* ExceptionMessage* index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when errors happen in sending a Radius packet to a remote end point. Check the error messages and try to find what is going wrong and reach out to Radius devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: Radius packet sending errors in last 15 minutes: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_radius_service_failure_to_fetch_customers_14" {
  name                     = "GOV Radius Service failure to fetch Customers_14"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=Radius EventType=Error Method=RadiusService.AuthenticateAsync Message=Failed to resolve Athena customer* | rex field=_raw \"customer\s+(?<customer>[^\s]+)\s+\" | dedup customer index=productiongov_ath_services | eval StartTime='-20m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when errors happen while fetching customer detail from Customers service using authdomain. Check the error messages and try to find what is going wrong and reach out to Radius devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/20 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: Radius Service CC customer resolve error in last 20 minutes: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_radius_service_failures_to_fetch_the_shared_secret_15" {
  name                     = "GOV Radius Service Failures to fetch the shared secret_15"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=Radius EventType=Error Message=Unable to find value for shared secret corresponding to key* index=productiongov_ath_services | eval StartTime='-20m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when radius service fails to fetch shared secret . Check the error messages and try to find what is going wrong and reach out to Radius devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/20 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: Radius service shared secret fetch failed in last 20 mins: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_radius_service_failures_to_create_the_shared_secret_16" {
  name                     = "GOV Radius Service Failures to create the shared secret_16"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=Radius EventType=Error Message=*StoreSecretsException* index=productiongov_ath_services | eval StartTime='-20m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when radius service fails to create shared secret . Check the error messages and try to find what is going wrong and reach out to Radius devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/20 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: Radius service shared secret create failed in last 20 mins: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_radius_service_failures_to_delete_the_shared_secret_17" {
  name                     = "GOV Radius Service Failures to delete the shared secret_17"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=\"Radius\" EventType=Error Message=*DeleteSecretsException* index=productiongov_ath_services | eval StartTime='-20m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when radius service fails to delete shared secret . Check the error messages and try to find what is going wrong and reach out to Radius devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/20 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: Radius service shared secret delete failed in last 20 mins: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "radius_failure_to_establish_socks_conn_with_servicenode_18" {
  name                     = "Radius Failure to establish socks conn with ServiceNode_18"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=Radius EventType=Error Method=RadiusClient.ConnectAsync Message=Failed to activate connection | rex field=_raw \"customer\s+(?<customer>[^\s]+)\.\" | dedup customer index=productiongov_ath_services | eval StartTime='-20m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when errors happens while creating socks connection with ServiceNode. Check the error messages and try to find what is going wrong and reach out to Radius devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/20 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: Radius Service SOCKS connection failure with ServiceNode in last 20 minutes: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "radius_failure_to_establish_tunnel_with_gwconnbroker_19" {
  name                     = "Radius Failure to establish tunnel with GwConnBroker_19"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=Radius EventType=Error Method=ConnectionBrokerClient.NewTunnelAsync Message=Received response* | dedup Customer index=productiongov_ath_services | eval StartTime='-20m' | eval EndTime='now'"
EOT
  description              =<<EOT
"This alert will be triggered when failure occurs while forming tunnel with GwConnBroker. Check the error messages and try to find what is going wrong and reach out to Radius devs."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/20 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *PRODUCTION GOV*: Radius Service tunnel formation failure with GwConnBroker in last 20 minutes: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "alert_for_dsauth_throttling_20" {
  name                     = "Alert for DSAuth throttling_20"
  search                   = <<EOT
"\"Not building the domain contexts due to throttling\" | stats count by ServiceInstanceIp | where count > 100 index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"To alert throttling customers too aggressively in Athena. If alerted Correlate log's ServiceInstanceIp key to its respective value for scaleset and node ID, restart nodeID through CC Dashboard."
EOT
  disabled                 = true
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Alert for DSAuth throttling"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"Athena GOV: DSAuth throttling customers too aggressively."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/a6479c7a2ce24497b7155138378f46f9/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "alert_for_athena_gov_authdomain_21" {
  name                     = "Alert for Athena GOV AuthDomain._21"
  search                   = <<EOT
"\"sourcetype=ath:services ServiceName=DSAuth* Message=\"not found in athena customer AuthDomains\" | stats count by AuthDomain\" index=productiongov_ath_services | eval StartTime='-30m' | eval EndTime='now'"
EOT
  description              =<<EOT
"AuthDomain not found in Athena Customer.
 Link to SOP - https://info.citrite.net/pages/viewpage.action?pageId=1381595811"
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/30 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Alert for Athena GOV AuthDomain."
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"Production Athena GOV: One or more auth domains not found in an athena customer: $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "system_timeout_exception_detected_gov_splunk_instance_22" {
  name                     = "System Timeout Exception Detected - GOV Splunk Instance_22"
  search                   = <<EOT
"\"System.TimeoutException: This can happen if message is dropped when service is busy or its long running operation and taking more time than configured Operation Timeout.\" index=productiongov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered whenever services start logging a system timeout (which should never occur under normal circumstances)"
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "System Timeout Exception Detected - GOV Splunk Instance"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*System Timeout Exception Detected - GOV Splunk Instance*
Please run <https://citrixsys.splunkcloud.com/en-US/app/search_citrixcloud/search?q=search%20index%3Dproductiongov_ath_services%20%22System.TimeoutException%3A%20This%20can%20happen%20if%20message%20is%20dropped%20when%20service%20is%20busy%20or%20its%20long%20running%20operation%20and%20taking%20more%20time%20than%20configured%20Operation%20Timeout.%22%20%7C%20stats%20count%20by%20ServiceName%2C%20Method&display.page.search.mode=verbose&dispatch.sample_ratio=1&earliest=-10m%40m&latest=now&display.page.search.tab=statistics&display.general.type=statistics | this query> to identify which services and methods are throwing this exception and determine from the context which application has an unresponsive instance and needs to be redeployed. Please see <https://info.citrite.net/x/WmDGVw | SOP> for more information."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "gov_events_sent_to_cas_23" {
  name                     = "GOV Events sent to CAS_23"
  search                   = <<EOT
"ServiceName=NotificationsWorker OR ServiceName=Identity4 NOT \"LayerName=ProductionInternal\" Message=\"Deleting notifications from EventToCas\" OR Message=\"Sending notification to CasQueue\" OR Message=\"Sent notification.\" 
| stats count(eval(Message=\"Sending notification to CasQueue\")) as total_sent_to_hub count(eval(Message=\"Deleting notifications from EventToCas\")) as deleted_notifications count(eval(Message=\"Sent notification.\")) as total_sent_to_queue index=productiongov_ath_services | eval StartTime='-24h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Indicates how many events have been received by the Notifications Worker and sent to the CAS event hub.
 Link to SOP - https://info.citrite.net/display/CWC/Athena+CAS+Notifications"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "00 11 * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
"*Athena Production GOV *
Athena sent $result.total_sent_to_hub$ messages to cas in the last day.
Events successfully deleted from queue: $result.deleted_notifications$ (should be the same as messages sent)
Event messages sent to the CasQueue from the Identity4 service in the last day: $result.total_sent_to_queue$ (this does not represent the total events sent by Athena and should be different)
These events are documented here: <https://info.citrite.net/display/CWC/Athena+CAS+Notifications | Confluence Link>
These events are logged here: <https://citrixsys.splunkcloud.com/en-US/app/search_citrixcloud/alert?s=%2FservicesNS%2Fnobody%2Fsearch_citrixcloud%2Fsaved%2Fsearches%2FAthena%2520Production%253A%2520Notification%2520Events | Splunk Link>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_not_redirecting_to_logon_page_24" {
  name                     = "Athena GOV not redirecting to Logon Page_24"
  search                   = <<EOT
"ServiceName=DSAuth-Web2 RequestUri=\"*webview*\" Message=\"Error looking up auth domain:*\" index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Production GOV: Failing to redirect from DSAuth-Web to Identity to show the Logon Page: Error looking up auth domain. See: https://info.citrite.net/display/CWC/DSAuthWeb2+Logon+page+not+available+cross-geo"
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV not redirecting to Logon Page"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Production:*
There are an abnormal count of failures to get redirect to the Logon Page: $result.ErrorMessage$
```ServiceName=DSAuth-Web2 RequestUri="*webview*" Message="Error looking up auth domain:*"```
Possible issue with redirecting from DSAuth-Web to Identity to display the Logon page, please review splunk and follow <https://info.citrite.net/display/CWC/DSAuthWeb2+Logon+page+not+available+cross-geo | this runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "signing_key_not_found_in_dsauthweb2_gov_25" {
  name                     = "Signing key not found in DSAuthWeb2 GOV_25"
  search                   = <<EOT
"sourcetype=\"ath:services\" ServiceName=DSAuth-Web2 EventType=Error \"No appropriate signing key found in the discovery document.\" index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Production: This alert is triggered when DSAuthWeb2 cannot find appropriate signing key in the discovery document. Possible root cause could be an upgrade in Identity4 causing changes in kid. Please check <https://accounts.cloud.com/core/.well-known/openid-configuration/jwks>"
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Signing key not found in DSAuthWeb2 GOV"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Production GOV:*
 There are failures in DSAuthWeb2 when trying to find signing key in the discovery document: $result.ErrorMessage$
```sourcetype="ath:services" ServiceName=DSAuth-* EventType=Error "No appropriate signing key found in the discovery document."```
Possible root cause could be an upgrade in Identity4 causing changes in kid. Please check <https://accounts.cloud.com/core/.well-known/openid-configuration/jwks>.
Please execute this <https://info.citrite.net/x/lkfJWg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_admin_mfa_bypass_set_26" {
  name                     = "Athena GOV Admin MFA ByPass Set_26"
  search                   = <<EOT
"index=*_ath_services \"/principals/mfa/bypass\"  Method=\"PrincipalsController.UpdateMfaStatusBypass\" LayerName!=Integration \"EventType=Information\" | dedup TransactionId |
eval alertMessage=\"AlertType = Information 
Athena: MFA ByPass set for email *\".Email.\"* 
Region = \".RegionName.\"  
Layer = \".LayerName.\"
ClienName = \".ClientName.\"
TransanctionId = \".TransactionId.\"
\" |
stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a call to by pass Admin MFA for a user was made"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_feature_toggle_27" {
  name                     = "Athena GOV Feature Toggle_27"
  search                   = <<EOT
"\"The feature customer '*' was created successfully and it is now '*'.\" |
rex Message=\"The feature customer '(?<featureName>\w+)' was created successfully and it is now '(?<featureState>\w+)'.\" |
rex field=_raw \".*TransactionId=(?<transactionId>(\w+[-]*)+).*ClientId=(?<clientId>\w+).*ClientName=(?<clientName>\w+).*\" | 
eval alertMessage=\"AlertType=Information 
*Athena Feature - \".featureName.\"* set to `\".featureState.\"` 
By ClientId = \".clientId.\"
With ClientName = \".clientName.\"
TransactionId = \".transactionId.\"
\"  | stats  list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a call to the Athena features API was made to change the state of a feature"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_dsauthweb_500_errors_28" {
  name                     = "Athena GOV: DSAuthWeb 500 Errors_28"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=DSAuth-Web2 500 | stats count AS number_of_issues |
eval alertMessage=\"*Production Athena: 
AlertType = Error 
 Showing an increased level of 500 errors in DSAuthWeb.  Check in Splunk and warn the @cc-athena-squad\". 
\"`sourcetype=ath:services ServiceName=DSAuth-Web2 500`\"  | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the number of errors in DSAuthWeb is at an increased level of 500"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_dsauthweb_500_errors_29" {
  name                     = "Athena: DSAuthWeb 500 Errors_29"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=DSAuth-Web2 500 | stats count AS number_of_issues |
eval alertMessage=\"*Production Athena: 
AlertType = Error 
 Showing an increased level of 500 errors in DSAuthWeb.  Check in Splunk and warn the @cc-athena-squad\". 
\"`sourcetype=ath:services ServiceName=DSAuth-Web2 500`\"  | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the number of errors in DSAuthWeb is at an increased level of 500"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_customer_record_with_multiple_aliases_found_30" {
  name                     = "Athena: Customer record with multiple aliases found_30"
  search                   = <<EOT
"index=\"productiongov_ath_services\" \"A customer cannot have multiple aliases of the same type.\" | dedup TransactionId |
eval alertMessage = \"*Athena - Production:*
AlertType = Error 
 Found a bad customer record with multiple aliases of the same type.
We need to fix this customer record as soon as possible. 
```\".Message.\"```
TransactionId=\".TransactionId.\"
\"|
stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a customer record with multiple alias of the same alias type is found"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$
Please execute this <https://info.citrite.net/x/Af78VQ|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_customer_record_with_multiple_aliases_found_31" {
  name                     = "Athena: Customer record with multiple aliases found_31"
  search                   = <<EOT
"index=\"productiongov_ath_services\" \"A customer cannot have multiple aliases of the same type.\" | dedup TransactionId |
eval alertMessage = \"*Athena - Production:*
AlertType = Error 
 Found a bad customer record with multiple aliases of the same type.
We need to fix this customer record as soon as possible. 
```\".Message.\"```
TransactionId=\".TransactionId.\"
\"|
stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a customer record with multiple alias of the same alias type is found"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$
Please execute this <https://info.citrite.net/x/Af78VQ|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_dsauth_operation_timeouts_32" {
  name                     = "Athena: DSAuth Operation Timeouts_32"
  search                   = <<EOT
"EventType=Error \"Operation Timeout\" | top limit=1 CcCustomerName |
eval alertMessage = \"*Athena - Production:*
AlertType = Error 
There are Operation Timeouts happening in DSAuth at the moment 
```EventType=Error \\"Operation Timeout\\"```
Please review logs and if necessary start a call
\" | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there are any operation timeouts happening in DSAuth"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_dsauth_operation_timeouts_33" {
  name                     = "Athena: DSAuth Operation Timeouts_33"
  search                   = <<EOT
"EventType=Error \"Operation Timeout\" | top limit=1 CcCustomerName |
eval alertMessage = \"*Athena - Production:*
AlertType = Error 
There are Operation Timeouts happening in DSAuth at the moment 
```EventType=Error \\"Operation Timeout\\"```
Please review logs and if necessary start a call
\" | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there are any operation timeouts happening in DSAuth"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_exception_while_getting_user_oid_34" {
  name                     = "Athena: Exception while getting user OID_34"
  search                   = <<EOT
"\"Message=An exception occured while retrieving the user's oid\" | regex username!=\"([@\\\@])\" | dedup TransactionId | top TransactionId limit=1 |
eval alertMessage = \"*Athena - Production:*
AlertType = Error 
Abnormal exceptions from  
``` \\"Message=An exception occured while retrieving the user's oid\\"```
Possible issue during login for AD+TOTP users, please review logs and if necessary start a call
\" | 
stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if an exception was occurred while retrieving the user's oid"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$
Please execute this <https://info.citrite.net/x/oKssVg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_exception_while_getting_user_oid_35" {
  name                     = "Athena: Exception while getting user OID_35"
  search                   = <<EOT
"\"Message=An exception occured while retrieving the user's oid\" | regex username!=\"([@\\\@])\" | dedup TransactionId | top TransactionId limit=1 |
eval alertMessage = \"*Athena - Production:*
AlertType = Error 
Abnormal exceptions from  
``` \\"Message=An exception occured while retrieving the user's oid\\"```
Possible issue during login for AD+TOTP users, please review logs and if necessary start a call
\" | 
stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if an exception was occurred while retrieving the user's oid"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$
Please execute this <https://info.citrite.net/x/oKssVg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_principal_deleted_36" {
  name                     = "Athena: Principal Deleted_36"
  search                   = <<EOT
"HttpMethod=DELETE accounts*.cloud.com/principals/ |
dedup TransactionId |
eval alertMessage=\" *Athena Production - Principal Deleted* 
AlertType = Information 
CliendId = \".ClientId.\"
By ClientName = \".ClientName.\"
Client Permissions = \".ClientPermissions.\"
RequestUri = \".RequestUri.\"
TransactionId = \".TransactionId.\"
\"  | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Show if a call to the DELETE principals api was made"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_principal_deleted_37" {
  name                     = "Athena: Principal Deleted_37"
  search                   = <<EOT
"HttpMethod=DELETE accounts*.cloud.com/principals/ |
dedup TransactionId |
eval alertMessage=\" *Athena Production - Principal Deleted* 
AlertType = Information 
CliendId = \".ClientId.\"
By ClientName = \".ClientName.\"
Client Permissions = \".ClientPermissions.\"
RequestUri = \".RequestUri.\"
TransactionId = \".TransactionId.\"
\"  | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Show if a call to the DELETE principals api was made"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_redis_write_failures_38" {
  name                     = "Athena: Redis Write Failures_38"
  search                   = <<EOT
"LayerName=Production*  \"Citrix.CloudServices.Redis.RedisClient\" \"ExceptionMessage=Failed to write\" index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there are Redis Write exceptions with an abnormal count"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Production:*
AlertType = Error 
There are Redis Write exceptions with an abnormal count
``` LayerName=Production* "Citrix.CloudServices.Redis.RedisClient" "ExceptionMessage=Failed to write"```
Possible issue with Redis Connections or Timeouts affecting Token Exchanges, please review splunk and follow <https://info.citrite.net/x/clnSVQ | this runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_redis_write_failures_39" {
  name                     = "Athena: Redis Write Failures_39"
  search                   = <<EOT
"LayerName=Production*  \"Citrix.CloudServices.Redis.RedisClient\" \"ExceptionMessage=Failed to write\" index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there are Redis Write exceptions with an abnormal count"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Production:*
AlertType = Error 
 There are Redis Write exceptions with an abnormal count
``` LayerName=Production* "Citrix.CloudServices.Redis.RedisClient" "ExceptionMessage=Failed to write"```
Possible issue with Redis Connections or Timeouts affecting Token Exchanges, please review splunk and follow <https://info.citrite.net/x/clnSVQ | this runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_sts_events_40" {
  name                     = "Athena: STS Events_40"
  search                   = <<EOT
"\"Method=PrincipalUpdate.ProcessMessage Message=Processing principal\"
| stats count as Total

| appendcols[search  \"Method=PrincipalUpdate.ProcessMessage Message=Processing principal\" messageType=PasswordHash 
| stats count as PasswordHashEvents]

| appendcols[search  \"Method=PrincipalUpdate.ProcessMessage Message=Processing principal\" messageType=PersonDetail 
| stats count as PersonDetailEvents]

| appendcols[search  \"Method=PrincipalUpdate.ProcessMessage Message=Processing principal\" messageType=LoginID 
| stats count as LoginIDEvents]

| appendcols[search  \"Method=PrincipalUpdate.ProcessMessage Message=Processing principal\" messageType=GTC 
| stats count as GTCEvents]

| eval alertMessage=\"*Athena Production * 
AlertType = Information 
Athena processed \" .Total. \" IT/STS queue messages in the last day.
PasswordHash Events: \". PasswordHashEvents. \"
PersonDetail Events: \". PersonDetailEvents. \"
LoginID Events: \". LoginIDEvents. \"
GTC Events: \". GTCEvents. \"
These events are documented here: <https://info.citrite.net/display/CWC/Athena+Queue+Message+Schema+to+Report+STS+Updates | Confluence Link>
These events are logged here: <https://citrixsys.splunkcloud.com/en-US/app/search_citrixcloud/report?s=%2FservicesNS%2Fnobody%2Fsearch_citrixcloud%2Fsaved%2Fsearches%2FAthena%2520Production%253A%2520STS%2520Events%2520Clone&sid=javierf__javierf_c2VhcmNoX2NpdHJpeGNsb3Vk__RMD58dc3c1fa86df0ee4_at_1560278293_88593_4E87CF9E-FE18-411A-9472-95D526058A15&display.page.search.mode=verbose&dispatch.sample_ratio=1&earliest=-1d&latest=now&q=search%20index%3Dproductiongov_ath_services%20%22Method%3DQueueManager.ProcessV1QueueMessage%20Message%3DQueue%20subscription(*)%20processed%20change%22%20%7C%20timechart%20count%20by%20Type | Splunk Link>
```If the count of the above events is 0 across all counters, there is probably something wrong. Please create an ATH ticket with S1 severity for the team to follow up```\"
| stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-1d' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows daily summary of event counters from STS to Athena events"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 9 * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_token_exchange_timeouts_41" {
  name                     = "Athena GOV: Token Exchange Timeouts_41"
  search                   = <<EOT
"EventType=Error ServiceName=Tokens ThrowForNonSuccess  | top limit=1 TransactionId |
eval alertMessage = \"*Athena - Production:* 
AlertType = Error 
 Abnormal exceptions from  
``` EventType=Error ServiceName=Tokens ThrowForNonSuccess```
Possible issue during token exchange, maybe an issue with Redis, please review logs and if necessary start a call
\" | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there any events with ThrowForNonSuccess in Tokens Service"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_release_workflow_enable_42" {
  name                     = "Athena GOV Release Workflow: Enable_42"
  search                   = <<EOT
"index=productiongov_csgops_services EventType=Information RequestUri=https://csg-ath-wf.eng.citrite.net/api/products/athena/projects/*/layers/*/override/* HttpMethod=PUT  | dedup TransactionId |
rex RequestUri=\"*https://csg-ath-wf.eng.citrite.net/api/products/athena/projects/(?<project>\w+)/layers/(?<layer>\w+)/override/(?<action>\w+)*\" | 
eval alertMessage=\"AlertType= Information 
*Athena - \".project.\"* set to \".action.\" 
Layer = \".layer.\"
By UserId = \".UserId.\"
MachineName = \".MachineName.\"
RoleName = \".RoleName.\"
TransactionId = \".TransactionId.\"
\"  | stats list(alertMessage) as alertMessage index=productiongov_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a layer in the release workflow was enabled through the release workflow api"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_release_workflow_enable_dashboard_43" {
  name                     = "Athena GOV Release Workflow: Enable (Dashboard)_43"
  search                   = <<EOT
"index=productiongov_csgops_services RoleName=CCOpsDashboardApi LoggingLevel=Info  AbsoluteUri=https://cwcdashboard.eng.citrite.net/api/releaseworkflow/products/Athena/projects/*/layers/*/* RequestMethod=POST  | dedup TransactionId |
rex AbsoluteUri=\"*https://cwcdashboard.eng.citrite.net/api/releaseworkflow/products/Athena/projects/(?<project>\w+)/layers/(?<layer>\w+)/(?<action>\w+)*\"  | 
eval alertMessage=\"AlertType = Information 
*Athena - \".Project.\"* set to \".action.\" 
Layer = \".Layer.\"
By UserId = \".TokenUsername.\"
RoleName = \".RoleName.\"
TransactionId = \".TransactionId.\"
\"  | stats list(alertMessage) as alertMessage index=productiongov_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a layer in the release workflow was enabled through the cwc dashboard"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_release_workflow_override_dashboard_44" {
  name                     = "Athena GOV Release Workflow: Override (Dashboard)_44"
  search                   = <<EOT
"index=productiongov_csgops_services \"AbsoluteUri=https://ccdashboard.eng.citrite.net/api/releaseworkflow/products/Athena/projects/*/layers/*/override\"  \"RoleName=CCOpsDashboardApi\"  \"CallerFile=ReleaseWorkflowService.cs\" | dedup TransactionId | rex AbsoluteUri=\"*https://cwcdashboard.eng.citrite.net/api/releaseworkflow/products/Athena/projects/(?<project>\w+)/layers/(?<layer>\w+)/override*\"  | rex field=_raw \".*Message=(?<Contents>.*).*\" | dedup TransactionId |
rex AbsoluteUri=\"*https://cwcdashboard.eng.citrite.net/api/releaseworkflow/products/Athena/projects/(?<project>\w+)/layers/(?<layer>\w+)/override*\"  | 
rex field=_raw \".*Message=(?<Contents>.*).*\" |
eval alertMessage=\"AlertType = Information 
*Athena - \".Project.\"* set to Override 
Layer = \".Layer.\"
By UserId = \".TokenUsername.\"
RoleName = \".RoleName.\"
Contents = \".Contents.\"
TransactionId = \".TransactionId.\"
\"  | stats list(alertMessage) as alertMessage index=productiongov_csgops_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a layer in the release workflow was overriden through the cwc dashboard"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_release_workflow_overrides_45" {
  name                     = "Athena Release Workflow: Overrides_45"
  search                   = <<EOT
"index=productiongov_csgops_services  \"RequestUri=https://csg-ath-wf.eng.citrite.net/api/products/Athena/projects/*/layers/*/override\" \"HttpMethod=PATCH\" Method=ProjectLayerOverrideController.LogUpdate | rex RequestUri=\"https://csg-ath-wf.eng.citrite.net/api/products/Athena/projects/(?<project>\w+)/layers/(?<layer>\w+)/override\"  | dedup TransactionId |
eval alertMessage=\"AlertType = Information 
Override set in *Athena - \".project.\"* 
Layer = \".layer.\"
Override Content = \".UpdateItem.\"
UserId = \".UserId.\"
RoleName = \".RoleName.\"
TransanctionId = \".TransactionId.\"
\" |
stats list(alertMessage) as alertMessage index=productiongov_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if a layer in the release workflow was overriden through the release workflow api"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athenaemailverificationaveragetime_46" {
  name                     = "Athena-Email-Verification-Average-Time_46"
  search                   = <<EOT
"sourcetype=\"ath:services\" EventType=Information ServiceName=Email  Method=\"PendingUserManager.GetPendingUserByKeyAsync\" \"*Attempting to get pending user with sub*\" | rex field=Message \".* after '?(?<sec>\d*.\d*)'? seconds.*\" | stats  avg(sec) as prod_avg_vtime | 
appendcols [search index=\"productiongov_ath_services\" \"EventType=Information\" \"ServiceName=ActiveDirectoryWeb\" \"Verifying ReCaptcha and sending email.\" OR \"Successfully verified the email code.\" 
 | transaction SessionId startswith=\"Verifying ReCaptcha and sending email.\" endswith=\"Successfully verified the email code.\" maxevents=2 | stats avg(duration) as prod_avg_vtime_otp] |
  eval alertMessage = \"AlertType=Information 
*Athena Production* 
Daily native Email verification average: \".prod_avg_vtime.\" seconds
*Athena Production* 
Daily AD + TOTP email verification average: \".prod_avg_vtime_otp. \" seconds
\"| 
stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-1d' | eval EndTime='now'"
EOT
  description              =<<EOT
"Show daily average performance of email verifications"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 13 * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "frontdoor_us_gov_assigning_stores_are_not_allowed_47" {
  name                     = "FrontDoor US GOV -Assigning stores are not allowed_47"
  search                   = <<EOT
"index=productiongov_cc_services EventType=Error ServiceName=StoreFrontConfiguration \"Assigning stores are not allowed due to setting _assignStoreEnabled=False\" \"Message=CustomerId=*\" | rex field=_raw \"Message=CustomerId=(?<customerId>\w+).*\" | rex field=Message \".*Message: '(?<errorMessage>.*)'\)\" | rex field=_raw \"TransactionId=(?<transactionId>.*)\s+EventId.*\" | eval output=errorMessage. \". This happened for customer: \".customerId.\", logged with transactionId: \".transactionId | stats list(output) as alertMessage by source index=productiongov_cc_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if Assigning stores are not allowed due to setting _assignStoreEnabled=false"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#ws-exp-alerts"
  action_slack_param_message = <<EOT
"Production Virgina Gov US 
AlterType=Error 
$result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "frontdoor_error_unparking_the_store_domain_48" {
  name                     = "FrontDoor - Error unparking the store domain_48"
  search                   = <<EOT
"index=productiongov_cc_services EventType=Error ServiceName=StoreFrontConfiguration \"*Error while unparking the StoreFront domain. subdomain*\" | rex field=Message \".*Message: \'(?<alertMessage>.*)\'\)\" | table alertMessage, source, TransactionId, CustomerId index=productiongov_cc_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if available shard was not found - Exception updating Store"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#ws-exp-alerts"
  action_slack_param_message = <<EOT
"Production Virgina Gov US 
AlterType=Error 
$result.alertMessage$ (TransactionId=$result.TransactionId$; CustomerId=$result.CustomerId$; Source=$result.source$)"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "frontdoor_no_shard_available_49" {
  name                     = "FrontDoor - No Shard Available_49"
  search                   = <<EOT
"index=productiongov_cc_services  EventType=Error \"Exception updating Store. Cannot find an available shard.\"
| rex field=Message \"Exception\(Type: 'StatelessServiceException', Message: '(?<exception>[\w\s\.]+)'\)\"
| eval alertMessage=exception.\" TransactionId:\".TransactionId
| stats list(alertMessage) by source index=productiongov_cc_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if available shard was not found - Exception updating Store"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#ws-exp-alerts"
  action_slack_param_message = <<EOT
"Production East US 
AlterType=Error 
$result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_authdomain_not_found_in_athena_customer_50" {
  name                     = "Athena: AuthDomain not found in Athena Customer_50"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=DSAuth* Message=\"*not found in athena customer AuthDomains*\" | dedup AuthDomain | top limit=1 AuthDomain |
eval alertMessage=\"*Production Athena*:
AlertType = Error 
One or more auth domains not found in an athena customer. 
``` sourcetype=ath:services ServiceName=DSAuth* Message=\\"*not found in athena customer AuthDomains*\\"```
\"  | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if auth domains not found in an athena customer"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$

Confluence: https://info.citrite.net/pages/viewpage.action?pageId=1381595811"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_dsauthweb_is_failing_to_get_the_oidc_token_51" {
  name                     = "Athena: DSAuthWeb is failing to get the OIDC token_51"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=DSAuth* Message=\"The OpenID Connect Token request, returned Http status code: BadRequest\" | dedup AuthDomain | top limit=1 AuthDomain |
eval alertMessage=\"*Production Athena*:
AlertType = Error 
DSAuthWeb is failing to get the OIDC token for one or more customers. 
``` sourcetype=ath:services ServiceName=DSAuth* Message=\\"The OpenID Connect Token request, returned Http status code: BadRequest\\"```
\"  | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if OpenID Connect Token request returned Http status code: BadRequest"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$
Please execute this <https://info.citrite.net/x/s4aVVg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "workspace_dns_service_failure_52" {
  name                     = "Workspace: DNS Service Failure_52"
  search                   = <<EOT
"index=\"productiongov_cc_services\" \"UpsertCustomerDomain: An error occurred while calling the DNS service: HttpRequestException : Response status code does not indicate success: 500 (Internal Server Error).\" index=productiongov_cc_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there is an Error when calling the DNS Service while trying to Upsert Customer Domain "
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#ws-exp-alerts"
  action_slack_param_message = <<EOT
">>> *Production US Gov Workspace: DNS Service Failure*
AlertType = Error 
Error while trying to Upsert Customer Domain.  Please check Splunk `index="productiongov_cc_services" "An error occurred while calling the DNS service"` for more information.
This could mean the limit to assign subdomains in Route53 has been hit."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "redisconnectionexception_53" {
  name                     = "RedisConnectionException_53"
  search                   = <<EOT
"index=\"productiongov_cc_services\" \"RedisConnectionException\" index=productiongov_cc_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there is a RedisConnection Exception being thrown"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#cc-alerts"
  action_slack_param_message = <<EOT
">>> *Production US GOV: RedisConnectionException* 
AlterType = Error 
RedisConnectionException is being  thrown.  Please check Splunk `index="productiongov_cc_services" "RedisConnectionException"` for more information.
This could mean Redis instances are hitting machine thresholds"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_too_many_token_requests_54" {
  name                     = "Athena: Too Many Token Requests_54"
  search                   = <<EOT
"/core/connect/token ServiceName=Tokens LayerName=Production1 \"Method=TokensService.GetTokenAsync\" \"EventType=Performance\"  \"RequestType=PostLogin\" | bucket span=1d _time |stats count  by _time AuthDomainName | stats sum(count) as count avg(count) as avg by AuthDomainName | where avg > 1000 index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the there are calls to Token with an abnormal average"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Production:*
 AlertType = Error 
There are calls to Tokens with an abnormal average 
```  /core/connect/token ServiceName=Tokens LayerName=Production1 "Method=TokensService.GetTokenAsync" "EventType=Performance"  "RequestType=PostLogin" | bucket span=1d _time |stats count  by _time AuthDomainName | stats sum(count) as count avg(count) as avg by AuthDomainName ```
Possible issue can affect the Redis CPU and Server Load, please review splunk and follow <https://info.citrite.net/x/clnSVQ | this runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_redis_retries_55" {
  name                     = "Athena: Redis Retries_55"
  search                   = <<EOT
"index=\"productiongov_ath_services\" \"redis retry operation\" | top limit=1 TransactionId |
eval alertMessage = \"*Athena - Production:*
 AlertType = Error 
 There are Redis retry operation events with abnormal count
```index=\\"productiongov_ath_services\\" \\"redis retry operation\\"```
Possible issue with Redis Connections, please review splunk and start a call if needed
\" | stats list(alertMessage) as alertMessage index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there are Redis retry operation events with abnormal count"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.alertMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "failed_to_process_cip_cred_in_dsauthweb2_gov_56" {
  name                     = "Failed to process cip_cred in DSAuthWeb2 Gov_56"
  search                   = <<EOT
"sourcetype=\"ath:services\" ServiceName=DSAuth-Web2 EventType=Error Method=\"*OidcRequestTokenResponseFactory.CreateCredentialWalletReferenceFromCipCred*\" index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena Gov - Production: This alert is triggered when DSAuthWeb2 cannot process the cip_cred provided in the ID Token. Please review the Splunk query for more details"
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "WorkspaceAdmins@citrix.com"
  action_email_subject     = "Failed to process cip_cred in DSAuthWeb2 Gov"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Production:*
 DSAuthWeb2 cannot process the cip_cred: $result.ErrorMessage$
 Check Splunk to determine what the error is. If there is a decryption error and there has been a recent roll-out, then a service roll back may be required 
``` sourcetype="ath:services" ServiceName=DSAuth-* EventType=Error Method="*OidcRequestTokenResponseFactory.CreateCredentialWalletReferenceFromCipCred*"```"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_poa_monitor_57" {
  name                     = "Athena POA Monitor_57"
  search                   = <<EOT
"ServiceName=PatchMonitor RecordType=UpdateResult 
| eval currentxTimeStamp=now() 
| eval operationUnixTimeStamp=strptime(OperationTime,\"%Y-%m-%dT%H:%M:%S.%N\") 
| where currentxTimeStamp-operationUnixTimeStamp<3600 
| fields RegionName, LayerName, NodeName, OperationTime,OperationResult 
| join NodeName [search  ServiceName=PatchMonitor RecordType=UpdateDetail 
| rex \"[ |(]KB(?<KB>\d*)\"] 
| table RegionName, LayerName, NodeName, OperationTime, OperationResult, KB index=productionjp_ath_services OR index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"The alert to summarize recent POA result"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "00 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#cc-poa"
  action_slack_param_message = <<EOT
"> *Region:* $result.RegionName$ | *Node Name:* $result.NodeName$ | *Patch Time:* $result.OperationTime$ | *Result:* $result.OperationResult$ | *KB:* <http://www.catalog.update.microsoft.com/Search.aspx?q=KB$result.KB$|$result.KB$>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "marketplace_gov_failed_logins_using_ui_connect_button_58" {
  name                     = "Marketplace GOV- Failed logins using UI Connect button_58"
  search                   = <<EOT
"EventType=Error (ServiceName=Identity OR ServiceName=Identity4) (redirect_uri=https%3A%2F%2Fportal.azure.com%2FTokenAuthorize OR redirect_uri=https:%2F%2Fportal.azure.com%2FTokenAuthorize OR redirect_uri=https://portal.azure.com/TokenAuthorize) \"InnerExceptionMessage=The client with the specified Api Key was not found\" index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Failed to login using Marketplace UI blade Connect button due to updated/deleted Marketplace Athena client "
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "0 * * * *"
  action_email_to          = "workspaceadmins@citrix.comCC-Apollo@citrite.net"
  action_email_subject     = "Marketplace GOV- Failed logins using UI Connect button"
  action_slack_param_channel = "#cc-apollo-alerts"
  action_slack_param_message = <<EOT
"[Marketplace GOV] Interfaces: Failed logins using UI Connect button"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_invalid_autorization_token_59" {
  name                     = "Athena GOV: Invalid Autorization token_59"
  search                   = <<EOT
"EventType=Error \"Authorization token is not valid at the current time.\" 
| stats count by RegionName 
| table RegionName,count index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"If you receive this alert it means Token is Expired or start date is set to a future date. Please check token's validity and reach out to Athena Squad. Refer to https://info.citrite.net/display/CWC/Athena+Regional+Failover+Runbook to perform failover if this is region specific."
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena GOV: Invalid Autorization token"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *ATHENA-PRODUCTION GOV:* Invalid Authorization token error in $result.RegionName$ Region. Please check Splunk for more details using below query:``` EventType=Error "Authorization token is not valid at the current time."| table RegionName```. This can be a problem with the Secure Time Seeding Windows service and a clock skew affecting the cosmos db auth tokens. Refer to <https://info.citrite.net/display/CWC/Athena+Regional+Failover+Runbook |This Runbook> to perform failover if this is region specific."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/a6479c7a2ce24497b7155138378f46f9/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_request_timed_out_60" {
  name                     = "Athena GOV : Request timed out_60"
  search                   = <<EOT
"\"ExceptionMessage=Message: Request timed out.\" index=productiongov_ath_services | eval StartTime='-1h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if there are Request timed outs. Please review logs with Athena squad and if necessary start a call."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "59 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *Athena Production GOV: Request timed outs *
AlertType = Error 
 Please check Splunk ```index= productiongov_ath_services "ExceptionMessage=Message: Request timed out."``` 
<https://citrixsys.splunkcloud.com/en-US/app/search_citrixcloud/search?earliest=-1h%40h&latest=now&q=search%20index%3Dproductiongov_ath_services%20%22ExceptionMessage%3DMessage%3A%20Request%20timed%20out.%22&display.page.search.mode=verbose&dispatch.sample_ratio=1&sid=1607593394.13783_4E9D7071-E8BE-4313-B11D-38123ECCBC13 | US Splunk logs> 
<https://citrixeu.splunkcloud.com/en-GB/app/search_citrixcloud/search?earliest=-1h%40h&latest=now&q=search%20index%3Dproductiongov_ath_services%20%22ExceptionMessage%3DMessage%3A%20Request%20timed%20out.%22&sid=1607611542.1027877&display.page.search.mode=verbose&dispatch.sample_ratio=1 | EU Splunk logs>
Please review logs with Athena squad and if necessary start a call."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/a6479c7a2ce24497b7155138378f46f9/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_throttled_cosmosdb_request_61" {
  name                     = "Athena GOV Throttled CosmosDB Request_61"
  search                   = <<EOT
"cosmosdb-error-429 ServiceName!=NULL | stats count by ServiceName,RegionName,LayerName | where count>100 | fields RegionName,LayerName,ServiceName,count index=productiongov_ath_services | eval StartTime='-14m' | eval EndTime='now'"
EOT
  description              =<<EOT
"SOP : https://info.citrite.net/pages/viewpage.action?spaceKey=CWC&title=Azure+Cosmos+DB+Throttling+Issue"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/14 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">Throttled CosmosDB GOV requests in last 15 mins, <https://info.citrite.net/pages/viewpage.action?spaceKey=CWC&title=Azure+Cosmos+DB+Throttling+Issue|Runbook>
> *Region:* $result.RegionName$ *Layer:* $result.LayerName$ *Service Name:* $result.ServiceName$ *Count:* $result.count$
> 
```index=production*_ath_services cosmosdb-error-429 ServiceName!=NULL | stats count by ServiceName,RegionName,LayerName | where count>100 | fields RegionName,LayerName,ServiceName,count```"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_alert_for_invalid_refresh_token_error_62" {
  name                     = "Athena Alert for Invalid Refresh Token Error._62"
  search                   = <<EOT
"(ServiceName=Identity4 Message=\"Invalid refresh token\") OR (ServiceName=DSAuth-Web2 Message=\"Long lived token not found\") | transaction CallerIp OR ClientId | where eventcount > 200 index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"To alert for too many invalid Refresh Token Error. SOP: https://info.citrite.net/display/CWC/Invalid+Refresh+Token+Error+Runbook"
EOT
  disabled                 = true
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "0 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Alert for Invalid Refresh Token Error."
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
"Athena: Too many invalid refresh token error. https://info.citrite.net/display/CWC/Invalid+Refresh+Token+Error+Runbook"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "slow_http_requests_detected_runbook_63" {
  name                     = "Slow HTTP Requests Detected Runbook_63"
  search                   = <<EOT
"ServiceName=Identity4 ExceptionMessage=\"Reading the request body timed out due to data arriving too slowly.*\" | stats count | search count > 200 index=productiongov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered whenever 'Reading the request body timed out due to data arriving too slowly.' is detected in a service. Link to Runbook: https://info.citrite.net/display/CWC/Slow+HTTP+Requests+Detected+Runbook"
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Slow HTTP Requests Detected Runbook"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> *ATHENA-PRODUCTION GOV*: One of the services in Athena is rejecting requests because of the HTTP request data is arriving too slowly
Splunk Query: ```index="productiongov_ath_services" "Reading the request body timed out due to data arriving too slowly."``` 
Please execute this <https://info.citrite.net/display/CWC/Slow+HTTP+Requests+Detected+Runbook|Runbook>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/a6479c7a2ce24497b7155138378f46f9/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_failover_failure_gov_64" {
  name                     = "Athena Failover Failure (Gov)_64"
  search                   = <<EOT
"ServiceName=AutoFailover \"The failover operation could not be completed. Failover requirements not met.\" OR (Method=FailoverManager.Failover exception) | stats count | search count > 0 index=productiongov_csgops_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a failover cannot be completed due to a failover requirement not being met or another miscellaneous exception."
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Failover Failure (Gov)"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Failover Operation Failed * 
The AutoFailover service has encountered an error while attempting to failover an unhealthy region.
Please execute this <https://info.citrite.net/x/s4aVVg>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_failover_limit_reached_gov_65" {
  name                     = "Athena Failover Limit Reached (Gov)_65"
  search                   = <<EOT
"ServiceName=AutoFailover \"The operation would result in more than the maximum allowed disabled regions configured for the product\" |  rex  \"Message=(?<FullMessage>.*)\" | table NumberOfDisabledRegionsAfterOperation, MaximumAllowedNumberOfDisabledRegions, FullMessage index=productiongov_csgops_services | eval StartTime='-7m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when the AutoFailover service can't failover any more regions."
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Failover Limit Reached (Gov)"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*Failover Limit has been reached*
LogMessage: $result.FullMessage$
NumberOfDisabledRegionsAfterOperation: $result.NumberOfDisabledRegionsAfterOperation$
MaximumAllowedNumberOfDisabledRegions: $result.MaximumAllowedNumberOfDisabledRegions$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_failover_notification_production_gov_66" {
  name                     = "Athena Failover Notification Production (Gov)_66"
  search                   = <<EOT
"ServiceName=AutoFailover Product=Athena \"The failover operation completed successfully\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=production_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthEvents HealthScore!=0)| rex \"HealthEvents=(?<FullHealthEvents>.*) HealthStatus\" | eval MonitoredServiceName = Service | fields TransactionId, FullHealthEvents, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, FullHealthEvents, HealthScore, EventTime index=productiongov_csgops_services | eval StartTime='-7m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a region is failed over."
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Failover Notification Production (Gov)"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*A Failover Operation Occurred*
Event Time: $result.EventTime$
Disabled Region: $result.RegionCode$ was detected.
Failover Reason: $result.FullHealthEvents$
Health Score: $result.HealthScore$
TransactionId: $result.TransactionId$
Runbook: <https://info.citrite.net/x/cvhLWg>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
"The alert condition for '$name$' was triggered.

$description$

Please check runbook: https://info.citrite.net/x/cvhLWg"
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/cvhLWg"}"
EOT
}

resource "splunk_saved_searches" "athena_restore_notification_production_gov_67" {
  name                     = "Athena Restore Notification Production (Gov)_67"
  search                   = <<EOT
"ServiceName=AutoFailover Product=Athena \"The restore operation completed successfully.\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=production_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthScore)| eval MonitoredServiceName = Service | fields TransactionId, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, HealthScore, EventTime index=productiongov_csgops_services | eval StartTime='-7m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a failed over region is restored."
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Restore Notification Production (Gov)"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*A Failover Restore Operation Occurred*
Event Time: $result.EventTime$
Restored Region: $result.RegionCode$
Health Score: $result.HealthScore$
TransactionId: $result.TransactionId$
Runbook: <https://info.citrite.net/x/cvhLWg>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
"The alert condition for '$name$' was triggered.

$description$

Please check runbook: https://info.citrite.net/x/cvhLWg"
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/cvhLWg"}"
EOT
}

resource "splunk_saved_searches" "athena_dryrun_failover_notification_gov_68" {
  name                     = "Athena Dry-Run Failover Notification (Gov)_68"
  search                   = <<EOT
"ServiceName=AutoFailover \"Dry run mode is enabled. Skipping failover operation.\" | stats count | search count > 0 index=productiongov_csgops_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a would-be failover is detected in dry-run mode."
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Dry-Run Failover Notification (Gov)"
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Dry-Run Failover Detected * 
The AutoFailover service has detected an unhealthy service in dry-run mode and has logged a would-be failover that would occur in the region the unhealthy service is located in.
Please review the health of services and refer to this <https://info.citrite.net/display/CWC/Automatic+Failovers|runbook> for next steps."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "autofailover_frontdoor_failover_not_allowed_69" {
  name                     = "Autofailover - Frontdoor failover not allowed_69"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode=\"FdFailoverNotAllowed\"
| rex field=_raw \"Reason=(?<Reason>[^=]+) \" 
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=productiongov_csgops_services | eval StartTime='-7m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Autofailover detects possible FD issues, but for some reason the Failover is not allowed to be performed."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*Possible Frontdoor issues detected at $result.Profile$. Failover was not performed.*
Please see the below details, a manual failover might still be necessary.

>*Failover reason:* $result.FailoverReason$
>*Failover not executed because:*  $result.Reason$
>*Profile:*   $result.Profile$
>*Event Time:*  $result.EventTime$
>*Helpful TransactionId:* $result.TransactionId$ 

*:confluence2: <https://info.citrite.net/x/PLvpYQ|View Runbook>  :splunk: <https://$result.splunk_host$/app/search_citrixcloud/search?q=search%20index%3D$result.index$%20TransactionId%3D$result.TransactionId$&earliest=-15m&latest=now|Search by TransactionId>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/PLvpYQ"}"
EOT
}

resource "splunk_saved_searches" "autofailover_frontdoor_failover_completed_70" {
  name                     = "Autofailover - Frontdoor failover completed_70"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode=\"FdFailoverSuccess\"
| dedup Profile
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=productiongov_csgops_services | eval StartTime='-7m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Frontdoor automatic failover completed."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*Automatic Frontdoor failover completed*

>*Failover reason* $result.FailoverReason$
>*Profile:* $result.Profile$
>*Event Time:* $result.EventTime$
>*Helpful TransactionId:* $result.TransactionId$ 

*:confluence2: <https://info.citrite.net/x/PLvpYQ|View Runbook>  :splunk: <https://$result.splunk_host$/app/search_citrixcloud/search?q=search%20index%3D$result.index$%20TransactionId%3D$result.TransactionId$&earliest=-15m&latest=now|Search by TransactionId>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/PLvpYQ"}"
EOT
}

resource "splunk_saved_searches" "autofailover_frontdoor_failover_error_71" {
  name                     = "Autofailover - Frontdoor failover error_71"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode IN (\"FdFailoverFailed\", \"FdFailoverException\")
| dedup Profile
| rex field=_raw \"Message=(?<Message>[^=]+)\"
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=productiongov_csgops_services | eval StartTime='-7m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Triggered when a Frontdoor automatic failover fails to complete."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/7 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*Error trying to failover Frontdoor for $result.Profile$*
Please see the below details, a manual failover might still be necessary.

>*Failover reason:* $result.FailoverReason$
>*Profile:* $result.Profile$
>*Message:* $result.Message$
>*Event Time:* $result.EventTime$
>*Helpful TransactionId:* $result.TransactionId$ 

*:confluence2: <https://info.citrite.net/x/PLvpYQ|View Runbook>  :splunk: <https://$result.splunk_host$/app/search_citrixcloud/search?q=search%20index%3D$result.index$%20TransactionId%3D$result.TransactionId$&earliest=-15m&latest=now|Search by TransactionId>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/PLvpYQ"}"
EOT
}

resource "splunk_saved_searches" "csp_violation_detected_72" {
  name                     = "Csp Violation detected_72"
  search                   = <<EOT
"sourcetype=\"ath:services\" EventType=Error Message=\"*Csp Violation detected*\" index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Production GOV: This alert is triggered when a csp violation is detected. Runbook: https://info.citrite.net/display/CWC/Csp+Violation+Error+Alerts+Staging+or+Production "
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "0 * * * *"
  action_email_to          = "athena-csp-alert@cloud.com"
  action_email_subject     = "Csp Violation detected"
  action_slack_param_channel = "#athena-csp-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Production GOV:*
 A CSP violation is detected. Check splunk to investigate what the violation is about. Runbook: https://info.citrite.net/display/CWC/Csp+Violation+Error+Alerts+Staging+or+Production 
```index=staginggov_ath_services sourcetype="ath:services" EventType=Error Message="*Csp Violation detected*"```"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_rotation_plan_detected_73" {
  name                     = "Athena Rotation Plan detected_73"
  search                   = <<EOT
"ServiceName=KeyManagement \"Rotation plan created.\" OR \"Rotation plan updated.\" index=productiongov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a rotation plan is detected."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* New Rotation Plan Detected * 
 *ApplicationName*: $result.ApplicationName$ 
 *DiscoveryTime*: $result.DiscoveryTime$ 
 *AgreementTime*: $result.AgreementTime$ 
 *AdvertisementTime*: $result.AdvertisementTime$ 
 *ActivationTime*: $result.ActivationTime$ 
 *CompletionTime*: $result.CompletionTime$ 
 *NewCertThumbprint*: $result.NewCertThumbprint$ 
 *OldCertThumbprint*: $result.OldCertThumbprint$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_rotation_plan_invalid_74" {
  name                     = "Athena Rotation Plan invalid_74"
  search                   = <<EOT
"ServiceName=KeyManagement \"The rotation plan is not realistic.\" OR \"The rotation plan enters Activation phase before certificate is active.\" index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a rotation plan is not realistic."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Invalid Rotation Plan Detected * 
 The team must validate the content of the detected plan. <https://info.citrite.net/display/CWC/Invalid+Rotation+Plan>."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/display/CWC/Invalid+Rotation+Plan"}"
EOT
}

resource "splunk_saved_searches" "athena_rotation_plan_advertisement_phase_75" {
  name                     = "Athena Rotation Plan advertisement phase_75"
  search                   = <<EOT
"ServiceName=KeyManagement \"Rotation plan has entered in advertisement phase.\" index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a rotation plan has entered advertisement phase."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "42 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Rotation Plan reached advertisement phase. * 
 Customers must be notified about the rotation. <https://info.citrite.net/display/CWC/Notify+Customers+for+Saml+Signing+certificate+Rotation>."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_certificate_not_found_after_agreement_76" {
  name                     = "Athena certificate not found after agreement_76"
  search                   = <<EOT
"ServiceName=KeyManagement \"Certificate not found on VM and agreement passed.\" index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a certificate is not found on a VM and agreement phase has passed."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "43 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Athena certificate not found on VM * 
 <https://info.citrite.net/display/CWC/KeyManagement+failing+to+access+the+signing+certificate>."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/display/CWC/KeyManagement+failing+to+access+the+signing+certificate"}"
EOT
}

resource "splunk_saved_searches" "athena_certificate_not_found_after_agreement_and_advertisement_77" {
  name                     = "Athena certificate not found after agreement and advertisement_77"
  search                   = <<EOT
"ServiceName=KeyManagement \"Certificate not found on VM and advertisement passed.\" index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a certificate is not found on a VM and advertisement phase has passed."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "45 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Athena certificate not found on VM * 
 <https://info.citrite.net/display/CWC/KeyManagement+failing+to+access+the+signing+certificate>."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/display/CWC/KeyManagement+failing+to+access+the+signing+certificate"}"
EOT
}

resource "splunk_saved_searches" "athena_samlweb_unable_to_retrieve_a_cert_rotation_plan_78" {
  name                     = "Athena: SamlWeb unable to retrieve a cert rotation plan._78"
  search                   = <<EOT
"ServiceName=SamlWeb EventType=Error \"Error retrieving rotation plan.\" index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered if the SamlWeb service has failures while retrieving the certificate rotation plan."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "44 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Failures to retrieve a Certificate Rotation Plan for SamlWeb. * 
 <https://info.citrite.net/display/CWC/Failures+retrieving+Certificate+Rotation+Plans>."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "samlweb_unable_to_retrieve_a_cert_rotation_plan_pd_79" {
  name                     = "SamlWeb unable to retrieve a cert rotation plan PD_79"
  search                   = <<EOT
"ServiceName=SamlWeb EventType=Error \"Error retrieving rotation plan.\" index=productiongov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered if the SamlWeb service has, at least 2, failures while retrieving the certificate rotation plan."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "44 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* Failures to retrieve a Certificate Rotation Plan for SamlWeb. * 
 <https://info.citrite.net/display/CWC/Failures+retrieving+Certificate+Rotation+Plans>."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/display/CWC/Failures+retrieving+Certificate+Rotation+Plans"}"
EOT
}

resource "splunk_saved_searches" "samlweb_cannot_find_the_certificate_to_use_for_signing_80" {
  name                     = "SamlWeb cannot find the certificate to use for signing_80"
  search                   = <<EOT
"ServiceName=SamlWeb SamlCertificateException SamlException \"InnerExceptionMessage=The X.509 certificate with find type FindByThumbprint and value * could not be found in the LocalMachine My X.509 store.\" index=productiongov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when SamlWeb cannot find a certificate in the local store that matches the thumbprint in the active phase of the current rotation plan."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* SamlWeb cannot find the certificate to use for signing. * 
 This will create customer downtime, execute <https://info.citrite.net/display/CWC/SamlWeb+failing+to+access+the+signing+certificate>."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/display/CWC/SamlWeb+failing+to+access+the+signing+certificate"}"
EOT
}

resource "splunk_saved_searches" "athena_production_gov_features_circuit_breaker_opened_81" {
  name                     = "Athena Production Gov - Features Circuit Breaker Opened_81"
  search                   = <<EOT
"sourcetype=ath:services \"Features Circuit Breaker Opened.\" \"EventType=Information\" index=productiongov_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Detects if Features Circuit Breaker Opened for a specified Node"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/5 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*Features Circuit Breaker Opened*

> *ServiceName*: $result.ServiceName$

Please execute this Runbook: <https://info.citrite.net/x/KzBiYg|runbook>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/KzBiYg"}"
EOT
}

resource "splunk_saved_searches" "athena_too_many_email_notifications_for_updates_in_principals_82" {
  name                     = "Athena: Too many email notifications for updates in principals_82"
  search                   = <<EOT
"sourcetype=\"ath:services\" Message=\"*Email notification succeeded for change in principal account*\" index=productiongov_ath_services | eval StartTime='-240m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when too many email notifications were sent for updates in principals accounts."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "11 */4 * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"*Too many email notifications were sent for updates in principals accounts.* 
 <https://info.citrite.net/display/CWC/Too+Many+Notification+Emails+for+updates+in+principals+accounts>."
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/710ee052b75c480ac00421cc14d4fa3d/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_blocknonfrontdoortraffic_feature_update_fails_83" {
  name                     = "Athena Gov: BlockNonFrontDoorTraffic Feature Update fails_83"
  search                   = <<EOT
"sourcetype=ath:services ```Get all events in last 5 mins.```
| where ServiceName in (\"ActiveDirectoryWeb\", \"CertAuthWeb\", \"DSAuth-Web2\", \"Identity4\", \"SamlWeb\", \"ShareFileWeb\")
| stats count by ServiceName, host, source 
| join type=left left=L right=R where L.ServiceName=R.ServiceName L.host=R.host L.source=R.source ```Left join to get all Services:hosts```
    [search index=productiongov_ath_services sourcetype=ath:services \"Feature set to\" earliest=-10m ```Get \"Feature set to\" events to track this heartbeat message```
    | where ServiceName in (\"ActiveDirectoryWeb\", \"CertAuthWeb\", \"DSAuth-Web2\", \"Identity4\", \"SamlWeb\", \"ShareFileWeb\")
    | stats count by ServiceName, host, source]
| rename R.count AS countPerNode
| eval finalcount=if(isnull(countPerNode),0,countPerNode)
| where finalcount < 1
| rename L.source AS source_l
| eval sourcesplit=split(source_l,\"/\") ```Split source to get region and env```
| eval region=mvindex(sourcesplit, 2)
| eval env=mvindex(sourcesplit, 1)
| fields * region env
| rename env AS environment
| strcat \"BlockNonFrontDoorTraffic Feature update issue for \",environment,\":\",region,\":\",L.ServiceName,\" in host \",L.host message
| fields message
| mvcombine message delim=\",\"
| nomv message
| rex mode=sed field=message \"s/,/\n/g\" index=productiongov_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the background task to update BlockNonFrontDoorTraffic Feature in Services fail"
EOT
  disabled                 = true
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
">>> $result.message$
Please execute this <https://info.citrite.net/x/wofyXg|runbook>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/f43b76cc5258471796a205c42f8648aa/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/wofyXg"}"
EOT
}

resource "splunk_saved_searches" "athena_gov_frontdoorverification_blocking_requests_84" {
  name                     = "Athena Gov: FrontDoorVerification blocking requests_84"
  search                   = <<EOT
"sourcetype=ath:services \"Failed FrontDoor Verification\" \"EventType=Error\" | stats count by ServiceName | where count > 100 | strcat \"FrontDoorVerification failed for \",ServiceName,\" with update count: \",count message | fields message | mvcombine message delim=\",\" | nomv message | rex mode=sed field=message \"s/,/\n/g\" index=productiongov_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the FrontDoor validation in services fails"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/5 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
": FrontDoorVerification blocking requests >>> $result.message$
Please execute this <https://info.citrite.net/x/vUXIXg|runbook>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/f43b76cc5258471796a205c42f8648aa/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/x/vUXIXg"}"
EOT
}

resource "splunk_saved_searches" "athena_gov_ui_files_are_missing_identity6_85" {
  name                     = "Athena Gov: UI files are missing - Identity6_85"
  search                   = <<EOT
"EventType=Error \"Unable to find the specified file.\" index=productiongov_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when UI files are missing from an Identity6 node, after release"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/11 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts"
  action_slack_param_message = <<EOT
"* UI files are missing from an Identity6 node * 
Please execute this Runbook: <https://info.citrite.net/display/CWC/UI+files+are+missing+in+Identity6|runbook>"
EOT
  action_pagerduty_integration_url = "https://events.pagerduty.com/integration/89d8c00606974707c0dba6feae2f2b85/enqueue"
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
"{"description":"$description$","runbook_url":"https://info.citrite.net/display/CWC/UI+files+are+missing+in+Identity6"}"
EOT
}
