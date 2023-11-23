
resource "splunk_saved_searches" "athena_gov_pen_test_user_delete_calls_1" {
  name                     = "Athena Gov Pen Test user delete calls_1"
  search                   = <<EOT
"sourcetype=ath:services ClientName=ath_pen_testuser_2019_* HTTP/* DELETE
| bin span=5m _time index=staginggov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "alert_for_dsauth_throttling_2" {
  name                     = "Alert for DSAuth throttling_2"
  search                   = <<EOT
"\"Not building the domain contexts due to throttling\" | stats count by ServiceInstanceIp | where count > 50 index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "alert_for_athena_gov_authdomain_3" {
  name                     = "Alert for Athena Gov AuthDomain._3"
  search                   = <<EOT
"\"sourcetype=ath:services ServiceName=DSAuth* Message=\"not found in athena customer AuthDomains\" | stats count by AuthDomain\" index=staginggov_ath_services | eval StartTime='-30m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_gov_not_redirecting_to_logon_page_4" {
  name                     = "Athena Gov not redirecting to Logon Page_4"
  search                   = <<EOT
"ServiceName=DSAuth-Web2 RequestUri=\"*webview*\" Message=\"Error looking up auth domain:*\" index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena Gov - Staging: Failing to redirect from DSAuth-Web to Identity to show the Logon Page: Error looking up auth domain. See: https://info.citrite.net/display/CWC/DSAuthWeb2+Logon+page+not+available+cross-geo"
EOT
  disabled                 = false
  actions                  = "slack, pagerduty"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = ""
  action_email_subject     = ""
  action_slack_param_channel = "#athena-alerts-staging"
  action_slack_param_message = <<EOT
">>> *Athena Gov - Staging:*
There are an abnormal count of failures to get redirect to the Logon Page: $result.ErrorMessage$
```index=staginggov_ath_services ServiceName=DSAuth-Web2 RequestUri="*webview*" Message="Error looking up auth domain:*"```
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

resource "splunk_saved_searches" "signing_key_not_found_in_dsauthweb2_gov_5" {
  name                     = "Signing key not found in DSAuthWeb2 Gov_5"
  search                   = <<EOT
"sourcetype=\"ath:services\" ServiceName=DSAuth-Web2 EventType=Error \"No appropriate signing key found in the discovery document.\" index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena Gov - Staging: This alert is triggered when DSAuthWeb2 cannot find appropriate signing key in the discovery document. Possible root cause could be an upgrade in Identity4 causing changes in kid. Please check <https://accounts.cloud.com/core/.well-known/openid-configuration/jwks>"
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
```index=staginggov_ath_services sourcetype="ath:services" ServiceName=DSAuth-* EventType=Error "No appropriate signing key found in the discovery document."```
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

resource "splunk_saved_searches" "athena_gov_dsauthweb_500_errors_6" {
  name                     = "Athena Gov: DSAuthWeb 500 Errors_6"
  search                   = <<EOT
"index=staginggov_ath_services sourcetype=ath:services ServiceName=DSAuth-Web2 500 | stats count AS number_of_issues |
eval alertMessage=\"*Staging Athena: 
AlertType = Error 
 Showing an increased level of 500 errors in DSAuthWeb.  Check in Splunk and warn the @cc-athena-squad\". 
\"`staginggov_ath_services sourcetype=ath:services ServiceName=DSAuth-Web2 500`\"  | stats list(alertMessage) as alertMessage index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the number of errors in DSAuthWeb Gov is at an increased level of 500"
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

resource "splunk_saved_searches" "athena_gov_dsauthweb_is_failing_to_get_the_oidc_token_7" {
  name                     = "Athena Gov: DSAuthWeb is failing to get the OIDC token_7"
  search                   = <<EOT
"sourcetype=ath:services ServiceName=DSAuth* Message=\"The OpenID Connect Token request, returned Http status code: BadRequest\" | dedup AuthDomain | top limit=1 AuthDomain |
eval alertMessage=\"*Staging Athena*: DSAuthWeb is failing to get the OIDC token for one or more customers.
 AlertType=Error 
```index=staginggov_ath_services sourcetype=ath:services ServiceName=DSAuth* Message=\\"The OpenID Connect Token request, returned Http status code: BadRequest\\"```
\"  | stats list(alertMessage) as alertMessage index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "failed_to_process_cip_cred_in_dsauthweb2_gov_8" {
  name                     = "Failed to process cip_cred in DSAuthWeb2 Gov_8"
  search                   = <<EOT
"sourcetype=\"ath:services\" ServiceName=DSAuth-Web2 EventType=Error Method=\"*OidcRequestTokenResponseFactory.CreateCredentialWalletReferenceFromCipCred*\" index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
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
```index=staginggov_ath_services sourcetype="ath:services" ServiceName=DSAuth-* EventType=Error Method="*OidcRequestTokenResponseFactory.CreateCredentialWalletReferenceFromCipCred*"```"
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_invalid_autorization_token_9" {
  name                     = "Athena Gov: Invalid Autorization token_9"
  search                   = <<EOT
"EventType=Error \"Authorization token is not valid at the current time.\" 
| stats count by RegionName 
| table RegionName,count index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
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
">>> *ATHENA-STAGING:* Invalid Authorization token error in $result.RegionName$ Region. Please check Splunk for more details using below query: ```index=staginggov_ath_services EventType=Error "Authorization token is not valid at the current time."| table RegionName``` This can be a problem with the Secure Time Seeding Windows service and a clock skew affecting the cosmos db auth tokens. Refer to <https://info.citrite.net/display/CWC/Athena+Regional+Failover+Runbook |This Runbook> to perform failover if this is region specific."
EOT
  action_pagerduty_integration_url = ""
  action_email_message_report      =<<EOT
""
EOT
  action_pagerduty_custom_details  =<<EOT
""
EOT
}

resource "splunk_saved_searches" "athena_gov_throttled_cosmosdb_request_10" {
  name                     = "Athena Gov Throttled CosmosDB Request_10"
  search                   = <<EOT
"cosmosdb-error-429 ServiceName!=NULL | stats count by ServiceName,RegionName,LayerName | where count>100 | fields RegionName,LayerName,ServiceName,count index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_alert_for_invalid_refresh_token_error_11" {
  name                     = "Athena Alert for Invalid Refresh Token Error._11"
  search                   = <<EOT
"(ServiceName=Identity4 Message=\"Invalid refresh token\") OR (ServiceName=DSAuth-Web2 Message=\"Long lived token not found\") | transaction CallerIp OR ClientId | where eventcount > 200 index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "slow_http_requests_detected_runbook_12" {
  name                     = "Slow HTTP Requests Detected Runbook_12"
  search                   = <<EOT
"ServiceName=Identity4 ExceptionMessage=\"Reading the request body timed out due to data arriving too slowly.*\" | stats count | search count > 100 index=staginggov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
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
"> *STAGING GOV*: One of the services in Athena is rejecting requests because of the HTTP request data is arriving too slowly
Splunk Query: ```index="staginggov_ath_services" "Reading the request body timed out due to data arriving too slowly."``` 
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

resource "splunk_saved_searches" "athena_failover_failure_gov_13" {
  name                     = "Athena Failover Failure (Gov)_13"
  search                   = <<EOT
"ServiceName=AutoFailover \"The failover operation could not be completed. Failover requirements not met.\" OR (Method=FailoverManager.Failover exception) | stats count | search count > 0 index=staginggov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a failover cannot be completed due to a failover requirement not being met or another miscellaneous exception."
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Failover Failure (Gov)"
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

resource "splunk_saved_searches" "athena_failover_notification_gov_14" {
  name                     = "Athena Failover Notification (Gov)_14"
  search                   = <<EOT
"ServiceName=AutoFailover \"The failover operation completed successfully\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=staging_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthEvents)| rex \"HealthEvents=(?<FullHealthEvents>.*) HealthStatus\" | eval MonitoredServiceName = Service | fields TransactionId, FullHealthEvents, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, FullHealthEvents, HealthScore, EventTime index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a region is failed over."
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Failover Notification (Gov)"
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

resource "splunk_saved_searches" "athena_restore_notification_gov_15" {
  name                     = "Athena Restore Notification (Gov)_15"
  search                   = <<EOT
"ServiceName=AutoFailover \"The restore operation completed successfully.\" | table TransactionId, ServiceName, EventTime, RegionCode | join type=inner TransactionId [search (index=staging_ath_services ServiceName=\"HealthCheckMonitorWorker\" HealthScore)| eval MonitoredServiceName = Service | fields TransactionId, MonitoredServiceName, HealthScore] | table TransactionId, RegionCode, MonitoredServiceName, HealthScore, EventTime index=staginggov_ath_services | eval StartTime='-15m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a failed over region is restored."
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "*/15 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Restore Notification (Gov)"
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

resource "splunk_saved_searches" "athena_dryrun_failover_notification_gov_16" {
  name                     = "Athena Dry-Run Failover Notification (Gov)_16"
  search                   = <<EOT
"ServiceName=AutoFailover \"Dry run mode is enabled. Skipping failover operation.\" | stats count | search count > 0 index=staginggov_ath_services | eval StartTime='-10m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Alert is triggered when a would-be failover is detected in dry-run mode."
EOT
  disabled                 = false
  actions                  = "email, slack"
  cron_schedule            = "*/10 * * * *"
  action_email_to          = "workspaceadmins@citrix.com"
  action_email_subject     = "Athena Dry-Run Failover Notification (Gov)"
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

resource "splunk_saved_searches" "autofailover_frontdoor_failover_not_allowed_17" {
  name                     = "Autofailover - Frontdoor failover not allowed_17"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode=\"FdFailoverNotAllowed\"
| rex field=_raw \"Reason=(?<Reason>[^=]+) \" 
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=staginggov_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "autofailover_frontdoor_failover_completed_18" {
  name                     = "Autofailover - Frontdoor failover completed_18"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode=\"FdFailoverSuccess\"
| dedup Profile
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=staginggov_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "autofailover_frontdoor_failover_error_19" {
  name                     = "Autofailover - Frontdoor failover error_19"
  search                   = <<EOT
"ServiceName=\"Autofailover\" MsgCode IN (\"FdFailoverFailed\", \"FdFailoverException\")
| dedup Profile
| rex field=_raw \"Message=(?<Message>[^=]+)\"
| rex field=splunk_server \"[^\.]+\.(?<splunk_host>.+)\" 
| eval FailoverReason=case(Trigger == \"FrontdoorHealthReport\", \"High latency detected\", Trigger == \"RegionalFailover\", \"Multiple regions are unhealthy\") index=staginggov_csgops_services | eval StartTime='-15m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "csp_violation_detected_20" {
  name                     = "Csp Violation detected_20"
  search                   = <<EOT
"sourcetype=\"ath:services\" EventType=Error Message=\"*Csp Violation detected*\" index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Athena - Staging GOV: This alert is triggered when a csp violation is detected. Runbook: https://info.citrite.net/display/CWC/Csp+Violation+Error+Alerts+Staging+or+Production "
EOT
  disabled                 = false
  actions                  = "email, slack, pagerduty"
  cron_schedule            = "0 * * * *"
  action_email_to          = "athena-csp-alert@cloud.com"
  action_email_subject     = "Csp Violation detected"
  action_slack_param_channel = "#athena-csp-alerts"
  action_slack_param_message = <<EOT
">>> *Athena - Staging GOV:*
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

resource "splunk_saved_searches" "athena_blocknonfrontdoortraffic_feature_update_fails_21" {
  name                     = "Athena: BlockNonFrontDoorTraffic Feature Update fails_21"
  search                   = <<EOT
"sourcetype=ath:services ```Get all events in last 5 mins.```
| where ServiceName in (\"ActiveDirectoryWeb\", \"CertAuthWeb\", \"DSAuth-Web2\", \"Identity4\", \"SamlWeb\", \"ShareFileWeb\")
| stats count by ServiceName, host, source 
| join type=left left=L right=R where L.ServiceName=R.ServiceName L.host=R.host L.source=R.source ```Left join to get all Services:hosts```
    [search index=staginggov_ath_services sourcetype=ath:services \"Feature set to\" earliest=-10m ```Get \"Feature set to\" events to track this heartbeat message```
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
| rex mode=sed field=message \"s/,/\n/g\" index=staginggov_ath_services | eval StartTime='-5m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_frontdoorverification_blocking_requests_22" {
  name                     = "Athena: FrontDoorVerification blocking requests_22"
  search                   = <<EOT
"sourcetype=ath:services \"Failed FrontDoor Verification\" \"EventType=Error\" | stats count by ServiceName | where count > 500 | strcat \"FrontDoorVerification failed for \",ServiceName,\" with update count: \",count message | fields message | mvcombine message delim=\",\" | nomv message | rex mode=sed field=message \"s/,/\n/g\" index=staginggov_ath_services | eval StartTime='-30m' | eval EndTime='now'"
EOT
  description              =<<EOT
"Shows if the FrontDoor validation in services fails"
EOT
  disabled                 = false
  actions                  = "slack"
  cron_schedule            = "*/30 * * * *"
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

resource "splunk_saved_searches" "athena_rotation_plan_detected_23" {
  name                     = "Athena Rotation Plan detected_23"
  search                   = <<EOT
"ServiceName=KeyManagement \"Rotation plan created.\" OR \"Rotation plan updated.\" index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_rotation_plan_invalid_24" {
  name                     = "Athena Rotation Plan invalid_24"
  search                   = <<EOT
"ServiceName=KeyManagement \"The rotation plan is not realistic.\" OR \"The rotation plan enters Activation phase before certificate is active.\" index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_rotation_plan_advertisement_phase_25" {
  name                     = "Athena Rotation Plan advertisement phase_25"
  search                   = <<EOT
"ServiceName=KeyManagement \"Rotation plan has entered in advertisement phase.\" index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_certificate_not_found_after_agreement_26" {
  name                     = "Athena certificate not found after agreement_26"
  search                   = <<EOT
"ServiceName=KeyManagement \"Certificate not found on VM and agreement passed.\" index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_certificate_not_found_after_agreement_and_advertisement_27" {
  name                     = "Athena certificate not found after agreement and advertisement_27"
  search                   = <<EOT
"ServiceName=KeyManagement \"Certificate not found on VM and advertisement passed.\" index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_samlweb_unable_to_retrieve_a_cert_rotation_plan_28" {
  name                     = "Athena: SamlWeb unable to retrieve a cert rotation plan._28"
  search                   = <<EOT
"ServiceName=SamlWeb EventType=Error \"Error retrieving rotation plan.\" index=staginggov_ath_services | eval StartTime='-60m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "samlweb_cannot_find_the_certificate_to_use_for_signing_29" {
  name                     = "SamlWeb cannot find the certificate to use for signing_29"
  search                   = <<EOT
"ServiceName=SamlWeb SamlCertificateException SamlException \"InnerExceptionMessage=The X.509 certificate with find type FindByThumbprint and value * could not be found in the LocalMachine My X.509 store.\" index=staginggov_ath_services | eval StartTime='-30m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_staging_gov_features_circuit_breaker_opened_30" {
  name                     = "Athena Staging Gov- Features Circuit Breaker Opened_30"
  search                   = <<EOT
"sourcetype=ath:services \"Features Circuit Breaker Opened.\" \"EventType=Information\" index=staginggov_ath_services | eval StartTime='-30m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_too_many_email_notifications_for_updates_in_principals_31" {
  name                     = "Athena: Too many email notifications for updates in principals_31"
  search                   = <<EOT
"sourcetype=\"ath:services\" Message=\"*Email notification succeeded for change in principal account*\" index=staginggov_ath_services | eval StartTime='-240m' | eval EndTime='now'"
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

resource "splunk_saved_searches" "athena_staging_gov_ui_files_are_missing_identity6_32" {
  name                     = "Athena Staging Gov: UI files are missing - Identity6_32"
  search                   = <<EOT
"EventType=Error \"Unable to find the specified file.\" index=staginggov_ath_services | eval StartTime='-5m' | eval EndTime='now'"
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
