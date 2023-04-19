# vim: set syntax=tf:
project_name                = "web-based-gtfs-validator"
project_region              = "us-east1"
gcp_svc_accounts            = [
  {
    name    = "invoker-gtfs-web"
    display = "Invoker for gtfs web pub/sub"
  }
]
validator_cloud_run_service = {}
validator_cloud_run_invoker = ""
