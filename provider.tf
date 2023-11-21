terraform {
   required_providers {
    splunk = {
      source  = "splunk/splunk"
    }
  }
}

provider "splunk" {
  url                  = "localhost:8089"
  username             = "admin"
  password             = "adminadmin"
  insecure_skip_verify = true
}