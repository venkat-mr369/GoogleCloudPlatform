#### Explanation of GKE Cluster Creation Command
--- This document explains each parameter used in the following `gcloud` command to create a Google Kubernetes Engine (GKE) cluster.
--- Command:
```bash
gcloud container clusters create my-gke-cluster-latest \
  --region us-central1 \
  --num-nodes 3 \
  --enable-ip-alias \
  --disk-type=pd-ssd \
  --disk-size=20 \
  --cluster-ipv4-cidr=/14 \
  --services-ipv4-cidr=/20 \
  --no-enable-basic-auth \
  --metadata disable-legacy-endpoints=true \
  --workload-pool=randd-1.svc.id.goog \
  --workload-metadata-from-node=GKE_METADATA \
  --release-channel regular \
  --enable-autorepair \
  --enable-autoupgrade \
  --logging=SYSTEM,WORKLOAD \
  --monitoring=SYSTEM \
  --tags=gke-cluster
```
```bash
Explanation of Parameters:
•	--region us-central1:
  Specifies the region where the GKE cluster will be deployed.
•	--num-nodes 3:
  Sets the default number of nodes per zone in the cluster.
•	--enable-ip-alias:
  Enables alias IP ranges for Pod IPs, required for VPC-native clusters.
•	--disk-type=pd-ssd:
  Specifies the use of SSD persistent disks for node storage.
•	--disk-size=20:
  Sets each node's boot disk size to 20 GB.
•	--cluster-ipv4-cidr=/14:
  Defines the IP range for the Pod network (cluster).
•	--services-ipv4-cidr=/20:
  Defines the IP range for Kubernetes services.
•	--no-enable-basic-auth:
  Disables the basic authentication for accessing the Kubernetes API.
•	--metadata disable-legacy-endpoints=true:
  Disables legacy metadata endpoints to improve node security.
•	--workload-pool=randd-1.svc.id.goog:
  Enables Workload Identity using the specified workload pool.
•	--workload-metadata-from-node=GKE_METADATA:
  Sets the secure way for workloads to access node metadata.
•	--release-channel regular:
  Uses the 'regular' release channel for balanced feature stability and freshness.
•	--enable-autorepair:
  Automatically repairs unhealthy nodes in the cluster.
•	--enable-autoupgrade:
  Automatically upgrades cluster nodes to newer versions.
•	--logging=SYSTEM,WORKLOAD:
  Enables logging for both system components and application workloads.
•	--monitoring=SYSTEM:
  Enables monitoring of system metrics.
•	--tags=gke-cluster:
  Applies network tags to all VM instances in the cluster for firewall rules or other purposes.
```
