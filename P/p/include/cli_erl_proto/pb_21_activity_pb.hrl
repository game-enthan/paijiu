-ifndef(PBRANK_PB_H).
-define(PBRANK_PB_H, true).
-record(pbrank, {
    list = [],
    notice = erlang:error({required, notice})
}).
-endif.

-ifndef(PBRANKDATA_PB_H).
-define(PBRANKDATA_PB_H, true).
-record(pbrankdata, {
    player_id = erlang:error({required, player_id}),
    player_name = erlang:error({required, player_name}),
    icon = erlang:error({required, icon}),
    score = erlang:error({required, score}),
    win_num = erlang:error({required, win_num})
}).
-endif.

