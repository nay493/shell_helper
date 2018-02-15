#!/bin/bash

function dump_args {
	echo "Number of arguments: $#"
	local x=0
	while [ -n "$1" ] ; do
		echo -e "\t[$x]:\t\"$1\""
		shift
		let "x++"
	done
	return 0
}

[ -z "$1" ] && {
	echo "Running {$0 'GNU Linux' Bash} ... "
	$0 'GNU Linux' Bash
	exit $?
}

echo -n "dump_args \"\$*\" ... " && dump_args "$*" || exit 1
echo -n "dump_args \$* ... " && dump_args $* || exit 2
echo -n "dump_args \"\$@\" ... " && dump_args "$@" || exit 3 
echo -n "dump_args \$@ ... " && dump_args $@ || exit 4
exit 0
