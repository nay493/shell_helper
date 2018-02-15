#!/system/bin/bash

# this GNU Bash Shell Script unlocks
# my Android Phone by send `input_event
# to the linux kernel

function sync_mt_report {
	# `input_event structured defined in `include/linux/input.h
	# linux kernel version 3.0, little endian
	#        |-------- struct timeval -------| EV_SYN|SYN_MT_R|---- value ----|
	echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00'

	#        |-------- struct timeval -------| EV_SYN|SYN_REPO|---- value ----|
	echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
}

function screen_touch {
	[ -z "$1" ] && {
		return 1
	}
	if [ "$1" = "down" ] ; then
		#        |-------- struct timeval -------| EV_KEY|BTN_TOU|---- value ----|
		echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x4a\x01\x01\x00\x00\x00'
	elif [ "$1" = "up" ] ; then
		#        |-------- struct timeval -------| EV_KEY|BTN_TOU|---- value ----|
		echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x4a\x01\x00\x00\x00\x00'
	else
		return 2
	fi
	return 0
}

function screen_position {
	#        |-------- struct timeval -------| EV_ABS| MAJOR |---- value ----|
	echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x30\x00\x08\x00\x00\x00'
	#        |-------- struct timeval -------| EV_ABS| POS_X |---- value ----|
	echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x35\x00\x1a\x01\x00\x00'
	#        |-------- struct timeval -------| EV_ABS| POS_Y |---- value ----|
	echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x36\x00\x18\x03\x00\x00'
	#        |-------- struct timeval -------| EV_ABS| TRACKI|---- value ----|
	echo -en '\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x39\x00\x00\x00\x00\x00'
}

function main_func {
	# first synchronize report
	sync_mt_report 

	# then touch the screen down
	screen_touch down
	# report the position
	screen_position 
	# and synchronize again
	sync_mt_report 

	# wait for one second
	busybox sleep 1
	# last but not least, release the touch
	screen_touch up
	sync_mt_report 
}

main_func > /dev/input/event3

