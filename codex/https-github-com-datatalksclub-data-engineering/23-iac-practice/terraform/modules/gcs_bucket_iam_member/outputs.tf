output "bucket" {
  value = google_storage_bucket_iam_member.this.bucket
}

output "member" {
  value = google_storage_bucket_iam_member.this.member
}

