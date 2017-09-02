local AccountController = {}
local accoutSaveFileName = "accoutData"

function AccountController.getModel()
	return PlayerManager:getModel("Account")
end

-- 微信登录
function AccountController.loginByWechatReq()
	NetCom:send(10002, {wx_code = G_WX_CODE, wx_appid = ""})
end

-- 检查临时账号是否有效(不用判断过期)
function AccountController.getIsTempAccoutValid()
	local boRet = true
	local tempAccount, tempPassword, tempAccoutEndTime = AccountController.loadTempAccount()
	while true do
		-- 未保存临时账号和密码
		if nil == tempAccount then
			boRet = false
			break
		end
		-- 临时账号和密码过期
		-- local serverTime = Time.getServerTime()
		-- if tempAccoutEndTime < serverTime then
		-- 	boRet = false
		-- 	break
		-- end
		break
	end
	return boRet
end

-- 临时账号密码登录
function AccountController.loginByTempAccountReq()
	if AccountController.getIsTempAccoutValid() then
		local tempAccount, tempPassword, tempAccoutEndTime = AccountController.loadTempAccount()
		NetCom:send(10003, {account = tempAccount, password = tempPassword})
	else
		AccountController.saveTempAccount(nil, nil, nil)
		if device.platform ~= "windows" then
			wxLogin()
			local eventData = {
				uiName = "WaitingUI",
				parms = {5},
			}
			EventBus:dispatchEvent(EventEnum.openUI, eventData)
		end
	end
end

-- 正式账号密码登录
function AccountController.loginByFormalAccountReq(account, password)
	NetCom:send(10004, {account = account, password = password})
end

-- 登录成功返回
function AccountController.loginSuccessRes(netData)
	PlayerManager:reset()
	AccountController.getModel():setAccountInfo(netData)
	AccountController.saveTempAccount(netData.temp_account, netData.temp_password, netData.temp_account_endtime)
	AccountController.savePreLoginData(netData.temp_account, math.floor(netData.total_pay / 100), netData.total_round)
	if netData.room_id == 0 then
		EventBus:dispatchEvent(EventEnum.openUI, {uiName = "HallUI"})
		EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "LoginUI"})
	end
	if AccountController.getModel():getIsLoginBefore() then
		EventBus:dispatchEvent(EventEnum.reLogin)
		if nil ~= UIManager:getOpenedUI("DisbandRoomUI") then
			EventBus:dispatchEvent(EventEnum.closeUIIngoreEffect, {uiName = "DisbandRoomUI"})
		end
	else
		if AccountController.getModel():getPlayerAgentId() == 0 then
			EventBus:dispatchEvent(EventEnum.openUI, {uiName = "InviteCodeUI"})
		end
	end
	Game:loginSuccess()
end

-- 登录失败返回login_type:(1 = 微信登录, 2 = 临时账号, 3 = 正式账号)
function AccountController.loginFailRes(netData)
	local loginType = netData.login_type
	local errorCode = netData.err_code
	if 2 == loginType then
		if 1 == errorCode then
			AccountController.saveTempAccount(nil, nil, nil)
		end
	end
	-- (为查找到该临时账号/该临时账号过期，正式账号登录失败，微信登录失败)
	if 1 == errorCode then
		CommonFunc.showCenterMsg("微信授权过期")
	elseif 2 == errorCode then
		CommonFunc.showCenterMsg("登录失败")
	elseif 3 == errorCode then
		CommonFunc.showCenterMsg("微信登录失败")
	elseif 4 == errorCode then
		CommonFunc.showCenterMsg("您已被封号")
	end
	Game:backToLoginUI()
end

-- 请求发送心跳包
function AccountController.heartBeatReq()
	NetCom:send(10007)
	AccountController.getModel():updateHeartBeatTime()
end

-- 心跳包返回
function AccountController.heartBeatRes()
	AccountController.getModel():updateReceiveHeatBeatTime()
end

-- 更新玩家房卡数
function AccountController.updateRoomCard(roomCard)
	AccountController.getModel():updateRoomCard(roomCard)
	EventBus:dispatchEvent(EventEnum.roomCardChange)
end

-- 检查是否断线
function AccountController.getIsDisconnect()
	return AccountController.getModel():getIsDisconnect()
end

-- 玩家发送邀请码请求
function AccountController.inviteCodeReq(inviteCode)
	NetCom:send(10010, {invite_code = inviteCode})
end

-- 返回邀请码信息
function AccountController.inviteCodeRes(netData)
	local retCode = netData.ret_code
	if retCode == 0 then
		AccountController.getModel():updatePlayerAgentId(netData.agent_id)
		CommonFunc.showCenterMsg("绑定成功")
	else
		CommonFunc.showCenterMsg("绑定失败")
	end
end

-- 绑定账号返回
function AccountController.bindAccountSuccessRes(netData)
	CommonFunc.showCenterMsg("绑定账号成功")
end

-- 在其他设备登录
function AccountController.loginInOtherDiviceRes()
	Game:backToLoginUI()
	AccountController.saveTempAccount(nil, nil, nil)
	local strContent = "您的账号在其他设备登录，请留意账号是否泄漏！"
	CommonFunc.showTip(strContent)
end

-- 请求服务器信息
function AccountController.requestServerInfo()
	local preLoginData = AccountController.loadPreLoginData()
	local url = SERVER_CNF[1]
	-- not regist
	if nil == preLoginData.tempAccount then
		url = SERVER_CNF[1]
	-- have registed
	else
		-- pay more than 0
		if 0 < preLoginData.totalPay then
			-- pay less than 50
			if 50 >= preLoginData.totalPay then
				url = SERVER_CNF[10]
			-- pay less than 1000
			elseif 50 < preLoginData.totalPay and 1000 >= preLoginData.totalPay then
				url = SERVER_CNF[11]
			-- pay more than 0
			elseif 1000 >= preLoginData.totalPay then
				url = SERVER_CNF[12]
			end
		else
			-- round less than 80
			if 80 >= preLoginData.totalRound then
				local serInd = math.random(2, 6)
				url = SERVER_CNF[serInd]
			else
				-- round less than 160
				if 160 >= preLoginData.totalRound then
					url = SERVER_CNF[7]
				-- round less than 300
				elseif 160 < preLoginData.totalRound and 300 >= preLoginData.totalRound then
					url = SERVER_CNF[8]
				-- round more than 300
				elseif 300 < preLoginData.totalRound then
					url = SERVER_CNF[9]
				end
			end
		end
	end
	url = url.."?v="..os.date("%m%d%H%M", os.time())
	requstServerInfo(url)
end

function AccountController.clearTempAccount()
	AccountController.saveTempAccount(nil, nil, nil)
end

function AccountController.saveTempAccount(tempAccount, tempPassword, tempAccoutEndTime)
	local saveData = {
		tempAccount = tempAccount,
		tempPassword = tempPassword,
		tempAccoutEndTime = tempAccoutEndTime
	}
	CommonFunc.saveDataToFile(accoutSaveFileName, saveData)
end

function AccountController.loadTempAccount()
	local saveData = CommonFunc.loadDataFromFile(accoutSaveFileName) or {}
	return saveData.tempAccount, saveData.tempPassword, saveData.tempAccoutEndTime
end

function AccountController.loadPreLoginData()
	local preLoginData = CommonFunc.loadDataFromFile("preLogin") or {}
	return preLoginData
end

function AccountController.savePreLoginData(tempAccount, totalPay, totalRound)
	local saveData = {
		tempAccount = tempAccount,
		totalPay = totalPay,
		totalRound = totalRound,
	}
	CommonFunc.saveDataToFile("preLogin", saveData)
end


function AccountController.loadUpdateXbwData()
	local updateXbw = CommonFunc.loadDataFromFile("updateXbw") or {}
	AccountController.getModel():updateIsXbw(updateXbw.isXbw)
	return updateXbw
end

function AccountController.saveUpdateXbwData(isXbw)
	local saveData = {
		isXbw = isXbw,
	}
	AccountController.getModel():updateIsXbw(isXbw)
	CommonFunc.saveDataToFile("updateXbw", saveData)
end
---------------------------------------------------------------------------------
function AccountController.getPlayerName()
	return AccountController.getModel():getPlayerName()
end

function AccountController.getPlayerId()
	return AccountController.getModel():getPlayerId()
end

function AccountController.getPlayerIcon()
	return AccountController.getModel():getPlayerIcon()
end

function AccountController.getRoomCard()
	return AccountController.getModel():getRoomCard()
end

function AccountController.getPlayerAgentId()
	return AccountController.getModel():getPlayerAgentId()
end

function AccountController.getGps()
	return AccountController.getModel():getGps()
end

function AccountController.getIsDaiLi()
	return AccountController.getModel():getIsDaiLi()
end

function AccountController.getSex()
	return AccountController.getModel():getSex()
end

function AccountController.getGameNotice()
	return AccountController.getModel():getGameNotice()
end

function AccountController.getIsInRoom()
	return AccountController.getModel():getIsInRoom()
end

function AccountController.getIsXbw()
	return AccountController.getModel():getIsXbw()
end

cc.exports.AccountController = AccountController