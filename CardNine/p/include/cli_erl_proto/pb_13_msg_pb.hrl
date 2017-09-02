-ifndef(PBERROR_PB_H).
-define(PBERROR_PB_H, true).
-record(pberror, {
    errcode = erlang:error({required, errcode}),
    errmsg
}).
-endif.

-ifndef(PBHDIMG_PB_H).
-define(PBHDIMG_PB_H, true).
-record(pbhdimg, {
    img = erlang:error({required, img})
}).
-endif.

-ifndef(PBHDNOTICE_PB_H).
-define(PBHDNOTICE_PB_H, true).
-record(pbhdnotice, {
    content = erlang:error({required, content})
}).
-endif.

-ifndef(PBLOOPNOTICE_PB_H).
-define(PBLOOPNOTICE_PB_H, true).
-record(pbloopnotice, {
    content = erlang:error({required, content}),
    times = erlang:error({required, times})
}).
-endif.

-ifndef(PBMSGCHAT_PB_H).
-define(PBMSGCHAT_PB_H, true).
-record(pbmsgchat, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    icon = erlang:error({required, icon}),
    msg_type = erlang:error({required, msg_type}),
    content = erlang:error({required, content})
}).
-endif.

