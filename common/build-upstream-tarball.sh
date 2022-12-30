#!/bin/sh

# Generates a project's upstream tarball.
# It's the main release file, and it also serves as input for the deb and rpm
# packages.
#
# This script is not meant to be run directly. Use `../$1/build-deb-packages.sh`
# instead.
#
# First argument: Project name. (Either "jool" or "fort".) Mandatory.
# Second argument: Release Version. (Eg. "1.0.0".) Mandatory.
#   It needs to match the one defined in configure.ac.
# Third argument: Location of the project's git repository.
#   Optional; defaults to "~/git/$1".
#
# Will dump the resulting files into "bin/".

if [ -z "$1" ]; then
	echo 'I need the project name as 1st argument. ("jool" or "fort")'
	exit 1
fi
PROJECT="$1"

if [ -z "$2" ]; then
	echo 'I need the release version number as 2nd argument. (eg. "1.0.0")'
	exit 1
fi
VERSION="$2"

if [ -z "$3" ]; then
	GIT_REPOSITORY="$HOME/git/$PROJECT"
else
	GIT_REPOSITORY="$3"
fi

WORKSPACE="$(pwd)"
TARGZ="$PROJECT-$VERSION.tar.gz"
SIGNATURE="$TARGZ.asc"

set -x # Be verbose
set -e # Panic on errors

cd "$GIT_REPOSITORY"
git checkout debian
./deconf.sh
./autogen.sh
./configure
make dist
gpg --yes --detach-sign --armor "$TARGZ"

mkdir -p "$WORKSPACE/bin"
mv "$TARGZ" "$SIGNATURE" "$WORKSPACE/bin"
# These are sacred; don't tweak them.
chmod ugo-w "$WORKSPACE/bin/$TARGZ" "$WORKSPACE/bin/$SIGNATURE"

