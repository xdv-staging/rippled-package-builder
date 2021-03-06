#!/bin/bash

function error {
  echo $1
  exit 1
}

# Check rpm's md5sum
yumdownloader --enablerepo=$YUM_REPO rippled-$RIPPLED_VERSION-4.el7.centos
REPO_MD5SUM=`rpm -Kv *.x86_64.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
if [ "$REPO_MD5SUM" != "$MD5SUM" ]; then
  error "md5sum mismatch ($REPO_MD5SUM)"
fi

yum install -y --enablerepo=$YUM_REPO rippled-$RIPPLED_VERSION
rc=$?; if [[ $rc != 0 ]]; then
  error "error downloading rippled-$RIPPLED_VERSION rpm from $YUM_REPO"
fi

yumdownloader --source --enablerepo=$YUM_REPO rippled-$RIPPLED_VERSION
rc=$?; if [[ $rc != 0 ]]; then
  error "error downloading rippled-$RIPPLED_VERSION source rpm from $YUM_REPO"
fi

rpm -i rippled-*.src.rpm
tar -zxf ~/rpmbuild/SOURCES/rippled.tar.gz -C ./
cd rippled
npm install
mkdir build
ln -s /opt/ripple/bin/rippled build/rippled

/opt/ripple/bin/rippled --unittest
rc=$?; if [[ $rc != 0 ]]; then
  error "rippled --unittest failed"
fi

npm test
rc=$?; if [[ $rc != 0 ]]; then
  error "npm test failed"
fi
