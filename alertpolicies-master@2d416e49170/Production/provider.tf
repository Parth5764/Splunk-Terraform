terraform {
   required_providers {
    splunk = {
      source  = "splunk/splunk"
    }
  }
}

provider "splunk" {
  url                  = "127.0.0.1:8089"
  username             = "admin"
  password             = "adminadmin"
  insecure_skip_verify = true
}