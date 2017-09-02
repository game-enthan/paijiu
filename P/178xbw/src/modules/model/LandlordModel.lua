local LandlordModel = class("LandlordModel", BaseModel)
local maxPlayerNum = PlayerNumCnf[PlayType.TT_LANDLORD]

function LandlordModel:init()
	-- 是否回放
	self._isPlayBack = false
	self:reset()
end

function LandlordModel:reset()
	-- 房号
	self._roomId = 0
	-- 房主
	self._roomOwnId = 0
	-- 局数
	self._round = 0
	-- 最大局数
	self._maxRound = 0
	-- 倍数上限
	self._bombTop = LANDLORD_MULTIPLE_TYPE.TYPE_16
	-- 显示牌数
	self._showPokerNum = false
	-- 记牌器
	self._recordPoker = false
	-- 牌局人数（1 = 2人局数，2 = 3人局数）
	self._playerLimit = 1
	-- 叫地主(1 = 赢家先叫，2 = 轮流叫地主)
	self._callPaiChoose = 1
	-- 地主ID
	self._diZhuId = 0
	-- 我的座位号
	self._mySerSeatId = 0
	-- 牌局阶段
	self._period = GOLDFLOWER_PERIOD_WAIT
	-- 玩家列表
	self._playerList = {}
	-- 当前操作玩家
	self._actionPlayerId = 0
	-- 底分
	self._baseScore = 0
	-- 翻倍数
	self._multiple = 0
	-- 地主牌
	self._diZhuPokerList = {}
	-- 上家ID
	self._prePlayPlayerId = 0
	-- 上家出牌
	self._prePlayedPokers = {}
	-- 上一个叫地主的玩家
	self._preCallDiZhuId = 0
	-- 上一个叫地主的分数
	self._preCallDiZhuScore = 0
	-- 两人玩法农民被让多少牌
	self._farmerWinPokerNum = 0
	-- 缓存结算数据
	self._finalAccountData = nil
	-- 是否有让牌玩法
	self._letCard = false
end

-------------------------- 网络数据更新接口 S ---------------------------
-- 初始化房间数据
function LandlordModel:initRoomInfo(netData)
	self._roomId = netData.room_id
	self._roomOwnId = netData.room_owner_id
	self._round = netData.round
	self._maxRound = netData.max_round
	self._bombTop = netData.bomb_top
	self._showPokerNum = netData.show_poker_num
	self._recordPoker = netData.record_poker
	self._playerLimit = netData.player_num
	self._callPaiChoose = netData.call_dizhu
	self._diZhuId = netData.dizhu_id
	self._mySerSeatId = netData.my_seat_id
	self._period = netData.period
	self._actionPlayerId = netData.action_player_id
	self._baseScore = netData.base_score
	self._multiple = netData.multiple
	self._diZhuPokerList = CommonFunc.deepCopy(netData.dizhu_poker_list) or nil
	self._prePlayPlayerId = netData.discard_player_id
	self._prePlayedPokers = CommonFunc.deepCopy(netData.discard_poker_list) or {}
	self._preCallDiZhuId = netData.last_call_dizhu_id
	self._preCallDiZhuScore = netData.last_call_dizhu_score
	self._farmerWinPokerNum = netData.farmer_win_poker_num
	self._letCard = netData.is_win_poker_num
	for __, netPlayer in ipairs(netData.player_list) do
		self:insertPlayer(netPlayer)
	end
	LandlordController.sortPokers(self._prePlayedPokers)
end

-- 新增玩家
function LandlordModel:insertPlayer(netPlayer)
	local player = {
		-- 玩家id
		id = netPlayer.id,
		-- 玩家名
		name = netPlayer.name,
		-- 分数
		score = netPlayer.score,
		-- 服务端座位号
		serSeatId = netPlayer.seat_id,
		-- 客户端座位号
		cliSeatId = self:calCliSeatId(netPlayer.seat_id),
		-- 玩家头像
		icon = netPlayer.icon,
		-- 玩家状态（0 = 等待，1 = 游戏中）
		state = netPlayer.state,
		-- 在线
		isOnline = netPlayer.is_online,
		-- 扑克牌列表
		pokerList = CommonFunc.deepCopy(netPlayer.poker_list) or {},
		-- 性别(0 = 女, 1 = 男)
		sex = netPlayer.sex or 0,
		-- ip地址
		ip = netPlayer.ip,
		-- 定位信息
		gps = netPlayer.gps,
		-- 剩余牌的数量(0 = 剩余0张，999 = 大于0张，其他实际牌的数量)
		remainNum = netPlayer.remain_num,
		-- 报警标志
		isAlert = netPlayer.is_alert,
	}
	LandlordController.sortPokers(player.pokerList)
	self._playerList[netPlayer.id] = player
	return player
end

-- 移除玩家
function LandlordModel:removePlayer(id)
	self._playerList[id] = nil
end

-- 刷新玩家状态
function LandlordModel:updatePlayerState(id, state)
	local player = self._playerList[id]
	if player then
		player.state = state
	end
end

-- 重置玩家相关数据
function LandlordModel:resetPlayerData(id)
	local player = self._playerList[id]
	player.state = LANDLORD_PLAYER_PLAYING
	player.pokerList = {}
	player.remainNum = 0
	player.isAlert = false
end

-- 重置所有玩家数据
function LandlordModel:resetAllPlayerData()
	for __, player in pairs(self._playerList) do
		player.state = LANDLORD_PLAYER_PLAYING
		player.pokerList = {}
		player.remainNum = 0
		player.isAlert = false
	end
end

-- 更新牌局数
function LandlordModel:updateRound(round)
	self._round = round
end

-- 更新第一个叫地主的玩家ID
function LandlordModel:updatePreCallDiZhuInfo(id, score)
	self._preCallDiZhuId = id
	self._preCallDiZhuScore = score
end

-- 更新地主ID
function LandlordModel:updateDiZhuId(diZhuId)
	self._diZhuId = diZhuId
end

-- 更新底分
function LandlordModel:updateBaseScore(baseScore)
	self._baseScore = baseScore
end

-- 更新翻倍数
function LandlordModel:updateMultiple(multiple)
	self._multiple = multiple
end

-- 更新地主牌
function LandlordModel:updateDiZhuPokers(pokerList)
	self._diZhuPokerList = CommonFunc.deepCopy(pokerList or {})
	-- 将这三张牌插入到我的手牌列表中
	if self._diZhuId == AccountController.getPlayerId() then
		local player = self._playerList[self._diZhuId]
		for __, poker in ipairs(pokerList) do
			player.pokerList[#player.pokerList + 1] = CommonFunc.deepCopy(poker)
		end
		LandlordController.sortPokers(player.pokerList)
		player.remainNum = player.remainNum + 3
	else
		if #self._diZhuPokerList > 0 and self._diZhuId ~= 0 then
			self._playerList[self._diZhuId].remainNum = self._playerList[self._diZhuId].remainNum + 3
		end
	end
end

-- 更新牌局状态
function LandlordModel:updateRoundPeriod(period)
	if LANDLORD_PERIOD_WAIT == period then
	elseif LANDLORD_PERIOD_START == period then
		self:updateDiZhuId(0)
		self:resetAllPlayerData()
		self:updatePreCallDiZhuInfo(0, 0)
		self:updateBaseScore(1)
		self:updateMultiple(1)
		self:updateDiZhuPokers({})
		self:resetPrePlayPokers()
	elseif LANDLORD_PERIOD_CALL == period then
	elseif LANDLORD_PERIOD_PLAY == period then
	elseif LANDLORD_PERIOD_ACCOUNT == period then
	end
	self._period = period
end

-- 更新玩家在线状态
function LandlordModel:updatePlayerOnline(id, isOnline)
	self._playerList[id].isOnline = isOnline
end

-- 更新玩家扑克牌列表
function LandlordModel:updatePokerList(pokerList)
	local playerId = AccountController.getPlayerId()
	--dump(self._playerList)
	self._playerList[playerId].pokerList = CommonFunc.deepCopy(pokerList)
	for __, player in pairs(self._playerList) do
		player.remainNum = 17
	end
	LandlordController.sortPokers(self._playerList[playerId].pokerList)
end

-- 更新当前行动玩家
function LandlordModel:updateActionPlayer(id)
	if id == self._prePlayPlayerId then
		self._prePlayPlayerId = 0
		self._prePlayedPokers = {}
	end
	self._actionPlayerId = id
end

-- 更新上家所出的牌
function LandlordModel:updatePrePlayPokers(id, pokerList)
	if #pokerList >= 1 then
		self._prePlayedPokers = CommonFunc.deepCopy(pokerList)
		self._prePlayPlayerId = id
		LandlordController.sortPokers(self._prePlayedPokers)
		if AccountController.getPlayerId() == id then
			local player = self._playerList[id]
			local num = #player.pokerList
			for index = num, 1, -1 do
				local handPoker = player.pokerList[index]
				for ind, outPoker in ipairs(pokerList) do
					if handPoker.num == outPoker.num and handPoker.flower == outPoker.flower then
						table.remove(player.pokerList, index)
						table.remove(pokerList, ind)
						break
					end
				end
			end
			LandlordController.sortPokers(player.pokerList)
		end
	end
end

-- 重置上次出牌玩家
function LandlordModel:resetPrePlayPokers()
	self._prePlayPlayerId = 0
	self._prePlayedPokers = {}
end

-- 更新玩家剩余牌数
function LandlordModel:updatePlayerRemainCardNum(id, num)
	self._playerList[id].remainNum = num
end

-- 更新玩家报警状态
function LandlordModel:updatePlayerAlertState(id, isAlert)
	self._playerList[id].isAlert = isAlert
end

-- 更新玩家分数
function LandlordModel:updatePlayerScore(id, score)
	self._playerList[id].score = score
end

-- 更新两人玩法时农民被让几张牌
function LandlordModel:updateFarmerWinPokerNum(num)
	self._farmerWinPokerNum = num
end

-- 缓存大结算数据
function LandlordModel:updateFinalAccountData(finalAccountData)
	self._finalAccountData = finalAccountData
end

-- 设置回放标志
function LandlordModel:updatePlayBackState(isPlayBack)
	self._isPlayBack = isPlayBack
end

-- 计算客户端座位号
function LandlordModel:calCliSeatId(serSeatId)
	local dis = serSeatId - self._mySerSeatId
	local cliSeatId = (1 + dis) % maxPlayerNum
	cliSeatId = (cliSeatId == 0) and maxPlayerNum or cliSeatId
	return cliSeatId
end
-------------------------- 网络数据更新接口 E ---------------------------
----------------------------- 数据层接口 S ------------------------------
-- 获取房间号
function LandlordModel:getRoomId()
	return self._roomId
end

-- 获取房主ID
function LandlordModel:getRoomOwnerId()
	return self._roomOwnId
end

-- 获取牌局阶段
function LandlordModel:getRoundPeriod()
	return self._period
end

-- 获取局数
function LandlordModel:getRound()
	return self._round, self._maxRound
end

-- 获取让牌张数
function LandlordModel:getFarmerWinPokerNum()
	return self._farmerWinPokerNum
end

-- 获取底分
function LandlordModel:getBaseScore()
	return self._baseScore
end

-- 获取倍数
function LandlordModel:getMultiple()
	return self._multiple
end

-- 返回第一个叫地主的ID
function LandlordModel:getPreCallDiZhuInfo()
	return self._preCallDiZhuId, self._preCallDiZhuScore
end

-- 获取地主
function LandlordModel:getDiZhuId()
	return self._diZhuId
end

-- 获取玩法描述
function LandlordModel:getPlayTypeDes()
	local strTip = "玩法："
	if 1 == self._playerLimit then
		strTip = strTip.."两人玩法，"
	elseif 2 == self._playerLimit then
		strTip = strTip.."三人玩法，"
	end
	strTip = string.format("%s%s%s", strTip, LANDLORD_MULTIPLE_TYPE_STR[self._bombTop], "，")
	if self._showPokerNum then
		strTip = strTip.."显示牌数，"
	else
		strTip = strTip.."不显示牌数，"
	end
	if 1 == self._callPaiChoose then
		strTip = strTip.."赢家先叫，"
	elseif 2 == self._callPaiChoose then
		strTip = strTip.."轮流叫地主，"
	end
	if 1 == self._playerLimit then
		if self._letCard then
			strTip = strTip.."让牌，"
		else
			strTip = strTip.."不让牌，"
		end
	end
	strTip = strTip..string.format("%d局", self._maxRound)
	return strTip
end

-- 获取玩法配置
function LandlordModel:getCnf()
	local cnf = {}
	cnf.bombTop = self._bombTop
	cnf.showPokerNum = self._showPokerNum
	cnf.playerLimit = self._playerLimit
	cnf.callPaiChoose = self._callPaiChoose
	cnf.maxRound = self._maxRound
	return cnf
end

-- 获取牌局人数
function LandlordModel:getPlayerLimit()
	return self._playerLimit
end

-- 获取是否让牌
function LandlordModel:getLetCard()
	return self._letCard
end

-- 是否显示牌数
function LandlordModel:getIsShowPokerNum()
	return self._showPokerNum
end

-- 获取玩家的牌型
function LandlordModel:getPokerByIdAndIndex(id, index)
	local pokerKind, pokerType = POKER_ENUM.POKER_NIL, POKER_TYPE.TYPE_NIL
	local player = self._playerList[id]
	local poker = player.pokerList[index]
	if nil ~= poker then
		pokerKind = poker.num
		pokerType = poker.flower
	end
	return pokerKind, pokerType
end

-- 获取玩家手牌
function LandlordModel:getMyPokers()
	local id = AccountController.getPlayerId()
	return self._playerList[id].pokerList
end

-- 获取当前可以操作的玩家
function LandlordModel:getActionPlayerId()
	return self._actionPlayerId
end

-- 获取地主牌
function LandlordModel:getLandlordPokers()
	return self._diZhuPokerList
end

-- 获取打出牌
function LandlordModel:getPrePlayedPokers()
	return self._prePlayedPokers
end

function LandlordModel:getPrePlayPlayerId()
	return self._prePlayPlayerId
end

-- 获取玩家手牌数量
function LandlordModel:getRemainPokerNum(id)
	return self._playerList[id].remainNum
end

-- 获取玩家客户端状态
function LandlordModel:getPlayerCliState(id)
	local cliState = CliPlayerState.STATE_NIL
	while true do
		-- 回放禁用所有操作
		if self._isPlayBack then
			cliState = CliPlayerState.STATE_NIL
			break
		end
		local player = self._playerList[id]
		-- 离线
		if not player.isOnline then
			cliState = CliPlayerState.STATE_OFFLINE
			break
		end
		-- 准备
		if player.state == LANDLORD_PLAYER_PREPARE then
			cliState = CliPlayerState.STATE_READY
			break
		end
		break
	end
	return cliState
end

-- 玩家是否可以抢地主
function LandlordModel:getIsCanQiang()
	local boRet = true
	while true do
		-- 回放不能抢地主
		if self._isPlayBack then
			boRet = false
			break
		end
		-- 不在抢地主阶段
		if LANDLORD_PERIOD_CALL ~= self._period then
			boRet = false
			break
		end
		-- 当前不是行动的玩家
		if self._actionPlayerId ~= AccountController.getPlayerId() then
			boRet = false
			break
		end
		break
	end
	return boRet
end

-- 玩家是否可以出牌
function LandlordModel:getIsCanPlayPoker()
	local boRet = true
	while true do
		-- 回放不能打牌
		if self._isPlayBack then
			boRet = false
			break
		end
		-- 不在打牌阶段
		if LANDLORD_PERIOD_PLAY ~= self._period then
			boRet = false
			break
		end
		-- 当前不是行动的玩家
		if self._actionPlayerId ~= AccountController.getPlayerId() then
			boRet = false
			break
		end
		break
	end
	return boRet
end

-- 是否是地主
function LandlordModel:getIsDiZhu(id)
	local boRet = false
	if id == self._diZhuId then
		boRet = true
	end
	return boRet
end

-- 获取所有玩家
function LandlordModel:getPlayers()
	local players = {}
	for __, player in pairs(self._playerList) do
		players[player.cliSeatId] = player
	end
	return players
end

-- 获取玩家
function LandlordModel:getPlayerById(id)
	return self._playerList[id]
end

-- 是否在回放
function LandlordModel:getIsPlayBack()
	return self._isPlayBack
end

-- 获取大结算数据
function LandlordModel:getFinalAccountData()
	return self._finalAccountData
end
----------------------------- 数据层接口 E ------------------------------

return LandlordModel