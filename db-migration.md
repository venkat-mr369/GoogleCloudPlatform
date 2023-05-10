# Create Database Migration


## Create and connect  Onprem Mysql
```bash
gcloud compute instances create onprim-mysql-new --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20211115 --zone us-central1-a

# Perform the following actions to install mysql
sudo apt update
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Enter into mysql terminal 
mysql

# Create a database
create database demo;

use demo

# Create a table
CREATE TABLE Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);

# Insert into tables
INSERT INTO Persons (PersonID, LastName, FirstName, Address, City)
Values("1","venkat","M","Tirupati","Andhra Pradesh");

#create bulk table
create table bulk(id int, name varchar(30);
insert into bulk values (1,'record');
insert into bulk values (2,'record');

#insert some records and then insert bulk
insert into bulk select * from bulk; 

#same command insert multiple times 

SELECT user,authentication_string,plugin,host FROM mysql.user;

CREATE USER 'venkat'@'Public-of-vm' IDENTIFIED BY 'PASSWORD';
grant all on *.* to 'venkat'@'Public-of-vm';
flush privileges;

GRANT ALL PRIVILEGES ON *.* TO 'venkat'@'%' IDENTIFIED BY 'PASSWORD' WITH GRANT OPTION;
flush privileges;


# Try to connect to mysql instance from anywhere 
mysql -u venkat -h Public-of-vm -p

# If we get below error : 
ERROR 2003 (HY000): Can't connect to MySQL server on '34.125.93.52:3306' (111)

vi /etc/mysql/mysql.conf.d/mysqld.cnf
comment the below line
#bind-address           = 127.0.0.1

[mysqld]
log-bin=mysql-bin
server-id=1

systemctl restart mysql.service
```
