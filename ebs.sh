#!/bin/bash

#lists all unmounted volumes
volumes=""
for vol in `lsblk|grep -v NAME | awk '{ print $1 }'`
do 
    vol=`echo $vol | sed 's/└─//g'`
    if [[ $(mount | grep -c  $vol) = 0 ]]
    then
        volumes=$volumes" "$vol
    fi
done

#if there are any volumes, this will display them and ask if the user wants to mount any
if [[ $(echo $volumes | wc -m) > 1 ]] 
then
    lsblk | grep NAME
    for i in $volumes
    do
        lsblk | grep $i
    done
    read -p "would you like to mount these now? (y/n) " volmount
fi



fileBuild=y

if [[ $volmount = "y" ]]
then
    for ((i=1; i<=$(echo $volumes | wc -w); i++)); do
        read -p "enter block device: " BLOCK
        read -p "enter location to mount directory: " MOUNT

        #checks to see if volumes are in fstab, if they are it asks the user if they want to remove them
        #FUTURE: will show volumes and compare them with what user has specified and ask if user wants to replace them
        #FUTURE: will check to see if mount points are taken and will ask if user wants to remove/replace them
        entry=$(grep $MOUNT /etc/fstab)
        if [[ $(echo $entry | wc -m) > 1 ]]
        then
            read -p "There is an fstab entry for $MOUNT, do you want to delete it and re-enter it? (y/n): " fileBuild
        fi

        #backs up fstab
        cp /etc/fstab /etc/fstab.orig
        #if user wants to replace fstab values, this is done here
        if [[ $fileBuild = "y" ]]
        then
            echo $volumes | xargs -n1 -I {} sed -i '/.*'"{}"'.*/d' /etc/fstab
            read -p "rebuilding file system, this will wipe all data on drive, press the enter key to contine (if you can't find the any key I suggest purchasing a mac)"
            mkfs -t ext4 /dev/$BLOCK
            fstabEntry="/dev/$BLOCK $MOUNT ext4 defaults,noatime 0 2"
            echo $fstabEntry >> /etc/fstab
        fi

        echo $BLOCK
        file -s /dev/$BLOCK
        mount /dev/$BLOCK $MOUNT 
        mount -a
    done
fi
