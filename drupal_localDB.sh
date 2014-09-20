#!/bin/bash

yum update -y
yum upgrade -y

yum -y install httpd mysql mysql-server php php-cli php-gd php-intl php-mbstring php-mysql php-pdo php-pear php-xml php-xmlrpc 
chkconfig httpd on
chkconfig mysqld on
service httpd start
service mysqld start 
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.old
vim /etc/httpd/conf/httpd.conf
service httpd restart 
mysqladmin -u root password 'PASSWORD' 
mysql -u root -p

pear upgrade
pear channel-discover pear.drush.org
pear install drush/drush 

bash ebs.sh

chown ec2-user /var/www/html/

su ec2-user
cd /var/www/html/
drush dl
mv drupal-7.*/* ./
mv drupal-7.*/.* ./

mkdir sites/default/files
chmod 777 sites/default/files/
cp sites/default/default.settings.php sites/default/settings.php
chmod 777 sites/default/settings.php 

echo "go to servers domain and install drupal"
read

for i in awssdk bootstrap sharethis jquery_update 
do
    drush dl $i
    drush en $i
done
