#!/bin/sh

# Generates Fort's upstream tarball. See ../common/build-upstream-tarball.sh
#
# First argument: Release version.
# Second argument: Location of Fort's git repository; optional.

../common/build-upstream-tarball.sh "fort" "$1" "$2"

