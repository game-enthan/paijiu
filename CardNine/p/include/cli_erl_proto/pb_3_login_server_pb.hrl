-ifndef(PBUPDATEIP_PB_H).
-define(PBUPDATEIP_PB_H, true).
-record(pbupdateip, {
    ip = erlang:error({required, ip})
}).
-endif.

