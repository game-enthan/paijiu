-- 支付方式
local PAY_WAY = {
	WECHAT 					= 1,		-- 微信
	ZHIFUBAO				= 2,		-- 支付宝
	HANDPAY					= 3,		-- 掌支付
}

-- 支付方式描述
local PAY_WAY_STR = {
	[PAY_WAY.WECHAT] 					= "微信支付",
	[PAY_WAY.ZHIFUBAO]					= "支付宝支付",
	[PAY_WAY.HANDPAY]					= "第三方支付",
}

-- 支付按钮图标
local PAY_WAY_URL = {
	[PAY_WAY.WECHAT] 					= "res/shop/shop_btnwxpay.png",
	[PAY_WAY.ZHIFUBAO]					= "res/shop/shop_btnzfbpay.png",
	[PAY_WAY.HANDPAY]					= "res/shop/shop_btnhandpay.png",
}

-- 游戏类型
local PlayType = {
	TT_BULLFIGHT			= 101,		-- 斗牛
--	TT_GOLDFLOWER			= 102,		-- 金花
	TT_LANDLORD				= 103,		-- 斗地主
	TT_SX_WK				= 104,		-- 陕西挖坑
	TT_LZ_WK				= 105,		-- 兰州挖坑
	TT_TEN_HALF				= 106,		-- 十点半
	TT_PUSH_PAIRS			= 107,		-- 推对子
	TT_SX_SD				= 108,		-- 陕西三代
}

-- 游戏人数限制
local PlayerNumCnf = {
	[PlayType.TT_BULLFIGHT] 	= 7,	-- 牛牛
--	[PlayType.TT_GOLDFLOWER] 	= 7,	-- 金花
	[PlayType.TT_LANDLORD] 		= 3,	-- 斗地主（分2人和3人）
	[PlayType.TT_SX_WK]			= 3,	-- 陕西挖坑
	[PlayType.TT_LZ_WK]			= 3,	-- 兰州挖坑
	[PlayType.TT_TEN_HALF]		= 7,	-- 十点半
	[PlayType.TT_PUSH_PAIRS]	= 7,	-- 推对子
	[PlayType.TT_SX_SD]			= 3,	-- 三代
} 

-- 每张房卡可以玩多少局
local PerRoomCardToRound = {
	[PlayType.TT_BULLFIGHT] 	= 10,
--	[PlayType.TT_GOLDFLOWER] 	= 8,
	[PlayType.TT_LANDLORD] 		= 8,
	[PlayType.TT_SX_WK]			= 8,
	[PlayType.TT_LZ_WK]			= 8,
	[PlayType.TT_TEN_HALF]		= 8,
	[PlayType.TT_PUSH_PAIRS]	= 10,
	[PlayType.TT_SX_SD]			= 10,
}

-- 玩法名
local PlayTypeToName = {
	[PlayType.TT_BULLFIGHT] 	= "牛  牛",
--	[PlayType.TT_GOLDFLOWER] 	= "飘三叶",
	[PlayType.TT_LANDLORD] 		= "斗地主",
	[PlayType.TT_SX_WK]			= "陕西挖坑",
	[PlayType.TT_LZ_WK]			= "兰州挖坑",
	[PlayType.TT_TEN_HALF]		= "十点半",
	[PlayType.TT_PUSH_PAIRS]	= "推对子",
	[PlayType.TT_SX_SD]			= "陕西三代",
}

-- 牌局模式
local RoundType = {
	TYPE_NORMAL				= 1,		-- 正常模式
	TYPE_RECORD				= 2,		-- 回放模式
}

-- 玩家前端显示状态
local CliPlayerState = {
	STATE_NIL			= 0,		-- 其他
	STATE_OFFLINE		= 1,		-- 离线
	STATE_READY			= 2,		-- 准备
	STATE_QIANG			= 3,		-- 抢庄
	STATE_WITNESS		= 4,		-- 观战
	STATE_BUQIANG		= 5,		-- 不抢
	STATE_RUBING		= 6,		-- 搓牌中
	STATE_WAITCHIP		= 7,		-- 待下注
	STATE_SHOWING		= 8,		-- 亮牌中
}

local CliPlayerStateUrl = {
	[CliPlayerState.STATE_NIL] 			= "",
	[CliPlayerState.STATE_OFFLINE] 		= "res/com/com_offline.png",
	[CliPlayerState.STATE_READY] 		= "res/com/com_ready.png",
	[CliPlayerState.STATE_QIANG] 		= "res/com/com_qiangzhuang.png",
	[CliPlayerState.STATE_WITNESS] 		= "res/com/com_witness.png",
	[CliPlayerState.STATE_BUQIANG]		= "res/com/com_buqiang.png",
	[CliPlayerState.STATE_RUBING]		= "res/com/com_rubing.png",
	[CliPlayerState.STATE_WAITCHIP]		= "res/com/com_waitchip.png",
	[CliPlayerState.STATE_SHOWING]		= "res/com/com_showing.png",
}

local RoundedCliPlayerStateUrl = {
	[CliPlayerState.STATE_NIL] 			= "",
	[CliPlayerState.STATE_OFFLINE] 		= "res/com/com_offline2.png",
	[CliPlayerState.STATE_READY] 		= "res/com/com_ready2.png",
	[CliPlayerState.STATE_QIANG] 		= "res/com/com_qiangzhuang2.png",
	[CliPlayerState.STATE_WITNESS] 		= "res/com/com_witness2.png",
	[CliPlayerState.STATE_BUQIANG]		= "res/com/com_buqiang2.png",
	[CliPlayerState.STATE_RUBING]		= "res/com/com_rubing2.png",
	[CliPlayerState.STATE_WAITCHIP]		= "res/com/com_waitchip2.png",
	[CliPlayerState.STATE_SHOWING]		= "res/com/com_showing2.png",
}

local OprExitRoomType = {
	TYPE_CHOOSING		= 0,		-- 选择中
	TYPE_REQUEST		= 1,		-- 申请
	TYPE_AGREE			= 2,		-- 同意
	TYPE_DISAGREE		= 3,		-- 拒绝
}

local OprExitRoomTypeStr = {
	[OprExitRoomType.TYPE_REQUEST]		= "申请解散",		-- 申请
	[OprExitRoomType.TYPE_AGREE]		= "同意解散",		-- 同意
	[OprExitRoomType.TYPE_DISAGREE]		= "拒绝解散",		-- 拒绝
}

-- 聊天消息类型
local ChatMsgType = {
	TYPE_COUNTENANCE	= 1,		-- 表情
	TYPE_COMMON			= 2,		-- 常用语
	TYPE_VOICE			= 3,		-- 语音
	TYPE_EMOTIONEFF		= 4,		-- 交互动画
}

-- 语言类型
local LanguageType = {
	TYPE_NORMAL = 1,		--普通话		
	TYPE_DIALECT 	= 2,	--方言
}

-- 交互动画
local EmotionEffCnf = {
	[101] = {imgUrl = "res/icon/emotions/emotion_101.png", aniUrl = "res/animation/emotionani101.csb", audioUrl = nil},
	[102] = {imgUrl = "res/icon/emotions/emotion_102.png", aniUrl = "res/animation/emotionani102.csb", audioUrl = nil},
	[103] = {imgUrl = "res/icon/emotions/emotion_103.png", aniUrl = "res/animation/emotionani103.csb", audioUrl = nil},
	[104] = {imgUrl = "res/icon/emotions/emotion_104.png", aniUrl = "res/animation/emotionani104.csb", audioUrl = nil},
	[105] = {imgUrl = "res/icon/emotions/emotion_105.png", aniUrl = "res/animation/emotionani105.csb", audioUrl = "res/audio/emotion_egg.mp3"},
	[106] = {imgUrl = "res/icon/emotions/emotion_106.png", aniUrl = "res/animation/emotionani106.csb", audioUrl = "res/audio/emotion_bomb.mp3"},
}

-- 禁用的颜色
local DISABLE_C4B = cc.c4b(77, 77, 77, 255)
-- 可用的颜色
local ENABLE_C4B	= cc.c4b(255, 255, 255, 255)

-- 获取表情路径
local function getCountenance(id)
	assert(id >= 1 and id <= 30)
	return string.format("res/icon/face/%d.png", id)
end

local function getChipResUrl(chipIndex)
	local url = string.format("res/chip/chip%d.png", chipIndex)
	return url
end

-- 整理牌
local function ANALYSE_POKERS(pokers)
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
		-- 搜索结果
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
	return analyseResult
end

-- 支付通道
cc.exports.PAY_WAY = PAY_WAY
cc.exports.PAY_WAY_STR = PAY_WAY_STR
cc.exports.PAY_WAY_URL = PAY_WAY_URL
cc.exports.RoundType = RoundType
-- 玩法类型
cc.exports.PlayType = PlayType
cc.exports.PlayerNumCnf = PlayerNumCnf
cc.exports.PerRoomCardToRound = PerRoomCardToRound
cc.exports.PlayTypeToName = PlayTypeToName
-- 广播消息轮播次数
cc.exports.HornMsgLoopTime = 3
cc.exports.CliPlayerState = CliPlayerState
cc.exports.CliPlayerStateUrl = CliPlayerStateUrl
cc.exports.RoundedCliPlayerStateUrl = RoundedCliPlayerStateUrl
-- 操作退出房间类型
cc.exports.OprExitRoomType = OprExitRoomType
cc.exports.OprExitRoomTypeStr = OprExitRoomTypeStr
cc.exports.ChatMsgType = ChatMsgType
cc.exports.getCountenance = getCountenance
-- 下注资源
cc.exports.getChipResUrl = getChipResUrl
cc.exports.DISABLE_C4B = DISABLE_C4B
cc.exports.ENABLE_C4B = ENABLE_C4B
--设置类型
cc.exports.LanguageType = LanguageType
-- 牌型整理函数
cc.exports.ANALYSE_POKERS = ANALYSE_POKERS
-- 交互特效
cc.exports.EmotionEffCnf = EmotionEffCnf