variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID."
  type        = string
}

variable "location" {
  description = "BigQuery dataset location."
  type        = string
}

variable "description" {
  description = "Dataset description."
  type        = string
}

variable "labels" {
  description = "Standard labels."
  type        = map(string)
}

variable "default_table_expiration_ms" {
  description = "Default table expiration in milliseconds. Null means no default expiration."
  type        = number
  default     = null
}

