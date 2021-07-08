# WIP (work in progress)

# Content

## a service for (re)installing ipk after sysupgrade
/etc/init.d/update_refresh

## a script adding opkg backup, restore and others commands ...
/etc/profile.d/opkg.sh

## a preinit script for preparing a extroot additional partition
/lib/preinit/75_rootfs_copy

# Howto use
wget/copy them to you OpenWrt system
and add them to your backuped files in /etc/sysupgrade.conf

# Use it at your own risks !
