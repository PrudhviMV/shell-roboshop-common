#!/bin/bash

source ./common.sh

check_root

cp $PWD/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing Mongo db"

systemctl enable mongod
VALIDATE $? "Enabling Mongo db"

systemctl start mongod
VALIDATE $? "Starting Mongo db"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "adding remote connections"

systemctl restart mongod
VALIDATE $? "Restarting Mongo db"

print_total_time