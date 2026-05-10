output "bucket_name" {
  value       = google_storage_bucket.this.name
  description = "GCS bucket name."
}

output "bucket_url" {
  value       = google_storage_bucket.this.url
  description = "GCS bucket URL."
}

