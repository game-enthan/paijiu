%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%% 陕西三代房间
%%% @end
%%% Created : 25. 七月 2017 17:30
%%%-------------------------------------------------------------------
-author("Administrator").

-define(MAX_SEAT_NUM, 3). %% 最大座位数
-define(MAX_ROUND_NUM(CostCardNum), CostCardNum * 10).  %% 最大回合数

%% 房间阶段
-define(PERIOD_WAITING, 0).   %% 等待
-define(PERIOD_START, 1).     %% 开始
-define(PERIOD_PLAYING, 2).   %% 打牌
-define(PERIOD_CALC, 3).      %% 结算

%% 进程字典
-define(DICT_PLAYER_LIST, dict_player_list).  %% 玩家列表
-define(DICT_PERIOD, dict_period).  %% 房间所处于阶段
-define(DICT_ROUND, dict_round).    %% 当前局数
-define(DICT_INIT_POKER_LIST, dict_init_poker_list).  %% 初始扑克列表
-define(DICT_POKER_LIST, dict_poker_list).    %% 扑克牌列表
-define(DICT_ACTION_PLAYER_ID, dict_action_player_id).  %% 可行动玩家ID
-define(DICT_BASE_SCORE, dict_base_score).  %% 底分
-define(DICT_MULTIPLE, dict_multiple).  %% 倍数
-define(DICT_LAST_STATE_NAME, dict_last_state_name).  %% 上一次的StateName
-define(DICT_ROUND_CALC_PB, dict_round_calc_pb).  %% 结算消息数据
-define(DICT_LAST_DISCARD, dict_last_discard).  %% 最近出牌
-define(DICT_BOMB_NUM, dict_bomb_num).    %% 本局炸弹数
-define(DICT_LAST_WINNER_ID, dict_last_winner_id).    %% 上一次胜利玩家ID
-define(DICT_HEART_FOUR_PLAYER_ID, dict_heart_four_player_id).  %% 有红心4玩家id
-define(DICT_DISMISS_OPT_LIST, dict_dismiss_opt_list). %% 解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
-define(DICT_RECORD_PID, dict_record_pid).    %% 回放记录进程
-define(DICT_CAN_COST_CARD, dict_can_cost_card).  %% 是否可以扣卡
-define(DICT_SCORE_TYPE, dict_score_type).   %% 炸弹附加的分数
-define(DICT_IS_SPRING, dict_is_spring).  %% 是否春天
-define(DICT_YIN_BAO, dict_yin_bao).      %% 是否引爆

%% 回放记录的协议
-define(SANDAI_RECORD_LIST, [
    22001, 22003, 22004, 22005, 
    22007, 22008, 22009, 22010,
    22013
]).

%% 牌型
-define(STYLE_SINGLE, 1).        %% 单牌
-define(STYLE_PAIR, 2).          %% 对牌
-define(STYLE_THREE_TWO, 3).     %% 三带二
-define(STYLE_THREE_PAIR, 4).    %% 三带一对
-define(STYLE_ORDER_SINGLE, 5).  %% 顺子
-define(STYLE_ORDER_DOUBLE, 6).  %% 双顺（连对）
-define(STYLE_PLANE, 7).         %% 飞机
-define(STYLE_BOMB, 8).          %% 炸弹
-define(STYLE_PLANE_SINGLE, 11). %% 飞机带单牌
-define(STYLE_PLANE_FOUR, 12).   %% 飞机带四张
%% 牌型数据
-record(poker_style, {
    style = 0,          %% 牌型
    order_num = 0,      %% 顺序数
    max_num = 0         %% 最大数（用作比较大小）
}).

%% 玩家出牌数据
-record(player_discard, {
    player_id = 0,
    poker_list = [],
    style = false     %% #poker_style{}
}).

%% 陕西三代房间进程state
-record(room_sandai, {
    room_id = 0,
    room_type = 0,
    owner_id = 0,
    cost_card_num = 0,    %% 消耗房卡数
    max_round = 0,        %% 最大局数
    create_time = 0,      %% 创建时间
    property,
    ts = 0,               %% 状态起始时间截
    t_cd = 0             %% 状态CD
}).



%% 陕西三代玩家
-record(player_sandai, {
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
  ,is_alert = false            %% 是否警报
  ,bomb_num = 0                 %% 打出炸弹数
  ,total_bomb_num = 0           %% 打出炸弹总数
  ,max_score_change = 0         %% 单局最高分
  ,win_num = 0                  %% 胜利局数
  ,is_playing = false          %% 是否已经在玩
  ,sex = 0
  ,ip                           %%
  ,gps = ""                     %% 定位信息
}).