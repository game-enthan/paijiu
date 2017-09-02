-ifndef(PBCHIP_PB_H).
-define(PBCHIP_PB_H, true).
-record(pbchip, {
    chip_type = erlang:error({required, chip_type}),
    chip_num = erlang:error({required, chip_num})
}).
-endif.

-ifndef(PBCHIPINTIME_PB_H).
-define(PBCHIPINTIME_PB_H, true).
-record(pbchipintime, {
    time = erlang:error({required, time})
}).
-endif.

-ifndef(PBMAHJONG_PB_H).
-define(PBMAHJONG_PB_H, true).
-record(pbmahjong, {
    num = erlang:error({required, num}),
    quantity = erlang:error({required, quantity})
}).
-endif.

-ifndef(PBMAHJONGLIST_PB_H).
-define(PBMAHJONGLIST_PB_H, true).
-record(pbmahjonglist, {
    total_mahjong_list = []
}).
-endif.

-ifndef(PBPLAYER_PB_H).
-define(PBPLAYER_PB_H, true).
-record(pbplayer, {
    id = erlang:error({required, id}),
    icon = erlang:error({required, icon}),
    name = erlang:error({required, name}),
    seat_id = erlang:error({required, seat_id}),
    state = erlang:error({required, state}),
    is_online = erlang:error({required, is_online}),
    score = erlang:error({required, score}),
    player_chip_list = [],
    sex = erlang:error({required, sex}),
    ip = erlang:error({required, ip}),
    gps = erlang:error({required, gps})
}).
-endif.

-ifndef(PBPLAYERCHIPIN_PB_H).
-define(PBPLAYERCHIPIN_PB_H, true).
-record(pbplayerchipin, {
    player_id = erlang:error({required, player_id}),
    point_chose = erlang:error({required, point_chose}),
    mohjong_point = erlang:error({required, mohjong_point})
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

-ifndef(PBPLAYERMAHJONGLIST_PB_H).
-define(PBPLAYERMAHJONGLIST_PB_H, true).
-record(pbplayermahjonglist, {
    mahjong_list = [],
    mahjong_dianshu = erlang:error({required, mahjong_dianshu}),
    mahjong_type = erlang:error({required, mahjong_type}),
    style
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
-record(pbroominfotuiduizi, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    zhuang_id = erlang:error({required, zhuang_id}),
    period = erlang:error({required, period}),
    my_seat_id = erlang:error({required, my_seat_id}),
    player_list = [],
    max_round = erlang:error({required, max_round}),
    banker_type = erlang:error({required, banker_type}),
    point_chose = erlang:error({required, point_chose}),
    is_red_half = erlang:error({required, is_red_half}),
    nine_double = erlang:error({required, nine_double}),
    is_one_red = erlang:error({required, is_one_red}),
    is_river = erlang:error({required, is_river}),
    mahjong_list = erlang:error({required, mahjong_list}),
    chip_in_time = erlang:error({required, chip_in_time}),
    xian_double = erlang:error({required, xian_double}),
    zhuang_double = erlang:error({required, zhuang_double})
}).
-endif.

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

