Perfect! Here's a **GCP DevSecOps Security Bootstrap Script** using `bash` and `gcloud` — designed to **secure IAM, VPC, Shielded VMs, Cloud Build, and Secret Manager** in a new or existing project. This can be extended into Terraform later if you prefer Infrastructure as Code.

---

## 🔐 GCP DevSecOps Security Bootstrap Script (Bash + `gcloud`)

> **Before You Run**: Set your project ID and billing is enabled.

```bash
#!/bin/bash

# === CONFIG ===
PROJECT_ID="your-project-id"
REGION="us-central1"
VPC_NAME="secure-vpc"
SUBNET_NAME="secure-subnet"
SERVICE_ACCOUNT_NAME="secure-sa"

# === 1. SET PROJECT ===
gcloud config set project $PROJECT_ID

# === 2. Enable Key APIs ===
gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  container.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  containeranalysis.googleapis.com

# === 3. Create Custom VPC with deny-all ingress ===
gcloud compute networks create $VPC_NAME --subnet-mode=custom

gcloud compute networks subnets create $SUBNET_NAME \
  --network=$VPC_NAME \
  --region=$REGION \
  --range=10.10.0.0/24

gcloud compute firewall-rules create deny-all-ingress \
  --network=$VPC_NAME \
  --direction=INGRESS \
  --priority=1000 \
  --action=DENY \
  --rules=all

# Allow SSH only from Google IAP
gcloud compute firewall-rules create allow-ssh-from-iap \
  --network=$VPC_NAME \
  --direction=INGRESS \
  --priority=900 \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=35.235.240.0/20

# === 4. Create Shielded VM (debian)
gcloud compute instances create secure-vm \
  --zone=$REGION-a \
  --machine-type=e2-micro \
  --subnet=$SUBNET_NAME \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --tags=secure-vm

# === 5. Create Least Privilege Service Account ===
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --description="Least privilege service account" \
  --display-name="Secure Service Account"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"

# === 6. Create Secret in Secret Manager ===
gcloud secrets create db-password --replication-policy="automatic"

echo -n "SuperSecret123!" | gcloud secrets versions add db-password --data-file=-

# === 7. Harden Cloud Build Permissions ===
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"

# === 8. Enable Binary Authorization (optional hardening)
gcloud container binauthz policy export > policy.yaml

# NOTE: You must manually edit `policy.yaml` to allow only signed images or specific registries
# Then re-import it:
# gcloud container binauthz policy import policy.yaml

# === 9. Enable Cloud Logging & Monitoring Alerts ===
gcloud logging sinks create security-logs-sink \
  storage.googleapis.com/YOUR_LOGGING_BUCKET \
  --log-filter='protoPayload.methodName:"SetIamPolicy" OR "compute.firewalls.insert"' \
  --include-children

echo "✅ GCP DevSecOps Hardening Completed."
```

---

## 📦 Optional: What to Add Next?

* ✅ Terraform version of this script
* ✅ CI/CD secured pipeline in Cloud Build or GitHub Actions
* ✅ Monitoring dashboard in Cloud Monitoring
* ✅ Audit policy for organization-level

---

