--region EffectRoundflag.lua
--Author : Effectroundflag
--Date   : 2015/1/6
--此文件由[BabeLua]插件自动生成

EffectRoundflag = class(EffectPlayerCast)local function getFlagRes(flag)    local str = "wofanghuihe.png"    if flag == "myround" then        str = "wofanghuihe.png"    elseif flag == "enemyround" then        str = "difanghuihe.png"    elseif flag =="myround_add" then        str = "wofangzengyuan.png"    elseif flag == "enemy_add"  then        str = "difangzengyuan.png"    end     return strend --构造function EffectRoundflag:ctor()   self.mCampFlag = nil end--初始化function EffectRoundflag:init(campFlag)    self.mCampFlag = campFlagend--执行function EffectRoundflag:play()	local function exitCB(sender)		sender:removeFromParentAndCleanup(true)		self:over()	end	local parent = EffectMgr.getConfig("emc_front_layer")		--背景遮罩	local mask = self:createMask(ccc4(255,255,255,0))	parent:addChild(mask)	local arr = CCArray:create()	arr:addObject(CCDelayTime:create(0.8))	arr:addObject(CCCallFuncN:create(exitCB))	mask:runAction(CCSequence:create(arr))		--图层	local layer = CCLayer:create()	mask:addChild(layer, 1000)	layer:setPosition(ccp(0, 0))	--背景    FightDateCache.setData("fd_global_lockevent", self.mCampFlag ~= "myround")	local bg = CCSprite:create(getFlagRes(self.mCampFlag))	layer:addChild(bg)	bg:setPosition(ccp(320-200, 480))    bg:setOpacity(0)    local action1 = CCSpawn:createWithTwoActions(
	CCEaseSineIn:create( CCMoveBy:create(0.3,CCPointMake(200,0))),
	CCFadeIn:create(0.3))    local action2 =  CCMoveBy:create(0.2,CCPointMake(100,0))    local action3 = CCSpawn:createWithTwoActions(
	CCEaseSineOut:create( CCMoveBy:create(0.2,CCPointMake(200,0))),
	CCFadeOut:create(0.3))	local arr = CCArray:create()    arr:addObject(action1)	arr:addObject(action2)    arr:addObject(action3)	bg:runAction(CCSequence:create(arr))    endfunction EffectRoundflag:getDuration()
    return 0.8
end 

--endregion
