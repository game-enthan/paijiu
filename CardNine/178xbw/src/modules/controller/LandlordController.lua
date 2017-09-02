local LandlordController = {}

function LandlordController.getModel()
	return PlayerManager:getModel("Landlord")
end

------------------------- 永久监听事件 S -------------------------
-- 开始回放
function LandlordController.onStartPlayBack()
	LandlordController.getModel():updatePlayBackState(true)
end

-- 结束回放
function LandlordController.onEndPlayBack()
	LandlordController.getModel():updatePlayBackState(false)
end

-- 退出炸金花
function LandlordController.exitLandlord()
	-- 关闭金花相关界面(金花界面，金花结算界面，金花大结算界面)
	if nil == UIManager:getOpenedUI("HallUI") then
		EventBus:dispatchEvent(EventEnum.openUI, {uiName = "HallUI"})
	end
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LandlordUI"})
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LandlordRoundAccountUI"})
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LandlordFinalAccountUI"})
	LandlordController.getModel():reset()
end

function LandlordController.exitRoom(eventData)
	LandlordController.getModel():removePlayer(eventData.id)
end

function LandlordController.closeRoom(eventData)
	if nil ~= UIManager:getOpenedUI("LandlordUI") then
		local period = LandlordController.getModel():getRoundPeriod()
		if period == LANDLORD_PERIOD_WAIT then
			LandlordController.exitLandlord()
		end
	end
end

-- 观战玩家退出房间
EventBus:addEventListener(EventEnum.exitRoom, LandlordController.exitRoom)
-- 关闭房间
EventBus:addEventListener(EventEnum.closeRoom, LandlordController.closeRoom)
-- 回放开始
EventBus:addEventListener(EventEnum.startPlayBack, LandlordController.onStartPlayBack)
-- 结束回放
EventBus:addEventListener(EventEnum.endPlayBack, LandlordController.onEndPlayBack)
-- 退出炸金花
EventBus:addEventListener(EventEnum.exitLandlord, LandlordController.exitLandlord)
------------------------- 永久监听事件 E -------------------------
---------------------------- 网络接口 S --------------------------
-- 进入房间
function LandlordController.enterRoomRes(netData)
	LandlordController.getModel():reset()
	LandlordController.getModel():initRoomInfo(netData)
	if LandlordController.getModel():getIsPlayBack() then
		EventBus:dispatchEvent(EventEnum.openUI, {uiName = "LandlordUI"})
	else
		local landlordUI = UIManager:getOpenedUI("LandlordUI")
		if nil ~= landlordUI then
			landlordUI:reEnter()
		else
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LoginUI"})
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "JoinRoomUI"})
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "RoomCreateUI"})
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "HallUI"})
			EventBus:dispatchEvent(EventEnum.openUI, {uiName = "LandlordUI"})
		end
	end
end

-- 广播玩家在线状态
function LandlordController.notifyPlayerOnlineRes(netData)
	LandlordController.getModel():updatePlayerOnline(netData.player_id, netData.is_online)
	EventBus:dispatchEvent(EventEnum.landlordPlayerOnline, {id = netData.player_id})
end

-- 广播房间阶段变更
function LandlordController.notifyPeriodRes(netData)
	LandlordController.getModel():updateRoundPeriod(netData.state)
	EventBus:dispatchEvent(EventEnum.landlordPeriod, {period = netData.state})
end

-- 推送玩家扑克牌列表
function LandlordController.notifyPokerListRes(netData)
	LandlordController.getModel():updatePokerList(netData.poker_list)
end

-- 广播行动玩家变更
function LandlordController.notifyActionPlayerRes(netData)
	LandlordController.getModel():updateActionPlayer(netData.player_id)
	EventBus:dispatchEvent(EventEnum.landlordActionPlayer)
end

-- 请求叫地主
function LandlordController.callDiZhuReq(score)
	local tabMsg = {
		player_id = AccountController.getPlayerId(),
		result = score,
	}
	NetCom:send(16006, tabMsg)
end

-- 广播叫地主的选择
function LandlordController.notifyCallDiZhuRes(netData)
	local isCallDiZhuFirst = false
	local model = LandlordController.getModel()
	local preCallDiZhuId, preCallDiZhuScore = model:getPreCallDiZhuInfo()
	if netData.result ~= 0 then
		model:updatePreCallDiZhuInfo(netData.player_id, netData.result)
		if preCallDiZhuId == 0 then
			isCallDiZhuFirst = true
		end
	end
	local eventData = {
		id = netData.player_id,
		score = netData.result,
		preId = preCallDiZhuId,
		preScore = preCallDiZhuScore,
		isCallDiZhuFirst = isCallDiZhuFirst,
	}
	EventBus:dispatchEvent(EventEnum.landlordPlayerCallDiZhu, eventData)
end

-- 广播定地主结果
function LandlordController.notifyQureyDiZhuRes(netData)
	LandlordController.getModel():updateDiZhuId(netData.player_id)
	LandlordController.getModel():updateBaseScore(netData.result)
	-- 更新地主和分数TODO:
	EventBus:dispatchEvent(EventEnum.landlordQureyDiZhu)
end

-- 广播底牌
function LandlordController.notifyBottomPokersRes(netData)
	LandlordController.getModel():updateDiZhuPokers(netData.poker_list)
end

-- 玩家出牌操作
function LandlordController.playPokerReq(choosePokers)
	NetCom:send(16011, {poker_list = choosePokers})
end

-- 不出
function LandlordController.refusePlayCardReq()
	NetCom:send(16011, {poker_list = {}})
end

-- 广播玩家出牌
function LandlordController.notifyPlayPokerRes(netData)
	LandlordController.getModel():updatePrePlayPokers(netData.player_id, netData.poker_list or {})
	LandlordController.getModel():updatePlayerRemainCardNum(netData.player_id, netData.remain_num)
	EventBus:dispatchEvent(EventEnum.landlordPlayCard, {id = netData.player_id})
end

-- 广播倍数更新
function LandlordController.notifyMultipleUpdateRes(netData)
	LandlordController.getModel():updateMultiple(netData.num)
	EventBus:dispatchEvent(EventEnum.landlordMultipleUpdate, {num = netData.num})
end

-- 报警
function LandlordController.notifyBaoJingRes(netData)
	LandlordController.getModel()
	EventBus:dispatchEvent(EventEnum.landlordBaoJing, {id = netData.player_id})
end

-- 广播玩家回合结算
function LandlordController.notifyRoundAccountRes(netData)
	local model = LandlordController.getModel()
	for __, playerResult in ipairs(netData.player_result_list) do
		model:updatePlayerScore(playerResult.player_id, playerResult.score)
	end
	model:updateBaseScore(1)
	model:updateMultiple(1)
	EventBus:dispatchEvent(EventEnum.landlordRoundAccount, {accountData = netData})
end

-- 广播玩家退出结算界面
function LandlordController.exitRoundAccounReq()
	NetCom:send(16018)
end

-- 广播玩家退出结算界面
function LandlordController.exitRoundAccounRes(netData)
	LandlordController.getModel():updateFarmerWinPokerNum(0)
	LandlordController.getModel():resetPlayerData(netData.player_id)
	LandlordController.getModel():updatePlayerState(netData.player_id, LANDLORD_PLAYER_PREPARE)
	EventBus:dispatchEvent(EventEnum.landlordExitRoundAccount, {id = netData.player_id})
end

-- 广播玩家最终结算
function LandlordController.notifyFinalAccountRes(netData)
	LandlordController.getModel():updateFinalAccountData(netData)
end

-- 广播新玩家加入
function LandlordController.notifyNewPlayerRes(netData)
	local player = LandlordController.getModel():insertPlayer(netData)
	EventBus:dispatchEvent(EventEnum.landlordNewPlayer, {player = player})
end

-- 广播局数更新
function LandlordController.notifyRoundUpdateRes(netData)
	LandlordController.getModel():updateRound(netData.num)
	EventBus:dispatchEvent(EventEnum.landlordRoundUpdate)
end

-- 出牌失败
function LandlordController.playCardFailRes(netData)
	if 1 == netData.num then
		CommonFunc.showCenterMsg("出牌失败")
	elseif 2 == netData.num then
		CommonFunc.showCenterMsg("牌型错误")
	elseif 3 == netData.num then
		CommonFunc.showCenterMsg("必须出")
	elseif 4 == netData.num then
		CommonFunc.showCenterMsg("必须出")
	end
end

-- 广播让多少张牌
function LandlordController.notifyFarmerWinPokerNum(netData)
	LandlordController.getModel():updateFarmerWinPokerNum(netData.num)
	EventBus:dispatchEvent(EventEnum.landlordFarmerWinPokerNum)
end
---------------------------- 网络接口 E --------------------------
---------------------------- 牌型检索 S --------------------------
-- 排序
function LandlordController.sortPokers(pokers)
	table.sort(pokers, function(pokerA, pokerB)
			local indexA = getPokerIndex(pokerA.num, pokerA.flower)
			local indexB = getPokerIndex(pokerB.num, pokerB.flower)
			return indexA > indexB
		end)
end

-- 整理牌
function LandlordController.analysePokers(pokers, analyseResult)
	local cnt = #pokers
	local ind = 1
	while ind <= cnt do
		local sameCnt = 1
		local num = pokers[ind].num
		-- 搜索相同牌
		for jnd = ind + 1, cnt do
			if pokers[jnd].num ~= num then break end
			sameCnt = sameCnt + 1
		end
		-- 重置搜索结果
		if 1 == sameCnt then
			analyseResult.singleCount = analyseResult.singleCount + 1
			analyseResult.singlePokers[#analyseResult.singlePokers + 1] = pokers[ind]
		elseif 2 == sameCnt then
			analyseResult.doubleCount = analyseResult.doubleCount + 1
			analyseResult.doublePokers[#analyseResult.doublePokers + 1] = pokers[ind]
			analyseResult.doublePokers[#analyseResult.doublePokers + 1] = pokers[ind + 1]
		elseif 3 ==  sameCnt then
			analyseResult.threeCount = analyseResult.threeCount + 1
			analyseResult.threePokers[#analyseResult.threePokers + 1] = pokers[ind]
			analyseResult.threePokers[#analyseResult.threePokers + 1] = pokers[ind + 1]
			analyseResult.threePokers[#analyseResult.threePokers + 1] = pokers[ind + 2]
		elseif 4 == sameCnt then
			analyseResult.fourCount = analyseResult.fourCount + 1
			analyseResult.fourPokers[#analyseResult.fourPokers + 1] = pokers[ind]
			analyseResult.fourPokers[#analyseResult.fourPokers + 1] = pokers[ind + 1]
			analyseResult.fourPokers[#analyseResult.fourPokers + 1] = pokers[ind + 2]
			analyseResult.fourPokers[#analyseResult.fourPokers + 1] = pokers[ind + 3]
		end
		ind = ind + sameCnt
	end
end

-- 获取牌型
function LandlordController.getPokerStyle(pokers)
	local cnt = #pokers
	LandlordController.sortPokers(pokers)

	---------------------- 简单牌型 S ---------------------
	if 0 == cnt then
		return LANDLORT_STYLE.CT_ERROR
	-- 单张
	elseif 1 == cnt then
		return LANDLORT_STYLE.CT_SINGLE
	-- 对子
	elseif 2 == cnt then
		-- 火箭
		if pokers[1].num == POKER_ENUM.POKER_17 and
			pokers[2].num == POKER_ENUM.POKER_16 then
			return LANDLORT_STYLE.CT_ROCKET
		end
		-- 普通对子
		if pokers[1].num == pokers[2].num then
			return LANDLORT_STYLE.CT_DOUBLE
		end
		return LANDLORT_STYLE.CT_ERROR
	end
	---------------------- 简单牌型 E ---------------------
	---------------------- 复杂牌型 S ---------------------
	local analyseResult = {
		fourCount			= 0,
		threeCount			= 0,
		doubleCount			= 0,
		singleCount			= 0,
		fourPokers			= {},
		threePokers			= {},
		doublePokers		= {},
		singlePokers		= {},
	}
	LandlordController.analysePokers(pokers, analyseResult)
	-- 有四张相同的牌
	if 0 < analyseResult.fourCount then
		-- 炸弹
		if 1 == analyseResult.fourCount and 4 == cnt then
			return LANDLORT_STYLE.CT_BOMB
		end
		-- 四带二(5555,67)
		if 1 == analyseResult.fourCount and 2 == analyseResult.singleCount and 6 == cnt then
			return LANDLORT_STYLE.CT_FOUR_TAKE_SINGLE
		end
		-- 四带二(5555,66,77)
		if 1 == analyseResult.fourCount and 2 == analyseResult.doubleCount and 8 == cnt then
			return LANDLORT_STYLE.CT_FOUR_TAKE_SINGLE
		end
		return LANDLORT_STYLE.CT_ERROR
	end
	-- 有三张相同的牌
	if 0 < analyseResult.threeCount then
		-- 三不带
		if 1 == analyseResult.threeCount and 3 == cnt then
			return LANDLORT_STYLE.CT_THREE
		end
		-- 三带一
		if 1 == analyseResult.threeCount and 4 == cnt then
			return LANDLORT_STYLE.CT_THREE_TAKE_SINGLE
		end
		-- 三带一对
		if 1 == analyseResult.threeCount and 5 == cnt then
			return LANDLORT_STYLE.CT_THREE_TAKE_DOUBLE
		end
		-- 错误过滤
		if 1 < analyseResult.threeCount then
			local num = analyseResult.threePokers[1].num
			-- 2和王都不可以参与连牌
			if num >= POKER_ENUM.POKER_15 then
				return LANDLORT_STYLE.CT_ERROR
			end
			-- 连牌判断
			for ind = 1, analyseResult.threeCount - 1 do
				local poker = analyseResult.threePokers[ind * 3 + 1]
				if poker.num + ind ~= num then
					return LANDLORT_STYLE.CT_ERROR
				end
			end
		end
		-- 三顺
		if cnt == analyseResult.threeCount * 3 then
			return LANDLORT_STYLE.CT_THREE_LINE
		end
		-- 飞机(333,444,...,5,6,...)
		if cnt == analyseResult.threeCount * 4 then
			return LANDLORT_STYLE.CT_THREE_LINE_TAKE_SINGLE
		end
		-- 飞机(333,444,...,55,66,...)
		if cnt == analyseResult.threeCount * 5 and
			analyseResult.threeCount == analyseResult.doubleCount then
			return LANDLORT_STYLE.CT_THREE_LINE_TAKE_DOUBLE
		end

		return LANDLORT_STYLE.CT_ERROR
	end
	-- 有对子的牌
	if 3 <= analyseResult.doubleCount then
		local num = analyseResult.doublePokers[1].num
		-- 2和王都不可以参与连牌
		if num >= POKER_ENUM.POKER_15 then
			return LANDLORT_STYLE.CT_ERROR
		end
		-- 连牌判断
		for ind = 1, analyseResult.doubleCount - 1 do
			local poker = analyseResult.doublePokers[ind * 2 + 1]
			if poker.num + ind ~= num then
				return LANDLORT_STYLE.CT_ERROR
			end
		end
		-- 连对
		if analyseResult.doubleCount * 2 == cnt then
			return LANDLORT_STYLE.CT_DOUBLE_LINE
		end
		return LANDLORT_STYLE.CT_ERROR
	end
	-- 顺子
	if analyseResult.singleCount >= 5 and cnt == analyseResult.singleCount then
		local num = analyseResult.singlePokers[1].num
		-- 2和王都不可以参与顺子
		if num >= POKER_ENUM.POKER_15 then
			return LANDLORT_STYLE.CT_ERROR
		end
		-- 连牌判断
		for ind = 1, analyseResult.singleCount - 1 do
			local poker = analyseResult.singlePokers[ind + 1]
			if poker.num + ind ~= num then
				return LANDLORT_STYLE.CT_ERROR
			end
		end
		-- 顺子
		return LANDLORT_STYLE.CT_SINGLE_LINE
	end
	return LANDLORT_STYLE.CT_ERROR
	---------------------- 复杂牌型 E ---------------------
end

-- 比牌
function LandlordController.compareCard(sorPokers, desPokers)
	local cnt1, ctn2 = #sorPokers, #desPokers
	local type1 = LandlordController.getPokerStyle(sorPokers)
	local type2 = LandlordController.getPokerStyle(desPokers)
	-- 牌型错误
	if type2 == LANDLORT_STYLE.CT_ERROR then return false end
	-- 火箭
	if type1 == LANDLORT_STYLE.CT_ROCKET then return false end
	if type2 == LANDLORT_STYLE.CT_ROCKET then return true end
	-- 炸弹
	if type1 ~= LANDLORT_STYLE.CT_BOMB and type2 == LANDLORT_STYLE.CT_BOMB then
		return true
	end
	if type1 == LANDLORT_STYLE.CT_BOMB and type2 ~= LANDLORT_STYLE.CT_BOMB then
		return false
	end
	-- 规则判断
	if type1 ~= type2 or cnt1 ~= ctn2 then
		return false
	end
	-- 比牌
	if type2 == LANDLORT_STYLE.CT_SINGLE or
		type2 == LANDLORT_STYLE.CT_DOUBLE or
		type2 == LANDLORT_STYLE.CT_THREE or
		type2 == LANDLORT_STYLE.CT_SINGLE_LINE or
		type2 == LANDLORT_STYLE.CT_DOUBLE_LINE or
		type2 == LANDLORT_STYLE.CT_THREE_LINE or
		type2 == LANDLORT_STYLE.CT_BOMB then
		return desPokers[1].num > sorPokers[1].num
	elseif type2 == LANDLORT_STYLE.CT_THREE_TAKE_SINGLE or
		type2 == LANDLORT_STYLE.CT_THREE_TAKE_DOUBLE or
		type2 == LANDLORT_STYLE.CT_THREE_LINE_TAKE_SINGLE or
		type2 == LANDLORT_STYLE.CT_THREE_LINE_TAKE_DOUBLE then
		local analyseResult1 = {
			fourCount			= 0,
			threeCount			= 0,
			doubleCount			= 0,
			singleCount			= 0,
			fourPokers			= {},
			threePokers			= {},
			doublePokers		= {},
			singlePokers		= {},
		}
		LandlordController.analysePokers(sorPokers, analyseResult1)
		local analyseResult2 = {
			fourCount			= 0,
			threeCount			= 0,
			doubleCount			= 0,
			singleCount			= 0,
			fourPokers			= {},
			threePokers			= {},
			doublePokers		= {},
			singlePokers		= {},
		}
		LandlordController.analysePokers(desPokers, analyseResult2)
		return analyseResult2.threePokers[1].num > analyseResult1.threePokers[1].num
	elseif type2 == LANDLORT_STYLE.CT_FOUR_TAKE_SINGLE or
		type2 == LANDLORT_STYLE.CT_FOUR_TAKE_SINGLE then
		local analyseResult1 = {
			fourCount			= 0,
			threeCount			= 0,
			doubleCount			= 0,
			singleCount			= 0,
			fourPokers			= {},
			threePokers			= {},
			doublePokers		= {},
			singlePokers		= {},
		}
		LandlordController.analysePokers(sorPokers, analyseResult1)
		local analyseResult2 = {
			fourCount			= 0,
			threeCount			= 0,
			doubleCount			= 0,
			singleCount			= 0,
			fourPokers			= {},
			threePokers			= {},
			doublePokers		= {},
			singlePokers		= {},
		}
		LandlordController.analysePokers(desPokers, analyseResult2)
		return analyseResult2.fourPokers[1].num > analyseResult1.fourPokers[1].num
	end
	return false
end

-- 智能提示(返回满足条件的所有解)
function LandlordController.intelligentOutPokers(handPokers, prePlayedPokers)
	local canOutPokersArr = {}
	local handCnt = #handPokers
	local prePlayCnt = #prePlayedPokers
	if handCnt <= 0 then
		return canOutPokersArr
	end
	local prePlayType = LandlordController.getPokerStyle(prePlayedPokers)
	-- 记录出牌的类型
	local prePlayAnalyseResult = {
		fourCount			= 0,
		threeCount			= 0,
		doubleCount			= 0,
		singleCount			= 0,
		fourPokers			= {},
		threePokers			= {},
		doublePokers		= {},
		singlePokers		= {},
	}
	LandlordController.analysePokers(prePlayedPokers, prePlayAnalyseResult)
	-- 上家没出牌
	if prePlayType == LANDLORT_STYLE.CT_ERROR then
		return canOutPokersArr
	-- 单张、对子、三张
	elseif prePlayType == LANDLORT_STYLE.CT_SINGLE or
		prePlayType == LANDLORT_STYLE.CT_DOUBLE or
		prePlayType == LANDLORT_STYLE.CT_THREE then
		local preMaxValue = prePlayedPokers[1].num
		local handAnalyseResult = {
			fourCount			= 0,
			threeCount			= 0,
			doubleCount			= 0,
			singleCount			= 0,
			fourPokers			= {},
			threePokers			= {},
			doublePokers		= {},
			singlePokers		= {},
		}
		LandlordController.analysePokers(handPokers, handAnalyseResult)
		-- 单张
		if prePlayCnt <= 1 then
			for i = 1, handAnalyseResult.singleCount do
				local idx = handAnalyseResult.singleCount - i + 1
				if handAnalyseResult.singlePokers[idx].num > preMaxValue then
					canOutPokersArr[#canOutPokersArr + 1] = {handAnalyseResult.singlePokers[idx]}
				end
			end
		end
		-- 寻找对子
		if prePlayCnt <= 2 then
			for i = 1, handAnalyseResult.doubleCount do
				local idx = (handAnalyseResult.doubleCount - i) * 2 + 1
				if handAnalyseResult.doublePokers[idx].num > preMaxValue then
					local pokers = {}
					for ind = 1, prePlayCnt do
						pokers[ind] = handAnalyseResult.doublePokers[idx + ind - 1]
					end
					canOutPokersArr[#canOutPokersArr + 1] = pokers
				end
			end
		end
		-- 寻找三张
		if prePlayCnt <= 3 then
			for i = 1, handAnalyseResult.threeCount do
				local idx = (handAnalyseResult.threeCount - i) * 3 + 1
				if handAnalyseResult.threePokers[idx].num > preMaxValue then
					local pokers = {}
					for ind = 1, prePlayCnt do
						pokers[ind] = handAnalyseResult.threePokers[idx + ind - 1]
					end
					canOutPokersArr[#canOutPokersArr + 1] = pokers
				end
			end
		end
		-- 寻找四张
		if prePlayCnt <= 4 then
			for i = 1, handAnalyseResult.fourCount do
				local idx = (handAnalyseResult.fourCount - i) * 4 + 1
				if handAnalyseResult.fourPokers[idx].num > preMaxValue then
					local pokers = {}
					for ind = 1, prePlayCnt do
						pokers[ind] = handAnalyseResult.fourPokers[idx + ind - 1]
					end
					canOutPokersArr[#canOutPokersArr + 1] = pokers
				end
			end
		end
	-- 单顺类型
	elseif prePlayType == LANDLORT_STYLE.CT_SINGLE_LINE and handCnt >= prePlayCnt then
		local preMaxValue = prePlayedPokers[1].num
		-- 搜索连牌
		for i = prePlayCnt, handCnt do
			local handValue = handPokers[handCnt - i + 1].num
			-- 2和王都不可以参与连牌
			if handValue >= POKER_ENUM.POKER_15 then
				break
			end
			if handValue > preMaxValue then
				local lineCnt = 0
				local pokers = {}
				for j = handCnt - i + 1, handCnt do
					if handPokers[j].num + lineCnt == handValue then
						pokers[#pokers + 1] = handPokers[j]
						lineCnt = lineCnt + 1
						-- 匹配成功
						if lineCnt == prePlayCnt then
							canOutPokersArr[#canOutPokersArr + 1] = pokers
							break
						end
					end
				end
			end
		end
	-- 连对
	elseif prePlayType == LANDLORT_STYLE.CT_DOUBLE_LINE and handCnt >= prePlayCnt then
		local preMaxValue = prePlayedPokers[1].num
		-- 搜索连对
		for i = prePlayCnt, handCnt do
			local handValue = handPokers[handCnt - i + 1].num
			-- 2和王都不可以参与连对
			if handValue >= POKER_ENUM.POKER_15 then
				break
			end
			if handValue > preMaxValue then
				local lineCnt = 0
				local pokers = {}
				for j = handCnt - i + 1, handCnt - 1 do
					if handPokers[j].num + lineCnt == handValue and
						handPokers[j + 1].num + lineCnt == handValue then
						-- 增加连对数
						pokers[lineCnt * 2 + 1] = handPokers[j]
						pokers[lineCnt * 2 + 2] = handPokers[j + 1]
						lineCnt = lineCnt + 1
						-- 匹配成功
						if lineCnt * 2 == prePlayCnt then
							canOutPokersArr[#canOutPokersArr + 1] = pokers
							break
						end
					end
				end
			end
		end
	-- 三顺，飞机，三带一，三带对，飞机翅膀，飞机翅膀
	elseif (prePlayType == LANDLORT_STYLE.CT_THREE_LINE or
		prePlayType == LANDLORT_STYLE.CT_THREE_TAKE_SINGLE or
		prePlayType == LANDLORT_STYLE.CT_THREE_TAKE_DOUBLE or
		prePlayType == LANDLORT_STYLE.CT_THREE_LINE_TAKE_SINGLE or
		prePlayType == LANDLORT_STYLE.CT_THREE_LINE_TAKE_DOUBLE) and
		handCnt >= prePlayCnt then
		local preMaxValue = 0
		-- 获取最大的三张相同的牌
		for i = 1, prePlayCnt - 2 do
			preMaxValue = prePlayedPokers[i].num
			if prePlayedPokers[i + 1].num == preMaxValue and
				prePlayedPokers[i + 2].num == preMaxValue then
				break
			end
		end
		local preLineCnt = prePlayAnalyseResult.threeCount
		-- 搜索连牌
		local preSearceValue = 0
		for i = 1, handCnt - 2 do
			local handValue = handPokers[handCnt - i + 1].num
			if handValue > preMaxValue then
				-- 2和王都不可以参与连对
				if preLineCnt > 1 and handValue >= POKER_ENUM.POKER_15 then
					break
				end
				local lineCnt = 0
				local pokers = {}
				for j = 1, handCnt - 2 do
					if handPokers[j].num + lineCnt == handValue and
						handPokers[j + 1].num + lineCnt == handValue and
						handPokers[j + 2].num + lineCnt == handValue and
						handPokers[j + 2].num + lineCnt ~= preSearceValue then
						preSearceValue = handValue
						pokers[lineCnt * 3 + 1] = handPokers[j]
						pokers[lineCnt * 3 + 2] = handPokers[j + 1]
						pokers[lineCnt * 3 + 3] = handPokers[j + 2]
						lineCnt = lineCnt + 1
						-- 匹配成功
						if lineCnt == preLineCnt then
							-- 删除手牌中三顺
							local leftPokers = CommonFunc.deepCopy(handPokers)
							local needRemoveArr = {}
							for __, poker in ipairs(pokers) do
								needRemoveArr[poker.num] = needRemoveArr[poker.num] or {}
								needRemoveArr[poker.num][poker.flower] = true
							end
							for ind = #leftPokers, 1 do
								local poker = leftPokers[ind]
								if needRemoveArr[poker.num] and needRemoveArr[poker.num][poker.flower] then
									table.remove(leftPokers, ind)
								end
							end
							-- 分析剩余的扑克
							local leftAnalyseResult = {
								fourCount			= 0,
								threeCount			= 0,
								doubleCount			= 0,
								singleCount			= 0,
								fourPokers			= {},
								threePokers			= {},
								doublePokers		= {},
								singlePokers		= {},
							}
							LandlordController.analysePokers(leftPokers, leftAnalyseResult)
							-- 三带一
							if prePlayType == LANDLORT_STYLE.CT_THREE_LINE_TAKE_SINGLE or
								prePlayType == LANDLORT_STYLE.CT_THREE_TAKE_SINGLE then
								-- 提取单牌
								local boContinue = true
								if boContinue then
									for ind = 1, leftAnalyseResult.singleCount do
										-- 匹配成功
										if #pokers == prePlayCnt then
											boContinue = false
											break
										end
										local idx = leftAnalyseResult.singleCount - ind + 1
										pokers[#pokers + 1] = leftAnalyseResult.singlePokers[idx]
									end
								end

								-- 提取牌from对牌
								if boContinue then
									for ind = 1, leftAnalyseResult.doubleCount do
										-- 匹配成功
										if #pokers == prePlayCnt then
											boContinue = false
											break
										end
										local idx = (leftAnalyseResult.doubleCount - ind) * 2 + 1
										pokers[#pokers + 1] = leftAnalyseResult.doublePokers[idx]
									end
								end

								-- 提取单牌from三张
								if boContinue then
									for ind = 1, leftAnalyseResult.threeCount do
										-- 匹配成功
										if #pokers == prePlayCnt then
											boContinue = false
											break
										end
										local idx = (leftAnalyseResult.threeCount - ind) * 3 + 1
										pokers[#pokers + 1] = leftAnalyseResult.threePokers[idx]
									end
								end

								-- 提取单牌from四张
								if boContinue then
									for ind = 1, leftAnalyseResult.fourCount do
										-- 匹配成功
										if #pokers == prePlayCnt then
											boContinue = false
											break
										end
										local idx = (leftAnalyseResult.fourCount - ind) * 4 + 1
										pokers[#pokers + 1] = leftAnalyseResult.fourPokers[idx]
									end
								end
							end
							-- 对牌处理
							if prePlayType == LANDLORT_STYLE.CT_THREE_LINE_TAKE_DOUBLE or
								prePlayType == LANDLORT_STYLE.CT_THREE_TAKE_DOUBLE then
								local boContinue = true
								-- 提取对牌
								if boContinue then
									for ind = 1, leftAnalyseResult.doubleCount do
										-- 匹配成功
										if #pokers == prePlayCnt then
											boContinue = false
											break
										end
										local idx = (leftAnalyseResult.doubleCount - ind) * 2 + 1
										pokers[#pokers + 1] = leftAnalyseResult.doublePokers[idx]
										pokers[#pokers + 1] = leftAnalyseResult.doublePokers[idx + 1]
									end
								end
								-- 提取对牌from三张
								if boContinue then
									for ind = 1, leftAnalyseResult.threeCount do
										-- 匹配成功
										if #pokers == prePlayCnt then
											boContinue = false
											break
										end
										local idx = (leftAnalyseResult.threeCount - ind) * 3 + 1
										pokers[#pokers + 1] = leftAnalyseResult.threePokers[idx]
										pokers[#pokers + 1] = leftAnalyseResult.threePokers[idx + 1]
									end
								end

								-- 提取对牌from四张
								if boContinue then
									for ind = 1, leftAnalyseResult.fourCount do
										-- 匹配成功
										if #pokers == prePlayCnt then
											boContinue = false
											break
										end
										local idx = (leftAnalyseResult.fourCount - ind) * 4 + 1
										pokers[#pokers + 1] = leftAnalyseResult.fourPokers[idx]
										pokers[#pokers + 1] = leftAnalyseResult.fourPokers[idx + 1]
									end
								end
							end
							if #pokers == prePlayCnt then
								-- 避免拆炸弹(333 444 35)
								if LandlordController.getPokerStyle(pokers) ~= LANDLORT_STYLE.CT_ERROR then
									canOutPokersArr[#canOutPokersArr + 1] = pokers
									break
								end
							end
						end
					end
				end
			end
		end
	-- 四带二
	elseif (prePlayType == LANDLORT_STYLE.CT_FOUR_TAKE_DOUBLE or
		prePlayType == LANDLORT_STYLE.CT_FOUR_TAKE_SINGLE) and
		handCnt >= prePlayCnt then
		local handAnalyseResult = {
			fourCount			= 0,
			threeCount			= 0,
			doubleCount			= 0,
			singleCount			= 0,
			fourPokers			= {},
			threePokers			= {},
			doublePokers		= {},
			singlePokers		= {},
		}
		LandlordController.analysePokers(handPokers, handAnalyseResult)
		local pokers = {}
		for i = 1, handAnalyseResult.fourCount do
			local idx = (handAnalyseResult.fourCount - i) * 4 + 1
			if handAnalyseResult.fourPokers[idx].num > prePlayAnalyseResult.fourPokers[1].num then
				for ind = 1, 4 do
					pokers[ind] = handAnalyseResult.fourPokers[idx + ind - 1]
				end
				break
			end
		end
		if 4 == #pokers then
			-- 删除手牌中三顺
			local leftPokers = CommonFunc.deepCopy(handPokers)
			local needRemoveArr = {}
			for __, poker in ipairs(pokers) do
				needRemoveArr[poker.num] = needRemoveArr[poker.num] or {}
				needRemoveArr[poker.num][poker.flower] = true
			end
			for ind = #leftPokers, 1 do
				local poker = leftPokers[ind]
				if needRemoveArr[poker.num] and needRemoveArr[poker.num][poker.flower] then
					table.remove(leftPokers, ind)
				end
			end
			-- 分析剩余的扑克
			local leftAnalyseResult = {
				fourCount			= 0,
				threeCount			= 0,
				doubleCount			= 0,
				singleCount			= 0,
				fourPokers			= {},
				threePokers			= {},
				doublePokers		= {},
				singlePokers		= {},
			}
			LandlordController.analysePokers(leftPokers, leftAnalyseResult)
			-- 四带两张单
			if prePlayType == LANDLORT_STYLE.CT_FOUR_TAKE_SINGLE then
				-- 提取单牌
				local boContinue = true
				if boContinue then
					for ind = 1, leftAnalyseResult.singleCount do
						-- 匹配成功
						if #pokers == prePlayCnt then
							boContinue = false
							break
						end
						local idx = leftAnalyseResult.singleCount - ind + 1
						pokers[#pokers + 1] = leftAnalyseResult.singlePokers[idx]
					end
				end

				-- 提取牌from对牌
				if boContinue then
					for ind = 1, leftAnalyseResult.doubleCount do
						-- 匹配成功
						if #pokers == prePlayCnt then
							boContinue = false
							break
						end
						local idx = (leftAnalyseResult.doubleCount - ind) * 2 + 1
						pokers[#pokers + 1] = leftAnalyseResult.doublePokers[idx]
					end
				end

				-- 提取单牌from三张
				if boContinue then
					for ind = 1, leftAnalyseResult.threeCount do
						-- 匹配成功
						if #pokers == prePlayCnt then
							boContinue = false
							break
						end
						local idx = (leftAnalyseResult.threeCount - ind) * 3 + 1
						pokers[#pokers + 1] = leftAnalyseResult.threePokers[idx]
					end
				end

				-- 提取单牌from四张
				if boContinue then
					for ind = 1, leftAnalyseResult.fourCount do
						-- 匹配成功
						if #pokers == prePlayCnt then
							boContinue = false
							break
						end
						local idx = (leftAnalyseResult.fourCount - ind) * 4 + 1
						pokers[#pokers + 1] = leftAnalyseResult.fourPokers[idx]
					end
				end
			end
			-- 四带对
			if prePlayType == LANDLORT_STYLE.CT_FOUR_TAKE_DOUBLE then
				local boContinue = true
				-- 提取对牌
				if boContinue then
					for ind = 1, leftAnalyseResult.doubleCount do
						-- 匹配成功
						if #pokers == prePlayCnt then
							boContinue = false
							break
						end
						local idx = (leftAnalyseResult.doubleCount - ind) * 2 + 1
						pokers[#pokers + 1] = leftAnalyseResult.doublePokers[idx]
						pokers[#pokers + 1] = leftAnalyseResult.doublePokers[idx + 1]
					end
				end
				-- 提取对牌from三张
				if boContinue then
					for ind = 1, leftAnalyseResult.threeCount do
						-- 匹配成功
						if #pokers == prePlayCnt then
							boContinue = false
							break
						end
						local idx = (leftAnalyseResult.threeCount - ind) * 3 + 1
						pokers[#pokers + 1] = leftAnalyseResult.threePokers[idx]
						pokers[#pokers + 1] = leftAnalyseResult.threePokers[idx + 1]
					end
				end

				-- 提取对牌from四张
				if boContinue then
					for ind = 1, leftAnalyseResult.fourCount do
						-- 匹配成功
						if #pokers == prePlayCnt then
							boContinue = false
							break
						end
						local idx = (leftAnalyseResult.fourCount - ind) * 4 + 1
						pokers[#pokers + 1] = leftAnalyseResult.fourPokers[idx]
						pokers[#pokers + 1] = leftAnalyseResult.fourPokers[idx + 1]
					end
				end
			end
			if #pokers == prePlayCnt then
				canOutPokersArr[#canOutPokersArr + 1] = pokers
			end
		end
	end
	-- 搜索炸弹
	if handCnt >= 4 and prePlayType ~= LANDLORT_STYLE.CT_ROCKET then
		local handAnalyseResult = {
			fourCount			= 0,
			threeCount			= 0,
			doubleCount			= 0,
			singleCount			= 0,
			fourPokers			= {},
			threePokers			= {},
			doublePokers		= {},
			singlePokers		= {},
		}
		LandlordController.analysePokers(handPokers, handAnalyseResult)
		local preMaxValue = 0
		if prePlayType == LANDLORT_STYLE.CT_BOMB then
			preMaxValue = prePlayedPokers[1].num
			for i = 1, handAnalyseResult.fourCount do
				local pokers = {}
				local idx = (handAnalyseResult.fourCount - i) * 4 + 1
				if handAnalyseResult.fourPokers[idx].num > preMaxValue then
					for ind = 1, 4 do
						pokers[ind] = handAnalyseResult.fourPokers[idx + ind - 1]
					end
					canOutPokersArr[#canOutPokersArr + 1] = pokers
				end
			end
		else
			if handAnalyseResult.fourCount >= 1 then
				for i = 1, handAnalyseResult.fourCount do
					local pokers = {}
					local idx = (handAnalyseResult.fourCount - i) * 4 + 1
					for ind = 1, 4 do
						pokers[ind] = handAnalyseResult.fourPokers[idx + ind - 1]
					end
					canOutPokersArr[#canOutPokersArr + 1] = pokers
				end
			end
		end
	end

	-- 搜索火箭
	if handCnt >= 2 and
		handPokers[1].num == POKER_ENUM.POKER_17 and 
		handPokers[2].num == POKER_ENUM.POKER_16 then
		local pokers = {
			handPokers[1],
			handPokers[2],
		}
		canOutPokersArr[#canOutPokersArr + 1] = pokers
	end
	return canOutPokersArr
end
---------------------------- 牌型检索 E --------------------------

cc.exports.LandlordController = LandlordController