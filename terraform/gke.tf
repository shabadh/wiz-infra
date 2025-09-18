resource "google_container_cluster" "wiz_gke" {
  name       = var.gke_cluster_name
  location   = var.region
  network    = var.vpc_name
  subnetwork = var.private_subnet_name
  project    = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

}

resource "google_container_node_pool" "primary_nodes" {
  name     = "primary-node-pool"
  cluster  = google_container_cluster.wiz_gke.name
  location = var.region
  project  = var.project_id

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags = ["gke-node"]
  }

  initial_node_count = 2
}