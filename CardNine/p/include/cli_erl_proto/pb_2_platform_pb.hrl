-ifndef(PBADDCARD_PB_H).
-define(PBADDCARD_PB_H, true).
-record(pbaddcard, {
    player_id = erlang:error({required, player_id}),
    card = erlang:error({required, card})
}).
-endif.

-ifndef(PBCREATEUSER_PB_H).
-define(PBCREATEUSER_PB_H, true).
-record(pbcreateuser, {
    wechat_id = erlang:error({required, wechat_id}),
    agent_id = erlang:error({required, agent_id}),
    create_time = erlang:error({required, create_time}),
    room_card = erlang:error({required, room_card}),
    agent_invite_code = erlang:error({required, agent_invite_code})
}).
-endif.

-ifndef(PBDISMISSROOMINFO_PB_H).
-define(PBDISMISSROOMINFO_PB_H, true).
-record(pbdismissroominfo, {
    apply_player_id = erlang:error({required, apply_player_id}),
    accept_player_id = []
}).
-endif.

-ifndef(PBLOOPMSG_PB_H).
-define(PBLOOPMSG_PB_H, true).
-record(pbloopmsg, {
    content = erlang:error({required, content}),
    times = erlang:error({required, times})
}).
-endif.

-ifndef(PBMSGWINDOW_PB_H).
-define(PBMSGWINDOW_PB_H, true).
-record(pbmsgwindow, {
    content = erlang:error({required, content}),
    times = erlang:error({required, times}),
    interval = erlang:error({required, interval})
}).
-endif.

-ifndef(PBNUMBER_PB_H).
-define(PBNUMBER_PB_H, true).
-record(pbnumber, {
    number = erlang:error({required, number})
}).
-endif.

-ifndef(PBRESULT_PB_H).
-define(PBRESULT_PB_H, true).
-record(pbresult, {
    ret = erlang:error({required, ret})
}).
-endif.

-ifndef(PBTEST_PB_H).
-define(PBTEST_PB_H, true).
-record(pbtest, {
    number = erlang:error({required, number}),
    string = erlang:error({required, string}),
    binary = erlang:error({required, binary})
}).
-endif.

-ifndef(PBUPDATEAGENTID_PB_H).
-define(PBUPDATEAGENTID_PB_H, true).
-record(pbupdateagentid, {
    uid = erlang:error({required, uid}),
    agent_id = erlang:error({required, agent_id})
}).
-endif.

-ifndef(PBUPDATESTRING_PB_H).
-define(PBUPDATESTRING_PB_H, true).
-record(pbupdatestring, {
    uid = erlang:error({required, uid}),
    key = erlang:error({required, key}),
    value = erlang:error({required, value})
}).
-endif.

-ifndef(PBUPDATEINT_PB_H).
-define(PBUPDATEINT_PB_H, true).
-record(pbupdateint, {
    uid = erlang:error({required, uid}),
    key = erlang:error({required, key}),
    value = erlang:error({required, value})
}).
-endif.

