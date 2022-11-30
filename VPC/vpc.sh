#gcloud commands to create network 
gcloud compute networks create my-vpc-network --subnet-mode=custom


# To create a subnet to already created network
gcloud compute networks subnets create subnet-a  --network=my-vpc-network --range=10.0.10.0/24 --region=asia-southeast1
gcloud compute networks subnets create subnet-b  --network=my-vpc-network --range=10.0.20.0/24 --region=asia-southeast1

gcloud compute instances create instance-1a --zone=asia-southeast1-a --machine-type=f1-micro --subnet=subnet-a 
gcloud compute instances create instance-1b --zone=asia-southeast1-a --machine-type=f1-micro --subnet=subnet-a --no-address
