#!/system/binary/bash

# Fast Code Viewer, with the help of GNU Global

# check number of command-line arguments
if [[ $# -eq 0 || $# -gt 2 ]] ; then
	echo "Usage: $0 [number-of-lines] symbol"
	exit 1
fi

outnum=8  # default output 8 lines of code
if [ -n "$2" ] ; then
	outnum="$1"
	let "outnum += 0"
	[ ${outnum} -eq 0 ] && outnum=8
	shift
fi

# check the symbol interested in
if [ -z "$1" ] ; then
	echo "Usage: $0 [number-of-lines] symbol"
	exit 2
fi

pat="$1"
gout="`global -x ${pat}`"
if [ -z "${gout}" ] ; then
	echo "Symbol not found: \"${pat}\""
	exit 3
fi

function display_symbol {
	# get the line number
	local lino="`echo ${1} | gawk '{print $2}'`"
	if [ -z "${lino}" ] ; then
		return 1
	fi

	# get the file path
	local path="`echo ${1} | gawk '{print $3}'`"
	if [ -z "${path}" ] ; then
		return 2
	fi

	# ensure that `lino is a number
	local li_no="${lino}"
	let "li_no += 0"
	if [ "${li_no}" != "${lino}" ] ; then
		return 3
	fi

	# ensure that we're dealing with a normal file
	if [ ! -f "${path}" ] ; then
		return 4
	fi

	# show the specified area
	echo "=========== ${path} =========="
	sed -n -e "${lino},+${outnum}p" "${path}"
	return 0
}

# process the output of `GNU Global, one line at a time
while read lin ; do
	if [ -z "${lin}" ] ; then
		continue
	fi
	display_symbol "${lin}"
	if [ $? -ne 0 ] ; then
		echo "Invalid global output: \"${lin}\""
	fi
done <<< "${gout}"

exit 0

