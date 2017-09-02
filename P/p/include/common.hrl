%%%-------------------------------------------------------------------
%%% @author jolee
%%% @copyright (C) 2016, 105326073@qq.com
%%% @doc
%%%
%%% @end
%%% Created : 06. 四月 2016 16:41
%%%-------------------------------------------------------------------
-author("jolee").
-ifndef(_COMMON_HRL_).
-define(_COMMON_HRL_, common_hrl).

-define(COOKIE, 'dy@gaga2017').

%% 服务器定义
-define(GAME_SERVER, 1).    %% 游戏服
-define(LOGIN_SERVER, 2).   %% 网关服
% -define(GAME_NODE, 'master@172.18.135.104').   %% 游戏服节点  外网
% -define(GATEWAY_NODE, 'login@172.18.135.105'). %% 网关服节点  外网
% -define(GAME_NODE, 'master@172.18.78.23').   %% 游戏服节点  测试服
% -define(GATEWAY_NODE, 'login@172.18.78.24'). %% 网关服节点  测试服
-define(GAME_NODE, 'master@server.dev').   %% 游戏服节点  本地服
-define(GATEWAY_NODE, 'login@server.dev'). %% 网关服节点  本地服

%% 数据库连接定义
% -define(DB_POOL, game_mysql_conn).
% -define(DB_LOG_POOL, log_mysql_conn).
% -define(DB_DISPATCHER_NUM, 5).

-define(DB_MODULE, db_mysql).
-define(DB_POOL, mysql_conn).
-define(DB_POOL_ADMIN, mysql_conn_admin).
-define(DB_LABEL, 1).
-define(DB_LABEL_EFFORT, 2).


-ifdef(debug).
-define(DEBUG(Msg), logger:debug(Msg, [], ?MODULE, ?LINE)).     %% 输出调试信息
-define(DEBUG(Msg, Args), logger:debug(Msg, Args, ?MODULE, ?LINE)).
-else.
-define(DEBUG(Msg), ok).
-define(DEBUG(Msg, Args), ok).
-endif.

-define(INFO(Msg), catch logger:info(Msg, [], ?MODULE, ?LINE)).   %% 输出普通信息
-define(INFO(M, A), catch logger:info(M, A, ?MODULE, ?LINE)).
-define(WARN(Msg), catch logger:warning(Msg, [], ?MODULE, ?LINE)).   %% 输出警告信息
-define(WARN(M, A), catch logger:warning(M, A, ?MODULE, ?LINE)).
-define(ERR(Msg), catch logger:error(Msg, [], ?MODULE, ?LINE)).   %% 输出错误信息
-define(ERR(M, A), catch logger:error(M, A, ?MODULE, ?LINE)).

-define(NODE_ERROR_LOG(Msg), catch logger:error(Msg, [], ?MODULE, ?LINE)).   %% 输出错误信息
-define(NODE_ERROR_LOG(M, A), catch logger:error(M, A, ?MODULE, ?LINE)).


%% 带catch的gen_server:call/2，返回{error, timeout} | {error, noproc} | {error, term()} | term() | {exit, normal}
%% case catch gen_server:call(Pid, Request)
-define(CALL(Pid, Request),
    case catch gen_server:call(Pid, Request) of
        {'EXIT', {timeout, _}} -> {error, timeout};
        {'EXIT', {noproc, _}} -> {error, noproc};
        {'EXIT', normal} -> {exit, normal};
        {'EXIT', Msg} -> {error, Msg};
        Rtn -> Rtn
    end
).

%% IIF函数
-define(IIF(Expression, Expression1, Expression2), case Expression of true -> Expression1; _ -> Expression2 end).

-endif.

-define(role_socket, role_socket).
-define(client_ip, client_ip).
-define(client_port, client_port).

-define(atomic, atomic).
-define(undefined,undefined).
-define(true, true).
-define(false, false).
-define(nil, nil).
-define(error,error).
-define(none,none).
-define(next,next).
-define(break,break).
-define(nonproc, nonproc).
-define(badarg,badarg).
-define(yes,yes).
-define(reply, reply).
-define(noreply, noreply).
-define(normal,normal).
-define(protected, protected).
-define(private, private).
-define(public, public).
-define(write_concurrency, write_concurrency).
-define(read_concurrency, read_concurrency).
-define(keypos, keypos).
-define(value, value).
-define(infinity, infinity).
-define(named_table, named_table).
-define(end_of_table, '$end_of_table').
-define(attributes, attributes).
-define(behaviour, behaviour).
-define(set, set).
-define(ordered_set, ordered_set).
-define(disc_only_copies, disc_only_copies).
-define(disc_copies, disc_copies).
-define(latin1, latin1).
-define(shutdown, shutdown).
-define(not_enough, not_enough).
-define(key_exists, key_exists).
-define(mail_full, mail_full).
-define(record_fields(Name), record_info(fields, Name)).

-define(if_else(Condition, Exp, Else), case begin Condition end of  true-> (Exp); false -> (Else) end).
