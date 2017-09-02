%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 五月 2017 17:14
%%%-------------------------------------------------------------------
-author("Administrator").

-define(MAX_SEAT_NUM, 3). %% 最大座位数
-define(MAX_ROUND_NUM(CostCardNum), CostCardNum * 8).  %% 最大回合数

%% 房间阶段
-define(PERIOD_WAITING, 0).
-define(PERIOD_START, 1).
-define(PERIOD_HEI_WA, 2).
-define(PERIOD_WA_KENG, 3).
-define(PERIOD_PLAYING, 4).
-define(PERIOD_CALC, 5).

%% 进程字典
-define(DICT_PLAYER_LIST, dict_player_list).  %% 玩家列表
-define(DICT_PERIOD, dict_period).  %% 房间所处于阶段（0=等待，1=开始，2=抢庄，3=下注，4=亮牌，5=结算）
-define(DICT_ROUND, dict_round).    %% 当前局数
-define(DICT_KENGZHU_ID, dict_kengzhu_id).  %% 坑主玩家ID
-define(DICT_INIT_POKER_LIST, dict_init_poker_list).  %% 初始扑克列表
-define(DICT_POKER_LIST, dict_poker_list).    %% 扑克牌列表
-define(DICT_ACTION_PLAYER_ID, dict_action_player_id).  %% 可行动玩家ID
-define(DICT_BASE_SCORE, dict_base_score).  %% 底分
-define(DICT_MULTIPLE, dict_multiple).  %% 倍数
-define(DICT_LAST_STATE_NAME, dict_last_state_name).  %% 上一次的StateName
-define(DICT_ROUND_CALC_PB, dict_round_calc_pb).  %% 结算消息数据
-define(DICT_CALL_KENGZHU, dict_call_kengzhu).    %% 叫坑主记录
-define(DICT_KENGZHU_POKER_LIST, dict_kengzhu_poker_list).    %% 坑主4张牌
-define(DICT_LAST_DISCARD, dict_last_discard).  %% 最近出牌
-define(DICT_BOMB_NUM, dict_bomb_num).    %% 本局炸弹数
-define(DICT_FIRST_CALL_KENGZHU, dict_first_call_kengzhu).    %% 第一个叫坑主
-define(DICT_LAST_WINNER_ID, dict_last_winner_id).    %% 上一次胜利玩家ID
-define(DICT_HEART_FOUR_PLAYER_ID, dict_heart_four_player_id).  %% 有红心4玩家id
-define(DICT_DISMISS_OPT_LIST, dict_dismiss_opt_list). %% 解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
-define(DICT_RECORD_PID, dict_record_pid).    %% 回放记录进程
-define(DICT_CAN_COST_CARD, dict_can_cost_card). %% 是否可以扣卡

%% 回放记录的协议
-define(WAKENG_RECORD_LIST, [17001, 17003, 17004, 17005, 17007, 17008, 17009, 17012, 17013, 17015, 17017, 17020]).

%% 牌型
-define(STYLE_BOMB, 1).         %% 炸弹
-define(STYLE_SINGLE, 2).       %% 单牌
-define(STYLE_PAIR, 3).         %% 对牌
-define(STYLE_THREE, 4).        %% 三张牌
-define(STYLE_ORDER_SINGLE, 5). %% 单顺
-define(STYLE_ORDER_DOUBLE, 6). %% 双顺
-define(STYLE_ORDER_THREE, 7).  %% 三顺

%% 牌型数据
-record(poker_style, {
  style = 0           %% 牌型
  ,order_num = 0      %% 顺序数
  ,max_num = 0        %% 最大数（用作比较大小）
}).

%% 玩家出牌数据
-record(player_discard, {
  player_id = 0
  ,poker_list = []
  ,style = false     %% #poker_style{}
}).

%% 斗地主房间进程state
-record(room_wakeng, {
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

%% 挖坑玩家
-record(player_wakeng, {
  id = 0                        %% 玩家id
  ,pid = 0                      %% 玩家进程ID
  ,socket = 0                   %% 登录游戏服的socket
  ,name = ""                    %% 玩家名字
  ,score = 0                    %% 积分
  ,score_change = 0             %% 当前局得分
  ,seat_id = 0                  %% 座位ID
  ,icon = ""                    %% 玩家头像
  ,state = 0                    %% 状态 0=等待，1=游戏中，2=观战中
  ,is_online = true            %% 是否在线
  ,is_exit_calc = false        %% 是否已退出结算界面
  ,is_exit_room = false        %% 是否申请退出房间
  ,poker_list = []              %% 扑克牌列表 [#poker{}, ...]
  ,discarded_poker_list = []    %% 已出扑克牌列表 [[#poker{}, ...], [#poker{}, ...], ...]
  ,bomb_num = 0                 %% 打出炸弹数
  ,total_bomb_num = 0           %% 打出炸弹总数
  ,is_alert = false            %% 是否发出警报
  ,max_score_change = 0         %% 单局最高分
  ,win_num = 0                  %% 胜利局数
  ,is_playing = false          %% 是否已经在玩
  ,sex = 0
  ,ip                           %%
  ,gps = ""                     %% 定位信息
}).