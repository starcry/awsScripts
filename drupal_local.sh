#!/bin/bash

#THIS IS NOT SUITABLE FOR A PROD ENVIROMENT

yum update -y
yum upgrade -y

yum -y install httpd mysql php php-cli php-gd php-intl php-mbstring php-mysql php-pdo php-pear php-xml php-xmlrpc mysql-server php-mcrypt php-devel php-pecl-apc gcc
chkconfig httpd on
chkconfig mysqld on
service httpd start
service mysqld start 
mysqladmin -u root password 'Pa55word'
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.old
sed 's_<Directory \"/var/www/html\">\(.*\)</Directory>_\1_' temp2 | sed -i 's_AllowOverride None_AllowOverride All_g' /etc/httpd/conf/httpd.conf
service httpd restart 

echo "you are now going to configure your database and possibly your AWS command line tools, depending on what you choose. Please have your access keys and secret access keys to hand. It is reccomended that this be an IAM access key, this will make your life easier in the event of a compromise.

press any key to continue"
read

read -p "please enter the name of the database you wish to create: " tableName

mysql -f -h localhost -P 3306 -u root -p << EOF
    DROP DATABASE $tableName;
    CREATE DATABASE $tableName;
    DELETE FROM mysql.user WHERE user = ''; 
    GRANT usage ON *.* TO $tableName@localhost IDENTIFIED BY 'Pa55w0rd';
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, CREATE TEMPORARY TABLES ON $tableName.* TO $tableName@localhost IDENTIFIED BY 'Pa55w0rd';
    FLUSH PRIVILEGES; 
EOF

echo "this is a standard error check"
echo "we have just connected to the database,"
echo "dropped and recreated the database you mentioned"
echo "if you don't see any errors then press the enter key to continue"
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
chmod 777 /var/www/html/sites/default/files
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

