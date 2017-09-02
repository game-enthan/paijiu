local RoomCreateUI = class("RoomCreateUI", BaseUI)

local RoomCreateController = RoomCreateController
local PlayType = PlayType
local pageCnf = {
	[PlayType.TT_BULLFIGHT] 		= "modules/view/room/BullPageUI",
--	[PlayType.TT_GOLDFLOWER] 		= "modules/view/room/GoldFlowerPageUI",
	[PlayType.TT_LANDLORD]			= "modules/view/room/LandlordPageUI",
	[PlayType.TT_SX_WK]				= "modules/view/room/WKPageUI",
	[PlayType.TT_TEN_HALF]			= "modules/view/room/TenHalfPageUI",
	[PlayType.TT_PUSH_PAIRS]		= "modules/view/room/PushPairsPageUI",
	[PlayType.TT_SX_SD]				= "modules/view/room/SXSDPageUI",
}

RoomCreateUI._widgetsCnf = {
	{"panContent", children = {
		{"sprLight", len = 6},
		{"btnCreate", click = "onCreateClickHandler"},
		{"btnCreateAgentRoom", click = "onCreateAgentRoomClickHandler"},
		{"btnClose", click = "onCloseClickHandler"},
		{"svPlayList", children = {
			{"btnPlayType1"},
		}},
		{"panContainer"},
	}},
}

function RoomCreateUI:ctor()
	BaseUI.ctor(self, "res/RoomCreateUI")
	self:init()
end

function RoomCreateUI:init()
	self._playTypeItems = {}
	self._pages = {}
	self:initPlayTypeList()
	local bullArr = {}
	for ind = 1, 6 do
		bullArr[#bullArr + 1] = self["sprLight"..ind]
	end
	CommonFunc.runColorBulbEffect(bullArr)
end

function RoomCreateUI:initPlayTypeList()
	local lastPlayType = RoomCreateController.getLastPlayType()
	if lastPlayType == PlayType.TT_LZ_WK then
		lastPlayType = PlayType.TT_SX_WK
	end
	local playTypeDatas = RoomCreateController.getPlayTypeDatas()
	for index, playTypeData in ipairs(playTypeDatas) do
		if playTypeData.playType == PlayType.TT_LZ_WK then
			table.remove(playTypeDatas, index)
			break
		end
	end
	local sizeOfItem = self.btnPlayType1:getContentSize()
	local sizeOfSv = self.svPlayList:getContentSize()
	local height = math.max(sizeOfSv.height, (sizeOfItem.height) * #playTypeDatas)
	local sizeOfInner = cc.size(sizeOfSv.width, height)
	self.svPlayList:setInnerContainerSize(sizeOfInner)
	local ind = 1
	for index, playTypeData in ipairs(playTypeDatas) do
		if playTypeData.playType == PlayType.TT_SX_WK then
			playTypeData.playName = "挖  坑"
		end
		local item
		if 1 == index then
			item = self.btnPlayType1
		else
			item = self.btnPlayType1:clone()
			self.svPlayList:addChild(item)
		end
		item:setTag(index)
		item:setVisible(true)
		item:setName("btnPlayType"..index)
		local iniPosY = sizeOfInner.height - sizeOfItem.height / 2
		local pos = cc.p(sizeOfSv.width / 2, iniPosY - (sizeOfItem.height) * (index - 1))
		item:setAnchorPoint(cc.p(0.5, 0.5))
		item:setPosition(pos)
		local btnName = item:getChildByName("btnName")
		btnName:setString(playTypeData.playName)
		self._playTypeItems[#self._playTypeItems + 1] = item
		item._playType = playTypeData.playType
		CommonFunc.bindClickFunc(item, handler(self, self.onItemClickHandler))
		if lastPlayType == playTypeData.playType then
			ind = index
		end
	end
	local isXbw = AccountController.getIsXbw()
	if not isXbw then
		lastPlayType = playTypeDatas[1].playType
	else
		self.svPlayList:jumpToPercentVertical((ind - 1) / (#self._playTypeItems - 1) * 100)
	end
	self:choosePlayType(lastPlayType)
end

function RoomCreateUI:onEnter()
	BaseUI.onEnter(self)
end

function RoomCreateUI:onExit()
	BaseUI.onExit(self)
end

function RoomCreateUI:choosePlayType(playType)
	local url = pageCnf[playType]
	if nil == url then
		CommonFunc.showCenterMsg("功能暂未开发")
		return
	end
	for __, item in ipairs(self._playTypeItems) do
		local boChoose = item._playType == playType
		item:setTouchEnabled(not boChoose)
		local url = boChoose and "res/com/com_tab_cho.png" or "res/com/com_tab_nor.png"
		item:loadTexture(url)
	end
	for __, page in pairs(self._pages) do
		page:setVisible(false)
	end
	local page = self._pages[playType]
	if nil == page then
		page = require(url).new(playType)
		self.panContainer:addChild(page)
		self._pages[playType] = page
	end
	page:setVisible(true)
	if page.refreshView then page:refreshView() end
	self._playType = playType
	self.btnCreateAgentRoom:setVisible(AccountController.getIsDaiLi() and playType == PlayType.TT_BULLFIGHT)
end

function RoomCreateUI:onItemClickHandler(sender)
	self:choosePlayType(sender._playType)
end

function RoomCreateUI:onCreateClickHandler()
	local choosePlayType = self._playType
	local page = self._pages[choosePlayType]
	if nil ~= page then
		if choosePlayType == PlayType.TT_SX_WK then
			choosePlayType = page:getChooseType()
		end
		local cnf = page:getCnf()
		RoomCreateController.createRoomReq(choosePlayType, cnf, false)
	end
end

function RoomCreateUI:onCreateAgentRoomClickHandler()
	local choosePlayType = self._playType
	local page = self._pages[choosePlayType]
	if nil ~= page then
		if choosePlayType == PlayType.TT_SX_WK then
			choosePlayType = page:getChooseType()
		end
		local cnf = page:getCnf()
		RoomCreateController.createRoomReq(choosePlayType, cnf, true)
	end
end

function RoomCreateUI:onCloseClickHandler()
	EventBus:dispatchEvent(EventEnum.closeUI, {uiName = "RoomCreateUI"})
end

return RoomCreateUI