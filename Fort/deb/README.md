# Fort's Debian package generator

`build-package.sh` is the script I use to generate Fort's Debian package.

If you're not me, read this first (at least chapters 2, 4 and 6): https://www.debian.org/doc/manuals/maint-guide/

These are the steps:

## Create a Debian VM

(If you haven't already. Otherwise simply update it, take a snapshot and jump to the next step.)

This step is optional if you're already running Debian, but it's kind of recommended anyway because of VirtualBox's snapshot feature. Very useful if you make a mess.

(If it's going to take long, you can work on the next step in the meantime.)

The package *should not* be generated on a derivative such as Ubuntu, because they often have newer versions of several things, which leads to compiled binaries that cannot easily run on Debian.

(Debian binaries, on the other hand, should always run on derivatives.)

1. Update the environment. (`sudo apt update && sudo apt upgrade`)
2. Take a snapshot. (And probably delete old ones.)
3. If you plann on using Shared Folders,
	1. Install Virtualbox Guest additions.
	2. Add `~/git` to `VM Settings > Shared Folders`, permanent. (I'm assuming you cloned `packaging` and `FORT-validator` into `~/git`.)
	3. Create `~/mount-git.sh`:

		#!/bin/sh
		
		sudo mount -t vboxsf -o uid=1000,gid=1000 git git

	4. `chmod +x ~/mount-git.sh`
4. Install your GPG keys.
5. Install the Debian packaging tools. (Can't find the recipe; go to the Maintainers' Guide and figure it out.)
6. Install Fort's dependencies. See `debian/control/Build-Depends`.
7. Create the script from step [Generate the Debian package](#generate-the-debian-package).
8. If you plan to also use this VM to package Jool, also install its dependencies and `~/package-jool.sh` script.
9. Take another snapshot.
10. Dance.

That was the most annoying part.

## Update the debian directory

Go to `debian/` (Adjacent to this README), and open and read everything. Update stuff as needed.

At the very least, make sure you add a new `debian/changelog` entry, and if you're not me, replace the `debian/upstream/signing-key.asc` with your own public key.

## Generate the upstream tarball

If you haven't already.

See `../build-upstream-tarball.sh`.

## Generate the Debian package

`~/package-fort.sh`:

	#!/bin/sh

	FVERSION=$1

	set -e
	set -x

	./mount-git.sh

	# The packaging employs some symlinks, which seem to clash with the
	# guest additions driver. So we'll work on a copy.
	rm -rf git2
	mkdir git2
	cp -r git/FORT-validator git/packaging git2

	cd git2/packaging/Fort/deb
	./build-package.sh $FVERSION

	BUILD_FILE=~/git/packaging/Fort/bin/deb-$FVERSION.tar.gz
	rm -f $BUILD_FILE
	tar czvf $BUILD_FILE build
	chmod ugo-w $BUILD_FILE

	blhc dpkg-buildpackage.log

	cd
	sudo umount git

Run with something like

	./package-fort.sh 1.5.2

Done. See `../bin/deb-$FVERSION.tar.gz`, in the host.

Before you turn the VM off, install `~/git2/packaging/Fort/deb/build/fort_$FVERSION-1_amd64.deb` and manhandle it a bit:

	sudo service fort start
	sudo service fort status
	tail -30 /var/log/syslog
	sudo service fort stop

