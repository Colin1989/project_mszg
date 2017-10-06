----------------------------------------------------------------------
-- Author:	李慧琴
-- Date:	2014-09-29
-- Brief:	邀请码奖励礼包信息
----------------------------------------------------------------------
local mLayerRoot = nil
local mInviteCodeGiftId = 0

LayerInviteCodeGift = {}
LayerAbstract:extend(LayerInviteCodeGift)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_InviteCodeGift")
	end
end
----------------------------------------------------------------------
-- 点击领取按钮
local function clickGetBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_InviteCodeGift")
		--widget:setTouchEnabled(false)
		--DailyActivenessLogic.requestActivenessReward(mActivenessRewardId)
	end
end
----------------------------------------------------------------------
-- 设置礼包内的奖励
local function setScrollInfo()
	local giftInfo = LogicTable.getGiftBagRow(mInviteCodeGiftId)
	
	local scrollReward = tolua.cast(mLayerRoot:getWidgetByName("ScrollView_gift"), "UIScrollView")
	local tempData =giftInfo.reward_item_ids
	local data ={}
	for k,v in pairs(tempData) do
		local ItemDate = LogicTable.getRewardItemRow(v) 
		ItemDate.amounts = giftInfo.reward_item_amounts[k]
		table.insert(data,ItemDate)
	end 
	-- 创建奖励单元格
	local function createReawardCell(ItemDate)
		-- 背景
		local cellBg = UIImageView:create()
		cellBg:loadTexture("public2_bg_05.png")
		cellBg:setScale9Enabled(true)
		cellBg:setCapInsets(CCRectMake(15, 15, 1, 1))
		cellBg:setSize(CCSizeMake(145, 149))
		-- 奖励名称
		local nameLabel = CommonFunc_getLabel(ItemDate.name, 20,ccc3(255, 255, 255))
		nameLabel:setPosition(ccp(0, 56))
		cellBg:addChild(nameLabel)
		-- 奖励图标
		local icon = FightOver_addQuaIconByRewardId(ItemDate.id,nil,tonumber(ItemDate.amounts))
		icon:setPosition(ccp(0,0))
		cellBg:addChild(icon)
		return cellBg	
	end
	UIEasyScrollView:create(scrollReward,data,createReawardCell,2, true,0,3,true)
end
----------------------------------------------------------------------
-- 初始化
LayerInviteCodeGift.init = function(inviteCodeGiftId)
	mInviteCodeGiftId = inviteCodeGiftId
	mLayerRoot = UIManager.findLayerByTag("UI_InviteCodeGift")
	-- 关闭按钮
	local closeBtn = tolua.cast(mLayerRoot:getWidgetByName("close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 领取按钮
	local getBtn = tolua.cast(mLayerRoot:getWidgetByName("getReward"), "UIButton")
	getBtn:registerEventScript(clickGetBtn)
	
	setScrollInfo()
end
----------------------------------------------------------------------
-- 销毁
LayerInviteCodeGift.destroy = function()
	mLayerRoot = nil
end
----------------------------------------------------------------------
