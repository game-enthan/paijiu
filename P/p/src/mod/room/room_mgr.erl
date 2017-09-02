%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 五月 2017 16:09
%%%-------------------------------------------------------------------
-module(room_mgr).
-author("Administrator").

-behaviour(gen_server).

%% API
-export([
    start_link/0,
    create_room/12,
    create_room/16,
    allocate_seat/1,
    get_mod/1,
    get_seat_list/1,
    get_room_id_by_owner_id/1,
    get_balance_config_by_type/1,
    dis_room/1
]).

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-include("common.hrl").
-include("public_ets.hrl").
-include("room.hrl").
-include("role.hrl").
-include("error.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

-define(SERVER, ?MODULE).

-record(state, {
    max_room_id = 999999
}).

%% 解散房间
dis_room(RoomId) ->
    case ets:lookup(?ETS_ROOM, RoomId) of
        [#room{type = Type, pid = RoomPid}] ->
            Mod = room_mgr:get_mod(Type),
            Mod:gm_dismiss_room(RoomPid),
            0;
        _ ->
            1
    end.

%%%===================================================================
%%% API
%%%===================================================================
%% 创建房间
create_room(Type, OwnerId, RPid, Name, Icon, Sex, Ip, Gps, CostCardNum, IsAgentRoom, PayWay, Property) ->
    gen_server:cast(
        ?MODULE, 
        {create_room, 
        Type, OwnerId, 
        RPid, Name, 
        Icon, Sex, Ip, Gps, 
        CostCardNum, IsAgentRoom,
        PayWay, Property}).

%% 创建房间
create_room(Type, OwnerId, RPid, Socket, Name, Icon, Sex, Ip, Gps, CostCardNum, IsAgentRoom, PayWay, BalanceTotalScore, BalanceTotalScore2, Property, Role) ->
    ?INFO("创建一个房间"),
    Mod = get_mod(Type),
    SeatList = get_seat_list(Type),
    {Seat, SeatList2} = 
    case IsAgentRoom of
        true -> 
            {0, SeatList};
        _ -> 
            allocate_seat(SeatList)
    end,
    Owner = Mod:create_player(OwnerId, RPid, Socket, Name, Seat, Icon, Sex, Ip, Gps, BalanceTotalScore, BalanceTotalScore2, Property),
    RoomId = get_room_id(0),
    case Mod:start(RoomId, Type, Owner, CostCardNum, PayWay, Property) of
        {ok, Pid} -> %% Pid 是房间的fsm进程pid
            Room = 
            #room{
                id = RoomId, pid = Pid, owner_id = OwnerId, 
                cost_room_card_num = CostCardNum, 
                type = Type, pay_way = PayWay,
                property = Property, seat_list = SeatList2, 
                creator_id = ?IIF(IsAgentRoom, OwnerId, 0), 
                is_agent_room = IsAgentRoom},
            ets:insert(?ETS_ROOM, Room),
            case IsAgentRoom of
                false ->
                    NewRole = Role#role{room_id = RoomId, room_pid = Pid, room_type = Type},
                    role_db:update_room_id(OwnerId, RoomId),
                    {ok, NewRole};
                _ ->
                    Num = Role#role.agent_room_num,
                    {ok, Role#role{agent_room_num = Num + 1}}
            end;
        _Err ->
            ?ERR("创建房间失败，_ERR:~w", [_Err]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end.
%% 分配座位
allocate_seat(SeatList) ->
    Seat = util:rand_list(SeatList),
    {Seat, lists:delete(Seat, SeatList)}.

%% 获取房间类型对应的模块
get_mod(?ROOM_TYPE_NIUNIU) -> room_niuniu;
get_mod(?ROOM_TYPE_ZHAJINHUA) -> room_zhajinhua;
get_mod(?ROOM_TYPE_DOUDIZHU) -> room_doudizhu;
get_mod(?ROOM_TYPE_SHANXI_WAKENG) -> room_wakeng;
get_mod(?ROOM_TYPE_LANZHOU_WAKENG) -> room_wakeng;
get_mod(?ROOM_TYPE_SHIDIANBAN) -> room_shidianban;
get_mod(?ROOM_TYPE_TUIDUIZI) -> room_tuiduizi;
get_mod(?ROOM_TYPE_SANDAI) -> room_sandai;
get_mod(_) -> undefined.

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
    ?INFO("[~w] 正在启动", [?MODULE]),
    ets:new(?ETS_ROOM, [named_table, {keypos, #room.id}, set, public]),
    ets:new(?ETS_BALANCE_CONFIG, [named_table, {keypos, #balance_config.type}, set, public]),
    init_balance_config(),
    process_flag(trap_exit, true),
    erlang:send_after(300 * 1000, self(), flush_balance_config),
    ?INFO("[~w] 启动完成", [?MODULE]),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
%% 创建房间
handle_cast({create_room, Type, OwnerId, RPid, Name, Icon, Sex, Ip, Gps, CostCardNum, IsAgentRoom, PayWay, Property}, State) ->
    Mod = get_mod(Type),
    SeatList = get_seat_list(Type),
    {Seat, SeatList2} = 
    case IsAgentRoom of
        true -> 
            {0, SeatList};
        _ -> 
            allocate_seat(SeatList)
    end,
    Owner = Mod:create_player(OwnerId, RPid, Name, Seat, Icon, Sex, Ip, Gps, Property),
    RoomId = get_room_id(0),
    case Mod:start(RoomId, Type, Owner, CostCardNum, PayWay, Property) of
        {ok, Pid} -> %% Pid 是房间的fsm进程pid
            Room = 
            #room{
                id = RoomId, pid = Pid, owner_id = OwnerId, 
                cost_room_card_num = CostCardNum, 
                type = Type, pay_way = PayWay,
                property = Property, seat_list = SeatList2, 
                creator_id = ?IIF(IsAgentRoom, OwnerId, 0), 
                is_agent_room = IsAgentRoom},
            ets:insert(?ETS_ROOM, Room),
            %% 此处异步操作，会有些问题
            role:apply(async, RPid, {lib_player_room, create_room_success, [RoomId, Pid, Type, IsAgentRoom]}),
            {noreply, State};
        _ ->
            {noreply, State}
    end;
handle_cast(_Request, State) ->
    ?DEBUG("handle_cast 没处理消息：~w", [_Request]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(flush_balance_config, State) ->
    % ?DEBUG("1---------------------------------------------"),
    init_balance_config(),
    erlang:send_after(300 * 1000, self(), flush_balance_config),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% 棋牌类型对应初始座位列表
get_seat_list(?ROOM_TYPE_NIUNIU) -> [1,2,3,4,5,6,7];
get_seat_list(?ROOM_TYPE_ZHAJINHUA) -> [1,2,3,4,5,6,7];
get_seat_list(?ROOM_TYPE_DOUDIZHU) -> [1,2,3];
get_seat_list(?ROOM_TYPE_SHANXI_WAKENG) -> [1,2,3];
get_seat_list(?ROOM_TYPE_LANZHOU_WAKENG) -> [1,2,3];
get_seat_list(?ROOM_TYPE_SHIDIANBAN) -> [1,2,3,4,5,6,7];
get_seat_list(?ROOM_TYPE_TUIDUIZI) -> [1,2,3,4,5,6,7];
get_seat_list(?ROOM_TYPE_SANDAI) -> [1,2,3];
get_seat_list(_) -> [].

%% 获取房间id
get_room_id(Times) when Times > 1000 ->
    get_room_id_2(100000);
get_room_id(Times) ->
    Id = util:rand(100000, 999999),
    case ets:member(?ETS_ROOM, Id) of
        true ->
            get_room_id(Times + 1);
        _ ->
            Id
    end.
get_room_id_2(Id) ->
    case ets:member(?ETS_ROOM, Id) of
        true ->
            get_room_id_2(Id + 1);
        _ ->
            Id
    end.

get_room_id_by_owner_id(OwnerId) ->
    Fun = 
    ets:fun2ms(fun(#room{owner_id = Id, id = RoomId, is_agent_room = IsAgentRoom}) 
        when Id =:= OwnerId andalso IsAgentRoom =:= false ->
            RoomId
    end),
    ets:select(?ETS_ROOM, Fun).

init_balance_config() ->
    case do_data_of_mysql:load_all_balance_config() of
        false ->
            pass;
        List ->
            lists:foreach(fun([_Id, Type, IsOpen, RangePorb]) ->
                {ok, RangePorb2} = util:bitstring_to_term(RangePorb),
                case RangePorb2 of
                    R when is_list(R) ->
                        ets:insert(?ETS_BALANCE_CONFIG, #balance_config{type = Type, is_open = IsOpen, list = RangePorb2});
                    _E ->
                        ?ERR("balance_config is err: ~w", [_E])
                end
            end,    
            List)
    end.

get_balance_config_by_type(Type) when is_integer(Type) ->
    case ets:lookup(?ETS_BALANCE_CONFIG, Type) of
        [] ->
            false;
        [#balance_config{is_open = 0}] ->
            false;
        [#balance_config{list = List}] ->
            List
    end;
get_balance_config_by_type(_T) ->
    ?ERR("get_balance_config_by_type  _type:  ~w", [_T]),
    false.
