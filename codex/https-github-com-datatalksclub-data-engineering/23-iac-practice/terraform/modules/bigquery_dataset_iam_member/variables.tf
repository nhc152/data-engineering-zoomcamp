variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID."
  type        = string
}

variable "role" {
  description = "Dataset-level IAM role."
  type        = string
}

variable "member" {
  description = "IAM member."
  type        = string
}

