#!/system/bin/sh

export PATH=/system/bin

LOG=/init.log

DIR_DRMFIX=/lib/libdrmfix

INS_DRMFIX=/lib/libdrmfix/lib/libdrmfix.so
INS_DRMFIX64=/lib/libdrmfix/lib64/libdrmfix.so

LIB_DRMFIX=/system/vendor/lib/libdrmfix.so
LIB_DRMFIX64=/system/vendor/lib64/libdrmfix.so

NO_DRMFIX=/system/libdrmfix_no

exec >> ${LOG} 2>&1

if ! [ -e ${LIB_DRMFIX} ]; then
  echo "install libdrmfix.so"
  cp ${INS_DRMFIX} ${LIB_DRMFIX}
  chown root:root ${LIB_DRMFIX}
  chmod 0644 ${LIB_DRMFIX}
  chcon u:object_r:system_file:s0 ${LIB_DRMFIX}
fi

if ! [ -e ${LIB_DRMFIX64} ]; then
  echo "install libdrmfix.so:64"
  cp ${INS_DRMFIX64} ${LIB_DRMFIX64}
  chown root.root ${LIB_DRMFIX64}
  chmod 0644 ${LIB_DRMFIX64}
  chcon u:object_r:system_file:s0 ${LIB_DRMFIX64}
fi

# Save RAM in initramfs
rm -fr ${DIR_DRMFIX}

# Check libdrmfix disable status
if [ -e ${NO_DRMFIX} ]; then
  echo "libdrmfix disabled by user"
  setprop ro.libdrmfix.load 0
else
  echo "libdrmfix enabled"
  setprop ro.libdrmfix.load 1
fi