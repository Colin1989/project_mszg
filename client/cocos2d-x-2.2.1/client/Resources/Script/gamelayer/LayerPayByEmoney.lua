--region LayerPayByEmoney.lua
--Author : songcy
--Date   : 2015/02/11

--模态提示框
LayerPayByEmoney = {
}

local mRootView = nil
local mButtonEvent = {}		-- 按钮事件表
local mSysRootView  = nil
local mItem = nil

LayerAbstract:extend(LayerPayByEmoney)

--计数器ID
local mScheduleScriptEntryID = nil

local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		if widgetName == "Panel_20" then
			LayerPayByEmoney.onExit()
		elseif widgetName == "button_yes" then
			if mScheduleScriptEntryID ~= nil then
			--取消删除计时器
				cclog("取消删除计时器")
				mRootView:getScheduler():unscheduleScriptEntry(mScheduleScriptEntryID)
			end
			mScheduleScriptEntryID = nil
			mRootView = nil
			-- UIManager.pop("UI_PayByEmoney")
			if mButtonEvent[1] ~= nil then
				mButtonEvent[1](mButtonEvent_Param[1])
			end
		elseif widgetName == "button_no" then
			LayerPayByEmoney.onExit()
			if mButtonEvent[2] ~= nil then
				mButtonEvent[2](mButtonEvent_Param[2])
			end
		end
	end
end

LayerPayByEmoney.onExit = function()
	if mScheduleScriptEntryID ~= nil then
		--取消删除计时器
		cclog("取消删除计时器")
		mRootView:getScheduler():unscheduleScriptEntry(mScheduleScriptEntryID)
	end
	mScheduleScriptEntryID = nil
	mRootView = nil
	LayerPayByEmoney.pop()
end

LayerPayByEmoney.pop = function()
	UIManager.pop("UI_PayByEmoney")
end

LayerPayByEmoney.init = function (structConfirm)
	if mRootView ~= nil then
		cclog("ERROR :弹框出错")
	end
	
	mRootView = UIManager.findLayerByTag("UI_PayByEmoney")
	--initButtonEvent()
	 mSysRootView = mRootView:getWidgetByName("ImageView_22")
	FightAnimation_openX(mSysRootView)
	
	mButtonEvent = {}
	mButtonEvent_Param = {}
	mItem = structConfirm.item
	local emoneyItemRow = LogicTable.getRewardItemRow(3)		-- 魔石
	local pay = mRootView:getWidgetByName("pay")
	local pay_icon = tolua.cast(pay:getChildByName("icon"),"UIImageView")
	LayerFightReward_AddGirdWidget(emoneyItemRow.icon,0,nil,pay_icon)
	pay_icon:setTouchEnabled(true)
	local pay_name = tolua.cast(pay:getChildByName("name"),"UILabel")
	pay_name:setText(emoneyItemRow.name)
	local pay_num = tolua.cast(pay:getChildByName("num"),"UILabelAtlas")
	pay_num:setStringValue(tostring(mItem.emoney))
	
	local function clickSkillIcon(rewardImage)
		showLongInfoByRewardId(3,rewardImage)
	end
	local function clickSkillIconEnd(rewardImage)
		longClickCallback_reward(3,rewardImage)
	end
	UIManager.registerEvent(pay_icon, nil, clickSkillIcon, clickSkillIconEnd)
	
	if mItem.type == 1 then
		local logoMoney = mRootView:getWidgetByName("ImageView_179")
		logoMoney:setVisible(true)
		local logoItem = mRootView:getWidgetByName("ImageView_180")
		logoItem:setVisible(false)
		local tempTb = LogicTable.getRewardItemRow(1)
		local buy = mRootView:getWidgetByName("buy")
		local buy_icon = tolua.cast(buy:getChildByName("icon"),"UIImageView")
		LayerFightReward_AddGirdWidget(tempTb.icon,0,nil,buy_icon)
		buy_icon:setTouchEnabled(true)
		local buy_name = tolua.cast(buy:getChildByName("name"),"UILabel")
		buy_name:setText(tempTb.name)
		local buy_num = tolua.cast(buy:getChildByName("num"),"UILabelAtlas")
		buy_num:setStringValue(tostring(mItem.gold))
		
		local function clickSkillIcon(rewardImage)
			showLongInfoByRewardId(1,rewardImage)
		end
		local function clickSkillIconEnd(rewardImage)
			longClickCallback_reward(1,rewardImage)
		end
		UIManager.registerEvent(buy_icon, nil, clickSkillIcon, clickSkillIconEnd)
	elseif mItem.type == 3 then
		local logoMoney = mRootView:getWidgetByName("ImageView_179")
		logoMoney:setVisible(false)
		local logoItem = mRootView:getWidgetByName("ImageView_180")
		logoItem:setVisible(true)
		local tempTb = LogicTable.getItemById(mItem.item_id)
		local buy = mRootView:getWidgetByName("buy")
		local buy_icon = tolua.cast(buy:getChildByName("icon"),"UIImageView")
		LayerFightReward_AddGirdWidget(tempTb.icon,0,nil,buy_icon)
		buy_icon:setTouchEnabled(true)
		local buy_name = tolua.cast(buy:getChildByName("name"),"UILabel")
		buy_name:setText(tempTb.name)
		local buy_num = tolua.cast(buy:getChildByName("num"),"UILabelAtlas")
		buy_num:setStringValue(tostring(mItem.amount * mItem.item_amount))
		
		local function clickSkillIcon(rewardImage)
			showLongInfoByRewardId(mItem.item_id,rewardImage)
		end
		local function clickSkillIconEnd(rewardImage)
			longClickCallback_reward(mItem.item_id,rewardImage)
		end
		UIManager.registerEvent(buy_icon, nil, clickSkillIcon, clickSkillIconEnd)
	end
	
	local lable = mRootView:getWidgetByName("Label_txt")
	tolua.cast(lable,"UILabel")
	lable:ignoreContentAdaptWithSize(true)
	lable:setText(structConfirm.strText)
	local contentSize = lable:getContentSize()
	lable:setScale(330/contentSize.width)
	
	local btn_yes = mRootView:getWidgetByName("button_yes")
	tolua.cast(btn_yes,"UIButton")
	local btn_no = mRootView:getWidgetByName("button_no")
	tolua.cast(btn_no,"UIButton")
	
	if structConfirm.buttonCount == 0 or structConfirm.buttonCount == nil then
		btn_yes:setVisible(false)
		btn_no:setVisible(false)
		
		local panel = mRootView:getWidgetByName("Panel_20")
		tolua.cast(btn_no,"UILayout")
		panel:registerEventScript(onClickEvent)
		
		--设置定时器
		mScheduleScriptEntryID = mRootView:getScheduler():scheduleScriptFunc(LayerPayByEmoney.onExit,2,false)
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
		
		btn_yes:setVisible(true)
		btn_yes:registerEventScript(onClickEvent)
		
		btn_no:setVisible(true)
		btn_no:registerEventScript(onClickEvent)
	end
end

LayerPayByEmoney.destroy = function()
	mRootView = nil
	mItem = nil
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- 魔石购买金币
LayerPayByEmoney.onPayForGold = function(emoney)
	local tb = req_emoney_2_gold()
	tb.emoney = emoney
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_emoney_2_gold_result"])
end

local function handle_emoney_2_gold_result(packet)
	if nil == mItem then
		return
	end
	if packet.result == 1 then
		if mItem.func[1] ~= nil then
			mItem.func[1]()
		end
		Toast.show(GameString.get("NEW_RECHARGE_TIP_3", mItem.gold))
		UIManager.pop("UI_PayByEmoney")
		return
	end
end
NetSocket_registerHandler(NetMsgType["msg_notify_emoney_2_gold_result"],  notify_emoney_2_gold_result, handle_emoney_2_gold_result)

--------------------------------------------------------------------------------------------------------------------------------------------------
-- 魔石购买物品
LayerPayByEmoney.onPayForItem = function(data)
	NetLogic.requestBuyMallItem(data.id, data.amount)
end

local function Handle_req_onPayForItem(success)
	if nil == mItem then
		return
	end
	if false == success then
		return
	end
	local name = LogicTable.getItemById(mItem.item_id).name
	local amount = mItem.amount * mItem.item_amount
	Toast.show(GameString.get("ShopMall_PUR_GET",name,amount))
	-- 更新购买次数
	LayerShopMall.setLastPurchaseTimesById(mItem.id, mItem.amount)
	if mItem.func[1] ~= nil then
		mItem.func[1]()
	end
	UIManager.pop("UI_PayByEmoney")
	return
end
EventCenter_subscribe(EventDef["ED_BUY_MALL_ITEM"], Handle_req_onPayForItem)