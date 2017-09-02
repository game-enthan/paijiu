%%%-------------------------------------------------------------------
%%% @author jolee
%%% @copyright (C) 2016, 105326073@qq.com
%%% @doc
%%%
%%% @end
%%% Created : 12. 四月 2016 14:09
%%%-------------------------------------------------------------------
-author("jolee").

%% 登录错误
-define(ERR_TEMP_ACCOUNT_INVALID, 1).   %% 未查找到该临时账号\该临时账号过期
-define(ERR_FORMAL_ACCOUNT_FALSE, 2).   %% 正式账号登录失败
-define(ERR_WECHAT_LOGIN_FALSE, 3).     %% 微信登录失败
-define(ERR_FORBID_LOGIN, 4).     %% 已被封号
-define(ERR_CREATE_ROLE, 5).     %% 创建玩家失败

%% 通用错误
-define(ERR_ABNORMAL, {0, ""}).                 %% 未知错误
-define(ERR_ROOM_NOEXIST, {1, ""}).             %% 房间不存在
-define(ERR_ROOM_CARD_NOT_ENOUGH, {2, ""}).     %% 房卡不足
-define(ERR_ROOM_FULL, {3, ""}).                %% 房间已满
-define(ERR_ROOM_FORBID_ENTER, {4, ""}).        %% 房间禁止加入
-define(ERR_INVITE_CODE_ERROR, {5, ""}).        %% 邀请码错误
-define(ERR_BIND_ACCOUNT_FALSE, {6, ""}).       %% 绑定账号失败
-define(ERR_BIND_ACCOUNT_EXIST, {7, ""}).       %% 绑定账号名已存在
-define(ERR_AGENT_ROOM_LIMIT_ERROR, {8, ""}).   %% 代理房最多同时开4个
-define(ERR_NOT_AGENT, {9, ""}).       			%% 不是代理不能开代理房
-define(ERR_WATCHING_CANNOT_OPT, {10, ""}).     %% 观战玩家不能操作
-define(ERR_HAVE_NOT_AUTH, {11, ""}).       	%% 没有授权，不能进房间
-define(ERR_AGENT_NO_CARD, {12, ""}).       	%% 代理卡不够，不能进房间