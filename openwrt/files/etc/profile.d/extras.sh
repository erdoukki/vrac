## 202109271025
## Start of all extras
mkdir -p /etc/profile.d
cat << "EOAF" > /etc/profile.d/extras.sh
## opkg-extras
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/opkg.sh
opkg() {
local OPKG_CMD="${1}"
local OPKG_UCI="$(uci -q get opkg.defaults."${OPKG_CMD}")"
case "${OPKG_CMD}" in
(init|uci|import|save|restore|rollback\
|upgr|export|newconf|proc|reinstall) opkg_"${@}" ;;
(*) command opkg "${@}" ;;
esac
}

opkg_init() {
uci import opkg < /dev/null
uci -q batch << EOI
set opkg.defaults=opkg
set opkg.defaults.import=/etc/backup/installed_packages.txt
set opkg.defaults.save=auto
set opkg.defaults.restore=auto
set opkg.defaults.rollback=auto
set opkg.defaults.upgr=ai
set opkg.defaults.export=ai
set opkg.defaults.proc=--force-depends
set opkg.defaults.reinstall=--force-reinstall
set opkg.defaults.newconf=/etc
EOI
}

opkg_uci() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
local OPKG_OPT="${OPKG_OPT:-auto}"
if ! uci -q get opkg > /dev/null
then opkg init
fi
uci -q batch << EOI
delete opkg.${OPKG_OPT}
set opkg.${OPKG_OPT}=opkg
$(sed -r -e "s/^(.*)\s(.*)$/\
del_list opkg.${OPKG_OPT}.\2=\1\n\
add_list opkg.${OPKG_OPT}.\2=\1/")
commit opkg
EOI
}

opkg_import() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
if [ -e "${OPKG_OPT}" ]
then sed -n -r -e "s/\s(overlay|unknown)$/\
\tipkg/p" "${OPKG_OPT}" \
| opkg uci auto
fi
}

opkg_save() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
local OPKG_WR="$(opkg export wr)"
local OPKG_WI="$(opkg export wi)"
local OPKG_UR="$(opkg export ur)"
local OPKG_UI="$(opkg export ui)"
if uci -q get fstab.rwm > /dev/null \
&& grep -q -e "\s/rwm\s" /etc/mtab
then {
sed -e "s/$/\trpkg/" "${OPKG_WR}"
sed -e "s/$/\tipkg/" "${OPKG_WI}"
} | opkg uci rwm
fi
{
sed -e "s/$/\trpkg/" "${OPKG_UR}"
sed -e "s/$/\tipkg/" "${OPKG_UI}"
} | opkg uci "${OPKG_OPT}"
rm -f "${OPKG_WR}" "${OPKG_WI}" "${OPKG_UR}" "${OPKG_UI}"
}

opkg_restore() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
local OPKG_CFG="${OPKG_OPT}"
local OPKG_AI="$(opkg export ai)"
local OPKG_PR="$(opkg export pr)"
local OPKG_PI="$(opkg export pi)"
grep -x -f "${OPKG_AI}" "${OPKG_PR}" \
| opkg proc remove
grep -v -x -f "${OPKG_AI}" "${OPKG_PI}" \
| opkg proc install
rm -f "${OPKG_AI}" "${OPKG_PR}" "${OPKG_PI}"
}

opkg_rollback() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
local OPKG_CFG="${OPKG_OPT}"
local OPKG_UR="$(opkg export ur)"
local OPKG_UI="$(opkg export ui)"
local OPKG_PR="$(opkg export pr)"
local OPKG_PI="$(opkg export pi)"
if uci -q get opkg."${OPKG_CFG}" > /dev/null
then opkg restore "${OPKG_CFG}"
grep -v -x -f "${OPKG_PI}" "${OPKG_UI}" \
| opkg proc remove
grep -v -x -f "${OPKG_PR}" "${OPKG_UR}" \
| opkg proc install
fi
rm -f "${OPKG_UR}" "${OPKG_UI}" "${OPKG_PR}" "${OPKG_PI}"
}

opkg_upgr() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
case "${OPKG_OPT}" in
(ai|oi) opkg_"${OPKG_CMD}"_type ;;
esac | opkg proc upgrade
}

opkg_upgr_type() {
local OPKG_AI="$(opkg export ai)"
local OPKG_OI="$(opkg export oi)"
local OPKG_AU="$(opkg export au)"
case "${OPKG_OPT::1}" in
(a) grep -x -f "${OPKG_AI}" "${OPKG_AU}" ;;
(o) grep -x -f "${OPKG_OI}" "${OPKG_AU}" ;;
esac
rm -f "${OPKG_AI}" "${OPKG_OI}" "${OPKG_AU}"
}

opkg_export() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
local OPKG_EXP="$(mktemp -t opkg.XXXXXX)"
case "${OPKG_OPT}" in
(ai|au) opkg_"${OPKG_CMD}"_cmd ;;
(ri|wr|wi|or|oi) opkg_"${OPKG_CMD}"_type ;;
(ur|ui) opkg_"${OPKG_CMD}"_run ;;
(pr|pi) opkg_"${OPKG_CMD}"_uci ;;
esac > "${OPKG_EXP}"
echo "${OPKG_EXP}"
}

opkg_export_cmd() {
local OPKG_TYPE
case "${OPKG_OPT:1}" in
(i) OPKG_TYPE="installed" ;;
(u) OPKG_TYPE="upgradable" ;;
esac
opkg list-"${OPKG_TYPE}" \
| sed -e "s/\s.*$//"
}

opkg_export_type() {
local OPKG_INFO="/usr/lib/opkg/info"
local OPKG_TYPE
case "${OPKG_OPT::1}" in
(r) OPKG_INFO="/rom${OPKG_INFO}" ;;
(w) OPKG_INFO="/rwm/upper${OPKG_INFO}" ;;
(o) OPKG_INFO="/overlay/upper${OPKG_INFO}" ;;
esac
case "${OPKG_OPT:1}" in
(r) OPKG_TYPE="c" ;;
(i) OPKG_TYPE="f" ;;
esac
find "${OPKG_INFO}" -name "*.control" \
-type "${OPKG_TYPE}" 2> /dev/null \
| sed -e "s/^.*\///;s/\.control$//"
}

opkg_export_run() {
local OPKG_AI="$(opkg export ai)"
local OPKG_RI="$(opkg export ri)"
case "${OPKG_OPT:1}" in
(r) grep -v -x -f "${OPKG_AI}" "${OPKG_RI}" ;;
(i) grep -v -x -f "${OPKG_RI}" "${OPKG_AI}" ;;
esac
rm -f "${OPKG_AI}" "${OPKG_RI}"
}

opkg_export_uci() {
local OPKG_TYPE
case "${OPKG_OPT:1}" in
(r) OPKG_TYPE="rpkg" ;;
(i) OPKG_TYPE="ipkg" ;;
esac
uci -q get opkg."${OPKG_CFG}"."${OPKG_TYPE}" \
| sed -e "s/\s/\n/g"
}

opkg_proc() {
local OPKG_OPT="${OPKG_UCI}"
local OPKG_CMD="${1:?}"
local OPKG_PKG
while read -r OPKG_PKG
do opkg "${OPKG_CMD}" "${OPKG_PKG}" ${OPKG_OPT}
done
}

opkg_reinstall() {
local OPKG_OPT="${OPKG_UCI}"
opkg install "${@}" ${OPKG_OPT}
}

opkg_newconf() {
local OPKG_OPT="${1:-${OPKG_UCI}}"
find "${OPKG_OPT}" -name "*-opkg"
}
EOF
. /etc/profile.d/opkg.sh

# Restore packages automatically
mkdir -p /etc/hotplug.d/online
cat << "EOF" > /etc/hotplug.d/online/50-opkg-restore
if [ ! -e /etc/opkg-restore ] \
&& lock -n /var/lock/opkg-restore \
&& opkg update
then . /etc/profile.d/opkg.sh
if uci -q get fstab.overlay > /dev/null \
&& ! grep -q -e "\s/overlay\s" /etc/mtab
then opkg restore rwm
else opkg restore
fi
touch /etc/opkg-restore
lock -u /var/lock/opkg-restore
reboot
fi
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/online/50-opkg-restore
EOF
## hotplug-extras
# Configure hotplug
mkdir -p /etc/hotplug.d/iface
cat << "EOF" > /etc/hotplug.d/iface/90-online
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_find_wan6 NET_IF6
if [ "${INTERFACE}" != "${NET_IF}" ] \
&& [ "${INTERFACE}" != "${NET_IF6}" ]
then exit 0
fi
if [ "${ACTION}" != "ifup" ] \
&& [ "${ACTION}" != "ifupdate" ]
then exit 0
fi
if [ "${ACTION}" = "ifupdate" ] \
&& [ -z "${IFUPDATE_ADDRESSES}" ] \
&& [ -z "${IFUPDATE_DATA}" ]
then exit 0
fi
for FILE in /etc/hotplug.d/online/*
do sh "${FILE}" 2>&1
done | logger -t hotplug-online
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/iface/90-online
EOF
mkdir -p /etc/hotplug.d/online
cat << "EOF" > /etc/hotplug.d/online/30-sleep
sleep 10
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/online/30-sleep
EOF
## uci-extras
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/uci.sh
uci() {
local UCI_CMD="${1}"
case "${UCI_CMD}" in
(validate|diff) uci_"${@}" ;;
(*) command uci "${@}" ;;
esac
}

uci_validate() {
local UCI_CONF="${@:-/etc/config/*}"
for UCI_CONF in ${UCI_CONF}
do if ! uci show "${UCI_CONF}" > /dev/null
then echo "${UCI_CONF}"
fi
done
}

uci_diff() {
local UCI_OCONF="${1:?}"
local UCI_NCONF="${2:-${1}-opkg}"
local UCI_OTEMP="$(mktemp -t uci.XXXXXX)"
local UCI_NTEMP="$(mktemp -t uci.XXXXXX)"
uci export "${UCI_OCONF}" > "${UCI_OTEMP}"
uci export "${UCI_NCONF}" > "${UCI_NTEMP}"
diff -a -b -d -y "${UCI_OTEMP}" "${UCI_NTEMP}"
rm -f "${UCI_OTEMP}" "${UCI_NTEMP}"
}
EOF
. /etc/profile.d/uci.sh
## extroot-restore
cat << "EOF" > /etc/uci-defaults/90-extroot-restore
if [ ! -e /etc/extroot-restore ] \
&& lock -n /var/lock/extroot-restore \
&& uci -q get fstab.overlay > /dev/null \
&& block info > /dev/null
then
OVR_UUID="$(uci -q get fstab.overlay.uuid)"
OVR_DEV="$(block info | sed -n -e "/${OVR_UUID}/s/:.*$//p")"
mount "${OVR_DEV}" /mnt
OVR_BAK="$(mktemp -d -p /mnt -t bak.XXXXXX)"
mv -f /mnt/etc /mnt/upper "${OVR_BAK}"
cp -f -a /overlay/. /mnt
umount /mnt
rm -f /etc/opkg-restore
touch /etc/extroot-restore
lock -u /var/lock/extroot-restore
reboot
fi
exit 1
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/uci-defaults/90-extroot-restore
EOF
## extroot-init
# Prepare extroot/overlay automatically
mkdir -p /etc/hotplug.d/online
cat << "EOF" > /etc/hotplug.d/online/49-extroot-init
if [ ! -e /etc/extroot-init ] && lock -n /var/lock/extroot-init && opkg update
then
  . /etc/profile.d/opkg.sh
  if ! uci -q get fstab.overlay > /dev/null
  then
    DISK=/dev/mmcblk0
    DEVICE=${DISK}p3
    uci set opkg.rwm="opkg"
    uci add_list opkg.rwm.ipkg="fdisk"
    uci add_list opkg.rwm.ipkg="block-mount"
    uci add_list opkg.rwm.ipkg="kmod-fs-f2fs"
    uci add_list opkg.rwm.ipkg="f2fs-tools"
    uci add_list opkg.rwm.ipkg="partx-utils"
    uci add_list opkg.rwm.ipkg="mount-utils"
    uci commit opkg
    opkg restore rwm
    if [ ! -b ${DEVICE} ]
    then
      # Add root fs before mount root
      yes | fdisk -u ${DISK} << "EOCF"
n
p
3
1000000

w
EOCF
      partx -d - ${DEVICE}
      partx -a - ${DEVICE}
    fi
    if [ -b ${DEVICE} ]
    then
      mkfs.f2fs -l rootfs_data  ${DEVICE}
      eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")
      uci -q delete fstab.overlay
      uci set fstab.overlay="mount"
      uci set fstab.overlay.uuid="${UUID}"
      uci set fstab.overlay.target="/overlay"
      uci set fstab.overlay.enabled_fsck="1"
      uci set fstab.overlay.enabled="1"
      uci commit fstab
      touch /etc/extroot-init
      lock -u /var/lock/extroot-init
      sync
      reboot
    fi
  fi
  touch /etc/extroot-init
  lock -u /var/lock/extroot-init     
fi
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/online/49-extroot-init
EOF
## End of all extras
EOAF
. /etc/profile.d/extras.sh
