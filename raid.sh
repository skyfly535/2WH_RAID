#!/bin/bash
# скрипт создания RAID 5 из 4 блочных устройств
mdadm --zero-superblock --force /dev/sd{b,c,d,e}
mdadm --create --verbose /dev/md0 -l 5 -n 4 /dev/sd{b,c,d,e}
cd /etc
mkdir mdadm
cd /mdadm
touch mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 30%
parted /dev/md0 mkpart primary ext4 30% 60%
parted /dev/md0 mkpart primary ext4 60% 100%
for i in $(seq 1 3); do sudo mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3}
for i in $(seq 1 3); do mount /dev/md0p$i /raid/part$i; done
exit 0