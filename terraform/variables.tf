variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "wiz-dev-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "wiz-dev-public-subnet"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_name" {
  description = "The name of the private subnet"
  type        = string
  default     = "wiz-dev-private-subnet"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west1"
}

variable "description" {
  description = "Description for the VPC network"
  type        = string
  default     = "VPC for Wiz Dev infrastructure"
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "clgcporg10-181"
}

variable "mongodb_instance_name" {
  description = "The name of the MongoDB VM instance"
  type        = string
  default     = "wiz-mongodb-dev-vm"
}

variable "mongodb_machine_type" {
  description = "The machine type for the MongoDB VM instance"
  type        = string
  default     = "e2-medium"
}

variable "zone" {
  description = "The GCP zone for the VM instance"
  type        = string
  default     = "europe-west1-b"
}

variable "gke_cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "wiz-gke-dev-cluster"
}