#!/bin/bash

yum update -y
yum upgrade -y

yum -y install httpd mysql php php-cli php-gd php-intl php-mbstring php-mysql php-pdo php-pear php-xml php-xmlrpc 
chkconfig httpd on
chkconfig mysqld on
service httpd start
service mysqld start 
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.old
sed 's_<Directory \"/var/www/html\">\(.*\)</Directory>_\1_' temp2 | sed -i 's_AllowOverride None_AllowOverride All_g' /etc/httpd/conf/httpd.conf
service httpd restart 

echo "you are now going to configure your AWS tools, please have your access keys and secret access keys to hand. It is reccomended that this be an IAM access key, this will make your life easier in the event of a compromise.

press any key to continue"
read

aws configure

aws rds describe-db-instances | egrep "DBInstanceIdentifier|Address|MasterUsername" | sed 's/"//g'
echo "above you see the various databases in the default region, please select which RDS database you would like to use accourding to the main database name. You will get a change to change this later if you like."
read DBName

read -p "please enter the name of the database you wish to create" tableName
#echo "thank you, you have selected the " $DBName " would you like to use a different database? (y/n)"
#read diffName

#if [ $diffName = "y" ]
#then
#    echo "please enter the name of the database you would like to create:"
#    read DBName
#fi

echo "DBName is $DBName"
DNS=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "Address" | sed 's/.*|  //;s/ .*//')
echo "DNS is $DNS"
username=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "MasterUsername" | sed 's/.*|  //;s/ .*//')
echo "username is $username"

mysql -h $DNS -P 3306 -u $username -p << EOF
DROP DATABASE $tableName;
CREATE DATABASE $tableName;
DELETE FROM mysql.user WHERE user = ''; 
FLUSH PRIVILEGES; 
EOF

echo "this is a standard error check"
echo "we have just connected to the database,"
echo "dropped and recreated the database you mentioned"
echo "if you don't see any errors then press any key to continue"
read -p "otherwise exit this script and troubleshoot"

pear update-channels
pear upgrade
pear channel-discover pear.drush.org
pear install drush/drush 

bash ebs.sh

chown ec2-user /var/www/html/

cd /var/www/html/
drush dl
chown -R ec2-user:ec2-user drupal-7*/
su ec2-user -c "
mv drupal-7.*/* ./
mv drupal-7.*/.* ./

mkdir /var/www/html/sites/default/files
chmod 666 /var/www/html/sites/default/files
cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php
chmod 666 /var/www/html/sites/default/settings.php

echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo go to servers domain and install drupal
echo please note that at this time this
echo only works with MYSql.
echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
read

chmod 444 /var/www/html/sites/default/settings.php

cd /var/www/html/
drush dl awssdk bootstrap sharethis jquery_update
drush en -y awssdk bootstrap sharethis jquery_update
"
