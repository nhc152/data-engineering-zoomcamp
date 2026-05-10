variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Globally unique GCS bucket name."
  type        = string
}

variable "location" {
  description = "Bucket location, for example US or asia-southeast1."
  type        = string
}

variable "labels" {
  description = "Standard labels for ownership and cost attribution."
  type        = map(string)
}

variable "versioning_enabled" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "lifecycle_age_days" {
  description = "Delete objects older than this many days. Null disables delete lifecycle."
  type        = number
  default     = null
}
