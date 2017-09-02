local PlaybackBaseUI = require("lib/PlaybackBaseUI")
local SDUI = class("SDUI", PlaybackBaseUI)

local Poker = require("modules/view/common/WKPoker")
local IpInfoNode = require("modules/view/common/IpInfoNode")
local PokerSize = WZ_POKERSIZE
local maxPaiDuiNum = 51
local paiDuiIniPos = cc.p(0, GL_SIZE.height - 220)
local iniPokerDis = 5
local iniPokerScale = 0.5
local myPokerScale = 1
local myDis = 55
local otherPokerScale = 0.4
local otherDis = 10
local myRiverDis = 40
local otherRiverDis = 35
local myRiverScale = 0.75
local otherRiverScale = 0.55

SDUI._widgetsCnf = {
	{"imgBg"},{"imgCannotPlay", visible = false},
	{"seat", len = 3, visible = false},
	{"btnHelp", click = "onHelpClickHandler"},
	{"panPokerLayer"},
	{"imgClock", visible = false, children = {{"textAtlasTime"}}},
	{"btnDisband", click = "onDisbandClickHandler"},
	{"btnChat", click = "onChatClickHandler"},
	{"btnSet", click = "onSetClickHandler"},
	{"btnShare", click = "onShareClickHandler"},
	{"btnVoice"},
	{"panRoomInfo", children = {
		{"labRoomId"},{"labTime"},
		{"labBaseScore"},{"labRound"},{"labBombNum"}
	}},
	{"panOprPai", children = {
		{"btnBuChu", click = "onBuChuClickHandler"},
		{"btnTiShi", click = "onTiShiClickHandler"},
		{"btnOut", click = "onOutClickHandler"},
	}},
}

function SDUI:ctor()
	PlaybackBaseUI.ctor(self, "res/SDUI")
	self:init()
end

function SDUI:init()
	self:listenEvents()
	self:initData()
	self:initView()
end

function SDUI:listenEvents()
	self:listenEvent(EventEnum.sdPlayerOnline, "onPlayerOnlineHandler")
	self:listenEvent(EventEnum.sdPeriod, "onPeriodChangeHandler")
	self:listenEvent(EventEnum.sdPlayCard, "onPlayCardHandler")
	self:listenEvent(EventEnum.sdBombNumUpdate, "onBombNumUpdateHandler")
	self:listenEvent(EventEnum.sdBaoJing, "onBaoJingHandler")
	self:listenEvent(EventEnum.sdRoundAccount, "onRoundAccountHandler")
	self:listenEvent(EventEnum.sdExitRoundAccount, "onExitRoundAccountHandler")
	self:listenEvent(EventEnum.sdNewPlayer, "onNewPlayerHandler")
	self:listenEvent(EventEnum.sdRoundUpdate, "onRoundUpdateHandler")
	self:listenEvent(EventEnum.sdActionPlayer, "onActionPlayerChangeHandler")
	self:listenEvent(EventEnum.sdIsTipping, "onIsTippingChangeHandler")
	self:listenEvent(EventEnum.exitRoom, "onPlayerExitRoom")
	self:listenEvent(EventEnum.chatMsg, "onChatMsgHandler")
	self:listenEvent(EventEnum.voiceFinishPlay, "onVoiceFinishPlayHandler")
end

function SDUI:initData()
	self._controller = SDController
	self._model = self._controller:getModel()
	self._isPlayBack = self._model:getIsPlayBack()
	self._maxPlayerNum = PlayerNumCnf[PlayType.TT_SX_SD]
	self._id = self._model:getPlayerId()
	self._countDown = nil
	self._frameListeners = {}
	self._paiDui = {}
	self._playerViewByCliSeatId = {}
	self._playerViewById = {}
	self._period = nil
	self._waitAccountEffect = false
	paiDuiIniPos.x = (GL_SIZE.width - iniPokerDis * (maxPaiDuiNum - 1)) / 2
end

function SDUI:initView()
	self:initTouchLayer()
	self:initAllSeats()
	self.btnVoice:addTouchEventListener(handler(self, self.onBtnVoiceEventHandler))
	self.btnChat:setVisible(not self._isPlayBack)
end

function SDUI:initTouchLayer()
	if nil == self._touchLayer then
		local layer = cc.Layer:create()
		self.panPokerLayer:addChild(layer)
		layer:setTouchEnabled(not self._isPlayBack)
		layer:registerScriptTouchHandler(handler(self, self.onTouchEvent))
		self._touchLayer = layer
	end
	self._touchLayer:setVisible(false)
end

function SDUI:initAllSeats()
	local players = self._model:getPlayers()
	for cliSeatId = 1, self._maxPlayerNum do
		local player = players[cliSeatId]
		local seat = self["seat"..cliSeatId]
		seat._cliSeatId = cliSeatId
		seat._player = nil
		seat._pokers = nil
		seat._riverPokers = nil
		seat._id = nil
		seat._pos = cc.p(seat:getPosition())
		seat._size = seat:getContentSize()
		if nil == player then
			seat:setVisible(false)
		else
			seat:setVisible(true)
			self:refreshSeatInfo(seat, player)
		end
		local imgIconBg = seat:getChildByName("imgIconBg")
		CommonFunc.bindClickFunc(imgIconBg, function()
				self:onIconClickHandler(cliSeatId)
			end)
	end
end

function SDUI:onEnter()
	PlaybackBaseUI.onEnter(self)
	self:startSchedule()
	self:startTimer(handler(self, self.second), 1)
	self:openTanMuUI()
	self:refreshView()
	AudioEngine:playEffect("res/audio/com_ready.mp3")
end

function SDUI:onExit()
	PlaybackBaseUI.onExit(self)
end

-- 每帧调用
function SDUI:update(dt)
	if #self._frameListeners > 0 then
		for ind = #self._frameListeners, 1, -1 do
			local listener = self._frameListeners[ind]
			if listener.cnt <= 0 then
				table.remove(self._frameListeners, ind)
			else
				listener.callback()
				listener.cnt = listener.cnt - 1
				if listener.cnt <= 0 then
					table.remove(self._frameListeners, ind)
				end
			end
		end
	end
end

-- 每秒调用
function SDUI:second(dt)
	self:refreshTime()
	self:refreshCountDown()
end

function SDUI:insertFrameListener(callback, cnt, boStartNow)
	if boStartNow then
		callback()
		cnt = cnt - 1
	end
	self._frameListeners[#self._frameListeners + 1] = {callback = callback, cnt = cnt}
end

function SDUI:openTanMuUI()
	if self._isPlayBack then return end
	self._tanMuUI = require("modules/view/common/TanMuUI").new(PlayType.TT_SX_SD)
	self:addChild(self._tanMuUI)
	self._tanMuUI:setGlobalZOrder(50)
end

function SDUI:refreshView()
	self:refreshRoomId()
	self:refreshRound()
	self:refreshBottomScore()
	self:refreshBombNum()
	self:refreshPlayType()
	self:clearCards()
	self:initPeriod()
	self:refreshAllPlayerState()
end

--------------------------- 牌局状态 S --------------------------------
-- 初始化牌局阶段
function SDUI:initPeriod()
	local period = self._model:getRoundPeriod()
	if self._period == period then return end
	self:hideAllOpr()
	local funcName = SD_PERIOD_INI_FUNC[period]
	assert(funcName, "ileagel period----------->>"..period)
	self[funcName](self)
	self._period = period
	self:refreshRemainCardNum()
end

-- 切换牌局阶段
function SDUI:switchPeriod(period)
	if self._period and self._period == period then return end
	local funcName = SD_PERIOD_SWITCH_FUNC[period]
	assert(funcName, "ileagel period----------->>"..period)
	self[funcName](self)
	self._period = period
	self:refreshRemainCardNum()
end

-- 初始化等待阶段
function SDUI:initWaitPeriod()
	self.panPokerLayer:setVisible(false)
	self.btnShare:setVisible(true)
end

-- 跳转到等待阶段
function SDUI:switchWaitPeriod()
end

-- 初始化开始阶段
function SDUI:initStartPeriod()
end

-- 跳转到开始阶段
function SDUI:switchStartPeriod()
	self:hideAllOpr()
	self:clearCards()
	self.panPokerLayer:setVisible(false)
	self._touchLayer:setVisible(false)
	self:refreshAllPlayerState()
end

-- 初始化打牌阶段
function SDUI:initPlayPeriod()
	self:hideAllOpr()
	self:dispatchPokerWithOutEffect()
	self._touchLayer:setVisible(true and not self._isPlayBack)
	self:initRiverCards()
	self:startCountDown(10)
	self:refreshActionPlayer()
end

-- 跳转到打牌阶段
function SDUI:switchPlayPeriod()
	self:hideAllOpr()
	local function callback()
		self:refreshActionPlayer()
	end
	self:startCountDown(10)
	self:dispatchPokerWithEffect(callback)
	self._touchLayer:setVisible(true and not self._isPlayBack)
	self:clearChoosePokers()
end

-- 初始化结算阶段
function SDUI:initAccountPeriod()
	self:hideAllOpr()
	self._touchLayer:setVisible(false)
	self:stopCountDown()
end

-- 跳转到结算阶段
function SDUI:switchAccountPeriod()
	self:hideAllOpr()
	self._touchLayer:setVisible(false)
	self:stopCountDown()
end

-- 隐藏所有操作
function SDUI:hideAllOpr()
	self.imgClock:setVisible(false)
	self.btnShare:setVisible(false)
	self.panOprPai:setVisible(false)
end
--------------------------- 牌局状态 E --------------------------------
-- 刷新座位信息
function SDUI:refreshSeatInfo(seat, player)
	if nil ~= player then
		local imgIconBg = seat:getChildByName("imgIconBg")
		local imgIcon = seat:getChildByName("imgIconBg"):getChildByName("imgIcon")
		local panName = seat:getChildByName("panName")
		local labName = panName:getChildByName("labName")
		local labScore = seat:getChildByName("labScore")
		CommonFunc.setIcon(imgIcon, player.icon)
		labName:setString(player.name)
		labScore:setString(string.format("积分：%d", player.score))
		local sizeOfPan = panName:getContentSize()
		local sizeOfName = labName:getContentSize()
		if sizeOfName.width <= sizeOfPan.width then
			labName:setAnchorPoint(cc.p(0.5, 0.5))
			labName:setPosition(cc.p(sizeOfPan.width / 2, sizeOfPan.height / 2))
		else
			labName:stopAllActions()
			labName:setAnchorPoint(cc.p(0, 0.5))
			local sPos = cc.p(0, sizeOfPan.height / 2)
			local dPos = cc.p(sizeOfPan.width - sizeOfName.width, sizeOfPan.height / 2)
			local moveTo1 = cc.MoveTo:create(0.5, sPos)
			local moveTo2 = cc.MoveTo:create(0.5, dPos)
			local delay1 = cc.DelayTime:create(2.0)
			local delay2 = cc.DelayTime:create(2.0)
			local seq = cc.Sequence:create(moveTo1, delay1, moveTo2, delay2)
			local repeatFor = cc.RepeatForever:create(seq)
			labName:runAction(repeatFor)
		end
		seat._id = player.id
		seat._player = player
		seat._pokers = {}
		seat._riverPokers = {}
		self._playerViewByCliSeatId[player.cliSeatId] = seat
		self._playerViewById[player.id] = seat
		self:refreshPlayerState(player.id)
	else
		seat:setVisible(false)
		self._playerViewByCliSeatId[seat._cliSeatId] = nil
		self._playerViewById[seat._id] = nil
		seat._id = nil
		seat._player = nil
		seat._pokers = nil
		seat._riverPokers = nil
	end
end

-- 更新所有玩家信息
function SDUI:resetAllPlayerScore()
	for __, playerView in pairs(self._playerViewById) do
		local labScore = playerView:getChildByName("labScore")
		labScore:setString(string.format("积分：%d", playerView._player.score))
	end
end

-- 刷新所有玩家状态
function SDUI:refreshAllPlayerState()
	for __, playerView in pairs(self._playerViewById) do
		self:refreshPlayerState(playerView._id)
	end
end

-- 刷新单个玩家状态
function SDUI:refreshPlayerState(id)
	local playerView = self._playerViewById[id]
	local cliState = self._model:getPlayerCliState(id)
	if playerView then
		local imgIconBg = playerView:getChildByName("imgIconBg")
		if cliState == CliPlayerState.STATE_NIL then
			if imgIconBg._stateEffect then
				imgIconBg._stateEffect:setVisible(false)
				imgIconBg._stateEffect:stopAllActions()
			end
		else
			local url = CliPlayerStateUrl[cliState]
			local sizeOfNode = imgIconBg:getContentSize()
			if nil == imgIconBg._stateEffect then
				imgIconBg._stateEffect = cc.Sprite:create()
				imgIconBg._stateEffect:setAnchorPoint(cc.p(0.5, 0.5))
				imgIconBg:addChild(imgIconBg._stateEffect)
				imgIconBg._stateEffect:setPosition(cc.p(sizeOfNode.width / 2, sizeOfNode.height / 2))
			end
			imgIconBg._stateEffect:setVisible(true)
			imgIconBg._stateEffect:stopAllActions()
			imgIconBg._stateEffect:setTexture(url)
			imgIconBg._stateEffect:setOpacity(255)
		end
	end
end

-- 清空玩家手牌和地主牌和河里的牌
function SDUI:clearCards()
	for __, playerView in pairs(self._playerViewById) do
		playerView._pokers = {}
		self:clearRiverCardsById(playerView._cliSeatId)
		if playerView._sprBuChu then
			playerView._sprBuChu:setVisible(false)
		end
	end
end

-- 清空玩家河里的牌
function SDUI:clearRiverCardsById(cliSeatId)
	local playerView = self._playerViewByCliSeatId[cliSeatId]
	if playerView._riverPokers and #playerView._riverPokers > 0 then
		for ind = #playerView._riverPokers, 1, -1 do
			playerView._riverPokers[ind]:setVisible(false)
			table.remove(playerView._riverPokers, ind)
		end
	end
end
------------------------------ 发牌 S ----------------------------
-- 播放发牌效果
function SDUI:dispatchPokerWithEffect(callback)
	self._isDispatchingPoker = true
	self.panPokerLayer:setVisible(true)
	local needRemoveNum = math.max(0, #self._paiDui - maxPaiDuiNum)
	for ind = #self._paiDui, 1, -1 do
		local poker = self._paiDui[ind]
		if ind <= needRemoveNum then
			poker:removeFromParent()
			table.remove(self._paiDui, ind)
		else
			poker:setVisible(false)
			poker:initPoker(WZ_POKER_ENUM.POKER_NIL, WZ_POKER_TYPE.TYPE_NIL, WZ_POKER_STATE.NEGATIVE)
		end
	end
	local pokerIndex = 1
	local function createPokerByFrame()
		for ind = 1, 4 do
			local cnt = pokerIndex
			if cnt <= maxPaiDuiNum then
				local poker = self._paiDui[cnt]
				if nil == poker then
					poker = Poker.new()
					self.panPokerLayer:addChild(poker)
					self._paiDui[cnt] = poker
					poker:setAnchorPoint(cc.p(0.5, 0.5))
				end
				local pos = cc.p(paiDuiIniPos.x + (cnt - 1) * 5, paiDuiIniPos.y)
				poker:setOpacity(255)
				poker:setPosition(pos)
				poker:setScale(iniPokerScale)
				poker:setVisible(true)
				poker:setLocalZOrder(cnt)
				if cnt == maxPaiDuiNum then
					self:startDispatchPoker(callback)
				end
			end
			pokerIndex = pokerIndex + 1
		end
	end
	self:insertFrameListener(createPokerByFrame, maxPaiDuiNum / 4, true)
end

-- 发牌不带特效
function SDUI:dispatchPokerWithOutEffect()
	self.panPokerLayer:setVisible(true)
	for __, poker in ipairs(self._paiDui) do
		poker:stopCurAction()
		poker:setVisible(false)
		poker:initPoker(WZ_POKER_ENUM.POKER_NIL, WZ_POKER_TYPE.TYPE_NIL, WZ_POKER_STATE.NEGATIVE)
	end
	local inPlayingPlayerList = self:getInPlayingPlayers()
	local playerNum = #inPlayingPlayerList
	-- 初始化我自己的手牌
	local myPokerNum = self._model:getRemainPokerNum(self._id)
	local myPlayerView = self._playerViewById[self._id]
	local iniPos = self:calFirstPokerPos(1, myPokerNum)
	local cnt = 1
	for index = 1, myPokerNum do
		local poker = self._paiDui[cnt]
		if nil == poker then
			poker = Poker.new()
			self.panPokerLayer:addChild(poker)
			self._paiDui[#self._paiDui + 1] = poker
		end
		local pokerKind, pokerType = self._model:getPokerByIdAndIndex(self._id, index)
		local desPos = cc.p(iniPos.x, iniPos.y)
		desPos.x = desPos.x + myDis * (index - 1)
		poker:setOpacity(255)
		poker:setPosition(desPos)
		poker:setLocalZOrder(index)
		poker:setScale(myPokerScale)
		poker:initPoker(pokerKind, pokerType, WZ_POKER_STATE.POSITIVE)
		poker:setVisible(true)
		myPlayerView._pokers[#myPlayerView._pokers + 1] = poker
		cnt = cnt + 1
	end
	-- 初始化其他玩家的手牌
	for __, playerView in ipairs(inPlayingPlayerList) do
		if playerView._id ~= self._id then
			local pokerNum = self._model:getRemainPokerNum(playerView._id)
			local iniPos = self:calFirstPokerPos(playerView._cliSeatId, 0)
			for index = 1, pokerNum do
				local poker = self._paiDui[cnt]
				if nil == poker then
					poker = Poker.new()
					self.panPokerLayer:addChild(poker)
					self._paiDui[#self._paiDui + 1] = poker
				end
				local desPos = cc.p(iniPos.x, iniPos.y)
				desPos.y = desPos.y - otherDis * (index - 1)
				poker:setOpacity(255)
				poker:setPosition(desPos)
				poker:setLocalZOrder(index)
				poker:setScale(otherPokerScale)
				poker:setVisible(true)
				playerView._pokers[#playerView._pokers + 1] = poker
				cnt = cnt + 1
			end
		end
	end
	if self._isDispatchingPoker then
		self._isDispatchingPoker = false
	end
end

-- 开始发牌
function SDUI:startDispatchPoker(callback)
	local inPlayingPlayerList = self:getInPlayingPlayers()
	local playerNum = #inPlayingPlayerList
	local pokerNum = 17
	local delay = 1
	if self._isPlayBack then
		delay = 0.4
	end
	for index = 1, pokerNum do
		for ind = 1, playerNum do
			local cnt = (index - 1) * playerNum + ind
			local paiDuiInd = maxPaiDuiNum - cnt + 1
			local poker = self._paiDui[paiDuiInd]
			local playerView = inPlayingPlayerList[ind]
			local playerId = playerView._player.id
			local cliSeatId = playerView._cliSeatId
			local isShowPokerNum = self._model:getIsCardNum()
			local iniPos = self:calFirstPokerPos(cliSeatId, pokerNum)
			if poker then
				playerView._pokers[#playerView._pokers + 1] = poker
				local desPos = cc.p(iniPos.x, iniPos.y)
				local scale = myPokerScale
				if cliSeatId == 1 then
					desPos.x = desPos.x + myDis * (index - 1)
				else
					scale = otherPokerScale
					if isShowPokerNum then
						desPos.y = desPos.y - otherDis * (index - 1)
					end
				end				
				local moveTo = cc.MoveTo:create(0.1 * delay, desPos)
				local scaleTo = cc.ScaleTo:create(0.1 * delay, scale)
				local delayTime = cc.DelayTime:create((index - 1) * 0.08 * delay)
				local callfunc = cc.CallFunc:create(function()
						AudioEngine:playEffect("res/audio/com_dispatchpoker1.mp3")
						poker:setLocalZOrder(index)
						if playerId == self._id then
							local pokerKind, pokerType = self._model:getPokerByIdAndIndex(self._id, index)
							poker:initPoker(pokerKind, pokerType, WZ_POKER_STATE.NEGATIVE, false)
							poker:turnPoker()
						end
						if cnt == playerNum * pokerNum then
							performWithDelay(self, function()
									if callback then callback() end
									self:clearChoosePokers()
									self._isDispatchingPoker = false
								end, 0.5)
						end
					end)
				local spa = cc.Spawn:create(moveTo, scaleTo)
				local seq = cc.Sequence:create(delayTime, spa, callfunc)
				poker:runAction(seq)
			end
		end
	end
end

function SDUI:calFirstPokerPos(cliSeatId, totalPokerNum)
	local playerView = self._playerViewByCliSeatId[cliSeatId]
	local anchorOfView = cc.p(0.5, 0.5)
	local pos = cc.p(0, 0)
	local posOfView = playerView._pos
	local sizeOfView = playerView._size
	if 1 == cliSeatId then
		pos.x = pos.x + GL_SIZE.width / 2 - (totalPokerNum - 1) * myDis / 2
		pos.y = PokerSize.height * myPokerScale / 2 + 10
	elseif 2 == cliSeatId then
		pos.x = posOfView.x - anchorOfView.x * sizeOfView.width - PokerSize.width * otherPokerScale / 2
		pos.y = posOfView.y + (1  - anchorOfView.y) * sizeOfView.height - PokerSize.height * otherPokerScale / 2
	elseif 3 == cliSeatId then
		pos.x = posOfView.x + (1 - anchorOfView.x) * sizeOfView.width + PokerSize.width * otherPokerScale / 2
		pos.y = posOfView.y + (1  - anchorOfView.y) * sizeOfView.height - PokerSize.height * otherPokerScale / 2
	end
	return pos
end
------------------------------ 发牌 E ----------------------------
---------------------------- 打牌效果 S --------------------------
function SDUI:calOprRetPos(id)
	local pos = cc.p(0, 0)
	local playerView = self._playerViewById[id]
	local cliSeatId = playerView._cliSeatId
	local posXOfView = playerView:getPositionX()
	local sizeOfView = playerView:getContentSize()
	local anchorOfView = playerView:getAnchorPoint()
	if 1 == cliSeatId then
		pos.x = GL_SIZE.width / 2
		pos.y = PokerSize.height * myPokerScale + 20 + PokerSize.height * myRiverScale / 2
	elseif 2 == cliSeatId then
		pos.x = posXOfView - sizeOfView.width * (1- anchorOfView.x) - PokerSize.width * otherPokerScale - 20
		pos.y = GL_SIZE.height - 200
	elseif 3 == cliSeatId then
		pos.x = posXOfView + sizeOfView.width * anchorOfView.x + 20 + PokerSize.width * otherPokerScale
		pos.y = GL_SIZE.height - 200
	end
	return pos
end

function SDUI:calFirstRiverPos(id, num)
	local pos = cc.p(0, 0)
	local playerView = self._playerViewById[id]
	local cliSeatId = playerView._cliSeatId
	local posXOfView = playerView:getPositionX()
	local sizeOfView = playerView:getContentSize()
	local anchorOfView = playerView:getAnchorPoint()
	if 1 == cliSeatId then
		pos.x = GL_SIZE.width / 2 - (num - 1) * myRiverDis / 2
		pos.y = PokerSize.height * myPokerScale + 40 + PokerSize.height * myRiverScale / 2
	elseif 2 == cliSeatId then
		pos.x = posXOfView - sizeOfView.width * anchorOfView.x
		pos.x = pos.x - PokerSize.width * otherRiverScale / 2 - (num - 1) * otherRiverDis - 20 - PokerSize.width * otherPokerScale
		pos.y = GL_SIZE.height - 180
	elseif 3 == cliSeatId then
		pos.x = posXOfView + sizeOfView.width * anchorOfView.x + 20 + PokerSize.width * otherRiverScale / 2 + PokerSize.width * otherPokerScale
		pos.y = GL_SIZE.height - 180
	end
	return pos
end

function SDUI:playPokerEffect(id)
	local playerView = self._playerViewById[id]
	local prePlayedPokers = self._model:getPrePlayedPokers()
	local prePlayedId = self._model:getPrePlayPlayerId()
	if #prePlayedPokers > 0 and id == prePlayedId then
		if playerView._sprBuChu then
			playerView._sprBuChu:setVisible(false)
		end
		local iniPos = self:calFirstRiverPos(id, #prePlayedPokers)
		local disX = myRiverDis
		local scale = myRiverScale
		if 1 ~= playerView._cliSeatId then
			disX = otherRiverDis
			scale = otherRiverScale
		end
		if id == self._id then
			local pokerIndToPosArr = {}
			for ind, pokerData in ipairs(prePlayedPokers) do
				pokerIndToPosArr[pokerData.num] = pokerIndToPosArr[pokerData.num] or {}
				pokerIndToPosArr[pokerData.num][pokerData.flower] = ind
			end
			for ind = #playerView._pokers, 1, -1 do
				local poker = playerView._pokers[ind]
				local pokerKind = poker:getPokerKind()
				local pokerType = poker:getPokerType()
				if nil ~= pokerIndToPosArr[pokerKind] and nil ~= pokerIndToPosArr[pokerKind][pokerType] then
					local curIndex = pokerIndToPosArr[pokerKind][pokerType]
					local desPos = cc.p(iniPos.x, iniPos.y)
					desPos.x = desPos.x + (curIndex - 1) * disX
					poker:stopAllActions()
					local scaleTo = cc.ScaleTo:create(0.05, scale)
					local moveTo = cc.MoveTo:create(0.05, desPos)
					local spa = cc.Spawn:create(moveTo, scaleTo)
					local callfunc = cc.CallFunc:create(function()
							poker:setLocalZOrder(curIndex)
						end)
					poker:runAction(cc.Sequence:create(spa, callfunc))
					playerView._riverPokers[#playerView._riverPokers + 1] = poker
					table.remove(playerView._pokers, ind)
				end
			end
			local function delayCall()
				local iniHandPos = self:calFirstPokerPos(playerView._cliSeatId, #playerView._pokers)
				for ind = 1, #playerView._pokers do
					local poker = playerView._pokers[ind]
					poker:stopAllActions()
					local desPos = cc.p(iniHandPos.x, iniHandPos.y)
					desPos.x = desPos.x + myDis * (ind - 1)
					poker:setLocalZOrder(ind)
					local delayTime = cc.DelayTime:create(0.1)
					local moveTo = cc.MoveTo:create(0.1, desPos)
					poker:runAction(cc.Sequence:create(delayTime, moveTo))
				end
			end
			performWithDelay(self, delayCall, 0.05)
			self._choosedPokers = {}
		else
			local sIndex = #playerView._pokers - #prePlayedPokers + 1
			for ind, pokerData in ipairs(prePlayedPokers) do
				local desPos = cc.p(iniPos.x, iniPos.y)
				desPos.x = desPos.x  + otherRiverDis * (ind - 1)
				local poker = playerView._pokers[sIndex]
				poker:initPoker(pokerData.num, pokerData.flower, WZ_POKER_STATE.POSITIVE)
				local scaleTo = cc.ScaleTo:create(0.05, scale)
					local moveTo = cc.MoveTo:create(0.05, desPos)
					local spa = cc.Spawn:create(moveTo, scaleTo)
					local callfunc = cc.CallFunc:create(function()
							poker:setLocalZOrder(ind)
						end)
					local seq = cc.Sequence:create(spa, callfunc)
					poker:runAction(seq)
				playerView._riverPokers[#playerView._riverPokers + 1] = poker
				table.remove(playerView._pokers, sIndex)
			end
		end
		AudioEngine:playEffect("res/audio/com_playcard.mp3", false)
		local cliSeatId = playerView._cliSeatId
		local pokerStyle = SDController.getPokerStyle(prePlayedPokers)
		performWithDelay(self, function()
				self:runPokerStyleEffect(id, pokerStyle, prePlayedPokers)
			end, 0.2)
	else
		for ind = #playerView._riverPokers, 1, -1 do
			playerView._riverPokers[ind]:setVisible(false)
			table.remove(playerView._riverPokers, ind)
		end
		if nil == playerView._sprBuChu then
			playerView._sprBuChu = cc.Sprite:create("res/landlord/landlord_buchu.png")
			local pos = self:calOprRetPos(id)
			playerView._sprBuChu:setPosition(pos)
			self._layer:addChild(playerView._sprBuChu)
		end
		playerView._sprBuChu:setOpacity(0)
		playerView._sprBuChu:setVisible(true)
		playerView._sprBuChu:setScale(2.0)
		local fadeIn = cc.FadeIn:create(0.2)
		local scaleTo = cc.ScaleTo:create(0.2, 1.0)
		local spa = cc.Spawn:create(fadeIn, scaleTo)
		playerView._sprBuChu:runAction(spa)
		local sex = playerView._player.sex
		local audioName = "pass"..tostring(math.random(1, 2))
		SD_PLAY_SPECIAL_AUDIO(sex, audioName)
	end
--	self:stopCountDown()
end

function SDUI:initRiverCards()
	local prePlayedPokers = self._model:getPrePlayedPokers()
	local prePlayedId = self._model:getPrePlayPlayerId()
	local playerView = self._playerViewById[prePlayedId]
	if self._model:getActionPlayerId() ~= prePlayedId and 0 ~= prePlayedId then
		local iniPos = self:calFirstRiverPos(prePlayedId, #prePlayedPokers)
		for ind, pokerData in ipairs(prePlayedPokers) do
			local desPos = cc.p(iniPos.x, iniPos.y)
			local scale = 1
			if prePlayedId == self._id then
				desPos.x = desPos.x + myRiverDis * (ind - 1)
				scale = myRiverScale
			else
				desPos.x = desPos.x  + otherRiverDis * (ind - 1)
				scale = otherRiverScale
			end
			local poker = playerView._riverPokers[ind]
			if nil == poker then
				poker = Poker.new(pokerData.num, pokerData.flower, WZ_POKER_STATE.POSITIVE)
				self.panPokerLayer:addChild(poker)
				self._paiDui[#self._paiDui + 1] = poker
				playerView._riverPokers[#playerView._riverPokers + 1] = poker
			end
			poker:setPosition(desPos)
			poker:setLocalZOrder(ind)
			poker:setScale(scale)
		end
	end
end
---------------------------- 打牌效果 E --------------------------
---------------------------- 牌型效果 S --------------------------
function SDUI:runPokerStyleEffect(id, style, pokers)
	if style == SD_POKER_STYLE.CT_BOMB then
		self:playBombAni(id)
		AudioEngine:playEffect("res/audio/effect/bomb.mp3", false)
	elseif style == SD_POKER_STYLE.CT_SINGLE_LINE then
		self:playStraightAni(id)
	elseif style == SD_POKER_STYLE.CT_THREE_LINE then
		self:playFeiJiAni(id)
	elseif style == SD_POKER_STYLE.CT_THREE_TAKE_SINGLE or
			style == SD_POKER_STYLE.CT_THREE_TAKE_DOUBLE then
	elseif style == SD_POKER_STYLE.CT_DOUBLE_LINE then
		self:playPairsAni(id)
	end
	if #pokers >= 1 then
		local player = self._model:getPlayerById(id)
		SD_PLAY_AUDIO(player.sex, style, pokers[1].num)
	end
end

-- 炸弹
function SDUI:playBombAni(id)
	local pos = cc.p(GL_SIZE.width / 2, GL_SIZE.height / 2 + 150)
	local ani = cc.CSLoader:createNode("res/animation/bomb.csb")
	local action = cc.CSLoader:createTimeline("res/animation/bomb.csb")
	ani:runAction(action)
	action:play("bomb", false)
	self._layer:addChild(ani, 100)
	ani:setPosition(pos)
	local delayTime = cc.DelayTime:create(0.6)
	local reomveSelf = cc.RemoveSelf:create()
	ani:runAction(cc.Sequence:create(delayTime, reomveSelf))
end

-- 春天
function SDUI:playSpringAni(playerId)
	local pos = cc.p(GL_SIZE.width / 2, GL_SIZE.height / 2)
	local ani = cc.CSLoader:createNode("res/animation/spring.csb")
	local action = cc.CSLoader:createTimeline("res/animation/spring.csb")
	ani:runAction(action)
	action:play("spring", true)
	self._layer:addChild(ani, 100)
	ani:setPosition(pos)
	local delayTime = cc.DelayTime:create(2.0)
	local reomveSelf = cc.RemoveSelf:create()
	ani:runAction(cc.Sequence:create(delayTime, reomveSelf))
	local player = self._playerViewById[playerId]._player
	local sex = math.random(0, 1)
	if player and player.sex then
		sex = player.sex
	end
	local url = string.format("res/audio/effect/%s_spring.mp3", sex == 0 and "w" or "m")
	AudioEngine:playEffect(url, false)
end

-- 连对
function SDUI:playPairsAni(id)
	local pos = cc.p(GL_SIZE.width / 2, GL_SIZE.height / 2 )
	local ani = cc.CSLoader:createNode("res/animation/pair.csb")
	local action = cc.CSLoader:createTimeline("res/animation/pair.csb")
	ani:runAction(action)
	action:play("pair", true)
	self._layer:addChild(ani, 100)
	ani:setPosition(pos)
	local delayTime = cc.DelayTime:create(1.0)
	local reomveSelf = cc.RemoveSelf:create()
	ani:runAction(cc.Sequence:create(delayTime, reomveSelf))
end

-- 飞机
function SDUI:playFeiJiAni(id)
	local pos = cc.p(GL_SIZE.width, GL_SIZE.height / 2)
	local ani = cc.CSLoader:createNode("res/animation/plane.csb")
	local action = cc.CSLoader:createTimeline("res/animation/plane.csb")
	ani:runAction(action)
	action:play("plane", true)
	self._layer:addChild(ani, 100)
	ani:setPosition(pos)
	local moveTo = cc.MoveTo:create(1, cc.p(0, GL_SIZE.height / 2))
	local reomveSelf = cc.RemoveSelf:create()
	local seq = cc.Sequence:create(moveTo, reomveSelf)
	ani:runAction(seq)
end

-- 顺子
function SDUI:playStraightAni(id)
	local pos = cc.p(GL_SIZE.width + 200, 0)
	local ani = cc.CSLoader:createNode("res/animation/straight.csb")
	local action = cc.CSLoader:createTimeline("res/animation/straight.csb")
	ani:runAction(action)
	action:play("straight", true)
	self._layer:addChild(ani, 100)
	ani:setPosition(pos)
	local moveTo = cc.MoveTo:create(2.0, cc.p(-200, 0))
	local reomveSelf = cc.RemoveSelf:create()
	ani:runAction(cc.Sequence:create(moveTo, reomveSelf))
end
---------------------------- 牌型效果 E --------------------------
--------------------------- 显示报警效果 S -----------------------
function SDUI:showAlert(id)
	if self._id ~= id then
		local playerView = self._playerViewById[id]
		if playerView then
			if nil == playerView._alertEffect then
				local sizeOfView = playerView:getContentSize()
				playerView._alertEffect = cc.CSLoader:createNode("res/animation/alert.csb")
				local action = cc.CSLoader:createTimeline("res/animation/alert.csb")
				playerView._alertEffect:runAction(action)
				action:play("alert", true)
				playerView:addChild(playerView._alertEffect)
				playerView._alertEffect:setPosition(cc.p(sizeOfView.width / 2, 50))
			end
			playerView._alertEffect:setVisible(true)
		end
		AudioEngine:playEffect("res/audio/effect/baojing.mp3", false)
	end
end

function SDUI:clearAllAlert()
	for __, playerView in pairs(self._playerViewById) do
		if playerView._alertEffect then
			playerView._alertEffect:setVisible(false)
		end
	end
end
--------------------------- 显示报警效果 E -----------------------
---------------------------- 选牌 S ------------------------------
function SDUI:choosePokers(pokerList)
	local inChooseArr = {}
	for __, poker in ipairs(pokerList) do
		inChooseArr[poker.num] = inChooseArr[poker.num] or {}
		inChooseArr[poker.num][poker.flower] = true
	end
	local playerView = self._playerViewById[self._id]
	for __, poker in ipairs(playerView._pokers) do
		local num = poker:getPokerKind()
		local flower = poker:getPokerType()
		if inChooseArr[num] and inChooseArr[num][flower] then
			self._choosedPokers = self._choosedPokers or {}
			self._choosedPokers[#self._choosedPokers + 1] = poker
			local iniPos = self:calFirstPokerPos(1, #playerView._pokers)
			poker:stopAllActions()
			poker:setPositionY(iniPos.y + 20)
		end
	end
end
---------------------------- 选牌 E ------------------------------

-- 更新时间
function SDUI:refreshTime()
	self.labTime:setString(Time.getFormat2Time())
end

-- 时钟倒计时
function SDUI:refreshCountDown()
	if nil ~= self._countDown then
		if self._countDown > 0 then
			self._countDown = math.max(0, self._countDown - 1)
			self.textAtlasTime:setString(self._countDown)
			if self._countDown <= 5 then
				AudioEngine:playEffect("res/audio/com_countdown.mp3")
			end
		end
	end
end

-- 重置操作按钮位置
function SDUI:resetOprBtnPos()
	local sizeOfPan = self.panOprPai:getContentSize()
	local sizeOfBtn = self.btnTiShi:getContentSize()
	self.btnTiShi:setPositionX(sizeOfPan.width / 2)
	self.btnBuChu:setPositionX(sizeOfBtn.width / 2)
	self.btnOut:setPositionX(sizeOfPan.width - sizeOfBtn.width / 2)
end

function SDUI:resetBtnView(isShow)
	self.btnTiShi:setVisible(isShow)
	self.btnBuChu:setVisible(isShow)
	self.btnOut:setVisible(isShow)
end

-- 刷新出牌操作
function SDUI:refreshPlayCardOpr(isNeedNewTiShi)
	local isCanPlayPoker = self._model:getIsCanPlayPoker()
	self.panOprPai:setVisible(isCanPlayPoker)
	self.imgCannotPlay:setVisible(false)
	if isCanPlayPoker then
		-- 上次自己打的牌没人管就不在提示
		local pan = self.panOprPai
		local sizeOfPan = pan:getContentSize()
		local prePlayedId = self._model:getPrePlayPlayerId()
		local prePlayerPoker = self._model:getPrePlayedPokers()
		local handPokers = self._model:getMyPokers()
		local ifForcePoker = SDController.getPokerIsForce(handPokers, prePlayerPoker)
		local isTipping = self._model:getIsTipping()
		local isFourBomb = SDController.getIsFourBomb(handPokers)
		local isHeatFour = false
		local isHasAir = self._model:getAircraft()
		local forceCard = self._model:getForceCard()
		self:resetBtnView(true)
		if prePlayedId == self._id then
			if self._choosedPokers == nil or #self._choosedPokers < 1 then
				CommonFunc.disableBtn(self.btnOut)
			else
				local pokerDatas = {}
				for __, poker in ipairs(self._choosedPokers) do
					pokerDatas[#pokerDatas + 1] = {
						flower = poker:getPokerType(),
						num = poker:getPokerKind(),
					}
				end
				local choosePokerStyle = SDController.getPokerStyle(pokerDatas)
				local nextPlayerCardNum = self._model:getNextPlayerCardNum()
				if choosePokerStyle == SD_POKER_STYLE.CT_ERROR then
					CommonFunc.disableBtn(self.btnOut)
				else
					if nextPlayerCardNum == 1 and choosePokerStyle == SD_POKER_STYLE.CT_SINGLE then
						local forceOut = SDController.intelligentOutPokers(handPokers, pokerDatas)
						if #forceOut < 1 then
							CommonFunc.enableBtn(self.btnOut)
						else
							CommonFunc.disableBtn(self.btnOut)
						end
					elseif isTipping then
						if choosePokerStyle ~= SD_POKER_STYLE.CT_BOMB then
							CommonFunc.disableBtn(self.btnOut)
						else
							CommonFunc.enableBtn(self.btnOut)
						end
					else
						CommonFunc.enableBtn(self.btnOut)
					end
				end
			end
			CommonFunc.disableBtn(self.btnTiShi)
			CommonFunc.disableBtn(self.btnBuChu)
			self:resetOprBtnPos()
			self.imgCannotPlay:setVisible(false)
		elseif prePlayedId == 0 then
			CommonFunc.disableBtn(self.btnBuChu)
			CommonFunc.disableBtn(self.btnTiShi)
			if self._choosedPokers == nil or #self._choosedPokers < 1 then
				CommonFunc.disableBtn(self.btnOut)
			else
				local pokerDatas = {}
				for __, poker in ipairs(self._choosedPokers) do
					pokerDatas[#pokerDatas + 1] = {
						flower = poker:getPokerType(),
						num = poker:getPokerKind(),
					}
					if poker:getPokerKind() == 4 and poker:getPokerType() == 3 then
						isHeatFour = true
					end
				end
				if isHeatFour then
					local pokerStyle = SDController.getPokerStyle(pokerDatas)
					if isFourBomb then
						if pokerStyle ~= SD_POKER_STYLE.CT_BOMB then
							CommonFunc.disableBtn(self.btnOut)
						else
							CommonFunc.enableBtn(self.btnOut)
						end
					else
						if pokerStyle == SD_POKER_STYLE.CT_ERROR then
							CommonFunc.disableBtn(self.btnOut)
						else
							CommonFunc.enableBtn(self.btnOut)
						end
					end
				else
					CommonFunc.disableBtn(self.btnOut)
				end
			end
			self:resetOprBtnPos()
		else
			if self:getIsCanPlay() then
				if isNeedNewTiShi then
					self:getIntellegentPokers(true)
					self._tiShiIndex = 0
				end
				if ifForcePoker or isTipping or forceCard then
					CommonFunc.disableBtn(self.btnBuChu)
				else
					CommonFunc.enableBtn(self.btnBuChu)
				end
				if #self._canOutPokers < 1 then
					CommonFunc.disableBtn(self.btnTiShi)
				else
					CommonFunc.enableBtn(self.btnTiShi)
				end
				if self._choosedPokers == nil or #self._choosedPokers < 1 then
					CommonFunc.disableBtn(self.btnOut)
				else
					local prePlayedPokers = self._model:getPrePlayedPokers()
					local pokerDatas = {}
					for __, poker in ipairs(self._choosedPokers) do
						pokerDatas[#pokerDatas + 1] = {
							flower = poker:getPokerType(),
							num = poker:getPokerKind(),
						}
					end
					if SDController.compareCard(prePlayedPokers, pokerDatas) then
						local choosePokerStyle = SDController.getPokerStyle(pokerDatas)
						local nextPlayerCardNum = self._model:getNextPlayerCardNum()
						if nextPlayerCardNum == 1 and choosePokerStyle == SD_POKER_STYLE.CT_SINGLE then
							local forceOut = SDController.intelligentOutPokers(handPokers, pokerDatas)
							if #forceOut < 1 then
								CommonFunc.enableBtn(self.btnOut)
							else
								CommonFunc.disableBtn(self.btnOut)
							end
						else
							CommonFunc.enableBtn(self.btnOut)
						end
					else
						CommonFunc.disableBtn(self.btnOut)
					end
				end
				self:resetOprBtnPos()
			else
				self.btnBuChu:setVisible(true)
				self.btnTiShi:setVisible(false)
				self.btnOut:setVisible(false)
				self.imgCannotPlay:setVisible(true)
				local sizeOfPan = self.panOprPai:getContentSize()
				self.btnBuChu:setPositionX(sizeOfPan.width / 2)
				CommonFunc.enableBtn(self.btnBuChu)
			end
		end
	end
end

-- 刷新玩家手牌数
function SDUI:refreshRemainCardNum()
	local period = self._model:getRoundPeriod()
	local boNeedShow = period ~= SD_PERIOD_WAIT and period ~= SD_PERIOD_START
	local isCardNum = self._model:getIsCardNum()
	for __, playerView in pairs(self._playerViewById) do
		local labCardNum = playerView:getChildByName("labCardNum")
		if boNeedShow and isCardNum then
			labCardNum:setVisible(true)
			local remainNum = self._model:getRemainPokerNum(playerView._id)
			labCardNum:setString(string.format("剩余：%d", remainNum))
		else
			labCardNum:setVisible(false)
		end
	end
end

-- 刷新当前可操作玩家
function SDUI:refreshActionPlayer()
	self:refreshPlayCardOpr(true)
end

-- 玩家加入房间
function SDUI:insertPlayer(player)
	local cliSeatId = player.cliSeatId
	local seat = self["seat"..cliSeatId]
	assert(seat._player == nil, "该位置上已经有人坐了") 
	seat:setVisible(true)
	self:refreshSeatInfo(seat, player)
	AudioEngine:playEffect("res/audio/com_ready.mp3")
end

-- 玩家退出房间
function SDUI:removePlayer(id)
	local seat = self._playerViewById[id]
	self:refreshSeatInfo(seat, nil)
end

-- 计算闹钟的位子
function SDUI:getClockPos(cliSeatId)
	local pos = cc.p(0, 0)
	if 1 == cliSeatId then
		pos.x = GL_SIZE.width / 2
		pos.y = 390
	elseif 2 == cliSeatId then
		pos.x = GL_SIZE.width - 280
		pos.y = GL_SIZE.height * 2 / 3
	elseif 3 == cliSeatId then
		pos.x = 280
		pos.y = GL_SIZE.height * 2 / 3
	end
	return pos
end

-- 开始倒计时
function SDUI:startCountDown(cnt)
	local actionPlayerId = self._model:getActionPlayerId()
	local playerView = self._playerViewById[actionPlayerId]
	if playerView then
		local cliSeatId = playerView._cliSeatId
		self._countDown = cnt
		self.imgClock:setVisible(true)
		self.textAtlasTime:setString(self._countDown)
		self.imgClock:setPosition(self:getClockPos(cliSeatId))
	end
end

-- 停止倒计时
function SDUI:stopCountDown()
	self._countDown = nil
	self.imgClock:setVisible(false)
end

-- 获取游戏中的玩家
function SDUI:getInPlayingPlayers()
	local playerViews = {}
	for __, playerView in pairs(self._playerViewById) do
		playerViews[#playerViews + 1] = playerView
	end
	table.sort(playerViews, function(a, b)
			return a._cliSeatId < b._cliSeatId
		end)
	return playerViews
end

-- 刷新房号
function SDUI:refreshRoomId()
	self.labRoomId:setString(string.format("房号：%d", self._model:getRoomId()))
end

-- 刷新局数
function SDUI:refreshRound()
	local round, maxRound = self._model:getRound()
	self.labRound:setString(string.format("第(%d/%d)局", round, maxRound))
end

-- 刷新底分
function SDUI:refreshBottomScore()
	self.labBaseScore:setString(string.format("底分：%d", self._model:getBaseScore()))
end

-- 刷新炸弹
function SDUI:refreshBombNum()
	self.labBombNum:setString(string.format("炸弹：%d", self._model:getBombNum()))
end

-- 刷新玩法Tip
function SDUI:refreshPlayType()
--	self.labPlayTip:setString(self._model:getPlayTypeDes())
end

-- 不出
function SDUI:onBuChuClickHandler()
	SDController.playPokerReq({})
	self:clearChoosePokers()
end

function SDUI:getIntellegentPokers(boNew)
	local pokers = {}
	self._tiShiIndex = self._tiShiIndex or 0
	if boNew then
		self._canOutPokers = {}
		local prePlayedId = self._model:getPrePlayPlayerId()
		local prePlayedPokers = self._model:getPrePlayedPokers()
		local handPokers = self._model:getMyPokers()
		if prePlayedId ~= self._id and #prePlayedPokers > 0 then
			self._canOutPokers = SDController.intelligentOutPokers(handPokers, prePlayedPokers)
			self._tiShiIndex = 0
		else
			self._tiShiIndex = 0
		end
	end
	if self._canOutPokers and #self._canOutPokers >= 1 then
		self._tiShiIndex = self._tiShiIndex + 1
		self._tiShiIndex = self._tiShiIndex > #self._canOutPokers and 1 or self._tiShiIndex
		pokers = self._canOutPokers[self._tiShiIndex] or {}
	end
	return pokers
end

-- 智能提示
function SDUI:intelligentPokers(boNew)
	self:clearChoosePokers()
	self:choosePokers(self:getIntellegentPokers(boNew))
end

-- 重置所有手中的牌
function SDUI:clearChoosePokers()
	local playerView = self._playerViewById[self._id]
	local iniPos = self:calFirstPokerPos(1, #playerView._pokers)
	local playerView = self._playerViewById[self._id]
	for __, poker in ipairs(playerView._pokers) do
		poker:setPositionY(iniPos.y)
	end
	CommonFunc.disableBtn(self.btnOut)
	self._choosedPokers = {}
	self._sIndex = 0
	self._eIndex = 0
end

-- 点击玩家头像
function SDUI:onIconClickHandler(cliSeatId)
	local playerView = self._playerViewByCliSeatId[cliSeatId]
	local playerInfo = {
		id = playerView._player.id,
		icon = playerView._player.icon,
		name = playerView._player.name,
		ip = playerView._player.ip,
		gps = playerView.gps,
	}
	EventBus:dispatchEvent(EventEnum.openUI, {uiName = "InfoUI", parms = {playerInfo}})
end

function SDUI:onDisbandClickHandler()
	if self._isPlayBack then
		EventBus:dispatchEvent(EventEnum.exitSD)
		AudioEngine:resumeMusic()
	else
		local period = self._model:getRoundPeriod()
		local roomOwnerId = self._model:getRoomOwnerId()
		local strContent = "确认解散房间？"
		if SD_PERIOD_WAIT == period then
			if roomOwnerId ~= self._id then
				strContent = "确认退出房间？"
			end
		end
		CommonFunc.showTip(strContent, function()
				HallController.exitRoomReq()
			end)
	end
end

-- 设置
function SDUI:onSetClickHandler()
	EventBus:dispatchEvent(EventEnum.openUI, {uiName = "SettingUI"})
end

function SDUI:onChatClickHandler()
	ChatController.openChatUI(PlayType.TT_SX_SD)	
end

function SDUI:onHelpClickHandler()
	local tabDes = SDController.getTabDes()
	EventBus:dispatchEvent(EventEnum.openUI, {uiName = "PlayTipUI", parms = {tabDes}})	
end

-- 分享
function SDUI:onShareClickHandler()
	local strTitle = string.format("[178西北玩] 房号:%d", self._model:getRoomId())
	local strContent = string.format("三代<%s>一起来玩吧！", self._model:getPlayTypeDes())
	local url = string.format(GAME_URL, tostring(AccountController.getPlayerId()), os.date("%m%d%H", os.time()))
	wxShare(strTitle, strContent, url, "0")
end

-- 播放录音动画
function SDUI:playRecordAni(boRun)
	if nil ~= self._voiceAni then
		self._voiceAni:removeFromParent()
		self._voiceAni = nil
	end
	if boRun then
		self._voiceAni = cc.CSLoader:createNode("res/animation/voiceani.csb")
		local action = cc.CSLoader:createTimeline("res/animation/voiceani.csb")
		self._voiceAni:runAction(action)
		action:play("ani", true)
		self._layer:addChild(self._voiceAni, 100)
		self._voiceAni:setPosition(cc.p(GL_SIZE.width / 2, GL_SIZE.height / 2 + 20))
		self._voiceAni:setScale(1.2)
	end
end

-- 语音
function SDUI:onBtnVoiceEventHandler(sender, eventType)
	if eventType == TOUCH_EVENT_BEGAN then
		sender._preScale = sender:getScale()
		sender:setScale(sender._preScale - 0.05)
		self:playRecordAni(true)
        AudioEngine:pauseMusic()
        startRecord( cc.FileUtils:getInstance():getWritablePath().."mj_sound"..self._id..".amr", self._id)
	elseif eventType == TOUCH_EVENT_ENDED then
		sender:setScale(sender._preScale)
		sender._preScale = nil
		self:playRecordAni(false)
		stopRecord()
		AudioEngine:resumeMusic()
	elseif eventType == TOUCH_EVENT_CANCELED then
		sender:setScale(sender._preScale)
		sender._preScale = nil
		self:playRecordAni(false)
		AudioEngine:resumeMusic()
	end
end

-- 提示
function SDUI:onTiShiClickHandler()
	local prePlayedPokers = self._model:getPrePlayedPokers()
	if #prePlayedPokers > 0 then
		self:intelligentPokers(false)
		self:refreshPlayCardOpr()
	end
end

-- 出牌
function SDUI:onOutClickHandler()
	local pokerList = {}
	local isHeatFour = false
	local prePlayedId = self._model:getPrePlayPlayerId()
	self._touchLayer:setVisible(true and not self._isPlayBack)
	if self._choosedPokers == nil or #self._choosedPokers < 1 then
		CommonFunc.showCenterMsg("未选中任何牌")
		return
	end
	for __, poker in ipairs(self._choosedPokers) do
		pokerList[#pokerList + 1] = {
			num = poker:getPokerKind(),
			flower = poker:getPokerType(),
		}
		if poker:getPokerKind() == 4 and poker:getPokerType() == 3 then
			isHeatFour = true
		end
	end
	if prePlayedId == 0 then
		if not isHeatFour then
			CommonFunc.showCenterMsg("首出必带红桃4")
			return
		else
			if SD_POKER_STYLE.CT_BOMB == SDController.getPokerStyle(pokerList) then
				SDController.isTippingReq()
			end
		end
	end
	isHeatFour = false
	SDController.playPokerReq(pokerList)
end

-- 是否有牌大于上家
function SDUI:getIsCanPlay()
	local boRet = false
	local canOutPokers = {}
	local prePlayedId = self._model:getPrePlayPlayerId()
	local prePlayedPokers = self._model:getPrePlayedPokers()
	local handPokers = self._model:getMyPokers()
	if prePlayedId ~= self._id and #prePlayedPokers > 0 then
		canOutPokers = SDController.intelligentOutPokers(handPokers, prePlayedPokers)
	end
	if #canOutPokers >= 1 then
		boRet = true
	end
	return boRet
end

function SDUI:refreshChoosedPokers()
	self._choosedPokers = self._choosedPokers or {}
	local playerView = self._playerViewById[self._id]
	local iniPos = self:calFirstPokerPos(1, #playerView._pokers)
	for ind = #self._choosedPokers, 1, -1 do
		local poker = self._choosedPokers[ind]
		if self._touchedPokers[poker] then
			table.remove(self._choosedPokers, ind)
		end
		self._touchedPokers[poker] = nil
		poker:setShade(false)
		poker:setPositionY(iniPos.y)
	end
	for __, poker in pairs(self._touchedPokers) do
		self._choosedPokers[#self._choosedPokers + 1] = poker
		poker:setShade(false)
	end
	for __, poker in ipairs(self._choosedPokers) do
		poker:setPositionY(iniPos.y + 20)
	end
	self._touchedPokers = {}
end

function SDUI:checkTouchCard(poker, gX, gY)
	local posOfPoker = cc.p(poker:getPosition())
	local boundingBox = poker:getBoundingBox()
	local ret = false
	if cc.rectContainsPoint(boundingBox, cc.p(gX, gY)) then
		ret = true
	end
	return ret
end

function SDUI:refreshTouchedPokers(sIndex, eIndex)
	local minIndex = math.min(sIndex, eIndex)
	local maxIndex = math.max(sIndex, eIndex)
	local playerView = self._playerViewById[self._id]
	for ind, poker in ipairs(playerView._pokers) do
		if ind >= minIndex and ind <= maxIndex then
			self._touchedPokers[poker] = poker
			poker:setShade(true)
		else
			self._touchedPokers[poker] = nil
			poker:setShade(false)
		end
	end
end

function SDUI:getTouchedPokerIndex(gX, gY)
	local index = 0
	local playerView = self._playerViewById[self._id]
	for ind = #playerView._pokers, 1, -1 do
		local poker = playerView._pokers[ind]
		if self:checkTouchCard(poker, gX, gY) then
			index = ind
			break
		end
	end
	return index
end

-- 触碰
function SDUI:onTouchEvent(eventType, x, y)
	if eventType == "began" then
		local period = self._model:getRoundPeriod()
		if period ~= SD_PERIOD_PLAY then return false end
		self._sIndex = 0
		self._eIndex = 0
		self._touchedPokers = {}
		self._sIndex = self:getTouchedPokerIndex(x, y)
		if 0 == self._sIndex then
			self:clearChoosePokers()
			return false
		else
			AudioEngine:playEffect("res/audio/com_cardclick.mp3")
			self._eIndex = self._sIndex
			self:refreshTouchedPokers(self._sIndex, self._eIndex)
			return true
		end
	elseif eventType == "moved" then
		local index = self:getTouchedPokerIndex(x, y)
		if index ~= 0 then
			self._eIndex = index
			self:refreshTouchedPokers(self._sIndex, self._eIndex)
		end
	elseif eventType == "ended" then
		local index = self:getTouchedPokerIndex(x, y)
		if index ~= 0 then
			self._eIndex = index
			self:refreshTouchedPokers(self._sIndex, self._eIndex)
		end
		AudioEngine:playEffect("res/audio/com_cardclick.mp3")
		self:refreshChoosedPokers()
		self:refreshPlayCardOpr()
	elseif eventType == "cancelled" then
		local index = self:getTouchedPokerIndex(x, y)
		if index ~= 0 then
			self._eIndex = index
			self:refreshTouchedPokers(self._sIndex, self._eIndex)
		end
		AudioEngine:playEffect("res/audio/com_cardclick.mp3")
		self:refreshChoosedPokers()
	end
end
--------------------------- 数据层事件 S -------------------------
-- 上线
function SDUI:onPlayerOnlineHandler(eventData)
	self:refreshPlayerState(eventData.id)
end

-- 阶段变化
function SDUI:onPeriodChangeHandler(eventData)
	self:switchPeriod(eventData.period)
end

-- 玩家出牌
function SDUI:onPlayCardHandler(eventData)
	if self._isPlayBack then
		performWithDelay(self, function()
			self._canOutPokers = {}
			self:playPokerEffect(eventData.id)
			self:refreshRemainCardNum()
			if eventData.id == self._id then
				self:hideAllOpr()
			end
		end, 0.8)
	else
		self._canOutPokers = {}
		self:playPokerEffect(eventData.id)
		self:refreshRemainCardNum()
		if eventData.id == self._id then
			self:hideAllOpr()
		end
	end
end

-- 炸弹更新
function SDUI:onBombNumUpdateHandler(eventData)
	self:refreshBombNum()
end

function SDUI:onBaoJingHandler(eventData)
	self:showAlert(eventData.id)
end

function SDUI:onRoundAccountHandler(eventData)
	local accountData = eventData.accountData
	local isWin = nil
	self:stopCountDown()
	for __, data in ipairs(accountData.player_result_list) do
		if data.player_id == self._id then
			if data.score_change > 0 then
				isWin = true
			elseif data.score_change < 0 then
				isWin = false
			end
			break
		end
	end
	-- 弹出结算界面
	local function openAccountUI()
		EventBus:dispatchEvent(EventEnum.openUI, {uiName = "SDRAccountUI", parms = {accountData}})
	end
	local function showNotOutPokers()
		local notOutCardsList = {}
		-- 清掉河里的牌
		for __, roundResult in ipairs(accountData.player_result_list) do
			notOutCardsList[roundResult.player_id] = roundResult.not_discarded_list
		end
		for __, playerView in pairs(self._playerViewById) do
			if playerView._id ~= self._id then
				if playerView._pokers and #playerView._pokers > 0 then
					local totalNum = #playerView._pokers
					local iniPos = self:calFirstPokerPos(playerView._cliSeatId, 1)
					local notOutCards = notOutCardsList[playerView._id]
					for ind, poker in ipairs(playerView._pokers) do
						local midPos = cc.p(iniPos.x, iniPos.y)
						local desPos = cc.p(iniPos.x, iniPos.y)
						local line = math.ceil(ind / 10)
						local row = (ind - 1) % 10
						local curMaxNum = 0
						if totalNum <= 10 then
							curMaxNum = totalNum
						else
							if line == 1 then
								curMaxNum = 10
							else
								midPos.y = iniPos.y - 50
								desPos.y = iniPos.y - 50
								curMaxNum = totalNum - 10
							end
						end
						if playerView._cliSeatId == 2 then
							desPos.x = midPos.x - (curMaxNum - row + 1) * 30
						elseif playerView._cliSeatId == 3 then
							desPos.x = midPos.x + row * 30
						end
						local mt1 = cc.MoveTo:create(0.1, midPos)
						local mt2 = cc.MoveTo:create(0.2, desPos)
						poker:runAction(cc.Sequence:create(mt1, mt2, cf))
						poker:initPoker(notOutCards[ind].num, notOutCards[ind].flower, POKER_STATE.POSITIVE)
					end
				end
			end
		end
		performWithDelay(self, openAccountUI, 1.0)
	end
	local isNeedShowNotOutPoker = false
	for __, playerView in pairs(self._playerViewById) do
		if #playerView._pokers > 0 and playerView._cliSeatId ~= 1 then
			self:clearRiverCardsById(playerView._cliSeatId)
		end
		if playerView._sprBuChu then
			playerView._sprBuChu:setVisible(false)
		end
		if playerView._pokers and #playerView._pokers > 0 then
			if playerView._id ~= self._id then
				isNeedShowNotOutPoker = true
			end
		end
	end
	if isNeedShowNotOutPoker then
		if accountData.is_spring then
			self:playSpringAni(self._id)
			performWithDelay(self, showNotOutPokers, 1.2)
		else
			performWithDelay(self, showNotOutPokers, 0.7)
		end
	else
		if accountData.is_spring then
			self:playSpringAni(self._id)
			performWithDelay(self, openAccountUI, 0.7)
		else
			performWithDelay(self, openAccountUI, 0.2)
		end
	end
	if nil ~= isWin then
		if isWin then
			AudioEngine:playEffect("res/audio/ddz_win.mp3")
		else
			AudioEngine:playEffect("res/audio/ddz_lose.mp3")
		end
		AudioEngine:pauseMusic()
	end
end

function SDUI:onExitRoundAccountHandler(eventData)
	if eventData.id == self._id then
		EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "SDRAccountUI"})
		self:hideAllOpr()
		self.panPokerLayer:setVisible(false)
		self:refreshBottomScore()
		self:refreshBombNum()
		self:clearCards()
		self:clearAllAlert()
	end
	self:resetAllPlayerScore()
	self:refreshPlayerState(eventData.id)
	AudioEngine:playEffect("res/audio/com_ready.mp3")
end

function SDUI:onNewPlayerHandler(eventData)
	self:insertPlayer(eventData.player)
end

function SDUI:onRoundUpdateHandler(eventData)
	self:refreshRound()
end

function SDUI:onActionPlayerChangeHandler()
	local delayTime = 0
	if self._isPlayBack then
		delayTime = 0.8
	end
	local function callback()
		local actionPlayerId = self._model:getActionPlayerId()
		local playerView = self._playerViewById[actionPlayerId]
		assert(nil ~= playerView, "玩家ID ======》》》》"..actionPlayerId)
		if playerView._sprBuChu then
			playerView._sprBuChu:setVisible(false)
		end
		for ind = #playerView._riverPokers, 1, -1 do
			playerView._riverPokers[ind]:setVisible(false)
			table.remove(playerView._riverPokers, ind)
		end
		self:startCountDown(10)
		if not self._isDispatchingPoker then
			self:refreshActionPlayer()
		end
	end
	performWithDelay(self, callback, delayTime)
end

function SDUI:onIsTippingChangeHandler(eventData)
	self:refreshPlayCardOpr(eventData.isTipping)
end

function SDUI:onPlayerExitRoom(eventData)
	self:removePlayer(eventData.id)
	if eventData.id == self._id then
		EventBus:dispatchEvent(EventEnum.exitSD)
	end
end

-- 聊天信息
function SDUI:onChatMsgHandler(eventData)
	local id = eventData.id
	local playerView = self._playerViewById[id]
	if nil == playerView then return end
	if ChatMsgType.TYPE_VOICE == eventData.msgType then
		if playerView._speakAni then
			playerView._speakAni:removeFromParent()
			playerView._speakAni = nil
		end
		local posOfView = cc.p(playerView:getPosition())
		local anchorPos = cc.p(playerView:getAnchorPoint())
		local sizeOfView = playerView:getContentSize()
		local pos = cc.p(0, 0)
		local aniPath = ""
		if posOfView.x > GL_SIZE.width / 2 then
			aniPath = "res/animation/speakanir.csb"
			pos.x = 0
			pos.y = sizeOfView.height / 2
		else
			aniPath = "res/animation/speakanil.csb"
			pos.x = sizeOfView.width
			pos.y = sizeOfView.height / 2
		end
		local speakAni = cc.CSLoader:createNode(aniPath)
		local action = cc.CSLoader:createTimeline(aniPath)
		speakAni:runAction(action)
		action:play("ani", true)
		self._layer:addChild(speakAni, 110)
		playerView._speakAni = speakAni
		speakAni:setPosition(playerView:convertToWorldSpace(pos))
		local delay = cc.DelayTime:create(15)
		local callfunc = cc.CallFunc:create(function()
				if playerView._speakAni then
					playerView._speakAni:removeFromParent()
					playerView._speakAni = nil
				end
			end)
		local seq = cc.Sequence:create(delay, callfunc)
		speakAni:runAction(seq)
	elseif ChatMsgType.TYPE_EMOTIONEFF == eventData.msgType then
		local formatMsg = string.format("return{%s}", eventData.strContent)
		local toInfo = loadstring(formatMsg)()
		local sPlayerView = self._playerViewById[eventData.id]
		local ePlayerView = self._playerViewById[toInfo.id]
		if sPlayerView ~= nil and ePlayerView ~= nil then
			local imgIcon1 = sPlayerView:getChildByName("imgIconBg"):getChildByName("imgIcon")
			local imgIcon2 = ePlayerView:getChildByName("imgIconBg"):getChildByName("imgIcon")
			CommonFunc.runInteractiveEffect(self._layer, imgIcon1, imgIcon2, toInfo.emotionId)
		end
	end
end

function SDUI:onVoiceFinishPlayHandler(eventData)
	local id = eventData.id
	local playerView = self._playerViewById[id]
	if playerView._speakAni then
		playerView._speakAni:removeFromParent()
		playerView._speakAni = nil
	end
end

--------------------------- 数据层事件 E -------------------------

function SDUI:reEnter()
	self._period = nil
	for ind = #self._frameListeners, 1, -1 do
		local listener = self._frameListeners[ind]
		if nil ~= listener then
			table.remove(self._frameListeners, ind)
		end
	end
	self._frameListeners = {}
	self:initAllSeats()
	self:refreshView()
	self:clearChoosePokers()
	self:initPeriod()
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "SDRAccountUI"})
end

function SDUI:onReLoginHandler()
	if not AccountController.getIsInRoom() then
		EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "SDUI"})
	end
end

return SDUI