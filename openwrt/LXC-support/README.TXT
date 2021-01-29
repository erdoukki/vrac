#
# https://openwrt.org/docs/guide-developer/build-system/use-buildsystem

git pull

./scripts/feeds update
./scripts/feeds install -a


# ---8<---
# 
# Compile with the same packages as the official image
# https://forum.openwrt.org/t/compiling-openwrt-exactly-like-the-official-one/23214

git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
git checkout v19.07.6
./scripts/feeds update
./scripts/feeds install -a
wget https://downloads.openwrt.org/releases/19.07.6/targets/mvebu/cortexa53/config.buildinfo -O .config
wget https://downloads.openwrt.org/releases/19.07.6/targets/mvebu/cortexa53/feeds.buildinfo -O feeds.conf
make defconfig
make menuconfig # -> No luci packages are selected here. Shouldn´t it ?
make

# ---8<---

    git checkout <branch/revision/tag> 		# when you don't want HEAD.
    make menuconfig 				# and set target.
    make defconfig 				# to set default config for build system and device.
    make kernel_menuconfig 			# (optional :!: it's highly likely that kernel modules from the repositories won't work when you make changes here).
    make menuconfig 				# and modify set of package.
    make download 				# (download all dependency source files before final make, enables multi-core compilation).
    scripts/diffconfig.sh > mydiffconfig 	# (save your changes in the text file mydiffconfig).
    make 					# start the build process.

