# vim: set syntax=tf:

variable "buckets" {
  type = list(object({
    name            = string
    location        = string
    force_destroy   = optional(bool)
    project         = optional(string)
    storage_class   = optional(string)
    lifecycle_rules = optional(list(object({
      action_type                          = optional(string)
      action_storage_class                 = optional(string)
      condition_age                        = optional(number)
      condition_created_before             = optional(string)
      condition_with_state                 = optional(string)
      condition_matches_storage_class      = optional(list(string))
      condition_matches_prefix             = optional(list(string))
      condition_matches_suffix             = optional(list(string))
      condition_num_newer_versions         = optional(number)
      condition_custom_time_before         = optional(string)
      condition_days_since_custom_time     = optional(number)
      condition_days_since_noncurrent_time = optional(number)
      condition_noncurrent_time_before     = optional(string)
    })), [])
    versioning      = optional(object({
      enabled = bool
    }))
    website         = optional(object({
      main_page_suffix = optional(string)
      not_found_page   = optional(string)
    }))
    cors            = optional(object({
      origin          = optional(list(string))
      method          = optional(list(string))
      response_header = optional(list(string))
      max_age_seconds = optional(number)
    }))
  }))
}

output "buckets" {
  value = google_storage_bucket.buckets
}

resource "google_storage_bucket" "buckets" {
  count         = length(var.buckets)
  name          = var.buckets[count.index].name
  location      = var.buckets[count.index].location
  force_destroy = var.buckets[count.index].force_destroy
  project       = var.buckets[count.index].project
  storage_class = var.buckets[count.index].storage_class


  dynamic "lifecycle_rule" {
    for_each = var.buckets[count.index].lifecycle_rules
    iterator = rule
    content {
      action {
        type          = rule.value.action_type
        storage_class = rule.value.action_storage_class
      }
      condition {
        age                        = rule.value.condition_age
        created_before             = rule.value.condition_created_before
        with_state                 = rule.value.condition_with_state
        matches_storage_class      = rule.value.condition_matches_storage_class
        matches_prefix             = rule.value.condition_matches_prefix
        matches_suffix             = rule.value.condition_matches_suffix
        num_newer_versions         = rule.value.condition_num_newer_versions
        custom_time_before         = rule.value.condition_custom_time_before
        days_since_custom_time     = rule.value.condition_days_since_custom_time
        days_since_noncurrent_time = rule.value.condition_days_since_noncurrent_time
        noncurrent_time_before     = rule.value.condition_noncurrent_time_before
      }
    }
  }

  dynamic "versioning" {
    for_each = local.bucket_versionings[count.index] == null ? [] : [ local.bucket_versionings[count.index] ]
    content {
      enabled = versioning.value.enabled
    }
  }

  dynamic "website" {
      for_each = local.bucket_websites[count.index] == null ? [] : [ local.bucket_websites[count.index] ]
      content {
        main_page_suffix = website.value.main_page_suffix
        not_found_page   = website.value.not_found_page
      }
  }

  dynamic "cors" {
    for_each = local.bucket_cors[count.index] == null ? [] : [ local.bucket_cors[count.index] ]
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }
}

locals {
  bucket_websites    = [ for bucket in var.buckets: bucket.website    ]
  bucket_versionings = [ for bucket in var.buckets: bucket.versioning ]
  bucket_cors        = [ for bucket in var.buckets: bucket.cors       ]
}
