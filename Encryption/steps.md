### Below are the steps to execute the Customer-supplied Encryption Keys (CSEK):- Encryption Module

```bash
python3 generate-csek.py
gsutil -o 'GSUtil:encryption_key='n4sUxnFqz3oHbkfdfdfds5WH+RONyyUYfNX1Vdw9kZtvVm+heM50= cp examplecsek.txt gs://$DEVSHELL_PROJECT_ID-csek/examplecsek.txt
gsutil -o 'GSUtil:decryption_key1='encryptionkey cat gs://$DEVSHELL_PROJECT_ID-csek/examplecsek.txt
# this file creates a .boto file ar the ~ 
gsutil config -n 
```
