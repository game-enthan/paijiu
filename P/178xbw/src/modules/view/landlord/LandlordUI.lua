local PlaybackBaseUI = require("lib/PlaybackBaseUI")
local LandlordUI = class("LandlordUI", PlaybackBaseUI)

local Poker = require("modules/view/common/DDZPoker")
local PokerSize = PokerSize
local maxPaiDuiNum = 54
local paiDuiIniPos = cc.p((GL_SIZE.width - 5 * (maxPaiDuiNum - 1)) / 2, GL_SIZE.height - 220)
local iniPokerScale = 0.5
local myPokerScale = 1
local myDis = 55
local otherPokerScale = 0.4
local otherDis = 10
local myRiverDis = 40
local otherRiverDis = 35
local myRiverScale = 0.75
local otherRiverScale = 0.55


LandlordUI._widgetsCnf = {
	{"imgBg"},
	{"seat", len = 3, visible = false},
	{"labPlayTip"},{"panPokerLayer"},
	{"imgClock", visible = false, children = {{"textAtlasTime"}}},
	{"btnDisband", click = "onDisbandClickHandler"},
	{"btnVoice"},
	{"btnChat", click = "onChatClickHandler"},
	{"btnSet", click = "onSetClickHandler"},
	{"btnShare", click = "onShareClickHandler"},
	{"panRoomInfo", children = {
		{"labRoomId"},{"labTime"},
		{"labBaseScore"},{"labMultiple"},
		{"labFarmerWinNum"},
		{"labRound"},
	}},
	{"panQiangDiZhu", children = {
		{"btnBuQiang", click = "onBuQiangClickHandler"},
		{"btnQiang", click = "onQiangClickHandler"},
	}},
	{"panCallScore", children = {
		{"btnBuJiao", click = "onBuJiaoClickHandler"},
		{"btnOneScore", click = "onOneScoreClickHandler"},
		{"btnTwoScore", click = "onTwoScoreClickHandler"},
		{"btnThreeScore", click = "onThreeScoreClickHandler"},
	}},
	{"panOprPai", children = {
		{"btnBuChu", click = "onBuChuClickHandler"},
		{"btnTiShi", click = "onTiShiClickHandler"},
		{"btnOut", click = "onOutClickHandler"},
	}},
	{"panEatTouch", visible = false},
	{"imgCannotPlay", visible = false},
}

function LandlordUI:ctor()
	PlaybackBaseUI.ctor(self, "res/LandlordUI")
	self:init()
end

function LandlordUI:init()
	self:listenEvents()
	self:initData()
	self:initView()
end

function LandlordUI:listenEvents()
	self:listenEvent(EventEnum.landlordPlayerOnline, "onPlayerOnlineHandler")
	self:listenEvent(EventEnum.landlordPeriod, "onPeriodChangeHandler")
	self:listenEvent(EventEnum.landlordPlayerCallDiZhu, "onCallDiZhuHandler")
	self:listenEvent(EventEnum.landlordQureyDiZhu, "onQureyDiZhuHandler")
	self:listenEvent(EventEnum.landlordPlayCard, "onPlayCardHandler")
	self:listenEvent(EventEnum.landlordMultipleUpdate, "onMultipleUpdateHandler")
	self:listenEvent(EventEnum.landlordBaoJing, "onBaoJingHandler")
	self:listenEvent(EventEnum.landlordRoundAccount, "onRoundAccountHandler")
	self:listenEvent(EventEnum.landlordExitRoundAccount, "onExitRoundAccountHandler")
	self:listenEvent(EventEnum.landlordNewPlayer, "onNewPlayerHandler")
	self:listenEvent(EventEnum.landlordRoundUpdate, "onRoundUpdateHandler")
	self:listenEvent(EventEnum.landlordActionPlayer, "onActionPlayerChangeHandler")
	self:listenEvent(EventEnum.landlordFarmerWinPokerNum, "onFarmerWinPokerNumHandler")
	self:listenEvent(EventEnum.exitRoom, "onPlayerExitRoom")
	self:listenEvent(EventEnum.chatMsg, "onChatMsgHandler")
	self:listenEvent(EventEnum.voiceFinishPlay, "onVoiceFinishPlayHandler")
end

function LandlordUI:initData()
	self._controller = LandlordController
	self._model = self._controller.getModel()
	self._isPlayBack = self._model:getIsPlayBack()
	self._maxPlayerNum = PlayerNumCnf[PlayType.TT_LANDLORD]
	self._id = AccountController.getPlayerId()
	self._countDown = nil
	self._frameListeners = {}
	self._paiDui = {}
	self._diZhuPai = {}
	self._playerViewByCliSeatId = {}
	self._playerViewById = {}
	self._period = nil
	self._waitAccountEffect = false
end

function LandlordUI:initView()
	self:initTouchLayer()
	self:initAllSeats()
	self.btnChat:setVisible(not self._isPlayBack)
	self.btnVoice:setVisible(not self._isPlayBack)
	self.btnVoice:addTouchEventListener(handler(self, self.onBtnVoiceEventHandler))
end

-- 初始化触摸层
function LandlordUI:initTouchLayer()
	if nil == self._touchLayer then
		local layer = cc.Layer:create()
		self.panPokerLayer:addChild(layer)
		layer:setTouchEnabled(not self._isPlayBack)
		layer:registerScriptTouchHandler(handler(self, self.onTouchEvent))
		self._touchLayer = layer
	end
	self._touchLayer:setVisible(false)
end

-- 初始化所有座位信息
function LandlordUI:initAllSeats()
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

function LandlordUI:onEnter()
	PlaybackBaseUI.onEnter(self)
	self:startSchedule()
	self:startTimer(handler(self, self.second), 1)
	self:openTanMuUI()
	self:refreshView()
	AudioEngine:playEffect("res/audio/com_ready.mp3")
end

function LandlordUI:onExit()
	PlaybackBaseUI.onExit(self)
end

-- 每帧调用
function LandlordUI:update(dt)
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
function LandlordUI:second(dt)
	self:refreshTime()
	self:refreshCountDown()
end

function LandlordUI:insertFrameListener(callback, cnt, boStartNow)
	if boStartNow then
		callback()
		cnt = cnt - 1
	end
	self._frameListeners[#self._frameListeners + 1] = {callback = callback, cnt = cnt}
end

function LandlordUI:openTanMuUI()
	if self._isPlayBack then return end
	self._tanMuUI = require("modules/view/common/TanMuUI").new(PlayType.TT_LANDLORD)
	self:addChild(self._tanMuUI)
	self._tanMuUI:setGlobalZOrder(50)
end

function LandlordUI:refreshView()
	self:refreshRoomId()
	self:refreshRound()
	self:refreshBottomScore()
	self:refreshMultiple()
	self:refreshPlayType()
	self:refreshFarmerWinPokerNum()
	self:clearCards()
	self:initPeriod()
	self:refreshAllPlayerState()
end

--------------------------- 牌局状态 S --------------------------------
-- 初始化牌局阶段
function LandlordUI:initPeriod()
	local period = self._model:getRoundPeriod()
	if self._period == period then return end
	self:hideAllOpr()
	local funcName = LANDLORD_PERIOD_INI_FUNC[period]
	assert(funcName, "ileagel period----------->>"..period)
	self[funcName](self)
	self._period = period
	self:refreshRemainCardNum()
end

-- 切换牌局阶段
function LandlordUI:switchPeriod(period)
	if self._period and self._period == period then return end
	local funcName = LANDLORD_PERIOD_SWITCH_FUNC[period]
	assert(funcName, "ileagel period----------->>"..period)
	self[funcName](self)
	self._period = period
	self:refreshRemainCardNum()
end

-- 初始化等待阶段
function LandlordUI:initWaitPeriod()
	self.panPokerLayer:setVisible(false)
	self.btnShare:setVisible(true)
	self:clearDiZhuEffect()
	self:clearAllCallDiZhuEffect()
end

-- 跳转到等待阶段
function LandlordUI:switchToWaitPeriod()
end

-- 初始化开始阶段
function LandlordUI:initStartPeriod()
end

-- 跳转到开始阶段
function LandlordUI:switchToStartPeriod()
	self:hideAllOpr()
	self:clearCards()
	self.panPokerLayer:setVisible(false)
	self:clearDiZhuEffect()
	self:clearAllCallDiZhuEffect()
	self._touchLayer:setVisible(false)
	self:refreshLandlordPokers()
	self:refreshAllPlayerState()
end

-- 初始化叫地主阶段
function LandlordUI:initCallPeriod()
	self:hideAllOpr()
	self:dispatchPokerWithOutEffect()
	self._touchLayer:setVisible(false)
	self:startCountDown(10)
	self:refreshActionPlayer()
end

-- 跳转到叫分阶段
function LandlordUI:switchToCallPeriod()
	self:hideAllOpr()
	self._touchLayer:setVisible(false)
	local function callback()
		self:refreshActionPlayer()
		self:startCountDown(10)
	end
	self:dispatchPokerWithEffect(callback)
end

-- 初始化打牌阶段
function LandlordUI:initPlayPeriod()
	self:hideAllOpr()
	self:dispatchPokerWithOutEffect()
	self._touchLayer:setVisible(true and not self._isPlayBack)
	self:runQureyDiZhuEffect(false)
	self:initRiverCards()
	self:startCountDown(10)
	self:refreshLandlordPokers()
	self:refreshActionPlayer()
	self:initAlert()
end

-- 跳转到打牌阶段
function LandlordUI:switchToPlayPeriod()
	self:hideAllOpr()
	self._touchLayer:setVisible(true and not self._isPlayBack)
	self:clearChoosePokers()
	self:runQureyDiZhuEffect(true)
	self:refreshActionPlayer()
end

-- 初始化结算阶段
function LandlordUI:initAccountPeriod()
	self:hideAllOpr()
	self._touchLayer:setVisible(false)
	self:stopCountDown()
end

-- 跳转到结算阶段
function LandlordUI:switchToAccountPeriod()
	self:hideAllOpr()
	self._touchLayer:setVisible(false)
	self:stopCountDown()
end

-- 隐藏所有操作
function LandlordUI:hideAllOpr()
	self.imgClock:setVisible(false)
	self.btnShare:setVisible(false)
	self.panEatTouch:setVisible(false)
	self.panOprPai:setVisible(false)
	self.panQiangDiZhu:setVisible(false)
	self.panCallScore:setVisible(false)
end
--------------------------- 牌局状态 S --------------------------------
-- 刷新座位信息
function LandlordUI:refreshSeatInfo(seat, player)
	if nil ~= player then
		local imgIconBg = seat:getChildByName("imgIconBg")
		local imgIcon = seat:getChildByName("imgIconBg"):getChildByName("imgIcon")
		local panName = seat:getChildByName("panName")
		local labName = panName:getChildByName("labName")
		local labScore = seat:getChildByName("labScore")
		local sprLandlord = seat:getChildByName("sprLandlord")
		local labCardNum = seat:getChildByName("labCardNum")
		CommonFunc.setIcon(imgIcon, player.icon)
		sprLandlord:setVisible(false)
		labName:setString(player.name)
		labScore:setString(string.format("%d", player.score))
		labCardNum:setVisible(false)
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
function LandlordUI:resetAllPlayerScore()
	for __, playerView in pairs(self._playerViewById) do
		local labScore = playerView:getChildByName("labScore")
		labScore:setString(string.format("%d", playerView._player.score))
	end
end

-- 更新时间
function LandlordUI:refreshTime()
	self.labTime:setString(Time.getFormat2Time())
end

-- 时钟倒计时
function LandlordUI:refreshCountDown()
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

-- 刷新房号
function LandlordUI:refreshRoomId()
	self.labRoomId:setString(string.format("房号：%d", self._model:getRoomId()))
end

-- 刷新局数
function LandlordUI:refreshRound()
	local round, maxRound = self._model:getRound()
	self.labRound:setString(string.format("第（%d/%d）局", round, maxRound))
end

-- 刷新底分
function LandlordUI:refreshBottomScore()
	self.labBaseScore:setString(string.format("底分：%d", self._model:getBaseScore()))
end

-- 刷新倍数
function LandlordUI:refreshMultiple()
	self.labMultiple:setString(string.format("倍数：%d", self._model:getMultiple()))
end

-- 刷新让几张牌
function LandlordUI:refreshFarmerWinPokerNum()
	local farmerWinPokerNum = self._model:getFarmerWinPokerNum()
	local isLetCard = self._model:getLetCard()
	self.labFarmerWinNum:setString(string.format("让牌：%d", farmerWinPokerNum))
	self.labFarmerWinNum:setVisible(isLetCard)
end

-- 刷新玩法Tip
function LandlordUI:refreshPlayType()
	self.labPlayTip:setString(self._model:getPlayTypeDes())
end

-- 刷新地主牌显示
function LandlordUI:refreshLandlordPokers()
	self.panRoomInfo._pokers = self.panRoomInfo._pokers or {}
	local diZhuPokers = self._model:getLandlordPokers()
	local posOfRoomPan = cc.p(self.panRoomInfo:getPosition())
	local sizeOfRoomPan = self.panRoomInfo:getContentSize()
	local anchorOfPan = cc.p(self.panRoomInfo:getAnchorPoint())
	local posY = sizeOfRoomPan.height / 2
	local scale = 0.4
	for ind = 1, 3 do
		local poker = self.panRoomInfo._pokers[ind]
		if nil == poker then
			local posX = 165 +  PokerSize.width * scale / 2 + (ind - 1) * (PokerSize.width + 10) * scale
			poker = Poker.new()
			self.panRoomInfo._pokers[ind] = poker
			self.panRoomInfo:addChild(poker)
			poker:setPosition(cc.p(posX, posY))
			poker:setScale(scale)
		end
		poker:setVisible(false)
		local pokerInfo = diZhuPokers[ind]
		if pokerInfo then
			poker:initPoker(pokerInfo.num, pokerInfo.flower, POKER_STATE.POSITIVE)
			poker:setVisible(true)
		end
	end
end

-- 刷新所有玩家状态
function LandlordUI:refreshAllPlayerState()
	for __, playerView in pairs(self._playerViewById) do
		self:refreshPlayerState(playerView._id)
	end
end

-- 刷新单个玩家状态
function LandlordUI:refreshPlayerState(id)
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

-- 刷新抢地主操作
function LandlordUI:refreshQiangDiZhuOpr()
	local playerLimit = self._model:getPlayerLimit()
	local preCallDiZhuId, preCallScore = self._model:getPreCallDiZhuInfo()
	if 1 == playerLimit then
		local isCanQiang = self._model:getIsCanQiang()
		self.panQiangDiZhu:setVisible(self._model:getIsCanQiang())
		self.panCallScore:setVisible(false)
		local preCallDiZhuId = self._model:getPreCallDiZhuInfo()
		if 0 == preCallDiZhuId then
			self.btnQiang:getChildByName("btnName"):setString("叫地主")
			self.btnBuQiang:getChildByName("btnName"):setString("不 叫")
		else
			self.btnQiang:getChildByName("btnName"):setString("抢地主")
			self.btnBuQiang:getChildByName("btnName"):setString("不 抢")
		end
	elseif 2 == playerLimit then
		local isCanQiang = self._model:getIsCanQiang()
		self.panCallScore:setVisible(isCanQiang)
		self.panQiangDiZhu:setVisible(false)
		if isCanQiang then
			if preCallScore < 1 then
				CommonFunc.enableBtn(self.btnOneScore)
			else
				CommonFunc.disableBtn(self.btnOneScore)
			end
			if preCallScore < 2 then
				CommonFunc.enableBtn(self.btnTwoScore)
			else
				CommonFunc.disableBtn(self.btnTwoScore)
			end
			if preCallScore < 3 then
				CommonFunc.enableBtn(self.btnThreeScore)
			else
				CommonFunc.disableBtn(self.btnThreeScore)
			end
		end
	end
end

-- 重置操作按钮位置
function LandlordUI:resetOprBtnPos()
	local sizeOfPan = self.panOprPai:getContentSize()
	local sizeOfBtn = self.btnTiShi:getContentSize()
	self.btnTiShi:setPositionX(sizeOfPan.width / 2)
	self.btnBuChu:setPositionX(sizeOfBtn.width / 2)
	self.btnOut:setPositionX(sizeOfPan.width - sizeOfBtn.width / 2)
end

-- 刷新出牌操作
function LandlordUI:refreshPlayCardOpr(isNeedNewTiShi)
	local isCanPlayPoker = self._model:getIsCanPlayPoker()
	self.panOprPai:setVisible(isCanPlayPoker)
	self.imgCannotPlay:setVisible(false)
	if isCanPlayPoker then
		local pan = self.panOprPai
		local prePlayedId = self._model:getPrePlayPlayerId()
		self.btnTiShi:setVisible(true)
		self.btnOut:setVisible(true)
		self.btnBuChu:setVisible(true)
		-- 上次自己打的牌没人管就不再提示
		if prePlayedId == self._id or prePlayedId == 0 then
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
				local choosePokerStyle = LandlordController.getPokerStyle(pokerDatas)
				if choosePokerStyle == LANDLORT_STYLE.CT_ERROR then
					CommonFunc.disableBtn(self.btnOut)
				else
					CommonFunc.enableBtn(self.btnOut)
				end
			end
			CommonFunc.disableBtn(self.btnTiShi)
			CommonFunc.disableBtn(self.btnBuChu)
			self:resetOprBtnPos()
			self.imgCannotPlay:setVisible(false)
		else
			if self:getIsCanPlay() then
				if isNeedNewTiShi then
					self:getIntellegentPokers(true)
					self._tiShiIndex = 0					
				end
				CommonFunc.enableBtn(self.btnBuChu)
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
					if LandlordController.compareCard(prePlayedPokers, pokerDatas) then
						CommonFunc.enableBtn(self.btnOut)
					else
						CommonFunc.disableBtn(self.btnOut)
					end
				end
				self:resetOprBtnPos()
			else
				self.btnTiShi:setVisible(false)
				self.btnOut:setVisible(false)
				self.btnBuChu:setVisible(true)
				self.imgCannotPlay:setVisible(true)
				local sizeOfPan = self.panOprPai:getContentSize()
				self.btnBuChu:setPositionX(sizeOfPan.width / 2)
				CommonFunc.enableBtn(self.btnBuChu)
			end
		end
	end
end

-- 刷新当前可操作玩家
function LandlordUI:refreshActionPlayer()
	local actionPlayerId = self._model:getActionPlayerId()
	self._qiangDiZhuArr = self._qiangDiZhuArr or {}
	self:clearCallDiZhuEffectById(actionPlayerId)
	self:refreshQiangDiZhuOpr()
	self:refreshPlayCardOpr(true)
end

-- 刷新玩家手牌数
function LandlordUI:refreshRemainCardNum()
	local period = self._model:getRoundPeriod()
	local boNeedShow = period ~= LANDLORD_PERIOD_WAIT and period ~= LANDLORD_PERIOD_START
	boNeedShow = boNeedShow and self._model:getIsShowPokerNum()
	for __, playerView in pairs(self._playerViewById) do
		local labCardNum = playerView:getChildByName("labCardNum")
		if boNeedShow then
			labCardNum:setVisible(true)
			local remainNum = self._model:getRemainPokerNum(playerView._id)
			labCardNum:setString(string.format("剩余：%d", remainNum))
		else
			labCardNum:setVisible(false)
		end
	end
end

-- 玩家加入房间
function LandlordUI:insertPlayer(player)
	local cliSeatId = player.cliSeatId
	local seat = self["seat"..cliSeatId]
	assert(seat._player == nil, "该位置上已经有人坐了") 
	seat:setVisible(true)
	self:refreshSeatInfo(seat, player)
	AudioEngine:playEffect("res/audio/com_ready.mp3")
end

-- 玩家退出房间
function LandlordUI:removePlayer(id)
	local seat = self._playerViewById[id]
	self:refreshSeatInfo(seat, nil)
end

-- 计算闹钟的位子
function LandlordUI:getClockPos(cliSeatId)
	local pos = cc.p(0, 0)
	if 1 == cliSeatId then
		pos.x = GL_SIZE.width / 2
		pos.y = 390
	elseif 2 == cliSeatId then
		pos.x = GL_SIZE.width - 260
		pos.y = GL_SIZE.height * 2 / 3
	elseif 3 == cliSeatId then
		pos.x = 260
		pos.y = GL_SIZE.height * 2 / 3
	end
	return pos
end

-- 开始倒计时
function LandlordUI:startCountDown(cnt)
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
function LandlordUI:stopCountDown()
	self._countDown = nil
	self.imgClock:setVisible(false)
end

-- 获取游戏中的玩家
function LandlordUI:getInPlayingPlayers()
	local playerViews = {}
	for __, playerView in pairs(self._playerViewById) do
		playerViews[#playerViews + 1] = playerView
	end
	table.sort(playerViews, function(a, b)
			return a._cliSeatId < b._cliSeatId
		end)
	return playerViews
end

-- 清空玩家手牌和地主牌和河里的牌
function LandlordUI:clearCards()
	for __, playerView in pairs(self._playerViewById) do
		playerView._pokers = {}
		self:clearRiverCardsById(playerView._cliSeatId)
		if playerView._sprBuChu then
			playerView._sprBuChu:setVisible(false)
		end
	end
	self._diZhuPai = {}
end

-- 清空玩家河里的牌
function LandlordUI:clearRiverCardsById(cliSeatId)
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
function LandlordUI:dispatchPokerWithEffect(callback)
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
			poker:initPoker(POKER_ENUM.POKER_NIL, POKER_TYPE.TYPE_NIL, POKER_STATE.NEGATIVE)
		end
	end
	local pokerIndex = 1
	local function createPokerByFrame()
		for ind = 1, 6 do
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
	self:insertFrameListener(createPokerByFrame, maxPaiDuiNum / 6, true)
end

-- 发牌不带特效
function LandlordUI:dispatchPokerWithOutEffect()
	self.panPokerLayer:setVisible(true)
	for __, poker in ipairs(self._paiDui) do
		poker:stopCurAction()
		poker:setVisible(false)
		poker:initPoker(POKER_ENUM.POKER_NIL, POKER_TYPE.TYPE_NIL, POKER_STATE.NEGATIVE)
	end
	local inPlayingPlayerList = self:getInPlayingPlayers()
	local playerNum = #inPlayingPlayerList
	local isShowPokerNum = self._model:getIsShowPokerNum()
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
		poker:initPoker(pokerKind, pokerType, POKER_STATE.POSITIVE, self._model:getIsDiZhu(self._id))
		poker:setVisible(true)
		myPlayerView._pokers[#myPlayerView._pokers + 1] = poker
		cnt = cnt + 1
	end
	-- 初始化其他玩家的手牌
	local isShowPokerNum = self._model:getIsShowPokerNum()
	for __, playerView in ipairs(inPlayingPlayerList) do
		if playerView._id ~= self._id then
			if isShowPokerNum then
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
			else
				local poker = self._paiDui[cnt]
				if nil == poker then
					poker = Poker.new()
					self.panPokerLayer:addChild(poker)
					self._paiDui[#self._paiDui + 1] = poker
				end
				local iniPos = self:calFirstPokerPos(playerView._cliSeatId, 0)
				poker:setOpacity(255)
				poker:setPosition(iniPos)
				poker:setLocalZOrder(1)
				poker:setScale(otherPokerScale)
				poker:setVisible(true)
				playerView._pokers[#playerView._pokers + 1] = poker
				cnt = cnt + 1
			end
		end
	end
	-- 初始化河里的地主牌
	local period = self._model:getRoundPeriod()
	if period == LANDLORD_PERIOD_CALL then
		local iniDiZhuX = GL_SIZE.width / 2 - 30
		for ind = 1, 3 do
			local poker = self._paiDui[cnt]
			if nil == poker then
				poker = Poker.new()
				self.panPokerLayer:addChild(poker)
				self._paiDui[#self._paiDui + 1] = poker
			end
			local pX = iniDiZhuX + (ind - 1) * 30
			self._diZhuPai[#self._diZhuPai + 1] = poker
			poker:setOpacity(255)
			poker:setPosition(cc.p(pX, paiDuiIniPos.y))
			poker:setLocalZOrder(ind)
			poker:setScale(iniPokerScale)
			poker:setVisible(true)
			cnt = cnt + 1
		end
	end
end

-- 发地主牌
function LandlordUI:dispatchBottomCards()
	self.panEatTouch:setVisible(true)
	local diZhuId = self._model:getDiZhuId()
	local playerView = self._playerViewById[diZhuId]
	if diZhuId == 0 then return end
	local pokerDatas = self._model:getLandlordPokers()
	for ind, poker in ipairs(self._diZhuPai) do
		local pokerData = pokerDatas[ind]
		poker:initPoker(pokerData.num, pokerData.flower, POKER_STATE.NEGATIVE)
		poker:turnPoker()
		playerView._pokers[#playerView._pokers + 1] = poker
	end
	local function tidyPokers()
		if diZhuId == self._id then
			local myPokerDatas = self._model:getMyPokers()
			local pokerIndToPosArr = {}
			for ind, pokerData in ipairs(myPokerDatas) do
				pokerIndToPosArr[pokerData.num] = pokerIndToPosArr[pokerData.num] or {}
				pokerIndToPosArr[pokerData.num][pokerData.flower] = ind
			end
			local iniPos = self:calFirstPokerPos(1, #myPokerDatas)
			for ind, poker in ipairs(playerView._pokers) do
				local pokerKind = poker:getPokerKind()
				local pokerType = poker:getPokerType()
				local index = pokerIndToPosArr[pokerKind][pokerType]
				local desPos = cc.p(iniPos.x, iniPos.y)
				desPos.x = desPos.x + myDis * (index - 1)
				if ind > #playerView._pokers - 3 then
					desPos.y = desPos.y + 20
				end
				poker:setLocalZOrder(index)
				local moveTo = cc.MoveTo:create(0.2, desPos)
				local scaleTo = cc.ScaleTo:create(0.2, myPokerScale)
				local spa = cc.Spawn:create(moveTo, scaleTo)
				if ind > #playerView._pokers - 3 then
					local delayTime = cc.DelayTime:create(1.0)
					local moveTo1 = cc.MoveTo:create(0.1, cc.p(desPos.x, iniPos.y))
					local seq = cc.Sequence:create(spa, delayTime, moveTo1)
					poker:runAction(seq)
				else
					poker:runAction(spa)
				end
			end
			table.sort(playerView._pokers, function(pokerA, pokerB)
					local indexA = getPokerIndex(pokerA:getPokerKind(), pokerA:getPokerType())
					local indexB = getPokerIndex(pokerB:getPokerKind(), pokerB:getPokerType())
					return indexA > indexB
				end)
			pokerIndToPosArr = nil
		else
			local isShowPokerNum = self._model:getIsShowPokerNum()
			if isShowPokerNum then
				local totalNum = #playerView._pokers
				local iniPos = self:calFirstPokerPos(playerView._cliSeatId, 0)
				local sIndex = totalNum - #self._diZhuPai
				for ind, poker in ipairs(self._diZhuPai) do
					local desPos = cc.p(iniPos.x, iniPos.y)
					desPos.y = desPos.y - (sIndex + ind - 1) * otherDis
					local moveTo = cc.MoveTo:create(0.2, desPos)
					local scaleTo = cc.ScaleTo:create(0.2, otherPokerScale)
					local callfunc = cc.CallFunc:create(function()
						poker:initPoker(POKER_ENUM.POKER_NIL, POKER_TYPE.TYPE_NIL, POKER_STATE.NEGATIVE)
					end)
					poker:runAction(cc.Spawn:create(moveTo, scaleTo, callfunc))
					poker:setLocalZOrder(totalNum + ind)
				end
			else
				local totalNum = #playerView._pokers
				for ind, poker in ipairs(self._diZhuPai) do
					local iniPos = self:calFirstPokerPos(playerView._cliSeatId, 0)
					local moveTo = cc.MoveTo:create(0.2, iniPos)
					local scaleTo = cc.ScaleTo:create(0.2, otherPokerScale)
					local callfunc = cc.CallFunc:create(function()
						poker:initPoker(POKER_ENUM.POKER_NIL, POKER_TYPE.TYPE_NIL, POKER_STATE.NEGATIVE)
					end)
					poker:runAction(cc.Spawn:create(moveTo, scaleTo, callfunc))
					poker:setLocalZOrder(totalNum + ind)
				end
			end
		end
		-- 清空地主牌
		self._diZhuPai = {}
	end
	performWithDelay(self, tidyPokers, 0.5)
	performWithDelay(self, function()
			self.panEatTouch:setVisible(false)
			self:startCountDown(10)
			self:refreshLandlordPokers()
			for __, poker in ipairs(playerView._pokers) do
				poker:setDiZhuFlag(true)
			end
		end, 0.75)
end

-- 开始发牌
function LandlordUI:startDispatchPoker(callback)
	local inPlayingPlayerList = self:getInPlayingPlayers()
	local playerNum = #inPlayingPlayerList
	local isShowPokerNum = self._model:getIsShowPokerNum()
	for index = 1, 17 do
		for ind = 1, playerNum do
			local cnt = (index - 1) * playerNum + ind
			local paiDuiInd = maxPaiDuiNum - cnt + 1
			local poker = self._paiDui[paiDuiInd]
			local playerView = inPlayingPlayerList[ind]
			local playerId = playerView._player.id
			local cliSeatId = playerView._cliSeatId
			local iniPos = self:calFirstPokerPos(cliSeatId, 17)
			-- AudioEngine:playEffect("res/audio/com_dispatchpoker2.mp3")
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
				local moveTo = cc.MoveTo:create(0.1, desPos)
				local scaleTo = cc.ScaleTo:create(0.1, scale)
				local delayTime = cc.DelayTime:create((index - 1) * 0.08)
				local callfunc = cc.CallFunc:create(function()
						AudioEngine:playEffect("res/audio/com_dispatchpoker1.mp3")
						poker:setLocalZOrder(index)
						if playerId == self._id then
							local pokerKind, pokerType = self._model:getPokerByIdAndIndex(self._id, index)
							poker:initPoker(pokerKind, pokerType, POKER_STATE.NEGATIVE, self._model:getIsDiZhu(self._id))
							poker:turnPoker()
						end
						if cnt == playerNum * 17 then
							local count = 1
							local iniDiZhuX = GL_SIZE.width / 2 - 30
							for i = maxPaiDuiNum - cnt, 1, -1 do
								local tempPoker = self._paiDui[i]
								if nil ~= tempPoker then
									if count <= 3 then
										self._diZhuPai[#self._diZhuPai + 1] = tempPoker
										local pX = iniDiZhuX + (3 - count) * 30
										local m1 = cc.MoveTo:create(0.1, cc.p(pX, paiDuiIniPos.y))
										tempPoker:runAction(m1)
									else
										tempPoker:setCascadeOpacityEnabled(true)
										local fadeOut = cc.FadeOut:create(0.2)
										tempPoker:runAction(fadeOut)
									end
								end
								count = count + 1
							end
							performWithDelay(self, function()
									if callback then callback() end
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

function LandlordUI:calFirstPokerPos(cliSeatId, totalPokerNum)
	local playerView = self._playerViewByCliSeatId[cliSeatId]
	local anchorOfView = cc.p(0.5, 0.5)
	local pos = cc.p(0, 0)
	local posOfView = playerView._pos
	local sizeOfView = playerView._size
	if 1 == cliSeatId then
		pos.x = pos.x + GL_SIZE.width / 2 - (totalPokerNum - 1) * myDis / 2
		pos.y = PokerSize.height * myPokerScale / 2
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
---------------------------- 抢地主效果 S ------------------------
function LandlordUI:runCallDiZhuEffect(callDiZhuInfo)
	local id = callDiZhuInfo.id
	local score = callDiZhuInfo.score
	local preId = callDiZhuInfo.preId
	local preScore = callDiZhuInfo.preScore
	local isCallDiZhuFirst = callDiZhuInfo.isCallDiZhuFirst
	local playerView = self._playerViewById[id]
	local cliSeatId = playerView._cliSeatId
	self._qiangDiZhuArr = self._qiangDiZhuArr or {}
	local spr = self._qiangDiZhuArr[cliSeatId]
	if nil == spr then
		spr = cc.Sprite:create()
		self._layer:addChild(spr)
		spr:setAnchorPoint(cc.p(0.5, 0.5))
		spr:setPosition(self:calOprRetPos(id))
		self._qiangDiZhuArr[cliSeatId] = spr
	end
	local url = "res/landlord/landlord_bujiao.png"
	local audioName = "bujiao"
	if self._model:getPlayerLimit() == 1 then
		if score ~= 0 then
			if isCallDiZhuFirst then
				url = "res/landlord/landlord_calldizhu.png"
				audioName = "jiaodizhu"
			else
				url = "res/landlord/landlord_qiangdizhu.png"
				audioName = "qiangdizhu"
			end
		end
	else
		if score ~= 0 then
			url = string.format("res/landlord/landlord_%dscore.png", score)
			audioName = tostring(score).."fen"
		end
	end
	if preScore ~= 0 and score == 0 then
		url = "res/landlord/landlord_buqiang.png"
		audioName = "buqiang"
	end
	spr:setTexture(url)
	spr:setVisible(true)
	spr:setOpacity(0)
	spr:setScale(3.0)
	local fadeIn = cc.FadeIn:create(0.1)
	local scaleTo = cc.ScaleTo:create(0.1, 1.0)
	local easeSineIn = cc.EaseSineIn:create(scaleTo)
	local easeBounceOut = cc.EaseBounceOut:create(easeSineIn)
	local spa = cc.Spawn:create(fadeIn, easeBounceOut)
	spr:runAction(spa)
	local sex = playerView._player.sex
	local url = "res/audio/effect/%s_%s.mp3"
	url = string.format(url, sex == 0 and "w" or "m", audioName)
	AudioEngine:playEffect(url, false)
	self:stopCountDown()
end

function LandlordUI:clearAllCallDiZhuEffect()
	self._qiangDiZhuArr = self._qiangDiZhuArr or {}
	for __, spr in pairs(self._qiangDiZhuArr) do
		spr:setVisible(false)
	end
end

function LandlordUI:clearCallDiZhuEffectById(id)
	local playerView = self._playerViewById[id]
	local cliSeatId = playerView._cliSeatId
	local spr = self._qiangDiZhuArr[cliSeatId]
	if nil ~= spr then
		spr:setVisible(false)
	end
end

function LandlordUI:runQureyDiZhuEffect(isDispatchDiZhuCard)
	local diZhuId = self._model:getDiZhuId()
	-- 分发地主牌
	if isDispatchDiZhuCard then
		self:dispatchBottomCards()
		self:refreshRemainCardNum()
	end
	for __, playerView in pairs(self._playerViewById) do
		local sprLandlord = playerView:getChildByName("sprLandlord")
		sprLandlord:setVisible(playerView._id == diZhuId)
	end
	self:clearAllCallDiZhuEffect()
end

function LandlordUI:clearDiZhuEffect()
	for __, playerView in pairs(self._playerViewById) do
		local sprLandlord = playerView:getChildByName("sprLandlord")
		sprLandlord:stopAllActions()
		sprLandlord:setVisible(false)
	end
end
---------------------------- 抢地主效果 E ------------------------
---------------------------- 打牌效果 S --------------------------
function LandlordUI:calOprRetPos(id)
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
		pos.x = posXOfView - sizeOfView.width * (1- anchorOfView.x) - PokerSize.width * otherPokerScale - 40
		pos.y = GL_SIZE.height - 200
	elseif 3 == cliSeatId then
		pos.x = posXOfView + sizeOfView.width * anchorOfView.x + 40 + PokerSize.width * otherPokerScale
		pos.y = GL_SIZE.height - 200
	end
	return pos
end

function LandlordUI:calFirstRiverPos(id, num)
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

function LandlordUI:playCardEffect(id)
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
			if self._model:getIsShowPokerNum() then
				local sIndex = #playerView._pokers - #prePlayedPokers + 1
				for ind, pokerData in ipairs(prePlayedPokers) do
					local desPos = cc.p(iniPos.x, iniPos.y)
					desPos.x = desPos.x  + otherRiverDis * (ind - 1)
					local poker = playerView._pokers[sIndex]
					poker:initPoker(pokerData.num, pokerData.flower, POKER_STATE.POSITIVE, self._model:getIsDiZhu(id))
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
			else
				local remainCardNum = self._model:getRemainPokerNum(id)
				local sPos = self:calFirstPokerPos(playerView._cliSeatId, 0)
				for ind, pokerData in ipairs(prePlayedPokers) do
					local poker
					if remainCardNum == 0 and ind == 1 then
						poker = playerView._pokers[ind]
					else
						local index = math.max(#playerView._pokers, 2)
						poker = playerView._pokers[index]
						if nil == poker then
							poker = Poker.new()
							poker:setPosition(sPos)
							self.panPokerLayer:addChild(poker)
							self._paiDui[#self._paiDui + 1] = poker
						else
							table.remove(playerView._pokers, index)
						end
					end
					poker:setLocalZOrder(100)
					poker:initPoker(pokerData.num, pokerData.flower, POKER_STATE.POSITIVE, self._model:getIsDiZhu(id))
					playerView._riverPokers[#playerView._riverPokers + 1] = poker
					local desPos = cc.p(iniPos.x, iniPos.y)
					desPos.x = desPos.x  + otherRiverDis * (ind - 1)
					local scaleTo = cc.ScaleTo:create(0.05, 0.8)
					local moveTo = cc.MoveTo:create(0.05, desPos)
					local spa = cc.Spawn:create(moveTo, scaleTo)
					local scaleTo1 = cc.ScaleTo:create(0.2, scale)
					local easeElaticOut = cc.EaseElasticOut:create(scaleTo1)
					local callfunc = cc.CallFunc:create(function()
							poker:setLocalZOrder(ind)
						end)
					local seq = cc.Sequence:create(spa, easeElaticOut, callfunc)
					poker:runAction(seq)
					if remainCardNum == 0 then
						for __, poker in ipairs(playerView._pokers) do
							poker:setVisible(false)
						end
						playerView._pokers = {}
					end
				end
			end
		end
		AudioEngine:playEffect("res/audio/com_playcard.mp3", false)
		local cliSeatId = playerView._cliSeatId
		local pokerStyle = LandlordController.getPokerStyle(prePlayedPokers)
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
		local url = "res/audio/effect/%s_pass%d.mp3"
		url = string.format(url, sex == 0 and "w" or "m", math.random(1, 3))
		AudioEngine:playEffect(url, false)
	end
	self:stopCountDown()
end

function LandlordUI:initRiverCards()
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
				poker = Poker.new(pokerData.num, pokerData.flower, POKER_STATE.POSITIVE, self._model:getIsDiZhu(prePlayedId))
				self.panPokerLayer:addChild(poker)
				self._paiDui[#self._paiDui + 1] = poker
				playerView._riverPokers[#playerView._riverPokers + 1] = poker
			end
			poker:setDiZhuFlag(self._model:getIsDiZhu(prePlayedId))
			poker:setPosition(desPos)
			poker:setLocalZOrder(ind)
			poker:setScale(scale)
		end
	end
end
---------------------------- 打牌效果 E --------------------------
---------------------------- 牌型效果 S --------------------------
function LandlordUI:runPokerStyleEffect(id, style, pokers)
	if style == LANDLORT_STYLE.CT_ROCKET then
		self:playRocketAni(id)
		AudioEngine:playEffect("res/audio/effect/aircraft.mp3", false)
	elseif style == LANDLORT_STYLE.CT_BOMB then
		self:playBombAni(id)
		AudioEngine:playEffect("res/audio/effect/bomb.mp3", false)
	elseif style ==  LANDLORT_STYLE.CT_THREE_LINE or
		style ==  LANDLORT_STYLE.CT_THREE_LINE_TAKE_SINGLE or
		style ==  LANDLORT_STYLE.CT_THREE_LINE_TAKE_DOUBLE then
		self:playFeiJiAni(id)
	elseif style == LANDLORT_STYLE.CT_SINGLE_LINE then
		self:playStraightAni(id)
	elseif style == LANDLORT_STYLE.CT_DOUBLE_LINE then
		self:playPairsAni(id)
	end
	if #pokers >= 1 then
		local player = self._model:getPlayerById(id)
		LANDLORD_PLAY_AUDIO(player.sex, style, pokers[1].num)
	end
end

-- 炸弹
function LandlordUI:playBombAni(id)
	local pos = cc.p(GL_SIZE.width / 2, GL_SIZE.height / 2 + 150)
	local ani = cc.CSLoader:createNode("res/animation/bomb.csb")
	local action = cc.CSLoader:createTimeline("res/animation/bomb.csb")
	ani:runAction(action)
	action:play("bomb", false)
	self._layer:addChild(ani, 100)
	ani:setPosition(pos)
	local delayTime = cc.DelayTime:create(1.0)
	local reomveSelf = cc.RemoveSelf:create()
	ani:runAction(cc.Sequence:create(delayTime, reomveSelf))
end

-- 火箭
function LandlordUI:playRocketAni(id)
	local pos = cc.p(GL_SIZE.width / 2, -200)
	local ani = cc.CSLoader:createNode("res/animation/rocket.csb")
	local action = cc.CSLoader:createTimeline("res/animation/rocket.csb")
	ani:runAction(action)
	action:play("rocket", true)
	self._layer:addChild(ani, 100)
	ani:setPosition(pos)
	local moveTo1 = cc.MoveTo:create(0.5, cc.p(GL_SIZE.width / 2, GL_SIZE.height / 2))
	local moveTo2 = cc.MoveTo:create(0.3, cc.p(GL_SIZE.width / 2, GL_SIZE.height + 300))
	local easeSineOut = cc.EaseSineIn:create(moveTo1)
	local delayTime = cc.DelayTime:create(0.5)
	local easeSineIn = cc.EaseSineIn:create(moveTo2)
	local reomveSelf = cc.RemoveSelf:create()
	ani:runAction(cc.Sequence:create(easeSineOut, delayTime, easeSineIn, reomveSelf))
end

-- 春天
function LandlordUI:playSpringAni(playerId)
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
	AudioEngine:playEffect("res/audio/effect/spring.mp3", false)
end

-- 飞机
function LandlordUI:playFeiJiAni(id)
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

-- 连对
function LandlordUI:playPairsAni(id)
	local pos = cc.p(GL_SIZE.width / 2, 0)
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

-- 顺子
function LandlordUI:playStraightAni(id)
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
function LandlordUI:showAlert(id)
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

function LandlordUI:initAlert()
	for id, playerView in pairs(self._playerViewById) do
		if id ~= self._id and playerView._player.isAlert then
			self:showAlert(id)
		end
	end
end

function LandlordUI:clearAllAlert()
	for __, playerView in pairs(self._playerViewById) do
		if playerView._alertEffect then
			playerView._alertEffect:setVisible(false)
		end
	end
end
--------------------------- 显示报警效果 E -----------------------
---------------------------- 选牌 S ------------------------------
function LandlordUI:choosePokers(pokerList)
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
----------------------------- UI事件 S ---------------------------
-- 点击玩家头像
function LandlordUI:onIconClickHandler(cliSeatId)
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

-- 解散
function LandlordUI:onDisbandClickHandler()
	if self._isPlayBack then
		EventBus:dispatchEvent(EventEnum.exitLandlord)
		AudioEngine:resumeMusic()
	else
		local period = self._model:getRoundPeriod()
		local roomOwnerId = self._model:getRoomOwnerId()
		local strContent = "确认解散房间？"
		if LANDLORD_PERIOD_WAIT == period then
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
function LandlordUI:onSetClickHandler()
	EventBus:dispatchEvent(EventEnum.openUI, {uiName = "SettingUI"})
end

-- 播放录音动画
function LandlordUI:playRecordAni(boRun)
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
function LandlordUI:onBtnVoiceEventHandler(sender, eventType)
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

-- 聊天
function LandlordUI:onChatClickHandler()
	ChatController.openChatUI(PlayType.TT_LANDLORD)
	-- local prePlayedPokers = {
	-- 	{num = 6, flower = 1},
	-- 	{num = 6, flower = 2},
	-- 	{num = 6, flower = 3},
	-- 	{num = 6, flower = 3},
	-- }
	-- local pokerStyle = LandlordController.getPokerStyle(prePlayedPokers)
	-- self:runPokerStyleEffect(10285, pokerStyle, {{num = 6, flower = 1}})
end

-- 分享
function LandlordUI:onShareClickHandler()
	local strTitle = string.format("[178西北玩] 房号:%d", self._model:getRoomId())
	local strContent = string.format("斗地主<%s>一起来玩吧！", self._model:getPlayTypeDes())
	local url = string.format(GAME_URL, tostring(AccountController.getPlayerId()), os.date("%m%d%H", os.time()))
	wxShare(strTitle, strContent, url, "0")
end

-- 不抢
function LandlordUI:onBuQiangClickHandler()
	LandlordController.callDiZhuReq(0)
end

-- 抢地主
function LandlordUI:onQiangClickHandler()
	LandlordController.callDiZhuReq(1)
end

-- 不叫
function LandlordUI:onBuJiaoClickHandler()
	LandlordController.callDiZhuReq(0)
end

-- 叫1分
function LandlordUI:onOneScoreClickHandler()
	LandlordController.callDiZhuReq(1)
end

-- 叫2分
function LandlordUI:onTwoScoreClickHandler()
	LandlordController.callDiZhuReq(2)
end

-- 叫3分
function LandlordUI:onThreeScoreClickHandler()
	LandlordController.callDiZhuReq(3)
end

-- 不出
function LandlordUI:onBuChuClickHandler()
	LandlordController.playPokerReq({})
	self:clearChoosePokers()
end

-- 是否有牌大于上家
function LandlordUI:getIsCanPlay()
	local boRet = false
	local canOutPokers = {}
	local prePlayedId = self._model:getPrePlayPlayerId()
	local prePlayedPokers = self._model:getPrePlayedPokers()
	local handPokers = self._model:getMyPokers()
	if prePlayedId ~= self._id and #prePlayedPokers > 0 then
		canOutPokers = LandlordController.intelligentOutPokers(handPokers, prePlayedPokers)
	end
	if #canOutPokers >= 1 then
		boRet = true
	end
	return boRet
end

function LandlordUI:getIntellegentPokers(boNew)
	local pokers = {}
	self._tiShiIndex = self._tiShiIndex or 0
	if boNew then
		self._canOutPokers = {}
		local prePlayedId = self._model:getPrePlayPlayerId()
		local prePlayedPokers = self._model:getPrePlayedPokers()
		local handPokers = self._model:getMyPokers()
		if prePlayedId ~= self._id and #prePlayedPokers > 0 then
			self._canOutPokers = LandlordController.intelligentOutPokers(handPokers, prePlayedPokers)
			self._tiShiIndex = 0
		else
			self._canOutPokers = {}
			self._tiShiIndex = 0
		end
	end
	if self._canOutPokers and #self._canOutPokers >= 1 then
		self._tiShiIndex = self._tiShiIndex + 1 > #self._canOutPokers and 1 or self._tiShiIndex + 1
		pokers = self._canOutPokers[self._tiShiIndex] or {}
	end
	return pokers
end

-- 智能提示
function LandlordUI:intelligentPokers(boNew)
	self:clearChoosePokers()
	self:choosePokers(self:getIntellegentPokers(boNew))
end


-- 提示
function LandlordUI:onTiShiClickHandler()
	local prePlayedPokers = self._model:getPrePlayedPokers()
	if #prePlayedPokers > 0 then
		self:intelligentPokers(false)
		self:refreshPlayCardOpr()
	end
end

-- 出牌
function LandlordUI:onOutClickHandler()
	local pokerList = {}
	if self._choosedPokers == nil or #self._choosedPokers < 1 then
		CommonFunc.showCenterMsg("未选中任何牌")
		return
	end
	for __, poker in ipairs(self._choosedPokers) do
		pokerList[#pokerList + 1] = {
			num = poker:getPokerKind(),
			flower = poker:getPokerType(),
		}
	end
	LandlordController.playPokerReq(pokerList)
end

function LandlordUI:refreshChoosedPokers()
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

function LandlordUI:checkTouchCard(poker, gX, gY)
	local posOfPoker = cc.p(poker:getPosition())
	local boundingBox = poker:getBoundingBox()
	local ret = false
	if cc.rectContainsPoint(boundingBox, cc.p(gX, gY)) then
		ret = true
	end
	return ret
end

function LandlordUI:refreshTouchedPokers(sIndex, eIndex)
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

function LandlordUI:getTouchedPokerIndex(gX, gY)
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

-- 重置所有手中的牌
function LandlordUI:clearChoosePokers()
	local playerView = self._playerViewById[self._id]
	local iniPos = self:calFirstPokerPos(1, #playerView._pokers)
	local playerView = self._playerViewById[self._id]
	for __, poker in ipairs(playerView._pokers) do
		poker:setPositionY(iniPos.y)
	end
	self._choosedPokers = {}
	self._sIndex = 0
	self._eIndex = 0
	self:refreshPlayCardOpr()
end

-- 触碰
function LandlordUI:onTouchEvent(eventType, x, y)
	if eventType == "began" then
		local period = self._model:getRoundPeriod()
		if period ~= LANDLORD_PERIOD_PLAY then return false end
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
----------------------------- UI事件 S ---------------------------
--------------------------- 数据层事件 S -------------------------
-- 上线
function LandlordUI:onPlayerOnlineHandler(eventData)
	self:refreshPlayerState(eventData.id)
end

-- 阶段变化
function LandlordUI:onPeriodChangeHandler(eventData)
	self:switchPeriod(eventData.period)
end

-- 玩家叫地主
function LandlordUI:onCallDiZhuHandler(eventData)
	if eventData.id == self._id then
		self.panCallScore:setVisible(false)
		self.panQiangDiZhu:setVisible(false)
	end
	self:runCallDiZhuEffect(eventData)
end

-- 确定地主
function LandlordUI:onQureyDiZhuHandler(eventData)
	self:refreshBottomScore()
end

-- 玩家出牌
function LandlordUI:onPlayCardHandler(eventData)
	self._canOutPokers = {}
	self:playCardEffect(eventData.id)
	self:refreshRemainCardNum()
	if eventData.id == self._id then
		self:hideAllOpr()
	end
end

-- 倍数更新
function LandlordUI:onMultipleUpdateHandler(eventData)
	self:refreshMultiple()
end

function LandlordUI:onBaoJingHandler(eventData)
	self:showAlert(eventData.id)
end

function LandlordUI:onRoundAccountHandler(eventData)
	local accountData = eventData.accountData
	local isWin = nil
	local minNotDiscardedNum = 15
	local finishPlayerId = 0
	self:stopCountDown()
	for __, data in ipairs(accountData.player_result_list) do
		if data.player_id == self._id then
			if data.score_change > 0 then
				isWin = true
			elseif data.score_change < 0 then
				isWin = false
			end
		end
		if data.score_change > 0 then
			local notDiscardList = data.not_discarded_list or {}
			local remainPokerNum = #notDiscardList
			if minNotDiscardedNum > remainPokerNum then
				finishPlayerId = data.player_id
				minNotDiscardedNum = math.min(minNotDiscardedNum, remainPokerNum)
			end
		end
	end
	-- 弹出结算界面
	local function openAccountUI()
		EventBus:dispatchEvent(EventEnum.openUI, {uiName = "LandlordRoundAccountUI", parms = {accountData}})
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
						poker:initPoker(notOutCards[ind].num, notOutCards[ind].flower, POKER_STATE.POSITIVE, self._model:getIsDiZhu(playerView._id))
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
	if nil ~= self._diZhuPai then
		for __, poker in ipairs(self._diZhuPai) do
			poker:setVisible(false)
		end
	end
	if isNeedShowNotOutPoker then
		if accountData.is_spring then
			self:playSpringAni(finishPlayerId)
			performWithDelay(self, showNotOutPokers, 1.2)
		else
			performWithDelay(self, showNotOutPokers, 0.7)
		end
	else
		if accountData.is_spring then
			self:playSpringAni(finishPlayerId)
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

function LandlordUI:onExitRoundAccountHandler(eventData)
	if eventData.id == self._id then
		EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LandlordRoundAccountUI"})
		self:hideAllOpr()
		self.panPokerLayer:setVisible(false)
		self:refreshBottomScore()
		self:refreshMultiple()
		self:clearCards()
		self:clearAllCallDiZhuEffect()
		self:clearDiZhuEffect()
		self:refreshFarmerWinPokerNum()
		self:clearAllAlert()
		self:refreshLandlordPokers()
		for __, playerView in pairs(self._playerViewById) do
			playerView:getChildByName("labCardNum"):setVisible(false)
		end
	end
	self:resetAllPlayerScore()
	self:refreshPlayerState(eventData.id)
	AudioEngine:playEffect("res/audio/com_ready.mp3")
end

function LandlordUI:onNewPlayerHandler(eventData)
	self:insertPlayer(eventData.player)
end

function LandlordUI:onRoundUpdateHandler(eventData)
	self:refreshRound()
end

-- 聊天信息
function LandlordUI:onChatMsgHandler(eventData)
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

function LandlordUI:onVoiceFinishPlayHandler(eventData)
	local id = eventData.id
	local playerView = self._playerViewById[id]
	if nil == playerView then return end
	if playerView._speakAni then
		playerView._speakAni:removeFromParent()
		playerView._speakAni = nil
	end
end

function LandlordUI:onActionPlayerChangeHandler()
	local actionPlayerId = self._model:getActionPlayerId()
	self:clearCallDiZhuEffectById(actionPlayerId)
	local playerView = self._playerViewById[actionPlayerId]
	if playerView._sprBuChu then
		playerView._sprBuChu:setVisible(false)
	end
	for ind = #playerView._riverPokers, 1, -1 do
		playerView._riverPokers[ind]:setVisible(false)
		table.remove(playerView._riverPokers, ind)
	end
	if not self._isDispatchingPoker then
		self:refreshActionPlayer()
		self:startCountDown(10)
	end
end

function LandlordUI:onFarmerWinPokerNumHandler()
	self:refreshFarmerWinPokerNum()
end

function LandlordUI:onPlayerExitRoom(eventData)
	self:removePlayer(eventData.id)
	if eventData.id == self._id then
		-- 退出斗地主
		EventBus:dispatchEvent(EventEnum.exitLandlord)
	end
end
--------------------------- 数据层事件 E -------------------------
function LandlordUI:reEnter()
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
end

function LandlordUI:onReLoginHandler()
	if not AccountController.getIsInRoom() then
		EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LandlordUI"})
	end
end

return LandlordUI