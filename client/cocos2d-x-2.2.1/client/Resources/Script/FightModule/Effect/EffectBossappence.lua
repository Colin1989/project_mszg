--region EffectBossappence.lua
--Author : Administrator
--Date   : 2014/10/21

EffectBossappence = class(Effect)

local function removeSelf(sender)
	sender:removeFromParentAndCleanup(true)
end

local function onTouch(eventType, x, y)
	if eventType == "began" then
		return true
	end
end


--构造
function EffectBossappence:ctor()
	self.mCallbackFunc		= nil		--回调函数
	self.mParam				= nil		--回调参数
end

--构造
function EffectBossappence:init(bossView,finnalPos)
	--self.mCallbackFunc		= nil	
        --mSprite mScaleNode mMoveNode	
	self.mMonsterSprite	 = bossView.mRoleView.mSprite --CCSprite:create("testmonster.png")  
    --self.mMonsterSprite:setPosition(ccp(360,540)) --test	code

    ---self.mMonsterSprite:setVisible(false)
    --self.mMonsterSprite:setAnchorPoint(ccp(0.5,0.32))
    
    self.mBossInfoView  = bossView.mInfoView
    self.mBossPosNode	= bossView.mRoleView.mMoveNode
    self.mFinnalPos	    = finnalPos 
    --闪避后位置还原
    bossView.mRoleView.mPos	= ccp(finnalPos.x, finnalPos.y)

    self.mBossPosNode:setScale(0.0)
end

--特效持续时间

function EffectBossappence:duration()
    return 4.5
end


--开始播放
function EffectBossappence:play()
    local layer = EffectMgr.getConfig("emc_front_layer")
    --local layer = g_uiRoot

    local movetime = 0.5
    local delaytime = 1.2
    local disappencetime = 1.0
    local lightuptime = 1.0
    local lightdowntime = 0.5
    --BOSS本体
    Lewis:spriteShaderEffect(self.mMonsterSprite,"monster_allwhite.fsh",true)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(movetime + delaytime + disappencetime +lightuptime + lightdowntime + 0.5))
    
    arr:addObject(CCCallFuncN:create(function(sender)
        --Lewis:spriteShaderEffectOnce(self.mMonsterSprite,"monster_white.fsh",true)
        Lewis:spriteShaderEffect(self.mMonsterSprite,"monster_allwhite.fsh",false)
        self.mMonsterSprite:setColor(ccc3(0,0,0))
        self.mBossInfoView:setViewVisible(true)
    end))
    arr:addObject(CCTintTo:create(0.3, 255, 255, 255) )
    arr:addObject(CCCallFuncN:create(
    function(sender)
	    if FightDateCache.getData("fd_copy_id") == FIRSTCOPYID then
                GuideMgr.onEnter()
                GuideMgr.onBattle(FIRSTCOPYID)
	    end
    end 
    ))
    self.mMonsterSprite:runAction(CCSequence:create(arr))
    --本体移动
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(movetime + delaytime + disappencetime +lightuptime))
    arr:addObject(CCPlace:create(ccp(self.mFinnalPos.x, self.mFinnalPos.y+600)))
    --arr:addObject(CCEaseSineIn:create(CCMoveBy:create(lightdowntime,ccp(0,-600))))   
    arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(lightdowntime,0.5),CCEaseSineIn:create(CCMoveTo:create(lightdowntime,self.mFinnalPos))))
    arr:addObject(CCScaleTo:create(0.5,2.0))
    self.mBossPosNode:runAction(CCSequence:create(arr))

    
    --黑色背景
    local Screen = CCDirector:sharedDirector():getVisibleSize()
	local layerColor = CCLayerColor:create(ccc4(0,0,0,128), Screen.width, Screen.height)
    layer:addChild(layerColor)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(movetime + delaytime+ disappencetime))
    arr:addObject(CCFadeTo:create(1.0,0))
    arr:addObject(CCDelayTime:create(lightuptime + lightdowntime))
    arr:addObject(CCCallFuncN:create(removeSelf))
    layerColor:runAction(CCSequence:create(arr))
    layerColor:registerScriptTouchHandler(onTouch, false, -200, true)
	layerColor:setTouchEnabled(true)

    local winSize = CCDirector:sharedDirector():getWinSize()
    
     --光晕
    local spCircleLight = CCSprite:create("boss_appence_light.png")
    spCircleLight:setPosition(ccp(winSize.width/2, winSize.height/2))
    layer:addChild(spCircleLight)

    spCircleLight:setScale(0.0)
    spCircleLight:setOpacity(0)

    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(movetime + delaytime))
    arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(disappencetime,1.0),CCFadeIn:create(disappencetime)))
    arr:addObject(CCEaseBackInOut:create(CCMoveBy:create(lightuptime,ccp(0,650))))
   -- arr:addObject(CCEaseSineIn:create(CCMoveBy:create(1.5,ccp(0,-650))))    --FIXME 有可能飞多只
   -- arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.5,1.0),CCFadeOut:create(0.5)))
    arr:addObject(CCCallFuncN:create(removeSelf))
    spCircleLight:runAction(CCSequence:create(arr))

   
    --鬼
    local spGui = CCSprite:create("boss_appence_gui.png")
    spGui:setPosition(ccp(winSize.width/2, winSize.height/2+600))
    layer:addChild(spGui)

    local arr = CCArray:create()
    arr:addObject(CCMoveBy:create(movetime,ccp(0,-600)))
    local blank = CCRepeat:create(CCSequence:createWithTwoActions(CCFadeTo:create(delaytime/4, 50), 
    CCFadeTo:create(delaytime/4, 255)), 2)
    arr:addObject(blank)
    arr:addObject(CCSpawn:createWithTwoActions(CCRotateBy:create(disappencetime,720),CCScaleBy:create(disappencetime,0.0)))
    arr:addObject(CCCallFuncN:create(removeSelf))
    spGui:runAction(CCSequence:create(arr))


    --感叹号左边
    local spSighLeft = CCSprite:create("boss_appence_gantan.png")
    spSighLeft:setPosition(ccp(180-250,365))
    layer:addChild(spSighLeft)

    local arr = CCArray:create()
    arr:addObject(CCMoveBy:create(movetime,ccp(250,0)))
    arr:addObject(CCDelayTime:create(delaytime))
    arr:addObject(CCEaseSineInOut:create(CCMoveBy:create(disappencetime,ccp(-250,0))))
    arr:addObject(CCCallFuncN:create(removeSelf))
    spSighLeft:runAction(CCSequence:create(arr))
    -- 感叹号右
    local spSighRgiht = CCSprite:create("boss_appence_gantan.png")
    spSighRgiht:setPosition(ccp(460+250,365))
    layer:addChild(spSighRgiht)

    local arr = CCArray:create()
    arr:addObject(CCMoveBy:create(movetime,ccp(-250,0)))
    arr:addObject(CCDelayTime:create(delaytime))
    arr:addObject(CCEaseSineOut:create(CCMoveBy:create(disappencetime,ccp(250,0)))) 
    arr:addObject(CCCallFuncN:create(removeSelf))
    spSighRgiht:runAction(CCSequence:create(arr))

    --文字
    local spFout = CCSprite:create("boss_appence_text.png")
    spFout:setPosition(ccp(320,340-400))
    layer:addChild(spFout)

    local arr = CCArray:create()
    arr:addObject(CCMoveBy:create(movetime,ccp(0,400)))
    arr:addObject(CCDelayTime:create(delaytime))
    arr:addObject( CCEaseSineOut:create(CCMoveBy:create(disappencetime,ccp(0,-600))))
    arr:addObject(CCCallFuncN:create(removeSelf)) 
    spFout:runAction(CCSequence:create(arr))

    --文字上的动画
    ResourceManger.LoadSinglePicture("boss_appence_fontlight")
    local spfontlight = CCSprite:create("boss_appence_text.png")
    spfontlight:setPosition(ccp(360,340))
    spfontlight:setVisible(false)
    layer:addChild(spfontlight)
    local animation = createAnimation("boss_appence_fontlight_%02d.png",12,0.05)
	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(movetime))
    arr:addObject(CCShow:create())
    arr:addObject(CCAnimate:create(animation))
    arr:addObject(CCAnimate:create(animation))
	arr:addObject(CCCallFuncN:create(removeSelf))
	spfontlight:runAction(CCSequence:create(arr))   
end

--特效结束
function EffectBossappence:over()
	if self.mCallbackFunc == nil then
		return
	end
	self.mCallbackFunc(self.mParam)
end


--endregion
