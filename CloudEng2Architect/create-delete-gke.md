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

#### In Autopilot, GKE automatically provisions nodes based on workload needs.
```bash
gcloud container clusters create-auto "my-gke-cluster" \
  --region "us-central1" \
  --project "randd-1" \
  --release-channel "regular"
```


#### If you want full control over nodes (like specifying 3 nodes), use create instead of create-auto:
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

To delete the **GKE cluster (and its nodes)** you created using `gcloud`, use the following command:

---

### 🧨 **Delete the GKE cluster (and all 3 nodes)**

#### If it's a **regional Autopilot** or **regional Standard** cluster:

```bash
gcloud container clusters delete my-gke-cluster \
  --region us-central1 \
  --project randd-1
```

#### If it's a **zonal Standard** cluster:

```bash
gcloud container clusters delete my-gke-cluster \
  --zone us-central1-a \
  --project randd-1
```

---

### 🔒 You will be prompted for confirmation:

If you want to **skip confirmation**, add the `--quiet` flag:

```bash
gcloud container clusters delete my-gke-cluster --region us-central1 --quiet
```

---

### ⚠️ Important:

* Deleting the cluster deletes **all node pools** and **Kubernetes workloads** inside it.
* This **does not delete** other resources like Cloud Storage buckets or external databases unless they are explicitly part of the cluster setup.

Let me know if you only want to delete **specific node pools** instead of the entire cluster.
