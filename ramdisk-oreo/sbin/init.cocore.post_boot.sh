#!/system/bin/sh

LOG=/init.log

exec >> ${LOG} 2>&1

echo init.cocore_post-boot: start

if [ -e ${LOG} ]; then
  # Mark init log global readable
  chmod 0644 ${LOG}
fi

# Remove splash logo to save some memory
BOOTLOGO=/res/logo.raw
if [ -f ${BOOTLOGO} ]; then
  rm ${BOOTLOGO}
fi

# Trim filesystems
/sbin/busybox fstrim -v /data
/sbin/busybox fstrim -v /cache
/sbin/busybox fstrim -v /system

#
# CPUFreq Settings:
#     board: msm8952
#     soc_id: 266
#

# Disable thermal core control
echo 0 > /sys/module/msm_thermal/core_control/enabled

# Wake up all CPU cores, just in case
for i in {0,1,2,3,4,5}; do
  echo 1 > /sys/devices/system/cpu/cpu$i/online
done

# RCU threads: Set affinity to offload RCU workload
for i in {0,1,2,3,4,5}; do
  RCU_PID=`pgrep "rcuop/$i"`
  taskset -a -p 01 ${RCU_PID}

  RCU_PID=`pgrep "rcuob/$i"`
  taskset -a -p 01 ${RCU_PID}

  RCU_PID=`pgrep "rcuos/$i"`
  taskset -a -p 01 ${RCU_PID}
done

# Set cpu_boost parameters
echo "0:1305600" > /sys/module/cpu_boost/parameters/input_boost_freq
echo "40" > /sys/module/cpu_boost/parameters/input_boost_ms
echo 9 > /proc/sys/kernel/sched_upmigrate_min_nice

# Set (super) packing parameters
echo 1017600 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_freq
echo 0 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_freq

# HMP Scheudler Settings
echo 200000 > /proc/sys/kernel/sched_freq_inc_notify

# CPU Governor Settings: power cluster
echo 19000    > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo 1017600  > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo 1        > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 20000    > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
echo 90       > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
echo 10000    > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 40000    > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack

# CPU Governor Settings: perf cluster
echo "19000 1382400:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo 1382400  > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
echo 1        > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
echo 40000    > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
echo "90 1747200:80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
echo 10000    > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo 40000    > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack

# MSM Core Control Settings
if [ -e /system/lib/modules/core_ctl.ko ]; then
  insmod /system/lib/modules/core_ctl.ko

  # Power cluster

  # Perf cluster
  echo 2    > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
  echo 4    > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
  echo 68   > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
  echo 40   > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
  echo 100  > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
  echo 1    > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
fi

# CPUQuiet Governor Settings
if [ -e /sys/devices/system/cpu/cpuquiet ]; then
  echo 4 > /sys/devices/system/cpu/cpuquiet/nr_min_cpus
  echo rqbalance > /sys/devices/system/cpu/cpuquiet/current_governor
fi

#
# CPUFreq Settings: end
#

# Block Queue Scheduler
echo cfq > /sys/block/mmcblk0/queue/scheduler
echo cfq > /sys/block/mmcblk1/queue/scheduler

# Let CFQ decide lowest latency by kernel HZ
echo 0 > /sys/block/mmcblk0/queue/iosched/target_latency
echo 0 > /sys/block/mmcblk1/queue/iosched/target_latency

# Mount world-writable ramfs for file-cache in ram
mkdir -p /ram
mount -t ramfs -o mode=0777 ramfs /ram

# Symlink install /sbin/busybox for su shell
#/sbin/busybox --install -s /sbin

# TCP fastopen
echo 3 > /proc/sys/net/ipv4/tcp_fastopen

# VM tweaks
echo 33 > /proc/sys/vm/vfs_cache_pressure
echo 90 > /proc/sys/vm/dirty_ratio

# CFS Scheduler Knobs
# echo 1000000 > /proc/sys/kernel/sched_latency_ns
# echo 100000 > /proc/sys/kernel/sched_min_granularity_ns
# echo 25000 > /proc/sys/kernel/sched_wakeup_granularity_ns
