#!/bin/bash

# This is the script I use to generate the RPM packages.
#
# Reference material:
#
#   https://rpm-packaging-guide.github.io
#   https://docs.fedoraproject.org/en-US/packaging-guidelines/
#   http://ftp.rpm.org/max-rpm/index.html
#
# Argument: Fort's version number (eg. "1.0.0"). Mandatory.

PROJECT=fort
ARCH=x86_64

# Parse script arguments
if [ -z "$1" ]; then
	echo "I need Fort's version number as argument. (eg. 1.0.0)"
	exit 1
fi
VERSION="$1"

set -x # Print commands
set -e # Panic on errors (You might have to clean up manually)

# Create the RPM workspace (~/rpmbuild/)
rm -rf ~/rpmbuild
rpmdev-setuptree
# Prepare the workspace with the source files
cp base/$PROJECT.spec ~/rpmbuild/SPECS
cp base/config.json ~/rpmbuild/SOURCES
cp base/$PROJECT.service ~/rpmbuild/SOURCES
cp base/default.slurm ~/rpmbuild/SOURCES
cp base/$PROJECT.keyring ~/rpmbuild/SOURCES/$PROJECT-$VERSION.keyring
cp ../bin/$PROJECT-$VERSION.tar.gz ~/rpmbuild/SOURCES/$PROJECT-$VERSION.tar.gz
cp ../bin/$PROJECT-$VERSION.tar.gz.asc ~/rpmbuild/SOURCES/$PROJECT-$VERSION.tar.gz.asc

# Build the package
cd ~/rpmbuild

rpmbuild -bs SPECS/$PROJECT.spec
mock -r epel-8-$ARCH SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm
mock -r epel-7-$ARCH SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm
rpmbuild --rebuild SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm

# TODO Sign with an official key
#rpm --addsign RPMS/$ARCH/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).$ARCH.rpm
#rpm --checksig RPMS/$ARCH/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).$ARCH.rpm

rpmlint -i ~/rpmbuild/RPMS/$ARCH/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).$ARCH.rpm

