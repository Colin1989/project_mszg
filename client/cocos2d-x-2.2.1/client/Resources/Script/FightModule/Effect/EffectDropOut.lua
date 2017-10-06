----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	掉落物品特效
----------------------------------------------------

EffectDropOut = class(Effect)

--构造
function EffectDropOut:ctor()
	self.mPosition		= ccp(360, 540)			--掉落位置
	self.mGoodsTB		= {}					--掉落物品表
end

--初始化
function EffectDropOut:init(pos, goodsTB)
	self.mPosition 	= pos
	self.mGoodsTB	= goodsTB
end

--开始播放
function EffectDropOut:play()
	local layer = EffectMgr.getConfig("emc_front_layer")
	local pos = ccp(self.mPosition.x, self.mPosition.y)
	local total = #self.mGoodsTB
	local width = 50
	local gap = 65
	local sx = pos.x - math.ceil((width + gap) * (total + 1) / 2)
	if sx < 150 then
		sx = 150 + 10
	end
	if sx > 720 then
		sx = 360 + 10
	end
	
	local delayTime = 0.55
	for key, value in pairs(self.mGoodsTB) do
		local node = self:createItemNode(value.id, value.amount)
		layer:addChild(node, 100)
		node:setPosition(pos)
		local destPos = ccp(sx, pos.y + math.random(-60, 60))
		local offx = destPos.x - pos.x
		self:playItemAction(node, destPos, 90, offx, delayTime)
		delayTime = delayTime + 0.1
		sx = sx + gap
	end
end

--创建掉落特品结点
function EffectDropOut:createItemNode(id, amount)
	local itemRow = LogicTable.getRewardItemRow(id)
	local bgStr = CommonFunc_getQualityInfo(itemRow.quality).image
	local bg = CCSprite:create(itemRow.icon)
	local sprite = CCSprite:create(bgStr)
	bg:addChild(sprite)
	local size = bg:getContentSize()
	sprite:setPosition(ccp(size.width / 2, size.height / 2))
	return bg
end


--获取宝箱
local function gainGoldBoxDone(sender)
	sender:getParent():removeChild(sender,true)
	LayerGameUI.updateBoxNum()
end

function EffectDropOut:playItemAction(sprite, destPos, height, offx, delayTime)
	--缩小到0.5倍
	sprite:setScale(0.5)
	--第二次弹跳距离
	local destPos1 = ccp(destPos.x + offx / 4, destPos.y)
	--第三次弹跳距离
	local destPos2 = ccp(destPos1.x + offx / 8, destPos.y)
	--第四次弹跳距离
	local destPos3 = ccp(destPos2.x + offx / 16, destPos.y)
	local arr = CCArray:create()
	arr:addObject(CCJumpTo:create(0.4, destPos, height, 1))
	arr:addObject(CCJumpTo:create(0.3, destPos1, height / 2, 1))
	arr:addObject(CCJumpTo:create(0.2, destPos2, height / 3, 1))
	arr:addObject(CCJumpTo:create(0.1, destPos3, height / 4, 1))
	arr:addObject(CCDelayTime:create(delayTime))
	arr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(0.75, ccp(50, 1060)), CCScaleTo:create(0.75, 0.2)))
	arr:addObject(CCCallFuncN:create(gainGoldBoxDone))
	sprite:runAction(CCSequence:create(arr))
end













