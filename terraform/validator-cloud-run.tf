# vim: set syntax=tf:

variable "validator_cloud_run_service" {
  type = object({
      name                      = string
      location                  = string
      image                     = string
      max_instance_count        = optional(number, null)
      container_port            = optional(number, 8080)
      limit_cpu                 = optional(string, null)
      limit_memory              = optional(string, null)
      startup_timeout_seconds   = optional(number, null)
      startup_period_seconds    = optional(number, null)
      startup_failure_threshold = optional(number, null)
  })
}

module "validator_cloud_run_invoker" {
  source               = "./gcp-iam"
  project_name         = basename(data.google_project.this.id)
  svc_accounts         = [ local.validator_cloud_run_invoker ]
}

resource "google_cloud_run_service_iam_member" "validator_cloud_run_invoker" {
  location = var.validator_cloud_run_service.location
  service  = google_cloud_run_v2_service.validator_cloud_run_service.name
  role     = "roles/run.invoker"
  member   = local.validator_cloud_run_invoker_member
}

resource "google_cloud_run_v2_service" "validator_cloud_run_service" {
  name           = var.validator_cloud_run_service.name
  location       = var.validator_cloud_run_service.location
  annotations    = {
    "client.knative.dev/user-image" = var.validator_cloud_run_service.image
  }

  template {

    revision    = "gtfs-validator-web-00058-gew"
    annotations = {
      "client.knative.dev/user-image" = var.validator_cloud_run_service.image
    }

    scaling {
      max_instance_count = var.validator_cloud_run_service.max_instance_count
    }

    containers {

      image = var.validator_cloud_run_service.image

      ports {
        name = "http1"
        container_port = var.validator_cloud_run_service.container_port
      }

      resources {
        cpu_idle = true
        limits = {
          cpu    = var.validator_cloud_run_service.limit_cpu
          memory = var.validator_cloud_run_service.limit_memory
        }
      }

      startup_probe {
        timeout_seconds   = var.validator_cloud_run_service.startup_timeout_seconds
        period_seconds    = var.validator_cloud_run_service.startup_period_seconds
        failure_threshold = var.validator_cloud_run_service.startup_failure_threshold
        tcp_socket {
          port = var.validator_cloud_run_service.container_port
        }
      }

    }

  }
}

locals {
  validator_cloud_run_invoker = {
    name    = "invoker-gtfs-web"
    display = "Invoker for gtfs web pub/sub"
  }
  validator_cloud_run_invoker_member = module.validator_cloud_run_invoker.svc_accounts.0.member
}
