WARNING!!!!!!
I ASSUME YOU KNOW WHAT YOUR DOING, THESE SCRIPTS ARE HERE TO SAVE YOU TIME IF YOU DON'T KNOW WHAT THE COMMANDS IN THE SCRIPTS ARE DOING DON'T RUN ANYTHING!

USE AT OWN RISK!!!

this is a set of tools to make life easier when setting up enviroments
many scripts depend on other scripts please download links too, this holds
the links to the various dependancies

ALPHA


BETA
    -

STABLE RELEASE
    - drupal.sh
            - must be run as root
            - this intalls drupal and assumes an RDS db
            - requires access ID keys, use an IAM role
            - run as root
            - auto installs drush and these extensions:
                awssdk bootstrap sharethis jquery_update
            - FUTURE UPDATES
                - currently this script only works with MYSql, will integrate more
        
    - ebs.sh
        - This builds a filesystem for volume and mounts it
        - should be run as root

    - dev.vim
        - pretty dev colours for vim that I prefer
        - installation instructions are contained in the file
    
    - wordpress.sh
        - sets up wordpress
        - requires access ID keys, use an IAM role
        - there is a security flaw here, the authentication keys only use numbers and letters, characters cause issues that I haven't been able to fix.

future
    - script to setup a dev enviroment
    - database setup script
    - cloud formation web interface
