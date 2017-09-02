%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 五月 2017 21:50
%%%-------------------------------------------------------------------
-module(lib_player_room).
-author("Administrator").

%% API
-export([
    create_room_success/5,
    exit_room/1,
    api_cost_card/14,
    api_exit_room/1,
    api_agent_cost_card/5,
    cost_card/2,
    api_close_agent_room/1,
    close_agent_room/1
]).

-include("role.hrl").
-include("cli_erl_proto/pb_10_login_pb.hrl").
-include("common.hrl").

%%===============================
%% API
%%===============================
api_cost_card(PlayerId, PlayerName, Icon, RPid, RoomId, RoomType, Score, BalanceScore, BalanceScore2, WinNum, CreateTime, CostCardNum, IsAgentRoom, Round) ->
    case IsAgentRoom of
        false -> 
            log:gambling_log(PlayerId, RoomId, Score, RoomType, CreateTime);
        _ -> 
            log:agent_gambling_log(PlayerId, RoomId, Score, RoomType, CreateTime)
    end,
    case role_db:reduce_room_card(PlayerId, CostCardNum) of
        {ok, RemainNum} ->
            log:room_card_log(PlayerId, lists:concat([RoomId, "房间消耗"]), -CostCardNum, RemainNum);
        _ ->
            skip
    end,
    case role_db:update_gambling_result(PlayerId, Score, BalanceScore, BalanceScore2, WinNum, Round) of
        {ok, TotalScore, TotalWinNum} ->
            activity:insert_rank(PlayerId, PlayerName, Icon, TotalScore, TotalWinNum);
        _ ->
            skip
    end,
    role_new:apply(async, RPid, {lib_player_room, cost_card, [CostCardNum]}).

api_exit_room(RPid) ->
    role:apply(async, RPid, {lib_player_room, exit_room, []}).

api_agent_cost_card(PlayerId, RoomId, CostCardNum, RoundNum, Content) ->
    case role_db:reduce_room_card(PlayerId, CostCardNum) of
        {ok, RemainCard} ->
            log:room_card_log(PlayerId, lists:concat([RoomId, "房间消耗"]), -CostCardNum, RemainCard),
            log:agent_room_record_log(RoomId, PlayerId, RoundNum, CostCardNum, RemainCard, util:unixtime(), Content);
        _ ->
            skip
    end,
    case role_mgr:get_role_pid(PlayerId) of
        false ->
            ?ERR("玩家不再线  PlayerId:~w",[PlayerId]);
        RolePid ->
            role_new:apply(async, RolePid, {lib_player_room, cost_card, [CostCardNum]})
    end.

api_close_agent_room(PlayerId) ->
    role_db:reduce_agent_num(PlayerId, 1),
    case role_mgr:get_role_pid(PlayerId) of
        false ->
            ?ERR("玩家不再线  PlayerId:~w",[PlayerId]);
        RolePid ->
            role_new:apply(async, RolePid, {lib_player_room, close_agent_room, []})
    end.

%%==============================
%% 玩家进程异步调用
%%==============================
create_room_success(Role = #role{agent_room_num = Num}, RoomId, RoomPid, RoomType, IsAgentRoom) ->
    case IsAgentRoom of
        false ->
            role_db:update_room_id(Role#role.id, RoomId),
            {ok, Role#role{room_id = RoomId, room_pid = RoomPid, room_type = RoomType}};
        _ ->
            {ok, Role#role{agent_room_num = Num + 1}}
    end.

exit_room(Role) ->
    role_db:update_room_id(Role#role.id, 0),
    {ok, Role#role{room_id = 0, room_type = 0, room_pid = 0}}.

cost_card(Role = #role{room_card = RoomCard, room_card_cost = RoomCardCost, connpid = ConnPid}, CostCardNum) ->
    RoomCard2 = RoomCard - CostCardNum,
    RoomCard3 = ?IIF(RoomCard2 > 0, RoomCard2, 0),
    % lib_send:send_async(ConnPid, 10009, #pbplayerroomcard{room_card = RoomCard3}),
    lib_send:send_data(ConnPid, 10009, #pbplayerroomcard{room_card = RoomCard3}),
    {ok, Role#role{room_card = RoomCard3, room_card_cost = RoomCardCost + CostCardNum}}.

close_agent_room(Role = #role{agent_room_num = Num}) ->
    Num2 = Num - 1,
    {ok, Role#role{agent_room_num = ?IIF(Num2 > 0, Num2, 0)}}.