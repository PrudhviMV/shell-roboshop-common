#!/bin/bash

source ./common.sh

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysql server"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting up mysql server password"

print_total_time