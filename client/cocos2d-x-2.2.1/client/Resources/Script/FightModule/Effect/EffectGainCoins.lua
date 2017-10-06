----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	拾取金币特效
----------------------------------------------------

EffectGainCoins = class(Effect)

--构造
function EffectGainCoins:ctor()
	self.mSpriteCoinsBag	= nil	--金袋
	self.mCoinsAmount		= 0		--金币数量
	self.mPosition			= ccp(360, 540)
end

--初始化
function EffectGainCoins:init(sprite, amount, pos)
	self.mSpriteCoinsBag 	= sprite
	self.mCoinsAmount		= amount
	self.mPosition			= pos
end

--开始播放
function EffectGainCoins:play()
	self:playNumerical()
	if self.mSpriteCoinsBag ~= nil then
		self:moveUp()
	elseif self.mPosition ~= nil then
		self:crush(self.mPosition)
	end
end

--血拾拾取动作
function EffectGainCoins:moveUp()
	local function moveUpDone(sender)
		local pos = sender:convertToWorldSpace(ccp(60, 0))
		sender:removeFromParentAndCleanup(true)
		self.mSpriteCoinsBag = nil
		self:crush(pos)
	end
	local act1 = CCMoveBy:create(0.4, ccp(0, 40))
	local act2 = CCCallFuncN:create(moveUpDone)
	self.mSpriteCoinsBag:runAction(CCSequence:createWithTwoActions(act1, act2))
end

--金币飞行到ICON动作完成,刷新金币数量
local function coinFlyToIconDone(sender)
	LayerGameUI.updateCoins(sender:getTag())
	sender:getParent():removeChild(sender, true)
end

--计算偏离位置
local function calOffsetPos(raduis, angle)
	angle = angle / 180.0 * 3.14
	local x = math.sin(angle) * raduis
	local y = math.cos(angle) * raduis
	return ccp(x, y)
end

--
function EffectGainCoins:crush(pos)
	--获得飞行终点
	local destPos = LayerGameUI.getCoinIconPos()
	local coins = self.mCoinsAmount
	local total = self:calCoinSpriteAmount(coins)
	local unit = math.floor(coins / total)
	local delay = 0.0
	for i = 1, total do
		local offset = calOffsetPos(60, math.random(1, 360))
		local newPos = ccp(pos.x + offset.x, pos.y + offset.y)
		local sprite = self:createCoinSprite(newPos)
		
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delay))
		arr:addObject(CCShow:create())
		arr:addObject(EffectMgr.curvilinearMotion(1.25, newPos, destPos))
		arr:addObject(CCCallFuncN:create(coinFlyToIconDone))
		sprite:runAction(CCSequence:create(arr))
		sprite:setVisible(false)
		local tag = 0
		if i == total then
			tag = coins
		else
			tag = unit
			coins = coins - unit
		end
		sprite:setTag(tag)
		delay = delay + math.random(5, 14) / 100
	end
end

--计算当前金币数转换成多少金币精灵
function EffectGainCoins:calCoinSpriteAmount(coins)
	local low = 1
	local high = 2
	if coins > 100 then
		low = 8
		high = 12
	elseif coins > 40 then
		low = 4
		high = 7
	elseif coins > 10 then
		low = 3
		high = 5
	elseif coins > 1 then
		low = 1
		high = 3
	else
		low = coins
		high = coins
	end
	return math.random(low, high)
end

--创建金币结点
function EffectGainCoins:createCoinSprite(pos)
	local layer = EffectMgr.getConfig("emc_front_layer")
	
	local node = CCNode:create()
	layer:addChild(node, 10000)
	node:setPosition(pos)
		
	local sprite = CCSprite:create("effect_coin_piece.png")
	node:addChild(sprite, 1)
	sprite:setScale(math.random(90, 100) / 100)
	
	local particle = CCParticleSystemQuad:create("coin_tail.plist")
	node:addChild(particle)
	particle:setPosition(ccp(0, 0))
	
	return node
end

---------------------------------------------------------------------------
--------------------------------数值显示-----------------------------------
---------------------------------------------------------------------------

local mDelay = 2.15
local function playAction(node)
	local act1 = CCSequence:createWithTwoActions(CCDelayTime:create(mDelay * 0.75), CCFadeTo:create(mDelay * 0.25, 64))
	node:runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(mDelay, CCPointMake(0, 40)), act1))
end

--移除自身
local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

function EffectGainCoins:playNumerical()
	local scale1 = 1.8
	local scale2 = 1.5
	local node, offx = self:numericalValue()
	
	local pos = self.mPosition
	local layer = EffectMgr.getConfig("emc_front_layer")
	layer:addChild(node)
	node:setPosition(ccp(pos.x + offx, pos.y))
	node:setAnchorPoint(ccp(0.0, 0.0))
	
	local act1 = CCEaseBackInOut:create(CCScaleBy:create(0.15, scale1))
	local act2 = CCEaseBackInOut:create(CCScaleBy:create(0.05, 1 / scale2))
	node:runAction(CCSequence:createWithTwoActions(act1, act2))
	local act3 = CCSequence:createWithTwoActions(CCDelayTime:create(mDelay), CCCallFuncN:create(removeSelf))
	node:runAction(act3)
end

--创建数值的视图
function EffectGainCoins:numericalValue()
	local layer = CCLayer:create()
	local label = nil
	local symbol = nil
	local preSprite = nil
	local offx = 0
	local valueStr = string.format("%d", math.abs(self.mCoinsAmount))
	
	offx = 50
	preSprite = CCSprite:create("golditem.png")
	label = CCLabelAtlas:create(valueStr, "num_gold.png", 24, 32, 48)
	symbol = CCSprite:create("num_symbol.png", CCRectMake(24 * 7, 0, 24, 32))
	
	--金币数量
	layer:addChild(label)
	label:setAnchorPoint(ccp(0.0, 0.5))
	label:setPosition(ccp(0, 0))
	playAction(label)
	
	--金币数量正负值
	layer:addChild(symbol)
	symbol:setPosition(ccp(-15, 0))
	playAction(symbol)
	
	--金币图标
	layer:addChild(preSprite)
	preSprite:setScale(0.5)
	preSprite:setPosition(ccp(-55, 0))
	playAction(preSprite)
	return layer, offx
end













