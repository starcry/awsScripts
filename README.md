WARNING!!!!!!
I ASSUME YOU KNOW WHAT YOUR DOING, THESE SCRIPTS ARE HERE TO SAVE YOU TIME IF YOU DON'T KNOW WHAT THE COMMANDS IN THE SCRIPTS ARE DOING DON'T RUN ANYTHING!

USE AT OWN RISK!!!

this is a set of tools to make life easier when setting up enviroments
many scripts depend on other scripts please download links too, this holds
the links to the various dependancies

ALPHA
    - drupal_localDB.sh
        - this installs drupal with a local DB
        - run as root
        - this will be deprecated shortly as it goes agains the aims of this project

BETA
    -

STABLE RELEASE
    - drupal_remoteDB.sh
            - this intalls drupal and assumes an RDS db
            - requires access ID keys, use an IAM role
            - run as root
            - UPDATES
                - currently this drops and then creats the main RDS DB, this is needs to be fixed. I would like this script to be able to setup drupal and auto integrate a prebuilt drupal DB
        
    - ebs.sh
        - This builds a filesystem for volume and mounts it
        - should be run as root

    - dev.vim
        - pretty dev colours for vim that I prefer
        - installation instructions are contained in the file

future
    - script to setup a dev enviroment
    - wordpress script
    - cloud formation web interface
