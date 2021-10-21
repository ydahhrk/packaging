The CentOS VM has to be roughly the same as the Debian machine. (I didn't install the Guest Additions because.)

	sudo yum install gcc rpm-build rpm-devel rpmlint make python bash \
			coreutils diffutils patch rpmdevtools rpm-sign epel-release \
			mock epel-rpm-macros
	sudo usermod -a -G mock al

Also install apache? and make sure there's a permanent SSH server.

--------------------------------------------------------------------------------

Start the CentOS VM. In the meantime, generate the upstream tarball (if you haven't already):

	../build-upstream-tarball.sh 1.5.2

Update `base/`. `fort.spec` needs a new version number and a new changelog entry. If you're not me, change the keyring.

Send `..` to the VM:

	./send-to-vm.sh 1.5.2

VM:

	tar xzf packaging.tar.gz
	cd Fort/rpm
	# Note: Might want to do a test run without the mocks first.
	time ./build-rpm-package.sh 1.5.2

Wait like a billion years, then look at the last lines of output; that's Lintian messages.

Now try it out:

	cd
	sudo yum install rpmbuild/RPMS/x86_64/fort_$FVERSION-1.el8.x86_64.rpm
	sudo service fort start
	sudo service fort status
	sudo tail -30 /var/log/messages
	sudo service fort stop

Send it to the host machine:

	# alt:
	# outside: sudo systemctl start sshd
	# inside: scp stuff.rpm ahhrk@10.0.2.2:/home/ahhrk/Downloads

	tar czf rpm-1.5.2.tar.gz rpmbuild
	sudo mv rpm-1.5.2.tar.gz /var/www/html
	sudo restorecon /var/www/html/rpm-1.5.2.tar.gz
	sudo systemctl start httpd.service

Then, in the host machine:

	cd ~/git/packaging/Fort/bin
	wget 127.0.0.1:8080/rpm-1.5.2.tar.gz
	chmod ugo-w rpm-1.5.2.tar.gz

Remember to save:

	cd ~/git/packaging
	git add .
	git commit -S
	git push origin master

