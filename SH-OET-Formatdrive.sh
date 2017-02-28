#!/bin/bash

#This script creates a primary partition of maximum size formats the partition as EXT4 asks for a directory to mount the drive to and adds this to the fstab so that it is mounted at startup.
#Run this script as a sudo user

# Check whether you are root

if [ "$(whoami)" != "root" ]; then
        echo "Sorry, you are not root. Please run with sudo rights!"
        exit 1
fi

function disk {
	clear
	lsblk
	echo -n "Which disk would you like to partition and format? (ie sdb) : "
	read DISK
	echo "You entered the following info"
	echo "Disk to paration and format" $DISK
	echo -n "Are you sure? All data will be lost (y/n)"
	read yn
}

disk

while [ "$yn" != "y" ]; do
 disk
done

(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk /dev/$DISK


mke2fs -t ext4 /dev/$DISK"1"

blkid -d /dev/null
UUID=$(blkid -o value -s UUID /dev/$DISK"1")

function directory {
	DIRECTORY=/var/data
	echo -n "Where do you want to mount the disk? (ie. /var/data) :"
	echo
	read DIRECTORY
	echo "Did you enter the correct directory?("$DIRECTORY") (y/n) :" 
	read yn
}

directory

while [ "$yn" != "y" ]; do
 directory
done
	if [ ! -d "$DIRECTORY" ]; then
	echo "The directory does not exist. I'll Create it for you "
	mkdir -p -m=0660 $DIRECTORY 
	echo "Check and set your permissions"	
	fi
echo "Adding the new disk to the fstab"
echo UUID=$UUID $DIRECTORY       ext4    nofail    0    1 >> /etc/fstab
echo
echo "Mounting the disk"
echo $UUID
mount -a
df -h
