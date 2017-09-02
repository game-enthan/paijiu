-ifndef(PBRECORDLIST_PB_H).
-define(PBRECORDLIST_PB_H, true).
-record(pbrecordlist, {
    play_type = erlang:error({required, play_type}),
    record_list = []
}).
-endif.

-ifndef(PBRECORDPLAYER_PB_H).
-define(PBRECORDPLAYER_PB_H, true).
-record(pbrecordplayer, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    score = erlang:error({required, score})
}).
-endif.

-ifndef(PBRECORDRECORDID_PB_H).
-define(PBRECORDRECORDID_PB_H, true).
-record(pbrecordrecordid, {
    play_type = erlang:error({required, play_type}),
    record_id = erlang:error({required, record_id})
}).
-endif.

-ifndef(PBRECORDROUNDID_PB_H).
-define(PBRECORDROUNDID_PB_H, true).
-record(pbrecordroundid, {
    play_type = erlang:error({required, play_type}),
    record_id = erlang:error({required, record_id}),
    round_id = erlang:error({required, round_id})
}).
-endif.

-ifndef(PBRECORDROUNDLIST_PB_H).
-define(PBRECORDROUNDLIST_PB_H, true).
-record(pbrecordroundlist, {
    record_id = erlang:error({required, record_id}),
    round_list = []
}).
-endif.

-ifndef(PBRECORDROUNDUNIT_PB_H).
-define(PBRECORDROUNDUNIT_PB_H, true).
-record(pbrecordroundunit, {
    round_id = erlang:error({required, round_id}),
    room_id = erlang:error({required, room_id}),
    round = erlang:error({required, round}),
    time = erlang:error({required, time}),
    player_list = []
}).
-endif.

-ifndef(PBRECORDTYPE_PB_H).
-define(PBRECORDTYPE_PB_H, true).
-record(pbrecordtype, {
    play_type = erlang:error({required, play_type})
}).
-endif.

-ifndef(PBRECORDUNIT_PB_H).
-define(PBRECORDUNIT_PB_H, true).
-record(pbrecordunit, {
    record_id = erlang:error({required, record_id}),
    room_id = erlang:error({required, room_id}),
    time = erlang:error({required, time}),
    player_list = []
}).
-endif.

