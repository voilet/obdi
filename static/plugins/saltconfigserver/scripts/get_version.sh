#!/bin/bash

BRANCH="$1"

# Where the salt master config file is
SALT_MASTER_FILE="/etc/salt/master"

get_all_version_strings() {
	cd $REPOHOME/$REPONAME.git

	git branch -a | \
		sed -n 's#^\s*'"$BRANCH"'_\(\)#\1#p' | \
		sort -nt . -k1,1 -k2,2 -k3,3 -k4,4
}

main() {
	local versions new_version

	[[ -z $BRANCH ]] && {
		echo '{"Error":"Argument 1 missing. Expected a branch name."}'
		exit 1
	}

	# This script expects the lines to be in the following format
	# in the SALT_MASTER_FILE
	#
	#   ...
	#   gitfs_remotes:
	#     - file:///srv/fdp-mgmt-salt.git
	#   ...
	#
	# So in this case, 't', below, is loaded with: '/srv/fdp-mgmt-salt.git'

	t=`sed -n '/gitfs_remotes:/,/^[^ ]/ {/^ \+/{s#^.*://\(.*\)#\1#p}}' $SALT_MASTER_FILE`

	[[ -z $t ]] && {
		echo -n '{"Error":"Getting the gitfs_remotes setting from'
		echo ', $SALT_MASTER_FILE, failed (Code 1). Aborting."}'
		exit 1
	}
	REPOHOME="`dirname $t`"
	[[ -z $REPOHOME ]] && {
		echo -n '{"Error":"Getting the gitfs_remotes setting from'
		echo ', $SALT_MASTER_FILE, failed (Code 2). Aborting."}'
		exit 1
	}

	b=`basename $t`
	REPONAME="${b%%.git}"
	[[ -z $REPONAME ]] && {
		echo -n '{"Error":"Getting the gitfs_remotes setting from'
		echo ', $SALT_MASTER_FILE, failed (Code 3). Aborting."}'
		exit 1
	}

	versions=`get_all_version_strings`

    comma=""
    echo -n '{"versions": ['
    for i in $versions; do
        echo -n "$comma\"$i\""
        comma=", "
    done
    echo -n '] }'
}

main

# vim:ts=4:sw=4:noet
