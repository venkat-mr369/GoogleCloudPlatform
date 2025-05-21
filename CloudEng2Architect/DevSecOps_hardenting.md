# Terraform GCP DevSecOps Hardening Template

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {}
variable "region"    { default = "us-central1" }

# Enable essential APIs
resource "google_project_service" "essential_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "containeranalysis.googleapis.com"
  ])

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

# VPC + Subnet
resource "google_compute_network" "secure_vpc" {
  name                    = "secure-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "secure_subnet" {
  name          = "secure-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.secure_vpc.id
}

# Firewall: deny-all-ingress
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

# Firewall: allow-ssh-from-IAP
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

# Service Account with least privilege
resource "google_service_account" "secure_sa" {
  account_id   = "secure-sa"
  display_name = "Secure Service Account"
}

resource "google_project_iam_member" "secure_sa_logging" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.secure_sa.email}"
}

# Secret Manager: create secret
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = "SuperSecret123!"
}

# Shielded VM example
resource "google_compute_instance" "secure_vm" {
  name         = "secure-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.secure_subnet.name
    access_config {}
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  tags = ["secure-vm"]
}
