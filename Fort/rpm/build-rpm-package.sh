#!/bin/bash

# This is the script I used to generate the RPM packages.
#
# If you're not me, read this first:
#   https://rpm-packaging-guide.github.io
#   https://docs.fedoraproject.org/en-US/packaging-guidelines/
#   http://ftp.rpm.org/max-rpm/index.html (Just as a reference)
#
# The first argument is the version number (eg. 1.0.0). Mandatory.
#   It needs to match the one defined in configure.ac.
#   (I could compute it automatically, but it sounds like a pain.)
# The second argument is the location of Fort's git repository.
#   Optional. Defaults to "~/git/FORT-validator".
#
# Steps to use this script, currently from CentOS 8:
# 1. Use your own GPG key to sign the dist file (.tar.gz), and use it also
#    to create a newer 'base/fort.keyring'. Here are some steps to import the
#    key to your local machine (where you will build the RPM):
#      gpg --allow-secret-key-import --import <your_private_key.asc>
#      sudo rpm --import <public_key.asc>
#      echo "%_gpg_name <public_KEY_ID>" >> ~/.rpmmacros
#      # And now create the .keyring
#      gpg2 --export --export-options export-minimal <public_KEY_ID> > fort.keyring
# 2. Install the required dependencies to build RPMS ('mock' is recommended):
#      sudo yum install gcc rpm-build rpm-devel rpmlint make python bash coreutils \
#                       diffutils patch rpmdevtools rpm-sign
#      sudo yum install mock
#      sudo yum install epel-rpm-macros
# 3. Run `./deconf.sh`, `./autogen.sh` and `./configure` at Fort source dir.
# 4. Generate the RPM:
#      ./build-rpm-package.sh 1.4.1 [fort-source-dir]
#
# This will create the SRPM and the RPM, and mock its creation at EPEL-8 and EPEL-7.
# If everything went ok, you can find the distributable RPM at ~/rpmbuild/RPMS/x86_64;
# don't forget to run 'rpmlint -i' on the resultant RPM.

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
gpg --yes --detach-sign --armor "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz

# Create the RPM workspace (~/rpmbuild/)
rm -rf ~/rpmbuild
rpmdev-setuptree
# Prepare the workspace with the source files
cp base/$PROJECT.spec ~/rpmbuild/SPECS
cp base/config.json ~/rpmbuild/SOURCES
cp base/$PROJECT.service ~/rpmbuild/SOURCES
cp base/default.slurm ~/rpmbuild/SOURCES
cp base/$PROJECT.keyring ~/rpmbuild/SOURCES
cp "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz ~/rpmbuild/SOURCES/$PROJECT-$VERSION.tar.gz
cp "$GIT_REPOSITORY"/$PROJECT-$VERSION.tar.gz.asc ~/rpmbuild/SOURCES/$PROJECT-$VERSION.tar.gz.asc

# Build the package
cd ~/rpmbuild

rpmbuild -bs SPECS/$PROJECT.spec
mock -r epel-8-$ARCH SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm
mock -r epel-7-$ARCH SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm
rpmbuild --rebuild SRPMS/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).src.rpm

# TODO Sign with an official key
#rpm --addsign RPMS/$ARCH/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).$ARCH.rpm
#rpm --checksig RPMS/$ARCH/$PROJECT-$VERSION-1$(rpm --eval %{?dist}).$ARCH.rpm

echo 'run rpmlint -i RPMS/'$ARCH'/'$PROJECT'-'$VERSION'-1'$(rpm --eval %{?dist})'.'$ARCH'.rpm'
