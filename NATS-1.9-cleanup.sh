#!/bin/bash
#
# Cleaning up the variables used for NATS install and config scripts
#

sudo cp /etc/fstab /etc/original.fstab
echo "==> You need to update fstab"
echo
echo "run: sudo blkid /dev/sdb"
echo 
echo "copy the UUID name/value pair" 
echo
echo "run: sudo vim /etc/fstab"
echo "add the following to the bottom of the file:"
echo "{UUID name/value pair} $NATS_HOME ext4 discard,defaults 0 2"
echo
echo "run: cat /etc/fstab"
echo "verify that {UUID name/value pair} $NATS_HOME ext4 discard,defaults 0 2 is at the bottom of the file."
echo
echo "==> You must run: sudo shutdown -r now"
echo " This will load the changes made."
echo
