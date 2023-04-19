# vim: set syntax=tf:
project_name                = "web-based-gtfs-validator"
project_region              = "us-east1"
gcp_svc_accounts            = [
  {
    name    = "invoker-gtfs-web"
    display = "Invoker for gtfs web pub/sub"
  }
]
validator_cloud_run_service = {
  name                      = "gtfs-validator-web"
  location                  = "us-east1"
  image                     = "gcr.io/web-based-gtfs-validator/gtfs-validator-web"
  max_instance_count        = 10
  container_port            = 8080
  limit_cpu                 = "4000m"
  limit_memory              = "16Gi"
  startup_timeout_seconds   = 240
  startup_period_seconds    = 240
  startup_failure_threshold = 1
}
validator_cloud_run_invoker = "invoker-gtfs-web"
