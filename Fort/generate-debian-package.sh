#!/bin/bash

# This is the script I used to generate the first Debian packages. It has to be
# run once per project (ie. one for libcmscodec, one for Fort.)
#
# If you're not me, read this first (at least chapters 2, 4 and 6):
# https://www.debian.org/doc/manuals/maint-guide/
#
# The first argument is the project name (libcmscodec or fort), all lowercase
#   (because Debian likes it that way).
#   Mandatory.
# The second argument is the version number (eg. 1.0.0). Mandatory.
#   It probably needs to match the one defined in configure.ac.
# The third argument is the location of the project's git repository.
#   Defaults to "~/$1".
# The fourth argument is the location of the updated debian directory.
#   (You have to update it manually, obviously.)
#   Its name doesn't need to be "debian".
#   Defaults to "debian-$1" (ie. "./debian-fort/" or "./debian-libcmscodec/")
# The fifth argument is the working directory.
#   Defaults to "~/build". Must be absolute.
#
# Always run this script from its parent. (ie. do
# `./generate-debian-package.sh`, not `Fort/generate-debian-package.sh`.)
#
# Example: ./generate-debian-package.sh fort 1.0.0 ~/git/fort debians/fort
#
# The procedure I'm using follows. (It can probably be optimized; I haven't
# mastered this mess at all. And I haven't reached chapter 8 yet.)
#
# I'm going to assume that you're running this on a virtual machine (which is
# recommended anyway, since the libcmscodec installation might pollute your
# /usr), of the VirtualBox variety. And that you have the following workspace:
#
#	~/fort/: Mounted shared folder containing Fort's git repository
#	~/libcmscodec/: Mounted shared folder containing libcmscodec's git repo
#	~/packaging/: Mounted shared folder containing this file's git repo
#	~/build/: Working directory (Currently empty)
#
# autotools will leave lots of junk in `~/fort` and `~/libcmscodec` as always.
# (ie. Don't assume that `~/build` is the only one that needs write
# permissions.)
#
# Also, even though you'll later want to move the resulting files elsewhere,
# `~/build` should not be a mounted shared folder. The reason is that the build
# process needs to create some symlinks at some points, and VirtualBox blocks
# this in shared folders for security reasons.
#
# These are the steps:
#
# 1. Update the debian directories (adjacent to this file).
# 2. If you installed libcmscodec and fort somehow, remove them.
#    You should probably mirror the method you installed them with.
#    (ie. use `make uninstall` if you used `make install`, `dpkg -r` for
#    `dpkg -i`, or `apt remove` for `apt install`.)
# 3. Make sure all the build dependencies are installed. (See the `control`
#    files in the debian directories.)
#    (Apparently, you also have to install dh-make.)
# 4. Run `./deconf.sh` and `./autogen.sh` in both libcmscodec and fort, or
#    better yet, re-clone, to ensure clean code. (You will need asn1c for
#    libcmscodec's, so maybe do it in the host machine.)
# 5. Generate the libcmscodec packages:
#	cd ~/packaging/Fort
#	./generate-debian-package.sh libcmscodec <version>`
#	  (respond "l" and "y".)
# 6. Install them:
#	sudo dpkg -i ~/build/*.deb
# 7. Generate the fort packages:
#	./generate-debian-package.sh fort <version>`
#	  (respond "s" and "y".)
# 8. (Optional) Clean up by uninstalling libcmscodec:
#	sudo dpkg -r libcmscodec1 libcmscodec-dev
#
# Done. It should have spewn a lot of crap in `~/build`, among which you can
# find your `.deb` files.
# The `$PROJECT-$VERSION.tar.gz` files are also important. They are the
# "upstream tarballs," and should definitely be included in the Github releases.
#
# Also, read the comments below before starting anything.
#
# Actually tested in Ubuntu 18.04, not Debian.


# Parse script arguments
if [ -z "$1" ]; then
	echo "Need project name as argument. (fort or libcmscodec)"
	exit -1
else
	PROJECT="$1"
fi

if [ -z "$2" ]; then
	echo "Need version number as argument. (eg. 1.0.0)"
	exit -1
else
	VERSION="$2"
fi

if [ -z "$3" ]; then
	GIT_REPOSITORY=~/"$1"
else
	GIT_REPOSITORY="$3"
fi

if [ -z "$4" ]; then
	DEBIAN_DIR=debian-"$1"
else
	DEBIAN_DIR="$4"
fi

if [ -z "$5" ]; then
	WORKING_DIR=~/build
else
	WORKING_DIR="$5"
fi


set -x # Be verbose
set -e # Panic on errors (You might have to clean up manually)

PACKAGING_DIR="$(pwd)"

# Clean up
rm -rf "$WORKING_DIR/*"


# Create upstream tarball
# (I'm assuming you haven't generated them already. Otherwise just use that.)
cd "$GIT_REPOSITORY"
# Run these outside of the script instead; I don't want to install asn1c here.
# Pain in the ass.
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
