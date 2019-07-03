#!/bin/bash

# This is the script I used to generate the first Debian packages.
#
# The first argument is the version number (eg. 1.0.0). Mandatory.
#   It needs to match the one defined in configure.ac.
#   (I could compute it automatically, but it sounds like a pain.)
# The second argument is the location of Jool's git repository.
#   Optional. Defaults to "~/git/Jool".
#
# These are the steps:
#
# 1. Update the debian directory (adjacent to this file).
# 2. Make sure all the build dependencies are installed. (See `debian/control`.)
# 3. Generate the Debian packages: `./build-packages.sh 4.0.2`
#
# Done. It should have spewn a lot of crap in `build/`, among which you can
# find your `.deb` files. At present, there are two of them: One for the kernel
# modules (jool-dkms), and one for the userspace tools (jool-utils).
# The `jool-$VERSION.tar.gz` file is also important. It is the "upstream
# tarball," and should definitely be included in the Github release.
#
# Actually tested in Ubuntu 18.04, not Debian.

# Parse script arguments
if [ -z "$1" ]; then
	echo "Need version number as argument. (eg. 1.0.0)"
	exit -1
fi
VERSION="$1"

if [ -z "$2" ]; then
	JOOL_REPOSITORY=~/git/Jool
else
	JOOL_REPOSITORY="$2"
fi

# Build the upstream tarball
make -C "$JOOL_REPOSITORY" dist

# Create the Debian workspace (build/)
rm -rf build/*
mkdir -p build/
mv "$JOOL_REPOSITORY"/jool-$VERSION.tar.gz build/jool_$VERSION.orig.tar.gz
tar -C build/ -xzf build/jool_$VERSION.orig.tar.gz
cp -r debian build/jool-$VERSION

# Build the package
cd build/jool-$VERSION
# TODO add signing?
dpkg-buildpackage -us -uc
