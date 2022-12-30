#!/bin/sh

# Generates Jool's Debian packages. See ../common/build-dev-packages.sh
#
# First argument: Release version.
# Second argument: Location of Jool's git repository.
#
# Will dump the resulting files into `bin/`.
# The most important landmarks are the kernel modules package (jool-dkms),
# and the userspace tools package (jool-tools).

../common/build-deb-packages.sh "jool" "$1" "$2"
