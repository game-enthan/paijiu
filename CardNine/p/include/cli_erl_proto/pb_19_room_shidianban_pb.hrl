-ifndef(PBADDCHIPIN_PB_H).
-define(PBADDCHIPIN_PB_H, true).
-record(pbaddchipin, {
    chipnum = erlang:error({required, chipnum}),
    is_add_chipin = erlang:error({required, is_add_chipin})
}).
-endif.

-ifndef(PBALLPLAYERPOKERLIST_PB_H).
-define(PBALLPLAYERPOKERLIST_PB_H, true).
-record(pballplayerpokerlist, {
    player_poker_list = []
}).
-endif.

-ifndef(PBCHIPIN_PB_H).
-define(PBCHIPIN_PB_H, true).
-record(pbchipin, {
    chipnum = erlang:error({required, chipnum})
}).
-endif.

-ifndef(PBPLAYER_PB_H).
-define(PBPLAYER_PB_H, true).
-record(pbplayer, {
    id = erlang:error({required, id}),
    icon = erlang:error({required, icon}),
    name = erlang:error({required, name}),
    chipnum = erlang:error({required, chipnum}),
    seat_id = erlang:error({required, seat_id}),
    state = erlang:error({required, state}),
    poker_dianshu = erlang:error({required, poker_dianshu}),
    poker_list = [],
    is_take_poker = erlang:error({required, is_take_poker}),
    is_online = erlang:error({required, is_online}),
    score = erlang:error({required, score}),
    poker_num = erlang:error({required, poker_num}),
    is_add_chipin = erlang:error({required, is_add_chipin}),
    sex = erlang:error({required, sex}),
    ip = erlang:error({required, ip}),
    gps = erlang:error({required, gps}),
    style
}).
-endif.

-ifndef(PBPLAYERCHIPIN_PB_H).
-define(PBPLAYERCHIPIN_PB_H, true).
-record(pbplayerchipin, {
    player_id = erlang:error({required, player_id}),
    chipnum = erlang:error({required, chipnum})
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
    result = erlang:error({required, result}),
    max_round_score = erlang:error({required, max_round_score}),
    score = erlang:error({required, score}),
    win = erlang:error({required, win})
}).
-endif.

-ifndef(PBPLAYERID_PB_H).
-define(PBPLAYERID_PB_H, true).
-record(pbplayerid, {
    player_id = erlang:error({required, player_id})
}).
-endif.

-ifndef(PBPLAYERONLINE_PB_H).
-define(PBPLAYERONLINE_PB_H, true).
-record(pbplayeronline, {
    player_id = erlang:error({required, player_id}),
    is_online = erlang:error({required, is_online})
}).
-endif.

-ifndef(PBPLAYERPOKERLIST_PB_H).
-define(PBPLAYERPOKERLIST_PB_H, true).
-record(pbplayerpokerlist, {
    player_id = erlang:error({required, player_id}),
    poker_list = [],
    poker_dianshu = erlang:error({required, poker_dianshu}),
    style
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
    poker_list = [],
    poker_dianshu = erlang:error({required, poker_dianshu}),
    style = erlang:error({required, style}),
    score = erlang:error({required, score}),
    score_change = erlang:error({required, score_change})
}).
-endif.

-ifndef(PBPOKER_PB_H).
-define(PBPOKER_PB_H, true).
-record(pbpoker, {
    num = erlang:error({required, num}),
    flower = erlang:error({required, flower})
}).
-endif.

-ifndef(PBPOKERLIST_PB_H).
-define(PBPOKERLIST_PB_H, true).
-record(pbpokerlist, {
    poker_list = [],
    style = erlang:error({required, style})
}).
-endif.

-ifndef(PBROOMINFOSHIDIANBAN_PB_H).
-define(PBROOMINFOSHIDIANBAN_PB_H, true).
-record(pbroominfoshidianban, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    zhuang_id = erlang:error({required, zhuang_id}),
    period = erlang:error({required, period}),
    my_seat_id = erlang:error({required, my_seat_id}),
    player_list = [],
    max_round = erlang:error({required, max_round}),
    banker_type = erlang:error({required, banker_type}),
    bottom_num = erlang:error({required, bottom_num}),
    is_play_chose = erlang:error({required, is_play_chose}),
    nowplayer = erlang:error({required, nowplayer})
}).
-endif.

-ifndef(PBROOMSTATE_PB_H).
-define(PBROOMSTATE_PB_H, true).
-record(pbroomstate, {
    state = erlang:error({required, state})
}).
-endif.

-ifndef(PBTAKEPOKER_PB_H).
-define(PBTAKEPOKER_PB_H, true).
-record(pbtakepoker, {
    is_take_true = erlang:error({required, is_take_true})
}).
-endif.

-ifndef(PBTAKEPOKERSTATE_PB_H).
-define(PBTAKEPOKERSTATE_PB_H, true).
-record(pbtakepokerstate, {
    player_id = erlang:error({required, player_id}),
    poker_num = erlang:error({required, poker_num})
}).
-endif.

