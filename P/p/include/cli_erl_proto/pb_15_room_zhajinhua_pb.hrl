-ifndef(PBZHAJINHUANUMBER_PB_H).
-define(PBZHAJINHUANUMBER_PB_H, true).
-record(pbzhajinhuanumber, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYER_PB_H).
-define(PBZHAJINHUAPLAYER_PB_H, true).
-record(pbzhajinhuaplayer, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    score = erlang:error({required, score}),
    chip = erlang:error({required, chip}),
    seat_id = erlang:error({required, seat_id}),
    icon = erlang:error({required, icon}),
    state = erlang:error({required, state}),
    is_online = erlang:error({required, is_online}),
    is_see_poker = erlang:error({required, is_see_poker}),
    pbzhajinhuapokerlist = [],
    sex = erlang:error({required, sex}),
    ip = erlang:error({required, ip}),
    gps = erlang:error({required, gps}),
    style
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERCHIPIN_PB_H).
-define(PBZHAJINHUAPLAYERCHIPIN_PB_H, true).
-record(pbzhajinhuaplayerchipin, {
    player_id = erlang:error({required, player_id}),
    chip_in = erlang:error({required, chip_in}),
    type = erlang:error({required, type}),
    total_chip_in = erlang:error({required, total_chip_in})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERFINALCALC_PB_H).
-define(PBZHAJINHUAPLAYERFINALCALC_PB_H, true).
-record(pbzhajinhuaplayerfinalcalc, {
    player_result_list = [],
    time = erlang:error({required, time}),
    room_id = erlang:error({required, room_id})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERFINALRESULT_PB_H).
-define(PBZHAJINHUAPLAYERFINALRESULT_PB_H, true).
-record(pbzhajinhuaplayerfinalresult, {
    player_id = erlang:error({required, player_id}),
    max_style = erlang:error({required, max_style}),
    score = erlang:error({required, score}),
    max_score_gain = erlang:error({required, max_score_gain}),
    win_num = erlang:error({required, win_num}),
    lost_num = erlang:error({required, lost_num})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERID_PB_H).
-define(PBZHAJINHUAPLAYERID_PB_H, true).
-record(pbzhajinhuaplayerid, {
    player_id = erlang:error({required, player_id})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERONLINE_PB_H).
-define(PBZHAJINHUAPLAYERONLINE_PB_H, true).
-record(pbzhajinhuaplayeronline, {
    player_id = erlang:error({required, player_id}),
    is_online = erlang:error({required, is_online})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERROUNDCALC_PB_H).
-define(PBZHAJINHUAPLAYERROUNDCALC_PB_H, true).
-record(pbzhajinhuaplayerroundcalc, {
    player_result_list = [],
    time = erlang:error({required, time}),
    room_id = erlang:error({required, room_id}),
    round = erlang:error({required, round}),
    zhuang_id = erlang:error({required, zhuang_id}),
    xiqian_num = erlang:error({required, xiqian_num})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERROUNDRESULT_PB_H).
-define(PBZHAJINHUAPLAYERROUNDRESULT_PB_H, true).
-record(pbzhajinhuaplayerroundresult, {
    player_id = erlang:error({required, player_id}),
    pbzhajinhuapokerlist = [],
    style = erlang:error({required, style}),
    score = erlang:error({required, score}),
    score_change = erlang:error({required, score_change}),
    is_give_up = erlang:error({required, is_give_up})
}).
-endif.

-ifndef(PBZHAJINHUAPLAYERVS_PB_H).
-define(PBZHAJINHUAPLAYERVS_PB_H, true).
-record(pbzhajinhuaplayervs, {
    player_id1 = erlang:error({required, player_id1}),
    player_id2 = erlang:error({required, player_id2}),
    win_player_id = erlang:error({required, win_player_id})
}).
-endif.

-ifndef(PBZHAJINHUAPOKER_PB_H).
-define(PBZHAJINHUAPOKER_PB_H, true).
-record(pbzhajinhuapoker, {
    num = erlang:error({required, num}),
    flower = erlang:error({required, flower})
}).
-endif.

-ifndef(PBZHAJINHUAPOKERLIST_PB_H).
-define(PBZHAJINHUAPOKERLIST_PB_H, true).
-record(pbzhajinhuapokerlist, {
    pbzhajinhuapokerlist = [],
    style
}).
-endif.

-ifndef(PBZHAJINHUAROOMINFO_PB_H).
-define(PBZHAJINHUAROOMINFO_PB_H, true).
-record(pbzhajinhuaroominfo, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    max_round = erlang:error({required, max_round}),
    first_see_poker = erlang:error({required, first_see_poker}),
    see_poker_cuopai = erlang:error({required, see_poker_cuopai}),
    forbid_enter = erlang:error({required, forbid_enter}),
    has_xiqian = erlang:error({required, has_xiqian}),
    p235_big_baozi = erlang:error({required, p235_big_baozi}),
    p235_big_aaa = erlang:error({required, p235_big_aaa}),
    score_type = erlang:error({required, score_type}),
    zhuang_id = erlang:error({required, zhuang_id}),
    my_seat_id = erlang:error({required, my_seat_id}),
    player_list = [],
    period = erlang:error({required, period}),
    one_chip = erlang:error({required, one_chip}),
    total_chip = erlang:error({required, total_chip}),
    lunshu = erlang:error({required, lunshu}),
    max_lunshu = erlang:error({required, max_lunshu}),
    action_player_id = erlang:error({required, action_player_id})
}).
-endif.

-ifndef(PBZHAJINHUAROOMSTATE_PB_H).
-define(PBZHAJINHUAROOMSTATE_PB_H, true).
-record(pbzhajinhuaroomstate, {
    state = erlang:error({required, state})
}).
-endif.

-ifndef(PBPBZHAJINHUAPLAYERCHIPINLIST_PB_H).
-define(PBPBZHAJINHUAPLAYERCHIPINLIST_PB_H, true).
-record(pbpbzhajinhuaplayerchipinlist, {
    chip_in_list = []
}).
-endif.

