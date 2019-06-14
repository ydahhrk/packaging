#!/bin/bash

# This is the script I used to generate the first Debian packages.
#
# If you're not me, read this first (at least chapters 2, 4 and 6):
# https://www.debian.org/doc/manuals/maint-guide/
#
# The first argument is the version number (eg. 1.0.0). Mandatory.
#   It probably needs to match the one defined in configure.ac.
# The second argument is the location of the project's git repository.
#   Optional. Defaults to "~/fort".
# The third argument is the working directory.
#   Optional. Defaults to "~/build". Must be absolute.
#
# Always run this script from its parent. (ie. do
# `./generate-debian-package.sh`, not `Fort/generate-debian-package.sh`.)
#
# Example: ./generate-debian-package.sh 1.0.0 ~/git/fort ~/build-tmp
#
# The procedure I'm using follows. (It can probably be optimized; I haven't
# mastered this mess at all. And I haven't reached chapter 8 yet.)
#
# I'm going to assume that you're running this on a virtual machine of the
# VirtualBox variety. And that you have the following workspace:
#
#	~/fort/: Mounted shared folder containing Fort's git repository
#	~/packaging/: Mounted shared folder containing this file's git repo
#	~/build/: Working directory (Currently empty)
#
# autotools will leave lots of junk in `~/fort` as always. (ie. Don't assume
# that `~/build` is the only one that needs write permissions.)
#
# Also, even though you'll later want to move the resulting files elsewhere,
# `~/build` should not be a mounted shared folder. The reason is that the build
# process needs to create some symlinks at some points, and VirtualBox blocks
# this in shared folders for security reasons.
#
# These are the steps:
#
# 1. Update the debian directory (adjacent to this file).
# 2. If you installed fort somehow, remove it. You should probably mirror the
#    method you installed it with.
#    (ie. use `make uninstall` if you used `make install`, `dpkg -r` for
#    `dpkg -i`, or `apt remove` for `apt install`.)
# 3. Make sure all the build dependencies are installed. (See the `control`
#    files in the debian directory.)
#    (Apparently, you also have to install dh-make.)
# 4. Run `./deconf.sh` and `./autogen.sh` in Fort, or better yet, re-clone, to
#    ensure clean code.
# 5. Generate the fort package:
#	./generate-debian-package.sh <version>`
#	  (respond "s" and "y" when prompted.)
#
# Done. It should have spewn a lot of crap in `~/build`, among which you can
# find your `.deb` file.
# The `fort-$VERSION.tar.gz` file is also important. It is the "upstream
# tarball," and should definitely be included in the Github release.
#
# Also, read the comments below before starting anything. (Just in case.)
#
# Actually tested in Ubuntu 18.04, not Debian.


# Parse script arguments
PROJECT="fort"

if [ -z "$1" ]; then
	echo "Need version number as argument. (eg. 1.0.0)"
	exit -1
else
	VERSION="$1"
fi

if [ -z "$2" ]; then
	GIT_REPOSITORY=~/fort
else
	GIT_REPOSITORY="$2"
fi

DEBIAN_DIR=debian

if [ -z "$3" ]; then
	WORKING_DIR=~/build
else
	WORKING_DIR="$3"
fi


set -x # Be verbose
set -e # Panic on errors (You might have to clean up manually)

PACKAGING_DIR="$(pwd)"

# Clean up
rm -rf "$WORKING_DIR/*"


# Create upstream tarball
# (I'm assuming you haven't generated them already. Otherwise just use that.)
cd "$GIT_REPOSITORY"
# Replaced by step 4.
#./deconf.sh
#./autogen.sh
./configure
make dist


# Prepare debian workspace
cd "$WORKING_DIR"
mv "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz .
tar xvfz $PROJECT-$VERSION.tar.gz
cd $PROJECT-$VERSION/
dh_make -f ../$PROJECT-$VERSION.tar.gz --copyright mit


# Build the package
rm -r debian/
cp -r "$PACKAGING_DIR/$DEBIAN_DIR" debian/
# TODO add signing
dpkg-buildpackage -us -uc
