local ShopController = {}

function ShopController.getModel()
	return PlayerManager:getModel("Shop")
end

------------------------------ 网络接口 S ----------------------------
-- 请求商品列表
function ShopController.getProductsReq()
	NetCom:send(18000, {mall_type = 0})
end

-- 返回商品列表
function ShopController.getProductsRes(netData)
	ShopController.getModel():updateProducts(netData.product_list or {})
	ShopController.getModel():updatePayWayList(netData.payway_id_list or {})
	EventBus:dispatchEvent(EventEnum.shopProducts)
end

-- 支付请求
function ShopController.payReq(productId, payway)
	local netData = {
		product_id = productId,
		payway_id = payway,
		appid = 0,
		os = device.platform,
		appinfo = base64Encode(getAppInfo()),
	}
	if device.platform == "android" then
		netData.appid = G_ZZF_ANDROID_APP_ID
	elseif device.platform == "ios" then
		if onlySupportWrap() == 1 then
			netData.appid = G_ZZF_WRAP_APP_ID
		else
			netData.appid = G_ZZF_APPLE_APP_ID
		end
	else
		netData.appid = G_ZZF_ANDROID_APP_ID
	end
	NetCom:send(18002, netData)

end

-- 支付返回
function ShopController.payRes(netData)
	-- 订单返回成功
	if 0 == netData.ret then
		-- 网页支付，针对IOS特殊处理
		if netData.payway == 10 then
			openWebView(netData.pay_info)
			EventBus:dispatchEvent(EventEnum.openUI, {uiName = "PayUI", parms = {999999}})
		else
			sdkBuy(netData.payway, netData.pay_info)
		end
	elseif 1 == netData.ret then
		CommonFunc.showCenterMsg("不存在该玩家账号")
	elseif 2 == netData.ret then
		CommonFunc.showCenterMsg("不存在该产品")
	elseif 3 == netData.ret then
		CommonFunc.showCenterMsg("支付方式错误")
	end
end
------------------------------ 网络接口 E ----------------------------

cc.exports.ShopController = ShopController