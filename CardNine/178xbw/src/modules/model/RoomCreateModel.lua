local RoomCreateModel = class("RoomCreateModel", BaseModel)

local saveFileName = "roomCreate"
local typeToMemberName = {
	[PlayType.TT_BULLFIGHT] = "_bullCnf",
--	[PlayType.TT_GOLDFLOWER] = "_goldFlowerCnf",
	[PlayType.TT_LANDLORD] = "_landlordCnf",
	[PlayType.TT_SX_WK]	= "_sxwkCnf",
	[PlayType.TT_LZ_WK]	= "_lzwkCnf",
	[PlayType.TT_TEN_HALF] = "_tenhalfCnf",
	[PlayType.TT_PUSH_PAIRS] = "_pushpairsCnf",
	[PlayType.TT_SX_SD] = "_sxsdCnf",
}

function RoomCreateModel:init()
	local roomCreateCnf = CommonFunc.loadDataFromFile(saveFileName) or {}
	self._bullCnf = roomCreateCnf.bullCnf or {}
	self._goldFlowerCnf = roomCreateCnf.goldFlowerCnf or {}
	self._landlordCnf = roomCreateCnf.landlordCnf or {}
	self._sxwkCnf = roomCreateCnf.sxwkCnf or {}
	self._lzwkCnf = roomCreateCnf.lzwkCnf or {}
	self._tenhalfCnf = roomCreateCnf.tenHalfCnf or {}
	self._pushpairsCnf = roomCreateCnf.pushPairsCnf or {}
	self._sxsdCnf = roomCreateCnf.sxsdCnf or {}
	self._lastPlayType = roomCreateCnf.lastPlayType or PlayType.TT_BULLFIGHT
	self:initBullCnf()
	self:initGoldFlowerCnf()
	self:initLandlordCnf()
	self:initSXWKCnf()
	self:initLZWKCnf()
	self:initTenHalfCnf()
	self:initPushPairsCnf()
	self:initSXSDCnf()
end

-- 牛牛
function RoomCreateModel:initBullCnf()
	local bullCnf = self._bullCnf
	-- 局数(1 = 10局，2 = 20局)
	bullCnf.round = bullCnf.round or 1
	-- 房费支付方式(1 = 房主支付，2 = AA支付)
	bullCnf.payWay = bullCnf.payWay or 1
	-- 有无花牌
	if nil == bullCnf.hasFlowerCard then
		bullCnf.hasFlowerCard = true
	end
	-- 固定底分(1/2/4/6分)
	bullCnf.fixScore = bullCnf.fixScore or 1
	-- 开始后禁止加入
	if nil == bullCnf.forbidEnter then
		bullCnf.forbidEnter = true
	end
	-- 翻倍规则(1 = "有牛番"，2 = "牛牛X3牛九X2牛八X2"， 3 = "牛牛X4牛九X3牛八X2牛七X2")
	bullCnf.doubleType = bullCnf.doubleType or 1
	-- 有五花牛
	if nil == bullCnf.hasWhn then
		bullCnf.hasWhn = false
	end
	-- 有炸弹牛
	if nil == bullCnf.hasZdn then
		bullCnf.hasZdn = false
	end
	-- 有五小牛
	if nil == bullCnf.hasWxn then
		bullCnf.hasWxn = false
	end
	-- 坐庄类型(1 = 房主坐庄，2 = 轮流坐庄，3 = 经典抢庄，4 = 翻四张抢庄, 5 = 牛牛上庄，6 = 通比牛牛)
	bullCnf.bankerType = bullCnf.bankerType or 1
	if 4 == bullCnf.bankerType then
		if bullCnf.doubleType == 1 then
			bullCnf.doubleType = 2
		end
	end
	-- 闲家推注
	if nil == bullCnf.isXianJiaTuiZhu then
		bullCnf.isXianJiaTuiZhu = false
	end
	-- 禁止搓牌
	if nil == bullCnf.isForbidCuoPai then
		bullCnf.isForbidCuoPai = false
	end
	-- 明牌抢庄倍数限制
	bullCnf.qiangScoreLimit = bullCnf.qiangScoreLimit or 2
	-- 是否自动
	if nil == bullCnf.isAuto then
		bullCnf.isAuto = false
	end
	-- 底分类型（1=1/2, 2=2/4, 3=4/8, 4=自由分）
	bullCnf.scoreType = bullCnf.scoreType or 1
end

-- 金花
function RoomCreateModel:initGoldFlowerCnf()
	local goldFlowerCnf = self._goldFlowerCnf
	-- 消耗房卡数
	goldFlowerCnf.costRoomCardNum = goldFlowerCnf.costRoomCardNum or 1
	-- 首轮不能看牌
	if nil == goldFlowerCnf.firstSeePoker then
		goldFlowerCnf.firstSeePoker = false
	end
	-- 看牌可搓牌
	if nil == goldFlowerCnf.canRubCard then
		goldFlowerCnf.canRubCard = false
	end
	-- 开始后禁止加入
	if nil == goldFlowerCnf.forbidEnter then
		goldFlowerCnf.forbidEnter = false
	end
	-- 类型（1 = 1分场，2 = 2分场，3 = 5分场，4 = 自由场）
	goldFlowerCnf.stakeType = goldFlowerCnf.stakeType or GOLDFLOWER_SCORE_TYPE.TYPE_ONE
	-- 特殊牌型有喜钱
	if nil == goldFlowerCnf.hasXiQian then
		goldFlowerCnf.hasXiQian = false
	end
	-- 235大于豹子
	if nil == goldFlowerCnf.p235BigBaoZi then
		goldFlowerCnf.p235BigBaoZi = true
	end
	-- 235大于AAA
	if nil == goldFlowerCnf.p235BigAAA then
		goldFlowerCnf.p235BigAAA = false
	end
end

-- 斗地主
function RoomCreateModel:initLandlordCnf()
	local landlordCnf = self._landlordCnf
	-- 消耗房卡数
	landlordCnf.costRoomCardNum = landlordCnf.costRoomCardNum or 1
	-- 倍数上限选择(1 = 16倍，2 = 32倍，3 = 64倍，4 = 不限倍数)
	landlordCnf.multiple = landlordCnf.multiple or LANDLORD_MULTIPLE_TYPE.TYPE_16
	-- 显示牌数
	if nil == landlordCnf.showPokerNum then
		landlordCnf.showPokerNum = true
	end
	-- 使用记牌器
	if nil == landlordCnf.showPokerCounter then
		landlordCnf.showPokerCounter = false
	end
	-- 人数限制（1 = 两人玩法，2 = 三人玩法）
	landlordCnf.playerLimit = landlordCnf.playerLimit or 1
	-- (1 = 赢家先叫，2 = 轮流叫地主)
	landlordCnf.callPaiChoose = landlordCnf.callPaiChoose or 1
	if nil == landlordCnf.latCard then
		landlordCnf.latCard = false
	end
end

-- 陕西
function RoomCreateModel:initSXWKCnf()
	local sxwkCnf = self._sxwkCnf
	-- 消耗房卡数
	sxwkCnf.costRoomCardNum = sxwkCnf.costRoomCardNum or 1
	-- 黑挖(1 = 叫分， 2 = 黑挖)
	sxwkCnf.heiWa = sxwkCnf.heiWa or 1
	-- 带炸弹
	if nil == sxwkCnf.isCanBomb then
		sxwkCnf.isCanBomb = false
	end
	-- 去掉一张3、一张2、4张A
	if nil == sxwkCnf.isCastPoker then
		sxwkCnf.isCastPoker = false
	end
	-- 炸弹上限(1 = 3炸，2 = 不限炸弹次数)
	sxwkCnf.bombTop = sxwkCnf.bombTop or 1
end

-- 兰州
function RoomCreateModel:initLZWKCnf()
	local lzwkCnf = self._lzwkCnf
	-- 消耗房卡数
	lzwkCnf.costRoomCardNum = lzwkCnf.costRoomCardNum or 1	
	-- 带炸弹(1 = 不带炸弹，2 = 带炸弹)
	if nil == lzwkCnf.isCanBomb then
		lzwkCnf.isCanBomb = false
	end
	-- 空炸不加倍
	if nil == lzwkCnf.isKongBombMultiple then
		lzwkCnf.isKongBombMultiple = false
	end
	-- 去掉一张3、一张2、4张A
	if nil == lzwkCnf.isCastPoker then
		lzwkCnf.isCastPoker = false
	end
	-- 炸弹上限(1 = 3炸，2 = 不限炸弹次数)
	lzwkCnf.bombTop = lzwkCnf.bombTop or 1
end

-- 十点半
function RoomCreateModel:initTenHalfCnf()
	local tenHalfCnf = self._tenhalfCnf
	tenHalfCnf.costRoomCardNum = tenHalfCnf.costRoomCardNum or 1
	if nil == tenHalfCnf.isSpecailPlay then
		tenHalfCnf.isSpecailPlay = true
	end
	tenHalfCnf.maxChip = tenHalfCnf.maxChip or 5
	tenHalfCnf.bankerType = tenHalfCnf.bankerType or 1
end

-- 推对子
function RoomCreateModel:initPushPairsCnf()
	local pushPairsCnf = self._pushpairsCnf
	pushPairsCnf.costRoomCardNum = pushPairsCnf.costRoomCardNum or 1
	pushPairsCnf.zhuangType = pushPairsCnf.zhuangType or 1
	pushPairsCnf.scoreType = pushPairsCnf.scoreType or 1
	if nil == pushPairsCnf.isRedHalf then
		pushPairsCnf.isRedHalf = true
	end
	if nil == pushPairsCnf.nineDouble then
		pushPairsCnf.nineDouble = false
	end	
	if nil == pushPairsCnf.xianDouble then
		pushPairsCnf.xianDouble = false
	end	
	if nil == pushPairsCnf.zhuangDouble then
		pushPairsCnf.zhuangDouble = false
	end	
	if nil == pushPairsCnf.isOneRed then
		pushPairsCnf.isOneRed = false
	end
	if nil == pushPairsCnf.isRiver then
		pushPairsCnf.isRiver = false
	end
end

-- 陕西三代
function RoomCreateModel:initSXSDCnf()
	local sxsdCnf = self._sxsdCnf
	sxsdCnf.costRoomCardNum = sxsdCnf.costRoomCardNum or 1
	if nil == sxsdCnf.isCardNum then
		sxsdCnf.isCardNum = true
	end
	sxsdCnf.threeTake = sxsdCnf.threeTake or 2
	sxsdCnf.scoreType = sxsdCnf.scoreType or 3
	if nil == sxsdCnf.forceCard then
		sxsdCnf.forceCard = false
	end
	if nil == sxsdCnf.hasAircraft then
		sxsdCnf.hasAircraft = true
	end
	for ind = 1, 5 do
		if nil == sxsdCnf["panForce"..ind] then
			sxsdCnf["panForce"..ind] = false
		end
	end
end

-- 更新玩法选择
function RoomCreateModel:updateChooseCnf(playType, cnf)
	self[typeToMemberName[playType]] = cnf
	self._lastPlayType = playType
	self:saveCnf()
end

-- 获取房间配置
function RoomCreateModel:getPlayTypeCnf(playType)
	return self[typeToMemberName[playType]]
end

-- 获取上次玩法
function RoomCreateModel:getLastPlayType()
	return self._lastPlayType
end

-- 保存配置
function RoomCreateModel:saveCnf()
	local cnf = {}
	cnf.bullCnf = self._bullCnf
	cnf.goldFlowerCnf = self._goldFlowerCnf
	cnf.landlordCnf = self._landlordCnf
	cnf.sxwkCnf = self._sxwkCnf
	cnf.lzwkCnf = self._lzwkCnf
	cnf.tenHalfCnf = self._tenhalfCnf
	cnf.pushPairsCnf = self._pushpairsCnf
	cnf.sxsdCnf = self._sxsdCnf
	cnf.lastPlayType = self._lastPlayType
	CommonFunc.saveDataToFile(saveFileName, cnf)
end

return RoomCreateModel