# Create a GCS bucket for MongoDB backups

resource "google_storage_bucket" "mongo_backups" {
  name     = "wiz-mongo-dev-backups-${random_id.bucket_suffix.hex}"
  location = var.region
  project  = var.project_id
}

# Upload the Cloud Function source code to the GCS bucket

resource "google_storage_bucket_object" "function_source" {
  name   = "mongo_backup_function_source.zip"
  bucket = google_storage_bucket.mongo_backups.name
  source = "functions/mongo_backup_function_source.zip"
}

# Create a service account for the Cloud Function with overly permissive roles

resource "google_service_account" "over_permissive" {
  account_id   = "mongo-backup-sa"
  display_name = "Service Account for MongoDB Backup Function with overly permissive roles"
  project      = var.project_id
}

resource "google_project_iam_member" "over_permissive_binding" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.over_permissive.email}"
}

# Make the GCS bucket publicly accessible (read and list) for demonstration purposes

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket  = google_storage_bucket.mongo_backups.name
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "google_storage_bucket_iam_binding" "public_list" {
  bucket  = google_storage_bucket.mongo_backups.name
  role    = "roles/storage.legacyBucketReader"
  members = ["allUsers"]
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Cloud Function to back up MongoDB to GCS

resource "google_cloudfunctions_function" "mongo_backup" {
  name                  = "mongo-backup-function"
  description           = "Function to back up MongoDB to GCS"
  runtime               = "python39"
  entry_point           = "backup_mongo"
  timeout               = 540
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.mongo_backups.name
  source_archive_object = google_storage_bucket_object.function_source.name
  trigger_http          = true
  project               = var.project_id

  environment_variables = {
    MONGO_HOST    = google_compute_instance.mongodb_instance.network_interface[0].network_ip
    MONGO_PORT    = "27017"
    GCS_BUCKET    = google_storage_bucket.mongo_backups.name
    BACKUP_PREFIX = "backups/"
  }

  service_account_email = google_service_account.over_permissive.email

  depends_on = [google_storage_bucket.mongo_backups]
}

# Cloud Scheduler job to trigger MongoDB backups every day at midnight

resource "google_cloud_scheduler_job" "daily_backup" {
  name        = "daily-mongo-backup"
  description = "Daily MongoDB backup to GCS"
  schedule    = "0 2 * * *"
  time_zone   = "Europe/Amsterdam"

  http_target {
    uri         = google_cloudfunctions_function.mongo_backup.https_trigger_url
    http_method = "POST"
    oidc_token {
      service_account_email = google_service_account.over_permissive.email
    }
  }
  depends_on = [google_storage_bucket.mongo_backups]
}