  #gcloud compute firewall-rules create
  #gcloud compute firewall-rules delete
  #gcloud compute firewall-rules describe
  #gcloud compute firewall-rules list
  #gcloud compute firewall-rules update

gcloud compute firewall-rules list
#According to the list, mentioned that names and delete

gcloud compute firewall-rules delete ssh-allow-network-1 ssh-allow-network-2 ssh-allow-network-3
gcloud compute firewall-rules delete icmp-allow-network-1 icmp-allow-network-2 icmp-allow-network-3

#To delete a network with the name 'my-network-1', run:
gcloud compute networks delete my-network-1

#To delete two networks with the names 'my-network-1' and 'my-network-2', run:
gcloud compute networks delete network-name2 network-name3
