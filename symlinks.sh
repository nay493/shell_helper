#!/bin/bash

if [ -z "$1" ] || [ ! -d "$1" ] ; then
	echo "Usage: `basename $0` target-dir [tarball ...]" 1>&2
	exit 1
fi
remotedir=`readlink -f -n "$1"` ; shift

basedir=`readlink -f -n "$0"`
basedir=`dirname "$basedir"`
if [ ! -d "$basedir" ] ; then
	echo "Failed to find base directory!" 1>&2
	exit 1
fi

if [ "$basedir" = "$remotedir" ] ; then
	echo "Invalid base & remote directory: \"$basedir\"" 1>&2
	exit 1
fi

cd "$basedir" || {
	echo "Failed to change to directory: \"$basedir\"!" 1>&2
	exit 1
}

function create_symlink {
	if [ -z "$1" ] ; then
		return
	fi
	local f0="${basedir}/$1"
	local f1="${remotedir}/$1"

	if [ ! -f "$f0" ] ; then
		echo "Skip file: \"$f0\""
		return
	fi
	if [ -e "$f1" ] ; then
		# echo "File exists: \"$f1\""
		return
	fi
	ln -sv "$f0" "$f1"
}

if [ -n "$1" ] ; then
	while [ -n "$1" ] ; do
		create_symlink "$1"
		shift
	done
	exit 0
fi

for fil in *.gz ; do
	create_symlink "$fil"
done

for fil in *.bz2 ; do
	create_symlink "$fil"
done

for fil in *.xz ; do
	create_symlink "$fil"
done

for fil in *.tgz ; do
	create_symlink "$fil"
done

exit 0
