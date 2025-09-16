FROM rockylinux:8 AS fortbuild
ARG FVERSION

# rpmdevtools is the basic RPM building package.
# epel-release is needed by crb enable.
RUN dnf install -y rpmdevtools epel-release
# Needed for jansson-devel and libmicrohttpd-devel to be available
RUN crb enable
# Declared by fort.spec
RUN dnf install -y autoconf automake epel-rpm-macros gcc \
	libxml2-devel make openssl-devel pkgconfig jansson-devel \
	libcurl-devel libmicrohttpd-devel rpmlint systemd-rpm-macros

RUN useradd ahhrk
USER ahhrk

WORKDIR /home/ahhrk/
RUN rpmdev-setuptree

WORKDIR /home/ahhrk/rpmbuild
COPY --chown=ahhrk:ahhrk rpm/base/fort.spec SPECS
COPY --chown=ahhrk:ahhrk rpm/base/config.json SOURCES
COPY --chown=ahhrk:ahhrk rpm/base/fort.service SOURCES
COPY --chown=ahhrk:ahhrk rpm/base/default.slurm SOURCES
COPY --chown=ahhrk:ahhrk rpm/base/fort.keyring SOURCES/fort-$FVERSION.keyring
COPY --chown=ahhrk:ahhrk bin/$FVERSION/fort-$FVERSION.tar.gz SOURCES/fort-$FVERSION.tar.gz
COPY --chown=ahhrk:ahhrk bin/$FVERSION/fort-$FVERSION.tar.gz.asc SOURCES/fort-$FVERSION.tar.gz.asc
RUN rpmbuild -bs SPECS/fort.spec
RUN rpmbuild --rebuild SRPMS/fort-$FVERSION-1$(rpm --eval %{?dist}).src.rpm
#RUN rpmlint -i RPMS/$ARCH/fort-$FVERSION-1$(rpm --eval %{?dist}).$ARCH.rpm

WORKDIR /home/ahhrk/
RUN tar czf rpm-$FVERSION.tar.gz rpmbuild
RUN chmod -w rpm-$FVERSION.tar.gz

################

FROM scratch AS fortexport
ARG FVERSION

COPY --from=fortbuild /home/ahhrk/rpm-$FVERSION.tar.gz rpm-$FVERSION.tar.gz
