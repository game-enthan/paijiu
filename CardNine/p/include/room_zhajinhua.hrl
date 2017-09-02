%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%% 诈金花房间
%%% @end
%%% Created : 15. 五月 2017 21:25
%%%-------------------------------------------------------------------
-author("Administrator").

-define(MAX_SEAT_NUM, 7). %% 最大座位数
-define(MAX_ROUND_NUM(CostCardNum), CostCardNum * 8).  %% 最大回合数
-define(MAX_LUNSHU, 10).    %% 最大轮数
-define(XIQIAN_NUM, 5).     %% 喜钱数

%% 房间阶段
-define(PERIOD_WAITING, 0).
-define(PERIOD_START, 1).
-define(PERIOD_CHIPIN, 2).
-define(PERIOD_CALC, 3).

%% 进程字典
-define(DICT_PLAYER_LIST, dict_player_list).  %% 玩家列表
-define(DICT_PERIOD, dict_period).  %% 房间所处于阶段（0=等待，1=开始，2=跟注，3=结算）
-define(DICT_ROUND, dict_round).    %% 当前局数
-define(DICT_ZHUANG_ID, dict_zhuang_id).  %% 庄家玩家ID
-define(DICT_INIT_POKER_LIST, dict_init_poker_list).  %% 初始扑克列表
-define(DICT_POKER_LIST, dict_poker_list).    %% 扑克牌列表
-define(DICT_LAST_STATE_NAME, dict_last_state_name).  %% 上一次的StateName
-define(DICT_TOTAL_CHIP, dict_total_chip).    %% 总注数
-define(DICT_LUNSHU, dict_lunshu).      %% 当前轮数
-define(DICT_CHIPIN_PLAYER_ID, dict_chipin_player_id).      %% 当前可下注玩家ID
-define(DICT_WINNER_ID, dict_winner_id).    %% 上一轮赢家ID
-define(DICT_ROUND_CALC_PB, dict_round_calc_pb).  %% 结算消息数据
-define(DICT_LUN_LAST_ID, dict_lun_last_id).  %% 一轮中最后玩家id
-define(DICT_DISMISS_OPT_LIST, dict_dismiss_opt_list). %% 解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
-define(DICT_RECORD_PID, dict_record_pid).    %% 回放记录进程
-define(DICT_CAN_COST_CARD, dict_can_cost_card). %% 是否可以扣卡

%% 回放记录的协议
-define(ZHAJINHUA_RECORD_LIST, [15001, 15004, 15006, 15008, 15009, 15010, 15012, 15014, 15015, 15016, 15017, 15018, 15020, 15021, 15024, 15025, 15029, 15030]).

%% 牌型
-define(STYLE_SANPAI, 0).   %% 散牌
-define(STYLE_DUIZI,  1).   %% 对子
-define(STYLE_SHUNZI, 2).   %% 顺子
-define(STYLE_JINHUA, 3).   %% 金花
-define(STYLE_SHUNJIN, 4).  %% 顺金
-define(STYLE_BAOZI,  5).   %% 豹子

%% 诈金花房间进程state
-record(room_zhajinhua, {
  room_id = 0
  ,room_type = 0
  ,owner_id = 0
  ,cost_card_num = 0    %% 消耗房卡数
  ,max_round = 0        %% 最大局数
  ,create_time = 0      %% 创建时间
  ,property
  ,ts = 0               %% 状态起始时间截
  ,t_cd = 0             %% 状态CD
}).

%% 诈金花玩家
-record(player_zhajinhua, {
  id = 0                        %% 玩家id
  ,pid = 0                      %% 玩家进程ID
  ,socket = 0                   %% 登录游戏服的socket
  ,name = ""                    %% 玩家名字
  ,score = 0                    %% 积分
  ,score_change = 0             %% 当前局得分
  ,total_chip_in = 0            %% 总下注数
  ,seat_id = 0                  %% 座位ID
  ,icon = ""                    %% 玩家头像
  ,state = 0                    %% 状态 0=等待，1=游戏中，2=观战中
  ,is_online = true            %% 是否在线
  ,is_see_poker = false        %% 是否已看牌
  ,is_add_chip = false         %% 是否已加注
  ,one_chip = 0                 %% 单注数
  ,is_exit_calc = false        %% 是否已退出结算界面
  ,poker_list = []              %% 扑克牌列表 [#poker{}, ...]
  ,style = 0                    %% 牌型 0=单张，1=对子，2=顺子，3=金花，4=顺金，5=豹子
  ,max_poker = {}               %% 最大牌
  ,max_style = 0                %% 最大牌型
  ,max_scroe_change = 0         %% 单局最高得分
  ,is_exit_room = false        %% 是否申请退出房间
  ,win_num = 0                  %% 赢多少局
  ,is_playing = false          %% 是否已经在玩
  ,sex = 0
  ,ip                           %%
  ,gps = ""                     %% 定位信息
}).