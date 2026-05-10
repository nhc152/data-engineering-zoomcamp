variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "role" {
  description = "IAM role to bind."
  type        = string
}

variable "member" {
  description = "IAM member, e.g. serviceAccount:name@project.iam.gserviceaccount.com."
  type        = string
}

