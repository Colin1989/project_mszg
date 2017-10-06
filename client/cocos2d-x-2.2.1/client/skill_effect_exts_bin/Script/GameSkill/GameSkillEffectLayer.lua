----------------------------------------------------------------------
-- 作者：lewis hamilton
-- 日期：2014-03-03
-- 描述：技能特效表现层，分成前景与后景
----------------------------------------------------------------------

local g_main_layer = nil
local g_front_layer = nil
local g_back_layer = nil

g_effect_count = 0

--local g_dest_pos = ccp(0, 0)
--local g_skillID = 0

GameSkillEffectLayer = {}

local function loadPlistFile(name)
		print("load plist file "..name)
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(name)
	end

local function effectEnd(skillID)
	g_effect_count = g_effect_count - 1
	if g_effect_count <= 0 then
		print("all effect end")
		--GameSkillMgr.skillEffectDone()
	end
end


--start back effect
local function backEffect(handleID, skillID, destPos)
	--get skill base info
	local skillBaseInfo = GameSkillConfig.getSkillBaseInfo(skillID)
	if skillBaseInfo == nil then
		return
	end
	
	local skillEffectInfo = GameSkillConfig.getSkillEffectInfo(skillBaseInfo.back_effect_id)
	if skillEffectInfo == nil then
		return
	end
	
	local function backEffectCB(node)
		--print("backEffectCB end skillID:"..skillID)
		node:removeFromParentAndCleanup(true)
		effectEnd(skillID)
	end
	loadPlistFile(skillEffectInfo.plist_name)
	local sprite = CCSprite:createWithSpriteFrameName(skillEffectInfo.file_name)
	local animation = GameSkillConfig.createAnimation(skillEffectInfo.string_format, skillEffectInfo.image_count, 1.0 / 8.0)
	g_back_layer:addChild(sprite)
	sprite:setPosition(destPos)
	local action = CCSequence:createWithTwoActions(CCAnimate:create(animation), CCCallFuncN:create(backEffectCB))
	sprite:runAction(action)
	g_effect_count = g_effect_count + 1
end

--start front effect
local function frontEffect(handleID, skillID, destPos)
	--get skill base info
	local skillBaseInfo = GameSkillConfig.getSkillBaseInfo(skillID)
	if skillBaseInfo == nil then
		return
	end
	
	local skillEffectInfo = GameSkillConfig.getSkillEffectInfo(skillBaseInfo.front_effect_id)
	if skillEffectInfo == nil then
		return
	end
	
	local frontEffectCount = 2
	local function frontEffectCB(node)
		--print("backEffectCB end skillID:"..skillID)
		frontEffectCount = frontEffectCount - 1
		if frontEffectCount <= 0 then
			node:removeFromParentAndCleanup(true)
		else
			node:setOpacity(0)
		end
		effectEnd(skillID)
	end
	loadPlistFile(skillEffectInfo.plist_name)
	local sprite = CCSprite:createWithSpriteFrameName(skillEffectInfo.file_name)
	local animation = GameSkillConfig.createAnimation(skillEffectInfo.string_format, skillEffectInfo.image_count, 1.0 / 8.0)
	g_front_layer:addChild(sprite)
	sprite:setPosition(destPos)
	local action = CCSequence:createWithTwoActions(CCAnimate:create(animation), CCCallFuncN:create(frontEffectCB))
	sprite:runAction(action)
	g_effect_count = g_effect_count + 1
	
	local function hurtEffectCB(node)
		print("hurtEffect end skillID:"..skillID)
		GameSkillMgr.skillEffectDone(handleID, skillID)
		frontEffectCount = frontEffectCount - 1
		if frontEffectCount <= 0 then
			node:removeFromParentAndCleanup(true)
		end
	end
	local delay = CCDelayTime:create(skillEffectInfo.effect_frame_idx * 1.0 / 16.0)
	local hurtAction = CCSequence:createWithTwoActions(delay, CCCallFuncN:create(hurtEffectCB))
	sprite:runAction(hurtAction)
	
end

local g_fly_sprite_table = {}

local function update(dt)
	for key, element in ipairs(g_fly_sprite_table) do
		local x, y = element.sprite:getPosition()
		local vecX = x - element.x
		local vecY = y - element.y
		local angle = math.atan2(vecY, vecX) * (180.0 / 3.14)
		element.sprite:setRotation(360.0 - angle)
	end
end

--start fly effect
local function flyAction(handleID, skillID, startPos, destPos)
	--get skill base info
	local skillBaseInfo = GameSkillConfig.getSkillBaseInfo(skillID)
	if skillBaseInfo == nil then
		return
	end
	
	local skillEffectInfo = GameSkillConfig.getSkillEffectInfo(skillBaseInfo.fly_effect_id)
	if skillEffectInfo == nil then
		print("skip to front effect and back effect")
		frontEffect(handleID, skillID, destPos)
		backEffect(handleID, skillID, destPos)
		if g_effect_count == 0 then
			print("no effect, skillID:", skillID)
			effectEnd(skillID)
		end
		return
	end
	
	loadPlistFile(skillEffectInfo.plist_name)
	local sprite = CCSprite:createWithSpriteFrameName(skillEffectInfo.file_name)
	g_front_layer:addChild(sprite)
	sprite:setPosition(startPos)
	
	local flySpriteTableElement = {}
	flySpriteTableElement.x = startPos.x
	flySpriteTableElement.y = startPos.y
	flySpriteTableElement.sprite = sprite
	table.insert(g_fly_sprite_table, flySpriteTableElement)
	
	local distance = (startPos.x - destPos.x) * (startPos.x - destPos.x) + (startPos.y - destPos.y) * (startPos.y - destPos.y)
	local duration = distance / (1500 * 1500)
	--animation
	local animation = GameSkillConfig.createAnimation(skillEffectInfo.string_format, skillEffectInfo.image_count, 1.0 / 8.0)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	
	local function flyActonCB(node)
		print("flyAction skillID:"..skillID)
		for key, element in ipairs(g_fly_sprite_table) do
			if element.sprite == node then
				table.remove(g_fly_sprite_table, key)
				break
			end
		end
		node:removeFromParentAndCleanup(true)
		frontEffect(handleID, skillID, destPos)
		backEffect(handleID, skillID, destPos)
	end
	
	--move action
	local movTo = CCMoveTo:create(duration, destPos)
	local action = CCSequence:createWithTwoActions(movTo, CCCallFuncN:create(flyActonCB))	
	sprite:runAction(action)
end


function GameSkillEffectLayer.create(parentLayer, front_layer, back_layer)
	g_main_layer = CCLayer:create()
	parentLayer:addChild(g_main_layer)
	g_front_layer = front_layer
	g_back_layer = back_layer
	
	g_fly_sprite_table = {}
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
end

function GameSkillEffectLayer.play(handleID, skillID, startPos, destPos)
	g_dest_pos = destPos
	g_effect_count = 0
	flyAction(handleID, skillID, startPos, destPos)
end

function GameSkillEffectLayer.flightTrajectory(callBack, flyEffectID, frontEffectID, backEffectID, startPos, destPos)
	local function naFrontEffect()
		local frontEffectCount = 2
		local skillEffectInfo = GameSkillConfig.getSkillEffectInfo(frontEffectID)
		if skillEffectInfo == nil then
			print("lewis++++no front effect and go to callBack()")
			callBack()
			return
		end
		
		local frontEffectCount = 2
		local function frontEffectCB(node)
			--print("backEffectCB end skillID:"..skillID)
			frontEffectCount = frontEffectCount - 1
			if frontEffectCount <= 0 then
				node:removeFromParentAndCleanup(true)
			else
				node:setOpacity(0)
			end
		end
		loadPlistFile(skillEffectInfo.plist_name)
		local sprite = CCSprite:createWithSpriteFrameName(skillEffectInfo.file_name)
		local animation = GameSkillConfig.createAnimation(skillEffectInfo.string_format, skillEffectInfo.image_count, 1.0 / 8.0)
		g_front_layer:addChild(sprite)
		sprite:setPosition(destPos)
		local action = CCSequence:createWithTwoActions(CCAnimate:create(animation), CCCallFuncN:create(frontEffectCB))
		sprite:runAction(action)
		
		local function hurtEffectCB(node)
			callBack()
			frontEffectCount = frontEffectCount - 1
			if frontEffectCount <= 0 then
				node:removeFromParentAndCleanup(true)
			end
		end
		local delay = CCDelayTime:create(skillEffectInfo.effect_frame_idx * 1.0 / 16.0)
		local hurtAction = CCSequence:createWithTwoActions(delay, CCCallFuncN:create(hurtEffectCB))
		sprite:runAction(hurtAction)
	end
	
	--normal attack fly effect
	local function naFlyEffect()
		local skillEffectInfo = GameSkillConfig.getSkillEffectInfo(flyEffectID)
		if skillEffectInfo == nil then
			print("Lewis++++normal attack no fly effect, and skip to front effect")
			naFrontEffect()
			return
		end
		
		loadPlistFile(skillEffectInfo.plist_name)
		local sprite = CCSprite:createWithSpriteFrameName(skillEffectInfo.file_name)
		g_front_layer:addChild(sprite)
		sprite:setPosition(startPos)
		
		local flySpriteTableElement = {}
		flySpriteTableElement.x = startPos.x
		flySpriteTableElement.y = startPos.y
		flySpriteTableElement.sprite = sprite
		table.insert(g_fly_sprite_table, flySpriteTableElement)
		
		local distance = (startPos.x - destPos.x) * (startPos.x - destPos.x) + (startPos.y - destPos.y) * (startPos.y - destPos.y)
		local duration = distance / (1200 * 1200)
		--animation
		local animation = GameSkillConfig.createAnimation(skillEffectInfo.string_format, skillEffectInfo.image_count, 1.0 / 8.0)
		sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
		
		local function flyActonCB(node)
			for key, element in ipairs(g_fly_sprite_table) do
				if element.sprite == node then
					table.remove(g_fly_sprite_table, key)
					break
				end
			end
			node:removeFromParentAndCleanup(true)
			naFrontEffect()
		end
		
		--move action
		local movTo = CCMoveTo:create(duration, destPos)
		local action = CCSequence:createWithTwoActions(movTo, CCCallFuncN:create(flyActonCB))	
		sprite:runAction(action)
	end

	naFlyEffect()
end


