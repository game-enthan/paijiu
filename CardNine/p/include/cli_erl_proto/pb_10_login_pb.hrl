-ifndef(PBFORMALACCOUNTLOGIN_PB_H).
-define(PBFORMALACCOUNTLOGIN_PB_H, true).
-record(pbformalaccountlogin, {
    account = erlang:error({required, account}),
    password = erlang:error({required, password})
}).
-endif.

-ifndef(PBLOGINFAILED_PB_H).
-define(PBLOGINFAILED_PB_H, true).
-record(pbloginfailed, {
    login_type = erlang:error({required, login_type}),
    err_code = erlang:error({required, err_code})
}).
-endif.

-ifndef(PBLOGININVITECODE_PB_H).
-define(PBLOGININVITECODE_PB_H, true).
-record(pblogininvitecode, {
    invite_code = erlang:error({required, invite_code})
}).
-endif.

-ifndef(PBLOGININVITECODERESULT_PB_H).
-define(PBLOGININVITECODERESULT_PB_H, true).
-record(pblogininvitecoderesult, {
    ret_code = erlang:error({required, ret_code}),
    agent_id = erlang:error({required, agent_id})
}).
-endif.

-ifndef(PBLOGINSUCCESS_PB_H).
-define(PBLOGINSUCCESS_PB_H, true).
-record(pbloginsuccess, {
    player_id = erlang:error({required, player_id}),
    wechat_id = erlang:error({required, wechat_id}),
    wechat_name = erlang:error({required, wechat_name}),
    sex = erlang:error({required, sex}),
    vip_lv = erlang:error({required, vip_lv}),
    room_card = erlang:error({required, room_card}),
    room_card_cost = erlang:error({required, room_card_cost}),
    room_card_recharge = erlang:error({required, room_card_recharge}),
    player_icon = erlang:error({required, player_icon}),
    temp_account = erlang:error({required, temp_account}),
    temp_password = erlang:error({required, temp_password}),
    temp_account_endtime = erlang:error({required, temp_account_endtime}),
    agent_invite_code = erlang:error({required, agent_invite_code}),
    agent_id = erlang:error({required, agent_id}),
    room_id = erlang:error({required, room_id}),
    total_pay = erlang:error({required, total_pay}),
    total_round = erlang:error({required, total_round}),
    game_url = erlang:error({required, game_url}),
    health_notice = erlang:error({required, health_notice})
}).
-endif.

-ifndef(PBPLAYERROOMCARD_PB_H).
-define(PBPLAYERROOMCARD_PB_H, true).
-record(pbplayerroomcard, {
    room_card = erlang:error({required, room_card})
}).
-endif.

-ifndef(PBSERVERTIME_PB_H).
-define(PBSERVERTIME_PB_H, true).
-record(pbservertime, {
    time = erlang:error({required, time})
}).
-endif.

-ifndef(PBTEMPACCOUNTLOGIN_PB_H).
-define(PBTEMPACCOUNTLOGIN_PB_H, true).
-record(pbtempaccountlogin, {
    account = erlang:error({required, account}),
    password = erlang:error({required, password})
}).
-endif.

-ifndef(PBWXLOGIN_PB_H).
-define(PBWXLOGIN_PB_H, true).
-record(pbwxlogin, {
    wx_code = erlang:error({required, wx_code}),
    wx_appid
}).
-endif.

