----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	技能管理器
----------------------------------------------------

require "Effect"
require "EffectBallistic"
require "EffectSkill"
require "EffectPlayerCast"
require "EffectWizardCast"
require "EffectWarriorCast"
require "EffectKnightCast"
require "EffectShamanCast"


require "EffectBloodBottle"
require "EffectGainCoins"
require "EffectStealConis"
require "EffectDropOut"
require "EffectSeparatBody"
require "Effectdevor"
require "EffectAnimate"
require "EffectCollectSoul"
require "EffectMapName"
require "EffectPVP"
require "EffectPlayerKnockout"
require "EffectBombGrid"
require "EffectPickupKey"
require "EffectSkillName"
require "EffectRespawn"
require "EffectSummon"
require "EffectBossappence"
require "EffectDamageRebound"

require "EffectRoundflag"
require "EffectPVP33"
require "Effectskillfont"

require "EffectBattleEnd"

EffectMgr = {}
local mConfigTB = {}

function EffectMgr.init()
	EffectMgr.initConfig()
end

function EffectMgr.cleanup()
	EffectMgr.reset()
	mConfigTB = {}
end

function EffectMgr.reset()
	local tb = EffectMgr.getConfig("emc_parent_table")
	if tb then
		for key, value in pairs(tb) do
			value:removeFromParentAndCleanup(true)
		end
	end
	EffectMgr.setConfig("emc_parent_table", {})
end
---------------------------------------------------------------------------
--------------------------------配置数据-----------------------------------
---------------------------------------------------------------------------
--初始化配置数据
function EffectMgr.initConfig()
	mConfigTB = {}
	mConfigTB["emc_front_layer"]				= nil		--前景父结点
	mConfigTB["emc_back_layer"]					= nil		--背景父结点
	mConfigTB["emc_parent_table"]				= {}		--特效父结点,采用batch node
	mConfigTB["emc_frame_interval"]				= 1.0 / 14.0--帧动画间隔
	mConfigTB["emc_ballistic_speed"]			= 2100		--弹道速度
    mConfigTB["emc_font_tips_layer"]			= nil		--文字提示层
    
end

--获得数据
function EffectMgr.getConfig(name)
	local ret = mConfigTB[name]
	return ret
end

--设置数据
function EffectMgr.setConfig(name, value)
	mConfigTB[name] = value
end

---------------------------------------------------------------------------
--------------------------------功能函数-----------------------------------
---------------------------------------------------------------------------
--获得父结点
function EffectMgr.getParent(zOrder, config)
	local parentTB 		= EffectMgr.getConfig("emc_parent_table")
	local parent 		= parentTB[config.effect_id]
	local frontLayer 	= EffectMgr.getConfig("emc_front_layer")
	local backLayer 	= EffectMgr.getConfig("emc_back_layer")
	--创建batch node父结点
	if parent == nil then
		local layer = (zOrder == 1) and frontLayer or backLayer
		local plistName = config.plist_name
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistName)
		local filename = string.gsub(plistName, ".plist", ".png")
		parent = CCSpriteBatchNode:create(filename, 29)
		layer:addChild(parent)
		parent:setPosition(ccp(0, 0))
		parentTB[config.effect_id] = parent
	end
	return parent
end

--创建精灵
function EffectMgr.createSprite(zOrder, config, pos)
	--获取父接点
	local parent = EffectMgr.getParent(zOrder, config)
	--创建精灵
	local sprite = CCSprite:createWithSpriteFrameName(config.file_name)
	parent:addChild(sprite)
	
	--读取偏移位置
	local offx, offy = SkillConfig.getSkillEffectOffset(config.effect_id)
	sprite:setPosition(ccp(pos.x + offx, pos.y + offy))
	
	return sprite
end

--计算弹道方向
function EffectMgr.calcRotation(sprite, fromPos, toPos)
	local vecX = toPos.x - fromPos.x
	local vecY = toPos.y - fromPos.y
	local angle = math.atan2(vecY, vecX) * (180.0 / 3.14)
	sprite:setRotation(360.0 - angle)
end

--计算飞行动画时间
function EffectMgr.calcFlyDuration(srcPos, destPos)
	local speed = EffectMgr.getConfig("emc_ballistic_speed")
	local distance = math.sqrt((srcPos.x - destPos.x) * (srcPos.x - destPos.x) + (srcPos.y - destPos.y) * (srcPos.y - destPos.y))
	local duration = distance / speed
	return duration
end

--创建黑色遮罩
function EffectMgr.creatMask()
	local parent = EffectMgr.getConfig("emc_front_layer")
	local layer = CCLayer:create()
	parent:addChild(layer)
	
	local mask = CCSprite:create("caster_mask.png")
	layer:addChild(mask)
	mask:setPosition(ccp(360, 540))
	mask:setScaleX(720 / 36)
	mask:setScaleY(1080 / 54)
	return layer
end

--曲线动作
function EffectMgr.curvilinearMotion(duration, fromPoint, toPoint)
	--创建路径数组
	--fromPoint.y = fromPoint.y + 40
	local array=CCPointArray:create(5)
	array:addControlPoint(fromPoint)
	local middlePoint = ccpMidpoint(fromPoint,toPoint)
	
	local delta = 0
	if math.random(1, 100) < 50 then
		delta = math.random(-120, -20)
	else
		delta = math.random(20, 120)
	end
	mbNegation = not mbNegation
	
	array:addControlPoint(ccpAdd(middlePoint,ccp(delta, delta)))
	array:addControlPoint(toPoint)	
	
	return CCCardinalSplineTo:create(duration, array, 0)--0.5)
end












