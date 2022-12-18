#!/bin/bash

echo "enter password for $1"
passwd $1 #<PASSWORD>
apt update
apt -y upgrade
apt -y install\
  bash-completion\
  openssh-server\
  avahi-daemon\
  ufw
ufw enable
ufw allow ssh
rm $0
exit
