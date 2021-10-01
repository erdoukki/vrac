How to build :
```
make image PROFILE=globalscale_espressobin-v7-emmc FILES=files/ PACKAGES="block-mount kmod-fs-ext4 kmod-fs-f2fs f2fstools fdisk mount-utils partx-utils luci-ssl" 
```
!!! ADVICE !!!

Depending of the version f the U-Boot and the commands available, and also on possible bugs in this method, preffer a stardard way to flash your firmware !

The method below is given **as is**, they may broke your system and put it in a necessary recovery mode !

**USE IT AT YOUR OWN RISK**

How to flash EBIN eMMC from u-boot (with gzwrite) : 
```
usb reset
load usb 0:1 $kernel_addr_r /TEMPO/19.07.04/openwrt-19.07.5-mvebu-cortexa53-globalscale_espressobin-v7-emmc-ext4-sdcard.img.gz
mmc dev 1 0
gzwrite mmc 1 $kernel_addr_r $filesize
mmc part
boot
```

How to flash EBIN-ULTRA eMMC from u-boot (without gzwrite) : 
```
usb reset
load usb 0:1 $kernel_addr_r /TEMPO/21.02.0/openwrt-21.02.0-mvebu-cortexa53-globalscale_espressobin-ultra-ext4-sdcard.img
mmc dev 0
mmc part
mmc write $kernel_addr_r 0 $filesize
mmc rescan
mmc part
reset
```

How to boot (EBIN) :
```
setenv bootowrt 'mmc dev 1; ext4load mmc 1:1 $kernel_addr_r $image_name; ext4load mmc 1:1 $fdt_addr_r $fdt_name; setenv bootargs $console root=/dev/mmcblk0p2 rw rootwait net.ifnames=0 biosdevname=0  $extra_params usb-storage.quirks=$usbstoragequirks; booti $kernel_addr_r - $fdt_addr_r'
setenv bootcmd 'run bootowrt'
setenv fdt_name 'armada-3720-espressobin-v7-emmc.dtb'
setenv image_name 'Image'
saveenv
reset
```

How to boot (EBIN-ULTRA) :
```
setenv bootowrt 'mmc dev 0; ext4load mmc 0:1 $kernel_addr_r $image_name; ext4load mmc 0:1 $fdt_addr_r $fdt_name; setenv bootargs $console root=/dev/mmcblk0p2 rw rootwait net.ifnames=0 biosdevname=0  $extra_params usb-storage.quirks=$usbstoragequirks; booti $kernel_addr_r - $fdt_addr_r'
setenv bootcmd 'run bootowrt'
setenv fdt_name 'armada-3720-espressobin-ultra.dtb'
setenv image_name 'Image'
saveenv
reset
```

How prepare extroot/overlay (WIP) :
```
mkdir -p /etc/profile.d/
wget https://raw.githubusercontent.com/erdoukki/vrac/master/openwrt/files/etc/profile.d/extras.sh -O /etc/profile.d/extras.sh
. /etc/profile.d/extras.sh
opkg save
```

How upgrade to next release :
-> luci (keep settings, force upgrade) openwrt-21.02.0-mvebu-cortexa53-globalscale_espressobin-(v7-emmc/ultra)-ext4-sdcard.img.gz
The autopgrade will reset your overlay extroot and automatically re-install the available packages...

KNOWN ISSUE :

#1. If you install user packages from unofficial downloads feeds, you will have to reinstall them manually after an upgrade ! 

#2. If the firmware is not correctly reconized, and propose only to make a FORCE UPGRADE;
bug report : https://bugs.openwrt.org/index.php?do=details&task_id=3304
just modify the bootargs as follow :
```
root@LGM:~# fw_setenv set_bootargs 'setenv bootargs $console $root $extra_params'
```
REBOOT and try again to upgrade !
