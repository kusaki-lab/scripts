#!/bin/sh
#_cat bin/setup-japanese.sh | grep "^# " | sed -e 's/^# //' -e 's/<host_name>/test-02/'

#_CMD:scp ~/bin/setup-japanese.sh <host_name>:
#_CMD:ssh -t <host_name> "sudo -s ./setup-japanese.sh"
#_CMD:ssh <host_name> "rm ./setup-japanese.sh"

if [ `id -u` -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

apt update
apt install -y gnupg wget
wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
wget https://www.ubuntulinux.jp/sources.list.d/focal.list -O /etc/apt/sources.list.d/ubuntu-ja.list
apt update -y && apt upgrade -y && apt install -y ubuntu-defaults-ja
dpkg-reconfigure tzdata
update-locale LANG=ja_JP.UTF-8

