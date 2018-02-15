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

cd "$remotedir" || {
	echo "Failed to change to directory: \"$basedir\"!" 1>&2
	exit 1
}

function mv_tarball {
	if [ -z "$1" ] ; then
		return
	fi
	local f0="${basedir}/$1"
	local f1="${remotedir}/$1"

	if [ -e "$f0" ] ; then
		echo "File exists: \"$f0\""
		return
	fi
	if [ ! -f "$f1" ] ; then
		echo "Skip file: \"$f1\""
		return
	fi
	mv -v "$f1" "$f0" && chmod 444 "$f0" && \
	chown "root:root" "$f0"
}

if [ -n "$1" ] ; then
	while [ -n "$1" ] ; do
		if [ ! -L "$1" ] ; then
			mv_tarball "$1"
		fi
		shift
	done
	exit 0
fi

for fil in *.gz ; do
	if [ ! -L "$fil" ] ; then
		mv_tarball "$fil"
	fi
done

for fil in *.bz2 ; do
	if [ ! -L "$fil" ] ; then
		mv_tarball "$fil"
	fi
done

for fil in *.xz ; do
	if [ ! -L "$fil" ] ; then
		mv_tarball "$fil"
	fi
done

for fil in *.tgz ; do
	if [ ! -L "$fil" ] ; then
		mv_tarball "$fil"
	fi
done

exit 0
