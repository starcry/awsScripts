#!/bin/bash

#SECURITY FLAW!!!
#currently this script only uses numbers and letters to set the for the authentication keys

yum update -y
yum upgrade -y

yum groupinstall -y "Web Server" "PHP Support"
yum install -y php-mysql mysql

service httpd start

groupadd www
usermod -a -G www ec2-user

chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} +
find /var/www -type f -exec sudo chmod 0664 {} +

echo "you are now going to configure your AWS tools, please have your access keys and secret access keys to hand. It is reccomended that this be an IAM access key, this will make your life easier in the event of a compromise.

press the enter key to continue"
read

aws configure

aws rds describe-db-instances | egrep "DBInstanceIdentifier|Address|MasterUsername" | sed 's/"//g'
echo "above you see the various databases in the default region, please select which RDS database you would like to use accourding to the main database name. You will get a change to change this later if you like."
read DBName

DNS=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "Address" | sed 's/.*|  //;s/ .*//')
username=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "MasterUsername" | sed 's/.*|  //;s/ .*//')
mysql -f -h $DNS -P 3306 -u $username -p << EOF
SHOW DATABASES;
EOF

read -p "please enter the name of the database you wish to create: " tableName

mysql -f -h $DNS -P 3306 -u $username -p << EOF
DROP DATABASE $tableName;
CREATE DATABASE $tableName;
DELETE FROM mysql.user WHERE user = ''; 
FLUSH PRIVILEGES; 
EOF

echo "this is a standard error check"
echo "we have just connected to the database,"
echo "dropped and recreated the database you mentioned"
echo "if you don't see any errors then press the enter key to continue"
read -p "otherwise exit this script and troubleshoot"

bash ebs.sh

chown -R ec2-user:www /var/www

su ec2-user -c "
wget -P /var/www/html/ http://wordpress.org/latest.tar.gz

tar -xzf /var/www/html/latest.tar.gz -C /var/www/html
mv /var/www/html/wordpress/* /var/www/html/

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
"

randCount=$(grep -c "put your unique phrase here" /var/www/html/wp-config.php)

for ((i=1; i<=$randCount; i++))
do 
    temp=$(</dev/urandom tr -dc '1234567890qwertyuiopQWERTYUIOPasdfghjklASDFGHJKLzxcvbnmZXCVBNM' | head -c65; echo "")
    sed -i '0,/put your unique phrase here/{s/put your unique phrase here/'"$temp"'/}' /var/www/html/wp-config.php
done

sed -i 's/database_name_here/'"$tableName"'/' /var/www/html/wp-config.php
sed -i 's/username_here/'"$username"'/' /var/www/html/wp-config.php
read -s -p "please re-enter the password you used to connect to this database, this will be stored in your wp-config.php file: " dbpw
sed -i 's/password_here/'"$dbpw"'/' /var/www/html/wp-config.php
sed -i 's/localhost/'"$DNS"'/' /var/www/html/wp-config.php

service httpd restart
chkconfig httpd on

echo "wordpress has now been installed, you will need to go to the servers domain through the web interface to compleate the installation. As a final word the web plugin installation can be a little wonky if you figgure it out let me know, otherwise just download and extract to the plugin directory"

echo "SECURITY FLAW!!!"
echo "currently this script only uses numbers and letters to set the for the authentication keys"
