terraform {
  backend "gcs" {
    bucket = "environments-state"
    prefix = "terraform/state/gke"
  }
}
