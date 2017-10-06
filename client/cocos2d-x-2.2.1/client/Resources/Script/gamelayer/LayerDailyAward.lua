----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-04-15
-- Brief:	每日奖励界面
----------------------------------------------------------------------

local mLayerDailyAwardRoot = nil
local mTempButton = nil
local mGetAwardType = nil

LayerDailyAward = {}
LayerAbstract:extend(LayerDailyAward)
----------------------------------------------------------------------
-- 判断奖励领取状态:2-已领取,3-可领取
local function checkAwardStatus(hasGet)
	if hasGet then
		return 2
	end
	return 3
end
----------------------------------------------------------------------
-- 计算奖励获取状态,1-不可领取,2-已领取,3-可领取
local function calcAwardStatus(days)
	local continueDays = DailyAwardLogic.getContinueDays()
	if 1 == days then
		return checkAwardStatus(DailyAwardLogic.hasGetDailyAward())
	elseif 3 == days then
		if continueDays >= 3 then
			return checkAwardStatus(DailyAwardLogic.hasGetDays3Award())
		end
	elseif 7 == days then
		if continueDays >= 7 then
			return checkAwardStatus(DailyAwardLogic.hasGetDays7Award())
		end
	elseif 15 == days then
		if continueDays >= 15 then
			return checkAwardStatus(DailyAwardLogic.hasGetDays15Award())
		end
	end
	return 1
end
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		setConententPannelJosn(LayerActivity, "Activity.json", widgetName)
	end
end
----------------------------------------------------------------------
-- 点击领取奖励按钮
local function clickGetAwardBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		mTempButton = widget
		mTempButton:setTouchEnabled(false)
		mGetAwardType = widget:getTag()
		DailyAwardLogic.request_get_daily_award(mGetAwardType)
	end
end
----------------------------------------------------------------------
-- 显示奖励内容
local function showAwardContent(contentLabel, giftBagRow, days)
	-- local str = ""
	-- local count = #(giftBagRow.reward_item_ids)
	-- if count > 0 then
		-- if 1 == days then
			-- str = GameString.get("DAILY_AWARD_STR_01").."\n"
		-- else
			-- str = GameString.get("DAILY_AWARD_STR_02", days).."\n"
		-- end
	-- end
	-- local comma = GameString.get("PUBLIC_COMMA")
	-- for i=1, count do
		-- local rewardItemId = giftBagRow.reward_item_ids[i]
		-- local rewardItemAmount = giftBagRow.reward_item_amounts[i]
		-- local rewardItem = LogicTable.getRewardItemRow(rewardItemId)
		-- local rewardItemName = rewardItem.name
		-- if i > 1 then
			-- str = str..comma
		-- end
		-- str = str..rewardItemName.."x"..rewardItemAmount
	-- end
	contentLabel:setTextAreaSize(CCSizeMake(290, 75))
	contentLabel:setText(giftBagRow.desc)
end
----------------------------------------------------------------------
-- 显示奖励按钮
local function showAwardBtn(awardBtn, days)
	local touchEnabled = false
	local status = calcAwardStatus(days)
	if 1 == status then			-- 不可领取
		touchEnabled = false
	elseif 2 == status then		-- 已领取
		touchEnabled = false
	elseif 3 == status then		-- 可领取
		touchEnabled = true
	end
	local awardType = nil
	local tipsPosition = nil
	if 1 == days then
		awardType = award_type["daily_award"]
		tipsPosition = ccp(136, 438)
	elseif 3 == days then
		awardType = award_type["cumulative_award3"]
		tipsPosition = ccp(136, 321)
	elseif 7 == days then
		awardType = award_type["cumulative_award7"]
		tipsPosition = ccp(136, 226)
	elseif 15 == days then
		awardType = award_type["cumulative_award15"]
		tipsPosition = ccp(136, 131)
	end
	awardBtn:setTag(awardType)
	awardBtn:setTouchEnabled(touchEnabled)
	awardBtn:setBright(touchEnabled)
	awardBtn:registerEventScript(clickGetAwardBtn)
	-- 显示提示角标
	local tipIcon = mLayerDailyAwardRoot:getChildByName("tip_icon_"..days)
	if nil == tipIcon then
		tipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		tipIcon:setName("tip_icon_"..days)
		tipIcon:setPosition(tipsPosition)
		mLayerDailyAwardRoot:addChild(tipIcon)
	end
	tipIcon:setVisible(touchEnabled)
end
----------------------------------------------------------------------
-- 显示奖励
local function showAward(panel, titleName, iconName, labelName, btnName, award, days)
	local giftBagRow = LogicTable.getGiftBagRow(award)
	--
	local giftBagIcon = tolua.cast(panel:getChildByName(iconName), "UIImageView")
	giftBagIcon:loadTexture(giftBagRow.icon)
	--
	local giftBagLable = tolua.cast(panel:getChildByName(labelName), "UILabel")
	showAwardContent(giftBagLable, giftBagRow, days)
	--
	local awardGetBtn = tolua.cast(panel:getChildByName(btnName), "UIButton")
	showAwardBtn(awardGetBtn, days)
end
----------------------------------------------------------------------
-- 显示每日奖励
local function showDailyAward(panel, playerLevel)
	local dailyAwardRow = LogicTable.getDailyAwardRow(playerLevel)
	--
	local closeBtn = tolua.cast(panel:getChildByName("close_btn"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	--
	local titleLabel = tolua.cast(panel:getChildByName("continue_days_label"), "UILabel")
	titleLabel:setText(tostring(DailyAwardLogic.getContinueDays()))
	local tips01Label = tolua.cast(panel:getChildByName("tips01_label"), "UILabel")
	tips01Label:setText(GameString.get("DAILY_AWARD_STR_06"))
	--
	showAward(panel, "daily_award_title", "daily_award_icon", "daily_award_label", "daily_award_btn", dailyAwardRow.days1_award, 1)
	showAward(panel, "days3_award_title", "days3_award_icon", "days3_award_label", "days3_award_btn", dailyAwardRow.days3_award, 3)
	showAward(panel, "days7_award_title", "days7_award_icon", "days7_award_label", "days7_award_btn", dailyAwardRow.days7_award, 7)
	showAward(panel, "days15_award_title", "days15_award_icon", "days15_award_label", "days15_award_btn", dailyAwardRow.days15_award, 15)
end
----------------------------------------------------------------------
local function dailyAward(param)
	if nil == mLayerDailyAwardRoot then
		return
	end
	showDailyAward(mLayerDailyAwardRoot, ModelPlayer.getLevel())
end
----------------------------------------------------------------------
-- 获取每日奖励
local function dailyGetAward(success)
	if true == success then
		local dailyAwardRow = LogicTable.getDailyAwardRow(ModelPlayer.getLevel())
		local giftBagId = nil
		if award_type["daily_award"] == mGetAwardType then
			giftBagId = dailyAwardRow.days1_award
		elseif award_type["cumulative_award3"] == mGetAwardType then
			giftBagId = dailyAwardRow.days3_award
		elseif award_type["cumulative_award7"] == mGetAwardType then
			giftBagId = dailyAwardRow.days7_award
		elseif award_type["cumulative_award15"] == mGetAwardType then
			giftBagId = dailyAwardRow.days15_award
		end
		if giftBagId then
			local giftBagRow = LogicTable.getGiftBagRow(giftBagId)
			CommonFunc_showItemGetInfo(giftBagRow.reward_item_ids, giftBagRow.reward_item_amounts)
		end
		UIManager.popBounceWindow("UI_TempPack")
	else
		if mTempButton then
			mTempButton:setTouchEnabled(true)
		end
	end
end
----------------------------------------------------------------------
-- 初始化
LayerDailyAward.init = function(rootView)
	-- 游戏事件注册
	EventCenter_subscribe(EventDef["ED_DAILY_AWARD"], dailyAward)
	EventCenter_subscribe(EventDef["ED_DAILY_GET_AWARD"], dailyGetAward)
	-- 
	mLayerDailyAwardRoot = rootView
	showDailyAward(rootView, ModelPlayer.getLevel())
	TipModule.onUI(rootView, "ui_dailyaward")
end
----------------------------------------------------------------------
-- 销毁
LayerDailyAward.destroy = function()
	-- 游戏事件删除
	EventCenter_unsubscribe(EventDef["ED_DAILY_AWARD"], dailyAward)
	EventCenter_unsubscribe(EventDef["ED_DAILY_GET_AWARD"], dailyGetAward)
	-- 
	mLayerDailyAwardRoot = nil
	mTempButton = nil
end
----------------------------------------------------------------------

