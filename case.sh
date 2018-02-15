#!/bin/bash

function main_func {
	local ret=0
	while [ -n "$1" ] ; do
		case "$1" in 
		0) echo "Zero" ;;
		1) echo "One" ;;
		2) echo "Two" ;&
		3) echo "Three" ;;
		4) echo "Four" ;;
		5) echo "Five" ;;&
		6) echo "Six" ;;
		7) echo "Seven" ;;
		8) echo "Eight" ;;
		9) echo "Nine" ;;
		*) ret=1; echo "Unknown Number: $1" ;;
		esac
		shift
	done
	return $ret
}

[ -z "$1" ] && {
	echo "main_func 2 5 4 9 10 :"
	main_func 2 5 4 9 10
	exit $?
}

main_func "$@"
exit $?
