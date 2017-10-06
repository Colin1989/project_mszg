----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	金币被盗取特效
----------------------------------------------------

EffectStealConis = class(EffectGainCoins)

--构造
function EffectStealConis:ctor()
	self.mCoinsAmount		= 0		--金币数量
	self.mPosition			= ccp(360, 540)
end

--初始化
function EffectStealConis:init(amount, pos)
	self.mCoinsAmount		= amount
	self.mPosition			= pos
end

--金币开始飞行,刷新金币数量
local function coinStartFly(sender)
	LayerGameUI.updateCoins(sender:getTag())
end

local function coinFlyToIconDone(sender)
	sender:getParent():removeChild(sender, true)
end

--开始播放
function EffectStealConis:play()
	local pos = LayerGameUI.getCoinIconPos()
	local destPos = self.mPosition
	local coins = self.mCoinsAmount
	local total = self:calCoinSpriteAmount(coins)
	local unit = math.floor(coins / total)
	local delay = 0.0
	for i = 1, total do
		local offset = ccp(0, 0)
		local newPos = ccp(pos.x + offset.x, pos.y + offset.y)
		local sprite = self:createCoinSprite(newPos)
		
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delay))
		arr:addObject(CCCallFuncN:create(coinStartFly))
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
		sprite:setTag(-tag)
		delay = delay + math.random(5, 14) / 100
	end
end















