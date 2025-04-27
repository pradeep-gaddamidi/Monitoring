resource "google_service_account" "gke" {
  account_id   = "gke-${local.env}"
  project    = var.cluster_config[local.env].project_id
  display_name = "Service account for gke"
}
