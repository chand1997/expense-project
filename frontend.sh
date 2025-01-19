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

if [ $(id -u) -ne 0 ]; then
    echo "Give root access"
    exit 1
fi

mkdir -p $LOG_FOLDER

echo "Script started executing at $TIME_STAMP" &>>$LOGFILE_NAME

dnf install nginx -y &>>$LOGFILE_NAME

VALIDATE $? Installing_nginx

systemctl enable nginx &>>$LOGFILE_NAME

VALIDATE $? Enabling_nginx

systemctl start nginx &>>$LOGFILE_NAME

VALIDATE $? Starting_nginx

rm -rf /usr/share/nginx/html/* &>>$LOGFILE_NAME

VALIDATE $? Removing_default_nginx_content

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE_NAME

VALIDATE $? Downloading_content_from_source

cd /usr/share/nginx/html

VALIDATE $? Changing_directory

unzip /tmp/frontend.zip &>>$LOGFILE_NAME

VALIDATE $? setting_content

cp /home/ec2-user/expense-project/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE_NAME

VALIDATE $? Copying_configuration_file

systemctl restart nginx

VALIDATE $? Restarting_nginx
