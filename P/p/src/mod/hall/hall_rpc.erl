%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 五月 2017 15:45
%%%-------------------------------------------------------------------
-module(hall_rpc).
-author("Administrator").

%% API
-export([handle/3]).

-include("cli_erl_proto/pb_11_hall_pb.hrl").
-include("common.hrl").
-include("role.hrl").
-include("room.hrl").
-include("error.hrl").
-include("public_ets.hrl").

%% 加入房间
handle(11000, #pbjoininroom{room_id = RoomId, gps = Gps, is_xbw = IsXbw}, 
        Role = #role{room_id = 0, id = RoleId, pid = RPid,
        connpid = ConnPid,
        wechat_name = Name, 
        balance_total_score = BalanceTotalScore, balance_total_score2 = BalanceTotalScore2,
        icon = Icon, room_card = CardNum, ip = Ip, sex = Sex}) ->
    case ets:lookup(?ETS_ROOM, RoomId) of
        [#room{cost_room_card_num = CostCardNum, pay_way = 2, is_agent_room = false}] when CardNum < CostCardNum ->
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH};
        [#room{seat_list = []}] ->
            {error, ?ERR_ROOM_FULL};
        [#room{is_start = true, property = #room_niuniu_property{forbid_enter = true}}] ->
            {error, ?ERR_ROOM_FORBID_ENTER};
        [#room{is_start = true, property = #room_zhajinhua_property{forbid_enter = true}}] ->
            {error, ?ERR_ROOM_FORBID_ENTER};
        [#room{seat_list = [_], property = #room_doudizhu_property{player_num = 1}}] ->
            {error, ?ERR_ROOM_FORBID_ENTER};
        [#room{pid = RoomPid, type = Type, seat_list = SeatList, property = Property, is_agent_room = IsAgentRoom, creator_id = CreateId}] ->
            CanJoinIn = 
            case IsAgentRoom of
                true ->
                    case role_db:check_agent(CreateId, RoleId) of
                       true ->
                            case role_db:get_card_num(CreateId) >= ?AGENT_ROOM_CARD of
                                true -> 
                                    true;
                                _ -> 
                                    agent_no_card
                            end;
                       _ -> 
                           no_auth
                    end;
                _ ->
                    case IsXbw of
                        true -> 
                            true;
                        _ ->
                            if
                                Type =:= ?ROOM_TYPE_NIUNIU ->
                                    true;
                                true ->
                                    false 
                            end
                    end
            end,
            case CanJoinIn of
                true ->
                    {Seat, _SeatList2} = room_mgr:allocate_seat(SeatList),
                    Mod = room_mgr:get_mod(Type),
                    % ?DEBUG("join RoleId----:~w-----B1---:~w,B2----:~w",[RoleId, BalanceTotalScore, BalanceTotalScore2]),
                    Player = Mod:create_player(RoleId, RPid, ConnPid, 
                        Name, Seat, Icon, Sex, ip_to_str(Ip),
                        Gps, BalanceTotalScore, BalanceTotalScore2, Property),
                    try
                        Mod:join_in(RoomPid, Player)
                    of
                        false ->
                            {error, ?ERR_ROOM_FULL};
                        ok ->
                            %Room2 = Room#room{seat_list = SeatList2},
                            %ets:insert(?ETS_ROOM, Room2),
                            %role_db:update_room_id(RoleId, RoomId),
                            {ok, Role#role{room_id = RoomId, room_pid = RoomPid, room_type = Type}}
                    catch
                        E:W ->
                            ?ERR("加入房间失败E: ~w   W: ~w",[E, W]),
                            {error, ?ERR_ROOM_NOEXIST}
                    end;
                no_auth ->
                    {error, ?ERR_HAVE_NOT_AUTH};
                agent_no_card ->
                    {error, ?ERR_AGENT_NO_CARD};
                false ->
                    {error, ?ERR_ROOM_NOEXIST}
            end;
        _ ->
            {error, ?ERR_ROOM_NOEXIST}
    end;


%% 创建牌九房间
handle(11020,#pbcreateroompaijiu{cost_room_card_num=CostCardNum0,zhuang_type=ZhuangType,gps = Gps,game_type=GameType,has_guizi=HasGuizi,
        has_tianjiuwang=HasTianJiuwang,has_dijiuwang=HasDijiuwang,has_sanbazha=HasSanbazha,score_type=ScoreType},
        #role{room_id = 0, id = RoleId, pid = RPid, wechat_name = Name, icon = Icon, room_card = CardNum, ip = Ip, sex = Sex} = Role)) ->
    CostCardNum=?IIF(?IS_COST_CARD,CostCardNum0,0),
    case CardNum >= CostCardNum of
        true -> room_mgr:create_room(?ROOM_TYPE_PAIJIU,RoleId,RPid,Name,Icon,Sex,ip_to_str(Ip),Gps,CostCardNum,false,0,0,2,
            #room_paijiu_property{banker_type=ZhuangType,game_type=GameType,has_guizi=HasGuizi,
            has_tianjiuwang=HasTianJiuwang,has_dijiuwang=HasDijiuwang,has_sanbazha=HasSanbazha,score_type=ScoreType},Role);
        _ ->
             ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;


%% 创建牛牛房间
handle(11001, #pbcreateroombull{round = RoundType, pay_way = PayWay, has_flower_card = HasFlowerCard,
    three_card = ThreeCard, forbid_enter = ForbidEnter, has_whn = HasWhn, has_zdn = HasZdn,
    has_wxn = HasWxn, double_type = DoubleType, tongbi_score = TongBiScore, banker_type = BankerType, gps = Gps,
    has_push_chip = HasPushChip, forbid_cuopai = ForbidCuoPai, qiang_score_limit = QiangScoreLimit, is_auto = IsAuto,
    is_agent_room = IsAgentRoom, score_type = ScoreType},
    #role{
        room_id = 0, id = RoleId, pid = RPid,
        connpid = ConnPid,
        wechat_name = Name, icon = Icon, room_card = CardNum, 
        ip = Ip, sex = Sex,
        agent_room_num = RoomNum, agent_invite_code = InviteCode, 
        balance_total_score = BalanceTotalScore, balance_total_score2 = BalanceTotalScore2} = Role) ->
    CostCardNum0 = 
    case IsAgentRoom of
        true -> 
            ?IIF(RoundType =:= 1, ?AGENT_ROOM_CARD, ?AGENT_ROOM_CARD * 2);
        _ ->
            Num = ?IIF(RoundType =:= 1, 1, 2),
            (?IIF(PayWay =:= 1, Num * 3, Num))
    end,
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            case (not IsAgentRoom) orelse RoomNum < ?AGENT_ROOM_MAX of
                true ->
                    case (not IsAgentRoom) orelse InviteCode =/= "" of
                        true ->
                            % ?DEBUG("create RoleId----:~w-----B1---:~w,B2----:~w",[RoleId, BalanceTotalScore, BalanceTotalScore2]),
                            room_mgr:create_room(?ROOM_TYPE_NIUNIU, RoleId, RPid, ConnPid, 
                            Name, Icon, Sex, ip_to_str(Ip), Gps, 
                            CostCardNum, IsAgentRoom, PayWay, BalanceTotalScore,BalanceTotalScore2,
                            #room_niuniu_property{has_flower_card = HasFlowerCard, three_card = ThreeCard,
                            double_type = DoubleType, forbid_enter = ForbidEnter, tongbi_score = TongBiScore, banker_type = BankerType,
                            has_whn = HasWhn, has_zdn = HasZdn, has_wxn = HasWxn, has_push_chip = HasPushChip, round_type = RoundType,
                            forbid_cuopai = ForbidCuoPai, qiang_score_limit = QiangScoreLimit, is_auto = IsAuto, is_agent_room = IsAgentRoom,
                            score_type = ScoreType}, Role);
                            %{ok};
                        _ ->
                            {error, ?ERR_NOT_AGENT}
                    end;
                _ ->
                    {error, ?ERR_AGENT_ROOM_LIMIT_ERROR}
            end;
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;
%% 申请退出房间
%% 确认房间解散
handle(11002, _, #role{id = RoleId, room_pid = RoomPid, room_type = RoomType}) when is_pid(RoomPid) ->
    Mod = room_mgr:get_mod(RoomType),
    Mod:exit_room_apply(RoomPid, RoleId),
    {ok};
%% 同意解散
handle(11006, _, #role{id = RoleId, room_pid = RoomPid, room_type = RoomType}) when is_pid(RoomPid) ->
    Mod = room_mgr:get_mod(RoomType),
    Mod:accept_exit_room(RoomPid, RoleId),
    {ok};
%% 不同意解散
handle(11008, _, #role{id = RoleId, room_pid = RoomPid, room_type = RoomType}) when is_pid(RoomPid) ->
    Mod = room_mgr:get_mod(RoomType),
    Mod:not_accept_exit_room(RoomPid, RoleId),
    {ok};
%% 创建诈金花房间
handle(11010, #pbcreateroomgoldflower{cost_room_card_num = CostCardNum0, first_see_poker = FirstSeePoker,
    see_poker_cuopai = SeePokerCuoPai, forbid_enter = FE, has_xiqian = HX, p235_big_aaa = P235AAA, p235_big_baozi = P235Baozi,
    score_type = ScoreType, gps = Gps}, 
    #role{room_id = 0, id = RoleId, pid = RPid, 
    connpid = ConnPid, 
    wechat_name = Name, icon = Icon,
    room_card = CardNum, ip = Ip, sex = Sex} = Role) ->
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            room_mgr:create_room(?ROOM_TYPE_ZHAJINHUA, RoleId, RPid, ConnPid, 
            Name, Icon, Sex, ip_to_str(Ip), Gps, CostCardNum, false,
            0,0,
            2, #room_zhajinhua_property{first_see_poker = FirstSeePoker, see_poker_cuopai = SeePokerCuoPai,
            forbid_enter = FE, has_xiqian = HX, p235_big_aaa = P235AAA, p235_big_baozi = P235Baozi, score_type = ScoreType}, Role);
            % {ok};
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;
%% 创建斗地主房间
handle(11011, #pbcreateroomdoudizhu{cost_room_card_num = CostCardNum0, bomb_top = BombTop,
    show_poker_num = ShowPokerNum, record_poker = RecordPoker, player_num = PlayerNum, 
    call_dizhu = CallDizhu, gps = Gps, let_card = LetCard},
    #role{room_id = 0, id = RoleId, pid = RPid, connpid = ConnPid,
    wechat_name = Name, icon = Icon, room_card = CardNum, ip = Ip, sex = Sex} = Role) ->
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            room_mgr:create_room(?ROOM_TYPE_DOUDIZHU, RoleId, RPid, ConnPid, 
            Name, Icon, Sex, ip_to_str(Ip), Gps, CostCardNum, false,
            0,0,
            2, #room_doudizhu_property{bomb_top = BombTop, show_poker_num = ShowPokerNum, record_poker = RecordPoker,
            player_num = PlayerNum, call_dizhu = CallDizhu, let_card = LetCard}, Role);
            % {ok};
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;
%% 创建陕西挖坑房间
handle(11012, #pbcreateroomshanxiwakeng{cost_room_card_num = CostCardNum0, call_dizhu = CallDizhu,
    is_can_bomb = IsCanBomb, put_off_poker = PutOffPoker, bomb_top = BombTop, gps = Gps}, 
    #role{room_id = 0, id = RoleId,pid = RPid, connpid = ConnPid,
    wechat_name = Name, icon = Icon, room_card = CardNum, ip = Ip, sex = Sex} = Role) ->
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            room_mgr:create_room(?ROOM_TYPE_SHANXI_WAKENG, RoleId, RPid, ConnPid,
            Name, Icon, Sex, ip_to_str(Ip), Gps, CostCardNum, false,
            0,0,
            2, #room_wakeng_property{call_dizhu = CallDizhu, is_can_bomb = IsCanBomb, put_off_poker = PutOffPoker,
            bomb_top = BombTop}, Role);
            % {ok};
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;

%% 创建兰州挖坑房间
handle(11013, #pbcreateroomlanzhouwakeng{cost_room_card_num = CostCardNum0, is_can_bomb = IsCanBomb,
    air_bomb_multiple = AirBombMultiple, put_off_poker = PutOffPoker, bomb_top = BombTop, gps = Gps}, 
    #role{room_id = 0,id = RoleId, pid = RPid, connpid = ConnPid,
    wechat_name = Name, icon = Icon, room_card = CardNum, ip = Ip, sex = Sex} = Role) ->
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            room_mgr:create_room(?ROOM_TYPE_LANZHOU_WAKENG, RoleId, RPid, ConnPid,
            Name, Icon, Sex, ip_to_str(Ip), Gps, CostCardNum, false,
            0,0,
            2, #room_wakeng_property{air_bomb_multiple = AirBombMultiple, is_can_bomb = IsCanBomb,
            put_off_poker = PutOffPoker, bomb_top = BombTop}, Role);
            % {ok};
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;
%% 创建十点半房间
handle(11014, #pbcreateroomtenhalf{cost_room_card_num = CostCardNum0, is_specail_play = IsSpecialPlay,
    max_chip = MaxChip, banker_type = BankerType, gps = Gps}, 
    #role{room_id = 0, id = RoleId, pid = RPid, connpid = ConnPid,
    wechat_name = Name,
    icon = Icon, room_card = CardNum, ip = Ip, sex = Sex} = Role) ->
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            room_mgr:create_room(?ROOM_TYPE_SHIDIANBAN, RoleId, RPid, ConnPid,
            Name, Icon, Sex, ip_to_str(Ip), Gps, CostCardNum, false,
            0,0,
            2, #room_shidianban_property{is_specail_play = IsSpecialPlay, max_chip = MaxChip, banker_type = BankerType}, Role);
            % {ok};
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;
%% 创建推对子房间
handle(11015, 
    #pbcreateroompushpairs{
        cost_room_card_num = CostCardNum0, 
        zhuang_type = ZhuangType,
        score_type = ScoreType, 
        is_red_half = IsRedHalf, 
        % pairs_double = PairsDouble, 
        nine_double = NineDouble,
        is_one_red = IsOneRed,
        is_river = Isriver, 
        gps = Gps,
        xian_double = XianDouble,
        zhuang_double = ZhuangDouble}, 
    #role{
        room_id = 0, 
        id = RoleId, 
        pid = RPid,
        connpid = ConnPid, 
        wechat_name = Name,
        icon = Icon, 
        room_card = CardNum, 
        ip = Ip, sex = Sex} = Role) ->
    io:format("创建推对子房间............~n"),
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            room_mgr:create_room(
                ?ROOM_TYPE_TUIDUIZI, RoleId, RPid, ConnPid,
                Name, Icon,
                Sex, ip_to_str(Ip), Gps, CostCardNum, false,
                0, 0, 2, 
                #room_tuiduizi_property{
                    banker_type = ZhuangType, 
                    point_chose = ScoreType, 
                    is_red_half = IsRedHalf,
                    % pairs_double = PairsDouble, 
                    is_one_red = IsOneRed, 
                    is_river = Isriver,
                    nine_double = NineDouble,
                    xian_double = XianDouble,
                    zhuang_double = ZhuangDouble}, Role),
            ?INFO("创建房间成功!................");
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;
%% 关闭代理房
handle(11016, #pbnumber{num = RoomId}, Role = #role{id = RoleId, connpid = ConnPid, agent_room_num = Num}) ->
    case ets:lookup(?ETS_ROOM, RoomId) of
        [#room{creator_id = RoleId, pid = RoomPid}] ->
            room_niuniu:gm_dismiss_room(RoomPid),
            % lib_send:send_async(ConnPid, 11017, #pbnumber{num = RoomId}),
            lib_send:send_data(ConnPid, 11017, #pbnumber{num = RoomId}),
            Num2 = Num - 1,
            role_db:update_agent_room_num(RoleId, Num2),
            {ok, Role#role{agent_room_num = Num2}};
        _ ->
            {ok}
    end;
%% 创建三代房间
handle(11019, #pbcreateroomsandai{cost_room_card_num = CostCardNum0, is_card_num = IsCardNum, score_type = ScoreType,
    three_take = ThreeTake, force_card = ForceCard, has_aircraft = HasAircraft, pan_force1 = PanForce1, pan_force2 = PanForce2,
    pan_force3 = PanForce3, pan_force4 = PanForce4, pan_force5 = PanForce5, gps = Gps}, 
    #role{room_id = 0, id = RoleId, connpid = ConnPid,
    pid = RPid, wechat_name = Name, icon = Icon, room_card = CardNum, ip = Ip, sex = Sex} = Role) ->
    CostCardNum = ?IIF(?IS_COST_CARD, CostCardNum0, 0),
    case CardNum >= CostCardNum of
        true ->
            room_mgr:create_room(?ROOM_TYPE_SANDAI, RoleId, RPid, ConnPid,
            Name, Icon, Sex, ip_to_str(Ip), Gps, CostCardNum, false,
            0,0,
            2, #room_sandai_property{is_card_num = IsCardNum, score_type = ScoreType, three_take = ThreeTake,
            force_card = ForceCard, has_aircraft = HasAircraft, pan_force1 = PanForce1, pan_force2 = PanForce2,
            pan_force3 = PanForce3, pan_force4 = PanForce4, pan_force5 = PanForce5}, Role);
            % {ok};
        _ ->
            ?DEBUG("房卡数不够，CostCardNum:~w, CardNum:~w", [CostCardNum, CardNum]),
            {error, ?ERR_ROOM_CARD_NOT_ENOUGH}
    end;
handle(_OpCode, _Data, _Role) ->
    ?DEBUG("没处理，OpCode:~w,Data:~w, room_id:~w", [_OpCode, _Data, _Role#role.room_id]),
    {ok}.

ip_to_str(Ip) ->
    L = tuple_to_list(Ip),
    Fun = 
    fun(Num, "") ->
            integer_to_list(Num);
        (Num, Str) ->
            lists:concat([Num, ".", Str])
    end,
    lists:foldl(Fun, "", L).