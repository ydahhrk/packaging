#!/bin/bash

# This is the script I used to generate the first Debian packages.
#
# If you're not me, read this first (at least chapters 2, 4 and 6):
# https://www.debian.org/doc/manuals/maint-guide/
#
# The first argument is the version number (eg. 1.0.0). Mandatory.
#   It needs to match the one defined in configure.ac.
#   (I could compute it automatically, but it sounds like a pain.)
# The second argument is the location of Jool's git repository.
#   Optional. Defaults to "~/git/jool".
#
# These are the steps:
#
# 1. Update the debian directory (adjacent to this file).
#    Note that, if you're not me, you need to replace the file
#    debian/upstream/signing-key.asc with your own public key.
# 2. Make sure all the build dependencies are installed. (See `debian/control`.)
# 3. Run `./deconf.sh`, `./autogen.sh` and `./configure` in Jool.
# 4. Generate the Debian packages: `./build-packages.sh 4.0.2`
#    (Remember: That version number needs to match configure.ac, as well as the
#    latest changelog entry from the debian directory.)
#
# Done. It should have spewn a lot of crap in `build/`, among which you can
# find your `.deb` files. At present, there are two of them: One for the kernel
# modules (jool-dkms), and one for the userspace tools (jool-tools).
# `$2/jool-$VERSION.tar.gz` is also important. It is the "upstream tarball,"
# and should definitely be included in the Github release. (Note that it ships
# with a signature, too.)
#
# Also, read the comments below before starting anything. (Just in case.)
#
# Actually tested in Ubuntu 18.04, not Debian.

PROJECT=jool

# Parse script arguments
if [ -z "$1" ]; then
	echo "Need version number as argument. (eg. 1.0.0)"
	exit -1
fi
VERSION="$1"

if [ -z "$2" ]; then
	GIT_REPOSITORY=~/git/$PROJECT
else
	GIT_REPOSITORY="$2"
fi

#set -x # Be verbose
#set -e # Panic on errors (You might have to clean up manually)

# Build the upstream tarball
# (I'm assuming you haven't generated it yet. Otherwise just use that.)
make -C "$GIT_REPOSITORY" dist
gpg --yes --detach-sign --armor "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz

# Create the Debian workspace (build/)
rm -rf build
mkdir -p build/
cp "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz build/"$PROJECT"_$VERSION.orig.tar.gz
cp "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz.asc build/"$PROJECT"_$VERSION.orig.tar.gz.asc
tar -C build/ -xzf build/"$PROJECT"_$VERSION.orig.tar.gz
cp -r debian build/$PROJECT-$VERSION

# Build the package
cd build/$PROJECT-$VERSION
dpkg-buildpackage -us -uc
debsign

#cd ../..
#tar -zcf build.tar.gz build/
#sudo mv build.tar.gz /var/www/html/
#sudo service apache2 start
