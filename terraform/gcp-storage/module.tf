# vim: set syntax=tf:

terraform {
  required_providers {
    google = {
      source  = "registry.terraform.io/hashicorp/google"
      version = "~> 4.57"
    }
  }
}
