-ifndef(PBMALLINFO_PB_H).
-define(PBMALLINFO_PB_H, true).
-record(pbmallinfo, {
    product_list = [],
    payway_id_list = []
}).
-endif.

-ifndef(PBMALLPAY_PB_H).
-define(PBMALLPAY_PB_H, true).
-record(pbmallpay, {
    product_id = erlang:error({required, product_id}),
    payway_id = erlang:error({required, payway_id}),
    appid = erlang:error({required, appid}),
    os = erlang:error({required, os}),
    appinfo = erlang:error({required, appinfo})
}).
-endif.

-ifndef(PBMALLPAYRESULT_PB_H).
-define(PBMALLPAYRESULT_PB_H, true).
-record(pbmallpayresult, {
    ret = erlang:error({required, ret}),
    payway = erlang:error({required, payway}),
    msg = erlang:error({required, msg}),
    pay_info = erlang:error({required, pay_info})
}).
-endif.

-ifndef(PBMALLPRODUCT_PB_H).
-define(PBMALLPRODUCT_PB_H, true).
-record(pbmallproduct, {
    id = erlang:error({required, id}),
    name = erlang:error({required, name}),
    card = erlang:error({required, card}),
    card_add = erlang:error({required, card_add}),
    amount = erlang:error({required, amount})
}).
-endif.

-ifndef(PBMALLRECIPT_PB_H).
-define(PBMALLRECIPT_PB_H, true).
-record(pbmallrecipt, {
    recipt = erlang:error({required, recipt}),
    player_id
}).
-endif.

-ifndef(PBMALLTYPE_PB_H).
-define(PBMALLTYPE_PB_H, true).
-record(pbmalltype, {
    mall_type
}).
-endif.

