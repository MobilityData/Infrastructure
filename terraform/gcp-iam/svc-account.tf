# vim: set syntax=tf:

variable "svc_accounts" {
  type = list(object({
    name    = string
    display = optional(string)
  }))
  description = "List of service accounts to create"
  default = []
}

variable "svc_account_bindings" {
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

output "svc_accounts" {
  value = google_service_account.svc_accounts[*]
}

resource "google_service_account" "svc_accounts" {
  count        = length(var.svc_accounts)
  project      = var.project_name
  account_id   = var.svc_accounts[count.index].name
  display_name = can(var.svc_accounts[count.index].display) ? var.svc_accounts[count.index].display : null
}

resource "google_project_iam_member" "svc_account_bindings" {
  count      = length(var.svc_account_bindings)
  project    = var.project_name
  member     = local.svc_account_members[var.svc_account_bindings[count.index].account]
  role       = var.svc_account_bindings[count.index].role

  dynamic "condition" {
    for_each = local.svc_account_binding_conditions["${var.svc_account_bindings[count.index].account}:${var.svc_account_bindings[count.index].role}"]
    content  {
      title       = condition.key
      description = condition.value.description
      expression  = condition.value.expression
    }
  }

}

locals {
  svc_account_members            = {for acct in google_service_account.svc_accounts:
    acct.account_id => acct.member
  }
  svc_account_binding_conditions = {for acct_role in var.svc_account_bindings: "${acct_role.account}:${acct_role.role}" => {
      for condition in acct_role.conditions: condition.title => {
        expression  = condition.expression
        description = can(condition.description) ? condition.description : null
      }
    }
  }
}
