variable "project_id" {
  description = "Production GCP project ID."
  type        = string
}

variable "location" {
  description = "GCP location for production resources."
  type        = string
  default     = "US"
}

variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "owner" {
  description = "Owner label."
  type        = string
}

variable "cost_center" {
  description = "Cost center label."
  type        = string
}

