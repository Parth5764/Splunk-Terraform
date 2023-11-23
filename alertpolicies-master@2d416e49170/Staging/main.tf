
resource "splunk_saved_searches" "athena_pen_test_user_delete_calls_1" {
  name                     = "Athena Pen Test user delete calls_1"
  search                   = <<EOT
"sourcetype=ath:services ClientName=ath_pen_testuser_2019_* HTTP/* DELETE
| bin span=5m _time index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered whenever the athena pentest users make a delete call."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"Staging Athena: Alert is triggered whenever the athena pentest users make a delete call : $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_alert_for_dsauth_throttling_2" {
  name                     = "Athena Alert for DSAuth throttling._2"
  search                   = <<EOT
"\"Not building the domain contexts due to throttling\" | stats count by ServiceInstanceIp | where count > 50 index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"To alert throttling customers too aggressively in Athena. If alerted Correlate log's ServiceInstanceIp key to its respective value for scaleset and node ID, restart nodeID through CC Dashboard."
EOT
  disabled                 = true
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"Athena: DSAuth throttling customers too aggressively."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "alert_for_athena_authdomain_3" {
  name                     = "Alert for Athena AuthDomain._3"
  search                   = <<EOT
"\"sourcetype=ath:services ServiceName=DSAuth* Message=\"not found in athena customer AuthDomains\" | stats count by AuthDomain\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-30m' | eval EndTime='now'"
EOT
  description              =<<EOT
"AuthDomain not found in Athena Customer.
 Link to SOP - https://info.citrite.net/pages/viewpage.action?pageId=1381595811"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/30 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"Staging Athena: One or more auth domains not found in an athena customer : $result.ErrorMessage$"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_not_redirecting_to_logon_page_4" {
  name                     = "Athena not redirecting to Logon Page_4"
  search                   = <<EOT
"ServiceName=DSAuth-Web2 RequestUri=\"*webview*\" Message=\"Error looking up auth domain:*\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Staging: Failing to redirect from DSAuth-Web to Identity to show the Logon Page: Error looking up auth domain. See: https://info.citrite.net/display/CWC/DSAuthWeb2+Logon+page+not+available+cross-geo"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> *Athena - Staging:*
There are an abnormal count of failures to get redirect to the Logon Page: $result.ErrorMessage$
```index=staging_ath_services ServiceName=DSAuth-Web2 RequestUri="*webview*" Message="Error looking up auth domain:*"```
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

resource "splunk_saved_searches" "signing_key_not_found_in_dsauthweb2_5" {
  name                     = "Signing key not found in DSAuthWeb2_5"
  search                   = <<EOT
"sourcetype=\"ath:services\" ServiceName=DSAuth-Web2 EventType=Error \"No appropriate signing key found in the discovery document.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Staging: This alert is triggered when DSAuthWeb2 cannot find appropriate signing key in the discovery document. Possible root cause could be an upgrade in Identity4 causing changes in kid. Please check <https://accounts.cloud.com/core/.well-known/openid-configuration/jwks>"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> *Athena - Staging:*
 There are failures in DSAuthWeb2 when trying to find signing key in the discovery document: $result.ErrorMessage$
```index=staging_ath_services sourcetype="ath:services" ServiceName=DSAuth-* EventType=Error "No appropriate signing key found in the discovery document."```
Possible root cause could be an upgrade in Identity4 causing changes in kid. Please check <https://accounts.cloudburrito.com/core/.well-known/openid-configuration/jwks>.
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

resource "splunk_saved_searches" "athena_dsauthweb_500_errors_6" {
  name                     = "Athena: DSAuthWeb 500 Errors_6"
  search                   = <<EOT
"index=staging_ath_services sourcetype=ath:services ServiceName=DSAuth-Web2 500 | stats count AS number_of_issues |
eval alertMessage=\"*Staging Athena: 
AlertType = Error 
 Showing an increased level of 500 errors in DSAuthWeb.  Check in Splunk and warn the @cc-athena-squad\". 
\"`staging_ath_services sourcetype=ath:services ServiceName=DSAuth-Web2 500`\"  | stats list(alertMessage) as alertMessage index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the number of errors in DSAuthWeb is at an increased level of 500"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "athena_dsauthweb_500_errors_7" {
  name                     = "Athena: DSAuthWeb 500 Errors_7"
  search                   = <<EOT
"index=staging_ath_services sourcetype=ath:services ServiceName=DSAuth-Web2 500 | stats count AS number_of_issues |
eval alertMessage=\"*Staging Athena: 
AlertType = Error 
 Showing an increased level of 500 errors in DSAuthWeb.  Check in Splunk and warn the @cc-athena-squad\". 
\"`index=staging_ath_services sourcetype=ath:services ServiceName=DSAuth-Web2 500`\"  | stats list(alertMessage) as alertMessage index=staging_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the number of errors in DSAuthWeb is at an increased level of 500"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "athena_dsauthweb_is_failing_to_get_the_oidc_token_8" {
  name                     = "Athena: DSAuthWeb is failing to get the OIDC token_8"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=DSAuth* Message=\"The OpenID Connect Token request, returned Http status code: BadRequest\" | dedup AuthDomain | top limit=1 AuthDomain |
eval alertMessage=\"*Staging Athena*: DSAuthWeb is failing to get the OIDC token for one or more customers.
 AlertType=Error 
```index=staging_ath_services sourcetype=ath:services ServiceName=DSAuth* Message=\\"The OpenID Connect Token request, returned Http status code: BadRequest\\"```
\"  | stats list(alertMessage) as alertMessage index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if OpenID Connect Token request returned Http status code: BadRequest"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "athenadsauthweb_is_failing_to_get_the_oidc_token_9" {
  name                     = "Athena:DSAuthWeb is failing to get the OIDC token_9"
  search                   = <<EOT
"index=staging_ath_services sourcetype=ath:services ServiceName=DSAuth* Message=\"The OpenID Connect Token request, returned Http status code: BadRequest\" | dedup AuthDomain | top limit=1 AuthDomain |
eval alertMessage=\"*Staging Athena*: DSAuthWeb is failing to get the OIDC token for one or more customers.
 AlertType=Error 
```index=staging_ath_services sourcetype=ath:services ServiceName=DSAuth* Message=\\"The OpenID Connect Token request, returned Http status code: BadRequest\\"```
\"  | stats list(alertMessage) as alertMessage index=staging_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if OpenID Connect Token request returned Http status code: BadRequest"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "failed_to_process_cip_cred_in_dsauthweb2_10" {
  name                     = "Failed to process cip_cred in DSAuthWeb2_10"
  search                   = <<EOT
"sourcetype=\"ath:services\" ServiceName=DSAuth-Web2 EventType=Error Method=\"*OidcRequestTokenResponseFactory.CreateCredentialWalletReferenceFromCipCred*\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Staging: This alert is triggered when DSAuthWeb2 cannot process the cip_cred provided in the ID Token. Please review the Splunk query for more details"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> *Athena - Staging:*
 DSAuthWeb2 cannot process the cip_cred: $result.ErrorMessage$
 Check Splunk to determine what the error is. If there is a decryption error and there has been a recent roll-out, then a service roll back may be required 
```index=staging_ath_services sourcetype="ath:services" ServiceName=DSAuth-* EventType=Error Method="*OidcRequestTokenResponseFactory.CreateCredentialWalletReferenceFromCipCred*"```"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_invalid_autorization_token_11" {
  name                     = "Athena: Invalid Autorization token_11"
  search                   = <<EOT
"EventType=Error \"Authorization token is not valid at the current time.\" 
| stats count by RegionName 
| table RegionName,count index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"If you receive this alert it means Token is Expired or start date is set to future date. please check token's validity and reachout to Athena Squad"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> *ATHENA-STAGING:* Invalid Authorization token error in $result.RegionName$ Region. Please check Splunk for more details using below query: ```index=staging_ath_services EventType=Error "Authorization token is not valid at the current time."| table RegionName``` This can be a problem with the Secure Time Seeding Windows service and a clock skew affecting the cosmos db auth tokens. Refer to <https://info.citrite.net/display/CWC/Athena+Regional+Failover+Runbook |This Runbook> to perform failover if this is region specific."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_throttled_cosmosdb_request_12" {
  name                     = "Athena Throttled CosmosDB Request_12"
  search                   = <<EOT
"cosmosdb-error-429 ServiceName!=NULL | stats count by ServiceName,RegionName,LayerName | where count>100 | fields RegionName,LayerName,ServiceName,count index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"SOP : https://info.citrite.net/pages/viewpage.action?spaceKey=CWC&title=Azure+Cosmos+DB+Throttling+Issue"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">Throttled CosmosDB requests in last 15 mins, <https://info.citrite.net/pages/viewpage.action?spaceKey=CWC&title=Azure+Cosmos+DB+Throttling+Issue|Runbook>
> *Region:* $result.RegionName$ *Layer:* $result.LayerName$ *Service Name:* $result.ServiceName$ *Count:* $result.count$
> 
```index=staging*_ath_services cosmosdb-error-429 ServiceName!=NULL | stats count by ServiceName,RegionName,LayerName | where count>100 | fields RegionName,LayerName,ServiceName,count```"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_synthetic_client_secret_expiration_monitoring_13" {
  name                     = "Athena Synthetic Client Secret Expiration Monitoring_13"
  search                   = <<EOT
"HostedRoleName=\"AthenaClientsMonitorWorker\"  | search Owner = \"athena-squad@cloud.com\"  ExpirationDate!=\"1/1/0001\" | eval od = strptime(ExpirationDate,\"%m/%d/%Y\") | eval td = now() | eval daysLeft = round(( od-td )/86400,0) | where daysLeft >= 0 AND daysLeft <= 30 | dedup APIKey | table ClientName, APIKey, Owner, ExpirationDate index=staging_csgops_services | eval StartTime='-24h' | eval EndTime='now'"
EOT
  description              =<<EOT
"Please follow the SOP to rotate Athena client secrets: https://info.citrite.net/pages/viewpage.action?spaceKey=CWC&title=Athena+Client+Secret+Rotation"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "00 11 * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> *STAGING*: Warning! Athena client is due rotation.
>*ClientName* : $result.ClientName$
>*APIKey* : $result.APIKey$
>*Owner* : $result.Owner$
>*ExpirationDate* : $result.ExpirationDate$
>Please review Splunk($results_link$) and follow <https://info.citrite.net/pages/viewpage.action?spaceKey=CWC&title=Athena+Client+Secret+Rotation | Runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_failover_failure_14" {
  name                     = "Athena Failover Failure_14"
  search                   = <<EOT
"ServiceName=AutoFailover \"The failover operation could not be completed. Failover requirements not met.\" OR (Method=FailoverManager.Failover exception) | stats count | search count > 0 index=staging_csgops_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a failover cannot be completed due to a failover requirement not being met or another miscellaneous exception."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "athena_failover_notification_staging_15" {
  name                     = "Athena Failover Notification Staging_15"
  search                   = <<EOT
"ServiceName=AutoFailover Product=Athena \"The failover operation completed successfully\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=staging_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthEvents)| rex \"HealthEvents=(?<FullHealthEvents>.*) HealthStatus\" | eval MonitoredServiceName = Service | fields TransactionId, FullHealthEvents, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, FullHealthEvents, HealthScore, EventTime index=staging_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a region is failed over."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"*A Failover Operation Occurred*
Event Time: $result.EventTime$
Disabled Region: $result.RegionCode$ was detected.
Failover Reason: $result.FullHealthEvents$
Health Score: $result.HealthScore$
TransactionId: $result.TransactionId$
Runbook: <https://info.citrite.net/x/cvhLWg>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_failover_notification_staging_japan_16" {
  name                     = "Athena Failover Notification Staging Japan_16"
  search                   = <<EOT
"ServiceName=AutoFailover Product=AthenaJP \"The failover operation completed successfully\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=stagingjp_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthEvents)| rex \"HealthEvents=(?<FullHealthEvents>.*) HealthStatus\" | eval MonitoredServiceName = Service | fields TransactionId, FullHealthEvents, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, FullHealthEvents, HealthScore, EventTime index=staging_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a region is failed over."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"*A Failover Operation Occurred*
Event Time: $result.EventTime$
Disabled Region: $result.RegionCode$ was detected.
Failover Reason: $result.FullHealthEvents$
Health Score: $result.HealthScore$
TransactionId: $result.TransactionId$
Runbook: <https://info.citrite.net/x/cvhLWg>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_restore_notification_staging_17" {
  name                     = "Athena Restore Notification Staging_17"
  search                   = <<EOT
"ServiceName=AutoFailover Product=Athena \"The restore operation completed successfully.\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=staging_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthScore)| eval MonitoredServiceName = Service | fields TransactionId, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, HealthScore, EventTime index=staging_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a failed over region is restored."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"*A Failover Restore Operation Occurred*
Event Time: $result.EventTime$
Restored Region: $result.RegionCode$
Health Score: $result.HealthScore$
TransactionId: $result.TransactionId$
Runbook: <https://info.citrite.net/x/cvhLWg>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_restore_notification_staging_japan_18" {
  name                     = "Athena Restore Notification Staging Japan_18"
  search                   = <<EOT
"ServiceName=AutoFailover Product=AthenaJP \"The restore operation completed successfully.\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=stagingjp_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthScore)| eval MonitoredServiceName = Service | fields TransactionId, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, HealthScore, EventTime index=staging_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a failed over region is restored."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"*A Failover Restore Operation Occurred*
Event Time: $result.EventTime$
Restored Region: $result.RegionCode$
Health Score: $result.HealthScore$
TransactionId: $result.TransactionId$
Runbook: <https://info.citrite.net/x/cvhLWg>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_dryrun_failover_notification_19" {
  name                     = "Athena Dry-Run Failover Notification_19"
  search                   = <<EOT
"ServiceName=AutoFailover \"Dry run mode is enabled. Skipping failover operation.\" | stats count | search count > 0 index=staging_csgops_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a would-be failover is detected in dry-run mode."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "autofailover_frontdoor_failover_not_allowed_20" {
  name                     = "Autofailover - Frontdoor failover not allowed_20"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode=\"FdFailoverNotAllowed\"
| rex field=_raw \"Reason=(?<Reason>[^=]+) \" 
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=staging_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Autofailover detects possible FD issues, but for some reason the Failover is not allowed to be performed."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "autofailover_frontdoor_failover_completed_21" {
  name                     = "Autofailover - Frontdoor failover completed_21"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode=\"FdFailoverSuccess\"
| dedup Profile
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=staging_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Triggered when a Frontdoor automatic failover is completed."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"*Automatic Frontdoor failover completed*

>*Failover reason* $result.FailoverReason$
>*Profile:* $result.Profile$
>*Event Time:* $result.EventTime$
>*Helpful TransactionId:* $result.TransactionId$ 

*:confluence2: <https://info.citrite.net/x/PLvpYQ|View Runbook>  :splunk: <https://$result.splunk_host$/app/search_citrixcloud/search?q=search%20index%3D$result.index$%20TransactionId%3D$result.TransactionId$&earliest=-15m&latest=now|Search by TransactionId>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "autofailover_frontdoor_failover_error_22" {
  name                     = "Autofailover - Frontdoor failover error_22"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode IN (\"FdFailoverFailed\", \"FdFailoverException\")
| dedup Profile
| rex field=_raw \"Message=(?<Message>[^=]+)\"
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=staging_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Triggered when a Frontdoor automatic failover fails to complete."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "excessive_failure_to_authenticate_customers_23" {
  name                     = "Excessive Failure to Authenticate Customers_23"
  search                   = <<EOT
"ServiceName=ActiveDirectory Message=\"Attempt to authenticate user failed\" | stats count | search count > 180 index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered whenever too many 'attempt to authenticate user failed' requests take place in Active Directory. Link to Runbook: https://info.citrite.net/display/CWC/Excessive+Failure+to+Authenticate+Customers"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"> *STAGING*: AD is Showing Excessive Failure to Authenticate Customers!
Splunk Query: ```index="staging_ath_services" ServiceName=ActiveDirectory Message="Attempt to authenticate user failed"``` 
Please execute this <https://info.citrite.net/x/w-JLWg|Runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_alert_for_invalid_refresh_token_error_24" {
  name                     = "Athena Alert for Invalid Refresh Token Error._24"
  search                   = <<EOT
"(ServiceName=Identity4 Message=\"Invalid refresh token\") OR (ServiceName=DSAuth-Web2 Message=\"Long lived token not found\") | transaction CallerIp OR ClientId | where eventcount > 200 index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"To alert for too many invalid Refresh Token Error. SOP: https://info.citrite.net/display/CWC/Invalid+Refresh+Token+Error+Runbook"
EOT
  disabled                 = true
  actions                  = "slack, pagerduty"
  cron_schedule            = "0 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-status"
  action_slack_param_message = <<EOT
"Athena: Too many invalid refresh token errors. SOP: https://info.citrite.net/display/CWC/Invalid+Refresh+Token+Error+Runbook"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "slow_http_requests_detected_runbook_25" {
  name                     = "Slow HTTP Requests Detected Runbook_25"
  search                   = <<EOT
"ServiceName=Identity4 ExceptionMessage=\"Reading the request body timed out due to data arriving too slowly.*\" | stats count | search count > 100 index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered whenever 'Reading the request body timed out due to data arriving too slowly.' is detected in a service. Link to Runbook: https://info.citrite.net/display/CWC/Slow+HTTP+Requests+Detected+Runbook"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"> *STAGING*: One of the services in Athena is rejecting requests because of the HTTP request data is arriving too slowly
Splunk Query: ```index="staging_ath_services" "Reading the request body timed out due to data arriving too slowly."``` 
Please execute this <https://info.citrite.net/display/CWC/Slow+HTTP+Requests+Detected+Runbook|Runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_user_conversion_from_it_to_athena_26" {
  name                     = "Athena: User Conversion from IT to Athena_26"
  search                   = <<EOT
"\"External User with IT alias was successfully converted to athena\" | stats count as UsersConverted 

| appendcols[search index=staging*_ath_services \"Exception while converting login alias from IT to Athena\" 
| stats count as Failed]

| eval alertMessage=\"Number of users converted alias from IT to Athena: \" . UsersConverted . \"Number of failures in the attempt: \" . Failed

| stats list(alertMessage) as alertMessage index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-1d' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows daily summary of number of user alias converted from IT to Athena"
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

resource "splunk_saved_searches" "too_many_sendgrid_email_validation_requests_27" {
  name                     = "Too many SendGrid Email Validation requests_27"
  search                   = <<EOT
"ServiceName=Email Message=\"The SendGrid Email Validation request was performed with the disposable result to*\" | stats count | search count > 100 index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered whenever there are too many SendGrid Email Validation requests to check for a disposable email. Link to Runbook: https://info.citrite.net/display/CWC/Too+many+SendGrid+Email+Validation+requests+for+disposable+email"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"> *STAGING*: Excessive API calls to SendGrid Email Validation API
Splunk Query: ```index="staging_ath_services" ServiceName=Email Message="The SendGrid Email Validation request was performed with the disposable result to*"``` 
Please execute this <https://info.citrite.net/display/CWC/Too+many+SendGrid+Email+Validation+requests+for+disposable+email>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_logins_with_very_large_number_of_groups_28" {
  name                     = "Athena: Logins with very large number of groups_28"
  search                   = <<EOT
"\"Group claimed from cache.\" | stats count as LargeGroupsHandled
| appendcols[search index=\"staging*_ath_services\" \"Cached group key * is not found in cache.\" | stats count as CacheMisses]
| appendcols[search index=\"staging*_ath_services\" \"Creating cache item for Compressed groups failed.\" | stats count as CacheItemNotCeated]

| eval alertMessage=\"Number of successful very large groups logins: \" . LargeGroupsHandled . \"
Number of cache keys not found : \" . CacheMisses . \"
Number of cache items not created : \" . CacheItemNotCeated

| stats list(alertMessage) as alertMessage index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-1d' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows daily summary of users with very large groups."
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

resource "splunk_saved_searches" "athena_autofailover_race_condition_29" {
  name                     = "Athena: Autofailover race condition_29"
  search                   = <<EOT
"ServiceName=\"AutoFailover\" \"Conflicting changes were detected when processing the request. This can happen when there are multiple requests trying to update one profile at the same time.\" index=staging_csgops_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Autofailover race condition has occurred. Need manual validation."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> *STAGING*: Race condition occurred while attempting to perform an autofailover operation.
Splunk Query: ```index="staging_csgops_services" ServiceName="AutoFailover"  "Conflicting changes were detected when processing the request. This can happen when there are multiple requests trying to update one profile at the same time."``` 
Please execute this <https://info.citrite.net/display/CWC/Automatic+Failover+Race+Condition>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_enumerate_resources_for_a_user_failed_30" {
  name                     = "Athena: Enumerate resources for a user failed_30"
  search                   = <<EOT
"ServiceName=BrokerService DalDuplicateRecordException: TX$EnumerateResources index=stagingjp_xaxd_services OR index=staging_xaxd_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Enumerate resources for a user failed due to duplicate entities"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"> *STAGING*: Enumerate resources for a user failed due to duplicate entities. 
SOP: Please use this runbook <https://info.citrite.net/display/CWC/Enumerate+resources+for+a+user+failed+due+to+duplicate+entities>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_authorization_code_is_too_long_31" {
  name                     = "Athena Authorization Code Is Too Long_31"
  search                   = <<EOT
"IdentityServer4.Validation.TokenRequestValidator \"Message=Authorization code is too long\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alerts if the authorization code used is longer than what is configured"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
" *Authorization Code is too Long Error(s)* 
The authorization code during the token exchange is larger than what was configured and was rejected by IdentityServer4. Please review logs with Athena squad and if necessary start a call: 
<https://citrixsys.splunkcloud.com/en-US/app/search_citrixcloud/search?q=search%20index%3Dstaging_ath_services%20%22Message%3DAuthorization%20code%20is%20too%20long%22&&earliest=-60m%40m&latest=now | US Splunk Logs>
<https://citrixeu.splunkcloud.com/en-US/app/search_citrixcloud/search?q=search%20index%3Dstaging_ath_services%20%22Message%3DAuthorization%20code%20is%20too%20long%22&=&earliest=-60m%40m&latest=now&sid=1660081276.19293796&display.page.search.mode=smart&dispatch.sample_ratio=1 | EU Splunk Logs>
Splunk Query: ```index=staging_ath_services IdentityServer4.Validation.TokenRequestValidator "Message=Authorization code is too long"```

<https://info.citrite.net/x/xB_eXg|Confluence SOP>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_frontdoorverification_blocking_requests_32" {
  name                     = "Athena: FrontDoorVerification blocking requests_32"
  search                   = <<EOT
"sourcetype=ath:services \"Failed FrontDoor Verification\" \"EventType=Error\" | stats count by ServiceName | where count > 50 | strcat \"FrontDoorVerification failed for \",ServiceName,\" with update count: \",count message | fields message | mvcombine message delim=\",\" | nomv message | rex mode=sed field=message \"s/,/\n/g\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the FrontDoor validation in services fails"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/5 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
": FrontDoorVerification blocking requests >>> $result.message$
Please execute this <https://info.citrite.net/x/vUXIXg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_blocknonfrontdoortraffic_feature_update_fails_33" {
  name                     = "Athena: BlockNonFrontDoorTraffic Feature Update fails_33"
  search                   = <<EOT
"sourcetype=ath:services ```Get all events in last 5 mins.```
| where ServiceName in (\"ActiveDirectoryWeb\",  \"CertAuthWeb\", \"DSAuth-Web2\", \"Identity4\", \"SamlWeb\", \"ShareFileWeb\")
| stats count by ServiceName, host, source 
| join type=left left=L right=R where L.ServiceName=R.ServiceName L.host=R.host L.source=R.source ```Left join to get all Services:hosts```
	[search index=staging_ath_services sourcetype=ath:services \"Feature set to\" earliest=-10m ```Get \"Feature set to\" events to track this heartbeat message```
	| where ServiceName in (\"ActiveDirectoryWeb\",  \"CertAuthWeb\", \"DSAuth-Web2\", \"Identity4\", \"SamlWeb\", \"ShareFileWeb\")
	| stats count by ServiceName, host, source]
| rename R.count AS countPerNode
| eval finalcount=if(isnull(countPerNode),0,countPerNode)
| where finalcount < 1
| rename L.source AS source_l
| eval sourcesplit=split(source_l,\"/\") ```Split source to get region and env```
| eval region=mvindex(sourcesplit, 2)
| eval env=mvindex(sourcesplit, 3)
| fields * region env
| join type=left left=X right=Y where X.region=Y.region_l X.env=Y.env ```Get a list of inprogress VMSS upgrade environments & regions```
	[search index=production_csgops_services ServiceName=ReleaseWorkflowAgent Product=\"Athena\" Project=VmssImageUpgrade \"Message=Deployment starting.\" earliest=\"-20h\"
	| stats latest(EventTime) AS starttime by Layer, Region
	| join type=left left=S right=E where S.Layer=E.Layer S.Region=E.Region  
		[search index=production_csgops_services ServiceName=ReleaseWorkflowAgent Product=\"Athena\" Project=VmssImageUpgrade \"Message=Deployment completed.\" earliest=\"-20h\"
		| stats latest(EventTime) AS endtime by Layer, Region]
	| rename S.starttime AS starttime_l
	| rename E.endtime AS endtime_l
	| rename S.Layer AS layer_l
	| rename S.Region AS region_l
	| eval isvalid=if(starttime_l>endtime_l,\"NO\",\"YES\")
	| eval env=case(like(layer_l,\"%ProductionInternal%\"),\"AthenaProductionInternal\",like(layer_l,\"%JapanProduction%\"),\"AthenaJapanProduction\",like(layer_l,\"%Production%\"),\"AthenaProduction\",like(layer_l,\"%JapanStaging%\"),\"AthenaStagingJP\",like(layer_l,\"%Staging%\"),\"AthenaStaging\",1=1,\"\") ```Map layer to environment```
	| where isvalid=\"NO\" OR isnull(endtime_l)
	| fields env region_l]
| rename Y.region_l AS region_f
| rename X.env AS environment
| where isnull(region_f)
| strcat \"BlockNonFrontDoorTraffic Feature update issue for \",environment,\":\",X.region,\":\",X.L.ServiceName,\" in host \",X.L.host message
| fields message
| mvcombine message delim=\",\"
| nomv message
| rex mode=sed field=message \"s/,/\n/g\" index=staging_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the background task to update BlockNonFrontDoorTraffic Feature in Services fail"
EOT
  disabled                 = true
  actions                  = "slack"
  cron_schedule            = "*/30 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> $result.message$
Please execute this <https://info.citrite.net/x/wofyXg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_blocknonfrontdoortraffic_feature_update_fails_34" {
  name                     = "Athena: BlockNonFrontDoorTraffic Feature Update fails_34"
  search                   = <<EOT
"sourcetype=ath:services ```Get all events in last 5 mins.```
| where ServiceName in (\"ActiveDirectoryWeb\",  \"CertAuthWeb\", \"DSAuth-Web2\", \"Identity4\", \"SamlWeb\", \"ShareFileWeb\")
| stats count by ServiceName, host, source 
| join type=left left=L right=R where L.ServiceName=R.ServiceName L.host=R.host L.source=R.source ```Left join to get all Services:hosts```
	[search index=stagingjp_ath_services sourcetype=ath:services \"Feature set to\" earliest=-10m ```Get \"Feature set to\" events to track this heartbeat message```
	| where ServiceName in (\"ActiveDirectoryWeb\",  \"CertAuthWeb\", \"DSAuth-Web2\", \"Identity4\", \"SamlWeb\", \"ShareFileWeb\")
	| stats count by ServiceName, host, source]
| rename R.count AS countPerNode
| eval finalcount=if(isnull(countPerNode),0,countPerNode)
| where finalcount < 1
| rename L.source AS source_l
| eval sourcesplit=split(source_l,\"/\") ```Split source to get region and env```
| eval region=mvindex(sourcesplit, 2)
| eval env=mvindex(sourcesplit, 3)
| fields * region env
| join type=left left=X right=Y where X.region=Y.region_l X.env=Y.env ```Get a list of inprogress VMSS upgrade environments & regions```
	[search index=production_csgops_services ServiceName=ReleaseWorkflowAgent Product=\"Athena\" Project=VmssImageUpgrade \"Message=Deployment starting.\" earliest=\"-20h\"
	| stats latest(EventTime) AS starttime by Layer, Region
	| join type=left left=S right=E where S.Layer=E.Layer S.Region=E.Region  
		[search index=production_csgops_services ServiceName=ReleaseWorkflowAgent Product=\"Athena\" Project=VmssImageUpgrade \"Message=Deployment completed.\" earliest=\"-20h\"
		| stats latest(EventTime) AS endtime by Layer, Region]
	| rename S.starttime AS starttime_l
	| rename E.endtime AS endtime_l
	| rename S.Layer AS layer_l
	| rename S.Region AS region_l
	| eval isvalid=if(starttime_l>endtime_l,\"NO\",\"YES\")
	| eval env=case(like(layer_l,\"%ProductionInternal%\"),\"AthenaProductionInternal\",like(layer_l,\"%JapanProduction%\"),\"AthenaJapanProduction\",like(layer_l,\"%Production%\"),\"AthenaProduction\",like(layer_l,\"%JapanStaging%\"),\"AthenaStagingJP\",like(layer_l,\"%Staging%\"),\"AthenaStaging\",1=1,\"\") ```Map layer to environment```
	| where isvalid=\"NO\" OR isnull(endtime_l)
	| fields env region_l]
| rename Y.region_l AS region_f
| rename X.env AS environment
| where isnull(region_f)
| strcat \"BlockNonFrontDoorTraffic Feature update issue for \",environment,\":\",X.region,\":\",X.L.ServiceName,\" in host \",X.L.host message
| fields message
| mvcombine message delim=\",\"
| nomv message
| rex mode=sed field=message \"s/,/\n/g\" index=stagingjp_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the background task to update BlockNonFrontDoorTraffic Feature in Services fail"
EOT
  disabled                 = true
  actions                  = "slack"
  cron_schedule            = "*/30 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> $result.message$
Please execute this <https://info.citrite.net/x/wofyXg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_customer_authdomain_cleanup_failed_35" {
  name                     = "Athena: Customer AuthDomain Cleanup Failed_35"
  search                   = <<EOT
"ServiceName=CustomersWorker ProcessMessage | stats count by IdToCleanup | where count > 10 index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Customer authdomain cleanup failed in customer worker"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/60 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"> *STAGING*: Customer AuthDomain Cleanup Unsuccessful. 
SOP: Please use this runbook <https://info.citrite.net/display/CWC/Customer+AuthDomain+Cleanup+Failed>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_invalid_domain_sid_36" {
  name                     = "Athena: Invalid Domain SID_36"
  search                   = <<EOT
"sourcetype=ath:services ServiceName IN (Okta, Google, Saml, AzureAD, Cip) \"ValidSids=False\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-4h' | eval EndTime='now'"
EOT
  description              =<<EOT
"validate CSP customer cross tenant login"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 */4 * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"> *STAGING*: Invalid Domain SID found. 
SOP: Please use this runbook <https://info.citrite.net/display/CWC/Invalid+Domain+SID+found>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_employee_login_okta_errors_37" {
  name                     = "Athena employee login Okta errors_37"
  search                   = <<EOT
"ServiceName=Identity4 RequestUri=\"https://accounts.cloudburrito.com/core/login-okta\" (Message=\"Error from RemoteAuthentication:*\" OR citritelogin) | transaction TransactionId maxspan=60s | search Message=\"Error from RemoteAuthentication:*\" citritelogin | stats count | where count > 100 index=staging_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Okta authentication errors during employee login"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "0 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"> *STAGING*: Okta authentication errors during employee login. Source: $result.source$
Please execute this: <https://info.citrite.net/x/m7NVXw>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "csp_violation_detected_38" {
  name                     = "Csp Violation detected_38"
  search                   = <<EOT
"sourcetype=\"ath:services\" EventType=Error Message=\"*Csp Violation detected*\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Staging: This alert is triggered when a csp violation is detected. Runbook: https://info.citrite.net/display/CWC/Csp+Violation+Error+Alerts+Staging+or+Production "
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "0 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-csp-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Staging:*
 A CSP violation is detected. Check splunk to investigate what the violation is about. Runbook: https://info.citrite.net/display/CWC/Csp+Violation+Error+Alerts+Staging+or+Production (For japan use stagingjp index) 
```index=staging_ath_services sourcetype="ath:services" EventType=Error Message="*Csp Violation detected*"```"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_rotation_plan_detected_39" {
  name                     = "Athena Rotation Plan detected_39"
  search                   = <<EOT
"ServiceName=KeyManagement \"Rotation plan created.\" OR \"Rotation plan updated.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a rotation plan is detected."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "40 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "athena_rotation_plan_invalid_40" {
  name                     = "Athena Rotation Plan invalid_40"
  search                   = <<EOT
"ServiceName=KeyManagement \"The rotation plan is not realistic.\" OR \"The rotation plan enters Activation phase before certificate is active.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a rotation plan is not realistic."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "41 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"* Invalid Rotation Plan Detected * 
 The team must validate the content of the detected plan. <https://info.citrite.net/display/CWC/Invalid+Rotation+Plan>."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_rotation_plan_advertisement_phase_41" {
  name                     = "Athena Rotation Plan advertisement phase_41"
  search                   = <<EOT
"ServiceName=KeyManagement \"Rotation plan has entered in advertisement phase.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a rotation plan has entered advertisement phase."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "42 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "athena_certificate_not_found_after_agreement_42" {
  name                     = "Athena certificate not found after agreement_42"
  search                   = <<EOT
"ServiceName=KeyManagement \"Certificate not found on VM and agreement passed.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a certificate is not found on a VM and agreement phase has passed."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "43 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"* Athena certificate not found on VM * 
 <https://info.citrite.net/display/CWC/KeyManagement+failing+to+access+the+signing+certificate>."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_certificate_not_found_after_agreement_and_advertisement_43" {
  name                     = "Athena certificate not found after agreement and advertisement_43"
  search                   = <<EOT
"ServiceName=KeyManagement \"Certificate not found on VM and advertisement passed.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a certificate is not found on a VM and advertisement phase has passed."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "45 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"* Athena certificate not found on VM * 
 <https://info.citrite.net/display/CWC/KeyManagement+failing+to+access+the+signing+certificate>."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_samlweb_unable_to_retrieve_a_certificate_rotation_plan_44" {
  name                     = "Athena: SamlWeb unable to retrieve a certificate rotation plan._44"
  search                   = <<EOT
"ServiceName=SamlWeb EventType=Error \"Error retrieving rotation plan.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered if the SamlWeb service has failures while retrieving the certificate rotation plan."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "44 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "samlweb_cannot_find_the_certificate_to_use_for_signing_45" {
  name                     = "SamlWeb cannot find the certificate to use for signing_45"
  search                   = <<EOT
"ServiceName=SamlWeb SamlCertificateException SamlException \"InnerExceptionMessage=The X.509 certificate with find type FindByThumbprint and value * could not be found in the LocalMachine My X.509 store.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-30m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when SamlWeb cannot find a certificate in the local store that matches the thumbprint in the active phase of the current rotation plan."
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/30 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"* SamlWeb cannot find the certificate to use for signing. * 
 This will create customer downtime, execute <https://info.citrite.net/display/CWC/SamlWeb+failing+to+access+the+signing+certificate>."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_staging_features_circuit_breaker_opened_46" {
  name                     = "Athena Staging - Features Circuit Breaker Opened_46"
  search                   = <<EOT
"sourcetype=ath:services \"Features Circuit Breaker Opened.\" \"EventType=Information\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-30m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Detects if Features Circuit Breaker Opened for a specified Node"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/30 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"*Features Circuit Breaker Opened*

> *ServiceName*: $result.ServiceName$

Please execute this Runbook: <https://info.citrite.net/x/KzBiYg|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_too_many_email_notifications_for_updates_in_principals_47" {
  name                     = "Athena: Too many email notifications for updates in principals_47"
  search                   = <<EOT
"sourcetype=\"ath:services\" Message=\"*Email notification succeeded for change in principal account*\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-240m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when too many email notifications were sent for updates in principals accounts."
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "11 */4 * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
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

resource "splunk_saved_searches" "athena_ui_files_are_missing_identity6_48" {
  name                     = "Athena: UI files are missing - Identity6_48"
  search                   = <<EOT
"EventType=Error \"Unable to find the specified file.\" index=staging_ath_services OR index=stagingjp_ath_services | eval StartTime='-5m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when UI files are missing from an Identity6 node, after release"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/21 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
"* UI files are missing from an Identity6 node * 
Please execute this Runbook: <https://info.citrite.net/display/CWC/UI+files+are+missing+in+Identity6|runbook>"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}
