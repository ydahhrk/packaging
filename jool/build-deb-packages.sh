#!/bin/sh

if [ -z "$JVERSION" ]; then
	echo "JVERSION is unset; please add it to the environment."
	return 1
fi

rm -rf deb/debian
cp -r $HOME/git/jool/debian deb/debian

docker build \
	--file deb/Dockerfile \
	--output bin/$JVERSION \
	--build-arg JVERSION="$JVERSION" \
	.

TARGZ="jool-$JVERSION-deb.tar.gz"

cd bin/$JVERSION
mkdir -p deb
tar -xzf $TARGZ -C deb
cd deb

lintian -i -I --show-overrides --profile debian *.changes
debsign *.changes || exit 1

rm ../$TARGZ
tar czf ../$TARGZ *
chmod -w ../$TARGZ
