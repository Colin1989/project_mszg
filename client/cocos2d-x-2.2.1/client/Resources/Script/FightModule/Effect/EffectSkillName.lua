----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	技能名字
----------------------------------------------------

EffectSkillName = class(Effect)

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

--构造
function EffectSkillName:ctor()
	self.mPosition = ccp(360, 540)
	self.mName 	= nil
end

--初始化
function EffectSkillName:init(pos, name)
	self.mPosition = ccp(pos.x, pos.y)
	self.mName = name
end

--开始播放
function EffectSkillName:play()
	local parent = EffectMgr.getConfig("emc_front_layer")
	local label = self:createFont()
	parent:addChild(label, 100)
	label:setPosition(ccp(self.mPosition.x, self.mPosition.y - 50))
	
	local arr = CCArray:create()
	local scale = label:getScale()
	label:setScale(0)
    arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.15, 2.4 * scale), CCFadeIn:create(0.15)))
	arr:addObject(CCScaleTo:create(0.1, scale))
	arr:addObject(CCDelayTime:create(1.2))
	arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 50)), CCFadeOut:create(0.2)))
	arr:addObject(CCCallFuncN:create(removeSelf))
	label:runAction(CCSequence:create(arr))
   
end

function EffectSkillName:createFont()
	local layer = CCLayer:create()
	local label1 = CCLabelBMFont:create(self.mName, "font_skill_name.fnt")
	layer:addChild(label1, 1)
	label1:setColor(ccc3(255, 255, 0))
	label1:setAnchorPoint(ccp(0.5, 0.5))
	
	local label2 = CCLabelBMFont:create(self.mName, "font_skill_name.fnt")
	layer:addChild(label2)
	label2:setColor(ccc3(0, 0, 0))
	label2:setAnchorPoint(ccp(0.5, 0.5))
	label2:setPosition(ccp(2, -2))

	layer:setAnchorPoint(ccp(0, 0))
	return layer
end












