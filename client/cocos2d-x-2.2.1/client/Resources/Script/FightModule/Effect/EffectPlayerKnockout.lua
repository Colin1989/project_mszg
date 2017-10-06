----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	玩家全屏特效基类
----------------------------------------------------

EffectPlayerKnockout = class(Effect)

local m_priority = -200

--构造
function EffectPlayerKnockout:ctor()
	self.mPosition = ccp(0, 0)
	self.mSprite = nil
end

--初始化
function EffectPlayerKnockout:init(pos)
	self.mPosition = ccp(pos.x , pos.y - 185)
	local parent = EffectMgr.getConfig("emc_front_layer")
	local sprite = CCSprite:create("effect_fight_tombstone.png")
	parent:addChild(sprite, 10000)
	sprite:setPosition(self.mPosition)
	sprite:setVisible(false)
	self.mSprite = sprite
end

--玩家被K.O墓碑升起
function EffectPlayerKnockout:knockout()
	local sprite = self.mSprite
	sprite:setPosition(self.mPosition)
	sprite:setVisible(true)
	local arr = CCArray:create()
	arr:addObject(CCEaseBackInOut:create(CCMoveBy:create(0.15, ccp(0, 200))))
	arr:addObject(CCEaseBackInOut:create(CCMoveBy:create(0.05, ccp(0, -30))))
	sprite:runAction(CCSequence:create(arr))

    local rolePleyrObject = RoleMgr.getConfig("rmc_player_object")
    rolePleyrObject:setRoleVisible(false)
end

--玩家复活墓碑降落
function EffectPlayerKnockout:respawn()
	local sprite = self.mSprite
	local arr = CCArray:create()
	arr:addObject(CCEaseBackInOut:create(CCMoveBy:create(0.15, ccp(0, -200))))
	arr:addObject(CCHide:create())
	sprite:runAction(CCSequence:create(arr))

    local rolePleyrObject = RoleMgr.getConfig("rmc_player_object")
    rolePleyrObject:setRoleVisible(true)
end














