%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2017 12:36
%%%-------------------------------------------------------------------
-author("Administrator").

%%牌型
-define(DATIANWANG, 110).			              	%%大天王
-define(JIUXIAO, 109).				              	%%九小
-define(BAXIAO, 108).					              	%%八小
-define(QIXIAO, 107).					              	%%七小
-define(LIUXIAO, 106).				              	%%六小
-define(TIANWANG, 105).				              	%%天王
-define(RENWUXIAO, 104).				              %%人五小
-define(WUXIAO, 103).						              %%五小
-define(SHIDIANBAN, 102).				              %%十点半
-define(DIANSHUPAI, 101).				              %%点数牌
-define(BAOPAI, 100).						              %%爆牌

-define(MAX_SEAT_NUM, 7). 			              %%最大座位数

%%扑克牌列表
-define(INIT_POKER_LIST, init_poker_list).   %%初始化扑克牌列表
-define(POKER_LIST, poker_list).				      %%洗牌列表

%%房间进程状态
-define(ROOM_STATE_WAITING, 1).		                     %%等待状态
-define(ROOM_STATE_START, 2).				                   %%开始状态
-define(ROOM_STATE_XIAZHU, 3).			                   %%下注状态
-define(ROOM_STATE_QUPAI, 4).				                   %%取牌状态
-define(ROOM_STATE_CALC, 5).				                   %%结算状态

%%进程属性
-define(DICT_LAST_STATE_NAME, dict_last_state_name).       %%上一个StateName
-define(DICT_PERIOD, dict_period).				          %%房间所处的状态（11为等待，12为开始，13为下注）
-define(DICT_PLAYER_LIST, dict_player_list).		          	%%所有玩家的列表
-define(DICT_ROUND, dict_round).				            %%当前的局数
-define(DICT_ZHUANGJIAID, dict_zhuangjiaid).		            %%庄家ID
-define(DICT_ROUND_ENDTIME, dict_round_endtime).		        %%当前局结束时间
-define(DICT_NOW_PLAYER, dict_now_player).                  %%当前操作玩家
-define(DICT_ROUND_CALC_PB, dict_round_calc_pb).  %% 结算消息数据
-define(DICT_DISMISS_OPT_LIST, dict_dismiss_opt_list). %% 解散房间操作列表 [{Opt, PlayerId, PlayerName},...]
-define(DICT_RECORD_PID, dict_record_pid).    %% 回放记录进程
-define(DICT_CAN_COST_CARD, dict_can_cost_card). %% 是否可以扣卡

-define(MAX_ROUND_NUM(CostCardNum), CostCardNum * 8).   %% 最大回合数

-define(SERVER, ?MODULE).

-define(SHIDIANBAN_RECORD_LIST, [19001, 19004, 19005, 19006, 19008, 19009, 19011, 19014, 19018, 19019]).

%%房间进程记录
-record(room_shidianban, {
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

%%10点半玩家
-record(player_shidianban,{
  id = 0												  %% 玩家id
  ,pid = 0												%% 玩家进程
  ,socket = 0                   %% 登录游戏服的socket
  ,card = 0 											%% 房卡
  ,name = ""											%% 姓名
  ,icon = ""                      %% 玩家头像
  ,chipnum = 0										%% 玩家下注数
  ,seat_id	=0										%% 玩家座位号
  ,state = 0											%% 玩家状态（0为等待，1为正在游戏，2为观战状态）
  ,poker_dianshu	= 0							%% 非特殊牌的点数
  ,poker_zhangshu = 0						  %% 非特殊牌型的张数
  ,poker_list = []								%% 玩家扑克列表
  ,style	= 0											%% 牌型
  ,style_list = []						    %% 牌型列表
  ,result = 0                     %% 全局最高分
  ,score = 0							        %% 分数
  ,score_change = 0						    %% 每局得分
  ,is_take_poker	= true				  %% 是否要牌（false为不要牌）
  ,is_baopai	= false					    %% 是否爆牌（true为爆牌）
  ,is_showpoker	= false					  %% 是否亮牌（true为亮牌）
  ,is_exit_calc = false					  %% 是否退出结算界面
  ,is_exit_room = false					  %% 是否退出房间
  ,win_num = 0                    %% 赢多少局
  ,is_addchipin = false					  %% 是否加注
  ,is_online = true						    %% 是否在线
  ,is_play_chose = false         	%% 是否有特殊牌型
  ,calc_list = []                 %% 总局的分数列表
  ,is_playing = false            	%% 是否已经在玩
  ,sex = 0
  ,ip                           %%
  ,gps = ""                     %% 定位信息
}).