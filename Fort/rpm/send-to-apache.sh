#!/bin/sh

# Publishes this folder and Fort's upstream tarball (and its signature) in the
# local apache webserver, so they can be downloaded from the VM where you'll
# generate the packages.
# (Because this often easier than setting up shared folders.)

# This script assumes you're doing this after generating the Debian package,
# so the upstream tarball should be in Fort's directory.
# Otherwise create it manually:
#
#	./generate-upstream-package 1.5.2

cd ..
tar czf rpm.tar.gz rpm
sudo mv rpm.tar.gz /var/www/html

cd ~/git
tar czf fort.tar.gz FORT-validator
sudo mv fort.tar.gz /var/www/html

sudo service apache2 start

