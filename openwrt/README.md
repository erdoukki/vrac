How to build :
make image PROFILE=globalscale_espressobin-v7-emmc FILES=files/ PACKAGES="block-mount kmod-fs-ext4 fdisk" 

How to flash : 
usb reset
load usb 0:1 $kernel_addr_r /TEMPO/19.07.04/openwrt-19.07.4-mvebu-cortexa53-globalscale_espressobin-v7-emmc-ext4-sdcard.img.gz
mmc dev 1 0
gzwrite mmc 1 $kernel_addr_r $filesize
mmc part
boot
