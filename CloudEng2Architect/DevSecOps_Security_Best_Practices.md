Here’s a **GCP DevSecOps Security Best Practices guide with practical `gcloud` commands**, designed for securing your **GCP environment across IAM, networks, workloads, and CI/CD pipelines**.

This is hands-on and ideal for DevOps or platform engineers building secure pipelines and infrastructure.

---

## 🔐 GCP DevSecOps: Security Best Practices with `gcloud`

---

### ✅ 1. **Identity & Access Management (IAM) Hardening**

#### 🔒 Principle of Least Privilege

Only assign **roles with minimum permissions**.

```bash
# List IAM roles for a project
gcloud projects get-iam-policy PROJECT_ID

# Assign a minimal role to a user
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:dev@example.com" \
  --role="roles/viewer"
```

#### 🔍 Audit who has access

```bash
gcloud iam roles list --project=PROJECT_ID
gcloud projects get-iam-policy PROJECT_ID
```

#### 🧾 Enable IAM audit logs

```bash
gcloud logging sinks create iam-audit-logs \
  storage.googleapis.com/YOUR_BUCKET --log-filter='logName:"cloudaudit.googleapis.com"'
```

---

### ✅ 2. **Service Accounts & Secrets Management**

#### 🚫 Disable unused default service accounts

```bash
gcloud iam service-accounts disable \
  --project=PROJECT_ID \
  service-PROJECT_NUMBER@compute-system.iam.gserviceaccount.com
```

#### 🔐 Create & limit a service account

```bash
gcloud iam service-accounts create secure-sa \
  --description="Least privilege SA" --display-name="SecureSA"

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:secure-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"
```

#### 🧪 Rotate service account keys regularly

```bash
# List keys
gcloud iam service-accounts keys list --iam-account secure-sa@PROJECT_ID.iam.gserviceaccount.com

# Delete old key
gcloud iam service-accounts keys delete KEY_ID \
  --iam-account secure-sa@PROJECT_ID.iam.gserviceaccount.com
```

#### 🔐 Use Secret Manager for secrets

```bash
gcloud secrets create db-password --replication-policy="automatic"

echo -n "SuperSecretPass" | gcloud secrets versions add db-password --data-file=-

gcloud secrets versions access latest --secret=db-password
```

---

### ✅ 3. **Network Security**

#### 🚫 Create private VPC subnets with firewall rules

```bash
gcloud compute networks create secure-vpc --subnet-mode=custom

gcloud compute networks subnets create secure-subnet \
  --network=secure-vpc --range=10.10.0.0/24 --region=us-central1

gcloud compute firewall-rules create deny-all-ingress \
  --network=secure-vpc --direction=INGRESS --priority=1000 \
  --action=DENY --rules=all
```

#### 🔥 Add specific allow-list firewall

```bash
gcloud compute firewall-rules create allow-ssh \
  --network=secure-vpc --direction=INGRESS --priority=100 \
  --action=ALLOW --rules=tcp:22 \
  --source-ranges=35.235.240.0/20
```

#### 🛡️ Enable VPC Service Controls for data exfiltration protection

```bash
gcloud access-context-manager perimeters create secure-perimeter \
  --title="Perimeter" --perimeter-type=regular --resources=projects/PROJECT_ID
```

---

### ✅ 4. **Container & VM Security**

#### 🧪 Enable Shielded VMs

```bash
gcloud compute instances create secure-vm \
  --shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --image-family=debian-11 --image-project=debian-cloud
```

#### ✅ Use GKE Autopilot with workload identity

```bash
gcloud container clusters create-auto secure-cluster \
  --region us-central1

# Enable Workload Identity
gcloud container clusters update secure-cluster \
  --workload-pool=PROJECT_ID.svc.id.goog
```

#### 🔍 Scan containers (Container Analysis)

```bash
gcloud artifacts docker images list gcr.io/PROJECT_ID/my-image

gcloud container images describe gcr.io/PROJECT_ID/my-image@sha256:HASH
```

---

### ✅ 5. **CI/CD DevSecOps Practices**

#### ✅ Use Cloud Build with restricted IAM & audit logging

```bash
# Assign minimal IAM for Cloud Build
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"
```

#### 🛡️ Scan images during builds with security policy

* Integrate [Binary Authorization](https://cloud.google.com/binary-authorization) for secure deployment

```bash
gcloud container binauthz policy export > policy.yaml
# Edit policy.yaml to allow only signed images
gcloud container binauthz policy import policy.yaml
```

---

### ✅ 6. **Logging, Monitoring, and Alerting**

#### 🧭 Enable Cloud Logging & Monitoring

```bash
gcloud services enable logging.googleapis.com monitoring.googleapis.com
```

#### 🔔 Create alert for IAM changes or public access

```bash
# In GCP Console, set alerting policy on logs matching:
# protoPayload.methodName="SetIamPolicy"
```

---

## ✅ Summary: DevSecOps Checklist with `gcloud`

| Area             | Best Practice                         | `gcloud` Command Used                    |
| ---------------- | ------------------------------------- | ---------------------------------------- |
| IAM              | Least privilege, remove defaults      | `projects add-iam-policy-binding`        |
| Service Accounts | Key rotation, secret storage          | `iam service-accounts`, `secrets`        |
| Networking       | VPC firewalls, deny-all baseline      | `compute firewall-rules`                 |
| Containers       | Shielded VMs, GKE autopilot, scanning | `container clusters`, `container images` |
| CI/CD            | Least-priv Cloud Build, Binary Auth   | `cloudbuild`, `binauthz`                 |
| Monitoring       | Enable logs & alert on risky changes  | `services enable`, Logging filters       |

---


