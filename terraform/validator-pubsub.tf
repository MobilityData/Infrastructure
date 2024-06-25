# vim: set syntax=tf:

variable "validator_pubsub_topic" {
  type        = string
  description = "Name of GCP pub/sub topic to manage"
}

variable "validator_pubsub_sub" {
  type        = object({
      name                       = optional(string, null)
      push_endpoint_path         = optional(string, "/")
      ack_deadline_seconds       = optional(number, 600)
      message_retention_duration = optional(string, null)
      retry_policy_max_backoff   = optional(string, null)
      retry_policy_min_backoff   = optional(string, null)
  })
  default     = {}
  description = "Attributes for validator service pub/sub subscription"
}

resource "google_pubsub_topic" "validator_pubsub_topic" {
  name  = var.validator_pubsub_topic
}

resource "google_pubsub_topic_iam_member" "validator_pubsub_topic_pub" {
  topic  = google_pubsub_topic.validator_pubsub_topic.name
  role   = "roles/pubsub.publisher"
  member = local.project_gcs_service_agent_member
}

resource "google_pubsub_subscription" "validator_pubsub_sub" {
  name                       = local.validator_pubsub_sub_name
  topic                      = google_pubsub_topic.validator_pubsub_topic.name
  ack_deadline_seconds       = var.validator_pubsub_sub.ack_deadline_seconds
  message_retention_duration = var.validator_pubsub_sub.message_retention_duration

  push_config {
    push_endpoint = local.validator_pubsub_sub_push_endpoint
    oidc_token {
      service_account_email = local.validator_cloud_run_invoker_email
    }
  }

  retry_policy {
    maximum_backoff = var.validator_pubsub_sub.retry_policy_max_backoff
    minimum_backoff = var.validator_pubsub_sub.retry_policy_min_backoff
  }
  expiration_policy {
    # Set expiration policy to never expired.
    # Official documentation:
    # https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions#ExpirationPolicy
    # 
    # A subscription is considered active as long as any connected subscriber
    # is successfully consuming messages from the subscription or is issuing operations on the subscription. 
    # If expirationPolicy is not set, a default policy with ttl of 31 days will be used. 
    # If it is set but ttl is "", the resource never expires.
    # ....
    ttl = ""
  }
}

resource "google_storage_notification" "validator_pubsub_pub" {
  bucket         = local.validator_storage_uploads_bucket_state.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.validator_pubsub_topic.name
  event_types    = [ "OBJECT_FINALIZE" ]
  depends_on = [ google_pubsub_topic_iam_member.validator_pubsub_topic_pub ]
}

resource "google_project_iam_member" "validator_pubsub_iam_binding" {
  project    = data.google_project.this.id
  member     = local.validator_pubsub_binding_member
  role       = "roles/iam.serviceAccountTokenCreator"
}

locals {
  validator_pubsub_binding_member    = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  validator_pubsub_sub_name          = var.validator_pubsub_sub.name != null ? var.validator_pubsub_sub.name : "${google_pubsub_topic.validator_pubsub_topic.name}-SUBSCRIPTION"
  validator_pubsub_sub_push_endpoint = "${google_cloud_run_v2_service.validator_cloud_run_service.uri}${var.validator_pubsub_sub.push_endpoint_path}"
}
