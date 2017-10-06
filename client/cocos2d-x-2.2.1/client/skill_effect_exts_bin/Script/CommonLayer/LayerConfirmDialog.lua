
--模态提示框

LayerConfirmDialog = {
}


--按钮事件表
local mButtonEvent = {}

local mLayerConfirmDialogRootLayer = nil

LayerAbstract:extend(LayerConfirmDialog)

--计数器ID
local mScheduleScriptEntryID = nil 


local function onClickEvent(typeName,widget)
	print("typeName:",typeName)	
	
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
	
		if widgetName == "Panel_ConfirmDialog" then
			LayerConfirmDialog.onExit()
			
		elseif widgetName == "button_yes" then
			
			if mButtonEvent[1] ~= nil then 
				mButtonEvent[1](mButtonEvent_Param[1])
			end
			UIManager.pop("UI_ComfirmDialog")
		elseif widgetName == "button_no" then
		
			if mButtonEvent[2] ~= nil then 
				mButtonEvent[2](mButtonEvent_Param[2])
			end
			UIManager.pop("UI_ComfirmDialog")
		end
		
	end
	
end


function LayerConfirmDialog.onExit()

	if mScheduleScriptEntryID ~= nil then
		--取消删除计时器
		mLayerConfirmDialogRootLayer:getScheduler():unscheduleScriptEntry(mScheduleScriptEntryID)
		mScheduleScriptEntryID = nil
	end
	
	UIManager.pop("UI_ComfirmDialog")
	
end

--[[
local structConfirm = {
	strText = "",
	buttonCount = 0,
	buttonName = {"确定","取消"},
	buttonEvent = {nil,nil} --回调函数
	buttonEvent_Param = {nil,nil} --函数参数
}]]
--UIManager.push("UI_ComfirmDialog",structConfirm)
-- onCreate
LayerConfirmDialog.init = function (structConfirm)
	mLayerConfirmDialogRootLayer = UIManager.findLayerByTag("UI_ComfirmDialog")
	--initButtonEvent()
	
	mButtonEvent = {}
	mButtonEvent_Param = {}
	
	local lable = mLayerConfirmDialogRootLayer:getWidgetByName("txt1")
	tolua.cast(lable,"UILabel")
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
		mButtonEvent = structConfirm.buttonEvent
		
		if structConfirm.buttonEvent_Param ~= nil then
			mButtonEvent_Param = structConfirm.buttonEvent_Param
		end
		
		structConfirm.buttonName = structConfirm.buttonName or {}
		
		local strName = structConfirm.buttonName[1] or "确定"
		btn_yes:setVisible(true)
		btn_yes:setTitleText(strName)
		btn_yes:registerEventScript(onClickEvent)	
		
		strName = structConfirm.buttonName[2] or "取消"
		btn_no:setVisible(true)
		btn_no:setTitleText(strName)
		btn_no:registerEventScript(onClickEvent)
	end
	
	
end