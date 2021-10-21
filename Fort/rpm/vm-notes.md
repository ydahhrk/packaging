Start the VM.

While it boots, make sure the upstream package exists in Fort's directory.
Otherwise create it with

	./generate-upstream-package.sh 1.5.2

Then send Fort and packaging to Apache:

	./send-to-apache.sh

VM:

- Username: The usual VM one
- Password: The very long one

	wget 10.0.2.2/rpm.tar.gz && tar xzf rpm.tar.gz
	wget 10.0.2.2/fort.tar.gz && tar xzf fort.tar.gz
	cd rpm
	time ./build-rpm-package.sh 1.5.2 ~/FORT-validator

Wait like a billion years, then

	cd
	tar czf rpmbuild.tar.gz rpmbuild
	sudo mv rpmbuild.tar.gz /var/www/html
	sudo restorecon /var/www/html/rpmbuild.tar.gz
	sudo systemctl restart httpd.service

Then, in the outer machine:

	cd ~/git/packaging/Fort
	wget 127.0.0.1:8080/rpmbuild.tar.gz
	chmod -x rpmbuild.tar.gz

