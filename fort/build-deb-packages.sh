#!/bin/sh

if [ -z "$FVERSION" ]; then
	echo "FVERSION is unset; please add it to the environment."
	return 1
fi

# TODO Hack.
# Probably fix this by moving the debian directory to deb/debian,
# and ridding Fort of its debian branch.
# It's clutter at this point, honestly.
rm -rf deb/debian
cp -r $HOME/git/fort/debian deb/debian

DOCKER_BUILDKIT=1 docker build \
	--file deb/Dockerfile \
	--output bin/$FVERSION \
	--build-arg FVERSION="$FVERSION" \
	.
