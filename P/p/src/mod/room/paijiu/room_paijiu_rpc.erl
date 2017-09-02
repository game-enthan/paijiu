%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 六月 2017 15:47
%%%-------------------------------------------------------------------
-module(room_paijiu_rpc).
-author("Administrator").

%% API
-export([handle/3]).

-include("role.hrl").
-include("room.hrl").
-include("public_ets.hrl").
-include("cli_erl_proto/pb_20_room_tuiduizi_pb.hrl").
-include("common.hrl").

%%下注操作
handle(20003, #pbchip{chip_num = Chipnum}, #role{id = RoleId, room_pid = RoomPid}) when is_pid(RoomPid) ->
    io:format("to outer interface,下注操作........."),
    room_paijiu:chipin(RoomPid, RoleId, Chiptype, Chipnum),
    {ok};


%% 退出结算界面
handle(20008, _, #role{id = RoleId, room_pid = RoomPid}) when is_pid(RoomPid) ->
    room_paijiu:exit_calc(RoomPid, RoleId),
    {ok};

%% 房主开始游戏
handle(20013, _, #role{id = RoleId, room_id = RoomId, room_pid = RoomPid}) ->
    io:format("to outer interface,房主开始游戏.............."),
    case ets:lookup(?ETS_ROOM, RoomId) of
        [Room = #room{owner_id = RoleId, pid = RoomPid, is_start = false}] ->
            ets:insert(?ETS_ROOM, Room#room{is_start = true}),
            room_paijiu:start_game(RoomPid);
        _ ->
            ?ERR("房主开始游戏失败，没有找到对应房间，RoleId:~w, RoomId:~w, RoomPid:~w", [RoleId, RoomId, RoomPid]),
            skip
    end,
    {ok};

%% 玩家坐下操作
handle(20014, _, #role{id = RoleId, room_pid = RoomPid}) ->
    io:format("to outer interface,玩家坐下操作.............."),
    room_paijiu:sit_down(RoomPid, RoleId),
    {ok};
%% 庄家开牌
handle(20018, _, #role{id = RoleId, room_pid = RoomPid}) ->
    io:format("to outer interface,房主庄家开牌.............."),
    room_paijiu:open_mahjongs(RoomPid, RoleId),
    {ok};
handle(_OpCode, _Data, _Role) ->
     io:format("to outer interface,没处理.............."),
    ?DEBUG("没处理，OpCode:~w,Data:~w", [_OpCode, _Data]),
    {ok}.
