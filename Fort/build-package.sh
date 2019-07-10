#!/bin/bash

# This is the script I used to generate the first Debian packages.
#
# If you're not me, read this first (at least chapters 2, 4 and 6):
# https://www.debian.org/doc/manuals/maint-guide/
#
# The first argument is the version number (eg. 1.0.0). Mandatory.
#   It needs to match the one defined in configure.ac.
#   (I could compute it automatically, but it sounds like a pain.)
# The second argument is the location of Fort's git repository.
#   Optional. Defaults to "~/git/fort".
#
# Example: ./build-package.sh 1.0.0 ~/fort
#
# These are the steps:
#
# 1. Update the debian directory (adjacent to this file).
# 2. Make sure all the build dependencies are installed. (See `debian/control`.)
#    (Apparently, you also have to install dh-make.)
# 3. Run `./deconf.sh`, `./autogen.sh` and `./configure` in Fort
# 4. Generate the Debian package: `./build-package.sh 0.0.2`
#
# Done. It should have spewn a lot of crap in `build/`, among which you can
# find your `.deb` file.

# The `fort-$VERSION.tar.gz` file is also important. It is the "upstream
# tarball," and should definitely be included in the Github release.
#
# Also, read the comments below before starting anything. (Just in case.)
#
# Actually tested in Ubuntu 18.04, not Debian.

# Parse script arguments
if [ -z "$1" ]; then
	echo "Need version number as argument. (eg. 1.0.0)"
	exit -1
fi
VERSION="$1"

if [ -z "$2" ]; then
	FORT_REPOSITORY=~/git/fort
else
	FORT_REPOSITORY="$2"
fi

#set -x # Be verbose
#set -e # Panic on errors (You might have to clean up manually)

# Build the upstream tarball
# (I'm assuming you haven't generated it already. Otherwise just use that.)
make -C "$FORT_REPOSITORY" dist

# Create the Debian workspace (build/)
rm -rf build/*
mkdir -p build/
mv "$FORT_REPOSITORY"/fort-$VERSION.tar.gz build/fort_$VERSION.orig.tar.gz
tar -C build/ -xzf build/fort_$VERSION.orig.tar.gz
cp -r debian build/fort-$VERSION

# Build the package
cd build/fort-$VERSION
# TODO add signing?
dpkg-buildpackage -us -uc
