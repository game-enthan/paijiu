%%%-------------------------------------------------------------------
%%% @author jolee
%%% @copyright (C) 2016, 105326073@qq.com
%%% @doc
%%%
%%% @end
%%% Created : 11. 四月 2016 11:40
%%%-------------------------------------------------------------------
-author("jolee").
-define(TEMP_ACCOUNT_TIME, 10 * 86400).     %% 临时账号有效期
-define(ROLE_ID_BEGIN, 10000).              %% 角色ID起始数
-define(BEGIN_CARD_NUM, 4).                 %% 初始房卡数
-define(IS_COST_CARD, true).                %% 是否消耗房卡
-define(AGENT_ROOM_CARD, 3).                %% 代理房扣卡数
-define(AGENT_ROOM_MAX, 4).                 %% 代理房最大数

-define(GAME_ROLE_TIME_OUT, 10).  %% 玩家进程自己检测是否正常游戏
-define(IS_ROLE_NORMAL, is_role_normal).

-define(role, role).
-record(role, {
    id      = 0     %% 玩家ID                  1
    ,pid        = 0     %% 玩家进程ID          2
    ,connpid    = 0     %% 连接进程ID          3
    ,socket     = 0     %% tcp socket          4
    ,wechat_id  = ""     %% 微信id               5
    ,wechat_name  = ""  %% 微信名字               6
    ,sex        = 0     %% 性别               7
    ,vip_lv      = 0     %% 玩家VIP等级           8
    ,room_card  = 0     %% 房卡数                 9
    ,room_card_cost = 0 %% 房卡消耗数            10
    ,room_card_recharge = 0 %% 房卡充值数       11
    ,icon       = ""    %% 玩家头像             12
    ,account    = ""    %% 正式账号             13
    ,password   = ""    %% 正式账号密码         14
    ,temp_account = ""  %% 临时账号             15
    ,temp_password = "" %% 临时密码             16
    ,temp_account_endtime = 0 %% 临时账号到期时间 17
    ,agent_invite_code = ""  %% 代理邀请码         18
    ,agent_id = 0 %% 代理id                      19
    ,room_id    = 0     %% 所在房间ID            20
    ,room_pid   = 0     %% 所在房间进程id        21
    ,room_type  = 0     %% 房间类型             22
    ,is_online = false  %% 是否在线            23
    ,status = 0  %% 0=正常，1=封号              24
    ,ip               %%                         25
    ,total_score = 0        %% 总积分            26
    ,total_win_num = 0      %% 总胜利局数         27
    ,total_pay = 0          %% 总充值数（单位：分）28
    ,total_round = 0        %% 总局数             29
    ,five_little_niu = 0    %% 一天中五小牛次数    30
    ,five_flower_niu = 0    %% 一天中五花牛次数    31
    ,two_three_five = 0     %% 一天中235次数       32
    ,bao_zi = 0             %% 一天中豹子次数       33
    ,total_room = 0         %% 总创建房间数         34
    ,doudizhu_room_card = 0 %% 斗地主房卡消耗数      35
    ,niuniu_room_card = 0   %% 牛牛房卡消耗数         36
    ,shidianban_room_card = 0   %% 十点半房卡消耗数      37
    ,tuiduizi_room_card = 0 %% 推对子房卡消耗数         38
    ,wakeng_room_card = 0   %% 挖坑房卡消耗数          39
    ,zhajinhua_room_card = 0    %% 诈金花房卡消耗数     40
    ,agent_room_num = 0     %% 创建的代理房数量         41
    ,balance_total_score = 0 %% 平衡总分 有牛番       42
    ,balance_total_score2 = 0 %%无牛番                43
}).

-record(ets_online, {
    role_id = 0
    ,role_pid = 0
    ,conn_pid = 0
}).

%% 自增id
-define(auto_id_tab, auto_id_tab).
-record(auto_id, {
    id,
    use_max_id
}).

%% 玩家房间列表
-define(player_room_log_tab, player_room_log_tab).
-record(player_room_log_tab, {
    id,               %% 玩家id
    room_list = []    %% 房间列表
}).

%% 玩家房间列表(牛牛之外的)
-define(player_room_log2_tab, player_room_log2_tab).
-record(player_room_log2_tab, {
    id,               %% 玩家id
    room_list = []    %% 房间列表[{PlayType, []}]
}).

%% 备份存入mysql的数据   房间回放
-define(room_log_backup_tab, room_log_backup_tab).
-record(room_log_backup_tab, {
    id,              %% 1 房间数据     2牌局数据
    num = 500,       %% 最大备份的数据条数
    list = []        %% 
}).

%% 微信唯一id 对应 玩家id
-define(wechatid_to_role_id_tab, wechatid_to_role_id_tab).
-record(wechatid_to_role_id_tab, {
    wechat_id, 
    role_id
}).

-define(temp_account_tab, temp_account_tab).
-record(temp_account_tab, {
    key,     %% {Account, Password}
    role_id  %% role id
}).