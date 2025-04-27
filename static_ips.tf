data "google_compute_subnetwork" "subnet" {
  name    = var.cluster_config[local.env].subnetwork
  project = var.cluster_config[local.env].network_project_id
  region  = var.cluster_config[local.env].region
}

resource "google_compute_address" "static_ips" {
  for_each    = { for ip in var.cluster_config[local.env].static_ips : ip => ip }
  name        = each.value
  address_type = "INTERNAL"
  region      = var.cluster_config[local.env].region
  subnetwork = data.google_compute_subnetwork.subnet.self_link
  project     = var.cluster_config[local.env].project_id
}
