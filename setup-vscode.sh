#!/bin/bash
# Reference sites
#_cat bin/setup-vscode.sh | grep "^# " | sed -e 's/^# //' -e 's/<host_name>/test-02/'

# scp ./bin/setup-vscode.sh <host_name>:
# ssh <host_name> "sudo -s ./setup-vscode.sh"
# ssh <host_name> "rm ./setup-vscode.sh"

sudo apt update
sudo apt install -y curl gnupg
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y

#-
#-to japanese
#-
#---> click block BTN (side bar extention)
#---> sarch 'japanese'
#---> install 'Japanese lang pack'
#---> restart App
