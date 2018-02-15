#!/bin/bash

# determine if current shell is forked by 
# a Vim edit session.

gppid=""
function get_parent_pid {
	[ -z "$1" ] && return 1

	local stfile="/proc/${1}/status"
	[ ! -f "${stfile}" ] && return 2 
	
	local ppid="`cat ${stfile} | grep -i ppid | gawk '{print $2}'`"
	[ -z "${ppid}" ] && return 3
	gppid="${ppid}"
	return 0
}

function dump_pid_cmdline {
	[ -z "$1" ] && return 1

	local cmdline="/proc/${1}/cmdline"
	[ ! -f "${cmdline}" ] && return 2

	cat "${cmdline}" | tr '\0' ' '
	return 0
}

function main_func {
	# get parent shell PID
	get_parent_pid $$ || {
		echo "Failed to get PID of parent shell: $?" 1>&2
		return 1
	}
	local shpid="${gppid}"

	# get the PID of shell's parent process
	get_parent_pid "${shpid}" || {
		echo "Failed to get parent PID of ${shpid}: $?" 1>&2
		return 2
	}

	local vimpid="${gppid}"
	local exe="/proc/${vimpid}/exe"
	[ ! -e "${exe}" ] && {
		# echo "Fatal error, process with PID ${vimpid} does not exist!" 1>&2
		return 3
	}

	local rexe="`readlink -fn ${exe}`"
	[ -z "${rexe}" ] && {
		# echo "Failed to find real executable ELF image for PID ${vimpid}!" 1>&2
		return 4
	}
	rexe="`basename ${rexe}`"
	if [ "${rexe}" = "vim" ] ; then
		echo "${vimpid}: [ `dump_pid_cmdline ${vimpid}`]"
		return 0
	fi
	# echo "rexe: \"${rexe}\""
	return 5
}

main_func || {
	echo "Not under any vim"
}

