How to build :
<code>
  make image PROFILE=globalscale_espressobin-v7-emmc FILES=files/ PACKAGES="block-mount kmod-fs-ext4 fdisk" 
</code>

How to flash : 
<code>
  usb reset
  load usb 0:1 $kernel_addr_r /TEMPO/19.07.04/openwrt-19.07.4-mvebu-cortexa53-globalscale_espressobin-v7-emmc-ext4-sdcard.img.gz
  mmc dev 1 0
  gzwrite mmc 1 $kernel_addr_r $filesize
  mmc part
  boot
</code>
