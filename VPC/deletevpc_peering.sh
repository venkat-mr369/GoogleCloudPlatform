#gcloud compute firewall-rules create
#gcloud compute firewall-rules delete
#gcloud compute firewall-rules describe
#gcloud compute firewall-rules list
#gcloud compute firewall-rules update

#According to the list, mentioned that names and delete
#gcloud compute firewall-rules list
#Do you want to continue (Y/n)? for this --quiet the flag

gcloud compute firewall-rules delete ssh-allow-network-1 ssh-allow-network-2 ssh-allow-network-3 --quiet
gcloud compute firewall-rules delete icmp-allow-network-1 icmp-allow-network-2 icmp-allow-network-3 --quiet

#According to the list, mentioned that instances names with zones then you can delete
#gcloud compute instances list
gcloud compute instances delete myinstance-1 myinstance-2 --zone=europe-west1-b --quiet
gcloud compute instances delete myinstance-3 --zone=europe-west1-c --quiet

#gcloud compute networks subnets  list --filter=my-network-1
#gcloud compute networks subnets  list --filter='my-network-2' 'my-network-3'
#gcloud compute networks subnets  list --filter="my-network-2" "my-network-3"

gcloud compute networks subnets delete subnet-1a subnet-1b --region europe-west1 --quiet
gcloud compute networks subnets delete conflict-with-my-network-2-subnet subnet-2a subnet-2b --region europe-west1 --quiet
gcloud compute networks subnets delete conflict-with-my-network-3-subnet subnet-3a subnet-3b --region europe-west1 --quiet

#To delete a network with the name 'myvpc-network-1', run:
gcloud compute networks delete myvpc-network-1 --quiet

#To delete two networks with the names 'myvpc-network-1' and 'myvpc-network-2', run:
gcloud compute networks delete myvpc-network-2 myvpc-network-3 --quiet
