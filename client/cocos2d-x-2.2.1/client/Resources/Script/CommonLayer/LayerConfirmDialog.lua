
--模态提示框

LayerConfirmDialog = {
}


--按钮事件表
local mButtonEvent = {}
local isPop = nil
local mLayerConfirmDialogRootLayer = nil

local mSysRootView  = nil

LayerAbstract:extend(LayerConfirmDialog)

--计数器ID
local mScheduleScriptEntryID = nil 


local function onClickEvent(typeName,widget)
	cclog("typeName:",typeName)	
	
	if typeName ~= "releaseUp" then
		return
	end
	local widgetName = widget:getName()

	if widgetName == "Panel_ConfirmDialog" then
		LayerConfirmDialog.onExit()
		
	elseif widgetName == "button_yes" then
		if mScheduleScriptEntryID ~= nil then
		--取消删除计时器
			cclog("取消删除计时器")
			mLayerConfirmDialogRootLayer:getScheduler():unscheduleScriptEntry(mScheduleScriptEntryID)
		end
		mScheduleScriptEntryID = nil
		mLayerConfirmDialogRootLayer = nil
		if isPop == nil or mButtonEvent[1] == nil then
			UIManager.pop("UI_ComfirmDialog")
		end
		if mButtonEvent[1] ~= nil then 
			mButtonEvent[1](mButtonEvent_Param[1])
		end
		
	elseif widgetName == "button_no" then
		LayerConfirmDialog.onExit()
		if mButtonEvent[2] ~= nil then 
			mButtonEvent[2](mButtonEvent_Param[2])
		end
		
	end
end

function LayerConfirmDialog.onExit()
	if mScheduleScriptEntryID ~= nil then
		--取消删除计时器
		cclog("取消删除计时器")
		mLayerConfirmDialogRootLayer:getScheduler():unscheduleScriptEntry(mScheduleScriptEntryID)
	end
	mScheduleScriptEntryID = nil
	-- mLayerConfirmDialogRootLayer = nil
	--UIManager.pop("UI_ComfirmDialog")
	LayerConfirmDialog.pop()
	
end

function LayerConfirmDialog.pop()
	UIManager.pop("UI_ComfirmDialog")
	
	--[[
	local scale = 1.2
	mSysRootView:stopAllActions()
	mSysRootView:setScale(1.0)

	local atc1 = CCEaseBackInOut:create(CCScaleBy:create(0.1, scale))
	local atc2 = CCEaseBackInOut:create(CCScaleBy:create(0.1, 0.1))
	local atc3 = CCCallFuncN:create(function(  sender)   
		UIManager.pop("UI_ComfirmDialog")
	end )
	local arr = CCArray:create()
	arr:addObject(atc1)
	arr:addObject(atc2)
	arr:addObject(atc3)
	mSysRootView:runAction( CCSequence:create(arr))
	]]--
end 

--[[
local structConfirm = {
	strText = "",
	buttonCount = 2,
	buttonName = {"确定","取消"},
	buttonEvent = {nil,nil}, --回调函数
	buttonEvent_Param = {nil,nil} --函数参数
}]]
--UIManager.push("UI_ComfirmDialog",structConfirm)
-- onCreate
LayerConfirmDialog.init = function (structConfirm)
	if mLayerConfirmDialogRootLayer ~= nil then
		cclog("ERROR :弹框出错")
	end
	
	mLayerConfirmDialogRootLayer = UIManager.findLayerByTag("UI_ComfirmDialog")
	--initButtonEvent()
	 mSysRootView = mLayerConfirmDialogRootLayer:getWidgetByName("sysmsg_2")
	FightAnimation_openX(mSysRootView)
	
	mButtonEvent = {}
	mButtonEvent_Param = {}
	isPop = nil
	
	local lable = mLayerConfirmDialogRootLayer:getWidgetByName("txt1")
	tolua.cast(lable,"UILabel")
	lable:ignoreContentAdaptWithSize(true)
	lable:setText(structConfirm.strText)
	
	local btn_yes = mLayerConfirmDialogRootLayer:getWidgetByName("button_yes")
	tolua.cast(btn_yes,"UIButton")
	local btn_no = mLayerConfirmDialogRootLayer:getWidgetByName("button_no")
	tolua.cast(btn_no,"UIButton")
	
	if structConfirm.buttonCount == 0 or structConfirm.buttonCount == nil then 
		btn_yes:setVisible(false)
		btn_no:setVisible(false)
		
		local panel = mLayerConfirmDialogRootLayer:getWidgetByName("Panel_ConfirmDialog")
		tolua.cast(btn_no,"UILayout")
		panel:registerEventScript(onClickEvent)		
			
		--设置定时器
		mScheduleScriptEntryID = mLayerConfirmDialogRootLayer:getScheduler():scheduleScriptFunc(LayerConfirmDialog.onExit,2,false)
	else
		if 1 ==  structConfirm.buttonCount then
			setWidget_Horizontal_Center(btn_yes)
			btn_no:setEnabled(false)
		end 
		
		mButtonEvent = structConfirm.buttonEvent
		isPop = structConfirm.isPop
		
		if structConfirm.buttonEvent_Param ~= nil then
			mButtonEvent_Param = structConfirm.buttonEvent_Param
		end
		
		structConfirm.buttonName = structConfirm.buttonName or {}
		
		local strName = structConfirm.buttonName[1] or GameString.get("sure")
		btn_yes:setVisible(true)
		btn_yes:setTitleText(strName)
		btn_yes:registerEventScript(onClickEvent)	
		
		strName = structConfirm.buttonName[2] or GameString.get("cancle")
		btn_no:setVisible(true)
		btn_no:setTitleText(strName)
		btn_no:registerEventScript(onClickEvent)
	end
end

LayerConfirmDialog.destroy = function()
	mLayerConfirmDialogRootLayer = nil
end