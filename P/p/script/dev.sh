#!/bin/bash

# 主节点相关设置
MASTER_NAME=master
MASTER_DOMAIN=server.dev
MASTER_PORT=9123
# 网关服节点设置
LOGIN_NAME=login
LOGIN_DOMAIN=server.dev
LOGIN_PORT=9000

# erl节点间通讯端口
ERL_PORT_MIN=60001
ERL_PORT_MAX=60100


if [ x$1 != x ]
then
    case $1 in
        "start")
            cd ../ebin
            erl -hidden -kernel inet_dist_listen_min $ERL_PORT_MIN -kernel inet_dist_listen_max $ERL_PORT_MAX +P 204800 +K true -smp enable -name $MASTER_NAME@$MASTER_DOMAIN -mnesia dir '"../var/mnesia"' -pa ../config -config ../config/server_game -s server start -extra $MASTER_PORT
            ;;
        "start_login")
            cd ../ebin
            erl -hidden -kernel inet_dist_listen_min $ERL_PORT_MIN -kernel inet_dist_listen_max $ERL_PORT_MAX +P 204800 +K true -smp enable -name $LOGIN_NAME@$LOGIN_DOMAIN -pa ../config -config ../config/server_login -s server start -extra $LOGIN_PORT
            ;;
        "stop")
            cd ../ebin
            erl -kernel inet_dist_listen_min $ERL_PORT_MIN -kernel inet_dist_listen_max $ERL_PORT_MAX -name $MASTER_NAME"_stop"@$MASTER_DOMAIN -pa ../config -config ../config/server_other -s server stop_from_shell -extra $MASTER_NAME@$MASTER_DOMAIN
            ;;
        "hotload")
            cd ../ebin
            erl -kernel inet_dist_listen_min $ERL_PORT_MIN -kernel inet_dist_listen_max $ERL_PORT_MAX -name $MASTER_NAME"_hotload"@$MASTER_DOMAIN -pa ../config -config ../config/server_other -s server_hotload reload -extra $MASTER_NAME@$MASTER_DOMAIN
            ;;
        *)
            ;;
    esac
else
    tips
fi
