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
-define(role, role).
-record(role, {
    id      = 0                     %% 玩家ID   
    ,pid        = 0                 %% 玩家进程ID
    ,connpid    = 0                 %% 连接进程ID
    ,socket     = 0                 %% tcp socket
    ,wechat_id  = ""                %% 微信id
    ,wechat_name  = ""              %% 微信名字
    ,sex        = 0                 %% 性别
    ,vip_lv      = 0                %% 玩家VIP等级
    ,room_card  = 0                 %% 房卡数
    ,room_card_cost = 0             %% 房卡消耗数
    ,room_card_recharge = 0         %% 房卡充值数
    ,icon       = ""                %% 玩家头像
    ,account    = ""                %% 正式账号
    ,password   = ""                %% 正式账号密码
    ,temp_account = ""              %% 临时账号
    ,temp_password = ""             %% 临时密码
    ,temp_account_endtime = 0       %% 临时账号到期时间
    ,agent_invite_code = ""         %% 代理邀请码
    ,agent_id = 0                   %% 代理id
    ,room_id    = 0                 %% 所在房间ID
    ,room_pid   = 0                 %% 所在房间进程id
    ,room_type  = 0                 %% 房间类型
    ,is_online = false              %% 是否在线
    ,status = 0                     %% 0=正常，1=封号
    ,ip
    ,total_score = 0                %% 总积分
    ,total_win_num = 0              %% 总胜利局数
    ,total_pay = 0                  %% 总充值数（单位：分）
    ,total_round = 0                %% 总局数
    ,five_little_niu = 0            %% 一天中五小牛次数
    ,five_flower_niu = 0            %% 一天中五花牛次数
    ,two_three_five = 0             %% 一天中235次数
    ,bao_zi = 0                     %% 一天中豹子次数
    ,total_room = 0                 %% 总创建房间数
    ,doudizhu_room_card = 0         %% 斗地主房卡消耗数
    ,niuniu_room_card = 0           %% 牛牛房卡消耗数
    ,shidianban_room_card = 0       %% 十点半房卡消耗数
    ,tuiduizi_room_card = 0         %% 推对子房卡消耗数
    ,wakeng_room_card = 0           %% 挖坑房卡消耗数
    ,zhajinhua_room_card = 0        %% 诈金花房卡消耗数
    ,agent_room_num = 0             %% 创建的代理房数量
    ,balance_total_score = 0        %% 平衡总分 有牛番
    ,balance_total_score2 = 0       %%无牛番
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

%% 备份存入mysql的数据   房间回放
-define(room_log_backup_tab, room_log_backup_tab).
-record(room_log_backup_tab, {
    id,              %% 1 房间数据     2牌局数据
    list = []
}).

%% 微信唯一id 对应 玩家id
-define(wechatid_to_role_id_tab, wechatid_to_role_id_tab).
-record(wechatid_to_role_id_tab, {
    wechat_id, 
    role_id
}).