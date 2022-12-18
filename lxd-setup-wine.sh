#!/usr/bin/env bash
set -Ceuo pipefail
source tcommon.sh


#---------------------------------------
#
#---------------------------------------
OPT_STRING=h
function usage(){
cat <<EOF
Usage:
  ${SCRIPT_NAME} [-${OPT_STRING}] <contname>

Params:
  <contname>:     cont name

Options:
  -h        :     show help

EOF
}
#---------------------------------------
function validate_parameters() {
  set +u
  CNT_NAME=$1
  set -u

  if [[ $CNT_NAME = "" ]]; then
    error_echo "<contname> must be specified!!"
    exit 21
  fi
  echo "-- <contname>: ${CNT_NAME}"

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


function main() { 
  local setup_script="setup-wine.sh"
  scp "${SCRIPT_DIR}/${setup_script}" ${CNT_NAME}:
  ssh -t ${CNT_NAME} "sudo -s ./${setup_script}"
  ssh ${CNT_NAME} "rm ./${setup_script}"
  confirm_Yn
  ssh ${CNT_NAME} 'DISPLAY=:0 notepad'
  #---------------------------------------------------------------
  # guiコンテナ バックアップ
  lxc snapshot ${CNT_NAME} wine-bak
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

