output "dataset_id" {
  value = google_bigquery_dataset_iam_member.this.dataset_id
}

output "member" {
  value = google_bigquery_dataset_iam_member.this.member
}

