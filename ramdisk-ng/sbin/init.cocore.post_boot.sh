#!/system/bin/sh

LOG=/init.log

exec >> ${LOG} 2>&1

if [ -e ${LOG} ]; then
  # Mark init log global readable
  chmod 0644 ${LOG}
fi

# Remove splash logo to save some memory
BOOTLOGO=/res/logo.raw
if [ -f ${BOOTLOGO} ]; then
  rm ${BOOTLOGO}
fi

# Remove su.img.xz to save some memory
rm /lib/supersu/su.img.xz

#
# CPUFreq Settings: board: msm8952, soc_id: 266
#

# Disable thermal & BCL core_control to update interactive gov settings
echo 0 > /sys/module/msm_thermal/core_control/enabled
  for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
  echo -n disable > $mode
done

for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
  bcl_hotplug_mask=`cat $hotplug_mask`
  echo 0 > $hotplug_mask
done

for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
  bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
  echo 0 > $hotplug_soc_mask
done

for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
  echo -n enable > $mode
done

# RCU threads: Set affinity (offload) to power cluster
for i in {0,1,2,3,4,5}; do
  RCU_PID=`ps | grep "rcuop/$i" | cut -b 11-16`
  taskset -a -p 0f ${RCU_PID}

  RCU_PID=`ps | grep "rcuob/$i" | cut -b 11-16`
  taskset -a -p 0f ${RCU_PID}

  RCU_PID=`ps | grep "rcuos/$i" | cut -b 11-16`
  taskset -a -p 0f ${RCU_PID}
done

# Set cpu_boost parameters
echo "0:1305600" > /sys/module/cpu_boost/parameters/input_boost_freq
echo "40" > /sys/module/cpu_boost/parameters/input_boost_ms
echo 9 > /proc/sys/kernel/sched_upmigrate_min_nice

# Set (super) packing parameters
echo 1017600 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_freq
echo 0 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_freq

# Disallow upmigrate for cgroup's tasks
echo 1 > /dev/cpuctl/bg_non_interactive/cpu.upmigrate_discourage

# HMP Scheudler Settings
echo 200000 > /proc/sys/kernel/sched_freq_inc_notify

# CPU Governor Settings: power cluster
echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo 1017600 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
echo 10000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads

# CPU Governor Settings: perf cluster
echo "19000 1382400:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo 1382400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
echo "90 1747200:80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
echo 10000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack

# Re-Enable thermal & BCL core_control now
echo 1 > /sys/module/msm_thermal/core_control/enabled
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
  echo -n disable > $mode
done

for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
  echo $bcl_hotplug_mask > $hotplug_mask
done

for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
  echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
done

for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
  echo -n enable > $mode
done

# Start Perfd service
start perfd

# CPUQuiet Governor Settings
echo 2 > /sys/devices/system/cpu/cpuquiet/nr_min_cpus
echo rqbalance > /sys/devices/system/cpu/cpuquiet/available_governors

#
# CPUFreq Settings: end
#

# Block queue scheduler
echo fiops > /sys/block/mmcblk0/queue/scheduler
echo fiops > /sys/block/mmcblk1/queue/scheduler

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
echo 1000000 > /proc/sys/kernel/sched_latency_ns
echo 100000 > /proc/sys/kernel/sched_min_granularity_ns
echo 25000 > /proc/sys/kernel/sched_wakeup_granularity_ns

# System UI Sched FIFO Class
#setprop sys.use_fifo_ui 1
