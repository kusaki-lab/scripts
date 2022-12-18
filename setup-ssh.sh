#!/usr/bin/env bash
set -Ceuo pipefail

#---------------------
# ssh setup
# $1:   remote name
#---------------------
function confirm_config_edit(){
  echo "Edit ssh .config file?"
  read -p "ok?[y/N]>" ans; [[ ! $ans =~ ^$|(^N|n$) ]] && vi "${HOME}/.ssh/config"
}

function copy_id(){
    SRC_FILE=~/.ssh/$(hostname)/id_*.pub
    TERGET_DIR='~/.ssh'
    TERGET_FILE=${TERGET_DIR}/authorized_keys
    echo $SRC_FILE
    echo $TERGET_DIR
    echo $TERGET_FILE
    CMD="mkdir -p ${TERGET_DIR} && \
         touch ${TERGET_FILE} && \
         chmod -R go= ${TERGET_DIR} && \
         cat >> ${TERGET_FILE}"
    echo $CMD
    if ! cat $SRC_FILE | ssh -oStrictHostKeyChecking=no $1 $CMD; then
        ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${1}.local"
        # retry
        cat $SRC_FILE | ssh -oStrictHostKeyChecking=no $1 $CMD
    fi
}

function close_passwd_login(){
    TERGET_FILE="/etc/ssh/sshd_config"
    NEW_LINE="PasswordAuthentication no"
    CMD="cat $TERGET_FILE | sudo tee ${TERGET_FILE}.bak > /dev/null && \
        echo ${NEW_LINE} | sudo tee -a ${TERGET_FILE} > /dev/null && \
        sudo systemctl restart ssh"
    echo $CMD
    ssh $1 $CMD
}

function main(){
    REMOTE_NAME=$1
    confirm_config_edit
    copy_id ${REMOTE_NAME}
    close_passwd_login ${REMOTE_NAME}
}

main $@
