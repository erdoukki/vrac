How to build :
```
make image PROFILE=globalscale_espressobin-v7-emmc FILES=files/ PACKAGES="block-mount kmod-fs-ext4 fdisk mount-utils partx-utils luci-ssl" 
```
How prepare SysUpgrade :
```
mkdir -p /etc/profile.d/
wget https://raw.githubusercontent.com/erdoukki/vrac/master/openwrt/files/etc/profile.d/opkg.sh -O /etc/profile.d/opkg.sh
. /etc/profile
opkg_backup
```
then -> luci (keep settings, force upgrade) openwrt-19.07.5-mvebu-cortexa53-globalscale_espressobin-v7-emmc-ext4-sdcard.img.gz

How to flash eMMC from u-boot : 
```
usb reset
load usb 0:1 $kernel_addr_r /TEMPO/19.07.04/openwrt-19.07.5-mvebu-cortexa53-globalscale_espressobin-v7-emmc-ext4-sdcard.img.gz
mmc dev 1 0
gzwrite mmc 1 $kernel_addr_r $filesize
mmc part
boot
```
How to boot : 
```
bootcmd=mmc dev 1; ext4load mmc 1:1 $kernel_addr $image_name; ext4load mmc 1:1 $fdt_addr $fdt_name; setenv bootargs $console root=/dev/mmcblk0p2 rw rootwait net.ifnames=0 biosdevname=0; booti $kernel_addr - $fdt_addr
console=console=ttyMV0,115200 earlycon=ar3700_uart,0xd0012000
fdt_addr=0x6f00000
fdt_name=armada-3720-espressobin-v7-emmc.dtb
image_name=Image
kernel_addr=0x7000000
```
KNOWN ISSUE :
If the firmware is not correctly reconized, and propose only to make a FORCE UPGRADE;
just modify the bootargs as follow :
```
root@LGM:~# fw_setenv set_bootargs 'setenv bootargs $console $root $extra_params'
```
REBOOT and try again to upgrade !
