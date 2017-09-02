%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 六月 2017 14:13
%%%-------------------------------------------------------------------
-author("Administrator").

-record(log_cfg, {
  table
  ,interval = 15
  ,field_list = []
}).