# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# Use selected cluster configuration
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "30.2.0"
  project_id                 = var.cluster_config[local.env].project_id
  name                       = var.cluster_config[local.env].name
  region                     = var.cluster_config[local.env].region
  zones                      = var.cluster_config[local.env].zones
  network                    = var.cluster_config[local.env].network
  network_project_id	     = var.cluster_config[local.env].network_project_id
  subnetwork                 = var.cluster_config[local.env].subnetwork
  ip_range_pods              = "${var.cluster_config[local.env].subnetwork}-pods"
  ip_range_services          = "${var.cluster_config[local.env].subnetwork}-services"
  http_load_balancing        = true
  enable_l4_ilb_subsetting   = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = true
  enable_private_nodes       = true
  remove_default_node_pool   = true
  master_ipv4_cidr_block     = "172.16.0.0/28"

  node_pools = [
    {
      name                      = "node-pool"
      machine_type              = var.cluster_config[local.env].machine_type
      node_locations            = join(",", var.cluster_config[local.env].zones)
      min_count                 = 1
      max_count                 = 1
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = var.cluster_config[local.env].disk_size_gb
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = "DEFAULT"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "${google_service_account.gke.email}"
      preemptible               = false
      initial_node_count        = 1
      autoscaling               = false
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }


  cluster_resource_labels = {
    environment   = local.env
    project       = var.cluster_config[local.env].project_id,
    resource_type = "gke",
    resource_name = var.cluster_config[local.env].name
    customer      = "all"
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }

  master_authorized_networks = [
    {
      cidr_block   = var.cluster_config[local.env].subnetwork_allow
      display_name = "VPC"
    }
  ]
}

resource "google_compute_subnetwork_iam_member" "network_user_service_account" {
  for_each    = { for user in var.cluster_config[local.env].network_user : user => user }
  project     = var.cluster_config[local.env].network_project_id
  subnetwork  = var.cluster_config[local.env].subnetwork
  region      = var.cluster_config[local.env].region
  role        = "roles/compute.networkUser"
  member      = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "hostServiceAgentUser_service_account" {
  for_each    = { for user in var.cluster_config[local.env].hostServiceAgent_user : user => user }
  project = var.cluster_config[local.env].network_project_id
  member      = "serviceAccount:${each.value}"
  role    = "roles/container.hostServiceAgentUser"
}

resource "google_project_iam_member" "serviceAgent_service_account" {
  for_each    = { for user in var.cluster_config[local.env].serviceAgent_user : user => user }
  project = var.cluster_config[local.env].network_project_id
  member      = "serviceAccount:${each.value}"
  role    = "roles/container.serviceAgent"
}

