----------------------------------------------------------------------
-- 李慧琴
-- 2014-10-13
-- 没有购买时的月卡界面
----------------------------------------------------------------------
LayerMonthCardNo = {}
local mRootNode = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_MonthCard_No")
	end
end
----------------------------------------------------------------------
-- 点击跳转按钮
local function clickGoBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_MonthCard_No")
		setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
	end
end
----------------------------------------------------------------------
-- 刷新界面
local function refreshUI()
	if nil == mRootNode then
		return
	end
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	local getImage = tolua.cast(mRootNode:getWidgetByName("ImageView_get"), "UIImageView")
	local goBtn = tolua.cast(mRootNode:getWidgetByName("Button_go"), "UIButton")
	goBtn:registerEventScript(clickGoBtn)

	--[[
	Log("refreshUI******",MonthCardLogic.getMonthCardId())
	local monthInfo = LogicTable.getRechargeRow(MonthCardLogic.getMonthCardId())
	--送的魔石
	local emoneyLbl =  tolua.cast(mRootNode:getWidgetByName("LabelBMFont_emoney"), "UILabelBMFont")
	emoneyLbl:setText(tostring(monthInfo.reward_emoney))
	--购买月卡的钱
	local moneyLbl =  tolua.cast(mRootNode:getWidgetByName("LabelAtlas_money"), "UILabelAtlas")
	moneyLbl:setStringValue(tonumber(monthInfo.money/100))
	]]--
	-- 奖励信息
	local row = LogicTable.getMonthCardDaiylAwardRow(MonthCardLogic.getMonthCardId())
	for i=1, 6 do
		LayerMonthCard.showRewardInfo(mRootNode, row.award_ids[i], row.amount[i], i)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerMonthCardNo.init = function()
	mRootNode = UIManager.findLayerByTag("UI_MonthCard_No")
	refreshUI()
end
----------------------------------------------------------------------
-- 销毁
LayerMonthCardNo.destroy = function()
	mRootNode = nil
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_MONTH_CARD_INFO"], refreshUI)


----------------------------------------------------------------------
--[[
-- 点击奖励图标
local function clickReward(typeName, widget)
	if "releaseUp" == typeName then
		CommonFunc_showInfo(0, widget:getTag())
	end
end
----------------------------------------------------------------------
-- 显示奖励信息
local function showRewardInfo(rootNode, rewardId, count, index)
	local rewardFrameImage = tolua.cast(rootNode:getWidgetByName("ImageView_reward"..index), "UIImageView")
	local rewardIconImage = tolua.cast(rootNode:getWidgetByName("ImageView_icon"..index), "UIImageView")
	local rewardCountLabel = tolua.cast(rootNode:getWidgetByName("Label_count"..index), "UILabel")
	if nil == rewardId or 0 == rewardId then
		rewardFrameImage:setEnabled(false)
		return
	end
	rewardFrameImage:setEnabled(true)
	rewardFrameImage:setTag(rewardId)
	rewardFrameImage:registerEventScript(clickReward)
	local rewardItemRow = LogicTable.getRewardItemRow(rewardId)
	-- 图标
	rewardIconImage:loadTexture(rewardItemRow.icon)
	CommonFunc_SetQualityFrame(rewardIconImage)
	-- 数量
	rewardCountLabel:setText(tostring(count))
end
]]--

