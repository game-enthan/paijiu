    %%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 六月 2017 18:42
%%%-------------------------------------------------------------------
-author("Administrator").

-define(MAX_SEAT_NUM, 4). 			                  %%最大座位数
-define(MAX_ROUND_NUM(CostCardNum), CostCardNum * 12).   %% 最大回合数
-define(CHIP_IN_TIME, 10).    %% 下注时间

%% 牌九属性值
%% 天,地,人,和,长,短,杂
%% 比较点数:value=(点数+1)*属性值
-define(DAN,80).
-define(ZA,82).
-define(DUAN,83).
-define(CHANG,84).
-define(HE,85).
-define(REN,86).
-define(DI,87).
-define(TIAN,88).
-define(DIGANG,1000). 
-define(TIANGANG,1001). 
-define(DIJIUWANG,5400).
-define(DUIZA,1100).    
-define(DUIDUAN,2000).
-define(DUICHANG,6000).
-define(DUIHE,20000).
-define(DUIREN,11000).

-define(DUIDI,50000).
-define(DUITIAN,10000).
-define(HUANGSHANG,15000).
-define(SANBAZHA,135000).
-define(GUIZI,135001).
%%牌九牌列表
-define(INIT_PAIJIU_LIST,init_paijiu_list).   		    %%初始化牌九列表
-define(PAIJIU_LIST,paijiu_list).				              %%洗牌牌九列表

%%房间进程状态
-define(ROOM_STATE_WAITING, 1).		                     %%  等待状态
-define(ROOM_STATE_START, 2).				                   %%  开始状态
-define(ROOM_STATE_XIAZHU, 3).			                   %%  下注状态
-define(ROOM_STATE_SHOW, 4).				                   %%  亮牌状态
-define(ROOM_STATE_CALC, 5).				                   %%  结算状态

%%进程属性
-define(DICT_LAST_STATE_NAME, dict_last_state_name).    %%  上一个StateName
-define(DICT_PERIOD, dict_period).				              %%  房间所处的状态（1为等待，2为开始，3为下注）
-define(DICT_PLAYER_LIST, dict_player_list).		        %%  所有玩家的列表
-define(DICT_ROUND, dict_round).				                %%  当前的局数
-define(DICT_ZHUANGJIAID, dict_zhuangjiaid).		        %%  庄家ID
-define(DICT_ROUND_ENDTIME, dict_round_endtime).		    %%  当前局结束时间
-define(DICT_NOW_PLAYER, dict_now_player).              %%  当前操作玩家
-define(DICT_ROUND_CALC_PB, dict_round_calc_pb).        %%  结算消息数据
-define(DICT_PAIJIU_LIST, dict_paijiu_list).            %%  每局牌九列表
-define(DICT_DISMISS_APPLY_ID, dict_dismiss_apply_id).  %%  解散房间申请人ID
-define(DICT_CHIP_IN_ENDTIME, dict_chip_in_endtime).    %%  下注结束时间
-define(DICT_DISMISS_OPT_LIST, dict_dismiss_opt_list).  %%  解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
-define(DICT_RECORD_PID, dict_record_pid).              %%  回放记录进程
-define(DICT_CAN_COST_CARD, dict_can_cost_card).        %%  是否可以扣卡
-define(DICT_ZHUANGJIA_SEATID,dict_zhuangjia_seatid).
-define(DICT_ROOM_TYPE,room_type).
%% 回放记录的协议  
-define(PAIJIU_RECORD_LIST, [20001, 20004, 20006, 20007, 20009, 20012]).

%% 牌九牌型记录
-record(dapaijiu, {num,property,value}).   %% 大牌九大牌牌型
-record(xiaopaijiu,{num,property,value}).  %% 小牌九小牌牌型
-record(dianshu,{sum,property,value}).     %% 牌的属性
-record(tianjiu,{num,property}).
%% 牌九进程记录
-record(room_paijiu, {
   room_id = 0
  ,room_type = 0
  ,owner_id = 0
  ,cost_card_num = 0    %% 消耗房卡数
  ,max_round = 0        %% 最大局数
  ,create_time = 0      %% 创建时间
  ,property             %% 房间属性
  ,ts = 0               %% 状态起始时间截
  ,t_cd = 0             %% 状态CD
}).

%% 牌九玩家信息
-record(player_paijiu,{
   id = 0												  %% 玩家id
  ,pid = 0												%% 玩家进程
  ,card = 0 											%% 房卡
  ,name = ""											%% 姓名
  ,icon = ""                      %% 玩家头像
  ,seat_id	=0										%% 玩家座位号
  ,cardlist =[]                   %% 牌局列表
  ,state = 0											%% 玩家状态（0为等待，1为正在游戏，2为观战状态）
  ,score = 0							        %% 总得分
  ,score_change = 0						    %% 每局得分
  ,is_exit_calc = false					  %% 是否退出结算界面
  ,is_exit_room = false					  %% 是否退出房间
  ,win_num = 0                    %% 赢多少局
  ,is_online = true						    %% 是否在线
  ,calc_list = []                 %% 总局的分数列表
  ,chipin_num = 0                 %% 下注分数
  ,player_chip_list = []          %% 玩家下注列表
  ,is_playing = false            	%% 是否已经在玩
  ,sex = 0                
  ,ip                             %% ip地址
  ,gps = ""                       %% 定位信息
  ,dapaijiu                      %% 大牌九,小牌九
  ,xiaopaijiu                     %% 小牌九
}).

