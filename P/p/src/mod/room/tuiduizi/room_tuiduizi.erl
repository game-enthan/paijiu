%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 六月 2017 18:41
%%%-------------------------------------------------------------------
-module(room_tuiduizi).
-author("Administrator").

-behaviour(gen_fsm).

%% API
-export([
    start/6,
    create_player/12,
    join_in/2,
    start_game/1,
    chipin/4,
    exit_calc/2,
    exit_room_apply/2,
    accept_exit_room/2,
    not_accept_exit_room/2,
    player_offline/2,
    player_return/4,
    chat/3,
    sit_down/2,
    open_mahjongs/2
]).
%%state name
-export([
    state_waiting/2,
    state_start_game/2,
    state_chipin/2,
    state_show/2,
    state_round_calc/2,
    state_final_calc/2,
    state_exit_room_apply/2,
    state_close_room/2
]).
%% gen_fsm callbacks
-export([
    init/1,
    state_name/2,
    state_name/3,
    handle_event/3,
    handle_sync_event/4,
    handle_info/3,
    terminate/3,
    code_change/4
]).

-include("room.hrl").
-include("room_tuiduizi.hrl").
-include("gambling_record.hrl").
-include("public_ets.hrl").
-include("role.hrl").
-include("cli_erl_proto/pb_13_msg_pb.hrl").
-include("cli_erl_proto/pb_11_hall_pb.hrl").
-include("cli_erl_proto/pb_20_room_tuiduizi_pb.hrl").
-include("common.hrl").
-include("error.hrl").

-define(NUM_HALF(N), ?IIF(N =:= 10, 0.5, N)).
-define(NUM_ZERO(N), ?IIF(N =:= 10, 0, N)).

%%%===================================================================
%%% API
%%%===================================================================
%% 创建玩家数据
create_player(RoleId, RPid, Socket, Name, Seat, Icon, Sex, Ip, Gps,_B1,_B2, _Property) ->
    #player_tuiduizi{id = RoleId, pid = RPid, socket = Socket,
    name = Name, seat_id = Seat, icon = Icon, sex = Sex, ip = Ip, gps = Gps}.

%%玩家加入
join_in(RoomPid, Player) ->
    %gen_fsm:send_all_state_event(RoomPid, {join_in, Player}).
    gen_fsm:sync_send_all_state_event(RoomPid, {join_in, Player}, 6000).

%%房主开始游戏
start_game(RoomPid)->
    gen_fsm:send_all_state_event(RoomPid, {start_game}).

%%玩家下注
chipin(RoomPid, Playerid, Chipin_type, Chipin_num) ->
    gen_fsm:send_all_state_event(RoomPid, {chipin,Playerid, Chipin_type, Chipin_num}).

%%退出结算界面操作
exit_calc(RoomPid, Playerid) ->
    gen_fsm:send_all_state_event(RoomPid, {exit_calc, Playerid}).

%%申请解散房间
exit_room_apply(RoomPid, Playerid) ->
    gen_fsm:send_all_state_event(RoomPid, {exit_room_apply, Playerid}).

%%同意解散房间
accept_exit_room(RoomPid, Playerid) ->
    gen_fsm:send_all_state_event(RoomPid, {accept_exit_room, Playerid}).

%%不同意解散房间
not_accept_exit_room(RoomPid, Playerid) ->
    gen_fsm:send_all_state_event(RoomPid, {not_accept_exit_room, Playerid}).

%%玩家离线
player_offline(RoomPid, Playerid) when is_pid(RoomPid) ->
    gen_fsm:send_all_state_event(RoomPid, {player_offline, Playerid}).

%%玩家重连操作
player_return(RoomPid, Playerid, PlayerPid, Socket) ->
    gen_fsm:send_all_state_event(RoomPid, {player_return, Playerid, PlayerPid, Socket}).

%%玩家聊天
chat(RoomPid, Playerid, Date) ->
    gen_fsm:send_all_state_event(RoomPid, {chat, Playerid, Date}).

%%玩家坐下
sit_down(RoomPid, Playerid) ->
    gen_fsm:send_all_state_event(RoomPid, {sit_down, Playerid}).

%% 庄家开牌
open_mahjongs(RoomPid, RoleId) ->
    gen_fsm:send_all_state_event(RoomPid, {open_mahjongs, RoleId}).

%%--------------------------------------------------------------------
%% @doc
%% Creates a gen_fsm process which calls Module:init/1 to
%% initialize. To ensure a synchronized start-up procedure, this
%% function does not return until Module:init/1 has returned.
%%
%% @end
%%--------------------------------------------------------------------
-spec(start(_RoomId, _RoomType, _Owner, _Costcardnum, _PayWay, _Property) -> {ok, pid()} | ignore | {error, Reason :: term()}).
start(RoomId, RoomType, Owner, Costcardnum, PayWay, Property) ->
    gen_fsm:start(?MODULE, [RoomId, RoomType, Owner, Costcardnum, PayWay, Property], []).

%%%===================================================================
%%% gen_fsm callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm is started using gen_fsm:start/[3,4] or
%% gen_fsm:start_link/[3,4], this function is called by the new
%% process to initialize.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, StateName :: atom(), StateData :: #room_tuiduizi{}} |
  {ok, StateName :: atom(), StateData :: #room_tuiduizi{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init(Args) ->
    try
        do_init(Args)
    catch
    _:Reason ->
        ?ERR("~p init is exception:~w", [?MODULE, Reason]),
        ?ERR("get_stacktrace:~n~p", [erlang:get_stacktrace()]),
        {stop, Reason}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_event/2, the instance of this function with the same
%% name as the current state name StateName is called to handle
%% the event. It is also called if a timeout occurs.
%%
%% @end
%%--------------------------------------------------------------------
-spec(state_name(Event :: term(), State :: #room_tuiduizi{}) ->
  {next_state, NextStateName :: atom(), NextState :: #room_tuiduizi{}} |
  {next_state, NextStateName :: atom(), NextState :: #room_tuiduizi{},
    timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #room_tuiduizi{}}).
state_name(_Event, State) ->
  {next_state, state_name, State}.
%%房间等待状态
state_waiting(timeout, State) ->
  put(?DICT_PERIOD, ?ROOM_STATE_WAITING),
  next(state_waiting, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = ?STATE_LOOP_TIME});
state_waiting(_Info, State) ->
  %?DEBUG("等待阶段消息处理忽略：~w", [_Info]),
  continue(state_waiting, State).
%%开始游戏状态
state_start_game(timeout, State = #room_tuiduizi{room_id = RoomId, property = #room_tuiduizi_property{banker_type = Bankertype}}) ->
  ?DEBUG("开始游戏阶段"),
  put(?DICT_PERIOD, ?ROOM_STATE_START),
  put(?DICT_HUIFANG_LIST, []),
  broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_START}),
  put(?DICT_ROUND, get(?DICT_ROUND) + 1),
  Playerlist = get(?DICT_PLAYER_LIST),
  Winer = find_winer(Playerlist),
  put(?DICT_PLAYER_LIST, round_init_player_list(get(?DICT_PLAYER_LIST))),
  [record_room_info(Player, State) || Player <- get(?DICT_PLAYER_LIST), Player#player_tuiduizi.is_playing],
  refresh_mahjong_list(),
  broadcast_msg(20016, #pbshaizi{num1 = util:rand(1, 6), num2 = util:rand(1, 6)}),
  % broadcast_msg(20017, #pbchipintime{time = ?CHIP_IN_TIME}),
  broadcast_period_start(20017, {RoomId, get(?DICT_ROOM_PID), #pbchipintime{time = ?CHIP_IN_TIME}}),
  put(?DICT_CHIP_IN_ENDTIME, util:unixtime() + ?CHIP_IN_TIME),
  ?DEBUG("开始下注。。。"),
  case Bankertype of
    1 ->
      broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_XIAZHU}),
      put(?DICT_PERIOD, ?ROOM_STATE_XIAZHU),
      next(state_chipin, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
    2 ->
      case get(?DICT_ROUND) > 1 of
        true ->
          #player_tuiduizi{id = PlayerId} = get_next_player(get(?DICT_ZHUANGJIAID)),
          change_zhuang(PlayerId);
        _ ->
          skip
      end,
      broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_XIAZHU}),
      put(?DICT_PERIOD, ?ROOM_STATE_XIAZHU),
      next(state_chipin, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
    3 ->
      case get(?DICT_ROUND) > 1 of
        true ->
          change_zhuang(Winer#player_tuiduizi.id);
        _ ->
          skip
      end,
      broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_XIAZHU}),
      put(?DICT_PERIOD, ?ROOM_STATE_XIAZHU),
      next(state_chipin, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0})
  end.
%%下注阶段
state_chipin(timeout, State) ->
    %?DEBUG("下注阶段结束。。。"),
    next(state_chipin, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = ?STATE_LOOP_TIME}).
%% 亮牌阶段
state_show(timeout, State = #room_tuiduizi{room_id = RoomId, room_type = RoomType, max_round = MaxRound}) ->
    %?DEBUG("亮牌阶段。。。"),
    PlayerList = get(?DICT_PLAYER_LIST),
    Now = util:unixtime(),
    put(?DICT_ROUND_ENDTIME, Now),
    broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_CALC}),
    put(?DICT_PERIOD, ?ROOM_STATE_CALC),
    Pb = #pbplayerroundcalc{player_result_list = player_list2pb_round_calc(PlayerList),
    time = Now, room_id = RoomId, round = get(?DICT_ROUND), zhuang_id = get(?DICT_ZHUANGJIAID)},
    put(?DICT_ROUND_CALC_PB, Pb),
    case get(?DICT_ROUND) < MaxRound of
        true ->
            broadcast_msg(20007, Pb),
            % end_record(RoomId, Now, RoomType),
            save_paiju_data(RoomType, RoomId, Now),
            next(state_round_calc, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
        _ ->
            broadcast_msg(20012, #pbplayerfinalcalc{player_result_list =
            player_list2pb_final_calc(PlayerList), time = Now, room_id = RoomId, round = get(?DICT_ROUND)}),
            broadcast_msg(20007, Pb),
            % end_record(RoomId, Now, RoomType),
            save_paiju_data(RoomType, RoomId, Now),
            next(state_final_calc, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0})
    end.
%%一般回合结算
state_round_calc(timeout, State) ->
    %?DEBUG("一般回合结算阶段。。。"),
    next(state_round_calc, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = ?STATE_LOOP_TIME}).
%%最后回合结算
state_final_calc(timeout, State = #room_tuiduizi{room_id = RoomId}) ->
    %?DEBUG("最后回合结算。。。"),
    close_room_handle(State),
    ets:delete(?ETS_ROOM, RoomId),
    % gambling_record:close(get(?DICT_RECORD_PID)),
    {stop, normal, State}.
%%申请解散房间状态
state_exit_room_apply(timeout, State) ->
    next(state_close_room, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0}).
%% 真正解散房间
state_close_room(timeout, State = #room_tuiduizi{room_id = RoomId}) ->
    broadcast_msg(11005, []),
    Playerlist = get(?DICT_PLAYER_LIST),
    Now = util:unixtime(),
    broadcast_msg(20012, #pbplayerfinalcalc{player_result_list = player_list2pb_final_calc(Playerlist), time = Now,
    room_id = RoomId, round = get(?DICT_ROUND)}),
    Pb = 
    case get(?DICT_ROUND_CALC_PB) of
        P = #pbplayerroundcalc{} -> 
            P;
        _ ->
           #pbplayerroundcalc{player_result_list = player_list2pb_round_calc(Playerlist), time = Now,
            room_id = RoomId, round = get(?DICT_ROUND), zhuang_id = get(?DICT_ZHUANGJIAID)}
    end,
    broadcast_msg(20007, Pb),
    next(state_final_calc, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0}).
%%--------------------------------------------------------------------
%% @private
%% @doc
%% There should be one instance of this function for each possible
%% state name. Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_event/[2,3], the instance of this function with
%% the same name as the current state name StateName is called to
%% handle the event.
%%
%% @end
%%--------------------------------------------------------------------
-spec(state_name(Event :: term(), From :: {pid(), term()},
    State :: #room_tuiduizi{}) ->
  {next_state, NextStateName :: atom(), NextState :: #room_tuiduizi{}} |
  {next_state, NextStateName :: atom(), NextState :: #room_tuiduizi{},
    timeout() | hibernate} |
  {reply, Reply, NextStateName :: atom(), NextState :: #room_tuiduizi{}} |
  {reply, Reply, NextStateName :: atom(), NextState :: #room_tuiduizi{},
    timeout() | hibernate} |
  {stop, Reason :: normal | term(), NewState :: #room_tuiduizi{}} |
  {stop, Reason :: normal | term(), Reply :: term(),
    NewState :: #room_tuiduizi{}}).
state_name(_Event, _From, State) ->
  Reply = ok,
  {reply, Reply, state_name, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:send_all_state_event/2, this function is called to handle
%% the event.
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_event(Event :: term(), StateName :: atom(),
    StateData :: #room_tuiduizi{}) ->
  {next_state, NextStateName :: atom(), NewStateData :: #room_tuiduizi{}} |
  {next_state, NextStateName :: atom(), NewStateData :: #room_tuiduizi{},
    timeout() | hibernate} |
  {stop, Reason :: term(), NewStateData :: #room_tuiduizi{}}).
handle_event(Event, StateName, State) ->
  try
    do_handle_event(Event, StateName, State)
  catch
    _:Reason ->
      ?ERR("~p handle_event is exception:~w~nEvent:~w", [?MODULE, Reason, Event]),
      ?ERR("get_stacktrace:~n~p", [erlang:get_stacktrace()]),
      continue(StateName, State)
  end.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a gen_fsm receives an event sent using
%% gen_fsm:sync_send_all_state_event/[2,3], this function is called
%% to handle the event.
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_sync_event(Event :: term(), From :: {pid(), Tag :: term()},
    StateName :: atom(), StateData :: term()) ->
  {reply, Reply :: term(), NextStateName :: atom(), NewStateData :: term()} |
  {reply, Reply :: term(), NextStateName :: atom(), NewStateData :: term(),
    timeout() | hibernate} |
  {next_state, NextStateName :: atom(), NewStateData :: term()} |
  {next_state, NextStateName :: atom(), NewStateData :: term(),
    timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewStateData :: term()} |
  {stop, Reason :: term(), NewStateData :: term()}).

handle_sync_event({join_in, Player}, _From, StateName, State = #room_tuiduizi{room_id = RoomId}) ->
    Playerlist = get(?DICT_PLAYER_LIST),
    {R, FinlaState} = 
    case length(Playerlist) of
        Size when Size >= 7 ->
            {false, State};
        _ ->
            [#room{seat_list = SeatList} = Room1] = ets:lookup(?ETS_ROOM, RoomId),
            {Seat, SeatList2} = room_mgr:allocate_seat(SeatList),
            Room2 = Room1#room{seat_list = SeatList2},
            ets:insert(?ETS_ROOM, Room2),
            role_db:update_room_id(Player#player_tuiduizi.id, RoomId),

            Player0 = 
            case StateName =/= state_waiting of
                true  ->
                    Player#player_tuiduizi{state  =  ?PLAYER_STATE_WATCHING, seat_id = Seat};
                _ ->
                    Player#player_tuiduizi{seat_id = Seat}
            end,
            put(?DICT_PLAYER_LIST, [Player0 | get(?DICT_PLAYER_LIST)]),
            send_room_info(Player0, State),
            broadcast_other_msg(Player#player_tuiduizi.id, 20005, player2pbtuiduizi(Player0)),
            % continue(StateName, State);
            {ok, State}
    end,
    #room_tuiduizi{ts = Ts, t_cd = Tcd} = FinlaState,
    T = time_left(Ts, Tcd),
    {reply, R, StateName, FinlaState, T};

handle_sync_event(_Event, _From, StateName, State) ->
    Reply = ok,
    {reply, Reply, StateName, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it receives any
%% message other than a synchronous or asynchronous event
%% (or a system message).
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: term(), StateName :: atom(),
    StateData :: term()) ->
  {next_state, NextStateName :: atom(), NewStateData :: term()} |
  {next_state, NextStateName :: atom(), NewStateData :: term(),
    timeout() | hibernate} |
  {stop, Reason :: normal | term(), NewStateData :: term()}).
handle_info(_Info, StateName, State) ->
  {next_state, StateName, State}.
%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_fsm when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_fsm terminates with
%% Reason. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: normal | shutdown | {shutdown, term()}
| term(), StateName :: atom(), StateData :: term()) -> term()).
terminate(_Reason, _StateName, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, StateName :: atom(),
    StateData :: #room_tuiduizi{}, Extra :: term()) ->
  {ok, NextStateName :: atom(), NewStateData :: #room_tuiduizi{}}).
code_change(_OldVsn, StateName, State, _Extra) ->
  {ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
do_init([RoomId, RoomType, Owner, Costcardnum, _PayWay, Property]) ->
    ?INFO("[~w] 正在启动", [?MODULE]),
    put(?DICT_ROOM_PID, self()),
    put(?DICT_PERIOD, ?ROOM_STATE_WAITING),
    put(?DICT_PLAYER_LIST, [Owner]),
    put(?DICT_ROUND, 0),
    put(?DICT_ROUND_ENDTIME, 0),
    put(?DICT_ZHUANGJIAID, Owner#player_tuiduizi.id),
    put(?DICT_NOW_PLAYER, Owner#player_tuiduizi.id),
    put(?DICT_MAHJONG_LIST, []),
    put(?DICT_CHIP_IN_ENDTIME, 0),
    put(?DICT_DISMISS_OPT_LIST, []),
    put(?DICT_ROUND_CALC_PB, {}),
    put(?DICT_CAN_COST_CARD, false),
    %{ok, RecordPid} = gambling_record:start(),
    put(?DICT_RECORD_PID, 0),
    put(?DICT_START_ROOM_TIME, util:unixtime()),
    put(?DICT_ROOM_ROUND_KEY_LIST, []),
    init_mahjong(),
    State = 
    #room_tuiduizi{
        max_round = ?MAX_ROUND_NUM(Costcardnum), 
        room_id = RoomId, 
        room_type = RoomType,
        property = Property#room_tuiduizi_property{max_round = ?MAX_ROUND_NUM(Costcardnum)},
        owner_id = Owner#player_tuiduizi.id, cost_card_num = Costcardnum
    },
    send_room_info(Owner, State),
    ?INFO("[~w] 启动完成", [?MODULE]),
    {ok, state_waiting, State}.

%%玩家加入事件处理
do_handle_event({join_in, Player}, StateName, State) ->
  Player0 = case StateName =/= state_waiting of
              true	->
                Player#player_tuiduizi{state  =  ?PLAYER_STATE_WATCHING};
              _ ->
                Player
            end,
  put(?DICT_PLAYER_LIST, [Player0 | get(?DICT_PLAYER_LIST)]),
  send_room_info(Player0, State),
  broadcast_other_msg(Player#player_tuiduizi.id, 20005, player2pbtuiduizi(Player0)),
  continue(StateName, State);
%%开始游戏事件处理
do_handle_event({start_game}, StateName = state_waiting, State)->
  case erlang:length(get(?DICT_PLAYER_LIST)) > 1 of
    true ->
      put(?DICT_PERIOD, ?ROOM_STATE_START),
      next(state_start_game, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 100});
    _ ->
      %?DEBUG("一个人不能开始游戏~w"),
      continue(StateName, State)
  end;
%%下注事件处理
do_handle_event({chipin, Playerid, Chipintype, Chipinum}, StateName = state_chipin, State) ->
  Playerlist = get(?DICT_PLAYER_LIST),
  case Playerid =/= get(?DICT_ZHUANGJIAID) of
    true ->
      case lists:keyfind(Playerid, #player_tuiduizi.id, Playerlist) of
        Player = #player_tuiduizi{shunmen_chipnum = Shunchip, tianmen_chipnum = Tianchip, dimen_chipnum = Dichip,
          duhong_chipnum = Duhongchip, yahe_chipnum = Yahechip, is_playing = true} ->
          put(?DICT_CAN_COST_CARD, true),
          Chipnumlist = Player#player_tuiduizi.player_chip_list,
          Player2 = case Chipintype of
                          1 ->
                              Player#player_tuiduizi{shunmen_chipnum = Shunchip + Chipinum, player_chip_list =
                              [#chipin{chipin_type = Chipintype, chipin_num = Chipinum} | Chipnumlist]};
                          2 ->
                              Player#player_tuiduizi{tianmen_chipnum = Tianchip + Chipinum, player_chip_list =
                              [#chipin{chipin_type = Chipintype, chipin_num = Chipinum} | Chipnumlist]};
                          3 ->
                              Player#player_tuiduizi{dimen_chipnum = Dichip + Chipinum, player_chip_list =
                              [#chipin{chipin_type = Chipintype, chipin_num = Chipinum} | Chipnumlist]};
                          4 ->
                              Player#player_tuiduizi{duhong_chipnum = Duhongchip + Chipinum, player_chip_list =
                              [#chipin{chipin_type = Chipintype, chipin_num = Chipinum} | Chipnumlist]};
                          5 ->
                              Player#player_tuiduizi{yahe_chipnum = Yahechip + Chipinum, player_chip_list =
                              [#chipin{chipin_type = Chipintype, chipin_num = Chipinum}|Chipnumlist]};
                          Other ->
                            ?ERR("下注类型不存在：~w",[Other])
                        end,
          put(?DICT_PLAYER_LIST, lists:keyreplace(Playerid, #player_tuiduizi.id, Playerlist, Player2)),
          broadcast_msg(20004, #pbplayerchipin{player_id = Playerid, point_chose = Chipinum, mohjong_point = Chipintype}),
          continue(StateName, State);
        _ ->
          continue(StateName, State)
      end;
    _ ->
      continue(StateName, State)
  end;
%%庄家开牌
do_handle_event({open_mahjongs, RoleId}, StateName = state_chipin, State = #room_tuiduizi{property =
    #room_tuiduizi_property{
        is_red_half = Isredhalf, 
        % pairs_double = PairsDouble, 
        is_one_red = Isonered,
        is_river = Isriver,
        nine_double = NineDouble,
        xian_double = XianDouble,
        zhuang_double = ZhuangDouble}}) ->
    case get(?DICT_ZHUANGJIAID) =:= RoleId of
        true ->
            send_mahjong(),
            mahjong_style(Isredhalf),
            Mahjonglist = get(?DICT_MAHJONG_LIST),
            put(?DICT_PERIOD, ?ROOM_STATE_SHOW),
            broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_SHOW}),
            send_mahjong_list(Mahjonglist),
            % calc_score(Mahjonglist, PairsDouble, Isonered, Isriver),
            calc_score(Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver),
            log_round(State),
            next(state_show, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 5000});
        _ ->
            continue(StateName, State)
    end;
%%退出结算界面
do_handle_event({exit_calc, RoleId}, StateName = state_round_calc, State) ->
    PlayerList = get(?DICT_PLAYER_LIST),
    case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
        Player = #player_tuiduizi{state = 1, is_exit_calc = false} ->
            PlayerList2 = lists:keyreplace(RoleId, #player_tuiduizi.id, PlayerList,
            Player#player_tuiduizi{is_exit_calc = true, state = 0}),
            put(?DICT_PLAYER_LIST, PlayerList2),
            broadcast_msg(20011, #pbplayerid{player_id = RoleId}),
            Fun = 
            fun(#player_tuiduizi{is_exit_calc = IsExitCalc, state = PlayerState}) ->
                (not IsExitCalc) andalso (PlayerState =:= 1) 
            end,
            case lists:filter(Fun, PlayerList2) of
                [] ->
                    put(?DICT_MAHJONG_LIST, []),
                    put(?DICT_ROUND_CALC_PB, {}),
                    next(state_start_game, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
                _ ->
                    continue(StateName, State)
            end;
        _ ->
            continue(StateName, State)
    end;
%%申请退出房间
do_handle_event({exit_room_apply, RoleId}, StateName, State = #room_tuiduizi{room_id = RoomId, owner_id = OwnerId}) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
    Player = #player_tuiduizi{name = PlayerName, seat_id = SeatId, pid = RPid, icon = Icon,
      state = PlayerState, is_exit_room = IsExitRoom, is_playing = IsPlaying} ->
      if
        RoleId =/= OwnerId andalso (StateName =:= state_waiting orelse PlayerState =:= ?PLAYER_STATE_WATCHING) ->
          [Room = #room{seat_list = SeatList}] = ets:lookup(?ETS_ROOM, RoomId),
          lib_player_room:api_exit_room(RPid),
          ets:insert(?ETS_ROOM, Room#room{seat_list = [SeatId | SeatList]}),
          broadcast_msg(11003, #pbbaseplayer{player_id = RoleId, player_name = PlayerName, dismiss_opt = 1, icon = Icon}),
          put(?DICT_PLAYER_LIST, lists:keydelete(RoleId, #player_tuiduizi.id, PlayerList)),
          continue(StateName, State);
        StateName =:= state_waiting andalso RoleId =:= OwnerId ->
          broadcast_msg(11005, []),
          next(state_final_calc, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
        true ->
          Fun = fun(#player_tuiduizi{is_exit_room = IsExitRoom2}) -> (not IsExitRoom2) end,
          case lists:all(Fun, PlayerList) of
            true ->
              case IsPlaying andalso IsExitRoom =:= false of
                true ->
                  PlayerList2 = lists:keyreplace(RoleId, #player_tuiduizi.id, PlayerList,
                    Player#player_tuiduizi{is_exit_room = true}),
                  put(?DICT_PLAYER_LIST, PlayerList2),
                  put(?DICT_DISMISS_APPLY_ID, RoleId),
                  put(?DICT_DISMISS_OPT_LIST, [{1, RoleId} | get(?DICT_DISMISS_OPT_LIST)]),
                  broadcast_dismiss_info(30),
                  put(?DICT_LAST_STATE_NAME, StateName),
                  next(state_exit_room_apply, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 30000});
                _ ->
                  continue(StateName, State)
              end;
            _ ->
              continue(StateName, State)
          end
      end;
    _ ->
      continue(StateName, State)
  end;
%%其他玩家同意退出房间
do_handle_event({accept_exit_room, RoleId}, StateName = state_exit_room_apply, State) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
    Player = #player_tuiduizi{is_exit_room = false, name = PlayerName, is_playing = true, icon = Icon} ->
      broadcast_msg(11007, #pbbaseplayer{player_id = RoleId, player_name = PlayerName, dismiss_opt = 2, icon = Icon}),
      put(?DICT_DISMISS_OPT_LIST, [{2, RoleId} | get(?DICT_DISMISS_OPT_LIST)]),
      PlayerList2 = lists:keyreplace(RoleId, #player_tuiduizi.id, PlayerList,
        Player#player_tuiduizi{is_exit_room = true}),
      put(?DICT_PLAYER_LIST, PlayerList2),
      Fun = fun(#player_tuiduizi{is_exit_room = IsExitRoom, is_playing = IsPlaying}) ->
        (not IsExitRoom) andalso IsPlaying end,
      case lists:filter(Fun, PlayerList2) of
        [] ->
          dismiss_room_log(State),
          next(state_close_room, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
        _ ->
          continue(StateName, State)
      end;
    #player_tuiduizi{is_playing = false} ->
      role:send_error_msg(RoleId, ?ERR_WATCHING_CANNOT_OPT),
      continue(StateName, State);
    _ ->
      continue(StateName, State)
  end;
%%其他人不同意退出房间
do_handle_event({not_accept_exit_room, RoleId}, StateName = state_exit_room_apply, State) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
    #player_tuiduizi{is_exit_room = false, name = Name, is_playing = true, icon = Icon} ->
      put(?DICT_PLAYER_LIST, [Player#player_tuiduizi{is_exit_room = false} || Player <- PlayerList]),
      broadcast_msg(11009, #pbbaseplayer{player_id = RoleId, player_name = Name, dismiss_opt = 3, icon = Icon}),
      put(?DICT_DISMISS_OPT_LIST, []),
      next(get(?DICT_LAST_STATE_NAME), State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
    #player_tuiduizi{is_playing = false} ->
      role:send_error_msg(RoleId, ?ERR_WATCHING_CANNOT_OPT),
      continue(StateName, State);
    _ ->
      continue(StateName, State)
  end;
%%玩家坐下操作
do_handle_event({sit_down, RoleId}, StateName, State) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
    Player = #player_tuiduizi{state = ?PLAYER_STATE_WATCHING} ->
      broadcast_msg(20015, #pbplayerid{player_id = RoleId}),
      PlayerList2 = lists:keyreplace(RoleId, #player_tuiduizi.id, PlayerList,
        Player#player_tuiduizi{state = ?PLAYER_STATE_WAITING}),
      put(?DICT_PLAYER_LIST, PlayerList2);
    _ ->
      skip
  end,
  continue(StateName, State);
%%玩家掉线操作
do_handle_event({player_offline, RoleId}, StateName, State) ->
  % ?DEBUG("~w", [{player_offline, RoleId}]),
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
    Player = #player_tuiduizi{is_online = true} ->
      broadcast_other_msg(RoleId, 20002, #pbplayeronline{player_id = RoleId, is_online = false}),
      PlayerList2 = lists:keyreplace(RoleId, #player_tuiduizi.id, PlayerList,
        Player#player_tuiduizi{is_online = false}),
      put(?DICT_PLAYER_LIST, PlayerList2);
    _ ->
      skip
  end,
  continue(StateName, State);
%%玩家重连操作
do_handle_event({player_return, RoleId, RolePid, Socket}, StateName, State) ->
  % ?DEBUG("~w", [{player_return, RoleId}]),
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
    Player = #player_tuiduizi{name = _Name, is_exit_calc = IsExitCalc, state = _PlayerState,
      is_exit_room = _IsExitRoom, icon = _Icon} ->
      % broadcast_other_msg(RoleId, 20002, #pbplayeronline{player_id = RoleId, is_online = true}),
      Player2 = Player#player_tuiduizi{is_online = true, pid = RolePid, socket = Socket},
      PlayerList2 = lists:keyreplace(RoleId, #player_tuiduizi.id, PlayerList, Player2),
      put(?DICT_PLAYER_LIST, PlayerList2),
      broadcast_other_msg(RoleId, 20002, #pbplayeronline{player_id = RoleId, is_online = true}),
      send_room_info(Player2, State),
      case (StateName =:= state_round_calc) andalso (IsExitCalc =:= false) of
        true ->
          send_msg(Player2, 20007, get(?DICT_ROUND_CALC_PB));
        _ ->
          skip
      end,
      case StateName of
        % state_exit_room_apply when PlayerState =/= ?PLAYER_STATE_WATCHING andalso IsExitRoom =:= false ->
        %   put(?DICT_PLAYER_LIST, [P#player_tuiduizi{is_exit_room = false} || P <- PlayerList2]),
        %   broadcast_msg(11009, #pbbaseplayer{player_id = RoleId, player_name = Name, dismiss_opt = 3, icon = Icon}),
        %   put(?DICT_DISMISS_OPT_LIST, []),
        %   next(get(?DICT_LAST_STATE_NAME), State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
        state_exit_room_apply ->
          send_dismiss_info(Player2, 30 - (util:unixtime() - State#room_tuiduizi.ts div 1000)),
          continue(StateName, State);
        _ ->
          continue(StateName, State)
      end;
    _ ->
      lib_player_room:api_exit_room(RolePid),
      continue(StateName, State)
  end;
%%聊天操作
do_handle_event({chat, RoleId, Data}, StateName, State) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_tuiduizi.id, PlayerList) of
    #player_tuiduizi{name = PlayerName, icon = PlayerIcon} ->
      broadcast_msg(13003, Data#pbmsgchat{id = RoleId, name = PlayerName, icon = PlayerIcon});
    _ ->
      skip
  end,
  continue(StateName, State);
do_handle_event({gm_dismiss_room}, _StateName, State) ->
  next(state_close_room, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
do_handle_event(Event, StateName, State) ->
  ?DEBUG("handle_event未处理消息：Event[~w], StateName[~w]", [Event, StateName]),
  continue(StateName, State).

next(StateName, State = #room_tuiduizi{t_cd = Tcd}) ->
  {next_state, StateName, State, Tcd}.

continue(StateName, State = #room_tuiduizi{ts = Ts, t_cd = Tcd}) ->
  T = time_left(Ts, Tcd),
%%    ?DEBUG("~w 毫秒后，进入~w状态", [T, StateName]),
  {next_state, StateName, State, T}.

time_left(Ts, Tcd) ->
  T = Tcd - (util:unixtime(ms) - Ts),
  case T > 0 of
    true -> T;
    _ -> 0
  end.

%%初始化一副麻将
init_mahjong() ->
    List = lists:seq(1, 10),
    List2 = lists:seq(1, 4),
    Fun = fun(Num, AccList) ->
        [#mahjong{num = Num, quantity  = Quantity} || Quantity <- List2] ++ AccList
    end,
    List3 = lists:foldl(Fun, [], List),
    put(?INIT_MAHJONG_LIST, List3),
    refresh_mahjong_list().

%%洗牌
refresh_mahjong_list() ->
    put(?MAHJONG_LIST, []),
    Fun = fun(_, {InitMahjongList, NewMahjongList}) ->
        Mahjong = util:rand_list(InitMahjongList),
        {lists:delete(Mahjong, InitMahjongList), [Mahjong | NewMahjongList]}
    end,
    MahjongList = get(?INIT_MAHJONG_LIST),
    {[], NewMahjongList2} = lists:foldl(Fun, {MahjongList, []}, MahjongList),
    put(?INIT_MAHJONG_LIST, NewMahjongList2),
    put(?MAHJONG_LIST, NewMahjongList2).

%%发牌
take_mahjong(Num) ->
    Mahjonglist = get(?MAHJONG_LIST),
    take_poker(Num, Mahjonglist, []).
take_poker(Num, Mahjonglist, List4) when Num =< 0 ->
    put(?MAHJONG_LIST, Mahjonglist),
    List4;
take_poker(_, Mahjonglist = [], List4) ->
    put(?MAHJONG_LIST, Mahjonglist),
    List4;
take_poker(Num, [H|List5], List4) ->
    take_poker(Num - 1, List5, [H|List4]).


%% 更新玩家的回放记录
update_player_huifang(PlayerId, OpCode, Data) ->
    HuiFangList = get(?DICT_HUIFANG_LIST),
    put(?DICT_HUIFANG_LIST, [#record_proto{id = PlayerId, opcode = OpCode, data = Data} | HuiFangList]).

%% 发送消息给单个玩家
send_msg(#player_tuiduizi{id = PlayerId, pid = _RPid, socket = Socket, state = State}, OpCode, Data) ->
    %role:send_msg(RPid, OpCode, Data),
    % lib_send:send_data_to_client(PlayerId, Socket, OpCode, Data),
    lib_send:send_data(Socket, OpCode, Data),
    case State =:= ?PLAYER_STATE_PLAYING andalso lists:member(OpCode, ?TUIDUIZI_RECORD_LIST) of
        true ->
            %gambling_record:record(get(?DICT_RECORD_PID), PlayerId, OpCode, Data);
            update_player_huifang(PlayerId, OpCode, Data);
        _ ->
            skip
    end.

%% 广播牌局阶段和同步玩家进程的房间id和房间pid
broadcast_period_start(OpCode, {RoomId, RoomPid, Data} = _D) ->
    PlayerList = get(?DICT_PLAYER_LIST),
    Fun = 
    fun(#player_tuiduizi{id = PlayerId, pid = RPid, socket = Socket, state = State}) ->
            %role:send_msg(RPid, OpCode, {sync_id ,D}),
            % role:sync_role_room_pid_and_room_id(RPid, {sync_id, RoomId, RoomPid}),
            % lib_send:send_data_to_client(PlayerId, Socket, OpCode, Data),
            lib_send:send_data(Socket, OpCode, Data),
            RPid ! {sync_room_of_id_pid, RoomId, RoomPid},
            case State =:= ?PLAYER_STATE_PLAYING andalso lists:member(OpCode, ?TUIDUIZI_RECORD_LIST) of
                true ->
                    update_player_huifang(PlayerId, OpCode, Data);
                _ ->
                    skip
            end
    end,
    lists:foreach(Fun, PlayerList).

%% 每一局结束后保存局记录
save_paiju_data(RoomType, RoomId, Time) ->
    PlayerList = get(?DICT_PLAYER_LIST),
    RecordPlayerList = player_list2round_record(PlayerList),
    HuiFangList = get(?DICT_HUIFANG_LIST),
    B1 = util:term_to_bitstring(RecordPlayerList),
    B2 = util:term_to_bitstring(HuiFangList),
    Round = get(?DICT_ROUND),
    Key = 
    case do_data_of_mysql:insert_paiju_data(RoomType, RoomId, Round, Time, B1, B2) of
        {error, Id} ->
            do_data_of_mnesia:update_room_log_backup(2, {RoomType, Id, RoomId, Round, Time, B1, B2}),
            Id;
        Id ->
            Id
    end,
    put(?DICT_ROOM_ROUND_KEY_LIST, [Key | get(?DICT_ROOM_ROUND_KEY_LIST)]).

%% 保存一个房间的数据
save_room_data(RoomType, RoomId) ->
    PlayerList = get(?DICT_PLAYER_LIST),
    RecordPlayerList = player_list2record(PlayerList),
    RoomRoundKeyList = get(?DICT_ROOM_ROUND_KEY_LIST),
    B1 = util:term_to_bitstring(RecordPlayerList),
    B2 = util:term_to_bitstring(RoomRoundKeyList),
    Time = get(?DICT_START_ROOM_TIME),
    Key = 
    case do_data_of_mysql:inset_fangjian_huifang_jilu(RoomType, RoomId, Time, B1, B2) of
        {error, Id} ->
            do_data_of_mnesia:update_room_log_backup(1, {RoomType, Id, RoomId, Time, B1, B2}),
            Id;
        Id ->
            Id
    end,
    [do_data_of_mnesia:update_player_room_log(RoomType, P#player_tuiduizi.id, Key) || P <- PlayerList, P#player_tuiduizi.is_playing].


%% 全体广播消息
broadcast_msg(OpCode, Data) ->
    PlayerList = get(?DICT_PLAYER_LIST),
    Fun = fun(Player) ->
        send_msg(Player, OpCode, Data)
    end,
    lists:foreach(Fun, PlayerList).
%% 广播消息（除自己以外）
broadcast_other_msg(PlayerId, OpCode, Data) ->
    PlayerList = get(?DICT_PLAYER_LIST),
    Fun = 
        fun(Player = #player_tuiduizi{id = PlayerId2}) when PlayerId2 =/= PlayerId ->
            send_msg(Player, OpCode, Data);
        (_) -> skip
    end,
    lists:foreach(Fun, PlayerList).

%% 推送房间数据
send_room_info(Player = #player_tuiduizi{seat_id = SeatId}, 
    #room_tuiduizi{
        room_id = RoomId, owner_id = OwnerId,
        max_round = MaxRound, 
        property = 
        #room_tuiduizi_property{
            banker_type = BK, 
            point_chose = PC, 
            is_red_half = IRH,
            % pairs_double = PD, 
            is_one_red = IOR, 
            is_river = IR,
            nine_double = NineDouble,
            xian_double = XianDouble,
            zhuang_double = ZhuangDouble}}) ->
    %%  ?DEBUG("玩家列表：~w",[PlayerList]),
    Now = util:unixtime(),
    ChipInEndTime = get(?DICT_CHIP_IN_ENDTIME),
    ChipInTime = 
    case ChipInEndTime > Now of
        true -> 
            ChipInEndTime - Now;
        _ -> 
            0
    end,
    send_msg(
        Player, 
        20001, 
        #pbroominfotuiduizi{
            room_id = RoomId,
            room_owner_id = OwnerId,
            round = get(?DICT_ROUND),
            zhuang_id = get(?DICT_ZHUANGJIAID),
            period = get(?DICT_PERIOD),
            my_seat_id = SeatId,
            player_list = player_list2pb_tuiduizi(get(?DICT_PLAYER_LIST)),
            max_round = MaxRound,
            banker_type = BK,
            point_chose = PC,
            is_red_half = IRH,
            % pairs_double = PD,
            nine_double = NineDouble,
            is_one_red = IOR,
            is_river = IR,
            mahjong_list = totalmahjong2pb(get(?DICT_MAHJONG_LIST)),
            chip_in_time = ChipInTime,
            xian_double = XianDouble,
            zhuang_double = ZhuangDouble}
    ).

%%玩家列表转成协议
player_list2pb_tuiduizi(Playerlist) ->
    [player2pbtuiduizi(Player) || Player <- Playerlist].
player2pbtuiduizi(Player) ->
    #pbplayer{
        id = Player#player_tuiduizi.id,
        icon = Player#player_tuiduizi.icon,
        name = Player#player_tuiduizi.name,
        seat_id = Player#player_tuiduizi.seat_id,
        state = Player#player_tuiduizi.state,
        is_online = Player#player_tuiduizi.is_online,
        score = Player#player_tuiduizi.score,
        player_chip_list = chip2pblist(Player#player_tuiduizi.player_chip_list),
        sex = Player#player_tuiduizi.sex,
        ip = Player#player_tuiduizi.ip,
        gps = Player#player_tuiduizi.gps
    }.

chip2pblist(Chiplist)->
    [chip2pb(Chip) || Chip <- Chiplist].
chip2pb(Chip) ->
    #pbchip{
        chip_type = Chip#chipin.chipin_type,
        chip_num = Chip#chipin.chipin_num
    }.


%%玩家本局结果转成协议
player_list2pb_round_calc(Playerlist) ->
    [player2pb_round_calc(Player) || Player <- Playerlist,Player#player_tuiduizi.is_playing].
player2pb_round_calc(Player) ->
    #pbplayerroundresult{
        player_id = Player#player_tuiduizi.id,
        score = Player#player_tuiduizi.score,
        score_change = Player#player_tuiduizi.score_change
    }.

%%玩家最终结果转成协议
player_list2pb_final_calc(Playerlist) ->
    [player2pb_final_calc(Player) || Player <- Playerlist, Player#player_tuiduizi.is_playing].
player2pb_final_calc(Player) ->
    Calclist = Player#player_tuiduizi.calc_list,
    MaxCalc = 
    case Calclist of
        [] ->
            0;
        _ ->
            lists:max(Calclist)
    end,
    #pbplayerfinalresult{
        player_id = Player#player_tuiduizi.id,
        score = Player#player_tuiduizi.score,
        max_score = MaxCalc
    }.

%%初始化玩家数据
round_init_player_list(PlayerList) -> 
    [round_init_player(Player) || Player <- PlayerList].
round_init_player(Player = #player_tuiduizi{state = ?PLAYER_STATE_WATCHING}) -> 
    Player;
round_init_player(Player) ->
    %gambling_record:begin_record(get(?DICT_RECORD_PID), Player#player_tuiduizi.id),
    put(?DICT_DISMISS_OPT_LIST, []),
    Player2 = 
    Player#player_tuiduizi{
        state = ?PLAYER_STATE_PLAYING, 
        score_change = 0, 
        is_exit_calc = false,
        is_exit_room = false, 
        shunmen_chipnum = 0, 
        tianmen_chipnum = 0, 
        dimen_chipnum = 0,
        duhong_chipnum = 0, 
        yahe_chipnum = 0, 
        player_chip_list = [], 
        is_playing = true
    },
    Player2.

record_room_info(#player_tuiduizi{id = PlayerId, seat_id = SeatId}, 
    #room_tuiduizi{
        room_id = RoomId,
        owner_id = OwnerId, 
        max_round = MaxRound, 
        property = 
        #room_tuiduizi_property{
            banker_type = BK, 
            point_chose = PC,
            is_red_half = IRH, 
            % pairs_double = PD, 
            is_one_red = IOR, 
            is_river = IR,
            nine_double = NineDouble,
            xian_double = XianDouble,
            zhuang_double = ZhuangDouble}}) ->
    update_player_huifang(PlayerId, 20001, 
        #pbroominfotuiduizi{
            room_id = RoomId,
            room_owner_id = OwnerId,
            round = get(?DICT_ROUND),
            zhuang_id = get(?DICT_ZHUANGJIAID),
            period = get(?DICT_PERIOD),
            my_seat_id = SeatId,
            player_list = player_list2pb_tuiduizi(get(?DICT_PLAYER_LIST)),
            max_round = MaxRound,
            banker_type = BK,
            point_chose = PC,
            is_red_half = IRH,
            % pairs_double = PD,
            nine_double = NineDouble,
            is_one_red = IOR,
            is_river = IR,
            mahjong_list = totalmahjong2pb(get(?DICT_MAHJONG_LIST)),
            chip_in_time = 0,
            xian_double = XianDouble,
            zhuang_double = ZhuangDouble}
        ).

%% 查找下一个玩家
get_next_player(PlayerId) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  #player_tuiduizi{seat_id = SeatId} = lists:keyfind(PlayerId, #player_tuiduizi.id, PlayerList),
  get_next_player(PlayerList, SeatId).
get_next_player(PlayerList, Pos) ->
  get_next_player(PlayerList, Pos, Pos + 1).
get_next_player(_, Pos, Pos) -> false;
get_next_player(PlayerList, Pos, NextPos) ->
  NextPos2 = ?IIF(NextPos > ?MAX_SEAT_NUM, 1, NextPos),
  case lists:keyfind(NextPos2, #player_tuiduizi.seat_id, PlayerList) of
    Player = #player_tuiduizi{state = ?PLAYER_STATE_PLAYING} ->
      Player;
    _ ->
      get_next_player(PlayerList, Pos, NextPos2 + 1)
  end.

%% 庄家变化
change_zhuang(ZhuangId) ->
  put(?DICT_ZHUANGJIAID, ZhuangId),
  broadcast_msg(20010, #pbplayerid{player_id = ZhuangId}).

%%找赢家
find_winer(Playerlist)->
  Scorelist = [Player#player_tuiduizi.score_change || Player <- Playerlist],
  Maxscore = lists:max(Scorelist),
  case lists:keyfind(Maxscore, #player_tuiduizi.score_change, Playerlist) of
    false ->
      skip;
    Player ->
      Player
  end.

%%发牌
send_mahjong()->
    Mahjonglist = [],
    MahjongZhuang = #mahjonglist{mahjong_list = take_mahjong(2),mahjong_type = 4},
    MahjongShun = #mahjonglist{mahjong_list = take_mahjong(2), mahjong_type = 1},
    MahjongTian = #mahjonglist{mahjong_list = take_mahjong(2), mahjong_type = 2},
    MahjongDi = #mahjonglist{mahjong_list = take_mahjong(2), mahjong_type = 3},
    Mahjonglist1 = [MahjongZhuang | Mahjonglist],
    Mahjonglist2 = [MahjongDi | Mahjonglist1],
    Mahjonglist3 = [MahjongTian | Mahjonglist2],
    Mahjonglist4 = [MahjongShun| Mahjonglist3],
    put(?DICT_MAHJONG_LIST, Mahjonglist4).

%%计算牌型和点数
mahjong_style(Isredhalf)->
    Mahjonglist = get(?DICT_MAHJONG_LIST),
    Mahjonglist1 = [mahjong_style(Mahjong, Isredhalf) || Mahjong <- Mahjonglist],
    put(?DICT_MAHJONG_LIST, Mahjonglist1).
mahjong_style(Mahjong, Isredhalf) ->
    Mahjonglist2 = Mahjong#mahjonglist.mahjong_list,
    Mahjongnumlist = [Mahjong2#mahjong.num || Mahjong2 <- Mahjonglist2],
    Dianshu = 
    case Isredhalf of
        true ->
            Sum = lists:sum([?NUM_HALF(X)|| X <- Mahjongnumlist]),
            case Sum >= 10 of
                true ->
                    Sum - 10;
                _ ->
                    Sum
            end;
        false ->
            Sum1 = lists:sum([?NUM_ZERO(X)|| X <- Mahjongnumlist]),
            case Sum1 >= 10 of
                true ->
                    Sum1 - 10;
                _ ->
                    Sum1
            end
    end,
    Maxdianshu = lists:max(Mahjongnumlist),
    Style = 
    case Mahjongnumlist of
        [Num, Num] ->
            ?DUIZI;
        _ ->
            ?SANPAI
    end,
    Mahjong3 = Mahjong#mahjonglist{mahjong_dianshu = Dianshu, mahjong_maxdianshu = Maxdianshu, mahjong_style = Style},
    Mahjong3.

%% 统计分数
calc_score(Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver) ->
    MahjongZhuang = lists:keyfind(4, #mahjonglist.mahjong_type, Mahjonglist),
    calc_score(MahjongZhuang, Mahjonglist -- [MahjongZhuang], NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, []).

calc_score(_MahjongZhuang, [], _NineDouble, _XianDouble, _ZhuangDouble, _Isonered, _Isriver, Zhuanglose)->
    Playerlist = get(?DICT_PLAYER_LIST),
    ZhuangjiaId = get(?DICT_ZHUANGJIAID),
    Zhuangjia = lists:keyfind(ZhuangjiaId, #player_tuiduizi.id, Playerlist),
    Xianlist = Playerlist -- [Zhuangjia],
    Yahe = lists:sum([N || #player_tuiduizi{yahe_chipnum = N} <- Playerlist]),
    Duhong = lists:sum([N || #player_tuiduizi{duhong_chipnum = N} <- Playerlist]),
    ZhuangLoseNum = length(Zhuanglose),
    Playerlist2 = 
    case ZhuangLoseNum of
        Num when Num < 2 ->
            Zhuangjia2 = Zhuangjia#player_tuiduizi{score_change = Zhuangjia#player_tuiduizi.score_change + Yahe + Duhong},
            Xianlist2 = [Xian#player_tuiduizi{score_change = Xian#player_tuiduizi.score_change -
            Xian#player_tuiduizi.yahe_chipnum - Xian#player_tuiduizi.duhong_chipnum} || Xian <- Xianlist],
            [Zhuangjia2 | Xianlist2];
        2 ->
            Zhuangjia2 = Zhuangjia#player_tuiduizi{score_change = Zhuangjia#player_tuiduizi.score_change + Duhong - Yahe},
            Xianlist2 = [Xian#player_tuiduizi{score_change = Xian#player_tuiduizi.score_change -
            Xian#player_tuiduizi.duhong_chipnum + Xian#player_tuiduizi.yahe_chipnum} || Xian <- Xianlist],
            [Zhuangjia2 | Xianlist2];
        3 ->
            Zhuangjia2 = Zhuangjia#player_tuiduizi{score_change = Zhuangjia#player_tuiduizi.score_change - 3 * Duhong - Yahe},
            Xianlist2 = [Xian#player_tuiduizi{score_change = Xian#player_tuiduizi.score_change +
            Xian#player_tuiduizi.duhong_chipnum * 3 + Xian#player_tuiduizi.yahe_chipnum} || Xian <- Xianlist],
            [Zhuangjia2 | Xianlist2]
    end,
    Playerlist3 = [Player#player_tuiduizi{score = Score + Scorechange, calc_list = [Scorechange | Claclist],
    win_num = ?IIF(Scorechange >= 0, WinNum + 1, WinNum)} || Player = #player_tuiduizi{score = Score,
    score_change = Scorechange, calc_list = Claclist, win_num = WinNum} <- Playerlist2],
    %%  ?DEBUG("玩家列表：~w",[Playerlist2]),
    put(?DICT_PLAYER_LIST, Playerlist3);


calc_score(MahjongZhuang, [Mahjongxian | Mahjonglist], NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, Zhuanglose)->
    if
        MahjongZhuang#mahjonglist.mahjong_style > Mahjongxian#mahjonglist.mahjong_style ->
            zhuangjiawin(
                MahjongZhuang#mahjonglist.mahjong_style, 
                MahjongZhuang#mahjonglist.mahjong_dianshu, 
                NineDouble,
                XianDouble,
                ZhuangDouble,
                Mahjongxian#mahjonglist.mahjong_type, 
                Zhuanglose),
            calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, Zhuanglose);
        MahjongZhuang#mahjonglist.mahjong_style < Mahjongxian#mahjonglist.mahjong_style ->
            xianjiawin(
                Mahjongxian#mahjonglist.mahjong_style, 
                Mahjongxian#mahjonglist.mahjong_dianshu, 
                NineDouble,
                XianDouble,
                ZhuangDouble,
                Mahjongxian#mahjonglist.mahjong_type, 
                Isonered, 
                Isriver, 
                [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]),
            %%      ?DEBUG("闲家赢"),
            calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]);
        true ->
            case MahjongZhuang#mahjonglist.mahjong_style of
                ?DUIZI ->
                    Zhuangmahjonglist = MahjongZhuang#mahjonglist.mahjong_list,
                    Xianmahjonglist = Mahjongxian#mahjonglist.mahjong_list,
                    if
                        Zhuangmahjonglist#mahjong.num >= Xianmahjonglist#mahjong.num ->
                            zhuangjiawin(
                                MahjongZhuang#mahjonglist.mahjong_style, 
                                MahjongZhuang#mahjonglist.mahjong_dianshu,
                                NineDouble,
                                XianDouble,
                                ZhuangDouble, 
                                Mahjongxian#mahjonglist.mahjong_type, 
                                Zhuanglose),
                            calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, Zhuanglose);
                        Zhuangmahjonglist#mahjong.num < Xianmahjonglist#mahjong.num ->
                            xianjiawin(
                                Mahjongxian#mahjonglist.mahjong_style, 
                                Mahjongxian#mahjonglist.mahjong_dianshu,
                                NineDouble,
                                XianDouble,
                                ZhuangDouble, 
                                Mahjongxian#mahjonglist.mahjong_type, 
                                Isonered, 
                                Isriver,
                                [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]),
                            %?DEBUG("闲家赢"),
                            calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]);
                        true ->
                            zhuangjiawin(
                                MahjongZhuang#mahjonglist.mahjong_style, 
                                MahjongZhuang#mahjonglist.mahjong_dianshu,
                                NineDouble,
                                XianDouble,
                                ZhuangDouble, 
                                Mahjongxian#mahjonglist.mahjong_type, 
                                Zhuanglose),
                            calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, Zhuanglose)
                    end;
                ?SANPAI ->
                    if
                        MahjongZhuang#mahjonglist.mahjong_dianshu >= Mahjongxian#mahjonglist.mahjong_dianshu ->
                            zhuangjiawin(
                                MahjongZhuang#mahjonglist.mahjong_style, 
                                MahjongZhuang#mahjonglist.mahjong_dianshu,
                                NineDouble,
                                XianDouble,
                                ZhuangDouble, 
                                Mahjongxian#mahjonglist.mahjong_type, 
                                Zhuanglose),
                            calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, Zhuanglose);
                        MahjongZhuang#mahjonglist.mahjong_dianshu < Mahjongxian#mahjonglist.mahjong_dianshu ->
                            xianjiawin(
                                Mahjongxian#mahjonglist.mahjong_style, 
                                Mahjongxian#mahjonglist.mahjong_dianshu,
                                NineDouble,
                                XianDouble,
                                ZhuangDouble, 
                                Mahjongxian#mahjonglist.mahjong_type, 
                                Isonered, 
                                Isriver,
                                [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]),
                            %?DEBUG("闲家赢"),
                            calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]);
                        true ->
                            if
                                MahjongZhuang#mahjonglist.mahjong_maxdianshu > Mahjongxian#mahjonglist.mahjong_maxdianshu ->
                                    zhuangjiawin(
                                        MahjongZhuang#mahjonglist.mahjong_style,
                                        MahjongZhuang#mahjonglist.mahjong_dianshu,
                                        NineDouble,
                                        XianDouble,
                                        ZhuangDouble, 
                                        Mahjongxian#mahjonglist.mahjong_type, 
                                        Zhuanglose),
                                        calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, Zhuanglose);
                                MahjongZhuang#mahjonglist.mahjong_maxdianshu < Mahjongxian#mahjonglist.mahjong_maxdianshu ->
                                    xianjiawin(
                                        Mahjongxian#mahjonglist.mahjong_style, 
                                        Mahjongxian#mahjonglist.mahjong_dianshu,
                                        NineDouble,
                                        XianDouble,
                                        ZhuangDouble, 
                                        Mahjongxian#mahjonglist.mahjong_type, 
                                        Isonered, 
                                        Isriver,
                                        [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]),
                                    calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, [Mahjongxian#mahjonglist.mahjong_type | Zhuanglose]);
                                true ->
                                    zhuangjiawin(
                                        MahjongZhuang#mahjonglist.mahjong_style,
                                        MahjongZhuang#mahjonglist.mahjong_dianshu,
                                        NineDouble,
                                        XianDouble,
                                        ZhuangDouble, 
                                        Mahjongxian#mahjonglist.mahjong_type, 
                                        Zhuanglose),
                                    calc_score(MahjongZhuang, Mahjonglist, NineDouble, XianDouble, ZhuangDouble, Isonered, Isriver, Zhuanglose)
                            end
                    end
            end
    end.

%%庄家赢
zhuangjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Zhuanglose) ->
    Playerlist = get(?DICT_PLAYER_LIST),
    Zhuangjiaid = get(?DICT_ZHUANGJIAID),
    Zhuangjia = lists:keyfind(Zhuangjiaid, #player_tuiduizi.id, Playerlist),
    Playerlist1 = Playerlist -- [Zhuangjia],
    zhuangjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Zhuanglose, Zhuangjia, Playerlist1, []).

zhuangjiawin(_Style, _Dianshu, _NineDouble, _XianDouble, _ZhuangDouble, _Type, _Zhuanglose, Zhuangjia, [], Scorelist) ->
    Playerlist = [Zhuangjia | Scorelist],
    %%  ?DEBUG("玩家列表3：~w",[Playerlist]),
    put(?DICT_PLAYER_LIST, Playerlist);
zhuangjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Zhuanglose, Zhuangjia, [Player = #player_tuiduizi{is_playing = false} | Playerlist], Scorelist) ->
    zhuangjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Zhuanglose, Zhuangjia, Playerlist, [Player | Scorelist]);

zhuangjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Zhuanglose, Zhuangjia = #player_tuiduizi{score_change = ZhuangScore},
    [Player = #player_tuiduizi{score_change = XianScore}|Playerlist], Scorelist) ->
    
    zhuangjiawin(
        Style, 
        Dianshu, 
        NineDouble,
        XianDouble,
        ZhuangDouble, 
        Type, 
        Zhuanglose, 
        Zhuangjia#player_tuiduizi{score_change = ZhuangScore + chose_type(Type, Player)}, 
        Playerlist,
        [Player#player_tuiduizi{score_change = XianScore - chose_type(Type, Player)}|Scorelist]).

chose_type(1, Player) -> Player#player_tuiduizi.shunmen_chipnum;
chose_type(2, Player) -> Player#player_tuiduizi.tianmen_chipnum;
chose_type(3, Player) -> Player#player_tuiduizi.dimen_chipnum.

xianjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Isonered, Isriver, Zhuanglose) ->
    Playerlist = get(?DICT_PLAYER_LIST),
    Zhuangjiaid = get(?DICT_ZHUANGJIAID),
    Zhuangjia = lists:keyfind(Zhuangjiaid, #player_tuiduizi.id, Playerlist),
    Playerlist1 = Playerlist -- [Zhuangjia],
    xianjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Isonered, Isriver, Zhuanglose, Zhuangjia, Playerlist1, []).

xianjiawin(_Style, _Dianshu, _NineDouble, _XianDouble, _ZhuangDouble, _Type, _Isonered, _Isriver, _Zhuanglose, Zhuangjia, [], Scorelist) ->
    Playerlist = [Zhuangjia | Scorelist],
    %%  ?DEBUG("玩家列表4：~w",[Playerlist]),
    put(?DICT_PLAYER_LIST, Playerlist);
xianjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Isonered, Isriver, Zhuanglose, Zhuangjia, [Player = #player_tuiduizi{is_playing = false} |
    Playerlist], Scorelist) ->
    xianjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Isonered, Isriver, Zhuanglose, Zhuangjia, Playerlist, [Player | Scorelist]);

xianjiawin(Style, Dianshu, NineDouble, XianDouble, ZhuangDouble, Type, Isonered, Isriver, Zhuanglose, Zhuangjia = #player_tuiduizi{score_change =
    Zhuangscore}, [Player = #player_tuiduizi{score_change = Xianscore} | Playerlist1], Scorelist) ->
    % ?ERR("XianDouble------------------:~w, Style---------------:~w",[XianDouble, Style]),
    case Style of
        ?DUIZI ->
            case XianDouble of %%判断对子是否翻倍（1不翻倍，2闲家翻倍，3庄闲家翻倍） todo
                true ->
                    xianjiawin(
                        Style,
                        Dianshu,
                        NineDouble,
                        XianDouble,
                        ZhuangDouble,
                        Type,
                        Isonered,
                        Isriver,
                        Zhuanglose,
                        Zhuangjia#player_tuiduizi{score_change = Zhuangscore - 3 * chose_type(Type, Player)}, Playerlist1,
                        [Player#player_tuiduizi{score_change = Xianscore + 3 * chose_type(Type, Player)} | Scorelist]);
                _ ->
                    xianjiawin(
                        Style, 
                        Dianshu,
                        NineDouble,
                        XianDouble,
                        ZhuangDouble,
                        Type, 
                        Isonered, 
                        Isriver, 
                        Zhuanglose,
                        Zhuangjia#player_tuiduizi{score_change = Zhuangscore - chose_type(Type, Player)}, Playerlist1,
                        [Player#player_tuiduizi{score_change = Xianscore + chose_type(Type, Player)} | Scorelist])
            end;
        ?SANPAI ->
            case Dianshu >= 9 andalso NineDouble == true of
                true ->
                    xianjiawin(
                        Style, 
                        Dianshu, 
                        NineDouble,
                        XianDouble,
                        ZhuangDouble, 
                        Type, 
                        Isonered, 
                        Isriver, 
                        Zhuanglose,
                        Zhuangjia#player_tuiduizi{score_change = Zhuangscore - 2 * chose_type(Type, Player)}, 
                        Playerlist1,
                        [Player#player_tuiduizi{score_change = Xianscore + 2 * chose_type(Type, Player)} | Scorelist]);
                _ ->
                    xianjiawin(
                        Style, 
                        Dianshu, 
                        NineDouble,
                        XianDouble,
                        ZhuangDouble, 
                        Type, 
                        Isonered, 
                        Isriver, 
                        Zhuanglose,
                        Zhuangjia#player_tuiduizi{score_change = Zhuangscore - chose_type(Type, Player)}, Playerlist1,
                        [Player#player_tuiduizi{score_change = Xianscore + chose_type(Type, Player)} | Scorelist])
            end
    end.

%% 玩家数据转换为回放记录玩家数据
player_list2round_record(PlayerList) -> [player2round_record(Player) || Player <- PlayerList].
player2round_record(Player) ->
  #record_player{player_id = Player#player_tuiduizi.id, player_name = Player#player_tuiduizi.name,
    score = Player#player_tuiduizi.score_change}.
player_list2record(PlayerList) -> 
    [player2record(Player) || Player <- PlayerList].
player2record(Player) ->
    #record_player{
        player_id = Player#player_tuiduizi.id, 
        player_name = Player#player_tuiduizi.name,
        score = Player#player_tuiduizi.score
    }.

%% 结束记录
% end_record(RoomId, Time, RoomType) ->
%   PlayerList = get(?DICT_PLAYER_LIST),
%   RoundRecordPlayerList = player_list2round_record(PlayerList),
%   RecordPlayerList = player_list2record(PlayerList),
%   [gambling_record:end_record(get(?DICT_RECORD_PID), P#player_tuiduizi.id, RoomType, RoomId, get(?DICT_ROUND),
%     Time, RoundRecordPlayerList, RecordPlayerList) || P <- PlayerList, P#player_tuiduizi.is_playing].

%%广播麻将列表
send_mahjong_list(Mahjonglist) ->
  broadcast_msg(20009, totalmahjong2pb(Mahjonglist)).
totalmahjong2pb(Mahjonglist) ->
  #pbmahjonglist{total_mahjong_list = [mahjong2pb(Mahjong) || Mahjong <- Mahjonglist]}.
mahjong2pb(Mahjong) ->
%%  ?DEBUG("麻将列表：~w",[Mahjong]),
  #pbplayermahjonglist{mahjong_list =  pb2mahjonglist(Mahjong#mahjonglist.mahjong_list),
    mahjong_dianshu = trunc(Mahjong#mahjonglist.mahjong_dianshu * 10),
    mahjong_type = Mahjong#mahjonglist.mahjong_type, style = Mahjong#mahjonglist.mahjong_style}.

%%麻将列表转成协议
pb2mahjonglist(Mahjonglist) ->
  [pb2mahjong(Mahjong) || Mahjong <- Mahjonglist].
pb2mahjong(Mahjong) ->
  #pbmahjong{
    num = Mahjong#mahjong.num,
    quantity = Mahjong#mahjong.quantity
  }.

%% 房间关闭处理
close_room_handle(#room_tuiduizi{room_id = RoomId, room_type = RoomType, cost_card_num = CostCardNum, create_time = CreateTime}) ->
  save_room_data(RoomType, RoomId),
  Fun = fun(#player_tuiduizi{id = PlayerId, name = PlayerName, icon = Icon, pid = RPid, score = Score, win_num = WinNum,
    is_playing = IsPlaying}) ->
    case IsPlaying andalso get(?DICT_CAN_COST_CARD) of
      true -> lib_player_room:api_cost_card(PlayerId, PlayerName, Icon, RPid, RoomId, RoomType, Score, 0, 0, WinNum,
        CreateTime, CostCardNum, false, get(?DICT_ROUND));
      _ -> skip
    end,
    lib_player_room:api_exit_room(RPid)
        end,
  lists:foreach(Fun, get(?DICT_PLAYER_LIST)).

%% 玩家每局得分日志
log_round(#room_tuiduizi{room_id = RoomId, room_type = RoomType}) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  Now = util:unixtime(),
  Round = get(?DICT_ROUND),
  [log:gambling_round_log(RoleId, RoomId, Score, RoomType, Now, Round) ||
    #player_tuiduizi{id = RoleId, score = Score} <- PlayerList].

%% 解散房间日志
dismiss_room_log(#room_tuiduizi{room_id = RoomId}) ->
  case lists:keyfind(1, 1, get(?DICT_DISMISS_OPT_LIST)) of
    {_, ApplyId} ->
      AcceptIdList = [PlayerId || {_, PlayerId} <- get(?DICT_DISMISS_OPT_LIST), PlayerId =/= ApplyId],
      log:dismiss_room_log(RoomId, ApplyId, AcceptIdList, get(?DICT_ROUND), util:unixtime());
    _ ->
      skip
  end.

%% 发送解散房间数据
send_dismiss_info(Player, RemainTime) ->
  send_msg(Player, 11018, make_dismiss_info(RemainTime)).

broadcast_dismiss_info(RemainTime) ->
  broadcast_msg(11018, make_dismiss_info(RemainTime)).

make_dismiss_info(RemainTime) ->
  Fun = fun(#player_tuiduizi{is_playing = true, id = PlayerId, name = PlayerName, icon = PlayerIcon}) ->
    case lists:keyfind(PlayerId, 2, get(?DICT_DISMISS_OPT_LIST)) of
      {Opt, _} ->
        {true, #pbbaseplayer{player_id = PlayerId, player_name = PlayerName, dismiss_opt = Opt, icon = PlayerIcon}};
      _ ->
        {true, #pbbaseplayer{player_id = PlayerId, player_name = PlayerName, dismiss_opt = 0, icon = PlayerIcon}}
    end;
    (_) -> false
        end,
  List = lists:filtermap(Fun, get(?DICT_PLAYER_LIST)),
  #pbdismissinfo{player_list = List, remain_time = ?IIF(RemainTime > 0, RemainTime, 0)}.