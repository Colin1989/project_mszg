--/**
-- *  @Brief: 援助
-- *  @Created by fjut on 14-03-18
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerAssistance = {}
local rootNode = nil

-- net tb
local tbResp = {}
-- 选中的tb的tag
local donorTag = nil
-- 选择的援助对象
local donorInfo = nil
-- tag 增量
local cellTagAdd = 10000
-- 打钩图
local checkBox = nil
-- scrollview
local scrollView = nil
-- json file
local guiJsonFile = "Assistance_1.ExportJson"
 
 -- 动态UI
local function loadDynamicUI()
	--
end

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	cclog(sender:getName())
	-- 进入战斗
	if sender:getName() == "btn_in" then
		if donorTag == nil then
			-- 提醒
			Toast.show(GameString.get("Assistance_XZYZDX_TIPS"))
			return
		end
		local tb = req_select_donor()
		tb.donor_id = tbResp[donorTag].role_id
		cclog("援助ID:"..tb.donor_id)
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_select_donor_result"]) 
	-- 上一级
	elseif sender:getName() == "btn_pre" then 
		UIManager.pop("UI_Assistance")
	end	
end

-- scrollView cell call 
local function cellCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	cclog("call tag:"..sender:getTag())
	local cell = scrollView:getChildByTag(sender:getTag())
	checkBox:setVisible(true)
	checkBox:setPosition(ccp(cell:getPosition().x, cell:getPosition().y))
	donorTag= sender:getTag() - cellTagAdd
end

-- 获取cell
local function getCellNode(k, tb)
	local cellNode = UIImageView:create() --CommonFunc_getSprite("1000.png", "headImg.plist")
	cellNode:loadTexture("points_normal.png")
	--local widget = UIWidget:create()
	--widget:setSize(cellNode:getContentSize())
	--widget:addChild(cellNode)
	
	-- 头像
	local imgHead = CommonFunc_getImgView(ModelPlayer.getRoleInitDetailMessageById(tb.role_type).heroicon)
	imgHead:setPosition(ccp(50, 0))
	imgHead:setScale(0.8)
	cellNode:addChild(imgHead)
	-- 等级
	local labelLv = CommonFunc_getLabel(string.format("%d", tb.level), 20)
	labelLv:setPosition(ccp(200, 50))
	cellNode:addChild(labelLv)
	-- 职业
	local labelRole = CommonFunc_getLabel(CommonFunc_GetRoletypeString(tb.role_type), 20)
	labelRole:setPosition(ccp(200, 0))
	cellNode:addChild(labelRole)
	-- 友情点
	local labelFri = CommonFunc_getLabel(string.format("%d", tb.friend_point), 20)
	labelFri:setPosition(ccp(300, 50))
	cellNode:addChild(labelFri)
	-- 战斗力
	local labelPower = CommonFunc_getLabel(string.format("%d", tb.power), 20)
	labelPower:setPosition(ccp(300, 0))
	cellNode:addChild(labelPower)
	-- 技能头像
	local imgSkill = CommonFunc_getImgView(LogicTable.getItemById(tb.sculpture).icon)
	imgSkill:setPosition(ccp(370, 0))
	imgSkill:setScale(0.8)
	cellNode:addChild(imgSkill)
	-- set cell tag
	cellNode:registerEventScript(cellCall)
	cellNode:setTouchEnabled(true)
	cellNode:setTag(cellTagAdd+k)

	return cellNode
end

-- show 消息推送scrollview
local function showMsgScrollView(tb)
	if tb == nil or #tb <= 0 then
		return
	end
	
	--[[ -- test
	for k, value in next, (tb) do
		cclog(value.role_id.." "..value.rel.." "..value.level.." "..value.nick_name )
	end
    tb.role_id = 0
    tb.rel = 0 -- 关系 1好友 2其他
    tb.level = 0
    tb.role_type = 0 
    tb.nick_name = ""
    tb.friend_point = 0 -- 友情点
    tb.power = 0
    tb.sculpture = 0 -- 雕纹
	--]]
	
	-- 援军列表
	local tbCellInfo = {}
	for k, value in next, (tb) do
		local cellNode = getCellNode(k, value)
		table.insert(tbCellInfo, cellNode)
	end
	scrollView = CommonFunc_getScrollView(rootNode, "scrollView_assistance", tbCellInfo, nil, "slider_assistance")
	-- 打钩图
	checkBox = CommonFunc_getImgView("xx.png")
	checkBox:setVisible(false)
	scrollView:addChild(checkBox)
end

-- 初始化静态UI
local function initUI()
	donorTag = nil
	-- 进入战斗btn event
	local btnIn = CommonFunc_getNodeByName(rootNode, "btn_in", "UIButton")
    btnIn:registerEventScript(btnCall)
	-- 上一步btn event
	local btnPre = CommonFunc_getNodeByName(rootNode, "btn_pre", "UIButton")
    btnPre:registerEventScript(btnCall)				
end

-- 援军列表
local function Handle_req_assistance(resp)
	if resp.donors == nil or #resp.donors == 0 then
		cclog("rec error!")
		return
	end
	
	for k, value in next, (resp.donors) do 
		cclog(value.nick_name)
	end
	tbResp = resp.donors
	showMsgScrollView(resp.donors)
end

-- 援军确定
local function Handle_req_assiSelected(resp)
	if resp.result == common_result["common_success"] then
		-- 援军
		donorInfo = LogicTable.getItemById(tbResp[donorTag].sculpture)
		cclog("援军技能Id:"..donorInfo.sub_id)
		cclog("技能头像:"..donorInfo.icon)
		-- 进入战斗
		LayerMain.switchLayer("EnterGame")
	end
end

-- 获取选中的援军
LayerAssistance.getDonorInfo = function()
	return donorInfo
end

-- net 请求
local function netReq()
	-- 援助UI
	NetSocket_registerHandler(NetMsgType["msg_notify_assistance_list"], notify_assistance_list(), Handle_req_assistance)
	local tb = req_assistance_list()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_assistance_list"]) 
	-- 确定援助
	NetSocket_registerHandler(NetMsgType["msg_notify_select_donor_result"], notify_select_donor_result(), Handle_req_assiSelected)
end
	
LayerAssistance.init = function(bundle)
	-- add gui
	--[[
	rootNode = GUIReader:shareReader():widgetFromJsonFile(guiJsonFile)
	if rootNode == nil then
		cclog("LayerAssistance init nil") 
		return nil
	end	
	--]]
	rootNode = CommonFunc_getNodeByName(UIManager.findLayerByTag("UI_Assistance"), "pannel_assistance")

	initUI()
	netReq()
	
	return rootNode
end

LayerAssistance.destory = function()

end




