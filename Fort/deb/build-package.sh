#!/bin/bash

# Generates Fort's Debian package.
# 
# It needs one argument: The version number of the Fort binary you're releasing.
# Example: "1.0.0"

PROJECT=fort

# Parse script arguments
if [ -z "$1" ]; then
	echo "I need Fort's version number as argument. (eg. 1.0.0)"
	exit 1
fi
VERSION="$1"

#set -x # Be verbose
set -e # Panic on errors (You will have to clean up manually)

# Create the Debian workspace (build/)
rm -rf build
mkdir -p build/
cp ../bin/$PROJECT-$VERSION.tar.gz build/"$PROJECT"_$VERSION.orig.tar.gz
cp ../bin/$PROJECT-$VERSION.tar.gz.asc build/"$PROJECT"_$VERSION.orig.tar.gz.asc
tar -C build/ -xzf build/"$PROJECT"_$VERSION.orig.tar.gz
cp -r debian build/$PROJECT-$VERSION

# Build the package
cd build/$PROJECT-$VERSION
DPKG_COLORS=never dpkg-buildpackage -us -uc > ../../dpkg-buildpackage.log
debsign

# Find problems
lintian -i -I --show-overrides ../*.changes | less

