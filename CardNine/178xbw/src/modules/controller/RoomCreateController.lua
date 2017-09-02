local RoomCreateController = {}

local PlayType = PlayType
local PerRoomCardToRound = PerRoomCardToRound
local PlayTypeToName = PlayTypeToName
local createFuncCnf = {
	[PlayType.TT_BULLFIGHT] = "createBullRoom",
--	[PlayType.TT_GOLDFLOWER] = "createFlowerRoom",
	[PlayType.TT_LANDLORD] = "createLandlordRoom",
	[PlayType.TT_SX_WK] = "createSXWaKeng",
	[PlayType.TT_LZ_WK] = "createLZWaKeng",
	[PlayType.TT_TEN_HALF] = "createTenHalf",
	[PlayType.TT_PUSH_PAIRS] = "createPushPairsRoom",
	[PlayType.TT_SX_SD] = "createSXSanDai",
}

function RoomCreateController.createRoomReq(playType, cnf, ...)
	RoomCreateController.getModel():updateChooseCnf(playType, cnf)
	-- 向服务器请求创建房间
	local funcName = createFuncCnf[playType]
	if funcName == nil then
		CommonFunc.showCenterMsg("功能暂未开放")
	else
		RoomCreateController[funcName](cnf, ...)
	end
end

function RoomCreateController.createBullRoom(cnf, boAgent)
	local tabData = {
		round = cnf.round,
		pay_way = cnf.payWay,
		has_flower_card = cnf.hasFlowerCard,
		three_card = false,
		forbid_enter = cnf.forbidEnter,
		has_whn = cnf.hasWhn,
		has_zdn = cnf.hasZdn,
		has_wxn = cnf.hasWxn,
		double_type = cnf.doubleType,
		tongbi_score = cnf.fixScore,
		banker_type = cnf.bankerType,
		gps = AccountController.getGps(),
		has_push_chip = cnf.isXianJiaTuiZhu,
		forbid_cuopai = cnf.isForbidCuoPai,
		qiang_score_limit = cnf.qiangScoreLimit,
		is_auto = cnf.isAuto,
		is_agent_room = false,
		score_type = cnf.scoreType
	}
	if boAgent then
		tabData.is_agent_room = true
	end
	NetCom:send(11001, tabData)
end

function RoomCreateController.createFlowerRoom(cnf)
	local tabData = {
		cost_room_card_num = cnf.costRoomCardNum,
		first_see_poker = cnf.firstSeePoker,
		see_poker_cuopai = cnf.canRubCard,
		forbid_enter = cnf.forbidEnter,
		has_xiqian = cnf.hasXiQian,
		p235_big_baozi = cnf.p235BigBaoZi,
		p235_big_aaa = cnf.p235BigAAA,
		score_type = cnf.stakeType,
		gps = AccountController.getGps(),
	}
	NetCom:send(11010, tabData)
end

function RoomCreateController.createLandlordRoom(cnf)
	local tabData = {
		cost_room_card_num = cnf.costRoomCardNum,
		bomb_top = cnf.multiple,
		show_poker_num = cnf.showPokerNum,
		record_poker = cnf.showPokerCounter,
		player_num = cnf.playerLimit,
		call_dizhu = cnf.callPaiChoose,
		gps = AccountController.getGps(),
		let_card = cnf.latCard,
	}
	if cnf.playerLimit == 2 and cnf.latCard then
		tabData.let_card = false
	end
	NetCom:send(11011, tabData)
end

function RoomCreateController.createSXWaKeng(cnf)
	local tabData = {
		cost_room_card_num = cnf.costRoomCardNum,
		call_dizhu = cnf.heiWa,
		is_can_bomb = cnf.isCanBomb,
		put_off_poker = cnf.isCastPoker,
		bomb_top = cnf.bombTop,
		gps = AccountController.getGps(),
	}
	NetCom:send(11012, tabData)
end

function RoomCreateController.createLZWaKeng(cnf)
	local tabData = {
		cost_room_card_num = cnf.costRoomCardNum,
		is_can_bomb = cnf.isCanBomb,
		air_bomb_multiple = cnf.isKongBombMultiple,
		put_off_poker = cnf.isCastPoker,
		bomb_top = cnf.bombTop,
		gps = AccountController.getGps(),
	}
	NetCom:send(11013, tabData)
end

function RoomCreateController.createTenHalf(cnf)
	local tabData = {
		cost_room_card_num = cnf.costRoomCardNum,
		is_specail_play = cnf.isSpecailPlay,
		max_chip = cnf.maxChip,
		banker_type = cnf.bankerType,
		gps = AccountController.getGps(),
	}
	NetCom:send(11014, tabData)
end

function RoomCreateController.createPushPairsRoom(cnf)
	local tabData = {
		cost_room_card_num = cnf.costRoomCardNum,
		zhuang_type = cnf.zhuangType,
		score_type = cnf.scoreType,
		is_red_half = cnf.isRedHalf,
		nine_double = cnf.nineDouble,
		xian_double = cnf.xianDouble,
		zhuang_double = cnf.zhuangDouble,
		is_one_red = cnf.isOneRed,
		is_river = cnf.isRiver,
		gps = AccountController.getGps(),
	}
	NetCom:send(11015, tabData)
end

function RoomCreateController.createSXSanDai(cnf)
	local tabData = {
		cost_room_card_num = cnf.costRoomCardNum,
		is_card_num = cnf.isCardNum or false,
		score_type = cnf.scoreType,
		three_take = cnf.threeTake,
		force_card = cnf.forceCard or false,
		has_aircraft = cnf.hasAircraft or false,
		pan_force1 = cnf.force1 or false,
		pan_force2 = cnf.force2 or false,
		pan_force3 = cnf.force3 or false,
		pan_force4 = cnf.force4 or false,
		pan_force5 = cnf.force5 or false,
		gps = AccountController.getGps(),
	}
	if tabData.force_card then
		tabData.pan_force1 = false
		tabData.pan_force2 = false
		tabData.pan_force3 = false
		tabData.pan_force4 = false
		tabData.pan_force5 = false
	end
	NetCom:send(11019, tabData)
end

function RoomCreateController.getModel()
	return PlayerManager:getModel("RoomCreate")
end

function RoomCreateController.getLastPlayType()
	return RoomCreateController.getModel():getLastPlayType()
end

function RoomCreateController.getPlayTypeCnf(playType)
	return RoomCreateController.getModel():getPlayTypeCnf(playType)
end

function RoomCreateController.getPlayTypeName(playType)
	return PlayTypeToName[playType]
end

function RoomCreateController.getRoundNum(playType, roomCard)
	return PerRoomCardToRound[playType] * roomCard
end

function RoomCreateController.getPlayTypeDatas()
	local playTypeDatas = {}
	local isXbw = AccountController.getIsXbw()
	for __, playType in pairs(PlayType) do
		playTypeDatas[#playTypeDatas + 1] = {
			playType = playType,
			playName = PlayTypeToName[playType],
		}
	end
	if not isXbw then
		local ind = 1
		for index = 1, 7 do
			if playTypeDatas[ind] and playTypeDatas[ind].playType ~= PlayType.TT_BULLFIGHT then
				table.remove(playTypeDatas, ind)
			else
				ind = ind + 1
			end
		end
	end
	table.sort(playTypeDatas, function(playTypeDataA, playTypeDataB)
			return playTypeDataA.playType < playTypeDataB.playType
		end)
	return playTypeDatas
end

function RoomCreateController.checkRoomId(roomId)
	CommonFunc.showCenterMsg(string.format("通过后端检查房间号(%d)是否存在", roomId))
end

function RoomCreateController.enterRoomReq(roomId)
	local tabData = {
		room_id = roomId,
		gps = AccountController.getGps(),
	}
	local isXbw = AccountController.getIsXbw()
	if isXbw then
		tabData.is_xbw = true
	end
	NetCom:send(11000, tabData)
end

function RoomCreateController.getRoomCardToRound(playType, roomCard)
	local perCardToRound = PerRoomCardToRound[playType]
	local strRet = string.format("%d局(房卡x%d张)", perCardToRound * roomCard, roomCard)
	return strRet
end

cc.exports.RoomCreateController = RoomCreateController