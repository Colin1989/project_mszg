----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-07-08
-- Brief:	在线奖励界面
----------------------------------------------------------------------
local mLayerOnlineRewardRoot = nil
local mTimeCountLabel = nil
local mOnlineRewardRow = nil
LayerOnlineReward = {}
LayerAbstract:extend(LayerOnlineReward)
----------------------------------------------------------------------
--[[
--点击图片信息，查看对应的信息
local function ItemInfoAction(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		CommonFunc_showInfo(0,widget:getTag(), 0)
	end
end
]]--
----------------------------------------------------------------------
-- 显示礼包列表
local function showGiftList(minutes)
	local giftBgName = {"ImageView_bg1", "ImageView_bg2", "ImageView_bg3", "ImageView_bg4", "ImageView_bg5"}
	local giftTimeBgName = {"ImageView_gift_times_bg1", "ImageView_gift_times_bg2", "ImageView_gift_times_bg3", "ImageView_gift_times_bg4", "ImageView_gift_times_bg5"}
	for key, val in pairs(ONLINE_TIMES) do
		local giftBg = tolua.cast(mLayerOnlineRewardRoot:getChildByName(giftBgName[key]), "UIImageView")
		local giftTimeBg = tolua.cast(mLayerOnlineRewardRoot:getChildByName(giftTimeBgName[key]), "UIImageView")
		if minutes == val then
			giftBg:loadTexture("public2_bg_07_h.png")
			giftTimeBg:loadTexture("public2_bg_05_h.png")
		else
			giftBg:loadTexture("public2_bg_07.png")
			giftTimeBg:loadTexture("public2_bg_05.png")
		end
	end
	--
	local onlineRewardRow = LogicTable.getOnlineRewardRow(ModelPlayer.getLevel(), minutes)
	for i=1, 10 do
		local rewardIconImage = tolua.cast(mLayerOnlineRewardRoot:getChildByName("ImageView_reward_icon"..i), "UIImageView")
		local rewardCountLabel = tolua.cast(mLayerOnlineRewardRoot:getChildByName("Label_reward_count"..i), "UILabel")
		local rewardId = onlineRewardRow.ids[i]
		local rewardCount = onlineRewardRow.amounts[i]
		if nil == rewardId or nil == rewardCount then
			rewardIconImage:setTouchEnabled(false)
			rewardIconImage:setVisible(false)
			rewardCountLabel:setVisible(false)
		else
			local rewardItem = LogicTable.getRewardItemRow(rewardId)
			if rewardItem.icon ~= "null" then
				rewardIconImage:loadTexture(rewardItem.icon)
			end
			rewardIconImage:setTag(rewardId)
			rewardIconImage:setTouchEnabled(true)
			--rewardIconImage:registerEventScript(ItemInfoAction)
			
			--长按
			local function clickSkillIcon(rewardIconImage)
				showLongInfoByRewardId(rewardId,rewardIconImage)
			end
			
			local function clickSkillIconEnd(rewardIconImage)
				longClickCallback_reward(rewardId,rewardIconImage)
			end

			UIManager.registerEvent(rewardIconImage, nil, clickSkillIcon, clickSkillIconEnd)
			
			rewardCountLabel:setText(tostring(rewardCount))
			rewardIconImage:setVisible(true)
			rewardCountLabel:setVisible(true)
		end
	end
	local canGet = OnlineRewardLogic.canGetAward(minutes)
	local rewardBtn = tolua.cast(mLayerOnlineRewardRoot:getChildByName("Button_reward"), "UIButton")
	rewardBtn:setTouchEnabled(canGet)
	rewardBtn:setBright(canGet)
	mOnlineRewardRow = onlineRewardRow
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
-- 点击领取按钮
local function clickRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		if nil == mOnlineRewardRow then
			return
		end
		widget:setTouchEnabled(false)
		OnlineRewardLogic.requestGetOnlineAward(mOnlineRewardRow.id, mOnlineRewardRow.minutes)
	end
end
----------------------------------------------------------------------
-- 点击礼包图标
local function clickGiftIcon(typeName, widget)
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local minutes = widget:getTag()
		showGiftList(minutes)
	end
end
----------------------------------------------------------------------
-- 刷新界面
local function refreshUI(updateList)
	local notGetImage = {"onlinereward_gift_1.png", "onlinereward_gift_2.png", "onlinereward_gift_3.png", "onlinereward_gift_4.png", "onlinereward_gift_5.png"}
	local hasGetImage = {"onlinereward_gift_empty1.png", "onlinereward_gift_empty2.png", "onlinereward_gift_empty3.png", "onlinereward_gift_empty4.png", "onlinereward_gift_empty5.png"}
	local canGetImage = {"onlinereward_gift_open1.png", "onlinereward_gift_open2.png", "onlinereward_gift_open3.png", "onlinereward_gift_open4.png", "onlinereward_gift_open5.png"}
	local giftIconName = {"ImageView_gift_icon1", "ImageView_gift_icon2", "ImageView_gift_icon3", "ImageView_gift_icon4", "ImageView_gift_icon5"}
	local index = nil
	for key, val in pairs(ONLINE_TIMES) do
		local giftIconImage = notGetImage[key]
		if true == OnlineRewardLogic.hasGetAward(val) then
			giftIconImage = hasGetImage[key]
		else
			if true == OnlineRewardLogic.canGetAward(val) then
				giftIconImage = canGetImage[key]
			end
		end
		local giftIcon = tolua.cast(mLayerOnlineRewardRoot:getChildByName(giftIconName[key]), "UIImageView")
		giftIcon:loadTexture(giftIconImage)
		if true == OnlineRewardLogic.canGetAward(val) and nil == index then
			index = key
		elseif false == OnlineRewardLogic.hasGetAward(val) and nil == index then
			index = key
		end
	end
	-- if index == nil and true == OnlineRewardLogic.hasGetAward(ONLINE_TIMES[#ONLINE_TIMES]) then
	if index == nil then
		index = #ONLINE_TIMES
	end
	if true == updateList then
		showGiftList(ONLINE_TIMES[index or 1])
	end
end
----------------------------------------------------------------------
-- 初始化
LayerOnlineReward.init = function(rootView)
	mLayerOnlineRewardRoot = rootView
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 领取按钮
	local rewardBtn = tolua.cast(rootView:getChildByName("Button_reward"), "UIButton")
	rewardBtn:registerEventScript(clickRewardBtn)
	-- 礼包图标1
	local giftIcon1 = tolua.cast(rootView:getChildByName("ImageView_bg1"), "UIImageView")
	giftIcon1:registerEventScript(clickGiftIcon)
	giftIcon1:setTag(ONLINE_TIMES[1])
	-- 礼包图标2
	local giftIcon2 = tolua.cast(rootView:getChildByName("ImageView_bg2"), "UIImageView")
	giftIcon2:registerEventScript(clickGiftIcon)
	giftIcon2:setTag(ONLINE_TIMES[2])
	-- 礼包图标3
	local giftIcon3 = tolua.cast(rootView:getChildByName("ImageView_bg3"), "UIImageView")
	giftIcon3:registerEventScript(clickGiftIcon)
	giftIcon3:setTag(ONLINE_TIMES[3])
	-- 礼包图标4
	local giftIcon4 = tolua.cast(rootView:getChildByName("ImageView_bg4"), "UIImageView")
	giftIcon4:registerEventScript(clickGiftIcon)
	giftIcon4:setTag(ONLINE_TIMES[4])
	-- 礼包图标5
	local giftIcon5 = tolua.cast(rootView:getChildByName("ImageView_bg5"), "UIImageView")
	giftIcon5:registerEventScript(clickGiftIcon)
	giftIcon5:setTag(ONLINE_TIMES[5])
	-- 
	mTimeCountLabel = tolua.cast(rootView:getChildByName("Label_count_times"), "UILabel")
	mTimeCountLabel:setText("00:00")
	--
	refreshUI(true)
	TipModule.onUI(rootView, "ui_onlinereward")
end
----------------------------------------------------------------------
-- 销毁
LayerOnlineReward.destroy = function()
	mLayerOnlineRewardRoot = nil
	mTimeCountLabel = nil
	mOnlineRewardRow = nil
end
----------------------------------------------------------------------
-- 处理在线奖励信息
local function handleOnlineAwardInfo()
	if nil == mLayerOnlineRewardRoot then
		return
	end
	refreshUI()
end
----------------------------------------------------------------------
-- 处理领取在线奖励
local function handleGetOnlineAward(success)
	if nil == mLayerOnlineRewardRoot then
		return
	end
	local rewardBtn = tolua.cast(mLayerOnlineRewardRoot:getChildByName("Button_reward"), "UIButton")
	if true == success then
		CommonFunc_showItemGetInfo(mOnlineRewardRow.ids, mOnlineRewardRow.amounts)
		rewardBtn:setBright(false)
		refreshUI(true)
		UIManager.popBounceWindow("UI_TempPack")
	else
		rewardBtn:setTouchEnabled(true)
	end
end
----------------------------------------------------------------------
-- 处理在线定时器
local function handleOnlineTimer(totalOnlineTime)
	if nil == mLayerOnlineRewardRoot then
		return
	end
	local remainTime = OnlineRewardLogic.getRemainTime(totalOnlineTime)
	local minutes, seconds = 0, 0
	if remainTime > 0 then
		minutes, seconds = math.floor(remainTime/60), remainTime%60
	end
	mTimeCountLabel:setText(string.format("%02d:%02d", minutes, seconds))
	for key, val in pairs(ONLINE_TIMES) do
		if totalOnlineTime == val*60 and val == mOnlineRewardRow.minutes then
			local rewardBtn = tolua.cast(mLayerOnlineRewardRoot:getChildByName("Button_reward"), "UIButton")
			rewardBtn:setBright(true)
			rewardBtn:setTouchEnabled(true)
		end
	end
end
----------------------------------------------------------------------
EventCenter_subscribe(EventDef["ED_ONLINE_AWARD_INFO"], handleOnlineAwardInfo)
EventCenter_subscribe(EventDef["ED_GET_ONLINE_AWARD"], handleGetOnlineAward)
EventCenter_subscribe(EventDef["ED_ONLINE_TIMER"], handleOnlineTimer)
