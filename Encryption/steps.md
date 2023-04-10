### Below are the steps to execute the Customer-supplied Encryption Keys (CSEK):- Encryption Module

```bash
python3 generate-csek.py
gsutil -o 'GSUtil:encryption_key='n4sUxnFqz3oHbkfdfdfds5WH+RONyyUYfNX1Vdw9kZtvVm+heM50= cp examplecsek.txt gs://$DEVSHELL_PROJECT_ID-csek/examplecsek.txt
gsutil -o 'GSUtil:decryption_key1='encryptionkey cat gs://$DEVSHELL_PROJECT_ID-csek/examplecsek.txt
# this file creates a .boto file ar the ~ 
gsutil config -n 
```
and open boto file

vi ~/.boto
edit ~/.boto
# enable and put the key
encryption_key=
# enable and put the key
decryption_key1=

# What is a Boto file?
A boto config file is a text file formatted like an . ini configuration file that specifies values for options that control the behavior of the boto library. In Unix/Linux systems, on startup, the boto library looks for configuration files in the following locations and in the following order: /etc/boto
