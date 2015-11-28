#!/bin/bash

#doesn't work, drupal doesn't use pair, updating
#require:
#composer: http://codybonney.com/installing-composer-globally-on-centos-6-4/
#drush: http://docs.drush.org/en/master/install-alternative/
#with the recent updates to drupal, drush and the amazon AMI this script is out of date and no longer works.
#currently rewriting
#currently everything is installing bar drush, that needs to be run separatly, I'm investigating why
#drupal installation also has some issues, will sort this out later.

yum update -y
yum upgrade -y

yum -y install php55
read

yum -y install mysql
read

yum -y install php55-cli php55-gd php55-intl php55-mbstring php55-mysqlnd php55-pdo php55-xml php55-xmlrpc 

read

chkconfig httpd on
#not sure if this line is required
chkconfig mysqld on
service httpd start
service mysqld start 
#these next 2 lines might need to go
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.old
sed 's_<Directory \"/var/www/html\">\(.*\)</Directory>_\1_' temp2 | sed -i 's_AllowOverride None_AllowOverride All_g' /etc/httpd/conf/httpd.conf
service httpd restart 

echo "you are now going to configure your database and possibly your AWS command line tools, depending on what you choose. Please have your access keys and secret access keys to hand. It is recomended that this be an IAM access key, this will make your life easier in the event of a compromise.

press the enter key to continue"
read

bash databaseSetup.sh 

bash ebs.sh

chown ec2-user /var/www/html/

cd /var/www/html/

wget http://files.drush.org/drush.phar -P /home/ec2-user/
php /home/ec2-user/drush.phar core-status
chmod +x /home/ec2-user/drush.phar
mv /home/ec2-user/drush.phar /usr/local/bin/drush

su ec2-user -c "

drush init

(cd /var/www/html; drush dl)
chown -R ec2-user:ec2-user /var/www/html/drupal-8.*/

mv /var/www/html/drupal-8.*/* /var/www/html/
mv /var/www/html/drupal-8.*/.* /var/www/html/
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
