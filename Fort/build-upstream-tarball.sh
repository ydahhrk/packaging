#!/bin/sh

# Generates the upstream tarball.
# This is the main release file, and it also serves as input for both the deb
# and rpm packages.

if [ -z "$1" ]; then
	echo "I need Fort's version number as argument. (eg. 1.0.0)"
	exit 1
fi
FVERSION=$1

TARGZ=fort-$FVERSION.tar.gz
SIG=$TARGZ.asc

cd ~/git/FORT-validator
./deconf.sh
./autogen.sh
./configure
make dist
gpg --yes --detach-sign --armor $TARGZ

mkdir -p ~/git/packaging/Fort/bin
mv $TARGZ $SIG ~/git/packaging/Fort/bin
chmod ugo-w ~/git/packaging/Fort/bin/$TARGZ ~/git/packaging/Fort/bin/$SIG

