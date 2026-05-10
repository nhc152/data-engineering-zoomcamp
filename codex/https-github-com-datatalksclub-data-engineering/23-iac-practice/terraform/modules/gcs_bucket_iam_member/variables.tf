variable "bucket" {
  description = "GCS bucket name."
  type        = string
}

variable "role" {
  description = "Bucket-level IAM role."
  type        = string
}

variable "member" {
  description = "IAM member."
  type        = string
}

