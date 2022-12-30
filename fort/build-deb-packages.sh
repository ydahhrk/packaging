#!/bin/sh

# Generates Fort's Debian packages. See ../common/build-dev-packages.sh
#
# First argument: Release version.
# Second argument: Location of Fort's git repository; optional.

../common/build-deb-packages.sh "fort" "$1" "$2"

