local AccountModel = class("AccountModel", BaseModel)

function AccountModel:init()
	-- 已经登录过
	self._loginBefore = false
	self:reset()
end

function AccountModel:reset()
	-- 玩家名
	self._id = 0
	-- 微信ID
	self._wechatId = ""
	-- 微信名
	self._wechatName = ""
	-- 性别(0 = 女, 1 = 男)
	self._sex = 0
	-- vip等级
	self._vipLv = 0
	-- 房卡数
	self._roomCard = 0
	-- 消耗房卡数
	self._roomCardCost = 0
	-- 充值房卡数
	self._roomCardRecharge = 0
	-- 玩家头像
	self._playerIcon = ""
	-- 临时账号
	self._tempAccount = ""
	-- 临时密码
	self._tempPassword = ""
	-- 临时账号有效时间，截止时间戳
	self._tempAccountEndtime = 0
	-- 代理邀请码
	self._agentInviteCode = ""
	-- 代理ID
	self._agentId = 0
	-- 房间ID(如果roomId不为零则等待接受)
	self._roomId = 0
	-- 上次发送心跳时间
	self._sendBeatHeartTime = 0
	-- 上次接受到心跳时间
	self._receiveBeatHeartTime = os.time()
	-- gps
	self._gps = ""
	-- 健康游戏公告
	self._gameNotice = ""
	-- game url
	self._gameUrl = GAME_URL
	-- 是否更新为西北玩
	self._isUpdateXbw = false
end

function AccountModel:setAccountInfo(netData)
	-- 玩家名
	self._id = netData.player_id
	-- 微信ID
	self._wechatId = netData.wechat_id
	-- 微信名
	self._wechatName = netData.wechat_name
	-- 性别
	self._sex = netData.sex
	-- vip等级
	self._vipLv = netData.vip_lv
	-- 房卡数
	self._roomCard = netData.room_card
	-- 消耗房卡数
	self._roomCardCost = netData.room_card_cost
	-- 充值房卡数
	self._roomCardRecharge = netData.room_card_recharge
	-- 玩家头像
	self._playerIcon = netData.player_icon
	-- 临时账号
	self._tempAccount = netData.temp_account
	-- 临时密码
	self._tempPassword = netData.temp_password
	-- 临时账号有效时间，截止时间戳
	self._tempAccountEndtime = netData.temp_account_endtime
	-- 代理邀请码
	self._agentInviteCode = netData.agent_invite_code
	-- 代理ID
	self._agentId = netData.agent_id
	-- 房间ID(如果roomId不为零则等待接受)
	self._roomId = netData.room_id
	-- game url
	GAME_URL = (netData.game_url == "") and GAME_URL or netData.game_url
	self._gameUrl = GAME_URL
	-- 登录过
	self._loginBefore = true
	-- 健康游戏公告
	self._gameNotice = netData.health_notice
end

function AccountModel:updateHeartBeatTime()
	self._sendBeatHeartTime = os.time()
end

function AccountModel:updateReceiveHeatBeatTime()
	self._receiveBeatHeartTime = os.time()
end

function AccountModel:updateIsXbw(isXbw)
	self._isUpdateXbw = isXbw
end

function AccountModel:updateRoomCard(roomCard)
	self._roomCard = roomCard
end

function AccountModel:updatePlayerAgentId(agentId)
	self._agentId = agentId
end

function AccountModel:getPlayerName()
	return self._wechatName
end

function AccountModel:getSex()
	return self._sex
end

function AccountModel:getPlayerId()
	return self._id
end

function AccountModel:getRoomCard()
	return self._roomCard
end

function AccountModel:getPlayerIcon()
	return self._playerIcon
end

function AccountModel:getPlayerAgentId()
	return self._agentId
end

function AccountModel:getGps()
	return self._gps
end

function AccountModel:getGameNotice()
	return self._gameNotice
end

function AccountModel:getIsXbw()
	return self._isUpdateXbw
end

function AccountModel:getIsDisconnect()
	local isDisconnect = false
	local curTime = os.time()
	if curTime - self._receiveBeatHeartTime > DISCONNECT_TIME then
		isDisconnect = true
	end
	return isDisconnect
end

function AccountModel:getIsLoginBefore()
	return self._loginBefore
end

-- 是否是代理
function AccountModel:getIsDaiLi()
	return "" ~= self._agentInviteCode
end

-- 是否在游戏中
function AccountModel:getIsInRoom()
	return self._roomId ~= 0
end

return AccountModel