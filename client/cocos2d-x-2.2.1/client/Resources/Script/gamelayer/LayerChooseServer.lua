----------------------------------------------------------------------
-- 作者：李慧琴
-- 日期：2014-3-31
-- 描述：选择服务器界面
----------------------------------------------------------------------
LayerChooseServer = {}
LayerAbstract:extend(LayerChooseServer)
local chooseSerLayerRoot = nil		---当前界面root节点
local curServerName = nil			--点击的当前item的服务器名字
local mCurPanel						--上次登录的panel
local mOpenData = {}				--开服的服务器数据

ServerSpeed =
{
	["smooth"] 	= 1,
	["crowd"] 	= 2,
	["maint"] 	= 3
}

ServerState =
{
	["Reco"] =  1,		--推荐服
	["new"]	 =  2,		--新服
	["hot"] = 3,		--热门服
}
----------------------------------------------------------------------
--确定键和返回键触发的函数
LayerChooseServer.onClick = function(weight)
	local weightName = weight:getName()
	if weightName == "Button_sure" then			--确定
		UIManager.pop("UI_ChooseServer")
		ChannelProxy.setUmsAgentEvent("STAT_LOGIN")
		LayerBegin.linkAndCheckVer()	
	elseif weightName == "Button_close" then	--返回
		UIManager.pop("UI_ChooseServer")
	end
end
----------------------------------------------------------------------
--根据服务器的速度，加载图片（顺畅，拥挤，维护）
local function  loadSpeedImage(speed)
	if ServerSpeed["smooth"] == tonumber(speed) then
		return  "server_free.png"
	elseif ServerSpeed["crowd"] == tonumber(speed) then
		return  "server_crowd.png"
	elseif ServerSpeed["maint"] == tonumber(speed) then
		return  "server_repair.png"
	end
end
----------------------------------------------------------------------
--根据服务器的状态，加载图片（推荐，新服）
local function  loadStatuImage(statu)
	if ServerState["Reco"] == tonumber(statu) then
		return  "server_recommend.png"
	elseif ServerState["new"] == tonumber(statu) then
		return  "server_new.png"
	elseif ServerState["hot"] == tonumber(statu) then
		return  "server_gray.png"
	else
		return "touming.png"
	end
end
----------------------------------------------------------------------
--根据服务器的状态和速度，加载panel的背景图片
local function loadPanelImage(statu,speed)
	if ServerState["Reco"] == tonumber(statu) or ServerState["new"] == tonumber(statu)
		or ServerState["hot"] == tonumber(statu) then
		return  "server_purple_d.png"
	elseif  ServerSpeed["maint"] == tonumber( speed)  then
		return "server_gray.png"
	else
		return "server_green_d.png"
	end
end
----------------------------------------------------------------------
--根据服务器的状态和速度，加载panel的选中背景图片（开服的）
local function loadPanelHImage(statu,speed)
	if ServerState["Reco"] == tonumber(statu) or ServerState["new"] == tonumber(statu) 
		or ServerState["hot"] == tonumber(statu) then
		return  "server_purple_h.png"
	else
		return "server_green_h.png"
	end
end
----------------------------------------------------------------------
--点击列表触发的函数(开服的)
local function itemClick(types,widget)
	if types == "releaseUp" then
		if widget:getName() ~= "Panel_server" then
			for key,val in pairs(mOpenData) do
				local item = chooseSerLayerRoot:getWidgetByName(string.format("item_%d",key))
				tolua.cast(item,"UILayout")
				item:setBackGroundImage(loadPanelImage(val.corner_mark,val.status))
			end	
			
			local num = widget:getTag()/100
			local data = chooseServerDataCache.getIpconfigRow(mOpenData[num].ip, mOpenData[num].port)
			widget:setBackGroundImage(loadPanelHImage(data.corner_mark,data.status))
			LayerBegin.setServerData(data)	
		end	
	end
end
----------------------------------------------------------------------
--创建服务器横条
local function  setServerItem (name,statu,speed)
	local  itemPanel = UILayout:create()                --整个大的容器
    itemPanel:setSize(CCSizeMake(256,87))
	itemPanel:setTouchEnabled(true)
	itemPanel:setAnchorPoint(ccp(0.5,0.5))
	itemPanel:setBackGroundImage(loadPanelImage(statu,speed))
	if speed ~= ServerSpeed["maint"] then
		itemPanel:registerEventScript(itemClick)
	else
		--itemPanel:registerEventScript(CloseItemClick)
	end
	local nameLabel = UILabel:create()                  --名字
	nameLabel:setTouchEnabled(false)
	nameLabel:setSize(CCSizeMake(135,44))
    nameLabel:setAnchorPoint(ccp(0.5,0.5))
    nameLabel:setPosition(ccp(135,44))
	nameLabel:setFontSize(26)
    nameLabel:setTextHorizontalAlignment(kCCTextAlignmentCenter)
    nameLabel:setText(name)
	itemPanel:addChild(nameLabel)
	local statusImage = UIImageView:create()                  --服务器状态
	statusImage:setSize(CCSizeMake(59,63))
	statusImage:setScale(0.80)
	statusImage:setTouchEnabled(false)
    statusImage:setAnchorPoint(ccp(0.5,0.5))
    statusImage:setPosition(ccp(32,54))
    statusImage:loadTexture(loadStatuImage(statu))
    itemPanel:addChild(statusImage)
	local speedImage = UIImageView:create()                  --服务器速度
	speedImage:setSize(CCSizeMake(33,43))
	speedImage:setTouchEnabled(false)
    speedImage:setAnchorPoint(ccp(0.5,0.5))
    speedImage:setPosition(ccp(223,40))
    speedImage:loadTexture(loadSpeedImage(speed))
    itemPanel:addChild(speedImage)
	return itemPanel
end
----------------------------------------------------------------------
--获取当前服务器名字，根据登录界面的设置
local function setCurServerNameByLogin()
	local server = chooseServerDataCache.getServerData()
	mCurPanel = chooseSerLayerRoot:getWidgetByName("Panel_server")
	tolua.cast(mCurPanel,"UILayout")
	local statu = server.corner_mark
	local speed = server.status
	mCurPanel:setBackGroundImage(loadPanelImage(statu,speed))
	curServerName = chooseSerLayerRoot:getWidgetByName("Label_server_name")
	tolua.cast(curServerName,"UILabel")
	curServerName:setText(server.name)
	curServerStatu = chooseSerLayerRoot:getWidgetByName("ImageView_recommend")
	tolua.cast(curServerStatu,"UIImageView")
	if loadStatuImage(statu) == nil then
		curServerStatu:setVisible(false)	
	else
		curServerStatu:setVisible(true)	
		curServerStatu:loadTexture(loadStatuImage(statu))
	end
	curServerSpeed = chooseSerLayerRoot:getWidgetByName("ImageView_status")
	tolua.cast(curServerSpeed,"UIImageView")
	curServerSpeed:loadTexture(loadSpeedImage(speed))
end
----------------------------------------------------------------------
--设置开服服务器列表
local function setOpenServerList()
	scroll = tolua.cast(chooseSerLayerRoot:getWidgetByName("ScrollView_list"), "UIScrollView")	--开服的
	local data = {}									--设置开服的列表
	for k,v in pairs(mOpenData) do
		local ItemDate = v
		ItemDate.key = k
		table.insert(data,ItemDate)
	end 
		--创建每一项
		local function createScrollItem(ItemDate)
			local item = setServerItem(ItemDate.name,ItemDate.corner_mark,ItemDate.status)
			item:setTag(ItemDate.key*100)
			item:setName(string.format("item_%d",ItemDate.key))
			return item
		end
	UIEasyScrollView:create(scroll,data,createScrollItem,50, true,2,2,true)	
end
----------------------------------------------------------------------
--设置服务器列表
local function setServerList()
	-- local serverData = chooseServerDataCache.getIpconfigTable(CONFIG["game_server_type"])
	local serverData = chooseServerDataCache.getIpconfigTable()
	mOpenData = {}		--保存开服的数据
	
	for key,value in pairs(serverData) do			--根据服务器的维护情况，分类数据
		if ServerSpeed["maint"] == value.status then
		elseif value.status ~= ServerSpeed["maint"] then
			table.insert(mOpenData,value)
		end
	end
	setOpenServerList()
end
----------------------------------------------------------------------
-- 初始化
LayerChooseServer.init = function()
	chooseSerLayerRoot = UIManager.findLayerByTag("UI_ChooseServer")
	setOnClickListenner("Button_sure")
	setOnClickListenner("Button_close")	
	setCurServerNameByLogin()
	setServerList()			
end
----------------------------------------------------------------------

