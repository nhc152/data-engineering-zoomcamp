output "raw_bucket" {
  value = module.raw_bucket.bucket_name
}

output "bq_raw_dataset" {
  value = module.bq_raw.dataset_id
}

output "loader_service_account" {
  value = module.loader_sa.email
}

