#!/bin/bash

# Create bridged network via Wireless Network Interface
# Created by yeholmes@outlook.com

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

function get_global_vars {
	if [ -z "${IFACE0}" ] ; then
		export IFACE0="eth0"
	fi
	echo "Using network interface \"${IFACE0}\"..."
	
	if [ -z "${IFACE1}" ] ; then
		export IFACE1="wlan0"
	fi
	echo "Using network interface \"${IFACE1}\"..."
	
	if [ -z "${BRIDGE}" ] ; then
		export BRIDGE="bridge"
	fi
	echo "Using bridge interface \"${BRIDGE}\"..."
}

function reset_interface {
	[ -z "$1" ] && return 1
	ip link set dev "$1" up || return 2
	ip addr flush dev "$1" || return 3
	return 0
}

function create_bridge {
	# check if bridge network already exists
	ip addr show dev "${BRIDGE}" >/dev/null 2>&1
	if [ $? -eq 0 ] ; then
		# the bridge already created.
		return 0
	fi
	# create the bridge network
	brctl addbr "${BRIDGE}" || return 1
	reset_interface "${BRIDGE}"

	reset_interface "${IFACE0}"
	# add interface 0 to the bridge
	brctl addif "${BRIDGE}" "${IFACE0}" || return 2

	reset_interface "${IFACE1}"
	# add interface 1 to the bridge
	if [ "${IFACE1}" = "wlan0" ] ; then
		rfkill unblock wifi
		iw dev "${IFACE1}" set "4addr" on
	fi
	brctl addif "${BRIDGE}" "${IFACE1}" || return 3
	return 0
}

function delete_bridge {
	# check if bridge network already exists
	ip addr show dev "${BRIDGE}" >/dev/null 2>&1
	if [ $? -ne 0 ] ; then
		# the bridge does not exist.
		return 0
	fi
	brctl delif "${BRIDGE}" "${IFACE0}"
	brctl delif "${BRIDGE}" "${IFACE1}"
	ip link set dev "${BRIDGE}" down || return 3
	brctl delbr "${BRIDGE}" || return 4
	return 0
}

function start_hostapd {
	local tmpconf="/tmp/hostapd.conf"
	cat > "${tmpconf}" <<EOF
# what the fuck ?!
interface=${IFACE1}
driver=nl80211
ssid=office-campus
hw_mode=g
channel=6
wpa=2
wpa_passphrase=ilovetelnet
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
auth_algs=1
macaddr_acl=0
# the fuck is pure shit
EOF
	hostapd -B "${tmpconf}" || return 1
	return 0
}

function stop_hostapd {
	killall -q hostapd
	return $?
}

function start_dhcp_client {
	[ -z "$1" ] && return 1
	# kill all the dhcp client daemon provided by busybox
	killall -q busybox

	# copy the dhcpc configuration file
	local dhcpconf="/tmp/dhcpc.sh"
	cp -f "simple.script" "${dhcpconf}" || return 2
	chmod 755 "${dhcpconf}" || return 3
	busybox udhcpc -i "$1" -b -s "${dhcpconf}" || return 4
	return 0
}

function stop_dhcp_client {
	killall -q busybox
	return $?
}

function main_stop {
	echo -n "Stopping hostapd... "
	stop_hostapd || {
		echo "Warning: \`stop_hostapd returned $? "
	}
	echo "Done."

	echo -n "Stopping DHCP client... "
	stop_dhcp_client || {
		echo "Warning: \`stop_dhcp_client returned $? "
	}
	echo "Done."

	echo -n "Removing bridge network... "
	delete_bridge || {
		echo "Warning: \`delete_bridge returned $? "
	}
	echo "Done."
}

function main_start {
	# first, if the bridge interface exists, call `main_stop
	ip addr show dev "${BRIDGE}" >/dev/null 2>&1 && \
		main_stop >/dev/null

	echo "Creating bridge network... "
	create_bridge || {
		echo "Error: \`create_bridge returned $?"
		return 1
	}
	echo "Done."

	echo "Starting DHCP client... "
	start_dhcp_client "${BRIDGE}" || {
		echo "Error: \`start_dhcp_client returned $?"
		return 2
	}
	echo "Done."

	echo "Starting hostapd... "
	start_hostapd || {
		echo "Error: \`start_hostapd returned $?"
		return 3
	}
	echo "Done."
	return 0
}

[ -z "$1" ] && {
	echo "Usage: `basename $0` (start | stop)" 1>&2
	exit 1
}

get_global_vars

if [ "$1" = "start" ] ; then
	main_start
elif [ "$1" = "stop" ] ; then
	main_stop
else
	echo "Usage: `basename $0` (start | stop)" 1>&2
	exit 2
fi

exit $?

