#!/bin/bash

PARENT_DIR=$( cd `dirname $0`/../.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}
echo "###########################################"
echo "##    Installing development tools      ###"
echo ""
yum -y install wget > /dev/null
yum -y groupinstall "Development tools" > /dev/null
yum -y install gcc libgcc glibc libffi-devel libxml2-devel libxslt-devel openssl-devel zlib-devel bzip2-devel ncurses-devel python-devel --skip-broken > /dev/null
echo "Done."

echo "Downloading GPM..."
wget https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2 > /dev/null

echo "Extracting..."
tar -xvjpf gmp-6.0.0a.tar.bz2 > /dev/null

cd gmp-6.0.0

mkdir log
touch log/compile.log

echo "Configuring..."
./configure > log/compile.log
echo "Making..."
make > log/compile.log
echo "Making with check..."
make check > log/compile.log
echo "Installing..."
make install > log/compile.log

cd ${BASE_DIR}
echo "DONE!"
echo "#############################################"
echo "#############################################"