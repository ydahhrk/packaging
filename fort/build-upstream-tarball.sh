#!/bin/sh

# Generates Fort's upstream tarball. See ../common/build-upstream-tarball.sh
#
# First argument: Location of Fort's git repository. Optional.

if [ -z "$1" ]; then
	GIT="$HOME/git/fort"
else
	GIT="$1"
fi

if [ -z "$FVERSION" ]; then
	echo "FVERSION is unset; please add it to the environment."
	return 1
fi

../common/build-upstream-tarball.sh "fort" "$FVERSION" "$GIT"
