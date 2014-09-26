#!/bin/bash

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

press any key to continue"
read

aws configure

aws rds describe-db-instances | egrep "DBName|Address|MasterUsername" | sed 's/"//g'
echo "please enter the database name you wish to use"
read DBName

DNS=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "Address" | sed 's/.*|  //;s/ .*//')
username=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "MasterUsername" | sed 's/.*|  //;s/ .*//')

read -s -p "enter database password: " dbpw

mysql -h $DNS -P 3306 -u $username -p$dbpw << EOF
DROP DATABASE $DBName;
CREATE DATABASE $DBName;
DELETE FROM mysql.user WHERE user = ''; 
FLUSH PRIVILEGES; 
EOF

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

sed -i 's/database_name_here/'"$DBName"'/' /var/www/html/wp-config.php
sed -i 's/username_here/'"$username"'/' /var/www/html/wp-config.php
sed -i 's/password_here/'"$dbpw"'/' /var/www/html/wp-config.php
sed -i 's/localhost/'"$DNS"'/' /var/www/html/wp-config.php

service httpd restart
chkconfig httpd on

echo "wordpress has now been installed, you will need to go to the servers domain through the web interface to compleate the installation. As a final word the web plugin installation can be a little wonky if you figgure it out let me know, otherwise just download and extract to the plugin directory"
