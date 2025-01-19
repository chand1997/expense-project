#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/expense_project_logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIME_STAMP.log"

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2  $R FAILED $N "
        exit 1
    else
        echo -e "$2 $G SUCCESS $N "
    fi

}
echo "Script started executing at $TIME_STAMP" &>>$LOGFILE_NAME
if [ $(id -u) -ne 0 ]; then
    echo "Give root access"
    exit 1
fi

dnf module disable nodejs -y &>>$LOGFILE_NAME

VALIDATE $? Disabling_default_version_Of_nodejs

dnf module enable nodejs:20 -y &>>$LOGFILE_NAME

VALIDATE $? Enabling_required_version_Of_nodejs

dnf install nodejs -y &>>$LOGFILE_NAME

VALIDATE $? Installing_nodejs

id expense | grep -q "expense"

if [ $? -eq 0]
then
echo "User already exists"
else
useradd expense &>>$LOGFILE_NAME 
VALIDATE $? Adding_user
fi



mkdir -p /app &>>$LOGFILE_NAME

VALIDATE $? Creating_directory_App

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE_NAME

VALIDATE $? Copying_code_from_source

cd /app

VALIDATE $? Changing_directory_to_app

unzip /tmp/backend.zip

cd /app

npm install &>>$LOGFILE_NAME

VALIDATE $? Installing_dependencies

cp -p /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service

VALIDATE $? Creating_backend_service

systemctl daemon-reload &>>$LOGFILE_NAME

VALIDATE $? Reloading_Daemon

systemctl start backend &>>$LOGFILE_NAME

VALIDATE $? Starting_backend_service

systemctl enable backend &>>$LOGFILE_NAME

VALIDATE $? Enabling_backend_service

dnf install mysql -y &>>$LOGFILE_NAME

VALIDATE $? Installing_Mysql_client

mysql -h 98.81.200.199 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE_NAME

VALIDATE $? Loading_Schema

systemctl restart backend &>>$LOGFILE_NAME

VALIDATE $? Restarting_backend




















