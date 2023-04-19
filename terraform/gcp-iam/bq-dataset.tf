# vim: set syntax=tf:

variable "bq_dataset_bindings" {
  type = list(object({
    dataset = string
    account = string
    role    = string
  }))
  description = "List of dataset-scoped role grants for service accounts"
  default = []
}

resource "google_bigquery_dataset_iam_member" "bq_dataset_bindings" {
  count      = length(var.bq_dataset_bindings)
  project    = var.project_name
  dataset_id = var.bq_dataset_bindings[count.index].dataset
  role       = var.bq_dataset_bindings[count.index].role
  member     = local.svc_account_members[var.bq_dataset_bindings[count.index].account]
}
