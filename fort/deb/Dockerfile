FROM debian:12 AS fortbuild
ARG FVERSION

# This prevents a prompt that happens when apt tries to install pbuilder.
# It might be a temporary problem; try deleting this.
# (Or consider removing pbuilder if it's no longer necessary.)
RUN echo "deb http://deb.debian.org/debian/ stable main contrib" > /etc/apt/sources.list

RUN apt update
RUN apt upgrade -y
# Build tools
RUN apt install -y build-essential autoconf automake autotools-dev debhelper debmake \
	devscripts fakeroot git gnupg pbuilder perl python3 quilt blhc \
	cpio gawk
# Declared by Fort's debian/control
RUN apt install -y pkg-config libcurl4-openssl-dev libjansson-dev \
	libmicrohttpd-dev libssl-dev libxml2-dev

RUN useradd ahhrk
USER ahhrk

# Create debian workspace
WORKDIR /home/ahhrk/deb
COPY --chown=ahhrk:ahhrk bin/$FVERSION/fort-$FVERSION.tar.gz fort_$FVERSION.orig.tar.gz
COPY --chown=ahhrk:ahhrk bin/$FVERSION/fort-$FVERSION.tar.gz.asc fort_$FVERSION.orig.tar.gz.asc
RUN tar xzf fort_$FVERSION.orig.tar.gz
COPY --chown=ahhrk:ahhrk deb/debian fort-$FVERSION/debian

# Build
WORKDIR /home/ahhrk/deb/fort-$FVERSION
RUN DPKG_COLORS=never dpkg-buildpackage -us -uc

# Check
# TODO Lintian fails even on success because it can't delete something;
# can't figure out why. I commented this for now.
#WORKDIR /home/ahhrk/deb
#RUN lintian -i -I --show-overrides *.changes

# Export
WORKDIR /home/ahhrk/deb
RUN tar czf ../fort-$FVERSION-deb.tar.gz *
RUN chmod -w ../fort-$FVERSION-deb.tar.gz

################

FROM scratch AS fortexport
ARG FVERSION

COPY --from=fortbuild /home/ahhrk/fort-$FVERSION-deb.tar.gz fort-$FVERSION-deb.tar.gz
