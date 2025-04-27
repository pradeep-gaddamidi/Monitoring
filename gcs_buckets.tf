module "gcs_buckets" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 5.0"
  project_id  = var.cluster_config[local.env].project_id
  location    = "US"
  storage_class = "STANDARD"
  names = var.cluster_config[local.env].bucket_names
  labels = {
    environment   = local.env
    project       = var.cluster_config[local.env].project_id
    resource_type = "gcs"
    customer      = "all"
  }
}

resource "google_storage_bucket_iam_binding" "buckets" {
  for_each    = { for bucket in var.cluster_config[local.env].bucket_names : bucket => bucket }
  bucket = each.value
  role = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.gke.email}"
  ]
  depends_on = [module.gcs_buckets]
}
