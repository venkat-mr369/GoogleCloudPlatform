**complete and detailed guide to deploy GCP Dataform using Terraform** for your Snowflake → BigQuery migration project.

---

## ✅ PROJECT DETAILS (AS PROVIDED)

| Parameter               | Value                                                                                                                                 |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Terraform Repo Path** | `data-engineering/dataform` or [GitHub Link](https://github.com/venkat-mr369/GoogleCloudPlatform/blob/main/data-engineering/dataform) |
| **GCP Project**         | `splendid-sled-460802-q9`                                                                                                             |
| **Region**              | `us-east1`                                                                                                                            |
| **BigQuery Dataset**    | `him-dataset`                                                                                                                         |
| **Service Account**     | `hometown@splendid-sled-460802-q9.iam.gserviceaccount.com`                                                                            |

---

## 📦 OBJECTIVE

Provision using Terraform:

1. BigQuery Dataset
2. Dataform Repository (linked to your GitHub)
3. Optional Compilation Result (to verify setup)
4. Optional Workflow Config (to schedule transformations)
5. IAM roles for the service account

---

## 📁 Terraform Structure in Your Repo

Update or organize your directory as:

```
data-engineering/
└── dataform/
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    └── outputs.tf
```

---

## 🔧 Step-by-Step Terraform Setup

### 🔹 `variables.tf`

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
  default = "dataform-him-repo"
}

variable "git_uri" {
  default = "https://github.com/venkat-mr369/GoogleCloudPlatform.git"
}

variable "repo_directory" {
  default = "data-engineering/dataform"
}

variable "branch" {
  default = "main"
}

variable "service_account_email" {
  default = "hometown@splendid-sled-460802-q9.iam.gserviceaccount.com"
}
```

---

### 🔹 `main.tf`

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

# BigQuery Dataset
resource "google_bigquery_dataset" "him_dataset" {
  dataset_id  = var.dataset_id
  location    = var.region
  project     = var.project_id
  description = "Dataset for Dataform-based ELT pipelines"
}

# Dataform Repository
resource "google_dataform_repository" "dataform_repo" {
  name         = var.repository_name
  project      = var.project_id
  region       = var.region
  display_name = "HIM Dataform Repo"
  
  git_remote_settings {
    url            = var.git_uri
    default_branch = var.branch
    path           = var.repo_directory
  }
}

# (Optional) Compile to test Dataform config
resource "google_dataform_compilation_result" "compile_result" {
  project    = var.project_id
  region     = var.region
  repository = google_dataform_repository.dataform_repo.name
  git_commitish = var.branch

  release_config {
    release_compilation_enabled = true
  }
}

# (Optional) Workflow - Daily run of tagged models
resource "google_dataform_workflow_config" "workflow_config" {
  name         = "daily_him_workflow"
  display_name = "Daily HIM Transformation"
  project      = var.project_id
  region       = var.region
  repository   = google_dataform_repository.dataform_repo.name

  schedule {
    cron      = "0 4 * * *"  # 4 AM UTC
    time_zone = "UTC"
  }

  release_config {
    release_compilation_enabled = true
  }

  invocation_config {
    included_tags = ["daily"]
  }
}

# IAM Binding - Allow service account access to BigQuery
resource "google_bigquery_dataset_iam_member" "bq_access" {
  dataset_id = google_bigquery_dataset.him_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${var.service_account_email}"
}

# IAM for Dataform Repository
resource "google_dataform_repository_iam_member" "dataform_repo_editor" {
  project    = var.project_id
  region     = var.region
  repository = google_dataform_repository.dataform_repo.name
  role       = "roles/dataform.editor"
  member     = "serviceAccount:${var.service_account_email}"
}
```

---

### 🔹 `terraform.tfvars`

```hcl
project_id            = "splendid-sled-460802-q9"
region                = "us-east1"
dataset_id            = "him-dataset"
repository_name       = "dataform-him-repo"
git_uri               = "https://github.com/venkat-mr369/GoogleCloudPlatform.git"
repo_directory        = "data-engineering/dataform"
branch                = "main"
service_account_email = "hometown@splendid-sled-460802-q9.iam.gserviceaccount.com"
```

---

### 🔹 `outputs.tf`

```hcl
output "repository_name" {
  value = google_dataform_repository.dataform_repo.name
}

output "workflow_name" {
  value = google_dataform_workflow_config.workflow_config.name
}

output "dataset_id" {
  value = google_bigquery_dataset.him_dataset.dataset_id
}
```

---

## 🔄 Terraform Execution Steps

```bash
cd data-engineering/dataform

terraform init
terraform plan
terraform apply
```

---

## 🔐 Service Account IAM Pre-check

Make sure the service account has these roles in the project:

```bash
gcloud projects add-iam-policy-binding splendid-sled-460802-q9 \
  --member="serviceAccount:hometown@splendid-sled-460802-q9.iam.gserviceaccount.com" \
  --role="roles/dataform.editor"

gcloud projects add-iam-policy-binding splendid-sled-460802-q9 \
  --member="serviceAccount:hometown@splendid-sled-460802-q9.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"
```

---

## 📌 GitHub Setup Reminder

For **GitHub integration**, ensure:

* The Dataform workspace in GCP has OAuth access to your GitHub repo
* The repo contains valid `definitions/`, `dataform.json`, `.sqlx`, and `.yaml` files

---

## 📄 Want a Word Document + Diagram?

Would you like me to export this setup as:

* A polished Word document
* A Visio-style diagram showing:

  * GitHub repo → Dataform → BigQuery pipeline
  * Terraform IaC integration flow

If yes, I’ll generate and share the `.docx` file with visuals. Let me know.
