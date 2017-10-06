-------------------------------------
--作者：lewis
--说明：新怪物出场小贴示视图
--时间：2014-5-22
-------------------------------------

UIMonsterIntroduce = {}


LayerAbstract:extend(UIMonsterIntroduce)

local mRootView = nil      --当前界面的根节点
local mbOnAction = false
local mBundleTB = nil

local function enterCB(sender)
	mbOnAction = false
end

--进场动画
local function onEnter(tb)
	local desktop = mRootView:getWidgetByName("desktop")
	tolua.cast(desktop, "UIImageView")
	local height = 320
	local distance = 60
	local newPos = ccp(320, 0)
	if tb.pos.y - height - distance < 80 then
		newPos.y = tb.pos.y + height / 2 + 180
	else
		newPos.y = tb.pos.y - 40 - height / 2
	end
	desktop:setScale(0.0)
	desktop:setPosition(tb.pos)
	
	local duration = 0.4
	local arr = CCArray:create()
	local act1 = CCSpawn:createWithTwoActions(CCScaleTo:create(duration, 1.0), CCMoveTo:create(duration, newPos))
    arr:addObject(act1)
	arr:addObject(CCCallFuncN:create(enterCB))
	desktop:runAction(CCSequence:create(arr))
	mbOnAction = true
end

local function exitCB(sender)
	mbOnAction = false
	local tb = MonsterIntroduceHelper.getNextMonsterInfo()
	if tb.isEnd then
		if mRoleView ~= nil then
			mRoleView:cleanup()
			mRoleView = nil
		end
		UIManager.pop("UI_MonsterIntroduce")
		FightDateCache.setData("fd_game_pause", false)
	else
		if mRoleView ~= nil then
			mRoleView:cleanup()
			mRoleView = nil
		end
		UIMonsterIntroduce.refresh(tb)
	end
end


--出场动画
local function onExit(tb)
	local desktop = mRootView:getWidgetByName("desktop")
	tolua.cast(desktop, "UIImageView")
	
	local duration = 0.2
	local arr = CCArray:create()
	local act1 = CCSpawn:createWithTwoActions(CCScaleTo:create(duration, 0.0), CCMoveTo:create(duration, tb.pos))
    arr:addObject(act1)
	arr:addObject(CCCallFuncN:create(exitCB))
	desktop:runAction(CCSequence:create(arr))
	mbOnAction = true
end


function UIMonsterIntroduce.isVisible()
	if mRoleView == nil then
		return false
	end
	return true
end

UIMonsterIntroduce.onClick = function(widget)
	if mbOnAction == true then
		return
	end
	
    local widgetName = widget:getName()
    if "mask" == widgetName then  					-- 确认键
		onExit(mBundleTB)
    end
end


UIMonsterIntroduce.init = function(bundle)
    mRootView = UIManager.findLayerByTag("UI_MonsterIntroduce")
	setOnClickListenner("mask")
	UIMonsterIntroduce.refresh(bundle)
end


UIMonsterIntroduce.destroy = function()
	mRootView = nil
end

--角色视图
local function roleView(tb)
	--角色视图
	local monsterView = mRootView:getWidgetByName("monster_view")
	tolua.cast(monsterView, "UIImageView")
	mRoleView = ActionSprite.new()
	mRoleView:init(monsterView:getRenderer(), ccp(0, 0), tb.icon, 0)
	
	--名字
	local labelName = mRootView:getWidgetByName("label_monster_name")
	tolua.cast(labelName, "UILabel")
	labelName:setText(tb.name)
end

--刷新数据
local function dataView(tb)
	local labelMonsterInfo = mRootView:getWidgetByName("label_monster_introduce")
	tolua.cast(labelMonsterInfo, "UILabel")
	labelMonsterInfo:setText(tb.description)
	
	local labelAttackType = mRootView:getWidgetByName("attack_type_var1")
	tolua.cast(labelAttackType, "UILabel")
	labelAttackType:setText(tb.atk_mode)
	
	local labelStrategy = mRootView:getWidgetByName("strategy_var1")
	tolua.cast(labelStrategy, "UILabel")
	labelStrategy:setText(tb.corresponding_strategy)
	
end

--刷新视图
function UIMonsterIntroduce.refresh(tb)
	FightDateCache.setData("fd_game_pause", true)
	roleView(tb)
	dataView(tb)
	mBundleTB = tb
	onEnter(tb)
end





