#!/bin/sh

# Generates a project's Debian packages.
#
# If you're not me, read this first (at least chapters 2, 4 and 6):
# https://www.debian.org/doc/manuals/maint-guide/
#
# First argument: Project name. (Either "jool" or "fort".) Mandatory.
# Second argument: Release Version. (Eg. "1.0.0".) Mandatory.
#   It needs to match the one defined in configure.ac, as well as the latest
#   entry from `debian/changelog`.
# Third argument: Location of the project's git repository.
#   Optional; defaults to `~/git/$1`.
#
# This script is not meant to be run directly. Steps:
#
# 1. In the project's "debian" branch, Update the `debian/` directory.
#    Note that, if you're not me, you need to replace the file
#    `debian/upstream/signing-key.asc` with your own public key.
# 2. Make sure all the build dependencies are installed. (See `debian/control`.)
# 3. Go to `../$1`
# 3. Build the upstream tarball: `./build-upstream-tarball.sh 4.0.2`
# 4. Generate the Debian packages: `./build-deb-packages.sh 4.0.2`
#
# Will dump the resulting files into `bin/`.
#
# Also, read the comments below before starting anything. (Just in case.)
#
# *This is meant to be run in a Debian machine.*
# Derivatives tend to update some dependencies, which renders their resulting
# packages incompatible with the parent distribution.

if [ -z "$1" ]; then
	echo 'I need the project name as argument. ("jool" or "fort")'
	exit 1
fi
PROJECT="$1"

if [ -z "$2" ]; then
	echo 'I need the release version number as argument. (eg. "1.0.0")'
	exit 1
fi
VERSION="$2"

if [ -z "$3" ]; then
	GIT_REPOSITORY="$HOME/git/$PROJECT"
else
	GIT_REPOSITORY="$3"
fi

set -x # Be verbose
set -e # Panic on errors

# Create the Debian workspace (deb/)
rm -rf deb
mkdir -p deb
cp bin/$VERSION/$PROJECT-$VERSION.tar.gz     deb/"$PROJECT"_$VERSION.orig.tar.gz
cp bin/$VERSION/$PROJECT-$VERSION.tar.gz.asc deb/"$PROJECT"_$VERSION.orig.tar.gz.asc

cd deb
chmod u+w "$PROJECT"_$VERSION.orig.tar.gz "$PROJECT"_$VERSION.orig.tar.gz.asc
tar -xzf "$PROJECT"_$VERSION.orig.tar.gz
cd $PROJECT-$VERSION
cp -r "$GIT_REPOSITORY"/debian .

# Workspace ready; let the Debian thing do its magics
DPKG_COLORS=never dpkg-buildpackage -us -uc > ../../dpkg-buildpackage.log
debsign

# Copy results to bin/
cd ..
tar czf "../bin/$VERSION/$PROJECT-$VERSION-deb.tar.gz" *
chmod ugo-w "../bin/$VERSION/$PROJECT-$VERSION-deb.tar.gz"

# Find problems
echo "Please watch out for errors and warnings on the output of these commands:"
blhc ../dpkg-buildpackage.log # Check log for missing hardening flags
lintian -i -I --show-overrides *.changes

