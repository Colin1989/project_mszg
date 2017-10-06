----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	战斗结束的延时动画
----------------------------------------------------

EffectBattleEnd = class(Effect)

local m_priority = -200
local function onTouch(eventType, x, y)
	if eventType == "began" then
		return true
	end
end

--构造
function EffectBattleEnd:ctor()
	self.mTag = "none"			--player_knock_out, enemy_knock_out
end

function EffectBattleEnd:init(tag)
	self.mTag = tag
end

function EffectBattleEnd:play()
	--事件屏蔽层
	local layer = CCLayer:create()
	layer:registerScriptTouchHandler(onTouch, false, m_priority, true)
	layer:setTouchEnabled(true)
	local parent = EffectMgr.getConfig("emc_front_layer")
	parent:addChild(layer, 1000)
	
	--移除自身
	local function removeSelf(sender)
		sender:removeFromParentAndCleanup(true)
		self:excute()
	end
	
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(1.5))
	arr:addObject(CCCallFuncN:create(removeSelf))
	layer:runAction(CCSequence:create(arr))
end

function EffectBattleEnd:excute()
	if self.mTag == "player_knock_out" then
		FightMgr.playerKnockout()
	elseif self.mTag == "enemy_knock_out" then
		FightMgr.enemyKnockout()
	end
end















