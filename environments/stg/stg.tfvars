# vim: set syntax=tf:
project_name                          = "web-based-gtfs-validator"
project_region                        = "us-east1"
project_gcs_service_agent_account     = "service-1084949198173@gs-project-accounts.iam.gserviceaccount.com"
validator_cloud_run_service           = {
  name                              = "stg-gtfs-validator-web"
  location                          = "us-east1"
  image                             = "gcr.io/web-based-gtfs-validator/gtfs-validator-web"
  invoker_account_name              = "stg-invoker-gtfs-web"
  max_instance_count                = 10
  container_port                    = 8080
  limit_cpu                         = "4000m"
  limit_memory                      = "16Gi"
  startup_timeout_seconds           = 240
  startup_period_seconds            = 240
  startup_failure_threshold         = 1
}
validator_cloud_run_manage_revision   = false
validator_pubsub_topic                = "STG-GTFS-WEB-VALIDATOR"
validator_pubsub_sub                  = {
  push_endpoint_path         = "/run-validator"
  message_retention_duration = "86400s"
  retry_policy_max_backoff   = "600s"
  retry_policy_min_backoff   = "10s"
}
validator_storage_uploads_bucket_name = "stg-gtfs-validator-user-uploads"
validator_storage_reports_bucket_name = "stg-gtfs-validator-results"
validator_storage_client_bucket_name  = "stg-gtfs-validator-web"
