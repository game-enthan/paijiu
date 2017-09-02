-ifndef(PBCHIP_PB_H).
-define(PBCHIP_PB_H, true).
-record(pbchip, {
    chip_num = erlang:error({required, chip_num})
}).
-endif.

-ifndef(PBCHIPINTIME_PB_H).
-define(PBCHIPINTIME_PB_H, true).
-record(pbchipintime, {
    time = erlang:error({required, time})
}).
-endif.

-ifndef(PBPAIJIU_PB_H).
-define(PBPAIJIU_PB_H, true).
-record(pbpaijiu, {
    num = erlang:error({required, num}),
    quantity = erlang:error({required, quantity})
}).
-endif.

-ifndef(PBPAIJIULIST_PB_H).
-define(PBPAIJIULIST_PB_H, true).
-record(pbpaijiulist, {
    total_paijiu_list = []
}).
-endif.

-ifndef(PBPLAYER_PB_H).
-define(PBPLAYER_PB_H, true).
-record(pbplayer, {
    id = erlang:error({required, id}),
    icon = erlang:error({required, icon}),
    name = erlang:error({required, name}),
    cardlist= erlang:error({required, cardlist}),
    seat_id = erlang:error({required, seat_id}),
    state = erlang:error({required, state}),
    is_online = erlang:error({required, is_online}),
    score = erlang:error({required, score}),
    player_chip_list = [],
    chip_num=erlang:error({required},chip_num),
    sex = erlang:error({required, sex}),
    ip = erlang:error({required, ip}),
    dapaijiu=erlang:error({required, dapaijiu}),
    xiaopaijiu=erlang:error({required, xiaopaijiu}),
    gps = erlang:error({required, gps})
}).
-endif.

-ifndef(PBPLAYERCHIPIN_PB_H).
-define(PBPLAYERCHIPIN_PB_H, true).
-record(pbplayerchipin, {
    player_id = erlang:error({required, player_id}),
    point_chose = erlang:error({required, point_chose}),
}).
-endif.

-ifndef(PBPLAYERFINALCALC_PB_H).
-define(PBPLAYERFINALCALC_PB_H, true).
-record(pbplayerfinalcalc, {
    player_result_list = [],
    time = erlang:error({required, time}),
    room_id = erlang:error({required, room_id}),
    round = erlang:error({required, round})
}).
-endif.

-ifndef(PBPLAYERFINALRESULT_PB_H).
-define(PBPLAYERFINALRESULT_PB_H, true).
-record(pbplayerfinalresult, {
    player_id = erlang:error({required, player_id}),
    score = erlang:error({required, score}),
    max_score = erlang:error({required, max_score})
}).
-endif.

-ifndef(PBPLAYERID_PB_H).
-define(PBPLAYERID_PB_H, true).
-record(pbplayerid, {
    player_id = erlang:error({required, player_id})
}).
-endif.

-ifndef(PBPLAYERPAIJIULIST_PB_H).
-define(PBPLAYERPAIJIULIST_PB_H, true).
-record(pbplayerpaijiulist, {
    paijiu_list = [],
    paijiu_dianshu = erlang:error({required, paijiu_dianshu}),
    paijiu_property = erlang:error({required, paijiu_property}),
    paijiu_value= erlang:error({required, paijiu_value}),
}).
-endif.

-ifndef(PBPLAYERONLINE_PB_H).
-define(PBPLAYERONLINE_PB_H, true).
-record(pbplayeronline, {
    player_id = erlang:error({required, player_id}),
    is_online = erlang:error({required, is_online})
}).
-endif.

-ifndef(PBPLAYERROUNDCALC_PB_H).
-define(PBPLAYERROUNDCALC_PB_H, true).
-record(pbplayerroundcalc, {
    player_result_list = [],
    time = erlang:error({required, time}),
    room_id = erlang:error({required, room_id}),
    round = erlang:error({required, round}),
    zhuang_id = erlang:error({required, zhuang_id})
}).
-endif.

-ifndef(PBPLAYERROUNDRESULT_PB_H).
-define(PBPLAYERROUNDRESULT_PB_H, true).
-record(pbplayerroundresult, {
    player_id = erlang:error({required, player_id}),
    score = erlang:error({required, score}),
    score_change = erlang:error({required, score_change})
}).
-endif.

-ifndef(PBROOMINFOTUIDUIZI_PB_H).
-define(PBROOMINFOTUIDUIZI_PB_H, true).
-record(pbroominfopaijiu, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    zhuang_id = erlang:error({required, zhuang_id}),
    period = erlang:error({required, period}),
    my_seat_id = erlang:error({required, my_seat_id}),
    player_list = [],
    max_round = erlang:error({required, max_round}),
    banker_type = erlang:error({required, banker_type}),
    score_type = erlang:error({required, score_type}),
    game_type =erlang:error({required, game_type}),
    has_guizi =erlang:error({required, has_guizi}),
    has_tianjiuwang =erlang:error({required, has_tianjiuwang}),
    has_dijiuwang =erlang:error({required, has_dijiuwang}),
    has_sanbazha =erlang:error({required, has_sanbazha}),
    chip_in_time = erlang:error({required, chip_in_time}),
}).
-endif.

%% 牌九房间进程的状态信息
-ifndef(PBROOMSTATE_PB_H).
-define(PBROOMSTATE_PB_H, true).
-record(pbroomstate, {
    state = erlang:error({required, state})
}).
-endif.

-ifndef(PBSHAIZI_PB_H).
-define(PBSHAIZI_PB_H, true).
-record(pbshaizi, {
    num1 = erlang:error({required, num1}),
    num2 = erlang:error({required, num2})
}).
-endif.

