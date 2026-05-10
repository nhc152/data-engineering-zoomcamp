locals {
  labels = {
    env         = "dev"
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terraform"
    system      = "de-learning"
  }
}

module "raw_bucket" {
  source                 = "../../modules/gcs_bucket"
  project_id             = var.project_id
  name                   = "${var.name_prefix}-dev-raw"
  location               = var.location
  labels                 = local.labels
  versioning_enabled     = true
  lifecycle_age_days     = 30
}

module "staging_bucket" {
  source                 = "../../modules/gcs_bucket"
  project_id             = var.project_id
  name                   = "${var.name_prefix}-dev-staging"
  location               = var.location
  labels                 = local.labels
  versioning_enabled     = true
  lifecycle_age_days     = 14
}

module "curated_bucket" {
  source                 = "../../modules/gcs_bucket"
  project_id             = var.project_id
  name                   = "${var.name_prefix}-dev-curated"
  location               = var.location
  labels                 = local.labels
  versioning_enabled     = true
  lifecycle_age_days     = 90
}

module "temp_bucket" {
  source                 = "../../modules/gcs_bucket"
  project_id             = var.project_id
  name                   = "${var.name_prefix}-dev-temp"
  location               = var.location
  labels                 = local.labels
  versioning_enabled     = false
  lifecycle_age_days     = 7
}

module "bq_raw" {
  source          = "../../modules/bigquery_dataset"
  project_id      = var.project_id
  dataset_id      = "de_dev_raw"
  location        = var.location
  description     = "Development raw dataset for DE learning lab."
  labels          = local.labels
}

module "bq_staging" {
  source          = "../../modules/bigquery_dataset"
  project_id      = var.project_id
  dataset_id      = "de_dev_staging"
  location        = var.location
  description     = "Development staging dataset for DE learning lab."
  labels          = local.labels
  default_table_expiration_ms = 1209600000
}

module "bq_marts" {
  source          = "../../modules/bigquery_dataset"
  project_id      = var.project_id
  dataset_id      = "de_dev_marts"
  location        = var.location
  description     = "Development marts dataset for DE learning lab."
  labels          = local.labels
}

module "loader_sa" {
  source       = "../../modules/service_account"
  project_id   = var.project_id
  account_id   = "de-dev-loader"
  display_name = "DE Dev Loader Service Account"
}

module "transformer_sa" {
  source       = "../../modules/service_account"
  project_id   = var.project_id
  account_id   = "de-dev-transformer"
  display_name = "DE Dev Transformer Service Account"
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
