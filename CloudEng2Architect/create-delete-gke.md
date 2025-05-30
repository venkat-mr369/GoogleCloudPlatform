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
```bash
gcloud components install kubectl
```
```bash
gcloud components install gke-gcloud-auth-plugin
```
#### you can install your shell to work on k8s services
```bash
sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin
```

#### 3. **Create the GKE cluster**

This command creates a regional GKE cluster with 3 nodes distributed across zones in the region `us-central1` (you can change the region).

#### In Autopilot, GKE automatically provisions nodes based on workload needs.
```bash
gcloud container clusters create-auto "my-gke-cluster-wkg" \
  --region "us-central1" \
  --project "randd-1" \
  --release-channel "regular"
```


#### If you want full control over nodes (like specifying 3 nodes), with latest to avoid below issue

Note: The Kubelet readonly port (10255) is now deprecated. Please update your workloads to use the recommended alternatives. See https://cloud.google.com/kubernetes-engine/docs/how-to/disable-kubelet-readonly-port for ways to check usage and for migration instructions.
Note: Your Pod address range (--cluster-ipv4-cidr) can accommodate at most 1008 node(s).

```bash
gcloud container clusters create my-gke-cluster-latest \
  --region us-central1 \
  --num-nodes 3 \
  --enable-ip-alias \
  --cluster-ipv4-cidr=/14 \
  --services-ipv4-cidr=/20 \
  --no-enable-basic-auth \
  --metadata disable-legacy-endpoints=true \
  --workload-metadata-from-node=GKE_METADATA \
  --release-channel regular \
  --enable-autorepair \
  --enable-autoupgrade \
  --logging=SYSTEM,WORKLOAD \
  --monitoring=SYSTEM \
  --tags=gke-cluster \
  --enable-stackdriver-kubernetes

```

| **Issue**                 | **Fix/Update**                                                                                                                                                                                                                                          |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Deprecated port 10255** | Ensure that none of your pods or services are configured to use the read-only Kubelet port. No need to configure this during cluster creation. [Check usage here](https://cloud.google.com/kubernetes-engine/docs/how-to/disable-kubelet-readonly-port) |
| **Pod IP range limit**    | By setting `--cluster-ipv4-cidr=/14`, you're allowing a max of \~16,384 pod IPs, which comfortably supports 1000+ nodes. Adjust this based on your expected scale.                                                                                      |
| **Security**              | `--no-enable-basic-auth` and `--metadata disable-legacy-endpoints=true` to enhance security.                                                                                                                                                            |
| **Workload metadata**     | Use `GKE_METADATA` for secure access to metadata.                                                                                                                                                                                                       |
| **Monitoring & Logging**  | Includes both system and workload metrics.                                                                                                                                                                                                              |


Alternatively, for a **zonal cluster** (all 3 nodes in the same zone):

```bash
gcloud container clusters create gke-cluster-manualnodes \
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
```bash
kubectl get nodes -o wide
```
```bash
kubectl get pods -o wide
```

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
