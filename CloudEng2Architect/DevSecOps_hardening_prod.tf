# Terraform code is now split into standard main.tf, variables.tf, and outputs.tf sections for production readiness.
// main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable essential APIs
resource "google_project_service" "essential_apis" {
  for_each = toset(var.essential_apis)

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

# VPC + Subnet
resource "google_compute_network" "secure_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "secure_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.secure_vpc.id
}

# Firewall Rules
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "deny-all-ingress"
  network = google_compute_network.secure_vpc.name

  direction = "INGRESS"
  priority  = 1000
  action    = "DENY"

  rules {
    protocol = "all"
  }
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-ssh-from-iap"
  network = google_compute_network.secure_vpc.name

  direction     = "INGRESS"
  priority      = 900
  action        = "ALLOW"
  source_ranges = ["35.235.240.0/20"]

  rules {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Least Privilege Service Account
resource "google_service_account" "secure_sa" {
  account_id   = var.service_account_id
  display_name = "Secure Service Account"
}

resource "google_project_iam_member" "secure_sa_logging" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.secure_sa.email}"
}

# Secret Manager
resource "google_secret_manager_secret" "db_password" {
  secret_id = var.secret_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.secret_value
}

# Shielded VM
resource "google_compute_instance" "secure_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  network_interface {
    subnetwork    = google_compute_subnetwork.secure_subnet.name
    access_config {}
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  tags = ["secure-vm"]
}

// variables.tf
variable "project_id" {}
variable "region" { default = "us-central1" }

variable "vpc_name" { default = "secure-vpc" }
variable "subnet_name" { default = "secure-subnet" }
variable "subnet_cidr" { default = "10.10.0.0/24" }

variable "essential_apis" {
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "containeranalysis.googleapis.com"
  ]
}

variable "service_account_id" { default = "secure-sa" }
variable "secret_id" { default = "db-password" }
variable "secret_value" { default = "SuperSecret123!" }

variable "vm_name" { default = "secure-vm" }
variable "machine_type" { default = "e2-micro" }
variable "vm_image" { default = "debian-cloud/debian-11" }

// outputs.tf
output "service_account_email" {
  value = google_service_account.secure_sa.email
}

output "vm_instance_ip" {
  value = google_compute_instance.secure_vm.network_interface[0].access_config[0].nat_ip
}

output "secret_resource_id" {
  value = google_secret_manager_secret.db_password.id
}
