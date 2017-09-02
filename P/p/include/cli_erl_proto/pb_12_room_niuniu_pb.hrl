-ifndef(PBAGENTROOMINFONIUNIU_PB_H).
-define(PBAGENTROOMINFONIUNIU_PB_H, true).
-record(pbagentroominfoniuniu, {
    room_id = erlang:error({required, room_id}),
    max_round = erlang:error({required, max_round}),
    pay_way = erlang:error({required, pay_way}),
    has_flower_card = erlang:error({required, has_flower_card}),
    three_card = erlang:error({required, three_card}),
    forbid_enter = erlang:error({required, forbid_enter}),
    has_whn = erlang:error({required, has_whn}),
    has_zdn = erlang:error({required, has_zdn}),
    has_wxn = erlang:error({required, has_wxn}),
    double_type = erlang:error({required, double_type}),
    banker_type = erlang:error({required, banker_type}),
    tongbi_score = erlang:error({required, tongbi_score}),
    has_push_chip = erlang:error({required, has_push_chip}),
    forbid_cuopai = erlang:error({required, forbid_cuopai}),
    qiang_score_limit = erlang:error({required, qiang_score_limit}),
    is_auto = erlang:error({required, is_auto}),
    score_type = erlang:error({required, score_type})
}).
-endif.

-ifndef(PBAGENTROOMINFONIUNIULIST_PB_H).
-define(PBAGENTROOMINFONIUNIULIST_PB_H, true).
-record(pbagentroominfoniuniulist, {
    list = []
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
    chip_num = erlang:error({required, chip_num})
}).
-endif.

-ifndef(PBNUMBER_PB_H).
-define(PBNUMBER_PB_H, true).
-record(pbnumber, {
    num = erlang:error({required, num})
}).
-endif.

-ifndef(PBPLAYER_PB_H).
-define(PBPLAYER_PB_H, true).
-record(pbplayer, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    score = erlang:error({required, score}),
    chip = erlang:error({required, chip}),
    seat_id = erlang:error({required, seat_id}),
    icon = erlang:error({required, icon}),
    state = erlang:error({required, state}),
    is_online = erlang:error({required, is_online}),
    qiang_zhuang = erlang:error({required, qiang_zhuang}),
    is_turn_poker = erlang:error({required, is_turn_poker}),
    is_show_poker = erlang:error({required, is_show_poker}),
    pbpokerlist = [],
    sex = erlang:error({required, sex}),
    ip = erlang:error({required, ip}),
    gps = erlang:error({required, gps}),
    push_chip_num = erlang:error({required, push_chip_num}),
    qiang_score = erlang:error({required, qiang_score}),
    auto_start_time = erlang:error({required, auto_start_time}),
    already_qiang_zhuang = erlang:error({required, already_qiang_zhuang}),
    style
}).
-endif.

-ifndef(PBPLAYERCHIPIN_PB_H).
-define(PBPLAYERCHIPIN_PB_H, true).
-record(pbplayerchipin, {
    player_id = erlang:error({required, player_id}),
    chip_num = erlang:error({required, chip_num})
}).
-endif.

-ifndef(PBPLAYERFINALCALC_PB_H).
-define(PBPLAYERFINALCALC_PB_H, true).
-record(pbplayerfinalcalc, {
    player_result_list = [],
    time = erlang:error({required, time}),
    room_id = erlang:error({required, room_id})
}).
-endif.

-ifndef(PBPLAYERFINALRESULT_PB_H).
-define(PBPLAYERFINALRESULT_PB_H, true).
-record(pbplayerfinalresult, {
    player_id = erlang:error({required, player_id}),
    style_num = [],
    score = erlang:error({required, score})
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
    pbpokerlist = [],
    style = erlang:error({required, style})
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
    pbpokerlist = [],
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
    pbpokerlist = [],
    style
}).
-endif.

-ifndef(PBQIANGSCORE_PB_H).
-define(PBQIANGSCORE_PB_H, true).
-record(pbqiangscore, {
    player_id = erlang:error({required, player_id}),
    score = erlang:error({required, score})
}).
-endif.

-ifndef(PBQIANGZHUANG_PB_H).
-define(PBQIANGZHUANG_PB_H, true).
-record(pbqiangzhuang, {
    qiang_zhuang = erlang:error({required, qiang_zhuang})
}).
-endif.

-ifndef(PBQIANGZHUANGSTATE_PB_H).
-define(PBQIANGZHUANGSTATE_PB_H, true).
-record(pbqiangzhuangstate, {
    player_id = erlang:error({required, player_id}),
    qiang_zhuang = erlang:error({required, qiang_zhuang})
}).
-endif.

-ifndef(PBROOMINFONIUNIU_PB_H).
-define(PBROOMINFONIUNIU_PB_H, true).
-record(pbroominfoniuniu, {
    room_id = erlang:error({required, room_id}),
    room_owner_id = erlang:error({required, room_owner_id}),
    round = erlang:error({required, round}),
    max_round = erlang:error({required, max_round}),
    pay_way = erlang:error({required, pay_way}),
    has_flower_card = erlang:error({required, has_flower_card}),
    three_card = erlang:error({required, three_card}),
    forbid_enter = erlang:error({required, forbid_enter}),
    has_whn = erlang:error({required, has_whn}),
    has_zdn = erlang:error({required, has_zdn}),
    has_wxn = erlang:error({required, has_wxn}),
    double_type = erlang:error({required, double_type}),
    banker_type = erlang:error({required, banker_type}),
    zhuang_id = erlang:error({required, zhuang_id}),
    my_seat_id = erlang:error({required, my_seat_id}),
    player_list = [],
    period = erlang:error({required, period}),
    tongbi_score = erlang:error({required, tongbi_score}),
    has_push_chip = erlang:error({required, has_push_chip}),
    forbid_cuopai = erlang:error({required, forbid_cuopai}),
    qiang_score_limit = erlang:error({required, qiang_score_limit}),
    is_auto = erlang:error({required, is_auto}),
    is_agent_room = erlang:error({required, is_agent_room}),
    score_type = erlang:error({required, score_type})
}).
-endif.

-ifndef(PBROOMSTATE_PB_H).
-define(PBROOMSTATE_PB_H, true).
-record(pbroomstate, {
    state = erlang:error({required, state}),
    pbpokerlist = [],
    style
}).
-endif.

