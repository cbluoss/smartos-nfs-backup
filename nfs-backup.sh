#!/usr/bin/bash
# Backup all (kvm) virtual machines (disks+json data) on a SmartOS hypervisor
# Intended for nfs/remote backups (if you want to keep them locally, stick to zfs snapshots)
# Original Author:  russell@ballestrini.net http://russell.ballestrini.net/
# Author: Yourcoke 
# E-Mail: deinkoks@gmail.com
# Version 0.11
# This Version does not use vmadm send but use zfs send instead


# Backup directory without trailing slash
backupdir=/net/HOSTNAMEorIP/backups/smartos/vms

tmpdir=/opt/tmp

svcadm enable autofs

for VM in `vmadm list -p -o alias,uuid`
  do
    # create an array called VM_PARTS splitting on ':'
    IFS=':' VM_PARTS=($VM)

    # create some helper varibles for alias and uuid
    alias=${VM_PARTS[0]}
    uuid=${VM_PARTS[1]}
    #zfs snapshot 
    echo "Backup started for $VM"
    vmadm get $uuid > $backupdir/$alias-$uuid.json
    #vmadm send $uuid > $tmpdir/$alias
    IFS=$'\n'
    i=0
    for disk in `vmadm get ${VM_PARTS[1]}| json disks | grep zfs_filesystem | awk -F \" '{printf "%s@backup\n", $4}'`
    do
        if [[ $disk == *@* ]]
        then
            zfs snapshot $disk
            zfs send $disk > $backupdir/$alias-$uuid-disk$i.zfs
            zfs destroy -r $disk
            ((i++))
        fi
    done

  done

svcadm disable autofs
