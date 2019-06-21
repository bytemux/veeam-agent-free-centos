#!/bin/bash
source $(dirname "$0")/job-config.sh

function start_proc() {
systemctl start kesl-supervisor
}

function stop_proc() {
systemctl stop kesl-supervisor
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
  start_proc
  shift
  ;;
  stop)
  stop_proc
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
