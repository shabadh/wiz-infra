resource "google_compute_instance" "mongodb_vm" {
  name         = var.mongodb_instance_name
  machine_type = var.mongodb_machine_type
  zone         = var.zone
  project      = var.project_id


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
      size  = 50
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.wiz_vpc.id
    subnetwork = google_compute_subnetwork.public_subnet.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
        apt-get update
        apt-get install -y mongodb
        systemctl start mongodb
        systemctl enable mongodb
    EOT

  tags = ["mongodb-server"]
  service_account {
    email  = google_service_account.mongodb_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  depends_on = [google_compute_firewall.allow_mongodb]
}

# Create a service account for the MongoDB VM
resource "google_service_account" "mongodb_sa" {
  account_id   = "mongodb-sa"
  display_name = "Service Account for MongoDB VM with overly permissive roles"
  project      = var.project_id
}

resource "google_project_iam_member" "over_permissive_binding" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.mongodb_sa.email}"
}

# Firewall rule to allow MongoDB traffic

resource "google_compute_firewall" "allow_mongodb_k8s" {
  name    = "allow-mongodb"
  network = google_compute_network.wiz_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  source_ranges = ["10.0.2.0/24"]
  project       = var.project_id
}

# Firewall rule to allow SSH access to the MongoDB VM

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.wiz_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # Allow SSH from anywhere
  target_tags   = ["mongodb-server"]
  project       = var.project_id
}

