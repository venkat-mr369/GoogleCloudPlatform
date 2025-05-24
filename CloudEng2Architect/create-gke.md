To create a GKE (Google Kubernetes Engine) cluster with **3 nodes** using `gcloud` commands in the project `randd-1`, follow the steps below:

---

### ✅ **Step-by-step GKE Cluster Creation**

#### 1. **Set the project**

```bash
gcloud config set project randd-1
```

#### 2. **Enable required services**

```bash
gcloud services enable container.googleapis.com
```

#### 3. **Create the GKE cluster**

This command creates a regional GKE cluster with 3 nodes distributed across zones in the region `us-central1` (you can change the region).

```bash
gcloud container clusters create-auto my-gke-cluster \
  --region us-central1 \
  --project randd-1 \
  --release-channel regular \
  --node-count 3
```

Alternatively, for a **zonal cluster** (all 3 nodes in the same zone):

```bash
gcloud container clusters create my-gke-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --project randd-1
```

---

### 📌 Notes:

* `my-gke-cluster`: Replace with your preferred cluster name.
* `--region` vs `--zone`: Use `create-auto` with `--region` for Autopilot or regional Standard clusters.
* `--release-channel`: Optional, defines the update channel (`rapid`, `regular`, `stable`).

---

### ✅ **Access your cluster (after creation)**

```bash
gcloud container clusters get-credentials my-gke-cluster \
  --region us-central1 \
  --project randd-1
```

This sets up `kubectl` context to communicate with your GKE cluster.

---

