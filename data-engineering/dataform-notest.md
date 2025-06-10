Thanks for the project details. Based on your inputs, here’s a **complete and detailed guide to create a GCP Dataform setup using Terraform** for:

* **Project**: `splendid-sled-460802-q9`
* **Dataset**: `him-dataset`
* **Region**: `us-east1`
* **Service Account**: `hometown@splendid-sled-460802-q9.iam.gserviceaccount.com`

---

## ✅ Goal

Provision the following with Terraform:

1. **BigQuery Dataset** (`him-dataset`)
2. **Dataform Repository**
3. **Compilation Result** (for testing SQL models)
4. **Workflow Configuration** (optional scheduled pipeline)
5. **IAM Permissions** for the service account

---

## 📁 Terraform Structure

```
dataform-terraform/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
```

---

## 🔹 Step 1: Enable Required APIs

Before running Terraform, run:

```bash
gcloud services enable dataform.googleapis.com bigquery.googleapis.com
```

---

## 🔹 Step 2: `variables.tf`

```hcl
variable "project_id" {
  default = "splendid-sled-460802-q9"
}

variable "region" {
  default = "us-east1"
}

variable "dataset_id" {
  default = "him-dataset"
}

variable "repository_name" {
  default = "him-dataform-repo"
}

variable "git_uri" {
  default = "https://github.com/your-org/dataform-repo.git"
}

variable "branch" {
  default = "main"
}

variable "service_account_email" {
  default = "hometown@splendid-sled-460802-q9.iam.gserviceaccount.com"
}
```

---

## 🔹 Step 3: `main.tf`

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

# BigQuery Dataset
resource "google_bigquery_dataset" "him_dataset" {
  dataset_id = var.dataset_id
  project    = var.project_id
  location   = var.region
  description = "Dataset for Snowflake migration"
}

# Dataform Repository
resource "google_dataform_repository" "dataform_repo" {
  name         = var.repository_name
  project      = var.project_id
  region       = var.region
  display_name = "HIM Dataform Repository"

  git_remote_settings {
    url            = var.git_uri
    default_branch = var.branch
  }
}

# Optional Compilation Result (test build)
resource "google_dataform_compilation_result" "compile" {
  project    = var.project_id
  region     = var.region
  repository = google_dataform_repository.dataform_repo.name
  git_commitish = var.branch

  release_config {
    release_compilation_enabled = true
  }
}

# Optional Workflow Configuration (daily schedule)
resource "google_dataform_workflow_config" "daily_workflow" {
  project     = var.project_id
  region      = var.region
  repository  = google_dataform_repository.dataform_repo.name
  name        = "daily_workflow"
  display_name = "Daily Snowflake ELT Run"

  schedule {
    cron      = "0 3 * * *"  # 3 AM UTC daily
    time_zone = "UTC"
  }

  release_config {
    release_compilation_enabled = true
  }

  invocation_config {
    included_tags = ["daily"]
  }
}

# IAM Binding for the Dataform Service Account to access BigQuery
resource "google_bigquery_dataset_iam_member" "dataform_access" {
  dataset_id = google_bigquery_dataset.him_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${var.service_account_email}"
}
```

---

## 🔹 Step 4: `terraform.tfvars`

```hcl
project_id            = "splendid-sled-460802-q9"
region                = "us-east1"
dataset_id            = "him-dataset"
repository_name       = "him-dataform-repo"
git_uri               = "https://github.com/your-org/dataform-repo.git"
branch                = "main"
service_account_email = "hometown@splendid-sled-460802-q9.iam.gserviceaccount.com"
```

---

## 🔹 Step 5: `outputs.tf`

```hcl
output "dataset_id" {
  value = google_bigquery_dataset.him_dataset.dataset_id
}

output "dataform_repository" {
  value = google_dataform_repository.dataform_repo.name
}

output "workflow_name" {
  value = google_dataform_workflow_config.daily_workflow.name
}
```

---

## 🔹 Step 6: Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

---

## 🔐 IAM Notes

Ensure `hometown@splendid-sled-460802-q9.iam.gserviceaccount.com` has:

* `roles/dataform.admin`
* `roles/bigquery.dataEditor`
* Access to your Git repo (via GitHub/GitLab token or deploy key)

---

## 📈 Optional Diagram and Word Document?

Would you like me to generate a **Word document** version of this with:

* A **Visio-style diagram** (Dataform + BQ + Git)
* Proper headers, structure, and command line highlights?

Let me know, and I’ll prepare the file for download.
