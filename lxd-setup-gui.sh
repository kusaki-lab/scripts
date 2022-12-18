#!/usr/bin/env bash
set -Ceuo pipefail
source tcommon.sh

#---------------------------------------------------------------
# コンテナのXサーバとオーディオをホストと共有する
#
# $1: コンテナ名
# $2: ユーザ名
#
#---------------------------------------------------------------

function validate_parameters() {
    set +u
    CNTNAME=$1
    CNTUSER=$2
    set -u
    
    if [[ $CNTNAME = "" ]]; then
        error_echo 'ERR: No cntaner name'
        exit
    fi
    echo "contaner name: $CNTNAME"

    if [[ $CNTUSER = "" ]]; then
        error_echo 'ERR: No cntaner user name'
        exit
    fi
    echo "contaner user: $CNTUSER"

    if  !(lxc list -c n | grep $CNTNAME > /dev/null 2>&1) ; then
        error_echo "ERR: No contaner such as $CNTNAME"
        exit
    fi
    if  !(lxc list -c ns | grep $CNTNAME | grep RUNNING > /dev/null 2>&1) ; then
        error_echo "ERR: Contaner $CNTNAME is not RUNNING"
        exit
    fi
}

function main() { 
    validate_parameters $@
    #---------------------------------------------------------------
    # 共有設定
    #---------------------------------------------------------------
    lxc config set $CNTNAME raw.idmap 'both 1000 1000'

    #---------------------------------------------------------------
    # Xサーバ
    lxc config device add $CNTNAME xorg disk source=/tmp/.X11-unix/X0 path=/tmp/.X11-unix/X0
    lxc exec $CNTNAME -- sh -c "echo export DISPLAY=:0 | tee --append /home/$CNTUSER/.profile"

    #---------------------------------------------------------------
    # オーディオ

    lxc exec $CNTNAME -- sh -c 'apt update && apt install -y pulseaudio sox libsox-fmt-all'
    lxc exec $CNTNAME -- sed -i "s/; enable-shm = yes/enable-shm = no/g" /etc/pulse/client.conf
    lxc exec $CNTNAME -- sh -c "echo export PULSE_SERVER=unix:/tmp/.pulse-native | tee --append /home/$CNTUSER/.profile"
    lxc config device add $CNTNAME pa disk source=/run/user/1000/pulse/native path=/tmp/.pulse-native

    #---------------------------------------------------------------
    # コンテナ再起動
    lxc restart $CNTNAME

    #---------------------------------------------------------------
    # guiコンテナ バックアップ
    lxc snapshot $CNTNAME gui-bak

    #---------------------------------------------------------------
    # 動作テスト
    echo "Do you want to DO TEST?"
    if confirm_Yn ; then
        echo "DO TEST"
        lxc exec $CNTNAME -- sh -c 'apt update && apt install -y x11-apps'
        scp -r ~/Music/sample/ $CNTNAME:
        ssh $CNTNAME 'PULSE_SERVER=unix:/tmp/.pulse-native play ./sample/toujyo.mp3 &'
        ssh $CNTNAME 'DISPLAY=:0 xeyes &'
        lxc restore $CNTNAME gui-bak
    fi
}
main $@



