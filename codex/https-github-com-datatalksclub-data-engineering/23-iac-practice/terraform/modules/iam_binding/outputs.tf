output "role" {
  value       = google_project_iam_member.this.role
  description = "Bound IAM role."
}

output "member" {
  value       = google_project_iam_member.this.member
  description = "Bound IAM member."
}

