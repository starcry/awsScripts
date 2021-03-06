#!/bin/bash

mysqlSetup() {

    mysql -f -h $DNS -P 3306 -u $username -p << EOF
    SHOW DATABASES;
EOF

    read -p "please enter the name of the database you wish to create: " tableName

    mysql -f -h $DNS -P 3306 -u $username -p << EOF
    DROP DATABASE $tableName;
EOF

    mysql -f -h $DNS -P 3306 -u $username -p << EOF
    CREATE DATABASE $tableName;
    DELETE FROM mysql.user WHERE user = ''; 
    FLUSH PRIVILEGES; 
EOF

    echo "this is a standard error check"
    echo "we have just connected to the database,"
    echo "dropped and recreated the database you mentioned"
    echo "if you don't see any errors then press the enter key to continue"
    read -p "otherwise exit this script and troubleshoot"
}

postgres() {
    echo "no actions required for postgres"
}

choosedb() {
    echo "you are now going to configure your AWS tools, please have your access keys and secret access keys to hand. It is reccomended that this be an IAM access key, this will make your life easier in the event of a compromise."

    aws configure


    aws rds describe-db-instances | egrep "DBInstanceIdentifier|Address|MasterUsername" | sed 's/"//g'
    echo "above you see the various databases in the default region, please select which RDS database Identifier you would like to use according to the main database name. You will get a chance to change this later if you like."
    read DBName

    DNS=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "Address" | sed 's/.*|  //;s/ .*//')
    username=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "MasterUsername" | sed 's/.*|  //;s/ .*//')
}


echo "mysql (1)"
echo "postgres (2)"
read -p "please enter the number of the database you wish to use: " choice 

case "$choice" in
    1)
        choosedb
        mysqlSetup
        ;;

    2)
        postgres
        ;;
    *)
        echo "else"
        ;;
esac
