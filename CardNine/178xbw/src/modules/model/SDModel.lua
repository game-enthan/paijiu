local SDModel = class("SDModel", BaseModel)
local maxPlayerNum = PlayerNumCnf[PlayType.TT_SX_SD]

function SDModel:init()
	self:reset()
	-- 是否回放
	self._isPlayBack = false
end

function SDModel:reset()
	-- 如果回放状态下就不重置数据层
	if self._isPlayBack then return end
	-- 玩家ID
	self._id = nil
	-- 房号
	self._roomId = 0
	-- 房主
	self._roomOwnId = 0
	-- 局数
	self._round = 0
	-- 最大局数
	self._maxRound = 0
	-- 显示牌数
	self._isCardNum = false
	-- 炸弹分(1 = 2分，2 = 5分，3 = 10分)
	self._scoreType = 1
	-- 三带单压三带对(1 = 能压，2 = 不能压)
	self._threeTake = 1
	-- 硬吃硬
	self._forceCard = false
	-- 带飞机
	self._aircraft = false
	-- 33必压22
	self._force1 = false
	-- 333必压222
	self._force2 = false
	-- 大炸弹必压小炸弹
	self._force3 = false
	-- 33必见炸弹
	self._force4 = false
	-- 333必见炸弹
	self._force5 = false
	-- 我的座位号
	self._mySerSeatId = 0
	-- 牌局阶段
	self._period = SD_PERIOD_WAIT
	-- 玩家列表
	self._playerList = {}
	-- 当前操作玩家
	self._actionPlayerId = 0
	-- 底分
	self._baseScore = 0
	-- 炸弹数
	self._bombNum = 0
	-- 上家ID
	self._prePlayPlayerId = 0
	-- 上家出牌
	self._prePlayedPokers = {}
	-- 缓存结算数据
	self._finalAccountData = nil
	-- 是否引爆
	self._isTipping = false
end

function SDModel:initRoomInfo(netData)
	self._roomId = netData.room_id
	self._roomOwnerId = netData.room_owner_id
	self._round = netData.round
	self._maxRound = netData.max_round
	self._isCardNum = netData.is_card_num
	self._scoreType = netData.score_type
	self._threeTake = netData.three_take
	self._forceCard = netData.force_card
	self._aircraft = netData.has_aircraft
	self._force1 = netData.pan_force1
	self._force2 = netData.pan_force2
	self._force3 = netData.pan_force3
	self._force4 = netData.pan_force4
	self._force5 = netData.pan_force5
	self._mySerSeatId = netData.my_seat_id
	self._period = netData.period
	self._actionPlayerId = netData.action_player_id
	self._baseScore = netData.base_score
	self._bombNum = netData.multiple
	self._prePlayPlayerId = netData.discard_player_id
	self._isTipping = netData.is_tipping
	self._prePlayedPokers = CommonFunc.deepCopy(netData.discard_poker_list)
	for __, netPlayer in ipairs(netData.player_list) do
		self:insertPlayer(netPlayer)
	end
	-- 对上家打出去的牌排序
	SDController.sortPokers(self._prePlayedPokers)
end

function SDModel:insertPlayer(netPlayer)
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
		pokerList = CommonFunc.deepCopy(netPlayer.poker_list),
		-- 性别
		sex = netPlayer.sex,
		-- ip地址
		ip = netPlayer.ip,
		-- 定位信息
		gps = netPlayer.gps,
		-- 剩余牌的数量
		remainNum = netPlayer.remain_num,
	}
	SDController.sortPokers(player.pokerList)
	self._playerList[netPlayer.id] = player
	return player
end

-- 移除玩家
function SDModel:removePlayer(id)
	self._playerList[id] = nil
end

-- 重置玩家相关数据
function SDModel:resetPlayerData(id)
	local player = self._playerList[id]
	player.state = SD_PLAYER_PLAYING
	player.pokerList = {}
	player.remainNum = 17
end

-- 重置所有玩家数据
function SDModel:resetAllPlayerData()
	for __, player in pairs(self._playerList) do
		player.state = SD_PLAYER_PLAYING
		player.pokerList = {}
		player.remainNum = 17
	end
end

-- 更新局数
function SDModel:updateRound(round)
	self._round = round
end

-- 更新底分
function SDModel:updateBaseScore(baseScore)
	self._baseScore = baseScore
end

-- 更新玩家在线状态
function SDModel:updatePlayerOnline(id, isOnline)
	self._playerList[id].isOnline = isOnline
end

-- 更新玩家扑克牌列表
function SDModel:updateMyPokerList(pokerList)
	local id = self:getPlayerId()
	self._playerList[id].pokerList = CommonFunc.deepCopy(pokerList)
	SDController.sortPokers(self._playerList[id].pokerList)
end

-- 更新牌局状态
function SDModel:updateRoundPeriod(period)
	if SD_PERIOD_WAIT == period then
	elseif SD_PERIOD_START == period then
		self:resetAllPlayerData()
		self:updateBaseScore(1)
		self:resetPrePlayedInfo()
		self:updateBombNum(0)
	elseif SD_PERIOD_PLAY == period then
	elseif SD_PERIOD_ACCOUNT == period then
	end
	self._period = period
end

-- 更新当前行动玩家
function SDModel:updateActionPlayer(id)
	self._actionPlayerId = id
end

--
function SDModel:resetPrePlayedInfo()
	self._prePlayPlayerId = 0
	self._prePlayedPokers = {}
end

-- 更新上家所出的牌
function SDModel:updatePrePlayPokers(id, pokerList)
	if #pokerList > 0 then
		self._prePlayedPokers = CommonFunc.deepCopy(pokerList)
		self._prePlayPlayerId = id
		SDController.sortPokers(self._prePlayedPokers)
		if self:getPlayerId() == id then
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
			SDController.sortPokers(player.pokerList)
		end
	end
end

-- 更新玩家剩余牌数
function SDModel:updatePlayerRemainCardNum(id, num)
	self._playerList[id].remainNum = num
end

-- 更新玩家分数
function SDModel:updatePlayerScore(id, score)
	self._playerList[id].score = score
end

-- 更新倍数
function SDModel:updateBombNum(bombNum)
	self._bombNum = bombNum
end

-- 缓存大结算数据
function SDModel:updateFinalAccountData(finalAccountData)
	self._finalAccountData = finalAccountData
end

-- 设置回放标志
function SDModel:updatePlayBackState(isPlayBack)
	self._isPlayBack = isPlayBack
end

function SDModel:updateIsTipping(isTipping)
	self._isTipping = isTipping
end

-- 计算客户端座位号
function SDModel:calCliSeatId(serSeatId)
	local dis = serSeatId - self._mySerSeatId
	local cliSeatId = (1 + dis) % maxPlayerNum
	cliSeatId = (cliSeatId == 0) and maxPlayerNum or cliSeatId
	return cliSeatId
end
-------------------------- 网络数据更新接口 E ---------------------------
----------------------------- 数据层接口 S ------------------------------
-- 获取玩家ID
function SDModel:getPlayerId()
	self._id = self._id or AccountController.getPlayerId()
	return self._id
end

-- 获取房间号
function SDModel:getRoomId()
	return self._roomId
end

-- 获取房主ID
function SDModel:getRoomOwnerId()
	return self._roomOwnId
end

-- 获取局数
function SDModel:getRound()
	return self._round, self._maxRound
end

-- 获取房间阶段
function SDModel:getRoundPeriod()
	return self._period
end

-- 获取底分
function SDModel:getBaseScore()
	return self._baseScore
end

function SDModel:getIsPlayBack()
	return self._isPlayBack
end

-- 获取当前可以操作的玩家
function SDModel:getActionPlayerId()
	return self._actionPlayerId
end

-- 获取当前是否被引爆
function SDModel:getIsTipping()
	return self._isTipping
end

function SDModel:getPlayers()
	local players = {}
	for __, player in pairs(self._playerList) do
		players[player.cliSeatId] = player
	end
	return players
end

-- 获取玩家
function SDModel:getPlayerById(id)
	return self._playerList[id]
end

-- 获取玩家上家打出去的牌
function SDModel:getPrePlayedPokers()
	return self._prePlayedPokers
end

-- 获取上次打牌的玩家
function SDModel:getPrePlayPlayerId()
	return self._prePlayPlayerId
end

-- 获取玩家手牌数量
function SDModel:getRemainPokerNum(id)
	return self._playerList[id].remainNum
end

-- 获取倍数
function SDModel:getBombNum()
	return self._bombNum
end

function SDModel:getIsCardNum()
	return self._isCardNum
end

function SDModel:getScoreType()
	return self._scoreType
end

function SDModel:getThreeTake()
	return self._threeTake
end

function SDModel:getAircraft()
	return self._aircraft
end

function SDModel:getForceCard()
	return self._forceCard
end

function SDModel:getForceCnf()
	local cnf = {}
	cnf.force1 = self._force1
	cnf.force2 = self._force2
	cnf.force3 = self._force3
	cnf.force4 = self._force4
	cnf.force5 = self._force5
	return cnf
end

function SDModel:getCnf()
	local cnf = {}
	cnf.isCardNum = self._isCardNum
	cnf.scoreType = self._scoreType
	cnf.threeTake = self._threeTake
	cnf.forceCard = self._forceCard
	cnf.hasAircraft = self._aircraft
	return cnf
end

-- 获取玩家的牌型
function SDModel:getPokerByIdAndIndex(id, index)
	local num, flower = WZ_POKER_ENUM.POKER_NIL, WZ_POKER_TYPE.TYPE_NIL
	local player = self._playerList[id]
	local poker = player.pokerList[index]
	if nil ~= poker then
		num = poker.num
		flower = poker.flower
	end
	return num, flower
end

-- 获取玩家手牌
function SDModel:getMyPokers()
	return self._playerList[self:getPlayerId()].pokerList
end

-- 获取客户端状态
function SDModel:getPlayerCliState(id)
	local cliState = CliPlayerState.STATE_NIL
	while true do
		local player = self._playerList[id]
		-- 回放禁用所有操作
		if self._isPlayBack then
			cliState = CliPlayerState.STATE_NIL
			break
		end
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

-- 玩家是否可以出牌
function SDModel:getIsCanPlayPoker()
	local boRet = true
	while true do
		-- 回放不能打牌
		if self._isPlayBack then
			boRet = false
			break
		end
		-- 不是行动玩家
		if self._actionPlayerId ~= self:getPlayerId() then
			boRet = false
			break
		end
		-- 不在打牌阶段
		if SD_PERIOD_PLAY ~= self._period then
			boRet = false
			break
		end
		break
	end
	return boRet
end

-- 获取玩法描述
function SDModel:getPlayTypeDes()
	local strTip = "玩法："
	if self._isCardNum then
		strTip = strTip.."显示剩余牌数，"
	end
	if 1 == self._scoreType then
		strTip = strTip.."2分，"
	elseif 2 == self._scoreType then
		strTip = strTip.."5分，"
	elseif 3 == self._scoreType then
		strTip = strTip.."10分，"
	end
	if 1 == self._threeTake then
		strTip = strTip.."三带单能压三带对，"
	elseif 2 == self._threeTake then
		strTip = strTip.."三带单不能压三带对，"
	end
	if self._aircraft then
		strTip = strTip.."带飞机，"
	end
	if self._forceCard then
		strTip = strTip.."硬吃硬，"
	end
	strTip = string.format("%s%d局", strTip, self._maxRound)
	return strTip
end

-- 获取下家手牌张数
function SDModel:getNextPlayerCardNum()
	local myId = self:getPlayerId()
	local players = self:getPlayers()
	local myCliSeatId = self._playerList[myId].cliSeatId
	local nextCliSeatId = (1 + myCliSeatId) % maxPlayerNum
	nextCliSeatId = (nextCliSeatId == 0) and maxPlayerNum or nextCliSeatId
	return players[nextCliSeatId].remainNum
end

-- 获取大结算数据
function SDModel:getFinalAccountData()
	return self._finalAccountData
end

return SDModel