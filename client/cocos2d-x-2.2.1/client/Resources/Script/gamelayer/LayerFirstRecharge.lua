----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-04-27
-- Brief:	首冲界面
----------------------------------------------------------------------

local mLayerFirstRechargeRoot = nil

--[[
--首充奖励物品奖励表中的id（reward_item_tplt）,策划可配置
local mRewardTb = {
	{["id"] = 1,["amount"] = 100},
	{["id"] = 9,["amount"] = 100},
	{["id"] = 12,["amount"] = 1},
	{["id"] = 10402,["amount"] = 1},

}
]]--

LayerFirstRecharge = {}
LayerFirstRecharge.jsonFile = "FirstRecharge.json"
LayerAbstract:extend(LayerFirstRecharge)
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerActivity, "Activity.json", typeName)
	end
end
----------------------------------------------------------------------
-- 去充值按钮
local function clickRechargeBtn(typeName, widget)
	if "releaseUp" == typeName then
		setConententPannelJosn(LayerRecharge, "Recharge.json", "LayerRecharge")
		EventCenter_post(EventDef["ED_ENTER_RECHARGE"], LayerFirstRecharge)
	end
end
----------------------------------------------------------------------
-- 领取礼包按钮
local function clickGetRewardBtn(typeName, widget)
	if "releaseUp" == typeName then
		FirstRechargeLogic.requestGetReward()
	end
end
----------------------------------------------------------------------
-- 设置首充领取的四个奖励物品
local function setRewardItem()
	for key,value in pairs(FirstRecharge_RewardTb) do
		local tempTb = LogicTable.getRewardItemRow(value.id)
		local image = mLayerFirstRechargeRoot:getChildByName(string.format("ImageView_%d",key))
		tolua.cast(image,"UIImageView")
		image:loadTexture(tempTb.icon)
		--长按
		image:setTouchEnabled(true)
		local function clickSkillIcon(image)
			showLongInfoByRewardId(tempTb.id,image)
		end
		
		local function clickSkillIconEnd(image)
			longClickCallback_reward(tempTb.id,image)
		end

		UIManager.registerEvent(image, nil, clickSkillIcon, clickSkillIconEnd)

		
		local numLbl = mLayerFirstRechargeRoot:getChildByName(string.format("num_%d",key))
		tolua.cast(numLbl,"UILabel")
		numLbl:setText(value.amount)
		local nameLbl = mLayerFirstRechargeRoot:getChildByName(string.format("name_%d",key))
		tolua.cast(nameLbl,"UILabel")
		nameLbl:setText(tempTb.name)
	end
end
----------------------------------------------------------------------
-- 设置领取奖励按钮
local function setGetRewardBtn()
	if mLayerFirstRechargeRoot == nil then
		return
	end
	--领取礼包按钮
	local getRewardBtn = tolua.cast(mLayerFirstRechargeRoot:getChildByName("Button_getReward"), "UIButton")
	if FirstRechargeLogic.existAward() == false then
		getRewardBtn:setTouchEnabled(false)
		getRewardBtn:setBright(false)
	else
		getRewardBtn:setBright(true)
		getRewardBtn:setTouchEnabled(true)
		getRewardBtn:registerEventScript(clickGetRewardBtn)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerFirstRecharge.init = function(bundle)

	mLayerFirstRechargeRoot = bundle
	
	--关闭按钮
	local closeBtn = tolua.cast(mLayerFirstRechargeRoot:getChildByName("close_btn"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	
	--去充值按钮
	local rechargeBtn = tolua.cast(mLayerFirstRechargeRoot:getChildByName("Button_recharge"), "UIButton")
	rechargeBtn:registerEventScript(clickRechargeBtn)
	
	setRewardItem()
	setGetRewardBtn()
	
	-- 游戏事件注册
	EventCenter_subscribe(EventDef["ED_FIRSTR_ECHARGE_GET"], setGetRewardBtn) 
	
end
----------------------------------------------------------------------
-- 销毁
LayerFirstRecharge.destroy = function()

	mLayerFirstRechargeRoot = nil
end
----------------------------------------------------------------------

