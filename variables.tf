variable "cluster_config" {
  description = "Cluster configuration per environment"
  type        = map(object({
    project_id         = string
    name               = string
    description        = string
    regional           = bool
    region             = string
    zones              = list(string)
    network            = string
    subnetwork         = string
    network_project_id = string
    machine_type       = string
    disk_size_gb       = number
    subnetwork_allow   = string
    bucket_names       = list(string)
    host_project       = string
    network_user       = list(string)
    hostServiceAgent_user = list(string)
    serviceAgent_user = list(string)
    static_ips         = list(string)
    
    # Add more attributes as needed
  }))
  default = {
    nonprod-mon = {
      project_id         = "nonprod-monitoring"
      name               = "cluster-nonprod"
      description        = "nonprod cluster"
      regional           = true
      region             = "us-central1"
      zones              = ["us-central1-a", "us-central1-b", "us-central1-c"]
      network            = "nonprod-vpc"
      subnetwork         = "nonprod-us-central1-sb01"
      subnetwork_allow   = "10.226.0.0/22"
      network_project_id = "nonprod-networking"
      machine_type       = "e2-custom-4-10240"
      disk_size_gb       = "50"
      bucket_names = ["mon_blocks_storage", "mon_alertmanager_storage", "mon_ruler_storage"]
      host_project       = "nonprod-networking"
      network_user       = ["service-123456789123@container-engine-robot.iam.gserviceaccount.com", "123456789123@cloudservices.gserviceaccount.com"]
      hostServiceAgent_user = ["service-123456789123@container-engine-robot.iam.gserviceaccount.com"]
      serviceAgent_user = ["service-123456789123@container-engine-robot.iam.gserviceaccount.com"]
      static_ips         = ["internal-ingress"]
    }
    prod-mon = {
      project_id         = "prod-monitoring"
      name               = "cluster-prod"
      description        = "prod cluster"
      regional           = true
      region             = "us-central1"
      zones              = ["us-central1-a", "us-central1-b", "us-central1-c"]
      network            = "prod-vpc"
      subnetwork         = "prod-us-central1-sb01"
      subnetwork_allow   = "10.227.0.0/22"
      network_project_id = "prod-networking"
      machine_type       = "n2-custom-4-32768"
      disk_size_gb       = "100"
      bucket_names       = ["mon_blocks_storage", "mon_alertmanager_storage", "mon_ruler_storage"]
      host_project       = "prod-networking"
      network_user       = ["service-123456789012@container-engine-robot.iam.gserviceaccount.com", "123456789012@cloudservices.gserviceaccount.com"]
      hostServiceAgent_user = ["service-123456789012@container-engine-robot.iam.gserviceaccount.com"]
      serviceAgent_user = ["service-123456789012@container-engine-robot.iam.gserviceaccount.com"]
      static_ips         = ["internal-ingress"]
    }
  }
}
