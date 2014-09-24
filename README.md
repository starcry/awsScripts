this is a set of tools to make life easier when setting up enviroments
many scripts depend on other scripts please download links too, this holds
the links to the various dependancies

ALPHA
    drupal_localDB.sh
        this installs drupal with a local DB
        run as root

BETA
    drupal_remoteDB.sh
        this intalls drupal and assumes an RDS db
        requires access ID keys, use an IAM role
        run as root

STABLE RELEASE
    ebs.sh
        This builds a filesystem for volume and mounts it
        should be run as root
        lines below need to be fixed and then will be ready for stable release
         52 chmod 777 sites/default/files/
         53 cp sites/default/default.settings.php sites/default/settings.php
         54 chmod 777 sites/default/settings.php 


    dev.vim
        pretty dev colours for vim that I prefer
        installation instructions are contained in the file

future
    script to setup a dev enviroment
    wordpress script
    cloud formation web interface
