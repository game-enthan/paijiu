%%%-------------------------------------------------------------------
%%% @author jolee
%%% @copyright (C) 2016, 105326073@qq.com
%%% @doc
%%%
%%% @end
%%% Created : 06. 四月 2016 17:48
%%%-------------------------------------------------------------------
-module(util).
-author("jolee").

%% API
-export([
    for/3,
    to_list/1,
    fbin/1,
    fbin/2,
    sleep/1,
    unixtime/0,
    unixtime/1,
    get_dict/2,
    rand/0,
    rand/2,
    rand_list/1,
    load_env/0,
    get_env/1,
    term_to_bitstring/1,
    bitstring_to_term/1,
    string_to_term/1,
    get_val_by_weight/2,
    pin_id/2,
    get_sum_num_list/1,
    datetime_to_timestamp/1,
    timestamp_to_datetime/1,
    get_now_time/0,
    get_today_riqi/0,
    get_yesterday_riqi/0,
    get_tomorrow_riqi/0,
    gb_trees_fold/3,
    term_to_string/1,
    rerefresh_list/1
]).

%% 系统时间截（秒）
unixtime() ->
    misc_timer:now_seconds().
%% 系统时间截（毫秒）
unixtime(ms) ->
    misc_timer:now_milseconds();
%% 当天0时0分0秒时间截
unixtime(today) ->
    {_, Time} = erlang:localtime(),
    unixtime() - calendar:time_to_seconds(Time);
unixtime(tomorrow) ->
    unixtime(today) + 86400.

%% @spec for(Begin::integer(), End::integer(), Fun::function()) -> ok
%% @doc 模拟for循环
for(End, End, Fun) ->
    Fun(End),
    ok;
for(Begin, End, Fun) when Begin < End ->
    Fun(Begin),
    for(Begin + 1, End, Fun).

%% @doc convert other type to list
to_list(Msg) when is_list(Msg) ->
    Msg;
to_list(Msg) when is_atom(Msg) ->
    atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) ->
    binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) ->
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) ->
    f2s(Msg);
to_list(Msg) when is_tuple(Msg) ->
    tuple_to_list(Msg);
to_list(_) ->
    throw(other_value).

%%   f2s(1.5678) -> 1.57 四舍五入
f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]),
    A.

%% @spec fbin(Bin, Args) -> binary()
%% Bin = binary(), Args = list()
%% @doc 返回格式化的二进制字符串
fbin(Bin, Args) ->
    list_to_binary(io_lib:format(Bin, Args)).

fbin(Bin) ->
    fbin(Bin, []).

%% @spec sleep(T) -> ok
%% T = integer()
%% @doc 程序暂停执行时长(单位:毫秒)
sleep(T) ->
    receive
    after T ->
        true
    end.

%% 获取进程字典数据
get_dict(Tag, Default) ->
    case get(Tag) of
        undefined ->
            Default;
        Val ->
            Val
    end.

%% 在0.0 ~ 1.0之间随机获取一个float
rand() ->
    rand:uniform().

%% 在[Min, Max] 之间随机一个数
rand(Min, Min) -> Min;
rand(Max, Min) when Max > Min ->
    rand(Min, Max);
rand(Min, Max) ->
    Min - 1 + rand:uniform(Max - Min + 1).

%% @spec rand_list(L::list()) -> null | term()
%% @doc 从一个list中随机取出一项
rand_list([]) -> null;
rand_list([I]) -> I;
rand_list(List) ->
%%麻将一共136张牌,Idx是取得的牌的位置
    Idx = trunc(rand() * 1000000) rem length(List) + 1,
    get_term_from_list(List, Idx).

get_term_from_list([H | _T], 1) ->
    H;
%%从列表里取第Idx个数
get_term_from_list([_H | T], Idx) ->
    get_term_from_list(T, Idx - 1).

%% @doc 获取配置值
get_env(Key) ->
    {ok, Val} = application:get_env(server, Key),
    Val.

set_env(Key, Val) ->
    application:set_env(server, Key, Val).

%% 加载server_login.config 中的配置
load_env() ->
    case init:get_argument(config) of
        {ok, Files} ->
            lists:foreach(
                fun([File]) ->
                    FName = filename:join(filename:dirname(File), File ++ ".config"),
                    case file:script(FName) of
                        {ok, Envs} ->
                            case lists:keyfind(server, 1, Envs) of
                                false ->
                                    skip;
                                {server, Env} ->
                                    [set_env(Key, Val) || {Key, Val} <- Env]
                            end;
                        _ ->
                            skip
                    end
                end, Files);
        _ ->
            skip
    end,
    ok.

%% @spec term_to_string(Term::term()) -> list()
%% @doc term序列化，term转换为string格式
term_to_string(Term) -> io_lib:format("~w", [Term]).

%% @spec term_to_bitstring(Term::term()) -> bitstring()
%% term序列化，term转换为bitstring格式，e.g., [{a},1] => <<"[{a},1]">>
term_to_bitstring(Term) -> list_to_bitstring(term_to_string(Term)).

%% @spec bitstring_to_term(String::list()) -> {error, Why::term()} | {ok, term()}
%% @doc term反序列化，bitstring转换为term
bitstring_to_term(undefined) -> {ok, undefined};
bitstring_to_term(BitString) -> string_to_term(binary_to_list(BitString)).

%% @spec string_to_term(String::list()) -> {error, Why::term()} | {ok, term()}
%% @doc term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String ++ ".") of
        {ok, Tokens, _} -> erl_parse:parse_term(Tokens);
        {error, Err, _} -> {error, Err};
        Err -> {error, Err}
    end.


get_val_by_weight([], _Num) ->
    [];
get_val_by_weight(List, Num) when Num > length(List) ->
    get_val_by_weight(List, length(List));
get_val_by_weight(List, Num) ->
    get_val_by_weight(List, 0, Num, []).

get_val_by_weight(_, Max, Max, RetList) -> RetList;
get_val_by_weight(List, Min, Max, RetList) ->
    {NewWeight, NewList} = 
    lists:foldl(fun({Id, Weight}, {TotalWeight, IdList}) ->
        {Weight + TotalWeight, [{Id, TotalWeight, TotalWeight + Weight} | IdList]}
    end,
    {0, []},
    List),
    RandomNum = rand:uniform(NewWeight),
    [{NewId, _WeightLow, _WeightHigh}] = 
    lists:filter(fun({_Id, Low, High}) ->
        RandomNum > Low andalso RandomNum =< High
    end,
    NewList),
    get_val_by_weight(lists:keydelete(NewId, 1, List), Min + 1, Max, [NewId | RetList]).

pin_id(Num1, Num2) ->
    list_to_integer(integer_to_list(Num1) ++ integer_to_list(Num2)).

get_sum_num_list(Num) when Num >= 6->
    rerefresh_list([[Num - 1, 1], [Num-2, 2], [Num-3, 3],[Num-4, 4]]);
get_sum_num_list(_) ->
    false.

% 时间转时间戳，格式：{{2013,11,13}, {18,0,0}}
datetime_to_timestamp(DateTime) ->
    calendar:datetime_to_gregorian_seconds(DateTime) - calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}}).

% 时间戳转时间
timestamp_to_datetime(Timestamp) ->
    calendar:gregorian_seconds_to_datetime(Timestamp + calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}})).

%% 获取今天的日期
get_today_riqi() ->
    Time = unixtime(today) + 10,
    timestamp_to_datetime(Time).
%% 获取昨天的日期
get_yesterday_riqi() ->
    Time = unixtime(today) - 100,
    timestamp_to_datetime(Time).
%% 获取后天的日期
get_tomorrow_riqi() ->
    Time = unixtime(today) + 86600,
    timestamp_to_datetime(Time).

get_now_time() ->
    {{DY, DM, DD}, {_H, _M, _S}} = calendar:local_time(),
    integer_to_list(DY) ++ "-" ++ append_to_string(DM) ++ "-" ++ append_to_string(DD).
append_to_string(Num) ->
    case Num < 10 of
        true ->
            "0" ++ integer_to_list(Num);
        _ ->
            integer_to_list(Num)
    end.

gb_trees_fold(Fun, AccIn, Tree) ->
    gb_trees_fold__(Fun, AccIn, gb_trees:iterator(Tree)).

gb_trees_fold__(Fun, Acc, Iter) ->
    case gb_trees:next(Iter) of
        none -> Acc;
        {K, V, Iter2} ->
            gb_trees_fold__(Fun, Fun(K, V, Acc), Iter2)
    end.

rerefresh_list(List) ->
    do_rerefresh_list(List, []).
do_rerefresh_list([], L) ->
    L;
do_rerefresh_list(List, L) ->
    N = rand:uniform(length(List)),
    Li = lists:nth(N, List),
    do_rerefresh_list(lists:delete(Li, List), [Li | L]).