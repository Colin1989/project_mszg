----------------------------------------------------------------------
-- jaron.ho
-- 2014-09-13
-- 月卡界面
----------------------------------------------------------------------
LayerMonthCard = {}
local mRootNode = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_MonthCard")
	end
end
----------------------------------------------------------------------
-- 点击领取按钮
local function clickGetBtn(typeName, widget)
	if "releaseUp" == typeName then
		MonthCardLogic.requestGetMooncardDailyAward()
	end
end
----------------------------------------------------------------------
-- 点击奖励图标
local function clickReward(typeName, widget)
	if "releaseUp" == typeName then
		CommonFunc_showInfo(0, widget:getTag())
	end
end
----------------------------------------------------------------------
-- 显示奖励信息
LayerMonthCard.showRewardInfo = function(rootNode, rewardId, count, index)
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
----------------------------------------------------------------------
-- 刷新界面
local function refreshUI()
	if nil == mRootNode then
		return
	end
	
	--12点刷新
	local remainDays = MonthCardLogic.getRemainDays()
	if 0 == remainDays then		-- 无月卡
		UIManager.pop("UI_MonthCard")
		UIManager.push("UI_MonthCard_No")
	end
	
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	local getBtn = tolua.cast(mRootNode:getWidgetByName("Button_get"), "UIButton")
	getBtn:registerEventScript(clickGetBtn)
	local getImage = tolua.cast(mRootNode:getWidgetByName("ImageView_get"), "UIImageView")
	local remainDaysImage = tolua.cast(mRootNode:getWidgetByName("ImageView_days"), "UIImageView")
	local remainDaysLabel = tolua.cast(mRootNode:getWidgetByName("Label_days"), "UILabel")
	-- 奖励信息
	local row = LogicTable.getMonthCardDaiylAwardRow(MonthCardLogic.getMonthCardId())
	for i=1, 6 do
		LayerMonthCard.showRewardInfo(mRootNode, row.award_ids[i], row.amount[i], i)
	end
	-- 按钮状态-- 有月卡
	if MonthCardLogic.canGetAward() then	-- 奖励可领取
		getBtn:setTouchEnabled(true)
		getBtn:setBright(true)
		getImage:loadTexture("Text_a_01.png")
	else									-- 奖励已领取
		getBtn:setTouchEnabled(false)
		getBtn:setBright(false)
		getImage:loadTexture("Text_a_01_gray.png")
	end
	remainDaysLabel:setText(tostring(remainDays))
end
----------------------------------------------------------------------
-- 初始化
LayerMonthCard.init = function()
	mRootNode = UIManager.findLayerByTag("UI_MonthCard")
	refreshUI()
end
----------------------------------------------------------------------
-- 销毁
LayerMonthCard.destroy = function()
	mRootNode = nil
end
----------------------------------------------------------------------
-- 处理领取月卡奖励
local function handleGetMonthCardReward(success)
	if true == success then
		refreshUI()
		local row = LogicTable.getMonthCardDaiylAwardRow(MonthCardLogic.getMonthCardId())
		CommonFunc_showItemGetInfo(row.award_ids, row.amount)
	end
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_MONTH_CARD_INFO"], refreshUI)
EventCenter_subscribe(EventDef["ED_GET_MONTH_CARD_REWARD"], handleGetMonthCardReward)

