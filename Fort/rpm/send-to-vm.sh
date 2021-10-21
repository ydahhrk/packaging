#!/bin/sh

cd ../..
tar czf packaging.tar.gz Fort
echo "The password is the very long one."
scp -P 2208 packaging.tar.gz al@127.0.0.1:/home/al
rm packaging.tar.gz

