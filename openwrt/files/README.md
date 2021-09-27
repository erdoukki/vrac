# WIP (work in progress)

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

# Use it at your own risks !
