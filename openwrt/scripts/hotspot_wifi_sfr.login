#!/bin/sh
# captive portal auto-login script for SFR FON HotSpot with credentials as parameters
# Copyright (c) 2021 GÃ©rald Kerma (gandalf@gk2.net)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2016,2039,2059,2086,2143,2181,2188
#
# Requirements : curl sleep sed sh
# move to /etc/travelmate/hotspot_wifi_sfr.login

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
set -o pipefail

if [ "$(uci_get 2>/dev/null; printf "%u" "${?}")" = "127" ]
then
        . "/lib/functions.sh"
fi

trm_domain="www.perdu.com"
trm_url="https://hotspot.wifi.sfr.fr/nb4_crypt.php"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:80.0) Gecko/20100101 Firefox/80.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"
trm_fetch="$(command -v curl)"

user="${1}"
password="${2}"

RET=0
CHALLENGE="$("${trm_fetch}" -Is http://${trm_domain} | grep challenge | sed -nr 's|.*&challenge=([0-9a-z]+)&.*|\1|p')"
PAGE="$("${trm_fetch}" -ks --user-agent "${trm_useragent}" --silent --connect-timeout $((trm_maxwait/6)) \
        --header "Content-Type:application/x-www-form-urlencoded" \
        --data "username=${user}&password=${password}&challenge=${CHALLENGE}&userurl=http%3A%2F%2F${trm_domain}" "${trm_url}")"
NEWURL="$(echo "$PAGE"|sed -nr 's|.*window.location.*"(.*)";.*|\1|p')"
response="$("${trm_fetch}" --user-agent "${trm_useragent}" --silent --connect-timeout $((trm_maxwait/6)) "$NEWURL")"
##echo ${response}
RET=$?
exit $RET
