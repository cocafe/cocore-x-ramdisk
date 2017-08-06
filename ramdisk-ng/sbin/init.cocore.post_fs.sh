#!/system/bin/sh

LOG=/init.log

exec >> ${LOG} 2>&1

RD_MOD=/lib/modules
SYS_MOD=/system/lib/modules

if ! [ -L ${SYS_MOD}/bcmdhd.ko ]; then
  mv ${SYS_MOD}/bcmdhd.ko ${SYS_MOD}/bcmdhd.ko.orig
  ln -s ${RD_MOD}/bcmdhd.ko ${SYS_MOD}/bcmdhd.ko
fi