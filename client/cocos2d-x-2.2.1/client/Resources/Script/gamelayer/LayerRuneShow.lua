--region LayerRuneShow.lua
--Author : songcy
--Date   : 2014/11/28


LayerRuneShow = {}
LayerAbstract:extend(LayerRuneShow)

local mRootView = nil
local typeIndex = nil			-- 之前抽取的类型
local againIndex = nil			-- 再抽一次的类型
local rewardItem = nil
local mPopCallback = nil
local mCallbackParam = nil

-- 发送寻宝类型
local function sendRuneMsg(mType)
	UIManager.pop("UI_RuneShow")
	LayerRune.updateUnlockSkill()
	local tb = req_sculpture_divine()
	tb.type = tonumber(mType)
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sculpture_divine"])
end

local function runeAgainOnce()
	
end

local function onClickEvent(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	TipModule.onClick(widget)
	local weightName = widget:getName()
	if weightName == "Button_close" then
		UIManager.pop("UI_RuneShow")
		if "function" == type(mPopCallback) then
			mPopCallback(mCallbackParam)
			mPopCallback = nil
		end
	elseif weightName == "Button_one" then
		if typeIndex == 1 then
			if CommonFunc_payConsume(1, RUNE_ONE_NORMAL_PAY) then
				return
			end
			
			local function dialogSureCall()
				sendRuneMsg(typeIndex)
			end
			local str = "RUNE_NORMAL_PAY_ONE"
			local diaMsg = 
			{
				strText = string.format(GameString.get(str, RUNE_ONE_NORMAL_PAY)),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {dialogSureCall, nil}
			}
			UIManager.push("UI_ComfirmDialog", diaMsg)
		elseif typeIndex == 3 then
			if CommonFunc_payConsume(2, RUNE_ONE_SPECIAL_PAY) then
				return
			end
			
			local function dialogSureCall()
				sendRuneMsg(typeIndex)
			end
			local str = "RUNE_SPECIAL_PAY_ONE"
			local diaMsg = 
			{
				strText = string.format(GameString.get(str, RUNE_ONE_SPECIAL_PAY)),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {dialogSureCall, nil}
			}
			UIManager.push("UI_ComfirmDialog", diaMsg)
		end
	elseif weightName == "Button_ten" then
		if typeIndex == 1 then
			if CommonFunc_payConsume(1, RUNE_TEN_NORMAL_PAY) then
				return
			end
			
			local function dialogSureCall()
				sendRuneMsg(2)
			end
			local str = "RUNE_NORMAL_PAY_TEN"
			local diaMsg = 
			{
				strText = string.format(GameString.get(str, RUNE_TEN_NORMAL_PAY)),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {dialogSureCall, nil}
			}
			UIManager.push("UI_ComfirmDialog", diaMsg)
		elseif typeIndex == 3 then
			if CommonFunc_payConsume(2, RUNE_TEN_SPECIAL_PAY) then
				return
			end
			
			local function dialogSureCall()
				sendRuneMsg(4)
			end
			local str = "RUNE_SPECIAL_PAY_TEN"
			local diaMsg = 
			{
				strText = string.format(GameString.get(str, RUNE_TEN_SPECIAL_PAY)),
				buttonCount = 2,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {dialogSureCall, nil}
			}
			UIManager.push("UI_ComfirmDialog", diaMsg)
		end
	end
end

-- 初始化动画
local function initRunShow()
	local black = tolua.cast(mRootView:getChildByName("ImageView_441"), "UIImageView")
	black:setOpacity(0)
	local background = tolua.cast(mRootView:getChildByName("ImageView_bg"), "UIImageView")
	background:setVisible(false)
	local light = tolua.cast(mRootView:getChildByName("ImageView_light"), "UIImageView")
	light:setVisible(false)
	local oneBtn = tolua.cast(mRootView:getChildByName("Button_one"), "UIButton")
	oneBtn:setOpacity(0)
	local tenBtn = tolua.cast(mRootView:getChildByName("Button_ten"), "UIButton")
	tenBtn:setOpacity(0)
	-- local sureBtn = tolua.cast(mRootView:getChildByName("Button_sure"), "UIButton")
	-- sureBtn:setOpacity(0)
	
	--转动的图片
	local function call_Func_2()
		light:runAction(CCRepeatForever:create(CCRotateBy:create(0.5,60)) )
	end
	
	local function call_Func_1()
		if typeIndex == 1 or typeIndex == 3 then
			local array_3 = CCArray:create()
			local spawnAction = CCSpawn:createWithTwoActions(
				CCMoveBy:create(0.2, ccp(0, -50)),
				CCFadeIn:create(0.2))
			array_3:addObject(spawnAction)
			oneBtn:runAction(CCSequence:create(array_3))
			oneBtn:registerEventScript(onClickEvent)
			local array_4 = CCArray:create()
			local spawnAction = CCSpawn:createWithTwoActions(
				CCMoveBy:create(0.2, ccp(0, -50)),
				CCFadeIn:create(0.2))
			array_4:addObject(spawnAction)
			tenBtn:runAction(CCSequence:create(array_4))
			tenBtn:registerEventScript(onClickEvent)
		-- elseif typeIndex == 2 or typeIndex == 4 then
			-- sureBtn:runAction(CCFadeIn:create(0.3))
			-- sureBtn:registerEventScript(onClickEvent)
		end
	end
	
	local function pushAction()
		local array_1 = CCArray:create()
		array_1:addObject(CCDelayTime:create(0.1))
		array_1:addObject(CCShow:create())
		array_1:addObject(CCEaseSineOut:create(CCMoveBy:create(0.3, ccp(0,-100))))
		array_1:addObject(CCCallFuncN:create(call_Func_1))
		background:runAction(CCSequence:create(array_1))
		
		local array_2 = CCArray:create()
		array_2:addObject(CCDelayTime:create(0.1))
		array_2:addObject(CCShow:create())
		array_2:addObject(CCCallFuncN:create(call_Func_2))
		light:runAction(CCSequence:create(array_2))
	end
	local action = CCSequence:createWithTwoActions(CCFadeIn:create(0.5),CCCallFuncN:create(pushAction))
	black:runAction(action)
end

-- bundle: runeType:奖励类型 callback:回调函数 param:回调函数参数
LayerRuneShow.init = function(bundle)
	mRootView = UIManager.findLayerByTag("UI_RuneShow"):getWidgetByName("Panel_439")
	if mRootView == nil then
		return
	end
	initRunShow()
	local closeBtn = tolua.cast(mRootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(onClickEvent)
	
	typeIndex = tonumber(bundle.runeType)
	rewardItem = bundle
	mPopCallback = bundle.callback
	mCallbackParam = bundle.param
	-- 物品icon
	local rewardImage = tolua.cast(mRootView:getChildByName("ImageView_icon"), "UIImageView")		--奖励Icon
	rewardImage:loadTexture(rewardItem.icon)
	rewardImage:setTag(rewardItem.temp_id)
	rewardImage:setTouchEnabled(true)
	local function clickSkillIcon(rewardImage)
		showLongInfoByRewardId(rewardItem.id,rewardImage)
	end
	local function clickSkillIconEnd(rewardImage)
		longClickCallback_reward(rewardItem.id,rewardImage)
	end
	UIManager.registerEvent(rewardImage, nil, clickSkillIcon, clickSkillIconEnd)
	-- 物品数量
	local rewardNum = tolua.cast(mRootView:getChildByName("Label_num"), "UILabel")
	rewardNum:setText(string.format("* %s", bundle.amount))
	-- 物品说明
	local rewardDescribe = tolua.cast(mRootView:getChildByName("Label_describe"), "UILabel")
	rewardDescribe:setTextAreaSize(CCSizeMake(314, 147))
	if rewardItem.type == 8 then
		rewardDescribe:setText(SkillMgr.getDescription(rewardItem.temp_id, 1))
	else
		rewardDescribe:setText(rewardItem.description)
	end
	TipModule.onUI(rootView, "ui_runeshow")
end

LayerRuneShow.destroy = function()
	mRootView = nil
end