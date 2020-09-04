#!/bin/bash

# This is the script I used to generate the RPM packages.
#
# If you're not me, read this first:
#   https://rpm-packaging-guide.github.io
#   https://docs.fedoraproject.org/en-US/packaging-guidelines/
#   http://ftp.rpm.org/max-rpm/index.html
#
# The first argument is the version number (eg. 1.0.0). Mandatory.
#   It needs to match the one defined in configure.ac.
#   (I could compute it automatically, but it sounds like a pain.)
# The second argument is the location of Fort's git repository.
#   Optional. Defaults to "~/git/FORT-validator".
#
# TODO: Complete steps, currently this is functional for CentOS8

PROJECT=fort
ARCH=x86_64

# Parse script arguments
if [ -z "$1" ]; then
	echo "Need version number as argument. (eg. 1.0.0)"
	exit -1
fi
VERSION="$1"

if [ -z "$2" ]; then
	GIT_REPOSITORY=~/git/FORT-validator
else
	GIT_REPOSITORY="$2"
fi

#set -x # Be verbose
#set -e # Panic on errors (You might have to clean up manually)

# Build the upstream tarball
# (I'm assuming you haven't generated it already. Otherwise just use that.)
make -C "$GIT_REPOSITORY" dist
##gpg --yes --detach-sign --armor "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz

# Create the RPM workspace (~/rpmbuild/)
rm -rf ~/rpmbuild
rpmdev-setuptree
# Prepare the workspace with the source files
cp base/$PROJECT.spec ~/rpmbuild/SPECS
cp base/config.json ~/rpmbuild/SOURCES
cp base/$PROJECT.service ~/rpmbuild/SOURCES
cp "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz ~/rpmbuild/SOURCES/"$PROJECT"-$VERSION.tar.gz
##cp "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz.asc ~/rpmbuild/SOURCES/"$PROJECT"-$VERSION.tar.gz.asc

# Build the package
cd ~/rpmbuild

rpmbuild -bs SPECS/$PROJECT.spec
mock -r epel-8-$ARCH SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm
rpmbuild --rebuild SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm
rpm --addsign RPMS/$ARCH/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).$ARCH.rpm
rpm --checksig RPMS/$ARCH/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).$ARCH.rpm

#cd ../..
#tar -zcvf build.tar.gz build/
#sudo mv build.tar.gz /var/www/html/

#run rpmlint -i <RPM>