local SDController = {}

function SDController.getModel()
	return PlayerManager:getModel("SD")
end

------------------------- 永久监听事件 S -------------------------
-- 开始回放
function SDController.onStartPlayBack()
	SDController.getModel():updatePlayBackState(true)
end

-- 结束回放
function SDController.onEndPlayBack()
	SDController.getModel():updatePlayBackState(false)
end

-- 退出三代
function SDController.exitSD()
	if nil == UIManager:getOpenedUI("HallUI") then
		EventBus:dispatchEvent(EventEnum.openUI, {uiName = "HallUI"})
	end
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "SDUI"})
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "SDRAccountUI"})
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "SDFAccountUI"})
	SDController.getModel():reset()
end

function SDController.exitRoom(eventData)
	SDController.getModel():removePlayer(eventData.id)
end

function SDController.closeRoom(eventData)
	if nil ~= UIManager:getOpenedUI("SDUI") then
		local period = SDController.getModel():getRoundPeriod()
		if period == SD_PERIOD_WAIT then
			SDController.exitSD()
		end
	end
end

-- 观战玩家退出房间
EventBus:addEventListener(EventEnum.exitRoom, SDController.exitRoom)
-- 关闭房间
EventBus:addEventListener(EventEnum.closeRoom, SDController.closeRoom)
-- 回放开始
EventBus:addEventListener(EventEnum.startPlayBack, SDController.onStartPlayBack)
-- 结束回放
EventBus:addEventListener(EventEnum.endPlayBack, SDController.onEndPlayBack)
-- 退出三代
EventBus:addEventListener(EventEnum.exitSD, SDController.exitSD)
------------------------- 永久监听事件 E -------------------------

function SDController.enterRoomRes(netData)
	local model = SDController.getModel()
	SDController.getModel():reset()
	SDController.getModel():initRoomInfo(netData)
	if model:getIsPlayBack() then
		EventBus:dispatchEvent(EventEnum.openUI, {uiName = "SDUI"})
	else
		local SDUI = UIManager:getOpenedUI("SDUI")
		if nil ~= SDUI then
			SDUI:reEnter()
		else
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LoginUI"})
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "JoinRoomUI"})
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "RoomCreateUI"})
			EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "HallUI"})
			EventBus:dispatchEvent(EventEnum.openUI, {uiName = "SDUI"})
		end
	end
end

-- 广播玩家在线状态
function SDController.notifyPlayerOnlineRes(netData)
	SDController.getModel():updatePlayerOnline(netData.player_id, netData.is_online)
	EventBus:dispatchEvent(EventEnum.sdPlayerOnline, {id = netData.player_id})
end

-- 广播房间阶段变更
function SDController.notifyPeriodRes(netData)
	SDController.getModel():updateRoundPeriod(netData.state)
	EventBus:dispatchEvent(EventEnum.sdPeriod, {period = netData.state})
end

-- 推送玩家扑克牌列表
function SDController.notifyPokerListRes(netData)
	SDController.getModel():updateMyPokerList(netData.poker_list)
end

-- 广播行动玩家变更
function SDController.notifyActionPlayerRes(netData)
	SDController.getModel():updateActionPlayer(netData.player_id)
	EventBus:dispatchEvent(EventEnum.sdActionPlayer)
end

-- 玩家出牌操作
function SDController.playPokerReq(choosePokers)
	local actionPlayerId = SDController.getModel():getActionPlayerId()
	if AccountController.getPlayerId() == actionPlayerId then
		NetCom:send(22006, {poker_list = choosePokers})
	end
end

-- 不出
function SDController.refusePlayCardReq()
	local actionPlayerId = SDController.getModel():getActionPlayerId()
	if AccountController.getPlayerId() == actionPlayerId then
		NetCom:send(22006, {poker_list = {}})
	end
end

-- 广播玩家出牌
function SDController.notifyPlayPokerRes(netData)
	SDController.getModel():updatePrePlayPokers(netData.player_id, netData.poker_list or {})
	SDController.getModel():updatePlayerRemainCardNum(netData.player_id, netData.remain_num)
	EventBus:dispatchEvent(EventEnum.sdPlayCard, {id = netData.player_id})
end

-- 广播炸弹数更新
function SDController.notifyBombNumUpdateRes(netData)
	SDController.getModel():updateBombNum(netData.num)
	EventBus:dispatchEvent(EventEnum.sdBombNumUpdate, {num = netData.num})
end

-- 报警
function SDController.notifyBaoJingRes(netData)
	EventBus:dispatchEvent(EventEnum.sdBaoJing, {id = netData.player_id})
end

-- 广播玩家回合结算
function SDController.notifyRoundAccountRes(netData)
	local model = SDController.getModel()
	for __, playerResult in ipairs(netData.player_result_list) do
		model:updatePlayerScore(playerResult.player_id, playerResult.score)
	end
	model:updateBaseScore(1)
	model:updateBombNum(0)
	EventBus:dispatchEvent(EventEnum.sdRoundAccount, {accountData = netData})
end

-- 广播玩家退出结算界面
function SDController.exitRoundAccounReq()
	NetCom:send(22011)
end

-- 引爆
function SDController.isTippingReq()
	NetCom:send(22017)
end

function SDController.isTippingRes(netData)
	SDController.getModel():updateIsTipping(netData.is_tipping)
	EventBus:dispatchEvent(EventEnum.sdIsTipping, {isTipping = netData.is_tipping})
end

-- 广播玩家退出结算界面
function SDController.exitRoundAccounRes(netData)
	SDController.getModel():resetPlayerData(netData.player_id)
	EventBus:dispatchEvent(EventEnum.sdExitRoundAccount, {id = netData.player_id})
end

-- 广播玩家最终结算
function SDController.notifyFinalAccountRes(netData)
	SDController.getModel():updateFinalAccountData(netData)
end

-- 广播新玩家加入
function SDController.notifyNewPlayerRes(netData)
	local player = SDController.getModel():insertPlayer(netData)
	EventBus:dispatchEvent(EventEnum.sdNewPlayer, {player = player})
end

-- 广播局数更新
function SDController.notifyRoundUpdateRes(netData)
	SDController.getModel():updateRound(netData.num)
	EventBus:dispatchEvent(EventEnum.sdRoundUpdate)
end

-- 出牌失败
function SDController.playCardFailRes(netData)
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
---------------------------- 网络接口 E --------------------------
---------------------------- 牌型检索 S --------------------------
-- 排序
function SDController.sortPokers(pokers)
	table.sort(pokers, function(pokerA, pokerB)
			local indexA = WZ_GETLOGICVALUE(pokerA.num, pokerA.flower)
			local indexB = WZ_GETLOGICVALUE(pokerB.num, pokerB.flower)
			return indexA > indexB
		end)
end

function SDController.getTabDes()
	local round,maxRound = SDController.getModel():getRound()
	local cnf = SDController.getModel():getCnf()
	local forceCnf = SDController.getModel():getForceCnf()
	local tabDes = {}
	tabDes[1] = {
		title = "牌数显示：",
		des = "",
	}
	if cnf.isCardNum then
		tabDes[1].des = "显示牌数"
	else
		tabDes[1].des = "不显示牌数"
	end
	tabDes[2] = {
		title = "炸弹：",
		des = "",
	}
	if cnf.scoreType == 1 then
		tabDes[2].des = "2分"
	elseif cnf.scoreType == 2 then
		tabDes[2].des = "5分"
	elseif cnf.scoreType == 3 then
		tabDes[2].des = "10分"
	end
	if cnf.threeTake == 1 then
		tabDes[3] = {
			title = "三代选择：",
			des = "三带单能压三带对",
		}
	elseif cnf.threeTake == 2 then
		tabDes[3] = {
			title = "三代选择：",
			des = "三带单不能压三带对",
		}
	end
	tabDes[4] = {
		title = "游玩局数：",
		des = string.format("%d局", maxRound),
	}
	tabDes[5] = {
		title = "特殊玩法：",
		des = ""
	}
	if cnf.hasAircraft then
		if tabDes[5].des == "" then
			tabDes[5].des = tabDes[5].des.."带飞机"
		else
			tabDes[5].des = tabDes[5].des.." 带飞机"
		end
	end
	if cnf.forceCard then
		if tabDes[5].des == "" then
			tabDes[5].des = tabDes[5].des.."硬吃硬"
		else
			tabDes[5].des = tabDes[5].des.." 硬吃硬"
		end
	else
		if forceCnf.force1 then
			if tabDes[5].des == "" then
				tabDes[5].des = tabDes[5].des.."33必压22"
			else
				tabDes[5].des = tabDes[5].des.." 33必压22"
			end
		end
		if forceCnf.force2 then
			if tabDes[5].des == "" then
				tabDes[5].des = tabDes[5].des.."333必压222"
			else
				tabDes[5].des = tabDes[5].des.." 333必压222"
			end
		end
		if forceCnf.force3 then
			if tabDes[5].des == "" then
				tabDes[5].des = tabDes[5].des.."大炸弹必压小炸弹"
			else
				tabDes[5].des = tabDes[5].des.." 大炸弹必压小炸弹"
			end
		end
		if forceCnf.force4 then
			if tabDes[5].des == "" then
				tabDes[5].des = tabDes[5].des.."33必见炸弹"
			else
				tabDes[5].des = tabDes[5].des.." 33必见炸弹"
			end
		end
		if forceCnf.force5 then
			if tabDes[5].des == "" then
				tabDes[5].des = tabDes[5].des.."333必见炸弹"
			else
				tabDes[5].des = tabDes[5].des.." 333必见炸弹"
			end
		end
	end
	return tabDes
end

-- 获取牌型
function SDController.getPokerStyle(pokers)
	local cnt = #pokers
	SDController.sortPokers(pokers)
	local isHasAir = SDController.getModel():getAircraft()
	---------------------------- 简单牌型 S -----------------------
	if 0 == cnt then
		return SD_POKER_STYLE.CT_ERROR
	elseif 1 == cnt then
		return SD_POKER_STYLE.CT_SINGLE
	elseif 2 == cnt then
		if pokers[1].num == pokers[2].num then
			return SD_POKER_STYLE.CT_DOUBLE
		end
		return SD_POKER_STYLE.CT_ERROR
	end
	---------------------------- 简单牌型 E -----------------------
	---------------------------- 复杂牌型 S -----------------------
	local analyseResult = ANALYSE_POKERS(pokers)
	-- 有四张相同
	if 0 < analyseResult.fourCount then
		if 1 == analyseResult.fourCount and 4 == cnt then
			-- 炸弹
			return SD_POKER_STYLE.CT_BOMB
		end
		return SD_POKER_STYLE.CT_ERROR
	end
	-- 有三张相同的
	if 0 < analyseResult.threeCount then
		-- 三条
		if 1 == analyseResult.threeCount and 5 == cnt then
			if analyseResult.doubleCount == 1 then
				return SD_POKER_STYLE.CT_THREE_TAKE_DOUBLE
			elseif analyseResult.singleCount == 2 then
				return SD_POKER_STYLE.CT_THREE_TAKE_SINGLE
			end
		end
		-- A、2、3和王不可以参与连牌
		if analyseResult.threePokers[1].num >= WZ_POKER_ENUM.POKER_14 then
			return SD_POKER_STYLE.CT_ERROR
		end
		-- 飞机
		if isHasAir then
			if cnt == analyseResult.threeCount * 5 and 2 == analyseResult.threeCount then
				return SD_POKER_STYLE.CT_THREE_LINE
			end
		end
		return SD_POKER_STYLE.CT_ERROR
	end
	-- 有对子的牌
	if 3 <= analyseResult.doubleCount then
		local num = analyseResult.doublePokers[1].num
		-- A、2、3和王不可以参与连牌
		if num >= WZ_POKER_ENUM.POKER_14 then
			return SD_POKER_STYLE.CT_ERROR
		end
		-- 连牌判断
		for ind = 1, analyseResult.doubleCount - 1 do
			local poker = analyseResult.doublePokers[ind * 2 + 1]
			if poker.num + ind ~= num then
				return SD_POKER_STYLE.CT_ERROR
			end
		end
		-- 连对
		if analyseResult.doubleCount * 2 == cnt then
			return SD_POKER_STYLE.CT_DOUBLE_LINE
		end
	end
	-- 顺子
	if analyseResult.singleCount >= 5 and cnt == analyseResult.singleCount then
		local num = analyseResult.singlePokers[1].num
		-- A、2、3和王不可以参与连牌
		if num >= WZ_POKER_ENUM.POKER_14 then
			return SD_POKER_STYLE.CT_ERROR
		end
		-- 连牌判断
		for ind = 1, analyseResult.singleCount - 1 do
			local poker = analyseResult.singlePokers[ind + 1]
			if poker.num + ind ~= num then
				return SD_POKER_STYLE.CT_ERROR
			end
		end
		-- 顺子
		return SD_POKER_STYLE.CT_SINGLE_LINE
	end
	return SD_POKER_STYLE.CT_ERROR
	---------------------------- 复杂牌型 E -----------------------
end

function SDController.getIsFourBomb(handPokers)
	local handAnalyseResult = ANALYSE_POKERS(handPokers)
	local handCnt = #handPokers
	if handAnalyseResult.fourCount > 0 then
		for i = 1, handAnalyseResult.fourCount do
			local pokers = {}
			local idx = (handAnalyseResult.fourCount - i) * 4 + 1
			if handAnalyseResult.fourPokers[idx].num == 4 then
				return true
			end
		end
	end
	return false
end

function SDController.getPokerIsForce(handPokers, prePlayedPokers)
	local prePlayType = SDController.getPokerStyle(prePlayedPokers)
	SDController.sortPokers(prePlayedPokers)
	local forceCnf = SDController.getModel():getForceCnf()
	local canOutPoker = SDController.intelligentOutPokers(handPokers, prePlayedPokers)
	if SD_POKER_STYLE.CT_DOUBLE == prePlayType then
		if prePlayedPokers[1].num == 15 and forceCnf.force1 then
			if #canOutPoker > 0 then
				for __,outPoker in ipairs(canOutPoker) do
					if outPoker[1].num == 16 then
						return true
					end
				end
			end
		end
		if prePlayedPokers[1].num == 16 and forceCnf.force4 then
			if #canOutPoker > 0 then
				return true
			end
		end
	elseif SD_POKER_STYLE.CT_THREE_TAKE_SINGLE == prePlayType or
		SD_POKER_STYLE.CT_THREE_TAKE_DOUBLE == prePlayType then
		if prePlayedPokers[1].num == 15 and forceCnf.force2 then
			if #canOutPoker > 0 then
				for __,outPoker in ipairs(canOutPoker) do
					if outPoker[1].num == 16 then
						poker[1].num = outPoker
						return true
					end
				end
			end
		end
		if prePlayedPokers[1].num == 16 and forceCnf.force5 then
			if #canOutPoker > 0 then
				return true
			end
		end
	elseif SD_POKER_STYLE.CT_BOMB == prePlayType then
		if forceCnf.force3 then
			if #canOutPoker > 0 then
				return true
			end
		end
	end
	return false
end
-- 比牌
function SDController.compareCard(sorPokers, desPokers)
	local cnt1, ctn2 = #sorPokers, #desPokers
	local type1 = SDController.getPokerStyle(sorPokers)
	local type2 = SDController.getPokerStyle(desPokers)
	local threeTake = SDController.getModel():getThreeTake()
	local isTipping = SDController.getModel():getIsTipping()
	-- 牌型错误
	if type2 == SD_POKER_STYLE.CT_ERROR then return false end
	-- 炸弹
	if type1 ~= SD_POKER_STYLE.CT_BOMB and type2 == SD_POKER_STYLE.CT_BOMB then
		return true
	end
	if type1 == SD_POKER_STYLE.CT_BOMB and type2 ~= SD_POKER_STYLE.CT_BOMB then
		return false
	end
	-- 规则判断
	if cnt1 ~= ctn2 then
		return false
	end
	if type1 ~= type2 then
		if threeTake == 2 and type2 == SD_POKER_STYLE.CT_THREE_TAKE_SINGLE then
				return false
		end
	end
	if isTipping and (type1 == SD_POKER_STYLE.CT_BOMB and type2 == SD_POKER_STYLE.CT_BOMB) then
		return true
	end
	-- 比牌
	if type2 == SD_POKER_STYLE.CT_SINGLE or
		type2 == SD_POKER_STYLE.CT_DOUBLE or
		type2 == SD_POKER_STYLE.CT_SINGLE_LINE or
		type2 == SD_POKER_STYLE.CT_DOUBLE_LINE or
		type2 == SD_POKER_STYLE.CT_BOMB then
		return desPokers[1].num > sorPokers[1].num
	end
	if type2 == SD_POKER_STYLE.CT_THREE_LINE or
	 	type2 == SD_POKER_STYLE.CT_THREE_TAKE_SINGLE or
		type2 == SD_POKER_STYLE.CT_THREE_TAKE_DOUBLE then
		local prePlayAnalyseResult = ANALYSE_POKERS(sorPokers)
		local handAnalyseResult = ANALYSE_POKERS(desPokers)
		return handAnalyseResult.threePokers[1].num > prePlayAnalyseResult.threePokers[1].num
	end
	return false
end

-- 智能提示（返回满足条件的所有解)
function SDController.intelligentOutPokers(handPokers, prePlayedPokers)
	local canOutPokersArr = {}
	local handCnt = #handPokers
	local prePlayCnt = #prePlayedPokers
	local threeTake = SDController.getModel():getThreeTake()
	if handCnt <= 0 then
		return canOutPokersArr
	end
	local prePlayType = SDController.getPokerStyle(prePlayedPokers)
	-- 记录出牌的类型
	local prePlayAnalyseResult = ANALYSE_POKERS(prePlayedPokers)
	-- 上家没出牌
	if prePlayType == SD_POKER_STYLE.CT_ERROR then
		return canOutPokersArr
	-- 三代1, 三代对，飞机(aaabbb1234)
	elseif(prePlayType == SD_POKER_STYLE.CT_THREE_TAKE_DOUBLE or
		prePlayType == SD_POKER_STYLE.CT_THREE_TAKE_SINGLE or 
		prePlayType == SD_POKER_STYLE.CT_THREE_LINE) and handCnt >= prePlayCnt then
		local preMaxValue = 0
		-- 获取三张相同的牌
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
				if preLineCnt > 1 and handValue >= WZ_POKER_ENUM.POKER_14 then
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
							local leftAnalyseResult = ANALYSE_POKERS(leftPokers)
							-- 三带单
							if prePlayType == SD_POKER_STYLE.CT_THREE_TAKE_SINGLE then
								-- 提取单牌from单牌
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
							-- 三带二
							if prePlayType == SD_POKER_STYLE.CT_THREE_TAKE_DOUBLE then
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
								if boContinue and threeTake then
									-- 提取牌from对牌
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
							end
							if #pokers == prePlayCnt then
								if SDController.getPokerStyle(pokers) ~= SD_POKER_STYLE.CT_ERROR then
									canOutPokersArr[#canOutPokersArr + 1] = pokers
									break
								end
							end
						end
					end
				end
			end
		end
	-- 单张、对子、三张、四张
	elseif prePlayType == SD_POKER_STYLE.CT_SINGLE or
		prePlayType == SD_POKER_STYLE.CT_DOUBLE then
		local preMaxValue = prePlayedPokers[1].num
		local handAnalyseResult = ANALYSE_POKERS(handPokers)
		-- 单张
		if prePlayCnt <= 1 then
			for i = 1, handAnalyseResult.singleCount do
				local idx = handAnalyseResult.singleCount - i + 1
				if handAnalyseResult.singlePokers[idx].num > preMaxValue then
					canOutPokersArr[#canOutPokersArr + 1] = {handAnalyseResult.singlePokers[idx]}
				end
			end
			if handAnalyseResult.doubleCount > 0 then
				local idx = (handAnalyseResult.doubleCount - 1) * 2 + 1
				if handAnalyseResult.doublePokers[idx].num > preMaxValue then
					canOutPokersArr[#canOutPokersArr + 1] = {handAnalyseResult.doublePokers[idx]}
				end
			end
			if handAnalyseResult.threeCount > 0 then
				local idx = (handAnalyseResult.threeCount - 1) * 3 + 1
				if handAnalyseResult.threePokers[idx].num > preMaxValue then
					canOutPokersArr[#canOutPokersArr + 1] = {handAnalyseResult.threePokers[idx]}
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
			if handAnalyseResult.threeCount > 0 then
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
		end
	-- 单顺类型
	elseif prePlayType == SD_POKER_STYLE.CT_SINGLE_LINE and handCnt >= prePlayCnt then
		local preMaxValue = prePlayedPokers[1].num
		-- 搜索连牌
		for i = prePlayCnt, handCnt do
			local handValue = handPokers[handCnt - i + 1].num
			-- A,2,3都不可以参与连牌
			if handValue >=WZ_POKER_ENUM.POKER_14 then
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
	elseif prePlayType == SD_POKER_STYLE.CT_DOUBLE_LINE and handCnt >= prePlayCnt then
		local preMaxValue = prePlayedPokers[1].num
		-- 搜索连对
		for i = prePlayCnt, handCnt do
			local handValue = handPokers[handCnt - i + 1].num
			-- A,2,3都不可以参与连牌
			if handValue >=WZ_POKER_ENUM.POKER_14 then
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
	-- 三顺
	elseif prePlayType == SD_POKER_STYLE.CT_THREE_LINE and
		handCnt >= prePlayCnt then
		if prePlayCnt == 10 then
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
			for i = preLineCnt * 3, handCnt do
				local handValue = handPokers[handCnt - i + 1].num
				if handValue > preMaxValue then
					-- A,2,3都不可以参与连牌
					if preLineCnt > 1 and handValue >=WZ_POKER_ENUM.POKER_14 then
						break
					end
					local lineCnt = 0
					local pokers = {}
					for j = handCnt - i + 1, handCnt - 2 do
						if handPokers[j].num + lineCnt == handValue and
							handPokers[j + 1].num + lineCnt == handValue and
							handPokers[j + 2].num + lineCnt == handValue then
							pokers[lineCnt * 3 + 1] = handPokers[j]
							pokers[lineCnt * 3 + 2] = handPokers[j + 1]
							pokers[lineCnt * 3 + 3] = handPokers[j + 2]
							lineCnt = lineCnt + 1
							-- 匹配成功
							if lineCnt == preLineCnt then
								-- 删除手牌中三顺
								local leftPokers = CommonFunc.deepCopy(handPokers)
								local takeCard = 1
								for k = 1, handCnt do
									if takeCard <= lineCnt * 2 then
										if k < j - 3 or k > j + 2 then
											pokers[lineCnt * 3 + takeCard] = handPokers[k]
											takeCard = takeCard + 1
										end
									end
								end
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
								if #pokers == prePlayCnt then
									-- 避免拆炸弹(333 444 35)
									if SDController.getPokerStyle(pokers) ~= SD_POKER_STYLE.CT_ERROR then
										canOutPokersArr[#canOutPokersArr + 1] = pokers
									end
								end
							end
						end
					end
				end
			end
		end
	end
	-- 搜索炸弹
	if handCnt >= 4 then
		local handAnalyseResult = ANALYSE_POKERS(handPokers)
		local preMaxValue = 0
		if prePlayType == SD_POKER_STYLE.CT_BOMB then
			preMaxValue = prePlayedPokers[1].num
			if isTipping then
				for i = 1, handAnalyseResult.fourCount do
					local pokers = {}
					local idx = (handAnalyseResult.fourCount - i) * 4 + 1
					for ind = 1, 4 do
						pokers[ind] = handAnalyseResult.fourPokers[idx + ind - 1]
					end
					canOutPokersArr[#canOutPokersArr + 1] = pokers
				end
			else
				if handCnt >= 4 then
					-- 检索正常的炸弹
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
				end
			end
		else
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
	local nextPlayerCardNum = SDController.getModel():getNextPlayerCardNum()
	if nextPlayerCardNum == 1 and prePlayType == SD_POKER_STYLE.CT_SINGLE then
		table.sort(canOutPokersArr, function(pokerA, pokerB)
			return pokerA[1].num < pokerB[1].num
		end)
		local forceOut = canOutPokersArr[#canOutPokersArr]
		canOutPokersArr = {}
		canOutPokersArr[#canOutPokersArr + 1] = forceOut
	end
	return canOutPokersArr
end
---------------------------- 牌型检索 E --------------------------

cc.exports.SDController = SDController