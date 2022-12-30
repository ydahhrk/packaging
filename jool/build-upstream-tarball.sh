#!/bin/sh

# Generates Jool's upstream tarball. See ../common/build-upstream-tarball.sh
#
# First argument: Release version.
# Second argument: Location of Jool's git repository.

../common/build-upstream-tarball.sh "jool" "$1" "$2"

