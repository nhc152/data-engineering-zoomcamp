resource "google_bigquery_dataset_iam_member" "this" {
  project    = var.project_id
  dataset_id = var.dataset_id
  role       = var.role
  member     = var.member
}

