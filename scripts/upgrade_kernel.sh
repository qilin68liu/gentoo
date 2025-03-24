#!/bin/bash
set -ex

CLEAN_BUILD=Yes
FORCE_UPGRADE=No

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
PRO_NUM=$(expr $(nproc) + 1)

echo "current version: $CUR_VER"
echo "new version: $NEW_VER"

## check version
if [ "$CUR_VER" == "$NEW_VER" ] && [ $FORCE_UPGRADE == 'No' ]; then
	echo 'no need to update, exit'
	exit 0
fi

## swich dir
cd $SRC_DIR

## copy old kernel config
cp /boot/config-$CUR_VER .config

## building kernel
make olddefconfig
make modules_prepare
make -j $PRO_NUM
emerge @module-rebuild
make modules_install
make install

## clean build dir
if [ "$CLEAN_BUILD" == 'Yes' ]; then
    make distclean
fi

## building initramfs
# dracut --force --kver=$NEW_VER

## removing old kernel
if [ "$CUR_VER" != "$NEW_VER" ]; then
    rm -vrf /lib/modules/$CUR_VER
    rm -vrf /boot/*$CUR_VER*
fi

## updating bootloader
# grub-mkconfig -o /boot/grub/grub.cfg

## set grub bootloader timeout
sed -i 's/timeout=[0-9]\+/timeout=1/g' /boot/grub/grub.cfg
