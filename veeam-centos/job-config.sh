#
# User variables
#
# Vpn & share credentials
auth_user="hostname_backup"
auth_password="INSERT_PASSWORD"

# share location
remote_host="10.1.1.1"                      # only for centos 6.x
remote_mount="//$remote_host/$auth_user/"   # only for centos 6.x
mount_unit="mnt-veeamrepo.mount"            # only for centos 7.x

# local
local_backups="/opt/backup"         # list host local backups in report


#
# Script variables
#
jobname="full"                      # MUST match job name in VEEAM
mount_folder="/mnt/veeamrepo"       # repo mount folder
hostname=$(hostname)
script_dir=$(dirname "$0")
logfile="$script_dir/veeam-centos.log"
# Veeam backup location
backup_folder="$mount_folder/$hostname $jobname"
# backup_folder resulting path: /mnt/veeamrepo/hostname.domain.local full
#                               ^ mount point    ^ hostname         ^ jobname
vpn_statefile="/tmp/vpn_statefile"
mount_statefile="/tmp/mount_statefile"

# Detect init system
rpm --quiet --query systemd; if [ $? == 0 ]; then systemd=true; else systemd=false; fi
