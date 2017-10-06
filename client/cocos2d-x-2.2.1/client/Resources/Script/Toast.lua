----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-3
-- 描述：系统消息提示
----------------------------------------------------------------------
require "sys_msg"

local mWinSize = CCDirector:sharedDirector():getWinSize()
local mNormalShowTable = {}	-- 文本显示列表,用于一个接一个显示

LAYER_ORDER = 200			--toast 渲染层级

local TAR_TOAST_LABEL = 20149200

Toast = {}

local function createCCLabel(text,pos,color,FontSize)
	local label = CCLabelTTF:new()
    label:init()
    label:autorelease()
    label:setFontName("fzzdh.TTF")
    label:setFontSize(FontSize)
	label:setPosition(pos)
	label:setString(text)
	label:setColor(color)
	local FLY_TIME = 2.5
	
	local downIng = CCEaseBackOut:create(CCMoveBy:create(FLY_TIME,CCPointMake(0,200)))
	local fadeIn = CCFadeOut:create(FLY_TIME);
	local action = CCSpawn:createWithTwoActions(fadeIn,downIng)
	
	function callFuncN(sender)
		sender:getParent():removeChild(sender, true)
	end
	
	label:runAction(CCSequence:createWithTwoActions(action, CCCallFuncN:create(callFuncN)))

	g_rootNode:addChild(label,LAYER_ORDER)
end 

Toast.Textstrokeshow =function(text,color,strokColor,FontSize)
	Toast.show(text)
	--[[ 描边方法已经废弃
	local winSize = CCDirector:sharedDirector():getWinSize()
	local pos = ccp(winSize.width/2, winSize.height/2)
	
	local pos1 = ccp(winSize.width/2+1, winSize.height/2)
	local pos4 = ccp(winSize.width/2-1, winSize.height/2)
	
	local pos2 = ccp(winSize.width/2, winSize.height/2+1)
	local pos3 = ccp(winSize.width/2, winSize.height/2-1)

	local pos5 = ccp(winSize.width/2-1, winSize.height/2-1)
	local pos6 = ccp(winSize.width/2+1, winSize.height/2+1)
	
	local pos7 = ccp(winSize.width/2+1, winSize.height/2-1)
	local pos8 = ccp(winSize.width/2-1, winSize.height/2+1)
	
	createCCLabel(text,pos1,strokColor,FontSize)
	createCCLabel(text,pos2,strokColor,FontSize)
	createCCLabel(text,pos3,strokColor,FontSize)
	createCCLabel(text,pos4,strokColor,FontSize)
	createCCLabel(text,pos5,strokColor,FontSize)
	createCCLabel(text,pos6,strokColor,FontSize)
	createCCLabel(text,pos7,strokColor,FontSize)
	createCCLabel(text,pos8,strokColor,FontSize)
	
	createCCLabel(text,pos,color,FontSize)
	]]--
end

----------------------------------------------------------------------
-- 计算字符串长度 (UTF-8)
function Calculate_Str_len(text)
	local totalSize = string.len(text)
	local numberSize = 0
	for key in string.gmatch(text, "([0-9a-zA-Z,.]+)") do
		numberSize = numberSize + string.len(key)
	end
	return (totalSize - numberSize)/3 + numberSize
end

-- 显示屏幕居中,淡出效果文本
local function addText(text, parent, zOrder)
	if nil == text or "" == text then
		return
	end
	local fontSize = 22
	local preferredWidth = Calculate_Str_len(text)*fontSize + fontSize*2
	local preferredHeight = fontSize*2
	-- 背景
	local bg = CCScale9Sprite:create("sysmsg.png")
	bg:setCapInsets(CCRectMake(15, 15, 10, 10))
	bg:setPreferredSize(CCSizeMake(preferredWidth, preferredHeight))
	bg:setAnchorPoint(ccp(0.5,0.5))
    bg:setPosition(ccp(mWinSize.width/2, mWinSize.height/2))
	parent:addChild(bg, zOrder)
	-- 文本
	local label = CCLabelTTF:new()
    label:init()
    label:autorelease()
    label:setFontName("fzzdh.TTF")
    label:setFontSize(fontSize)
	label:setString(text)
	label:setPosition(ccp(preferredWidth/2, preferredHeight/2))
	label:setAnchorPoint(ccp(0.5 ,0.5))
	bg:addChild(label)
	-- 动画
	local function callFuncN(sender)
		table.remove(mNormalShowTable, 1)
		sender:removeFromParentAndCleanup(true)
	end
	local arr1 = CCArray:create()
	arr1:addObject(CCDelayTime:create(3.0))
	arr1:addObject(CCFadeOut:create(1.5))
	label:runAction(CCSequence:create(arr1))
	local arr2 = CCArray:create()
	arr2:addObject(CCDelayTime:create(3.0))
	arr2:addObject(CCFadeOut:create(1.5))
	arr2:addObject(CCCallFuncN:create(callFuncN))
	bg:runAction(CCSequence:create(arr2))
	-- 保存
	for key, value in pairs(mNormalShowTable) do
		if value then
			local x, y = value:getPosition()
			value:setPosition(ccp(x, y + 50))
		end
	end
	table.insert(mNormalShowTable, bg)
	bg:setTag(#mNormalShowTable + TAR_TOAST_LABEL)
	if #mNormalShowTable > 3 then
		table.remove(mNormalShowTable, 1)
		parent:removeChildByTag(TAR_TOAST_LABEL+1, true)
		for key, value in pairs(mNormalShowTable) do
			if value then
				value:setTag(TAR_TOAST_LABEL + key)
			end
		end
	end
end
----------------------------------------------------------------------
----显示文本 自动消失
Toast.show = function(text)
	addText(text,g_rootNode,LAYER_ORDER)
end
----------------------------------------------------------------------
----显示文本跑马灯 自动消失 
Toast.Moveshow = function(text)
	local toast = CCLabelTTF:new()
    toast:init()
    toast:autorelease()
    toast:setFontName("Marker Felt")
    toast:setFontSize(48)
    toast:setString(text)
	
--[[	local action = CCSequence:createWithTwoActions(
	CCDelayTime:create(3.0),				--预留一个闪烁效果
	CCFadeOut:create(1.5))--]]
	local fontWidth = toast:boundingBox().size.width
	
	local action = CCMoveTo:create(3.0, ccp(-1*fontWidth,2*mWinSize.height/3));
	toast:setPosition(ccp(mWinSize.width+fontWidth,2*mWinSize.height/3));
	--toast:setAnchorPoint(ccp(-1,-1))
	function FucnC_DeleteThis(sender)
		sender:getParent():removeChild(sender,true)
	end
	
	local action2 = CCSequence:createWithTwoActions(action,CCCallFuncN:create(FucnC_DeleteThis))			
	
	toast:runAction(action2);
    --detalTTf->setScale(2.0f);
	g_rootNode:addChild(toast,LAYER_ORDER)
end

-- 从右向左移
local function moveRightToLeft(panel, label, speed, callBack)
	local anchorPoint = panel:getAnchorPoint()
	label:setAnchorPoint(ccp(0, 0.5))
	label:setPosition(ccp((1 - anchorPoint.x)*panel:getSize().width, (0.5 - anchorPoint.y)*panel:getSize().height))
	local moveDistance = panel:getSize().width + label:getSize().width
	local moveByAction = CCMoveBy:create(moveDistance/speed, ccp(-moveDistance, 0))
	label:runAction(CCSequence:createWithTwoActions(moveByAction, CCCallFunc:create(callBack)))
end

-- 从下向上(如果长度超出,则从右向左移)移动显示,向上移动消失
local function moveDownToUpAndRightToLeft(panel, label, vSpeed, hSpeed, callBack)
	local hMoveDistance = 0
	local anchorPoint = panel:getAnchorPoint()
	if label:getSize().width > panel:getSize().width then
		label:setAnchorPoint(ccp(0, 0.5))
		label:setPosition(ccp(-anchorPoint.x * panel:getSize().width, -anchorPoint.y*panel:getSize().height - label:getSize().height/2))
		hMoveDistance = label:getSize().width - panel:getSize().width
	else
		label:setAnchorPoint(ccp(0.5, 0.5))
		label:setPosition(ccp((0.5 - anchorPoint.x)*panel:getSize().width, -anchorPoint.y*panel:getSize().height - label:getSize().height/2))
	end
	local vMoveDistance = panel:getSize().height/2 + label:getSize().height/2
	local actionArr = CCArray:create()
	actionArr:addObject(CCMoveBy:create(vMoveDistance/vSpeed, ccp(0, vMoveDistance)))
	actionArr:addObject(CCDelayTime:create(2))
	local callfuncAction = nil
	if 0 == hMoveDistance or nil == hSpeed or hSpeed <= 0 then
		actionArr:addObject(CCMoveBy:create(vMoveDistance/vSpeed, ccp(0, vMoveDistance)))
		callfuncAction = CCCallFunc:create(callBack)
	else
		callfuncAction = CCCallFunc:create(function()
			local arr = CCArray:create()
			arr:addObject(CCMoveBy:create(hMoveDistance/hSpeed, ccp(-hMoveDistance, 0)))
			arr:addObject(CCDelayTime:create(1))
			arr:addObject(CCMoveBy:create(vMoveDistance/vSpeed, ccp(0, vMoveDistance)))
			arr:addObject(CCCallFunc:create(callBack))
			label:runAction(CCSequence:create(arr))
		end)
	end
	actionArr:addObject(callfuncAction)
	label:runAction(CCSequence:create(actionArr))
end

-- 显示公告
Toast.showNotice = function(parent, panelWidth, panelHeight, panelPos, overCallFunc)
	-- 条件判定
	if true == NoticeLogic.isBroading() then
		return
	end
	local notice = NoticeLogic.popNotice()
	if nil == notice then
		return
	end
	-- 创建控件
	parent:setVisible(true)
	local noticePanel = parent:getChildByName("notice_panel")
	if nil == noticePanel then
		noticePanel = UILayout:create()
		noticePanel:setName("notice_panel")
		noticePanel:setSize(CCSizeMake(panelWidth, panelHeight))
		noticePanel:setClippingEnabled(true)
		noticePanel:setPosition(panelPos)
		parent:addChild(noticePanel)
	end
	local noticeLabel = tolua.cast(noticePanel:getChildByName("notice_label"), "UILabel")
	if nil == noticeLabel then
		noticeLabel = UILabel:create()
		noticeLabel:setName("notice_label")
		noticeLabel:setFontSize(25)
		noticeLabel:setAnchorPoint(ccp(0, 0.5))
		noticeLabel:setPosition(ccp(panelWidth, panelHeight/2))
		noticePanel:addChild(noticeLabel)
	end
	-- 回调
	local function actionCallBack()
		NoticeLogic.setBroading(false)
		if true == MessageMgr.existMsg() then
			EventCenter_post(EventDef["ED_POST"])
		else
			if "function" == type(overCallFunc) then
				overCallFunc()
			end
		end
	end
	-- 播放
	NoticeLogic.setBroading(true)
	noticeLabel:setText(NoticeLogic.getContent(notice))
	local noticeType = NoticeLogic.checkType(notice)
	if "mt_sys_notice" == noticeType then
		moveRightToLeft(noticePanel, noticeLabel, 200, actionCallBack)
	elseif "mt_normal_notice" == noticeType or "mt_game_notice" == noticeType then
		moveDownToUpAndRightToLeft(noticePanel, noticeLabel, 80, 200, actionCallBack)
	elseif "mt_chat_notice_self" == noticeType or "mt_chat_notice_other" == noticeType then
		moveDownToUpAndRightToLeft(noticePanel, noticeLabel, 80, nil, actionCallBack)
	end
end

-- 处理公告
local function handlePost()
	if LayerGameUI.mRootView then
		return
	end
	local root = UIManager.findLayerByTag("UI_Main")
	if nil == root then
		return
	end
	local imgPostBg = root:getWidgetByName("systempenel")
	if nil == imgPostBg then
		return
	end
	Toast.showNotice(imgPostBg, imgPostBg:getSize().width - 62, imgPostBg:getSize().height - 10, ccp(62, 4))
end

EventCenter_subscribe(EventDef["ED_POST"], handlePost)

-- 处理通知系统消息网络消息事件
local function handleNotifySysMsg(resp)
	local sysMsgStr = sys_msg[resp.code]
	if nil == sysMsgStr then
		Toast.show(GameString.get("SYSTEM_STR_01", resp.code, "nil"))
		return
	end
	local errorTb = LogicTable.getErrorById(sysMsgStr)
	if nil == errorTb then
		Toast.show(GameString.get("SYSTEM_STR_01", resp.code, sysMsgStr))
		return
	end
	local sysMsgText = string.format(errorTb.text, unpack(resp.Params))
	if "sg_service_error" == sysMsgStr then
		assert(false, sysMsgText)
		return
	end
	local errorType = tonumber(errorTb.type)
	if 1 == errorType then			-- 普通消息
		if tonumber(resp.code) == 2 then
			TOAST_FLAG = true
		end
		Toast.show(sysMsgText)
	elseif 2 == errorType then 		-- 带对话框
		CommonFunc_CreateDialog(sysMsgText)
	elseif 3 == errorType then		-- 跑马灯(后台发的有循环次数的系统消息)
		NoticeLogic.pushSystemNotice(resp.Params[3], resp.Params[1], resp.Params[2])
	elseif 4 == errorType then		-- 跑马灯
		NoticeLogic.pushGameNotice(sysMsgText)
	else
		Toast.show("error_type:"..errorType..", sys_msg_text:"..sysMsgText)
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_sys_msg"], notify_sys_msg, handleNotifySysMsg)


