output "dataset_id" {
  value       = google_bigquery_dataset.this.dataset_id
  description = "Dataset ID."
}

output "self_link" {
  value       = google_bigquery_dataset.this.self_link
  description = "Dataset self link."
}

