----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	拾取血瓶特效
----------------------------------------------------

EffectBloodBottle = class(Effect)


--构造
function EffectBloodBottle:ctor()
	self.mSpriteBooldBottle	= nil	--血瓶
end

--初始化
function EffectBloodBottle:init(sprite)
	self.mSpriteBooldBottle = sprite
end

--开始播放
function EffectBloodBottle:play()
	self:moveUp()
end

--血拾拾取动作
function EffectBloodBottle:moveUp()
	local function moveUpDone(sender)
		local pos = sender:convertToWorldSpace(ccp(60, 0))
		sender:removeFromParentAndCleanup(true)
		self.mSpriteBooldBottle = nil
		self:crush(pos)
	end
	local act1 = CCMoveBy:create(0.4, ccp(0, 40))
	local act2 = CCCallFuncN:create(moveUpDone)
	self.mSpriteBooldBottle:runAction(CCSequence:createWithTwoActions(act1, act2))
end

local function heartFlyDone(sender)
	sender:removeFromParentAndCleanup(true)
end

--计算偏离位置
local function calOffsetPos(raduis, angle)
	angle = angle / 180.0 * 3.14
	local x = math.sin(angle) * raduis
	local y = math.cos(angle) * raduis
	return ccp(x, y)
end

--血瓶碎裂
function EffectBloodBottle:crush(pos)
	--获得飞行终点
	local playerPos = LayerGameUI.getHeartIconPos()
	
	local total = math.random(3, 8)
	local angle = math.random(0, 360)
	local raduis = 0
	local layer = EffectMgr.getConfig("emc_front_layer")
	
	for i = 1, total do
		raduis = math.random(45, 85)
		local scale = raduis / 100.0
		angle = angle + 360.0 / total
		local node = CCNode:create()
		layer:addChild(node, 10000)
		node:setPosition(pos)
		
		local sprite = CCSprite:create("effect_heart_piece.png")
		node:addChild(sprite, 1)
		sprite:setScale(scale)
		local offsetPos = calOffsetPos(raduis, angle)
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(math.random(10, 60) / 100))
		arr:addObject(CCShow:create())
		arr:addObject(CCEaseExponentialOut:create(CCMoveBy:create(0.5, offsetPos)))
		arr:addObject(EffectMgr.curvilinearMotion(0.6, ccp(pos.x + offsetPos.x, pos.y + offsetPos.y), playerPos))
		arr:addObject(CCCallFuncN:create(heartFlyDone))
		node:runAction(CCSequence:create(arr))
		node:setVisible(false)
		
		local particle = CCParticleSystemQuad:create("heart_tail.plist")
		node:addChild(particle)
		particle:setPosition(ccp(0, 0))
	end
end













