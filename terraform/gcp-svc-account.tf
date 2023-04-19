# vim: set syntax=tf:

variable "gcp_svc_accounts" {
  type = list(object({
    name    = string
    display = optional(string)
  }))
  description = "List of service accounts to create in GCP project"
  default = []
}

variable "gcp_svc_account_bindings" {
  type = list(object({
    account    = string
    role       = string
    conditions = optional(list(object({
      title       = string
      description = string
      expression  = optional(string)
    })), [])
  }))
  description = "List of project-scoped role grants for service accounts"
  default = []
}

module "gcp_svc_account" {
  source               = "./gcp-iam"
  project_name         = basename(data.google_project.this.id)
  svc_accounts         = var.gcp_svc_accounts
  svc_account_bindings = var.gcp_svc_account_bindings
}
