# vim: set syntax=tf:

variable "project_name" {
  type = string
  description = "GCP Project id"
}

terraform {
  required_providers {
    google = {
      source  = "registry.terraform.io/hashicorp/google"
      version = "~> 4.57"
    }
  }
}
