%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 五月 2017 20:38
%%%-------------------------------------------------------------------
-author("Administrator").

%% 记录字典索引
-define(DICT_GAMBLING_RECORD(RoleId), {record, RoleId}).

%%%% 回放存放时限
%%-define(RECORD_END_TIME, 2 * 86400).
%%%% 清档间隔时间
%%-define(CLEAN_INTERVAL_TIME, (util:unixtime(tomorrow) + 3600 * 6 - util:unixtime())).
%% 建表间隔时间
-define(CREATE_INTERVAL_TIME, (util:unixtime(tomorrow) - 60 - util:unixtime())).

%% mnesia数据库表名
% -define(MNESIA_PLAYER_RECORD, list_to_atom(lists:concat([mnesia_player_record, "_", util:unixtime(today)]))).
-define(MNESIA_PLAYER_RECORD, list_to_atom(lists:concat([mnesia_player_record, "_", util:get_now_time()]))).
%% 前一天mnesia数据库表名
-define(FORMER_MNESIA_PLAYER_RECORD, list_to_atom(lists:concat([mnesia_player_record, "_", util:unixtime(today) - 86400]))).
%% 后一天mnesia数据库表名
-define(LATTER_MNESIA_PLAYER_RECORD, list_to_atom(lists:concat([mnesia_player_record, "_", util:unixtime(tomorrow)]))).

%% 回放记录数据
-record(player_record, {
    player_id = 0,
    max_record_id = 1,              %% 最大记录id
    max_round_id = 1,               %% 最大牌局id
    type_record_list = []           %% 玩法记录列表 [#type_record{}, ...]
}).

%% 玩法记录
-record(type_record, {
    play_type = 0,                   %% (101 = 斗牛，102 = 金花)
    room_record_list = []            %% 房间记录列表 [#room_record{}, ...]
}).

%% 房间回放记录
-record(room_record, {
    record_id = 0,                   %% 记录id
    room_id = 0,                     %% 房间id
    time = 0,                        %% 房间结束时间
    player_list = [],                %% 玩家记录列表 [#record_player{}, ...]
    round_record_list = []           %% 牌局回放记录列表 [#round_record{}, ..]
}).

%% 牌局回放记录
-record(round_record, {
    round_id = 0,                    %% 牌局id
    room_id = 0,                    %% 房间id
    round = 0,                      %% 第几局
    time = 0,                       %% 牌局结束时间
    player_list = [],               %% 玩家记录列表 [#record_player{}, ...]
    proto_list = []                %% 协议消息列表 [#record_proto{}, ...]
}).

%% 记录中的玩家信息
-record(record_player, {
    player_id = 0,                   %% 玩家id
    player_name = <<"">>,           %% 玩家名字
    score = 0                      %% 分数
}).

%% 回放协议消息
-record(record_proto, {
    id,
    opcode = 0,                      %% 协议号
    data = {}                      %% 协议消息数据
}).