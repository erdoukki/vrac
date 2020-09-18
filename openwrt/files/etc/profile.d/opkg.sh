# Copyright (C) 2020 OpenWrt.org
# 
# https://openwrt.org/docs/guide-user/additional-software/opkg#functions

# Initialize Opkg configuration
opkg_uci() {
    if ! uci -q show opkg > /dev/null
    then uci import opkg < /dev/null
    fi
    uci -q batch << EOF
delete opkg.overlay
delete opkg.rom
delete opkg.rwm
set opkg.overlay=overlay
set opkg.rom=rom
set opkg.rwm=rwm
set opkg.custom=custom
$(sed -r -e "s/^(.*)\s(.*)$/add_list opkg.\2.pkg=\1/")
commit opkg
EOF
}
 
# Import Opkg configuration from sysupgrade backup
opkg_import() {
    local OPKG_BACK="${1:-/etc/backup/installed_packages.txt}"
    sed -e "s/\sunknown$/\trwm/" "${OPKG_BACK}" | opkg_uci
}
 
# Back up the list of installed packages
opkg_backup() {
    opkg_list_dest | opkg_uci
}
 
# Install missing packages from the list
opkg_restore() {
    local OPKG_LIST="${1:-overlay}"
    local OPKG_PKGS="$(uci get opkg."${OPKG_LIST}".pkg)"
    local OPKG_INST="$(mktemp -t opkg.XXXXXX)"
    local OPKG_BACK="$(mktemp -t opkg.XXXXXX)"
    opkg list-installed | sed -e "s/\s.*$//" > "${OPKG_INST}"
    echo "${OPKG_PKGS}" | sed -e "s/\s/\n/g" > "${OPKG_BACK}"
    opkg_proc install $(grep -v -x -f "${OPKG_INST}" "${OPKG_BACK}")
    rm -f "${OPKG_INST}" "${OPKG_BACK}"
}
 
# List packages by destination
opkg_list_dest() {
    find /usr/lib/opkg/info -name "*.control" "(" \
    "(" -exec test -f /rom/{} ";" -exec echo {} rom ";" ")" -o \
    "(" -exec test -f /overlay/upper/{} ";" -exec echo {} overlay ";" ")" -o \
    "(" -exec echo {} rwm ";" ")" ")" | sed -e "s/.*\///;s/\.control\s/\t/"
}
 
# Process packages one by one
opkg_proc() {
    local OPKG_PKG=""
    local OPKG_CMD="${1:?}"
    if [ -z "${2}" ]
    then local OPKG_PKGS=""
    else local OPKG_PKGS="${@#* }"
    fi
    for OPKG_PKG in ${OPKG_PKGS}
    do opkg "${OPKG_CMD}" "${OPKG_PKG}"
    done
}
 
# Upgrade all installed packages
opkg_upgrade_all() {
    local OPKG_DEST="${1:-.*}"
    local OPKG_INST="$(mktemp -t opkg.XXXXXX)"
    local OPKG_UPGR="$(mktemp -t opkg.XXXXXX)"
    opkg_list_dest | sed -n -e "s/\s${OPKG_DEST}$//p" > "${OPKG_INST}"
    opkg list-upgradable | sed -e "s/\s.*$//" > "${OPKG_UPGR}"
    opkg_proc upgrade $(grep -x -f "${OPKG_INST}" "${OPKG_UPGR}")
    rm -f "${OPKG_INST}" "${OPKG_UPGR}"
}
 
# Find new configurations
opkg_newconf() {
    find /etc -name "*-opkg"
}

