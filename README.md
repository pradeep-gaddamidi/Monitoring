This repo is created to support installing monitoring compoenents such as Prometheus, Grafana and Mimir on Kubernetes cluster.

This Terraform code in this repo creates a Private Kubernetes cluster in google cloud.
It also creates supporting other monitoring resources such as GCS buckets, Static IPs, Service accounts etc.

Instructions:

Terraform workspace set nonprod
terraform plan
terraform apply
