#!/bin/bash -vx
#
# Cleaning up the variables used for NATS install and config scripts
#

OG_FSTAB=""/etc/original.fstab""
if [ -f "$OG_FSTAB" ]; then
	echo "$OG_FSTAB exist, so you don't need to add mount point."
else
	sudo cp /etc/fstab /etc/original.fstab
	echo "==> You need to update fstab"
	echo
	echo "run: sudo blkid /dev/sdb"
	echo 
	echo "copy the UUID name/value pair" 
	echo
	echo "run: sudo vim /etc/fstab"
	echo "add the following to the bottom of the file:"
	echo "{UUID name/value pair} $MY_NATS_HOME ext4 discard,defaults 0 2"
	echo
	echo "run: cat /etc/fstab"
	echo "verify that {UUID name/value pair} $MY_NATS_HOME ext4 discard,defaults 0 2 is at the bottom of the file."
	echo
	echo "==> You must run: sudo shutdown -r now"
	echo " This will load the changes made."
	echo
fi