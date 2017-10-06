--region LayerPayByRMB.lua
--Author : songcy
--Date   : 2015/02/11

LayerPayByRMB = {
}

LayerAbstract:extend(LayerPayByRMB)

--按钮事件表
local mButtonEvent = {}
local mRootView = nil
local mSysRootView  = nil
local mId = nil
--计数器ID
local mScheduleScriptEntryID = nil

local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		if widgetName == "Panel_35" then
			LayerPayByRMB.onExit()
		elseif widgetName == "button_yes" then
			if mScheduleScriptEntryID ~= nil then
			--取消删除计时器
				cclog("取消删除计时器")
				mRootView:getScheduler():unscheduleScriptEntry(mScheduleScriptEntryID)
			end
			
			mScheduleScriptEntryID = nil
			mRootView = nil
			UIManager.pop("UI_PayByRMB")
			if mButtonEvent[1] ~= nil then
				mButtonEvent[1](mButtonEvent_Param[1])
			end
		elseif widgetName == "button_no" then
			LayerPayByRMB.onExit()
			if mButtonEvent[2] ~= nil then 
				mButtonEvent[2](mButtonEvent_Param[2])
			end
		end
	end
end

LayerPayByRMB.onExit = function()
	if mScheduleScriptEntryID ~= nil then
		--取消删除计时器
		cclog("取消删除计时器")
		mRootView:getScheduler():unscheduleScriptEntry(mScheduleScriptEntryID)
	end
	mScheduleScriptEntryID = nil
	mRootView = nil
	--UIManager.pop("UI_PayByRMB")
	LayerPayByRMB.pop()
end

LayerPayByRMB.pop = function()
	UIManager.pop("UI_PayByRMB")
end

LayerPayByRMB.init = function (structConfirm)
	if mRootView ~= nil then
		cclog("ERROR :弹框出错")
	end
	
	mRootView = UIManager.findLayerByTag("UI_PayByRMB")
	--initButtonEvent()
	 mSysRootView = mRootView:getWidgetByName("ImageView_recharge")
	FightAnimation_openX(mSysRootView)
	
	mButtonEvent = {}
	mButtonEvent_Param = {}
	
	mId = structConfirm.id
	local rechargeRow = LogicTable.getRechargeRow(mId)
	local atlasRecharge = tolua.cast(mRootView:getWidgetByName("LabelAtlas_recharge"), "UILabelAtlas")
	atlasRecharge:setStringValue(tostring(rechargeRow.recharge_emoney))
	-- local contentSize = atlasRecharge:getContentSize()
	-- atlasRecharge:setScale(72/contentSize.width)
	local atlasReward = tolua.cast(mRootView:getWidgetByName("LabelAtlas_reward"), "UILabelAtlas")
	atlasReward:setStringValue(tostring(rechargeRow.reward_emoney))
	
	
	local lable = mRootView:getWidgetByName("Label_txt")
	tolua.cast(lable,"UILabel")
	-- lable:setTextAreaSize(CCSizeMake(330, 60))
	
	lable:ignoreContentAdaptWithSize(true)
	lable:setText(structConfirm.strText)
	
	local btn_yes = mRootView:getWidgetByName("button_yes")
	tolua.cast(btn_yes,"UIButton")
	local btn_no = mRootView:getWidgetByName("button_no")
	tolua.cast(btn_no,"UIButton")
	
	if structConfirm.buttonCount == 0 or structConfirm.buttonCount == nil then
		btn_yes:setVisible(false)
		btn_no:setVisible(false)
		
		local panel = mRootView:getWidgetByName("Panel_35")
		tolua.cast(btn_no,"UILayout")
		panel:registerEventScript(onClickEvent)
		
		--设置定时器
		mScheduleScriptEntryID = mRootView:getScheduler():scheduleScriptFunc(LayerPayByRMB.onExit,2,false)
	else
		if 1 ==  structConfirm.buttonCount then
			setWidget_Horizontal_Center(btn_yes)
			btn_no:setEnabled(false)
		end
		
		mButtonEvent = structConfirm.buttonEvent
		
		if structConfirm.buttonEvent_Param ~= nil then
			mButtonEvent_Param = structConfirm.buttonEvent_Param
		end
		
		structConfirm.buttonName = structConfirm.buttonName or {}
		
		-- local strName = structConfirm.buttonName[1] or GameString.get("GO_TO_PAY")
		btn_yes:setVisible(true)
		btn_yes:registerEventScript(onClickEvent)
		
		-- strName = structConfirm.buttonName[2] or GameString.get("cancle")
		btn_no:setVisible(true)
		btn_no:registerEventScript(onClickEvent)
	end
end

LayerPayByRMB.destroy = function()
	mRootView = nil
end