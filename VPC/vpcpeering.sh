
#echo "Enabling Compute API"
#gcloud services enable compute.googleapis.com
#echo Delete default VPC

#gcloud compute firewall-rules delete default-allow-icmp default-allow-internal default-allow-rdp default-allow-ssh --quiet

#gcloud compute networks delete default --quiet

#echo Create 3 VPC networks, with purposely overlapping subnets


gcloud compute networks create network-1 --subnet-mode=custom 

gcloud compute networks subnets create subnet-1a --network=my-network-1 --region=europe-west1 --range=10.0.1.0/24

gcloud compute networks subnets create subnet-1b --network=my-network-1 --region=europe-west1 --range=10.1.1.0/24


gcloud compute networks create network-2 --subnet-mode=custom

gcloud compute networks subnets create subnet-2a --network=my-network-2 --region=europe-west1 --range=10.0.2.0/24

gcloud compute networks subnets create subnet-2b --network=my-network-2 --region=europe-west1 --range=10.1.2.0/24

gcloud compute networks subnets create conflict-with-my-network-1-subnet --network=my-network-2 --region=europe-west1 --range=10.0.1.0/24

gcloud compute networks create network-3 --subnet-mode=custom

gcloud compute networks subnets create subnet-3a --network=my-network-3 --region=europe-west1 --range=10.0.3.0/24

gcloud compute networks subnets create subnet-3b --network=my-network-3 --region=europe-west1 --range=10.1.3.0/24

gcloud compute networks subnets create conflict-with-network-2-subnet --network=my-network-3 --region=europe-west1 --range=10.0.2.0/24

echo Create firewall rules to allow port 22 , icmp access for all network resources

gcloud compute firewall-rules create ssh-allow-network-1 --direction=INGRESS --priority=1000 --network=my-network-1 --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create icmp-allow-network-1 --direction=INGRESS --priority=1000 --network=my-network-1 --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0


gcloud compute firewall-rules create ssh-allow-network-2 --direction=INGRESS --priority=1000 --network=my-network-2 --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create icmp-allow-network-2 --direction=INGRESS --priority=1000 --network=my-network-2 --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create ssh-allow-network-3 --direction=INGRESS --priority=1000 --network=my-network-3 --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create icmp-allow-network-3 --direction=INGRESS --priority=1000 --network=my-network-3 --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0

echo Create a instance in each created subnet

gcloud compute instances create myinstance-1 --zone=europe-west1-a --machine-type=f1-micro --subnet=subnet-1a

gcloud compute instances create myinstance-2 --zone=europe-west1-a --machine-type=f1-micro --subnet=subnet-2a

gcloud compute instances create myinstance-3 --zone=europe-west1-a --machine-type=f1-micro --subnet=subnet-3a


echo Setup complete, proceed to establish a VPC peering

