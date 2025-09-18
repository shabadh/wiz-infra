# Output the MongoDB VM instance details
output "mongodb_instance_ip" {
  value = google_compute_instance.mongodb_vm.network_interface[0].access_config[0].natural_ip
}

output "mongodb_instance_name" {
  value = google_compute_instance.mongodb_vm.name
}

output "mongodb_instance_zone" {
  value = google_compute_instance.mongodb_vm.zone
}

output "mongodb_instance_status" {
  value = google_compute_instance.mongodb_vm.status
}

output "mongodb_instance_self_link" {
  value = google_compute_instance.mongodb_vm.self_link
}