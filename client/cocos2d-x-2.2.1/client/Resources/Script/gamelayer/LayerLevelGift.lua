----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-07-02
-- Brief:	冲级活动界面
----------------------------------------------------------------------

local mLayerLevelGiftRoot = nil
local mTaskId = 0	--领取奖励的id

LayerLevelGift = {}
LayerAbstract:extend(LayerLevelGift)

----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerActivity, "Activity.json", widgetName)
	end
end
----------------------------------------------------------------------
--点击获取奖励按钮
local function clickGetRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		local tb = LevelGiftLogic.getRewardList()
		if tb[1] ~= nil then
			mTaskId = tb[1]
			LevelGiftLogic.request_get_level_award(tonumber(mTaskId))  	
		end
	end
end
----------------------------------------------------------------------
--根据是第几个清楚礼包内容，并决定第二个panel要不要显示
local function clearReward()
	for j =1,2,1 do
		for i=1,6,1 do
			if j == 1 then
				panel = mLayerLevelGiftRoot:getChildByName("Panel_39")	
			else
				panel = mLayerLevelGiftRoot:getChildByName("Panel_40")	
			end
			local icon = tolua.cast(panel:getChildByName(string.format("icon_%d",i)),"UIImageView")
			icon:loadTexture("touming.png")
			icon:setVisible(false)
			local label = tolua.cast(panel:getChildByName(string.format("Label_%d",i)),"UILabel")
			label:setText("")
			local bgImage = tolua.cast(panel:getChildByName(string.format("ImageView_%d",i + 208)),"UIImageView")
			bgImage:setVisible(false)	
		end
	end
	if  (LevelGiftLogic.getMaxId() + 1) >= LevelGiftLogic.getMaxRewardId() then
		panel = mLayerLevelGiftRoot:getChildByName("Panel_40")
		panel:setVisible(false)
	end
end
----------------------------------------------------------------------
--[[
--点击图片查看详细信息
local function iconClick(clickType,sender)
	if clickType ~= "releaseUp" then
		return
	end	
	CommonFunc_showInfo(0,sender:getTag(), 0)
end
]]--
----------------------------------------------------------------------
--根据奖励id，显示对应的礼包
local function showReward()
	if nil == mLayerLevelGiftRoot then
		return
	end
	clearReward()
	local rewardList = LevelGiftLogic.getRewardList()
	for k,v in pairs (rewardList) do	
		local tb = LogicTable.getlevelGiftInfoById(v)
		for key,value in pairs(tb.reward_ids) do			
			local tempTb = LogicTable.getRewardItemRow(value)
			local panel
			if k == 1 then
				panel = mLayerLevelGiftRoot:getChildByName("Panel_39")	
			else
				panel = mLayerLevelGiftRoot:getChildByName("Panel_40")	
			end
			local icon = tolua.cast(panel:getChildByName(string.format("icon_%d",key)),"UIImageView")
			icon:setVisible(true)
			icon:setTouchEnabled(true)
			icon:setTag(tonumber(value))
			--icon:registerEventScript(iconClick)
			--长按
			local function clickSkillIcon(icon)
				showLongInfoByRewardId(tempTb.id,icon)
			end
			
			local function clickSkillIconEnd(icon)
				longClickCallback_reward(tempTb.id,icon)
			end

			UIManager.registerEvent(icon, nil, clickSkillIcon, clickSkillIconEnd)
			
			
			icon:loadTexture(tempTb.icon)
			local label = tolua.cast(panel:getChildByName(string.format("Label_%d",key)),"UILabel")
			label:setText(string.format("*%s",tb.reward_amounts[key]))
			local bgImage = tolua.cast(panel:getChildByName(string.format("ImageView_%d",key + 208)),"UIImageView")
			bgImage:setVisible(true)
			local level = tolua.cast(panel:getChildByName("Label_level"),"UILabel")
			level:setText(string.format(GameString.get("Public_Level_Gift",tb.level)))
		end
		--领取奖励按钮
		local panelFirst = tolua.cast(mLayerLevelGiftRoot:getChildByName("Panel_39"), "UILayout")
		local rewardBtn = tolua.cast(panelFirst:getChildByName("Button_getReward"), "UIButton")
		if LevelGiftLogic.existAward () == false then
			rewardBtn:setTouchEnabled(false)
			rewardBtn:setBright(false)
		else
			rewardBtn:setTouchEnabled(true)
			rewardBtn:setBright(true)
			rewardBtn:registerEventScript(clickGetRewardBtn)
		end
	end	
	if  #rewardList == 0 then
		panel1 = mLayerLevelGiftRoot:getChildByName("Panel_39")
		panel2 = mLayerLevelGiftRoot:getChildByName("Panel_40")
		panel1:setVisible(false)
		panel2:setVisible(false)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerLevelGift.init = function(rootView)
	mLayerLevelGiftRoot = rootView	
	--关闭按钮
	local closeBtn = tolua.cast(mLayerLevelGiftRoot:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	showReward()	
end
----------------------------------------------------------------------
-- 销毁
LayerLevelGift.destroy = function()
	mLayerLevelGiftRoot = nil
	cclog("LayerLevelGift.destroy")
end
----------------------------------------------------------------------
-- 游戏事件注册
EventCenter_subscribe(EventDef["ED_LEVEL_GET_GIFT"], showReward)
