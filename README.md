# smartos-nfs-backup
Bash script to backup all your smartos (kvm) VMs to a nfs share

Be aware:
- Script enables (and disable!) automount on your smartos machine.
- Does not backup your smartos zones
- @backup for zfs snapshot might collide with your own snapshots (set in line 29)
