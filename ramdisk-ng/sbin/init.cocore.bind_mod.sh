#!/system/bin/sh

LOG=/init.log
exec >> ${LOG} 2>&1

export PATH=/system/bin

# Bind ramfs over original system module directory
mount -t ramfs -o mode=0755 ramfs /system/lib/modules

mv /lib/modules/* /system/lib/modules

chmod 0755 /system/lib/modules
chmod 0644 /system/lib/modules/*.ko