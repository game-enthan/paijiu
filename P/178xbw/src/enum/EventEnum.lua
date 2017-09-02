local EventEnum = {
	------------------------------- scoket S ----------------------------------
	socketClose 				= 10001,				-- 网络断开
	socketClosed				= 10002,				-- 网络已关闭
	socketConnected				= 10003,				-- 网络连接成功
	socketConnectFail			= 10004,				-- 网络连接失败
	serverTimeReturn			= 10005,				-- 服务器时间更新
	protoIdNotify				= 10006,				-- 协议ID通知
	reLogin						= 10007,				-- 断线重连
	responseIpInfo				= 10008,				-- ip信息
	receiveMsgFailed			= 10009,				-- 接收数据失败
	------------------------------- scoket S ----------------------------------
	--------------------------------- UI S ------------------------------------
	openUI 						= 20001,				-- 打开界面（eventdata = {uiName = "", params = {}}）
	closeUI 					= 20002,				-- 关闭界面
	closeUIIngoreEffect			= 20003,				-- 关闭界面忽略效果
	--------------------------------- UI E ------------------------------------
	-------------------------------- 玩家 S -----------------------------------
	roomCardChange				= 30001,
	-------------------------------- 玩家 E -----------------------------------
	------------------------------- 房间 S ------------------------------------
	closeRoom					= 40001,				-- 关闭房间
	exitRoom					= 40002,				-- 玩家离开房间（eventdata = {id = 1, name = ""}）
	agreeDisbandRoom			= 40003,				-- 同意解散房间（eventData = {id = 1, name = "", oprType = 1}）
	disagreeDisbandRoom			= 40004,				-- 拒绝解散房间（eventData = {id = 1, name = "", oprType = 1}）
	exitGoldFlower				= 40005,				-- 退出炸金花
	exitLandlord				= 40006,				-- 退出斗地主
	exitWK						= 40007,				-- 退出挖坑
	exitTenHalf					= 40008,				-- 退出十点半
	exitRoomReq					= 40009,				-- 解散房间的申请
	exitPushPairs				= 40010,				-- 退出推对子
	exitSD						= 40011,				-- 退出三代
	------------------------------- 房间 E ------------------------------------
	------------------------------- 斗牛 S ------------------------------------
	bullPlayerOnline			= 50001,				-- 斗牛玩家上线（eventdata = {id = 1, isOnline = false}}）
	bullPlayerEnter				= 50002,				-- 斗牛房间加入新玩家(eventdata = player)
	bullQiangZhuang				= 50003,				-- 抢庄（eventData = {id = 1, qiangZhuang = false}）
	bullChipIn					= 50004,				-- 玩家下注（eventData = {id, chipNum}）
	bullRoomStateChange			= 50008,				-- 房间状态变化
	bullRoundCalculate			= 50009,				-- 小结算
	bullPlayerShowPoker			= 50010,				-- 玩家亮牌
	bullPlayerReady				= 50011,				-- 玩家准备
	bullQureyZhuang				= 50012,				-- 定庄
	bullSitDown					= 50013,				-- 坐下
	bullRoundUpdate				= 50014,				-- 局数更新
	bullMQiangZhuang			= 50015,				-- 明牌抢庄
	bullAgentRoomList			= 50016,				-- 代理房间列表
	bullCloseAgentRoom			= 50017,				-- 关闭代理房间
	------------------------------- 斗牛 E ------------------------------------
	------------------------------- 战绩 S ------------------------------------
	recordListUpdate			= 60001,				-- 战绩列表更新
	roundListUpdate				= 60002,				-- 牌局列表更新
	startPlayBack				= 60003,				-- 开始回放
	endPlayBack					= 60004,				-- 结束回放
	------------------------------- 战绩 E ------------------------------------
	------------------------------- 聊天 S ------------------------------------
	chatMsg						= 70001,				-- 聊天消息(eventData = {id = 1, name = "", icon = "", msgType = 1, strContent = ""})
	msgNotice					= 70002,				-- 更新公告消息
	voiceFinishPlay				= 70003,				-- 音效播放完毕
	------------------------------- 聊天 E ------------------------------------
	------------------------------- 商城 S ------------------------------------
	shopProducts				= 80001,				-- 商品列表更新
	payResult					= 80002,				-- 支付返回
	------------------------------- 商城 E ------------------------------------
	------------------------------- 金花 S ------------------------------------
	goldFlowerPlayerOnline		= 90001,				-- 金花玩家上线（eventdata = {id = 1, isOnline = false}）
	goldFlowerPlayerChipIn		= 90002,				-- 跟注（eventdata = {id = 1, chip = 10}）
	goldFlowerPlayerAddChip		= 90003,				-- 加注（eventdata = {id = 1, chip = 10}）
	goldFlowerPlayerSeePoker	= 90004,				-- 玩家看牌(eventdata = {id = 1})
	goldFlowerPlayerSingleChip	= 90005,				-- 更新玩家单注数(eventdata = {singleChip = 1})
	goldFlowerTurnCard			= 90006,				-- 玩家自己看完牌推送扑克牌列表
	goldFlowerPlayerQuit		= 90007,				-- 玩家弃牌(eventdata = {id = 1})
	goldFlowerPlayerCompare		= 90008,				-- 比牌(eventdata = {id1 = 1, id2 = 2, winId = 1})
	goldFlowerPlayerOut			= 90009,				-- 广播玩家出局(eventdata = {id = 1})
	goldFlowerRoundUpdate		= 90010,				-- 广播局数更新
	goldFlowerTurnUpdate		= 90011,				-- 广播轮数更新
	goldFlowerTotalChipUpdate	= 90012,				-- 广播总注数更新
	goldFlowerNewPlayer			= 90013,				-- 广播新玩家加入
	goldFlowerRoundAccount		= 90014,				-- 广播小结算
	goldFlowerPlayerReady		= 90015,				-- 广播玩家退出小结算界面(eventdata = {id = 1})
	goldFlowerZhuangId			= 90016,				-- 广播庄家ID变更(eventdata = {id = 1})
	goldFlowerPlayerSitDown		= 90017,				-- 广播玩家坐下(eventdata = {id = 1})
	goldFlowerActionPlayer		= 90018,				-- 广播轮到该玩家操作(eventdata = {id = 1})
	goldFlowerBottomChip		= 90019,				-- 广播开始前所有玩家下底注
	goldFlowerPeriod			= 90020,				-- 金花牌局状态变更
	------------------------------- 金花 E ------------------------------------
	------------------------------ 斗地主 S -----------------------------------
	landlordPlayerOnline		= 11001,				-- 斗地主玩家在线状态改变（eventdata = {id = 1, isOnline = false}）
	landlordPeriod				= 11002,				-- 斗地主阶段更新
	landlordActionPlayer		= 11003,				-- 广播行动玩家变更(eventdata = {id = 1})
	landlordPlayerCallDiZhu		= 11004,				-- 广播玩家叫地主选择(eventdata = {id = 1, result = 0})
	landlordQureyDiZhu			= 11005,				-- 广播最终叫地主结果
	landlordBottomPoker			= 11006,				-- 广播地主牌更新
	landlordPlayCard			= 11007,				-- 广播玩家出牌(eventdata = {id = 1})
	landlordMultipleUpdate		= 11008,				-- 广播倍数更新(eventdata = {num = 1})
	landlordBaoJing				= 11009,				-- 广播玩家报警
	landlordRoundAccount		= 11010,				-- 广播小结算信息
	landlordExitRoundAccount	= 11011,				-- 广播退出小结算信息
	landlordNewPlayer			= 11012,				-- 广播新玩家加入
	landlordRoundUpdate			= 11013,				-- 广播局数更新
	landlordFarmerWinPokerNum	= 11014,				-- 广播让多少张牌
	------------------------------ 斗地主 E -----------------------------------
	------------------------------  挖坑 S ------------------------------------
	wkPlayerOnline				= 12001,				-- 斗地主玩家在线状态改变（eventdata = {id = 1, isOnline = false}）
	wkPeriod					= 12002,				-- 斗地主阶段更新
	wkActionPlayer				= 12003,				-- 广播行动玩家变更(eventdata = {id = 1})
	wkPlayerCallDiZhu			= 12004,				-- 广播玩家叫地主选择(eventdata = {id = 1, result = 0})
	wkQureyDiZhu				= 12005,				-- 广播最终叫地主结果
	wkBottomPoker				= 12006,				-- 广播地主牌更新
	wkPlayCard					= 12007,				-- 广播玩家出牌(eventdata = {id = 1})
	wkMultipleUpdate			= 12008,				-- 广播倍数更新(eventdata = {num = 1})
	wkBaoJing					= 12009,				-- 广播玩家报警
	wkRoundAccount				= 12010,				-- 广播小结算信息
	wkExitRoundAccount			= 12011,				-- 广播退出小结算信息
	wkNewPlayer					= 12012,				-- 广播新玩家加入
	wkRoundUpdate				= 12013,				-- 广播局数更新
	------------------------------  挖坑 E ------------------------------------
	-----------------------------  十点半 S -----------------------------------
	tenPlayerOnline				= 13001,				-- 十点半玩家上线（eventdata = {id = 1, isOnline = false}}）
	tenPlayerEnter				= 13002,				-- 十点半房间加入新玩家(eventdata = player)
	tenChipIn					= 13003,				-- 玩家下注（eventData = {id, chipNum}）
	tenCallCard					= 13004,				-- 玩家要牌 (eventData = {id, isCallCard})
	tenRoomStateChange			= 13005,				-- 房间状态变化
	tenRoundAccount				= 13006,				-- 小结算
	tenExitRoundAccount			= 13007,				-- 广播退出小结算信息
	tenPlayerReady				= 13008,				-- 玩家准备
	tenSitDown					= 13009,				-- 坐下
	tenRoundUpdate				= 13010,				-- 广播局数更新
	tenTurnCard					= 13011,				-- 广播玩家开牌
	tenUpdatePlayerCard			= 13012,				-- 更新玩家手牌
	tenPlayerCallCard			= 13013,				-- 更新要牌玩家ID	
	tenUpdateZhuangId			= 13014,				-- 更新庄家ID
	-----------------------------  十点半 E -----------------------------------
	-----------------------------  推对子 S -----------------------------------
	pushPlayerOnline			= 14001,				-- 推对子玩家上线（eventdata = {id = 1, isOnline = false}}）
	pushPlayerEnter				= 14002,				-- 推对子房间加入新玩家(eventdata = player)
	pushChipIn					= 14003,				-- 玩家下注（eventData = {id, chipNum}）
	pushRoomStateChange			= 14004,				-- 房间状态变化
	pushRoundAccount			= 14005,				-- 小结算
	pushExitRoundAccount		= 14006,				-- 广播退出小结算信息
	pushPlayerReady				= 14007,				-- 玩家准备
	pushSitDown					= 14008,				-- 坐下
	pushRoundUpdate				= 14009,				-- 广播局数更新
	pushTurnCard				= 14010,				-- 广播玩家开牌
	pushUpdateZhuangId			= 14011,				-- 更新庄家ID	
	pushChipCountDown			= 14012,				-- 更新下注时间限制
	-----------------------------  推对子 E -----------------------------------
	-----------------------------  排行榜 S -----------------------------------
	rankPlayerList				= 15001,				-- 更新排行榜玩家信息
	-----------------------------  排行榜 E -----------------------------------
	------------------------------  三代 S ------------------------------------
	sdPlayerOnline				= 16001,				-- 玩家在线状态改变（eventdata = {id = 1, isOnline = false}）
	sdPeriod					= 16002,				-- 阶段更新
	sdActionPlayer				= 16003,				-- 广播行动玩家变更(eventdata = {id = 1})
	sdPlayCard					= 16004,				-- 广播玩家出牌(eventdata = {id = 1})
	sdBombNumUpdate				= 16005,				-- 广播倍数更新(eventdata = {num = 1})
	sdBaoJing					= 16006,				-- 广播玩家报警
	sdRoundAccount				= 16007,				-- 广播小结算信息
	sdExitRoundAccount			= 16008,				-- 广播退出小结算信息
	sdNewPlayer					= 16009,				-- 广播新玩家加入
	sdRoundUpdate				= 16010,				-- 广播局数更新
	sdIsTipping					= 16011,				-- 广播是否引爆
	------------------------------  三代 E ------------------------------------
}

cc.exports.EventEnum = EventEnum