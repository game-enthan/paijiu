-ifndef(PBSANDAIDISCARDPOKERLIST_PB_H).
-define(PBSANDAIDISCARDPOKERLIST_PB_H, true).
-record(pbsandaidiscardpokerlist, {
    player_id = erlang:error({required, player_id}),
    poker_list = [],
    remain_num = erlang:error({required, remain_num})
}).
-endif.

-ifndef(PBSANDAINUMBER_PB_H).
-define(PBSANDAINUMBER_PB_H, true).
-record(pbsandainumber, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(PBSANDAIPLAYER_PB_H).
-define(PBSANDAIPLAYER_PB_H, true).
-record(pbsandaiplayer, {
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
    remain_num = erlang:error({required, remain_num})
}).
-endif.

-ifndef(PBSANDAIPLAYERFINALCALC_PB_H).
-define(PBSANDAIPLAYERFINALCALC_PB_H, true).
-record(pbsandaiplayerfinalcalc, {
    room_id = erlang:error({required, room_id}),
    time = erlang:error({required, time}),
    player_result_list = []
}).
-endif.

-ifndef(PBSANDAIPLAYERFINALRESULT_PB_H).
-define(PBSANDAIPLAYERFINALRESULT_PB_H, true).
-record(pbsandaiplayerfinalresult, {
    player_id = erlang:error({required, player_id}),
    bomb_num = erlang:error({required, bomb_num}),
    max_score_gain = erlang:error({required, max_score_gain}),
    win_num = erlang:error({required, win_num}),
    lost_num = erlang:error({required, lost_num}),
    score = erlang:error({required, score})
}).
-endif.

-ifndef(PBSANDAIPLAYERID_PB_H).
-define(PBSANDAIPLAYERID_PB_H, true).
-record(pbsandaiplayerid, {
    player_id = erlang:error({required, player_id})
}).
-endif.

-ifndef(PBSANDAIPLAYERONLINE_PB_H).
-define(PBSANDAIPLAYERONLINE_PB_H, true).
-record(pbsandaiplayeronline, {
    player_id = erlang:error({required, player_id}),
    is_online = erlang:error({required, is_online})
}).
-endif.

-ifndef(PBSANDAIPLAYERROUNDCALC_PB_H).
-define(PBSANDAIPLAYERROUNDCALC_PB_H, true).
-record(pbsandaiplayerroundcalc, {
    player_result_list = [],
    round = erlang:error({required, round}),
    time = erlang:error({required, time}),
    total_multiple = erlang:error({required, total_multiple}),
    room_id = erlang:error({required, room_id}),
    is_spring = erlang:error({required, is_spring})
}).
-endif.

-ifndef(PBSANDAIPLAYERROUNDRESULT_PB_H).
-define(PBSANDAIPLAYERROUNDRESULT_PB_H, true).
-record(pbsandaiplayerroundresult, {
    player_id = erlang:error({required, player_id}),
    bomb_num = erlang:error({required, bomb_num}),
    score = erlang:error({required, score}),
    score_change = erlang:error({required, score_change}),
    discarded_list = [],
    not_discarded_list = []
}).
-endif.

-ifndef(PBSANDAIPOKER_PB_H).
-define(PBSANDAIPOKER_PB_H, true).
-record(pbsandaipoker, {
    num = erlang:error({required, num}),
    flower = erlang:error({required, flower})
}).
-endif.

-ifndef(PBSANDAIPOKERLIST_PB_H).
-define(PBSANDAIPOKERLIST_PB_H, true).
-record(pbsandaipokerlist, {
    poker_list = []
}).
-endif.

-ifndef(PBSANDAIROOMINFO_PB_H).
-define(PBSANDAIROOMINFO_PB_H, true).
-record(pbsandairoominfo, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    max_round = erlang:error({required, max_round}),
    is_card_num = erlang:error({required, is_card_num}),
    score_type = erlang:error({required, score_type}),
    three_take = erlang:error({required, three_take}),
    force_card = erlang:error({required, force_card}),
    has_aircraft = erlang:error({required, has_aircraft}),
    my_seat_id = erlang:error({required, my_seat_id}),
    period = erlang:error({required, period}),
    player_list = [],
    action_player_id = erlang:error({required, action_player_id}),
    base_score = erlang:error({required, base_score}),
    multiple = erlang:error({required, multiple}),
    discard_player_id = erlang:error({required, discard_player_id}),
    discard_poker_list = [],
    pan_force1 = erlang:error({required, pan_force1}),
    pan_force2 = erlang:error({required, pan_force2}),
    pan_force3 = erlang:error({required, pan_force3}),
    pan_force4 = erlang:error({required, pan_force4}),
    pan_force5 = erlang:error({required, pan_force5}),
    is_tipping = erlang:error({required, is_tipping})
}).
-endif.

-ifndef(PBSANDAIROOMSTATE_PB_H).
-define(PBSANDAIROOMSTATE_PB_H, true).
-record(pbsandairoomstate, {
    state = erlang:error({required, state})
}).
-endif.

-ifndef(PBTIPPING_PB_H).
-define(PBTIPPING_PB_H, true).
-record(pbtipping, {
    is_tipping = erlang:error({required, is_tipping})
}).
-endif.

