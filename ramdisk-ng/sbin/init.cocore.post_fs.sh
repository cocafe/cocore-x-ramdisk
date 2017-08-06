#!/system/bin/sh

export PATH=/system/bin

LOG=/init.log

exec >> ${LOG} 2>&1

echo "mount /system rw,remount"

mount -o rw,remount /system