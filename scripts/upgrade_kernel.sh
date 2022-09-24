#!/bin/bash
set -e

## check kernel version in src
SRC_DIR='/usr/src/linux'
function new_version() {
	makefile="$SRC_DIR/Makefile"
	version=$(grep '^VERSION' $makefile | grep -o '[0-9]*')
	patchlevel=$(grep '^PATCHLEVEL' $makefile | grep -o '[0-9]*')
	sublevel=$(grep '^SUBLEVEL' $makefile | grep -o '[0-9]*')
	echo "$version.$patchlevel.$sublevel-gentoo"
}

## params
CUR_VER=$(uname -r)
NEW_VER=$(new_version)
CUR_DIR=$(pwd)
PRO_NUM=$(expr $(nproc) + 1)

echo "current version: $CUR_VER"
echo "new version: $NEW_VER"

## check version
if [ "$CUR_VER" == "$NEW_VER" ]; then
	echo "no need to update, exit"
fi

## swich dir
cd $SRC_DIR

## building kernel
make olddefconfig
make -j $PRO_NUM
make modules_install
make install
make clean

## building initramfs
NEW_VER=$(uname -r)
dracut --kver=$NEW_VER

## removing old kernel
rm -rf /lib/modules/$CUR_VER
rm -rf /boot/*$CUR_VER*

## updating bootloader
grub-mkconfig -o /boot/grub/grub.cfg

## switch dir
cd $CUR_DIR
