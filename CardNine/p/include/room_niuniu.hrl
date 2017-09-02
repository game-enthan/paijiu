%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%% 牛牛房间
%%% @end
%%% Created : 08. 五月 2017 16:35
%%%-------------------------------------------------------------------
-author("Administrator").

-define(MAX_SEAT_NUM, 7). %% 最大座位数
-define(AUTO_OPT_TIMEOUT, 10000). %% 自动操作等待时间10s

%% 房间阶段
-define(PERIOD_WAITING, 0).      %% 等待
-define(PERIOD_START, 1).        %% 开始
-define(PERIOD_QIANGZHUANG, 2).  %% 抢庄
-define(PERIOD_CHIPIN, 3).       %% 下注
-define(PERIOD_SHOWPOKER, 4).    %% 亮牌
-define(PERIOD_CALC, 5).         %% 结算

%% 进程字典
-define(DICT_PLAYER_LIST, dict_player_list).  %% 玩家列表
-define(DICT_PERIOD, dict_period).  %% 房间所处于阶段（0=等待，1=开始，2=抢庄，3=下注，4=亮牌，5=结算）
-define(DICT_ROUND, dict_round).    %% 当前局数
-define(DICT_QIANG_ZHUANG_LIST, dict_qiang_zhuang_list).  %% 翻四张抢庄列表
-define(DICT_LAST_ZHUANG_SCORE, dict_last_zhuang_score).  %% 翻四倍抢庄上一局的倍数
-define(DICT_ZHUANG_ID, dict_zhuang_id).  %% 庄家玩家ID
-define(DICT_LAST_ZHUANG_ID, dict_last_zhuang_id).  %% 上一局庄家玩家ID
-define(DICT_INIT_POKER_LIST, dict_init_poker_list).  %% 初始扑克列表
-define(DICT_POKER_LIST, dict_poker_list).    %% 扑克牌列表
-define(DICT_ROUND_ENDTIME, dict_round_endtime).    %% 当前局结束时间
-define(DICT_LAST_STATE_NAME, dict_last_state_name).  %% 上一次的StateName
-define(DICT_ROUND_CALC_PB, dict_round_calc_pb).  %% 结算消息数据
-define(DICT_LAST_NIUNIU_ZHUANG, dict_last_niuniu_zhuang).  %% 牛牛上庄 [{Round, PlayerId, Style, MaxPoker}, ...]
-define(DICT_BIGGEST_ID, dict_biggest_id).    %% 通比庄家ID
-define(DICT_HAS_CHIP, dict_has_chip).  %% 是否当局已有人下注
-define(DICT_DISMISS_OPT_LIST, dict_dismiss_opt_list). %% 解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
-define(DICT_RECORD_PID, dict_record_pid).    %% 回放记录进程
-define(DICT_ROOM_TYPE, dict_room_type).   %% 房间类型
-define(DICT_DOUBLE_TYPE, dict_double_type). %% 翻倍类型
% -define(DICT_HUIFANG_LIST, dict_huifang_list). %% 每一局的回放列表
% -define(DICT_ROOM_ROUND_KEY_LIST, dict_room_round_key_list). %% 这一轮（10局或20局）的牌局id记录
% -define(DICT_START_ROOM_TIME, dict_start_room_time).   %% 房间开始的时间

%% 回放记录的协议
-define(NIUNIU_RECORD_LIST, [12001, 12004, 12006, 12008, 12010, 12012, 12015, 12016, 12018, 12019, 12027]).
-define(NIU_LIST, [[1,3,6],[1,2,7],[2,3,5],[2,2,6],[3,4,3],[10,5,5],[11,2,8], [11,3,7], [11,4,6],[10,11,12],[13,1,9],[12,4,6]]).

-define(dict_poker_four(PlayerId), {dict_poker_four,PlayerId}).   %% 名牌抢的最后一张牌


%% 牛牛房间进程state
-record(room_niuniu, {
    room_id     = 0,          %%房间id
    room_type   = 0,          %%房间类型
    owner_id    = 0,          %% 开此房间的玩家id
    creator_id  = 0,       %% 代理房创建者id
    cost_card_num = 0,    %% 消耗房卡数
    max_round   = 0,        %% 最大局数
    create_time = 0,      %% 创建时间
    pay_way = 0,
    property,
    ts = 0,               %% 状态起始时间截
    t_cd = 0,             %% 状态CD
    is_gm_close = false %% 是否管理员关闭
}).

%% 牛牛玩家
-record(player_niuniu, {
  id = 0                        %% 玩家id
  ,pid = 0                      %% 玩家进程ID
  ,socket = 0                   %% 登录游戏服的socket
  ,name = ""                    %% 玩家名字
  ,balance_total_score = 0      %% 平衡总分
  ,balance_total_score2 = 0      %% 平衡总分 非
  ,score = 0                    %% 总积分
  ,score_change = 0             %% 当前局得分
  ,last_score_change = 0        %% 上局得分
  ,chip = 0                     %% 当前下的筹码数
  ,last_chip = 0                %% 上局下的筹码数
  ,push_chip_num = 0            %% 推注数
  ,seat_id = 0                  %% 座位ID
  ,icon = ""                    %% 玩家头像
  ,state = 0                    %% 状态 0=等待，1=游戏中，2=观战中
  ,is_online = true            %% 是否在线
  ,qiang_zhuang = false         %% 是否抢庄
  ,qiang_score = 0              %% 翻四张抢庄分数
  ,already_qiang_zhuang = false %% 是否进行抢庄操作
  ,is_complete_poker = false    %% 是否已完整算牌
  ,is_ture_poker = false        %% 是否翻牌
  ,is_show_poker = false        %% 是否亮牌
  ,is_exit_calc = false         %% 是否已退出结算界面
  ,poker_list = []              %% 扑克牌列表 [#poker{}, ...]
  ,style = 0                    %% 牌型 0=无牛，1=牛一，。。。 9=牛九，10=牛牛，11=五花牛，12=炸弹牛，13=五小牛
  ,style_list = []              %% 牌型统计
  ,is_exit_room = false        %% 是否申请退出房间
  ,win_num = 0                  %% 赢多少局
  ,is_playing = false          %% 是否已经在玩
  ,sex = 0
  ,ip                           %%
  ,gps = ""                     %% 定位信息
}).