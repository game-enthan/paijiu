-module(room_tianiu).

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
%% 回放记录的协议
-define(PAIJIU_RECORD_LIST, [20001, 20004, 20006, 20007, 20009, 20012]).

-include("room.hrl").
-include("room_paijiu.hrl").
-include("gambling_record.hrl").
-include("public_ets.hrl").
-include("role.hrl").
-include("cli_erl_proto/pb_13_msg_pb.hrl").
-include("cli_erl_proto/pb_11_hall_pb.hrl").
-include("cli_erl_proto/pb_23_room_paijiu_pb.hrl").
-include("common.hrl").
-include("error.hrl").
%%%===================================================================
%%% API
%%%===================================================================
%% 创建玩家在房间内的数据
create_player(RoleId, RPid, Name, Seat, Icon, Sex, Ip, Gps,_B1,_B2, _Property) ->
	#player_paijiu{id = RoleId, pid = RPid, name = Name, seat_id = Seat, icon = Icon, sex = Sex, ip = Ip, gps = Gps}.

%%房间的状态:1.无作为;2.初始化玩家和房间的数据;3.房间游戏开始;4.房间游戏结束;5.房间解散;6.房间不存在.

%%玩家加入,发送一个所有状态事件(异步消息)
join_in(RoomPid, Player) ->
	gen_fsm:send_all_state_event(RoomPid, {join_in, Player}).

%%房主开始游戏
start_game(RoomPid)->
	gen_fsm:send_all_state_event(RoomPid, {start_game}).

%%(chipin,{
%%  chipin_type = 0                 %%下注方式（1=顺门，2=天门，3=地门，4=独红，5=压河）
%%  ,chipin_num = 0                 %%下注的分数
%%}


%% 异步通信:消息投递完成后双方都会立即继续埋头处理手头的工作
%% 如果是同步,则call/2会阻塞该进程,直至服务器返回相应,这样的话其他玩家就无法进行操作;此外如果服务器刚好正忙着等待你的消息,就会陷入死锁
%% 如果用同步,断线重连的时候会发送大量的请求,会导致房间卡死
%%玩家下注    
chipin(RoomPid,Playerid,Chipin_num) ->
	gen_fsm:send_all_state_event(RoomPid, {chipin,Playerid,Chipin_num}).

%%退出结算界面操作,容错机制,游戏有很多种状态,每次调用的时候都不一定能保证在那个状态下,所以用这个send_all_event,能提高容错率
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
player_return(RoomPid, Playerid, PlayerPid) ->
	gen_fsm:send_all_state_event(RoomPid, {player_return, Playerid, PlayerPid}).

%%玩家聊天
chat(RoomPid, Playerid, Date) ->
	gen_fsm:send_all_state_event(RoomPid, {chat, Playerid, Date}).

%%玩家坐下
sit_down(RoomPid, Playerid) ->
	gen_fsm:send_all_state_event(RoomPid, {sit_down, Playerid}).

%% 庄家开牌
open_mahjongs(RoomPid, Zhuangjia_Seatid) ->
	gen_fsm:send_all_state_event(RoomPid, {open_paijiu, Zhuangjia_Seatid}).    

%% 创建一个房间状态机进程			#room_paijiu_property
start(RoomId, Type, Owner, CostCardNum, PayWay, Property) ->
	gen_fsm:start({local,?MODULE},?MODULE,[RoomId, Type, Owner, CostCardNum, PayWay, Property],[]).

init(Args) ->
	try
		do_init(Args) %{ok,state_waitting,State}
	catch
		_:Reason ->
		?ERR("~p init is exception:~w", [?MODULE, Reason]),
		?ERR("get_stacktrace:~n~p", [erlang:get_stacktrace()]),
		{stop, Reason}
	end.
state_name(_Event, State) ->
  {next_state, state_name, State}.
state_waitting(timeout,State) ->
	put(?DICT_PERIOD,?ROOM_STATE_WAITING),
	next(state_waiting, State#room_paijiu{ts = util:unixtime(ms), t_cd = ?STATE_LOOP_TIME});
state_waiting(_Info, State) ->
  ?DEBUG("等待阶段消息处理忽略：~w", [_Info]),
  continue(state_waiting, State).
%%开始游戏状态
state_start_game(timeout, State = #room_paijiu{property = #room_tuiduizi_property{banker_type = Bankertype}}) ->
  ?DEBUG("开始游戏阶段"),
  put(?DICT_PERIOD, ?ROOM_STATE_START),
  broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_START}),
  put(?DICT_ROUND, get(?DICT_ROUND) + 1),
  Playerlist = get(?DICT_PLAYER_LIST),
  Winer = find_winer(Playerlist),
  put(?DICT_PLAYER_LIST, round_init_player_list(get(?DICT_PLAYER_LIST))), %%初始化玩家每一局的数据,并记录玩家的操作数据
  [record_room_info(Player, State) || Player <- get(?DICT_PLAYER_LIST), Player#player_paijiu.is_playing],
  refresh_paijiu(),
  broadcast_msg(20016, #pbshaizi{num1 = util:rand(1, 6), num2 = util:rand(1, 6)}),
  broadcast_msg(20017, #pbchipintime{time = ?CHIP_IN_TIME}),
  put(?DICT_CHIP_IN_ENDTIME, util:unixtime() + ?CHIP_IN_TIME),
  ?DEBUG("开始下注。。。"),
  case Bankertype of
	1 ->
	  broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_XIAZHU}),
	  put(?DICT_PERIOD, ?ROOM_STATE_XIAZHU),          %%房间进程状态为下注
	  next(state_chipin, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0});
	2 ->
	  case get(?DICT_ROUND) > 1 of
		true ->
		  #player_paijiu{id = PlayerId} = get_next_player(get(?DICT_ZHUANGJIAID)),
		  change_zhuang(PlayerId);
		_ ->
		  skip
	  end,
	  broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_XIAZHU}),
	  put(?DICT_PERIOD, ?ROOM_STATE_XIAZHU),
	  next(state_chipin, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0});
	3 ->
	  case get(?DICT_ROUND) > 1 of
		true ->
		  change_zhuang(Winer#player_paijiu.id);
		_ ->
		  skip
	  end,
	  broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_XIAZHU}),
	  put(?DICT_PERIOD, ?ROOM_STATE_XIAZHU),
	  next(state_chipin, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0})
  end.
%%下注阶段
state_chipin(timeout, State) ->
  ?DEBUG("下注阶段结束。。。"),              
  next(state_chipin, State#room_paijiu{ts = util:unixtime(ms), t_cd = ?STATE_LOOP_TIME}). %% 状态起始时间截    %% 状态CD
%% 亮牌阶段
state_show(timeout, State = #room_paijiu{room_id = RoomId, room_type = RoomType, max_round = MaxRound}) ->
  ?DEBUG("亮牌阶段。。。"),
  PlayerList = get(?DICT_PLAYER_LIST),
  Now = util:unixtime(),
  put(?DICT_ROUND_ENDTIME, Now),
%%  ?DEBUG("玩家列表：~w",[PlayerList]),
  broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_CALC}),
  put(?DICT_PERIOD, ?ROOM_STATE_CALC),    %%结算状态
%%  ?DEBUG("回合数：~w",[get(?DICT_ROUND)]),
  Pb = #pbplayerroundcalc{player_result_list = player_list2pb_round_calc(PlayerList),
	time = Now, room_id = RoomId, round = get(?DICT_ROUND), zhuang_id = get(?DICT_ZHUANGJIAID)},
  put(?DICT_ROUND_CALC_PB, Pb),   %% 结算消息数据
  case get(?DICT_ROUND) < MaxRound of  %%如果小于最大局数则进入一般回合结算
	true ->
	  broadcast_msg(20007, Pb),
	  end_record(RoomId, Now, RoomType),  %%发送异步消息结束游戏操作数据的记录
	  next(state_round_calc, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0});
	_ ->
	  broadcast_msg(20012, #pbplayerfinalcalc{player_result_list =
	  player_list2pb_final_calc(PlayerList), time = Now, room_id = RoomId, round = get(?DICT_ROUND)}),
	  broadcast_msg(20007, Pb),
	  end_record(RoomId, Now, RoomType),
	  next(state_final_calc, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0}) %% 状态起始时间截    %% 状态CD
  end. 
%%一般回合结算
state_round_calc(timeout, State) ->
  ?DEBUG("一般回合结算阶段。。。"),
  next(state_round_calc, State#room_paijiu{ts = util:unixtime(ms), t_cd = ?STATE_LOOP_TIME}).
%%最后回合结算
state_final_calc(timeout, State = #room_paijiu{room_id = RoomId}) ->
  ?DEBUG("最后回合结算。。。"),
  close_room_handle(State),
  ets:delete(?ETS_ROOM, RoomId),
  gambling_record:close(get(?DICT_RECORD_PID)),   %%发起异步请求结束玩家游戏操作数据记录
  {stop, normal, State}.

%%申请解散房间状态
state_exit_room_apply(timeout, State) ->
  next(state_close_room, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0}).
%% 真正解散房间
state_close_room(timeout, State = #room_paijiu{room_id = RoomId}) ->
  broadcast_msg(11005, []),
  Playerlist = get(?DICT_PLAYER_LIST),
  Now = util:unixtime(),
  broadcast_msg(20012, #pbplayerfinalcalc{player_result_list = player_list2pb_final_calc(Playerlist), time = Now,
	room_id = RoomId, round = get(?DICT_ROUND)}),
  Pb = case get(?DICT_ROUND_CALC_PB) of       %% 结算消息数据
		 P = #pbplayerroundcalc{} -> P;
		 _ ->                                                 %%玩家本局结果转成协议
		   #pbplayerroundcalc{player_result_list = player_list2pb_round_calc(Playerlist), time = Now,
			 room_id = RoomId, round = get(?DICT_ROUND), zhuang_id = get(?DICT_ZHUANGJIAID)}
	   end,
  broadcast_msg(20007, Pb),
  next(state_final_calc, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0}).

state_name(_Event, _From, State) ->
  Reply = ok,
  {reply, Reply, state_name, State}.

handle_event(Event,StateName,State) ->
	try
		do_handle_event(Event,StateName,State)
	catch
		_ :Reason ->
			 ?ERR("~p handle_event is exception:~w~nEvent:~w", [?MODULE, Reason, Event]),
	  ?ERR("get_stacktrace:~n~p", [erlang:get_stacktrace()]),
	  continue(StateName, State)    %%    ?DEBUG("~w 毫秒后，进入~w状态", [T, StateName]),
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
	StateData :: #room_paijiu{}, Extra :: term()) ->
  {ok, NextStateName :: atom(), NewStateData :: #room_paijiu{}}).
code_change(_OldVsn, StateName, State, _Extra) ->
  {ok, StateName, State}.

%% 玩家加入游戏
do_handle_event({join_in,Player},StateName,State) ->
	Player0 = case StateName =/= state_waitting  of
		true ->
			Player#player_paijiu{state=?PLAYER_STATE_WATCHING};
		_ ->
			Player
		end,
	put(?DICT_PLAYER_LIST,[Player0|get(?DICT_PLAYER_LIST)]),
	send_room_info(Player0,State),
	%-----------------------------------------------------------
	broadcast_other_msg(Player#plauer_paijiu.id, 20005, player2pbpaijiu(Player0)),
  continue(StateName, State);
%% 开始游戏
do_handle_event({start_game,Player},StateName,State) ->
	case erlang:length(get(?DICT_PLAYER_LIST)) >1 of
		true -> 
			put(?DICT_PERIOD,?ROOM_STATE_START),
			next(state_start_game,State#room_paijiu{ts = util:unixtime(ms), t_cd = 100});  %% 开始成功,则返回下一个状态
		_ ->
			?DEBUG("一个人不能开始游戏~n"),
			continue(StateName,State)							%% 开始游戏失败,则在几毫秒后自动进入StateName的状态
	end;
%% 下注事件处理
do_handle_event({chipin,Playerid,Chipin_num},StateName,State) ->
	Playerlist=get(?DICT_PLAYER_LIST),
	case Playerid =/=get(?DICT_ZHUANGJIAID) of
		true ->	case Player=lists:keyfind(Playerid,#player_paijiu.id,Playerlist) of
					Player1=Player#player_paijiu{chip_num=Chipin_num,state=1,calc_list=[Chipin_num|Player#player_paijiu.calc_list]} ->
						put(?DICT_CAN_COST_CARD,true),
						broadcast_msg(20004, #pbplayerchipin{player_id = Playerid, point_chose = Chipinum}),
						continue(StateName, State);
					_ ->
						continue(StateName, State)
				end;
		_ ->
		  continue(StateName, State)
  end;

 %% 庄家发牌,开牌
do_handle_event({open_paijiu,Zhuangjia_Seatid},StateName,State=#room_paijiu{
	property=#room_paijiu_property{has_guizi=HasGuizi,has_tianjiuwang=HasTianjiuwang,
	has_dijiuwang=HasDijiuwang,has_sanbazha=HasSanbazha}
	}) ->
	card_to_players(get(?DICT_ROOM_TYPE)).
	Paijiulist=get(?DICT_PAIJIU_LIST),
	put(?DICT_PERIOD,?ROOM_STATE_SHOW),
	broadcast_msg(20006, #pbroomstate{state = ?ROOM_STATE_SHOW}),
	%----------------------------------------和庄家比较牌的大小
	
	log_round(State),
	next(state_show, State#room_paijiu{ts = util:unixtime(ms), t_cd = 5000});	%设置亮牌的时间
%% 退出结算界面
do_handle_event({exit_calc,RoleId},StateName=state_round_calc,State) ->
	PlayerList=get(?DICT_PLAYER_LIST),
	case lists:keyfind(RoleId,#player_paijiu.id,PlayerList) of
		Player=#player{state=1,is_exit_calc=false} ->
			PlayerList2=lists:keyreplace(RoleId,#player_paijiu.id,PlayerList,
				Player#player{state=0,is_exit_calc=true}),
			put(?DICT_PLAYER_LIST, PlayerList2),
			%-------------------------------------------------
			broadcast_msg(20011, #pbplayerid{player_id = RoleId}),
			Fun = 
			fun(#player_paijiu{is_exit_calc = IsExitCalc, state = PlayerState}) ->   %% 模式匹配
				(not IsExitCalc) andalso (PlayerState =:= 1) 
			end,
			case lists:filter(Fun, PlayerList2) of   
				[] ->								%% 如果有没退出房间的玩家,则将房间状态置为开始状态
					put(?DICT_PAIJIU_LIST, []),
					put(?DICT_ROUND_CALC_PB, {}),	%% 结算消息数据
					next(state_start_game, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0});
				_ ->
					continue(StateName, State)
			end;  
		_ ->
			continue(StateName, State)
	end;
%%申请退出房间  非房主可以在游戏没开始的时候退出房间   
do_handle_event({exit_room_apply, RoleId}, StateName, State = #room_paijiu{room_id = RoomId, owner_id = OwnerId}) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #room_paijiu.id, PlayerList) of
	Player = #room_paijiu{name = PlayerName, seat_id = SeatId, pid = RPid, icon = Icon,
	  state = PlayerState, is_exit_room = IsExitRoom, is_playing = IsPlaying} ->
		RoleId =/= OwnerId andalso (StateName =:= state_waiting orelse PlayerState =:= ?PLAYER_STATE_WATCHING) ->   %不为房主,且为等待或观战状态
		  [Room = #room{seat_list = SeatList}] = ets:lookup(?ETS_ROOM, RoomId),
		  lib_player_room:api_exit_room(RPid),		%RPid  RolePid	
		  ets:insert(?ETS_ROOM, Room#room{seat_list = [SeatId | SeatList]}),	%% 空座位列表
		  broadcast_msg(11003, #pbbaseplayer{player_id = RoleId, player_name = PlayerName, dismiss_opt = 1, icon = Icon}),
		  put(?DICT_PLAYER_LIST, lists:keydelete(RoleId, #room_paijiu.id, PlayerList)),
		  continue(StateName, State);
		StateName =:= state_waiting andalso RoleId =:= OwnerId ->	% 为房主,则直接解散房间
		  broadcast_msg(11005, []),
		  next(state_final_calc, State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
		true ->
		  Fun = fun(#room_paijiu{is_exit_room = IsExitRoom2}) -> (not IsExitRoom2) end,
		  case lists:all(Fun, PlayerList) of 	%如果lists中所有玩家没退出房间
			true ->
			  case IsPlaying andalso IsExitRoom =:= false of
				true ->
				  PlayerList2 = lists:keyreplace(RoleId, #room_paijiu.id, PlayerList,
				  Player#room_paijiu{is_exit_room = true}),		%更新玩家退出房间数据为true
				  put(?DICT_PLAYER_LIST, PlayerList2),
				  put(?DICT_DISMISS_APPLY_ID, RoleId),
				  put(?DICT_DISMISS_OPT_LIST, [{1, RoleId} | get(?DICT_DISMISS_OPT_LIST)]),	%% 解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
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
%% 其他玩家同意退出房间
do_handle_event({accept_exit_room, RoleId}, StateName = state_exit_room_apply, State) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_paijiu.id, PlayerList) of 		%申请退出房间的玩家的is_exit_room=true
	Player = #player_paijiu{is_exit_room = false, name = PlayerName, is_playing = true, icon = Icon} ->
	  broadcast_msg(11007, #pbbaseplayer{player_id = RoleId, player_name = PlayerName, dismiss_opt = 2, icon = Icon}),
	  put(?DICT_DISMISS_OPT_LIST, [{2, RoleId} | get(?DICT_DISMISS_OPT_LIST)]),  % 将同意申请退出的玩家的id放入opt_list里
	  PlayerList2 = lists:keyreplace(RoleId, #player_paijiu.id, PlayerList,
		Player#player_paijiu{is_exit_room = true}),
	  put(?DICT_PLAYER_LIST, PlayerList2),
	  Fun = fun(#player_paijiu{is_exit_room = IsExitRoom, is_playing = IsPlaying}) ->
		(not IsExitRoom) andalso IsPlaying end,
	  case lists:filter(Fun, PlayerList2) of
		[] ->
		  dismiss_room_log(State),
		  next(state_close_room, State#room_paijiu{ts = util:unixtime(ms), t_cd = 0});
		_ ->
		  continue(StateName, State)
	  end;
	#player_paijiu{is_playing = false} ->
	  role:send_error_msg(RoleId, ?ERR_WATCHING_CANNOT_OPT),
	  continue(StateName, State);
	_ ->
	  continue(StateName, State)
  end;
%%其他人不同意退出房间
do_handle_event({not_accept_exit_room, RoleId}, StateName = state_exit_room_apply, State) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_paijiu.id, PlayerList) of
	#player_paijiu{is_exit_room = false, name = Name, is_playing = true, icon = Icon} ->
	  put(?DICT_PLAYER_LIST, [Player#player_paijiu{is_exit_room = false} || Player <- PlayerList]),
	  broadcast_msg(11009, #pbbaseplayer{player_id = RoleId, player_name = Name, dismiss_opt = 3, icon = Icon}),
	  put(?DICT_DISMISS_OPT_LIST, []),
	  next(get(?DICT_LAST_STATE_NAME), State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
	#player_paijiu{is_playing = false} ->
	  role:send_error_msg(RoleId, ?ERR_WATCHING_CANNOT_OPT),
	  continue(StateName, State);
	_ ->
	  continue(StateName, State)
  end;
%%玩家坐下操作
do_handle_event({sit_down, RoleId}, StateName, State) ->
  PlayerList = get(?DICT_PLAYER_LIST),
  case lists:keyfind(RoleId, #player_paijiu.id, PlayerList) of
	Player = #player_paijiu{state = ?PLAYER_STATE_WATCHING} ->
		broadcast_msg(20015, #pbplayerid{player_id = RoleId}),
		PlayerList2 = lists:keyreplace(RoleId, #player_paijiu.id, PlayerList,
		Player#player_paijiu{state = ?PLAYER_STATE_WAITING}),
	  put(?DICT_PLAYER_LIST, PlayerList2);
	_ ->
	  skip
  end,
  continue(StateName, State);
%%玩家掉线操作
do_handle_event({player_offline, RoleId}, StateName, State) ->
	?DEBUG("~w", [{player_offline, RoleId}]),
	PlayerList = get(?DICT_PLAYER_LIST),
	case lists:keyfind(RoleId, #player_paijiu.id, PlayerList) of
	Player = #player_paijiu{is_online = true} ->
	  	broadcast_other_msg(RoleId, 20002, #pbplayeronline{player_id = RoleId, is_online = false}),
	 	PlayerList2 = lists:keyreplace(RoleId, #player_paijiu.id, PlayerList,
		Player#player_paijiu{is_online = false}),
	  	put(?DICT_PLAYER_LIST, PlayerList2);
	_ ->
	  	skip
  end,
  continue(StateName, State);
%%玩家重连操作
do_handle_event({player_return, RoleId, RolePid}, StateName, State) ->
  	?DEBUG("~w", [{player_return, RoleId}]),
  	PlayerList = get(?DICT_PLAYER_LIST),
  	case lists:keyfind(RoleId, #player_paijiu.id, PlayerList) of
		Player = #player_paijiu{is_online = false, name = Name, is_exit_calc = IsExitCalc, state = PlayerState,is_exit_room = IsExitRoom, icon = Icon} ->
	  		broadcast_other_msg(RoleId, 20002, #pbplayeronline{player_id = RoleId, is_online = true}),
	  		Player2 = Player#player_paijiu{is_online = true, pid = RolePid},
	  		PlayerList2 = lists:keyreplace(RoleId, #player_paijiu.id, PlayerList, Player2),
	  		put(?DICT_PLAYER_LIST, PlayerList2),
	  		send_room_info(Player2, State),
	  		case (StateName =:= state_round_calc) andalso (IsExitCalc =:= false) of
				true ->
			  		send_msg(Player2, 20007, get(?DICT_ROUND_CALC_PB));
				_ ->
			  		skip	
		  	end,
	  		case StateName of
				state_exit_room_apply when PlayerState =/= ?PLAYER_STATE_WATCHING andalso IsExitRoom =:= false ->
				  	put(?DICT_PLAYER_LIST, [P#player_paijiu{is_exit_room = false} || P <- PlayerList2]),
				  	broadcast_msg(11009, #pbbaseplayer{player_id = RoleId, player_name = Name, dismiss_opt = 3, icon = Icon}),
				  	put(?DICT_DISMISS_OPT_LIST, []),
				  	next(get(?DICT_LAST_STATE_NAME), State#room_tuiduizi{ts = util:unixtime(ms), t_cd = 0});
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
  	case lists:keyfind(RoleId, #player_paijiu.id, PlayerList) of
		#player_paijiu{name = PlayerName, icon = PlayerIcon} ->
	 		broadcast_msg(13003, Data#pbmsgchat{id = RoleId, name = PlayerName, icon = PlayerIcon});
		_ ->
	  		skip
 	end,
  	continue(StateName, State);
do_handle_event({gm_dismiss_room}, _StateName, State) ->
  	next(state_close_room, State#player_paijiu{ts = util:unixtime(ms), t_cd = 0});
do_handle_event(Event, StateName, State) ->
  	?DEBUG("handle_event未处理消息：Event[~w], StateName[~w]", [Event, StateName]),
  	continue(StateName, State).


card_to_oneplayer(Number,SeatId)	->
	PlayerList=get(?DICT_PLAYER_LIST),
	Player=lists:keyfind(SeatId,#player.seatid,PlayerList),
	%io:format("card_to_oneplayer:~p~n",[Player]),
	Paijiulist=take_tianjiu(Number),
	Player1=Player#player{cardlist=Paijiulist},
	put(?DICT_PAIJIU_LIST,[Paijiulist|get(?DICT_PAIJIU_LIST)]),
	put(?DICT_PLAYER_LIST,lists:keyreplace(SeatId,#player.seatid,PlayerList,Player1)).
card_to_players(GameType) ->
	Number = case GameType of
		dapaijiu -> 
			4;
		xiaopaijiu -> 
			2
	end,
	Zhuangjia_SeatId=get(?ZHUANGJIA_SEATID),
	%io:format("zhuangjia_seatid:~p~n",[Zhuangjia_SeatId]),
	%io:format("Number:~p~n",[Number]),
	card_to_oneplayer(Number,Zhuangjia_SeatId),
	card_to_oneplayer(Number,next_seat(Zhuangjia_SeatId+1)),
	card_to_oneplayer(Number,next_seat(Zhuangjia_SeatId+2)),
	card_to_oneplayer(Number,next_seat(Zhuangjia_SeatId+3)).

next_seat(SeatId) ->
	case SeatId > 4 of
		true -> 
			SeatId rem 4;
		_	-> 
			SeatId
	end.
%%发牌 Num:发牌的张数
take_tianjiu(Num) ->
	TianjiuList = get(?DICT_PAIJIU_LIST),
	take_poker(Num, TianjiuList, []).
take_poker(Num, TianjiuList, List4) when Num =< 0 ->
	put(?DICT_PAIJIU_LIST, TianjiuList),
	List4;
take_poker(_, TianjiuList = [], List4) ->
	put(?DICT_PAIJIU_LIST, TianjiuList),
	List4;
%从麻将牌列表List5中取出前Num张牌将其放入List4中,呈现给玩家
take_poker(Num, [H|List5], List4) ->
	take_poker(Num - 1, List5, [H|List4]).
%% 和庄家比较点数
compare_with_zhuangjia()->
	Playerlist=get(?DICT_PLAYER_LIST),
	Zhuangjia_Seatid=get(?DICT_ZHUANGJIA_SEATID),
	Zhuangjia_point=point_of_player(lists:keyfind(Zhuangjia_Seatid,#player_paijiu.seat_id,Playerlist)),
	Player1=point_of_player(next_seat(Zhuangjia_Seatid)).

%% 庄家和闲家比较点数
p2p_compare(Zhuangjia=#player_paijiu{playerid=Id1,score_change=ScoreChange1,dapaijiu=#dapaijiu{value=Value1},xiaopaijiu=#xiaopaijiu{value=Value11}},
			Player=#player_paijiu{playerid=Id2,score_change=ScoreChange2,chipin_num=ChipinNum,dapaijiu=#dapaijiu{value=Value2},xiaopaijiu=#xiaopaijiu{value=Value22}}) ->
	Playerlist=get(?DICT_PLAYER_LIST),
	case Id2 =:= Id1 of 
		true -> 
			skip;
		_ ->
			case get(?DICT_ROOM_TYPE) of
				dapaijiu ->
					% io:format("~w player compare_with_zhuangjia~n",[Id2]),
					case Value1 >= Value2 of
						true -> case Value11 >= Value22 of
									true -> 
											io:format("~w player lose!",[Id2]),
											NewPlayerlist=lists:keyreplace(Id1,#player_paijiu.id,Playerlist,NewZhuangjia=Zhuangjia#player_paijiu{score_change=ScoreChange1+ChipNum}),
									_   -> 
											io:format("~w player win and lose!",[Id2])
								end;
						_ ->
							 case Value11 >= Value22 of
								true ->
									io:format("~w  player win and lose!",[Id2]);
								_ -> 
									io:format("~w player win!",[Id2])
							 end
					end;
				xiaopaijiu ->
					case Value11 >=Value22 of
						true ->
							io:format("~w player lose!...",[Id2]);
						_ ->
							io:format("~w player win......!",[Id2])
					end
			end
	end.
ponint_paijiu(Tianjiu1=#tianjiu{num=Number1,property=Property1},Tianjiu2=#tianjiu{num=Number2,property=Property2})    ->
	Fun_maxProperty=
	fun(Pro1,Pro2) ->
		case Pro1 >= Pro2 of
			true ->
				Pro1;
			_ -> 
				Pro2
		end
	end,
	Fun_Property=fun(Pro1,Pro2) ->
		case Pro1 =:=?TIAN orelse Pro2=:=?TIAN of
			true ->
				?TIANGANG;
			_ -> 
				case Pro1 =:=?DI orelse Pro2=:=?DI of
					true -> 
						?DIGANG;
					_ -> 
						Fun_maxProperty(Pro1,Pro2)
				 end
		end
	end,

	case Number1 =:= Number2 andalso Property1 =:= Property2 of                         %% 是否是对子
		true -> 
			Dianshu=#dianshu{sum=Number1,property=duizi_property(Property1)};       
		_   -> 
			case (Number1+Number2) rem 10 of                                         %% 不是对子,计算点数
					9 -> 
						case (Property1 =:= Property2) andalso Property1=:=?DAN of     %% 点数为9的时候,判断是否是皇上
							true -> 
								Dianshu=#dianshu{sum=9,property=?HUANGSHANG};       %% 是皇上
							_   -> 
								Dianshu=#dianshu{sum=9,property=Fun_maxProperty(Property1,Property2)}    %%
						 end;
					0 -> 
						case (Number1 =:= 8 orelse Number2 =:= 8) of                   %% 点数为0的时候,判断是否是天杠,地杠
							true -> 
								Dianshu=#dianshu{sum=0,property=Fun_Property(Property1,Property2)};
							_ ->
								 case (Number1 =:=11 orelse Number2=:=11) of 			%% 点数为0时,有一个为11点,则为鬼子
									true -> 
										Dianshu=#dianshu{sum=0,property=?GUIZI};
									_ -> 
										Dianshu=#dianshu{sum=0,property=Fun_maxProperty(Property1,Property2)}
						 		 end
						 end;
					1 -> 
						case Number1 =:= 12 orelse Number2 =:=12 of 				%% 有一个为12,则为天九王
							true ->
								Dianshu=#dianshu{sum=1,property=?TIANJIUWANG};	
							_->
								case Number1=:=2 orelse Number2=:=2 of
										true ->
											Dianshu=#dianshu{sum=1,property=?DIJIUWANG}; %% 有一个为2 ,则为地九王
										_ 	 ->
											 case Number1=:=3 orelse Number2=:=3 of
													true ->
														Dianshu=#dianshu{sum=1,property=?SANBAZHA};	%% 有一个为3,则为炸弹
													_ 	 ->
														Dianshu=#dianshu{sum=1,property=Fun_maxProperty(Property1,Property2)}
												end
								   end
						 end;
					_ ->
						Dianshu=#dianshu{sum=(Number1+Number2) rem 10,property=Fun_maxProperty(Property1,Property2)}
				end
	end.


point_of_player(Player#player_paijiu{id=PlayerId,cardlist=CardList}) ->
	case get(?DICT_ROOM_TYPE) of 
		dapaijiu ->
			DapaiXiaopai=lists:keysort(#dianshu.value,get_dapai_xiaopai()),
			Xiaopai=lists:nth(1,DapaiXiaopai),
			Dapai=lists:nth(2,DapaiXiaopai),
			Player1=Player#player_paijiu{dapaijiu=#dapaijiu{num=Dapai#dianshu.sum,property=Dapai#dianshu.property,value=Dapai#dianshu.value,
								   xiaopaijiu=#xiaopaijiu{num=Xiaopai#dianshu.sum,property=Xiaopai#dianshu.property,value=Xiaopai#dianshu.value}
			}};
		xiaopaijiu ->
			Xiaopai=ponint_paijiu(lists:nth(1,CardList),lists:nth(2,CardList)),
			Player1=Player#player_paijiu{xiaopaijiu=#xiaopaijiu{num=Xiaopai#dianshu.sum,property=Xiaopai#dianshu.property,value=Xiaopai#dianshu.value}}
	end,
		% io:format("Xiaopai,Dapai:~p~n",[{Xiaopai,Dapai}]),
		% io:format("Player:~p~n",[Player]),                                              
	PlayerList1=lists:keyreplace(PlayerId,#player_paijiu.id,PlayerList,Player1),
	put(?PLAYERLIST,PlayerList1).


%% 得到一个玩家的大牌和小牌
get_dapai_xiaopai() ->
	Dianshulist=get_dianshu_list(),
	Fun=
		fun(Dianshu=#dianshu{sum=Num,property=Property,value=Value}) ->
			NewDianshu=Dianshu#dianshu{value=(Num+1) * Property}
	end,
	NewDianshuList=lists:map(Fun,Dianshulist),      % 1,6   2,5     3,4 
	List16=[lists:nth(1,NewDianshuList),lists:nth(6,NewDianshuList)],
	List34=[lists:nth(3,NewDianshuList),lists:nth(4,NewDianshuList)],
	List25=[lists:nth(2,NewDianshuList),lists:nth(5,NewDianshuList)],
	% io:format("List16,List34,List25:~p~n",[{List16,List34,List25}]),
	Fun1=fun(Dianshu1=#dianshu{value=Value1},Dianshu2=#dianshu{value=Value2}) ->
		case Value1 >=Value2 of
			true ->
				 Dianshu1;
			_ ->
				 Dianshu2
		end
	end,
	Max16=lists:foldl(Fun1,Dianshu=#dianshu{value=0},List16),
	Max25=lists:foldl(Fun1,Dianshu=#dianshu{value=0},List25),
	Max34=lists:foldl(Fun1,Dianshu=#dianshu{value=0},List34),
%   io:format("Max16,Max34,Max25:~p~n",[{Max16,Max34,Max25}]),
	case Max16#dianshu.value >=Max25#dianshu.value of
		true -> 
			case Max16#dianshu.value >=Max34#dianshu.value of
					true -> 	
						List16;
					_ ->
						List34
				end;
		_   ->  
			case Max25#dianshu.value >= Max34#dianshu.value of
					true -> 
						List25;
					_ ->
						List34
				end
	end.

get_dianshu_list() ->
	PlayerList=get(?PLAYERLIST),
	[Tianjiu1|CardList2]=Player#player.cardlist,
	[Tianjiu2|CardList3]=CardList2,
	[Tianjiu3|CardList4]=CardList3,
	[Tianjiu4|CardList5]=CardList4,
	Dianshu1=ponint_paijiu(Tianjiu1,Tianjiu2),
	Dianshu2=ponint_paijiu(Tianjiu1,Tianjiu3),
	Dianshu3=ponint_paijiu(Tianjiu1,Tianjiu4),
	Dianshu4=ponint_paijiu(Tianjiu2,Tianjiu3),
	Dianshu5=ponint_paijiu(Tianjiu2,Tianjiu4),
	Dianshu6=ponint_paijiu(Tianjiu3,Tianjiu4),
	[Dianshu1]++[Dianshu2]++[Dianshu3]++[Dianshu4]++[Dianshu5]++[Dianshu6].
%% 初始化房间的进程属性
do_init(RoomId, Type, Owner, CostCardNum, PayWay, Property) ->
	?INFO("[~w] 正在启动",[?MODULE]),
	put(?DICT_PERIOD,state_waitting),
	put(?DICT_PLAYER_LIST,[Owner]),
	put(?DICT_ROOM_TYPE,Type),
	put(?DICT_ROUND,0),
	put(?DICT_ZHUANGJIAID,Owner#player_paijiu.id),
	put(?DICT_ROUND_ENDTIME,0),
	put(?DICT_NOW_PLAYER,Owner#player_paijiu.id),
	put(?DICT_ROUND_CALC_PB,{}),
	put(?DICT_TIANJIU_LIST,[]),
	put(?DICT_CHIP_IN_ENDTIME,0),
	put(?DICT_CAN_COST_CARD,false),
	{ok,RecordPid}=gambling_record:start(),
	put(?DICT_RECORD_PID,RecordPid),
	init_paijiu(),
	State=#room_paijiu{room_id=RoomId,room_type=Type,ower_id=Owner#player_paijiu.id,
					  cost_card_num=CostCardNum,max_round=CostCardNum*12,
		property=Property#room_paijiu_property{max_round=CostCardNum*12}
	},
	send_room_info(Owner,State),
	?INFO("[~w] 启动完成", [?MODULE]),

	{ok,state_waitting,State}.


%%  初始化一副牌,有多种牌型的点数说明:
%% 	1.1,2 为大,3,4为小,5为最小
init_paijiu()	->
	ListNum2=[2,5,9,11,12],			 %% 每个点2张牌
	ListNum4=[4,7,8,10],			 %% 每个点4张牌
	DianList=lists:seq(2,12),	 		 %% 牌的点数,2 到 12
	Quantitylist=lists:seq(1,5),	 %% 牌的数量,1 到 5
	Fun_number = fun(X) ->
		case lists:member(X,ListNum2) of
			true -> 2;
			_ -> case lists:member(X,ListNum4) of
					true -> 4;
					_	 -> case X of
								3 ->1;
								6 ->5
							end
				end
		end
	end,
	Fun_one = fun(X,AccList) ->
		[#tianjiu{num=X,quantity=Quantity,property=fun_init_property(X,Quantity)} || Quantity <- Quantitylist,Fun_number(X) >= Quantity]++AccList
	end,
	Init_Paijiu_List=lists:foldl(Fun_one,[],DianList),
	put(?INIT_PAIJIU_LIST,Init_Paijiu_List),
	refresh_paijiu().
fun_init_property(X,Quantity)	->
	case X of
			2	->?DI;
			3	->?DAN;
			4	-> case lists:member(Quantity,[1,2]) of
					true -> ?HE;
					_	-> ?CHANG
					end;
			5	->?ZA;
			6	-> case lists:member(Quantity,[1,2]) of
					true ->?CHANG;
					_     ->case lists:member(Quantity,[3,4]) of
								true ->?DUAN;
								_	->?DAN
							end
					end;
			7	-> case lists:member(Quantity,[1,2]) of
						true ->?DUAN;
						_	->?ZA
					end;
			8	-> case lists:member(Quantity,[1,2]) of
						true ->?REN;
						_ ->?ZA
					end;
			9	-> ?ZA;
			10  -> case lists:member(Quantity,[1,2]) of	
						true ->?CHANG;
						_ -> ?DUAN
					end;
			11  -> ?DUAN;
			12	-> ?TIAN
	end.


%% 洗牌
refresh_paijiu()	->
	Fun = fun(_, {Init_Tianjiu_List, New_Tianjiu_List}) ->	% 初始牌列表,新麻将牌列表,从旧牌列表取出一章牌,放入新牌列表
		Tianjiu = rand_list(Init_Tianjiu_List),		% 取一张牌
		%io:format("Tianjiu:~p~n",[Tianjiu]),
		%%list:delete(Ele,List)删除列表中第一个符合这个值的值,返回一个列表
		{lists:delete(Tianjiu, Init_Tianjiu_List), [Tianjiu | New_Tianjiu_List]}  % 将这张牌从初始牌列表中删除,将取出的牌放如一个新列表
	end,
	TianjiuList=get(?INIT_PAIJIU_LIST),
	{[],New_Tianjiu_List2} = lists:foldl(Fun,{TianjiuList,[]},TianjiuList),
	put(?INIT_PAIJIU_LIST,New_Tianjiu_List2),
	put(?PAIJIU_LIST,New_Tianjiu_List2) ,get(?PAIJIU_LIST).

%%玩家本局结果转成协议
player_list2pb_round_calc(Playerlist) ->
	[player2pb_round_calc(Player) || Player <- Playerlist,Player#player_paijiu.is_playing].
player2pb_round_calc(Player) ->
	#pbplayerroundresult{
		player_id = Player#player_paijiu.id,
		score = Player#player_paijiu.score,
		score_change = Player#player_paijiu.score_change
	}.

%%玩家最终结果转成协议
player_list2pb_final_calc(Playerlist) ->
	[player2pb_final_calc(Player) || Player <- Playerlist, Player#player_paijiu.is_playing].
player2pb_final_calc(Player) ->
	Calclist = Player#player_paijiu.calc_list,
	MaxCalc = 
	case Calclist of
		[] ->
			0;
		_ ->
			lists:max(Calclist)
	end,
	#pbplayerfinalresult{
		player_id = Player#player_paijiu.id,
		score = Player#player_paijiu.score,
		max_score = MaxCalc
	}.


%%初始化玩家每一局开始时的数据
round_init_player_list(PlayerList) -> 
	[round_init_player(Player) || Player <- PlayerList].
round_init_player(Player = #player_paijiu{state = ?PLAYER_STATE_WATCHING}) ->  	  %如果玩家是观战状态,就返回该玩家
	Player;
round_init_player(Player) ->
	gambling_record:begin_record(get(?DICT_RECORD_PID), Player#player_paijiu.id),   %在游戏开始前,记录玩家操作的数据
	put(?DICT_DISMISS_OPT_LIST, []),     %% 解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
	Player2 = 
	Player#player_paijiu{
		state = ?PLAYER_STATE_PLAYING, 
		score_change = 0, 
		is_exit_calc = false,
		is_exit_room = false, 
		is_online=true,
		chip_num=0,
		is_playing = true,
		dapaijiu=[],
		xiaopaijiu=[],
		cardlist=[],
	},
	Player2.
	
%% 推送房间数据
send_room_info(Player = #player_paijiu{seat_id = SeatId}, 
	#room_paijiu{
		room_id = RoomId, owner_id = OwnerId,
		max_round = MaxRound, 
		property = 
		#room_paijiu_property{
			banker_type = BK, 
			game_type=GameType,
			has_guizi=HasGuizi,
			has_tianjiuwang=HasTianjiuwang,
			has_dijiuwang=HasDijiuwang,
			has_sanbazha=HasSanbazha,
			score_type=ScoreType,
			}}) ->
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
		#pbroominfopaijiu{
			room_id = RoomId,
			room_owner_id = OwnerId,
			round = get(?DICT_ROUND),
			zhuang_id = get(?DICT_ZHUANGJIAID),
			period = get(?DICT_PERIOD),
			my_seat_id = SeatId,
			player_list = player_list2pb_tuiduizi(get(?DICT_PLAYER_LIST)),
			max_round = MaxRound,
			banker_type = BK,
			score_type=ScoreType,
			game_type=GameType,
			has_guizi=HasGuizi,
			has_tianjiuwang=HasTianjiuwang,
			has_dijiuwang=HasDijiuwang,
			has_sanbazha=HasSanbazha,
			chip_in_time=ChipInTime
	).

%%玩家列表转成协议
player_list2pb_pajiu(Playerlist) ->
	[player2pbpaijiu(Player) || Player <- Playerlist].
player2pbpaijiu(Player) ->
	#pbplayer{
		id = Player#player_pajiu.id,
		icon = Player#player_pajiu.icon,
		name = Player#player_pajiu.name,
		cardlist=Player#player_pajiu.cardlist,
		seat_id = Player#player_pajiu.seat_id,
		state = Player#player_pajiu.state,
		is_online = Player#player_pajiu.is_online,
		score = Player#player_pajiu.score,
		player_chip_list = chip2pblist(Player#player_pajiu.player_chip_list),
		sex = Player#player_pajiu.sex,
		ip = Player#player_pajiu.ip,
		dapaijiu=Player#player_pajiu.dapaijiu,
		xiaopaijiu=Player#player_pajiu.xiaopaijiu,
		chip_num=Player#player_paijiu.chip_num,
		gps = Player#player_pajiu.gps
	}.
next(StateName, State = #room_paijiu{t_cd = Tcd}) ->
  {next_state, StateName, State, Tcd}.

continue(StateName, State = #room_paijiu{ts = Ts, t_cd = Tcd}) ->
  T = time_left(Ts, Tcd),
%%    ?DEBUG("~w 毫秒后，进入~w状态", [T, StateName]),time_left(Ts, Tcd) ->
  T = Tcd - (util:unixtime(ms) - Ts),
  case T > 0 of
	true -> T;
	_ -> 0
  end.

chip2pblist(Chiplist)->
	[chip2pb(Chip) || Chip <- Chiplist].
chip2pb(Chip) ->
	#pbchip{
		chip_num = Chip#chipin.chipin_num
	}.
  		
%% 更新玩家的回放记录
update_player_huifang(PlayerId, OpCode, Data) ->
	HuiFangList = get(?DICT_HUIFANG_LIST),
	put(?DICT_HUIFANG_LIST, [#record_proto{id = PlayerId, opcode = OpCode, data = Data} | HuiFangList]).

%% 发送消息给单个玩家
send_msg(#player_paijiu{id = PlayerId, pid = _RPid, socket = Socket, state = State}, OpCode, Data) ->
	%role:send_msg(RPid, OpCode, Data),
	% lib_send:send_data_to_client(PlayerId, Socket, OpCode, Data),
	lib_send:send_data(Socket, OpCode, Data),
	case State =:= ?PLAYER_STATE_PLAYING andalso lists:member(OpCode, ?PAIJIU_RECORD_LIST) of
		true ->
			%gambling_record:record(get(?DICT_RECORD_PID), PlayerId, OpCode, Data);
			update_player_huifang(PlayerId, OpCode, Data);
		_ ->
			skip
	end.

record_room_info(#player_paijiu{id = PlayerId, seat_id = SeatId}, 
    #room_paijiu{
        room_id = RoomId,
        owner_id = OwnerId, 
        max_round = MaxRound, 
        property = 
         #room_paijiu_property{
            banker_type = BK, 
            round_type=RoundType,
            game_type=GameType,
            has_guizi=HasGuizi,
            has_tianjiuwang=HasTianjiuwang,
            has_sanbazha=HasSanbazha,
            score_type=ScoreType
            }}) ->	
    update_player_huifang(PlayerId, 20001, 
        #pbroominfopaijiu{
			room_id = RoomId,
			room_owner_id = OwnerId,
			round = get(?DICT_ROUND),
			zhuang_id = get(?DICT_ZHUANGJIAID),
			period = get(?DICT_PERIOD),
			my_seat_id = SeatId,
			player_list = player_list2pb_pajiu(get(?DICT_PLAYER_LIST)),
			max_round = MaxRound,
			banker_type = BK,
			score_type = ScoreType,
			game_type=GameType,
            has_guizi=HasGuizi,
            has_tianjiuwang=HasTianjiuwang,
            has_sanbazha=HasSanbazha,
			mahjong_list = totalmahjong2pb(get(?DICT_MAHJONG_LIST)),
			chip_in_time = 0,
        ).


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
  {next_state, StateName, State, T}.

