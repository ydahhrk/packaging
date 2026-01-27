FROM debian:12 AS joolbuild
ARG JVERSION

RUN apt update
RUN apt upgrade -y
# Build tools
RUN apt install -y debhelper
# Declared by jool's debian/control
RUN apt install -y dh-sequence-dkms \
 pkgconf gawk file cpio \
 libnl-genl-3-dev libnl-3-dev \
 libxtables-dev

RUN useradd ahhrk
USER ahhrk

# Create debian workspace
WORKDIR /home/ahhrk/deb
COPY --chown=ahhrk:ahhrk bin/$JVERSION/jool-$JVERSION.tar.gz jool_$JVERSION.orig.tar.gz
COPY --chown=ahhrk:ahhrk bin/$JVERSION/jool-$JVERSION.tar.gz.asc jool_$JVERSION.orig.tar.gz.asc
RUN tar xzf jool_$JVERSION.orig.tar.gz
COPY --chown=ahhrk:ahhrk deb/debian jool-$JVERSION/debian

# Build
WORKDIR /home/ahhrk/deb/jool-$JVERSION
RUN DPKG_COLORS=never dpkg-buildpackage -us -uc

# Export
WORKDIR /home/ahhrk/deb
RUN tar czf ../jool-$JVERSION-deb.tar.gz *

################

FROM scratch AS joolexport
ARG JVERSION

COPY --from=joolbuild /home/ahhrk/jool-$JVERSION-deb.tar.gz jool-$JVERSION-deb.tar.gz
