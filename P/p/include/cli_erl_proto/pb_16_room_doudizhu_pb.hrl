-ifndef(PBDOUDIZHUCALLDIZHU_PB_H).
-define(PBDOUDIZHUCALLDIZHU_PB_H, true).
-record(pbdoudizhucalldizhu, {
    player_id = erlang:error({required, player_id}),
    result = erlang:error({required, result})
}).
-endif.

-ifndef(PBDOUDIZHUDISCARDPOKERLIST_PB_H).
-define(PBDOUDIZHUDISCARDPOKERLIST_PB_H, true).
-record(pbdoudizhudiscardpokerlist, {
    player_id = erlang:error({required, player_id}),
    poker_list = [],
    remain_num = erlang:error({required, remain_num})
}).
-endif.

-ifndef(PBDOUDIZHUNUMBER_PB_H).
-define(PBDOUDIZHUNUMBER_PB_H, true).
-record(pbdoudizhunumber, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(PBDOUDIZHUPLAYER_PB_H).
-define(PBDOUDIZHUPLAYER_PB_H, true).
-record(pbdoudizhuplayer, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    score = erlang:error({required, score}),
    seat_id = erlang:error({required, seat_id}),
    icon = erlang:error({required, icon}),
    state = erlang:error({required, state}),
    is_online = erlang:error({required, is_online}),
    poker_list = [],
    remain_num = erlang:error({required, remain_num}),
    sex = erlang:error({required, sex}),
    ip = erlang:error({required, ip}),
    gps = erlang:error({required, gps}),
    is_alert = erlang:error({required, is_alert})
}).
-endif.

-ifndef(PBDOUDIZHUPLAYERFINALCALC_PB_H).
-define(PBDOUDIZHUPLAYERFINALCALC_PB_H, true).
-record(pbdoudizhuplayerfinalcalc, {
    room_id = erlang:error({required, room_id}),
    time = erlang:error({required, time}),
    player_result_list = []
}).
-endif.

-ifndef(PBDOUDIZHUPLAYERFINALRESULT_PB_H).
-define(PBDOUDIZHUPLAYERFINALRESULT_PB_H, true).
-record(pbdoudizhuplayerfinalresult, {
    player_id = erlang:error({required, player_id}),
    bomb_num = erlang:error({required, bomb_num}),
    max_score_gain = erlang:error({required, max_score_gain}),
    win_num = erlang:error({required, win_num}),
    lost_num = erlang:error({required, lost_num}),
    score = erlang:error({required, score})
}).
-endif.

-ifndef(PBDOUDIZHUPLAYERID_PB_H).
-define(PBDOUDIZHUPLAYERID_PB_H, true).
-record(pbdoudizhuplayerid, {
    player_id = erlang:error({required, player_id})
}).
-endif.

-ifndef(PBDOUDIZHUPLAYERONLINE_PB_H).
-define(PBDOUDIZHUPLAYERONLINE_PB_H, true).
-record(pbdoudizhuplayeronline, {
    player_id = erlang:error({required, player_id}),
    is_online = erlang:error({required, is_online})
}).
-endif.

-ifndef(PBDOUDIZHUPLAYERROUNDCALC_PB_H).
-define(PBDOUDIZHUPLAYERROUNDCALC_PB_H, true).
-record(pbdoudizhuplayerroundcalc, {
    player_result_list = [],
    dizhu_multiple = erlang:error({required, dizhu_multiple}),
    is_spring = erlang:error({required, is_spring}),
    round = erlang:error({required, round}),
    dizhu_id = erlang:error({required, dizhu_id}),
    time = erlang:error({required, time}),
    total_multiple = erlang:error({required, total_multiple}),
    room_id = erlang:error({required, room_id}),
    farmer_win_poker_num = erlang:error({required, farmer_win_poker_num})
}).
-endif.

-ifndef(PBDOUDIZHUPLAYERROUNDRESULT_PB_H).
-define(PBDOUDIZHUPLAYERROUNDRESULT_PB_H, true).
-record(pbdoudizhuplayerroundresult, {
    player_id = erlang:error({required, player_id}),
    bomb_num = erlang:error({required, bomb_num}),
    score = erlang:error({required, score}),
    score_change = erlang:error({required, score_change}),
    discarded_list = [],
    not_discarded_list = []
}).
-endif.

-ifndef(PBDOUDIZHUPOKER_PB_H).
-define(PBDOUDIZHUPOKER_PB_H, true).
-record(pbdoudizhupoker, {
    num = erlang:error({required, num}),
    flower = erlang:error({required, flower})
}).
-endif.

-ifndef(PBDOUDIZHUPOKERLIST_PB_H).
-define(PBDOUDIZHUPOKERLIST_PB_H, true).
-record(pbdoudizhupokerlist, {
    poker_list = []
}).
-endif.

-ifndef(PBDOUDIZHUROOMINFO_PB_H).
-define(PBDOUDIZHUROOMINFO_PB_H, true).
-record(pbdoudizhuroominfo, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    max_round = erlang:error({required, max_round}),
    bomb_top = erlang:error({required, bomb_top}),
    show_poker_num = erlang:error({required, show_poker_num}),
    record_poker = erlang:error({required, record_poker}),
    player_num = erlang:error({required, player_num}),
    call_dizhu = erlang:error({required, call_dizhu}),
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
    farmer_win_poker_num = erlang:error({required, farmer_win_poker_num}),
    is_win_poker_num = erlang:error({required, is_win_poker_num})
}).
-endif.

-ifndef(PBDOUDIZHUROOMSTATE_PB_H).
-define(PBDOUDIZHUROOMSTATE_PB_H, true).
-record(pbdoudizhuroomstate, {
    state = erlang:error({required, state})
}).
-endif.

