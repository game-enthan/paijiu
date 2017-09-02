%%%-------------------------------------------------------------------
%%% @author jolee
%%% @copyright (C) 2016, 105326073@qq.com
%%% @doc
%%%
%%% @end
%%% Created : 11. 四月 2016 10:05
%%%-------------------------------------------------------------------
-author("jolee").

-define(RECV_HEAD_TIME_OUT, 6000).
-define(RECV_TIME_OUT, 6000).
-define(HEART_BEAT_TIME_OUT, 3).   %% 心跳频率
-define(LOGIN_MSG_TIME_OUT, 3).   %% 登录消息超时

-define(PACKET_HEAD_SIZE, 4).
-define(PACKET_LEN_BIT, 16).
-define(OPCODE_LEN_BIT, 16).
-define(SOCKET_ACTIVE, 300).

-define(DICT_LAST_HEARTBEAT, last_heartbeat).

-define(PLATFORM_IP_1, {114, 215, 240, 34}).
-define(PLATFORM_IP_2, {101, 37, 89, 244}).
-define(PLATFORM_IP_3, {114, 55, 106, 104}).

-record(conn, {
    role_id      = 0         %% 玩家ID
    ,socket					%%套接字
    ,ip	= <<>>				%%登录ip
    ,plat = 0               %%平台ID
    ,port = 0               %%端口
    ,pack_size = 0			%%需要读取包大小
    ,has_head = false		%%是否已经读取头信息
    ,login = false			%%是否已经登录
    ,opcode = 0				%%消息操作码
    ,role_pid = 0				%%角色进程pid
    ,conn_pid               %%连接进程pid
    ,has_login_msg = false  %% 是否已收到登录消息
    ,server_type = 0    %% 服务器类型
    ,login_conn_pid = 0   %% 登录服连接游戏服进程
    ,login_conn_socket = 0   %% 登录服连接游戏服socket
}).

-record(ranch_conn, {
    socket,          %% 玩家socket 
    transport,
    has_login_msg = false,  %% 是否已收到登录消息
    role_id = 0,     %% 玩家id
    role_pid = 0,    %% 玩家进程pid
    ip = <<>>,       %% ip地址
    port = 0,        %% 端口
    plat = 0,        %% 平台id
    conn_pid         %% 玩家连到网关的socket的控制进程
}).