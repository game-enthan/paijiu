-ifndef(PBWAKENGCALLDIZHU_PB_H).
-define(PBWAKENGCALLDIZHU_PB_H, true).
-record(pbwakengcalldizhu, {
    player_id = erlang:error({required, player_id}),
    result = erlang:error({required, result})
}).
-endif.

-ifndef(PBWAKENGDISCARDPOKERLIST_PB_H).
-define(PBWAKENGDISCARDPOKERLIST_PB_H, true).
-record(pbwakengdiscardpokerlist, {
    player_id = erlang:error({required, player_id}),
    poker_list = [],
    remain_num = erlang:error({required, remain_num})
}).
-endif.

-ifndef(PBWAKENGNUMBER_PB_H).
-define(PBWAKENGNUMBER_PB_H, true).
-record(pbwakengnumber, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(PBWAKENGPLAYER_PB_H).
-define(PBWAKENGPLAYER_PB_H, true).
-record(pbwakengplayer, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    score = erlang:error({required, score}),
    seat_id = erlang:error({required, seat_id}),
    icon = erlang:error({required, icon}),
    state = erlang:error({required, state}),
    is_online = erlang:error({required, is_online}),
    poker_list = [],
    sex = erlang:error({required, sex}),
    ip = erlang:error({required, ip}),
    gps = erlang:error({required, gps}),
    remain_num = erlang:error({required, remain_num}),
    is_alert = erlang:error({required, is_alert})
}).
-endif.

-ifndef(PBWAKENGPLAYERFINALCALC_PB_H).
-define(PBWAKENGPLAYERFINALCALC_PB_H, true).
-record(pbwakengplayerfinalcalc, {
    room_id = erlang:error({required, room_id}),
    time = erlang:error({required, time}),
    player_result_list = []
}).
-endif.

-ifndef(PBWAKENGPLAYERFINALRESULT_PB_H).
-define(PBWAKENGPLAYERFINALRESULT_PB_H, true).
-record(pbwakengplayerfinalresult, {
    player_id = erlang:error({required, player_id}),
    bomb_num = erlang:error({required, bomb_num}),
    max_score_gain = erlang:error({required, max_score_gain}),
    win_num = erlang:error({required, win_num}),
    lost_num = erlang:error({required, lost_num}),
    score = erlang:error({required, score})
}).
-endif.

-ifndef(PBWAKENGPLAYERID_PB_H).
-define(PBWAKENGPLAYERID_PB_H, true).
-record(pbwakengplayerid, {
    player_id = erlang:error({required, player_id})
}).
-endif.

-ifndef(PBWAKENGPLAYERONLINE_PB_H).
-define(PBWAKENGPLAYERONLINE_PB_H, true).
-record(pbwakengplayeronline, {
    player_id = erlang:error({required, player_id}),
    is_online = erlang:error({required, is_online})
}).
-endif.

-ifndef(PBWAKENGPLAYERROUNDCALC_PB_H).
-define(PBWAKENGPLAYERROUNDCALC_PB_H, true).
-record(pbwakengplayerroundcalc, {
    player_result_list = [],
    dizhu_multiple = erlang:error({required, dizhu_multiple}),
    round = erlang:error({required, round}),
    dizhu_id = erlang:error({required, dizhu_id}),
    time = erlang:error({required, time}),
    total_multiple = erlang:error({required, total_multiple}),
    room_id = erlang:error({required, room_id})
}).
-endif.

-ifndef(PBWAKENGPLAYERROUNDRESULT_PB_H).
-define(PBWAKENGPLAYERROUNDRESULT_PB_H, true).
-record(pbwakengplayerroundresult, {
    player_id = erlang:error({required, player_id}),
    bomb_num = erlang:error({required, bomb_num}),
    score = erlang:error({required, score}),
    score_change = erlang:error({required, score_change}),
    discarded_list = [],
    not_discarded_list = []
}).
-endif.

-ifndef(PBWAKENGPOKER_PB_H).
-define(PBWAKENGPOKER_PB_H, true).
-record(pbwakengpoker, {
    num = erlang:error({required, num}),
    flower = erlang:error({required, flower})
}).
-endif.

-ifndef(PBWAKENGPOKERLIST_PB_H).
-define(PBWAKENGPOKERLIST_PB_H, true).
-record(pbwakengpokerlist, {
    poker_list = []
}).
-endif.

-ifndef(PBWAKENGROOMINFO_PB_H).
-define(PBWAKENGROOMINFO_PB_H, true).
-record(pbwakengroominfo, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    max_round = erlang:error({required, max_round}),
    call_dizhu = erlang:error({required, call_dizhu}),
    is_can_bomb = erlang:error({required, is_can_bomb}),
    put_off_poker = erlang:error({required, put_off_poker}),
    bomb_top = erlang:error({required, bomb_top}),
    dizhu_id = erlang:error({required, dizhu_id}),
    my_seat_id = erlang:error({required, my_seat_id}),
    period = erlang:error({required, period}),
    player_list = [],
    action_player_id = erlang:error({required, action_player_id}),
    base_score = erlang:error({required, base_score}),
    multiple = erlang:error({required, multiple}),
    dizhu_poker_list = [],
    discard_player_id = erlang:error({required, discard_player_id}),
    discard_poker_list = [],
    last_call_dizhu_id = erlang:error({required, last_call_dizhu_id}),
    last_call_dizhu_score = erlang:error({required, last_call_dizhu_score}),
    room_type = erlang:error({required, room_type}),
    total_poker_num = erlang:error({required, total_poker_num}),
    air_bomb_multiple = erlang:error({required, air_bomb_multiple})
}).
-endif.

-ifndef(PBWAKENGROOMSTATE_PB_H).
-define(PBWAKENGROOMSTATE_PB_H, true).
-record(pbwakengroomstate, {
    state = erlang:error({required, state})
}).
-endif.

