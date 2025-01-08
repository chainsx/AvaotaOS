#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0
#
# This file is a part of the Avaota Build Framework
# https://github.com/AvaotaSBC/AvaotaOS/

build_bootloader(){
  BOARD=$1
  source ../boards/${BOARD}.conf
  
  cd ${BL_CONFIG}
  make CROSS_COMPILE=${BL_GCC} ${BL_CONF}
  make CROSS_COMPILE=${BL_GCC} -j$(nproc)
  cd ..
}

apply_bootloader(){
  BOARD=$1
  source ../boards/${BOARD}.conf
  if [ -d ${workspace}/bootloader-${BOARD} ];then rm -rf ${workspace}/bootloader-${BOARD}; fi
  
  dd if=${workspace}/${BL_CONFIG}/boot0_sdcard.fex of=${workspace}/bootloader.bin
  dd if=${workspace}/${BL_CONFIG}/boot_package.fex of=${workspace}/bootloader.bin bs=8k seek=2049 conv=notrunc
  
  mkdir -p ${workspace}/bootloader-${BOARD}/extlinux
  cp ${workspace}/../target/boot/uInitrd ${workspace}/bootloader-${BOARD}
  cp ${workspace}/../target/boot/extlinux.conf ${workspace}/bootloader-${BOARD}/extlinux
  sed -i "s|BOARD_NAME|${DEVICE_DTS}|g" ${workspace}/bootloader-${BOARD}/extlinux/extlinux.conf
  sed -i "s|BOOTARGS|${BOOTARGS}|g" ${workspace}/bootloader-${BOARD}/extlinux/extlinux.conf
  echo "${BOARD}" > ${workspace}/bootloader-${BOARD}/.done
}
