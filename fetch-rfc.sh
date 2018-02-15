#!/bin/bash

if [ -z "$1" ] ; then
	echo "Usage: $0 rfc-number ..." 1>&2
	exit 1
fi

function check_and_fetch {
	local rfc="rfc${1}.txt"
	if [ -e "${rfc}" ] ; then
		echo "\"${rfc}\" already exists!"
		return 0
	fi

	echo -n "Fetching \"${rfc}\"... "
	wget -q "http://www.rfc-editor.org/rfc/${rfc}" -O "${rfc}"
	local retval="$?"

	if [ ${retval} -eq 0 ] ; then
		echo "Done."
		chmod 444 "${rfc}"
	else
		echo "Error."
		rm -rf "${rfc}"
	fi
	return ${retval}
}

while [ -n "$1" ] ; do
	check_and_fetch "$1"
	if [ $? -ne 0 ] ; then
		echo "Failed to fetch \"rfc${1}.txt\"!" 1>&2
		break
	fi
	shift
done

