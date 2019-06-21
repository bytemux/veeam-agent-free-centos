#!/bin/bash
source $(dirname "$0")/job-config.sh

# announce job start
announce="
>> BACKUP: $hostname $jobname AT $(date +"%Y-%m-%d_%H:%M:%S")
"
echo "$announce" >> $logfile

# mount share
$script_dir/kesl.sh stop            # Option: Stop Kaspersky before running Veeam
$script_dir/vpn.sh start            # Option: Share is not local, available via OpenVPN
$script_dir/mount.sh start          # Option: Share is not local, connect with SMB

mount_status=$(cat $mount_statefile | cut -d ":" -f2)
vpn_status=$(cat $vpn_statefile | cut -d ":" -f2)

# start veeam
if [ "$mount_status" == "success" ]; then
    error=">> Veeam job was started ok"
    veeamconfig job start --name "$jobname"
    # wait for job to finish
    while [ $(veeamconfig session list | grep -i "running" | wc -l) == 1 ]; do sleep 5; done

    # check if veeam did OK
    #[25.07.2018 02:04:01] <140529559693056> lpbcore| JOB STATUS: SUCCESS.
    latestlog=/var/log/veeam/Backup/$jobname/$(ls -t /var/log/veeam/Backup/$jobname/ | head -1)/Job.log
    veeam_result=$(cat $latestlog | grep -E -a "JOB STATUS" )
    #cut "SUCCESS", or any word in it's place
    veeam_status=$(cat $latestlog | grep -E -a "JOB STATUS:" | awk '{print $7}' | rev | cut -c2- | rev )

else
   error=">> Veeam job was not started, check vpn.sh, mount.sh"
   veeam_status="NOT STARTED"
fi

# write log
log="
mount_status:$mount_status
vpn_status:$vpn_status
$error
---
Veeam result:
$veeam_result
--
Veeam repository at $backup_folder:
$(ls -lh "$backup_folder")
--
Local backups at $local_backups:
$(ls -lh "$local_backups")
--
"
echo "$log" >> $logfile

# send mail
mail="From: $hostname <from@domain.com>
Subject: [VeeamLinuxBackup - $veeam_status] $hostname $jobname

$announce
$log
"
echo "$mail" | msmtp --file $script_dir/msmtp.conf -t to@domain.com

# Clear before exit
$script_dir/mount.sh stop
$script_dir/vpn.sh stop
$script_dir/kesl.sh start

