#!/bin/sh

# Usage:
#
#	./generate-upstream-package.sh <version>
#
# Eg:
#
#	./generate-upstream-package.sh 1.5.2

FORT_VERSION="$1"

set -x
set -e

cd ~/git/FORT-validator
./deconf.sh
./autogen.sh
./configure
make dist
gpg --yes --detach-sign --armor "fort-$FORT_VERSION.tar.gz"

