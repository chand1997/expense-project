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

echo "Checking whether mysql-server is already installed"

dnf list installed mysql-server | grep -q "mysql-server"

if [ $? -eq 0 ]; then
    echo -e " $Y Mysql-server already INSTALLED $N "
    exit 1
fi

echo "Mysql-server installing" &>>$LOGFILE_NAME

dnf install mysql-server -y &>>$LOGFILE_NAME

VALIDATE $? Mysql_Installation

echo "Starting mysql-server" &>>$LOGFILE_NAME

systemctl start mysqld &>>$LOGFILE_NAME

VALIDATE $? Starting_Mysql

echo "Enabling Mysql-server" &>>$LOGFILE_NAME

systemctl enable mysqld &>>$LOGFILE_NAME

VALIDATE $? Enabling_Mysql

mysql -h 98.81.200.199  -uroot -pExpenseApp@1 -e 'show databases;'

if [ $? -eq 0 ]
then
echo "Password already set up"
exit 1
fi

mysql_secure_installation --set-root-pass ExpenseApp@1

VALIDATE $? Setting_Root_Password
