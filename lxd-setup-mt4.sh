#!/usr/bin/env bash
set -Ceuo pipefail
source tcommon.sh


#---------------------------------------
# 
#---------------------------------------
OPT_STRING=h
function usage(){
cat <<EOF
USAGE:
  ${SCRIPT_NAME} [-${OPT_STRING}] <contname> <username>

    <contname>:     cont name
    <username>:     user name   [default: ubuntu]

  options
    -h        :     show help

EOF
}
#---------------------------------------
function validate_parameters() {
  set +u
  CNT_NAME=$1
  USR_NAME=$2
  set -u

  if [[ $CNT_NAME = "" ]]; then
    error_echo "<contname> must be specified!!"
    exit 21
  fi

  if [[ $USR_NAME = "" ]]; then
    USR_NAME="ubuntu"
  fi

  echo "-- <contname>: ${CNT_NAME}"
  echo "-- <username>: ${USR_NAME}"

  if ! is_lxd_container_exist ${CNT_NAME} ; then
    error_echo "ERR: No contaner such as $CNT_NAME"
    exit 22
  fi
  echo "container <${CNT_NAME}> is exist."

  if ! is_lxd_container_running ${CNT_NAME} ; then
    error_echo "ERR: Contaner $CNT_NAME is not RUNNING"
    exit 23
  fi
  echo "container <${CNT_NAME}> is running."
}
#---------------------------------------
function main(){

  # create share folder
  local SRC_PATH=/mnt/hdd01/tuyu-env/mt4-env
  local DST_PATH=/mnt/mt4-env
  lxc config device add ${CNT_NAME} mt4-share disk source=${SRC_PATH} path=${DST_PATH}

  # run setup script
  local setup_script="setup-mt4.sh"
  scp "${SCRIPT_DIR}/${setup_script}" ${CNT_NAME}:
  ssh ${CNT_NAME} "sudo -s ./${setup_script} ${DST_PATH} ${USR_NAME}"
  ssh ${CNT_NAME} "rm ./${setup_script}"

}
#---------------------------------------
function entry_point() {
  local params
  params=$(validate_options $@)
  validate_parameters $params
  ! confirm_yN "continue?" && exit $RETURN_CODE_ABORT
  main
}

#---------------------------------------
function validate_options(){
  while getopts :${OPT_STRING} opt; do
    case $opt in
     h)
      usage >&2
      exit 10
      ;;
     *)
      error_echo "option [-$OPTARG] is not defined...."
      exit 11
      ;;
    esac
  done
  # コマンドライン引数から、オプション引数分を削除
  shift $((OPTIND - 1))
  echo $@
}
#---------------------------------------
function on_exit() {
  local exit_code=$1
  local print_code=$exit_code
  # do something before exit
  print_exit_code $exit_code
  exit "$exit_code"
}
trap 'on_exit $?' EXIT
entry_point $@

