# vim: set syntax=tf:

variable "validator_storage_uploads_bucket_name" {
  type = string
}

variable "validator_storage_reports_bucket_name" {
  type = string
}

variable "validator_storage_client_bucket_name" {
  type = string
}

module "validator_storage" {
  source  = "./gcp-storage"
  buckets = [
    local.validator_storage_uploads_bucket,
    local.validator_storage_reports_bucket,
    local.validator_storage_client_bucket
  ]
}

locals {
  validator_storage_uploads_bucket = {
    name          = var.validator_storage_uploads_bucket_name
    location      = var.project_region
    force_destroy = false
    cors          = {
      origin          = [ "*" ]
      method          = [ "PUT" ]
      response_header = ["content-type", "access-control-allow-origin"]
      max_age_seconds = 3600
    }
    lifecycle_rules = [
      {
        action_type                          = "Delete"
        condition_age                        = 30
        condition_days_since_custom_time     = 0
        condition_days_since_noncurrent_time = 0
        condition_matches_prefix             = []
        condition_matches_storage_class      = []
        condition_matches_suffix             = []
        condition_num_newer_versions         = 0
        condition_with_state                 = "ANY"
      }
    ]
  }
  validator_storage_reports_bucket = {
    name          = var.validator_storage_reports_bucket_name
    location      = split("-", var.project_region)[0]
    force_destroy = false
    cors          = {
      origin          = [ "*" ]
      method          = ["HEAD", "GET"]
      response_header = ["content-type", "access-control-allow-origin"]
      max_age_seconds = 3600
    }
    lifecycle_rules = [
      {
        action_type                          = "Delete"
        condition_age                        = 30
        condition_days_since_custom_time     = 0
        condition_days_since_noncurrent_time = 0
        condition_matches_prefix             = []
        condition_matches_storage_class      = []
        condition_matches_suffix             = []
        condition_num_newer_versions         = 0
        condition_with_state                 = "ANY"
      }
    ]
  }
  validator_storage_client_bucket = {
    name          = var.validator_storage_client_bucket_name
    location      = split("-", var.project_region)[0]
    force_destroy = false
  }
  validator_storage_uploads_bucket_state = module.validator_storage.buckets.0
  validator_storage_reports_bucket_state = module.validator_storage.buckets.1
  validator_storage_client_bucket_state  = module.validator_storage.buckets.2
}

