#!/system/binary/bash

# simple GNU Bash script to manipulate the
# brightness level of my android phone.
tbr=0
bfile="/sys/class/leds/lcd-backlight/brightness"

# get current touch screen brightness level
read cbr < "${bfile}"
if [ -z "${cbr}" ] ; then
	echo "Fatal Error, unable to read \"${bfile}\"."
	exit 1
fi

# check for any possible argument value
if [ -n "$1" ] ; then
	tbr="$1"
	let "tbr += 0" # make sure that $1 is a number

	# re-check 0
	if [ "$tbr" != "$1" ] ; then
		echo "\"$1\" is not a number."
		exit 2
	fi

	# re-check 1
	if [[ $tbr -gt 255 || $tbr -lt 0 ]] ; then
		echo "Invalid brightness: $tbr"
		exit 3
	fi

	# current brightness level is different from target level?
	if [ $cbr -ne $tbr ] ; then
		echo ${tbr} > "${bfile}"
		exit $?
	fi
	exit 0
fi

# flip the brightness level
if [ $cbr -eq 0 ] ; then
	tbr=128
fi

echo ${tbr} > "${bfile}"
exit $?

