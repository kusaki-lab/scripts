#!/usr/bin/env bash
set -Ceuo pipefail
#---------------------------------------
# 
#---------------------------------------
function main(){
  # check ubuntu
  if !(lsb_release -i|grep Ubuntu > /dev/null 2>&1); then
    echo Not Ubuntu.
    exit 1
  fi

  # check codename
  local codename=$(lsb_release -c | sed "s/Codename:[ \t]*//")
  
  case $codename in
  kinetic)
    url=https://dl.winehq.org/wine-builds/ubuntu/dists/kinetic/winehq-kinetic.sources
    ;;
  jammy)
    url=https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
    ;;
  focal)
    url=https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
    ;;
  bionic)
    url=https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/winehq-bionic.sources
    ;;
  *)
    echo "unknown codename [$codename]"
    exit 1
    ;;
  esac

  echo -e "Codename:\t$codename"
  echo $url
  read -p "ok?[y/N]>" ans; [[ ! $ans =~ (^Y|y$) ]] && exit

  # install
  dpkg --add-architecture i386
  mkdir -pm755 /etc/apt/keyrings
  wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
  wget -NP /etc/apt/sources.list.d/ $url
  apt update
  apt install -y --install-recommends winehq-stable
  wine --version
}
#---------------------------------------
main

