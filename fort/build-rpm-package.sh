#!/bin/sh

if [ -z "$FVERSION" ]; then
	echo "FVERSION is unset; please add it to the environment."
	return 1
fi

DOCKER_BUILDKIT=1 docker build \
	--file rpm/Dockerfile \
	--build-arg FVERSION="$FVERSION" \
	--output bin/$FVERSION \
	.
