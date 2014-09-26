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

aws rds describe-db-instances | egrep "DBName|Address|MasterUsername" | sed 's/"//g'
echo "above you see the various databases in the default region, please select which RDS database you would like to use accourding to the main database name. You will get a change to change this later if you like."
read DBName
echo "thank you, you have selected the " $DBName " would you like to use a different database? (t/n)"
read diffName

if [ $diffName = "y" ]
then
    echo "please enter the name of the database you would like to create:"
    read DBName
fi

DNS=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "Address" | sed 's/.*|  //;s/ .*//')
username=$(aws rds describe-db-instances --db-instance-identifier $DBName | egrep "MasterUsername" | sed 's/.*|  //;s/ .*//')

read -s -p "enter database password: " dbpw

mysql -h $DNS -P 3306 -u $username -p$dbpw << EOF
DROP DATABASE $DBName;
CREATE DATABASE $DBName;
DELETE FROM mysql.user WHERE user = ''; 
FLUSH PRIVILEGES; 
EOF

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

mkdir sites/default/files
chmod 777 sites/default/files/
cp sites/default/default.settings.php sites/default/settings.php
chmod 777 sites/default/settings.php 

echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo go to servers domain and install drupal
echo please note that at this time this
echo only works with MYSql.
echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
read

cd /var/www/html/
drush dl awssdk bootstrap sharethis jquery_update
drush en -y awssdk bootstrap sharethis jquery_update
"

chmod 444 sites/default/settings.php
chmod -R 444 sites/default/files/
