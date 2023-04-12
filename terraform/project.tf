# vim: set syntax=tf:

variable "project_name" {
  type        = string
  description = "Name of GCP project to manage"
}

variable "project_region" {
  type        = string
  description = "GCP Region in which to provision project resources."
  default     = null
}

provider "google" {
  project = var.project_name
  region  = var.project_region
}

terraform {
  backend "gcs" {}
}

data "google_project" "this" {}
data "google_client_openid_userinfo" "me" {}
