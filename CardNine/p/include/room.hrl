%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 五月 2017 16:33
%%%-------------------------------------------------------------------
-author("Administrator").

%% 房间类型
-define(ROOM_TYPE_NIUNIU, 101).               %% 牛牛
-define(ROOM_TYPE_ZHAJINHUA, 102).            %% 诈金花
-define(ROOM_TYPE_DOUDIZHU, 103).             %% 斗地主.
-define(ROOM_TYPE_SHANXI_WAKENG, 104).        %% 陕西挖坑.
-define(ROOM_TYPE_LANZHOU_WAKENG, 105).       %% 兰州挖坑.
-define(ROOM_TYPE_SHIDIANBAN, 106).           %% 十点半.
-define(ROOM_TYPE_TUIDUIZI, 107).             %% 推对子
-define(ROOM_TYPE_SANDAI, 108).               %% 陕西三代
-define(ROOM_TYPE_PAIJIU,109).
%% 玩家状态
-define(PLAYER_STATE_WAITING, 0).
-define(PLAYER_STATE_PLAYING, 1).   %% 游戏中
-define(PLAYER_STATE_WATCHING, 2).  %% 观战
-define(PLAYER_STATE_OUT, 3).       %% 出局
-define(PLAYER_STATE_GIVEUP, 4).    %% 弃牌

-define(STATE_LOOP_TIME, 86400 * 1000). %% 状态循环时间

-define(DICT_HUIFANG_LIST, dict_huifang_list). %% 每一局的回放列表
-define(DICT_ROOM_ROUND_KEY_LIST, dict_room_round_key_list). %% 这一轮（10局或20局）的牌局id记录
-define(DICT_START_ROOM_TIME, dict_start_room_time).   %% 房间开始的时间
-define(DICT_ROOM_PID, dict_room_pid). %% 房间进程


%% 房间基础数据
-record(room, {
    id = 0,                         %% 房间ID
    pid = 0,                        %% 进程ID
    owner_id = 0,                   %% 房主ID
    creator_id = 0,                 %% 创建者ID（代理房间使用）
    cost_room_card_num = 0,         %% 消耗房卡
    type = 0,                       %% 房间类型
    property = {},                  %% 房间属性（#room_niuniu{} / ...）
    seat_list = [],                 %% 空座位列表
    is_start = false,               %% 是否已开始
    is_agent_room = false,          %% 是否代理房
    pay_way = 0                     %% 房费支付方式(1 = 房主支付，2 = AA支付)
}).


%% 牌九房间属性
-record(room_paijiu_property,{
  round_type=1,                      %% 局数类型(1=12局,2=24局)
  banker_type=1,                     %% 坐庄类型 (1 = 房主坐庄，2 = 轮流坐庄，3 = 经典抢庄)
  game_type=1,                       %% 玩法选择(1=大牌九,2=小牌九,3=加锅牌九)
  has_guizi=false,                   %% 鬼子
  has_tianjiuwang=false,            %% 天九王
  has_dijiuwang=false,               %% 地九王
  has_sanbazha=false,                %% 三八为炸弹
  score_type=true                   %% 分数选择(true=每次选分,false=固定分)
}).


%% 牛牛房间属性
-record(room_niuniu_property, {
    round_type = 1,                 %% 回合数类型
    has_flower_card = false,        %% 是否有花牌
    three_card = false,             %% 是否三张牌
    double_type = 0,                %% 翻倍规则(1 = "有牛番"，2 = "牛牛X3牛九X2牛八X2"， 3 = "牛牛X4牛九X3牛八X2牛七X2")
    forbid_enter = false,           %% 是否可以中途进入
    tongbi_score = 0,               %% 通比牛牛分数选择：1\2\4\6
    banker_type = 0,                %% 坐庄类型 (1 = 房主坐庄，2 = 轮流坐庄，3 = 经典抢庄，4 = 翻四张抢庄，5=牛牛上庄，6=通比牛牛)
    has_whn = false,                %% 有五花牛
    has_zdn = false,                %% 有炸弹牛
    has_wxn = false,                %% 有五小牛
    has_push_chip = false,          %% 是否有推注
    forbid_cuopai = false,          %% 是否禁止搓牌
    qiang_score_limit = 4,          %% 明牌抢庄倍数限制（2/3/4）
    is_auto = false,                %% 是否自动
    is_agent_room = false,          %% 是否代理房
    score_type = 0                  %% 底分类型（1=1/2, 2=2/4, 3=4/8, 4=自由分）
}).

%% 诈金花房间属性
-record(room_zhajinhua_property, {
  first_see_poker = false         %% 是否第一回合可以看牌
  ,see_poker_cuopai = false       %% 是否看牌可以搓牌
  ,forbid_enter = false           %% 是否牌局开始后禁止玩家进入
  ,has_xiqian = false             %% 是否有喜钱
  ,p235_big_baozi = false         %% 是否不同花235大于豹子
  ,p235_big_aaa = false           %% 是否不同花235大于AAA
  ,score_type = 1                  %% 1=一分场，2=二分场，3=五分场，4=自由场
}).

%% 斗地主房间属性
-record(room_doudizhu_property, {
  bomb_top = 4         %% 倍数上限：1=16倍，2=32倍，3=64倍，4=不限
  ,show_poker_num = false       %% 显示牌数
  ,record_poker = false           %% 记牌器
  ,player_num = 2             %% 1=2人牌局，2=3人牌局
  ,call_dizhu = 2         %% 叫地主设定：1=赢家先叫，2=轮流叫地主
  ,let_card = false          %% 是否让牌
}).

%% 挖坑房间属性
-record(room_wakeng_property, {
  call_dizhu = 1            %% 叫地主设定：1=叫分，2=黑挖
  ,is_can_bomb = true          %% 是否带炸弹
  ,put_off_poker = false    %% 是否去掉一张3、一张2、4个A
  ,bomb_top = 2             %% 炸弹上限：1=3炸，2=不限
  ,air_bomb_multiple = true %% 是否空炸加倍（兰州）
}).

%% 10点半房间属性
-record(room_shidianban_property, {
  max_round	  				    %%房间的最大局数
  , banker_type = 1			    %%庄家的坐庄方式（1为房主坐庄，2为轮流坐庄）
  , max_chip = 0			    	%%下注数选择（5分封顶，10分封顶，20分封顶）
  , is_specail_play					%%特殊牌型
}).

%%推对子房间属性
-record(room_tuiduizi_property,{
  max_round                 %%房间最大局数
  , banker_type = 0         %%庄家的坐庄方式（1为房主坐庄，2为轮流坐庄，3为赢家坐庄）
  , point_chose = 0         %%分数选择（3分，5分，7分，1-10自由分）
  , is_red_half = false     %%红中算半点
  % , pairs_double = 0      %%翻倍选择（1=对子不翻倍，2=闲家对子翻倍，3=庄家对子翻倍)
  , is_one_red = false      %%是否有独红
  , is_river = false        %%是否压河
  , nine_double = false     %%闲家九点翻倍
  , xian_double = false     %%闲家对子翻倍
  , zhuang_double = false   %%庄翻倍 (庄家对子翻倍暂时闲置)
}).

%% 陕西三代房间属性
-record(room_sandai_property, {
    is_card_num = false,    %%显示牌数
    score_type = 0,         %%炸弹分数选择
    three_take = 0,         %%三代选择（1=三带单能压三带对，2=三带单不能压三带对）
    force_card = false,     %%硬吃硬
    has_aircraft = false,   %%带飞机
    pan_force1 = false,     %%33必压22
    pan_force2 = false,     %%333必压222
    pan_force3 = false,     %%大炸弹必压小炸弹
    pan_force4 = false,     %%33必见炸弹
    pan_force5 = false      %%333必见炸弹
}).

%% 扑克
-record(poker, {
  num = 0           %% 数字
  ,flower = 0       %% 花色 （1=方块，2=梅花，3=红桃，4=黑桃）
}).

%%麻将
-record(mahjong, {
  num = 0           %% 数字
  ,quantity = 0     %% 数量（麻将的筒数1—4）
}).

%% 平衡配置
-record(balance_config, {
    type = 0,     %% 玩法类型
    is_open = 1,  %% 是否开启，1表示开启
    list = []
}).