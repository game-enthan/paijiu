local LoginUI = class("LoginUI", BaseUI)

LoginUI._widgetsCnf = {
	{"imgBg"},
	{"aniNode"},
	{"btnWChat", visible = true, click = "onWChatClickHandler"},
	{"btnVisitor", visible = false, click = "onVisitorClickHandler"},
	{"btnReview", visible = false, click = "onReviewClickHandler"},
	{"btnupdatexbw", visible = false, click = "onUpdatexbwClickHandler"},
	{"imgProto"},
	{"txtVersion"},
}

function LoginUI:ctor()
	BaseUI.ctor(self, "res/LoginUI")
	self:listenEvents()
	self:initView()
	-- self.imgProto:setVisible(false)
end

function LoginUI:listenEvents()
	self:listenEvent(EventEnum.responseIpInfo, "onResponseIpInfoHandler")
end

function LoginUI:initView()
	-- logo动画
	local aniLogo = cc.CSLoader:createNode("res/animation/logoani.csb")
	local actionLogo = cc.CSLoader:createTimeline("res/animation/logoani.csb")
	aniLogo:runAction(actionLogo)
	actionLogo:play("ani", true)
	self.aniNode:addChild(aniLogo, 1)
	-- 微信登录按钮动画
	local aniWxLogin = cc.CSLoader:createNode("res/animation/wxloginani.csb")
	local actionWxLogin = cc.CSLoader:createTimeline("res/animation/wxloginani.csb")
	local sizeOfWxLogin = self.btnWChat:getContentSize()
	aniWxLogin:runAction(actionWxLogin)
	actionWxLogin:play("ani", true)
	self.btnWChat:addChild(aniWxLogin, 1)
	aniWxLogin:setPosition(cc.p(sizeOfWxLogin.width / 2, sizeOfWxLogin.height / 2))
	-- 游客登录按钮动画
	local aniYkLogin = cc.CSLoader:createNode("res/animation/ykani.csb")
	local actionYkLogin = cc.CSLoader:createTimeline("res/animation/ykani.csb")
	local sizeOfYkLogin = self.btnVisitor:getContentSize()
	aniYkLogin:runAction(actionYkLogin)
	actionYkLogin:play("ani", true)
	self.btnVisitor:addChild(aniYkLogin, 1)
	aniYkLogin:setPosition(cc.p(sizeOfYkLogin.width / 2, sizeOfYkLogin.height / 2))
	if not G_TEST then
		self.btnWChat:setVisible(false)
	end
	local isXbw = AccountController.loadUpdateXbwData()
	self.btnupdatexbw:setVisible(not isXbw.isXbw)
	self.txtVersion:setString(string.format("当前版本号：%s", CUR_VERSION))


	-- local poker = cc.Sprite:create("res/hdpoker/1.png")
	-- local gridPoker = cc.NodeGrid:create()

	-- self._layer:addChild(gridPoker, 100)
	-- gridPoker:setPosition(cc.p(GL_SIZE.width / 2, GL_SIZE.height / 2))
	-- gridPoker:addChild(poker)
	-- self._sprPoker = gridPoker

end

function LoginUI:onEnter()
	BaseUI.onEnter(self)
end

function LoginUI:onExit()
	BaseUI.onExit(self)
end

function LoginUI:onResponseIpInfoHandler(eventData)
	-- 审核版(只能走微信登录)
	if LOCAL_REVIEWING_FLAG then
		self.btnWChat:setVisible(false)
		self.btnVisitor:setVisible(false)
		self.btnReview:setVisible(true)
	-- 非审核版(只能走游客登录)
	else
		self.btnWChat:setVisible(true)
		self.btnVisitor:setVisible(false)
	end
end

function LoginUI:onWChatClickHandler()
	G_WX_CODE = ""
	if AccountController.getIsTempAccoutValid() then
		Game:initNetWork()
	else
		-- windows平台
		if device.platform == "windows" then
			G_WX_CODE = "9999"
			Game:initNetWork()
		else
			wxLogin()
			local eventData = {
				uiName = "WaitingUI",
				parms = {5},
			}
			EventBus:dispatchEvent(EventEnum.openUI, eventData)
		end
	end
end

function LoginUI:onVisitorClickHandler()
end

function LoginUI:onReviewClickHandler()
	if AccountController.getIsTempAccoutValid() then
		Game:initNetWork()
	else	
		G_WX_CODE = "9999"
		Game:initNetWork()
	end
end

function LoginUI:onUpdatexbwClickHandler()
	AccountController.saveUpdateXbwData(true)
	self.btnupdatexbw:setVisible(false)
end

return LoginUI