#!/bin/bash
source $(dirname "$0")/job-config.sh

function mount_share() {
  mkdir -p $mount_folder

  if $systemd
  then
    systemctl start $mount_unit
  else
    # for centos 6.x: only vers=1.0 works, so do not specify anything
    mount -t cifs $remote_mount $mount_folder --verbose -o username=$auth_user,password=$auth_password,rw
  fi

  # check if mount did OK
  if  [ $? -eq 0 ]
  then
      echo -e "mount_status:success" > $mount_statefile
  else
      echo -e "mount_status:failure" > $mount_statefile
  fi
}

function umount_share() {
  sleep 3
  if $systemd
  then
    systemctl stop $mount_unit
  else
    umount -f $mount_folder
  fi
  rm -f $mount_statefile
}

function help_menu() {
  cat << EOF
  Usage: ${0} (-h | start | stop )
  #launch options
  -h|--help
  start
  stop
EOF
}

while [[ $# > 0 ]]
do
case "${1}" in
  start)
  mount_share
  shift
  ;;
  stop)
  umount_share
  shift
  ;;
  -h|--help)
  help_menu
  shift
  ;;
  *)
  echo "${1} is not a valid flag, try running: ${0} --help"
  exit 1
  ;;
esac
shift
done
