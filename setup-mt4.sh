#!/usr/bin/env bash
set -euo pipefail
#---------------------------------------
# $1: env src path(/mnt/hdd01/tuyu-env/mt4-env)
# $2: user name
#---------------------------------------

function make_shortcut_file() {
  local share_path=$(dirname "$1")
  local env_name=$(basename "$1")
  local usr_name=$(echo ${share_path} | sed "s|^/home/||" | sed "s|/.*$||")
  local exe_path="./${env_name}/terminal.exe"
  echo "cd \"${share_path}\"" > "/home/${usr_name}/${env_name}.sh"
  echo "wine \"${exe_path}\"" >> "/home/${usr_name}/${env_name}.sh"
  chown ${usr_name}:${usr_name} "/home/${usr_name}/${env_name}.sh"
  chmod u+x "/home/${usr_name}/${env_name}.sh"
}

function main() {
  local src_path=$1
  local usr_name=$2
  
  if [ ! -d "$src_path" ]; then
    echo "ERR: [${src_path}] is not exist"
    exit 1
  fi

  local share_org="/home/${usr_name}/.wine/drive_c/Program Files (x86)"
  if [ ! -d "$share_org" ]; then
    echo "ERR: wine enviroment is not exist"
    exit 1
  fi
  
  local share_path="${share_org}/mt4-env"
  if [ ! -d "$share_path" ]; then
    echo "create link: ${share_path}"
    ln -s "${src_path}" "${share_path}"
  fi
  
  local dir
  while read -r dir; do
    if [ -f "${dir}/terminal.exe" ]; then
      make_shortcut_file "${dir}"
    fi
  done < <(find "${share_path}/" -mindepth 1 -maxdepth 1 -type d)  
}
main $@

