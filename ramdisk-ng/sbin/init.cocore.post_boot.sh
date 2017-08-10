#!/system/bin/sh

LOG=/init.log

exec >> ${LOG} 2>&1

if [ -e ${LOG} ]; then
  # Mark init log global readable
  chmod 0644 ${LOG}
fi

# TCP fastopen
echo 3 > /proc/sys/net/ipv4/tcp_fastopen

# Set cpu_boost parameters
echo "0:1305600" > /sys/module/cpu_boost/parameters/input_boost_freq
echo "40" > /sys/module/cpu_boost/parameters/input_boost_ms
echo 9 > /proc/sys/kernel/sched_upmigrate_min_nice

# Set (super) packing parameters
echo 1017600 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_freq
echo 0 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_freq

# Ensure 512 kb read-ahead setting
# echo 512 > /sys/block/dm-0/queue/read_ahead_kb
# echo 512 > /sys/block/dm-1/queue/read_ahead_kb
# echo 512 > /sys/block/mmcblk0/queue/read_ahead_kb

# Disallow upmigrate for cgroup's tasks
echo 1 > /dev/cpuctl/bg_non_interactive/cpu.upmigrate_discourage

# Changes to optimize performance and power consumption
echo 200000 > /proc/sys/kernel/sched_freq_inc_notify

# Changes to optimize performance and power consumption
echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo "19000 1382400:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo 1017600 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo 1382400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
echo "90 1747200:80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
echo 10000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 10000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
