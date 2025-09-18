# Configure the VPC network and subnet for Wiz deployment

resource "google_compute_network" "wiz_vpc" {
  name                    = var.vpc_name
  description             = var.description
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Create a public subnet within the VPC

resource "google_compute_subnetwork" "public_subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.wiz_vpc.id
  ip_cidr_range = var.public_subnet_cidr
}

# Create a private subnet within the VPC

resource "google_compute_subnetwork" "private_subnet" {
  name                     = var.private_subnet_name
  region                   = var.region
  network                  = google_compute_network.wiz_vpc.id
  ip_cidr_range            = var.private_subnet_cidr
  private_ip_google_access = true
}