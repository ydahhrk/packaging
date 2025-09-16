Requires `git`, autotools, `make`, `gpg` and Docker. Assumes fort has been cloned at `~/git/fort`.

```bash
export FVERSION=1.6.7    # Tweak!

./build-upstream-tarball.sh
./build-deb-packages.sh
./build-rpm-package.sh
```
