The Rocky Linux 8 has to be roughly the same as the Debian machine. (I didn't install the Guest Additions because.)

```
dnf install gcc rpm-build rpm-devel rpmlint make python bash \
		coreutils diffutils patch rpmdevtools rpm-sign epel-release \
		mock epel-rpm-macros

# Fort
dnf install autoconf automake libxml2-devel libcurl-devel openssl-devel jansson-devel

usermod -a -G mock al
```

Rocky 9 packages (I might be misremembering some):

```
# Common
dnf install tar autoconf automake

# Jool
dnf install gcc make elfutils-libelf-devel
dnf install kernel-devel libnl3-devel

# Fort
dnf --enablerepo=devel install jansson-devel libcurl-devel libxml2-devel
dnf install check-devel
```

Also, make sure there's a permanent SSH server.

--------------------------------------------------------------------------------

Start the "Rocky Linux 8" VM. In the meantime, generate the upstream tarball (if you haven't already):

```
../build-upstream-tarball.sh 1.5.4
```

Update `base/`. At the very least, `fort.spec` needs a new version number and a new changelog entry.

If you're not me, or the keyring needs updating:

```
gpg --list-keys
gpg --export --armor [your keyid here] > base/fort.keyring
```

Connect the VM (sudo not needed):

```
nmcli connection up enp0s3
```

You can SSH now. Update the VM:

```
sudo su
dnf check-update
dnf update
```

Save snapshot, restart, send `..` to the VM, build:

```
cd ../..
tar czf packaging.tar.gz fort
scp -P 2288 packaging.tar.gz al@127.0.0.1:/home/al
rm packaging.tar.gz

ssh -p 2288 al@127.0.0.1
tar xzf packaging.tar.gz
cd fort/rpm
# Note: Might want to do a test run without the mocks first.
# (Comment them out on build-rpm-package.sh.)
time ./build-rpm-package.sh 1.5.4
```

Wait like a billion years, then look at the last lines of output; that's Lintian messages.

Now try it out:

```
cd ~/rpmbuild/RPMS/x86_64
sudo dnf install ./fort-$FVERSION-1.el8.x86_64.rpm
fort --version
sudo service fort start
sudo service fort status
sudo tail -30 /var/log/messages
sudo service fort stop
```

Send it to the host machine:

```
cd
tar czf rpm-1.5.4.tar.gz rpmbuild/
exit
cd ~/git/packaging/fort/bin/
scp -P 2288 al@127.0.0.1:/home/al/rpm-1.5.4.tar.gz rpm-1.5.4.tar.gz
chmod ugo-w rpm-1.5.4.tar.gz
```

Remember to save:

```
cd ~/git/packaging
git add .
git commit -S
git push origin main
```
