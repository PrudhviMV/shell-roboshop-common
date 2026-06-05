#!/bin/bash

source ./common.sh
app_name=redis

check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "changing protected-mode to no and allowing local connections"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

print_total_time