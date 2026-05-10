locals {
  labels = {
    env         = "prod"
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terraform"
    system      = "de-platform"
  }
}

module "raw_bucket" {
  source                 = "../../modules/gcs_bucket"
  project_id             = var.project_id
  name                   = "${var.name_prefix}-prod-raw"
  location               = var.location
  labels                 = local.labels
  versioning_enabled     = true
  lifecycle_age_days     = 365
}

module "curated_bucket" {
  source                 = "../../modules/gcs_bucket"
  project_id             = var.project_id
  name                   = "${var.name_prefix}-prod-curated"
  location               = var.location
  labels                 = local.labels
  versioning_enabled     = true
  lifecycle_age_days     = null
}

module "temp_bucket" {
  source                 = "../../modules/gcs_bucket"
  project_id             = var.project_id
  name                   = "${var.name_prefix}-prod-temp"
  location               = var.location
  labels                 = local.labels
  versioning_enabled     = false
  lifecycle_age_days     = 7
}

module "bq_raw" {
  source          = "../../modules/bigquery_dataset"
  project_id      = var.project_id
  dataset_id      = "de_prod_raw"
  location        = var.location
  description     = "Production raw dataset."
  labels          = local.labels
}

module "bq_staging" {
  source          = "../../modules/bigquery_dataset"
  project_id      = var.project_id
  dataset_id      = "de_prod_staging"
  location        = var.location
  description     = "Production staging dataset."
  labels          = local.labels
  default_table_expiration_ms = 2592000000
}

module "bq_marts" {
  source          = "../../modules/bigquery_dataset"
  project_id      = var.project_id
  dataset_id      = "de_prod_marts"
  location        = var.location
  description     = "Production marts dataset."
  labels          = local.labels
}

module "loader_sa" {
  source       = "../../modules/service_account"
  project_id   = var.project_id
  account_id   = "de-prod-loader"
  display_name = "DE Prod Loader Service Account"
}

module "transformer_sa" {
  source       = "../../modules/service_account"
  project_id   = var.project_id
  account_id   = "de-prod-transformer"
  display_name = "DE Prod Transformer Service Account"
}

module "loader_job_user" {
  source     = "../../modules/iam_binding"
  project_id = var.project_id
  role       = "roles/bigquery.jobUser"
  member     = "serviceAccount:${module.loader_sa.email}"
}

module "transformer_job_user" {
  source     = "../../modules/iam_binding"
  project_id = var.project_id
  role       = "roles/bigquery.jobUser"
  member     = "serviceAccount:${module.transformer_sa.email}"
}

module "loader_raw_bucket_writer" {
  source = "../../modules/gcs_bucket_iam_member"
  bucket = module.raw_bucket.bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.loader_sa.email}"
}

module "loader_raw_dataset_editor" {
  source     = "../../modules/bigquery_dataset_iam_member"
  project_id = var.project_id
  dataset_id = module.bq_raw.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${module.loader_sa.email}"
}

module "transformer_staging_dataset_editor" {
  source     = "../../modules/bigquery_dataset_iam_member"
  project_id = var.project_id
  dataset_id = module.bq_staging.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${module.transformer_sa.email}"
}

module "transformer_marts_dataset_editor" {
  source     = "../../modules/bigquery_dataset_iam_member"
  project_id = var.project_id
  dataset_id = module.bq_marts.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${module.transformer_sa.email}"
}
