#---------------------------------------
# tuyu common liblary
#---------------------------------------
readonly SCRIPT_PATH=$0
readonly SCRIPT_DIR=$(cd $(dirname $0);pwd)
readonly SCRIPT_NAME=$(basename $0)
readonly RETURN_CODE_ERRMAX=200
readonly RETURN_CODE_DEBUG=201
readonly RETURN_CODE_ABORT=202
readonly TCOMMON_VER="0.0.1"
function tcommon_version(){
    echo "tcommon: ${TCOMMON_VER}"
}
#######################################
# Utility functions
#######################################
 
# 色付きの echo
function colored_echo() {
  local color_name color
  color_name="$1"
  shift
  case $color_name in
    red) color=31 ;;
    green) color=32 ;;
    yellow) color=33 ;;
    *) error_exit "An undefined color was specified." ;;
  esac
  printf "\033[${color}m%b\033[m\n" "$*"
}
 
# 赤文字でエラーメッセージを表示
function error_echo() {
  local message=$1
  colored_echo red "[ERROR] ${message}" >&2
}

#---------------------------------------
function confirm_Yn(){
  local msg="ko?"
  [[ $# -eq 1 ]] && msg=$1
  echo -n "${msg} [Y/n]: "
  local ans
  read ans

  case $ans in
    "" | [Yy]* )
    return 0
      ;;
    * )
      ;;
  esac
  return 1
}
#---------------------------------------
function confirm_yN(){
  local msg="ko?"
  [[ $# -eq 1 ]] && msg=$1
  echo -n "${msg} [y/N]: "
  local ans
  read ans

  case $ans in
    [Yy]* )
    return 0
      ;;
    * )
      ;;
  esac
  return 1
}
#---------------------------------------
function pause(){
  echo -n "press any key to continue. "
  local ans
  read ans
}
#---------------------------------------
function print_exit_code(){
  local exit_code=$1
  local print_code=$1
  if [[ $exit_code -ne 0 ]]; then
    print_code="\e[31m${exit_code}\e[m"
  fi
  echo -e "exit code(${print_code})" >&2
}
#---------------------------------------
function debug_break_Yn(){
  echo -n "break? [Y/n]: "
  local ans
  read ans

  case $ans in
    "" | [Yy]* )
    return 0
      ;;
    * )
      ;;
  esac
  return 1
}

#######################################
# for LXD functions
#######################################
function is_lxd_container_exist(){
  local cnt_name=$1
  if (lxc list -c n -f csv | grep "^${cnt_name}$" > /dev/null 2>&1) ; then
    return 0
  fi
  return 1
}
function is_lxd_container_running(){
  local cnt_name=$1
  if (lxc list -c ns -f csv | grep "^${cnt_name},RUNNING$" > /dev/null 2>&1) ; then
    return 0
  fi
  return 1
}
#---------------------------------------

