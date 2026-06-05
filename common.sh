#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
Mongo_host=mongodb.prudhvii.fun
MYSQL_HOST=mysql.prudhvii.fun

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "ERROR:: Please run this script with root privelege"
        exit 1 # failure is other than 0
    fi
}


nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling Nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling Nodejs"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing Nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Install NPM"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing Python"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing maven"

    mvn clean package &>>$LOG_FILE
    VALIDATE $? "compiling and cleaning package"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "moving package"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Roboshop user added"
    else
        echo "User is already present"
    fi

    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "Creating Directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Fetching Code to server"

    cd /app &>>$LOG_FILE
    VALIDATE $? "traversing into app directory"

    rm -rf /app/* &>>$LOG_FILE
    VALIDATE $? "Removing old code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzip code"
}

service_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "Adding $app_name repo"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Daemon reload"

    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"

    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "Start $app_name"
}

service_restart(){
    systemctl restart $app_name &>>$LOG_FILE
    VALIDATE $? "Restarted $app_name"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}