-ifndef(PBBASEPLAYER_PB_H).
-define(PBBASEPLAYER_PB_H, true).
-record(pbbaseplayer, {
    player_id = erlang:error({required, player_id}),
    player_name = erlang:error({required, player_name}),
    dismiss_opt = erlang:error({required, dismiss_opt}),
    icon = erlang:error({required, icon})
}).
-endif.

-ifndef(PBCREATEROOMBULL_PB_H).
-define(PBCREATEROOMBULL_PB_H, true).
-record(pbcreateroombull, {
    round = erlang:error({required, round}),
    pay_way = erlang:error({required, pay_way}),
    has_flower_card = erlang:error({required, has_flower_card}),
    three_card = erlang:error({required, three_card}),
    forbid_enter = erlang:error({required, forbid_enter}),
    has_whn = erlang:error({required, has_whn}),
    has_zdn = erlang:error({required, has_zdn}),
    has_wxn = erlang:error({required, has_wxn}),
    double_type = erlang:error({required, double_type}),
    tongbi_score = erlang:error({required, tongbi_score}),
    banker_type = erlang:error({required, banker_type}),
    gps = erlang:error({required, gps}),
    has_push_chip = erlang:error({required, has_push_chip}),
    forbid_cuopai = erlang:error({required, forbid_cuopai}),
    qiang_score_limit = erlang:error({required, qiang_score_limit}),
    is_auto = erlang:error({required, is_auto}),
    is_agent_room = erlang:error({required, is_agent_room}),
    score_type = erlang:error({required, score_type})
}).
-endif.

-ifndef(PBCREATEROOMDOUDIZHU_PB_H).
-define(PBCREATEROOMDOUDIZHU_PB_H, true).
-record(pbcreateroomdoudizhu, {
    cost_room_card_num = erlang:error({required, cost_room_card_num}),
    bomb_top = erlang:error({required, bomb_top}),
    show_poker_num = erlang:error({required, show_poker_num}),
    record_poker = erlang:error({required, record_poker}),
    player_num = erlang:error({required, player_num}),
    call_dizhu = erlang:error({required, call_dizhu}),
    gps = erlang:error({required, gps}),
    let_card = erlang:error({required, let_card})
}).
-endif.

-ifndef(PBCREATEROOMGOLDFLOWER_PB_H).
-define(PBCREATEROOMGOLDFLOWER_PB_H, true).
-record(pbcreateroomgoldflower, {
    cost_room_card_num = erlang:error({required, cost_room_card_num}),
    first_see_poker = erlang:error({required, first_see_poker}),
    see_poker_cuopai = erlang:error({required, see_poker_cuopai}),
    forbid_enter = erlang:error({required, forbid_enter}),
    has_xiqian = erlang:error({required, has_xiqian}),
    p235_big_baozi = erlang:error({required, p235_big_baozi}),
    p235_big_aaa = erlang:error({required, p235_big_aaa}),
    score_type = erlang:error({required, score_type}),
    gps = erlang:error({required, gps})
}).
-endif.

-ifndef(PBCREATEROOMLANZHOUWAKENG_PB_H).
-define(PBCREATEROOMLANZHOUWAKENG_PB_H, true).
-record(pbcreateroomlanzhouwakeng, {
    cost_room_card_num = erlang:error({required, cost_room_card_num}),
    is_can_bomb = erlang:error({required, is_can_bomb}),
    air_bomb_multiple = erlang:error({required, air_bomb_multiple}),
    put_off_poker = erlang:error({required, put_off_poker}),
    bomb_top = erlang:error({required, bomb_top}),
    gps = erlang:error({required, gps})
}).
-endif.

-ifndef(PBCREATEROOMPUSHPAIRS_PB_H).
-define(PBCREATEROOMPUSHPAIRS_PB_H, true).
-record(pbcreateroompushpairs, {
    cost_room_card_num = erlang:error({required, cost_room_card_num}),
    zhuang_type = erlang:error({required, zhuang_type}),
    score_type = erlang:error({required, score_type}),
    is_red_half = erlang:error({required, is_red_half}),
    nine_double = erlang:error({required, nine_double}),
    is_one_red = erlang:error({required, is_one_red}),
    is_river = erlang:error({required, is_river}),
    gps = erlang:error({required, gps}),
    xian_double = erlang:error({required, xian_double}),
    zhuang_double = erlang:error({required, zhuang_double})
}).
-endif.

-ifndef(PBCREATEROOMSANDAI_PB_H).
-define(PBCREATEROOMSANDAI_PB_H, true).
-record(pbcreateroomsandai, {
    cost_room_card_num = erlang:error({required, cost_room_card_num}),
    is_card_num = erlang:error({required, is_card_num}),
    score_type = erlang:error({required, score_type}),
    three_take = erlang:error({required, three_take}),
    force_card = erlang:error({required, force_card}),
    has_aircraft = erlang:error({required, has_aircraft}),
    pan_force1 = erlang:error({required, pan_force1}),
    pan_force2 = erlang:error({required, pan_force2}),
    pan_force3 = erlang:error({required, pan_force3}),
    pan_force4 = erlang:error({required, pan_force4}),
    pan_force5 = erlang:error({required, pan_force5}),
    gps = erlang:error({required, gps})
}).
-endif.

-ifndef(PBCREATEROOMSHANXIWAKENG_PB_H).
-define(PBCREATEROOMSHANXIWAKENG_PB_H, true).
-record(pbcreateroomshanxiwakeng, {
    cost_room_card_num = erlang:error({required, cost_room_card_num}),
    call_dizhu = erlang:error({required, call_dizhu}),
    is_can_bomb = erlang:error({required, is_can_bomb}),
    put_off_poker = erlang:error({required, put_off_poker}),
    bomb_top = erlang:error({required, bomb_top}),
    gps = erlang:error({required, gps})
}).
-endif.

-ifndef(PBCREATEROOMTENHALF_PB_H).
-define(PBCREATEROOMTENHALF_PB_H, true).
-record(pbcreateroomtenhalf, {
    cost_room_card_num = erlang:error({required, cost_room_card_num}),
    is_specail_play = erlang:error({required, is_specail_play}),
    max_chip = erlang:error({required, max_chip}),
    banker_type = erlang:error({required, banker_type}),
    gps = erlang:error({required, gps})
}).
-endif.

-ifndef(PBDISMISSINFO_PB_H).
-define(PBDISMISSINFO_PB_H, true).
-record(pbdismissinfo, {
    player_list = [],
    remain_time = erlang:error({required, remain_time})
}).
-endif.

-ifndef(PBJOININROOM_PB_H).
-define(PBJOININROOM_PB_H, true).
-record(pbjoininroom, {
    room_id = erlang:error({required, room_id}),
    gps = erlang:error({required, gps}),
    is_xbw
}).
-endif.

-ifndef(PBNUMBER_PB_H).
-define(PBNUMBER_PB_H, true).
-record(pbnumber, {
    num = erlang:error({required, num})
}).
-endif.

