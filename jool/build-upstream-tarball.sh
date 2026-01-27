#!/bin/sh

# Generates Jool's upstream tarball. See ../common/build-upstream-tarball.sh
#
# First argument: Location of Jool's git repository.

if [ -z "$JVERSION" ]; then
	echo "JVERSION is unset; please add it to the environment."
	return 1
fi

../common/build-upstream-tarball.sh "jool" "$JVERSION" "$2"
