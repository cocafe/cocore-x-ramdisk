#!/system/bin/sh

LOG=/init.log

exec >> ${LOG} 2>&1

if [ -e ${LOG} ]; then
  # Mark init log global readable
  chmod 0644 ${LOG}
fi

# TCP fastopen
echo 3 > /proc/sys/net/ipv4/tcp_fastopen