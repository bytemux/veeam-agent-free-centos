#!/bin/bash
source $(dirname "$0")/job-config.sh
vpn_conf="$script_dir/vpn.conf"
vpn_auth="$script_dir/vpn-auth"

function connect_vpn() {
  # Generate auth file for vpn
  echo -e "$auth_user\n$auth_password\n" >> $vpn_auth
  chmod 600 $vpn_auth
  # Start VPN
  openvpn --config $vpn_conf --auth-user-pass $vpn_auth &
  sleep 3

  # Cleanup
  rm $vpn_auth

  # Check if vpn did OK
  if ping -c 1 $remote_host &> /dev/null
  then
      echo -e "vpn_status:success" > $vpn_statefile
  else
      echo -e "vpn_status:failure" > $vpn_statefile
  fi
}

function disconnect_vpn() {
  kill $(pgrep -f $vpn_conf)
  rm -f $vpn_statefile
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
  connect_vpn
  shift
  ;;
  stop)
  disconnect_vpn
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
