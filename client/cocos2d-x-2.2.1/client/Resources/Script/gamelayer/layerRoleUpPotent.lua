

LayerRoleUpPotent = setmetatable({},{__mode='k'})
LayerRoleUpPotent.jsonFile = "RoleUpPotent_1.json"

LayerRoleUpPotent.RootView = nil

--是否使用护符
local isUsePro = 0 --不用 1 用
local isHadPro = 0 --0 有 1 没有 当前是否有护符
local mPlayerNode = nil	--帧动画节点
local cur_pl = 0
local UIView_loadingBar = nil
local CIRCLE_MARGIN = 85.8/360       --角度偏移

--护符对象（没有就默认nil)
local mAmuletInfo = nil 

-- 升级需要潜能
local mNeedPoint = 0


local mPotenceTb = XmlTable_load("potence_tplt.xml", "id") 

local function setUILabelTest(name,point)
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local label = LayerRoleUpPotent.RootView:getChildByName(name)
	tolua.cast(label,"UILabel")
	--label:setText(string.format("%d",tonumber(point)))
	if type(point) ~= "string" then 
		point = tostring(point)
	end 
	label:setText(point)
end 

--根据英雄的进阶等级，播放对应的帧动画
local function playRoleActionByAdvanceLel(level)
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local role_appence = LayerRoleUpPotent.RootView:getChildByName("nextRoleAppence")
	local role_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),level)	
	local role_Ani = ResourceManger.getAnimationFrameById(role_tplt.icon)
	ResourceManger.LoadSinglePicture(role_Ani.name)	
	local strPath = string.format("%s_%s", role_Ani.name, role_Ani.wait).."_%03d.png"
	mPlayerNode = createAnimation_forever(strPath, role_Ani.wait_frame, 0.1)
	role_appence:getRenderer():removeAllChildrenWithCleanup(true)
	role_appence:addRenderer(mPlayerNode,23)	
end

local lastAdvance_lv = nil
local function showRole()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	if lastAdvance_lv == ModelPlayer.getAdvancedLevel() or lastAdvance_lv == nil then  
		playRoleActionByAdvanceLel(ModelPlayer.getAdvancedLevel())
		--潜能提升动画
		LayerRoleUpPotent.showRoleUpEffect()
	elseif lastAdvance_lv ~= ModelPlayer.getAdvancedLevel() then
		--英雄升阶动画
	    LayerRoleUpPotent.HeroEvolveEffect()	
    end 
	lastAdvance_lv = ModelPlayer.getAdvancedLevel()
end

local function starMoveAction(duration, fromPoint, toPoint)
	--创建路径数组
	--fromPoint.y = fromPoint.y + 40
	local array=CCPointArray:create(5)
	array:addControlPoint(fromPoint)
	local middlePoint = ccpMidpoint(fromPoint,toPoint)
	
	local delta = 0
	if math.random(1, 100) < 50 then
		delta = math.random(-80, -30)
	else
		delta = math.random(30, 80)
	end
	mbNegation = not mbNegation
	
	array:addControlPoint(ccpAdd(middlePoint,ccp(delta, delta)))
	array:addControlPoint(toPoint)	
	
	return CCCardinalSplineTo:create(duration, array, 0)--0.5)
end

local function removeSelf(node)
	node:removeFromParentAndCleanup(true)
end

--计算偏离位置
local function calOffsetPos(raduis, angle)
	angle = angle / 180.0 * 3.14
	local x = math.sin(angle) * raduis
	local y = math.cos(angle) * raduis
	return ccp(x, y)
end

--背景动画
local function roleUpAnimation()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local widget = LayerRoleUpPotent.RootView:getChildByName("ImageView_262")
	local widget1 = LayerRoleUpPotent.RootView:getChildByName("ImageView_47")
	local effectNode1 = CCLayer:create()
	widget:addRenderer(effectNode1, 0)
	local effectNode2 = CCLayer:create()
	--effectNode2:setOpacity(0.5)
	widget1:addRenderer(effectNode2, 50)
	--背景动画
		local bgEffect1 = createAnimation_signal("effect_082d_%02d.png", 16, 0.1)
		bgEffect1:setAnchorPoint(ccp(0.5,0.5))
		bgEffect1:setPosition(ccp(0,0))
		effectNode1:addChild(bgEffect1)
	
	--旋转上升动画
		local bgEffect2 = createAnimation_signal("effect_082u_%02d.png", 16, 0.1)
		bgEffect2:setAnchorPoint(ccp(0.5,0.5))
		bgEffect2:setPosition(ccp(0,0))
		bgEffect2:setOpacity(80)
		effectNode2:addChild(bgEffect2)
end

--提升潜能的特效
function LayerRoleUpPotent.showRoleUpEffect()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local startPos = LayerRoleUpPotent.RootView:getWorldPosition()
	local destPos = LayerRoleUpPotent.RootView:getChildByName("nextRoleAppence"):getWorldPosition()
	destPos = ccpSub(destPos, startPos)
	destPos.y = destPos.y - 30
	local fromPos = ccp(destPos.x + 300, destPos.y)
	
	local total = math.random(7, 12)
	local delayTime = 0.0
	local moveTime = 0.6
	
	LayerRoleUpPotent.RootView:getRenderer():stopAllActions()
	for i = 1, total do
		local sprite = CCSprite:create("eff_white_star.png")
		LayerRoleUpPotent.RootView:getRenderer():addChild(sprite, 100)
		sprite:setScale(math.random(60, 80) / 100)
		sprite:setScale(0.5)
		
		local offsetPos = calOffsetPos(math.random(60, 90), math.random(0, 360))
		local arr = CCArray:create()
		arr:addObject(CCHide:create())
		arr:addObject(CCDelayTime:create(delayTime))
		arr:addObject(CCShow:create())
		arr:addObject(starMoveAction(moveTime, fromPos, destPos))
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.15, offsetPos), CCFadeTo:create(0.15, 128)))
		arr:addObject(CCScaleTo:create(0.2,1.0))
		arr:addObject(CCCallFuncN:create(removeSelf))
		arr:addObject(CCCallFuncN:create(roleUpAnimation))
		sprite:runAction(CCSequence:create(arr))
		
		local delta = math.random(8, 14) / 100
		delayTime = delayTime + delta
		moveTime = moveTime - delta / 3
	end
	
end
------------------------------------------------------------------------------------------------------
--出现进阶的英雄
function LayerRoleUpPotent.showHero()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	-- 英雄
	local hero = tolua.cast(LayerRoleUpPotent.RootView:getChildByName("nextRoleAppence"),"UIImageView")
	Lewis:spriteShaderEffect(mPlayerNode, "debuff_drug.fsh", true)
	hero:stopAllActions()
	
	--加载对应的升阶后的动画
	local function heroCallBack()
		playRoleActionByAdvanceLel(ModelPlayer.getAdvancedLevel())			
	end

	local function func()
		if mPlayerNode ~= nil then
			Lewis:spriteShaderEffect(mPlayerNode, "debuff_drug.fsh", false)	
			hero:setScale(1.0)
			local up = LayerRoleUpPotent.RootView:getChildByName("uppentent")
			up:setTouchEnabled(true)
		end

		--local action2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.2,1.0), CCCallFunc:create(heroCallBack))
		local action2 = CCSpawn:createWithTwoActions(CCFadeIn:create(1.0), CCCallFunc:create(heroCallBack))
		hero:runAction(action2)
	end
	
	local arr =CCArray:create()
	arr:addObject(CCSpawn:createWithTwoActions(CCEaseBackOut:create(CCScaleTo:create(0.1,1)),CCEaseExponentialIn:create(CCFadeIn:create(0.6))))
	--arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(1.1),CCScaleTo:create(1.1,0.5)))
	arr:addObject(CCFadeOut:create(1.1))
	arr:addObject(CCCallFunc:create(func))
	hero:runAction(CCSequence:create(arr))

end

--旋转的光线
function LayerRoleUpPotent.rotateLight()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local lightBg = tolua.cast(LayerRoleUpPotent.RootView:getChildByName("ImageView_262"),"UIImageView")
	local img = tolua.cast(LayerRoleUpPotent.RootView:getChildByName("rotateLight"),"UIImageView")
	
	if img == nil then
		img = UIImageView:create()
		img:loadTexture("evolve_effect6.png")
		img:setName("rotateLight")	
		img:setAnchorPoint(ccp(0.5,0.5))
		img:setPosition(ccp(0,0))
		lightBg:addChild(img)
	end
	img:stopAllActions()
	img:setScale(0.1)

	local arr = CCArray:create()
	arr:addObject(CCShow:create())
	arr:addObject(CCSpawn:createWithTwoActions( CCRotateBy:create(1,80),CCScaleTo:create(0.2,0.4)))
	arr:addObject(CCSpawn:createWithTwoActions( CCRotateBy:create(1,80),CCFadeOut:create(1 )))
	arr:addObject(CCHide:create())
	img:runAction(CCSequence:create(arr))	
end

--掉落的球
function LayerRoleUpPotent.dropBall()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local bg = tolua.cast(LayerRoleUpPotent.RootView:getChildByName("ImageView_47"),"UIImageView")
	local img = tolua.cast(LayerRoleUpPotent.RootView:getChildByName("ball"),"UIImageView")
	if img == nil then
		img = UIImageView:create()
		img:loadTexture("evolve_effect4.png")
		img:setName("ball")				
		bg:addChild(img)
	end
	img:stopAllActions()
	img:setOpacity(0.5)	
	img:setPosition(ccp(0,119))
	img:setScale(0.3)
	local function reset()
		img:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(0.3,1.3),CCFadeOut:create(0.4)))
		LayerRoleUpPotent.showHero()	
	end
	
	local arr = CCArray:create()
	arr:addObject(CCSpawn:createWithTwoActions( CCFadeIn:create(0.1),CCMoveBy:create(0.5,ccp(0,-119))))
	arr:addObject(CCCallFunc:create(LayerRoleUpPotent.rotateLight))
	arr:addObject(CCEaseElasticOut:create(CCScaleTo:create(0.3,1)))
	arr:addObject(CCCallFunc:create(reset))
	img:runAction(CCSequence:create(arr))	
end

--屏幕闪白光
function LayerRoleUpPotent.showWhiteScreen()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
    local img =  tolua.cast(LayerRoleUpPotent.RootView:getChildByName("screen"),"UIImageView")
	if img == nil then
		img = UIImageView:create()
		img:loadTexture("halo_2.png")
		img:setName("screen")
		img:setScale(50)
		img:setOpacity(0)
		img:setPosition(ccp(320,480))
		LayerRoleUpPotent.RootView:addChild(img)
	end
	img:stopAllActions()
	local function reset()
		img:setVisible(false)
	end
	local arr =CCArray:create()
	arr:addObject(CCShow:create())
	arr:addObject(CCFadeIn:create(0.1))
	arr:addObject(CCDelayTime:create(0.1))
	arr:addObject(CCFadeOut:create(0.1))
	arr:addObject(CCCallFunc:create(reset))
	img:runAction(CCSequence:create(arr))
end

--英雄进阶的动画
function LayerRoleUpPotent.HeroEvolveEffect()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local up = LayerRoleUpPotent.RootView:getChildByName("uppentent")
	up:setTouchEnabled(false)
	LayerRoleUpPotent.showWhiteScreen()
	LayerRoleUpPotent.dropBall()
end
-----------------------------------------------------------------------------------------------------------------
local function createCirCleLoadBar()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local loadBar = LayerRoleUpPotent.RootView:getChildByName("ynLoadingBar")
	local sprite = CCSprite:create("roleup_modify_2.png");
	sprite:setFlipY(true)

	local maskProgress = CCProgressTimer:create(sprite)

    print("-----------------------------CIRCLE_MARGIN*180--------->",CIRCLE_MARGIN*180)
	maskProgress:setRotation(180- CIRCLE_MARGIN*180)


	--maskProgress:setColor(ccc3(0, 0, 0))
	maskProgress:setOpacity(192)
	maskProgress:setType(kCCProgressTimerTypeRadial)

	UIView_loadingBar = maskProgress
	local advenceInfo = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel())

	local first_pl = tonumber(advenceInfo.potence_level)
	local total_pl = tonumber(advenceInfo.progress_length)
	local cur_pl = tonumber(ModelPlayer.getPotenceLevel())
	

     --print("circle:fannly--------init------------------>:",CIRCLE_MARGIN + (1-CIRCLE_MARGIN)*(cur_pl - first_pl)/total_pl *100 )
	maskProgress:setPercentage((cur_pl - first_pl)/total_pl *100 *(1-CIRCLE_MARGIN) + CIRCLE_MARGIN*100)
   
	loadBar:addRenderer(maskProgress,10)
end 

-- 更新进度条
local function UpdateLoadBar()
	--update LoadBar
	local advenceInfo = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel())
	local first_pl = tonumber(advenceInfo.potence_level)
	local total_pl = tonumber(advenceInfo.progress_length)
	local cur_pl = tonumber(ModelPlayer.getPotenceLevel())

	if UIView_loadingBar ~= nil then 
		cclog("(cur_pl - first_pl)/total_pl ++++update",25 + 0.75*(cur_pl - first_pl)/total_pl *100)
		UIView_loadingBar:runAction(CCProgressTo:create(0.5,(CIRCLE_MARGIN*100 + (1-CIRCLE_MARGIN)*(cur_pl - first_pl)/total_pl *100)))
	end
end 
--ModelPlayer.getPotenceLevel()
function getAttrByPotent(PotentId)
	local attr =  mPotenceTb.map[tostring(PotentId)]
	return attr
end 


-- 设置等阶信息
local function setNextPotence()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	--local PotentId = mPotenceTb.map[tostring(PotentId)]
	local curPotenceInfo =  getAttrByPotent(ModelPlayer.getPotenceLevel())
	setUILabelTest("curqn1",string.format("%.2f",ModelPlayer.getPotenceLevel()/100))
	setUILabelTest("curqn2",ModelPlayer.getPlayerAttr().life)
	setUILabelTest("curqn3",ModelPlayer.getPlayerAttr().atk)
	
	local labelatlas = LayerRoleUpPotent.RootView:getChildByName("roleUpShowlabelas")
	tolua.cast(labelatlas,"UILabelAtlas")
	labelatlas:setStringValue(string.format("%.2f", ModelPlayer.getPotenceLevel()/100))

	local NextPotenceInfo =  getAttrByPotent(ModelPlayer.getPotenceLevel()+1)

    local label = LayerRoleUpPotent.RootView:getChildByName("ny_rate")
	tolua.cast(label,"UILabel")
	
	if NextPotenceInfo == nil then 
		--setText()
		setUILabelTest("curqn1",GameString.get("FULL"))
		setUILabelTest("curqn2",GameString.get("FULL"))
		setUILabelTest("curqn2",GameString.get("FULL"))
		mNeedPoint = GameString.get("FULL")
        label:setText(GameString.get("FULL"))
	else 
        label:setText(NextPotenceInfo.rate.."%")
		setUILabelTest("nextpu1",string.format("%.2f",(1+ModelPlayer.getPotenceLevel())/100))
		setUILabelTest("nextpu2",ModelPlayer.getPlayerAttr().life +tonumber(NextPotenceInfo.life) - tonumber(curPotenceInfo.life))-- + )
		setUILabelTest("nextpu3",ModelPlayer.getPlayerAttr().atk+tonumber(NextPotenceInfo.attack) - tonumber(curPotenceInfo.attack))-- + ModelPlayer.getPlayerAttr().atk)
		mNeedPoint = tonumber(NextPotenceInfo.battle_soul)
	end
	
	--print("Need_Zf:mNeedPoint",mNeedPoint,NextPotenceInfo.battle_soul)
	setUILabelTest("need_zf",mNeedPoint)
	setUILabelTest("cur_zf",ModelPlayer.getBattleSoul())
	
	--createCirCleLoadBar()
end 

local function setPotenceAdvance(isUseAmulet)
	local tb = req_potence_advance()
	tb.is_use_amulet = isUseAmulet
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_potence_advance_result"])
end

local function useProLogic()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	local showIcon = LayerRoleUpPotent.RootView:getChildByName("showfuhuicon")
	tolua.cast(showIcon,"UIImageView")
	local unUseIcon = LayerRoleUpPotent.RootView:getChildByName("unuse_item")
	local protectBtn = LayerRoleUpPotent.RootView:getChildByName("usepro")
	tolua.cast(protectBtn, "UIImageView")
	if isUsePro == 0 then -- 如果没用使用护符
		unUseIcon:setVisible(false)
		protectBtn:loadTexture("gem_e_08.png")
		-- CommonFunc_AddGirdWidget(6002, 1, nil, function()
			-- widget:loadTexture("public_gemback.png")
			-- unUseIcon:setVisible(true)
			-- isUsePro = 0
		-- end, widget)
		local widget = CommonFunc_AddGirdWidget(6002, 0)
		showIcon:addChild(widget)
		isUsePro = 1
	else
		unUseIcon:setVisible(true)
		protectBtn:loadTexture("gem_e_05.png")
		-- protectAmountLabel:setVisible(false)
		showIcon:removeAllChildren()
		isUsePro = 0
	end 
end 

local function handle_onClick(typeName,widget) 
	if typeName == "releaseUp" then
		TipModule.onClick(widget)
		local curName = widget:getName()

		--提示潜能
		if curName == "uppentent" then 
			if type(mNeedPoint) == "number" and mNeedPoint >  ModelPlayer.getBattleSoul() then
				Toast.show(GameString.get("ZFBZ"))
				return 
			end 
			setPotenceAdvance(isUsePro)
		elseif curName == "qn_comeback" then 
			setConententPannelJosn(LayerRoleUp,LayerRoleUp.jsonFile,curName)
		--提升潜能说明
		elseif curName == "potentdesc" then 
			setConententPannelJosn(LayerRoleUpDesc,LayerRoleUpDesc.jsonFile,curName)
		--使用保护咒
		elseif curName == "usepro" then
			-- 6002 为护符ID
			local amuletInfo = ModelBackpack.getItemByTempId(6002)
			if nil == amuletInfo then	-- 背包中没有护符
				local func = {LayerRoleUpPotent.updateAmulet, nil}
				CommonFunc_payConsume(3, 1, 6002, One_Time_Purchase, func)
				return
			else
				useProLogic()
			end
		end 
	end 
end 

-- 更新提示按钮状态
function UpdateImproveBtnStatus()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	--update Btn
	local showLevelLimit = LayerRoleUpPotent.RootView:getChildByName("isOpenUppontent") 
	tolua.cast(showLevelLimit,"UIImageView")

    local limitlvlas = LayerRoleUpPotent.RootView:getChildByName("limitlvlas") 
    tolua.cast(limitlvlas,"UILabelAtlas")
    limitlvlas:setVisible(false)

	local nextPt_Info = mPotenceTb.map[tostring(ModelPlayer.getPotenceLevel()+1)]
	local btn = LayerRoleUpPotent.RootView:getChildByName("uppentent")
	
	if nextPt_Info == nil then 
	 	btn:unregisterEventScript()
		Lewis:spriteShaderEffect(btn:getVirtualRenderer(),"buff_gray.fsh",true)
        showLevelLimit:loadTexture("roleup_shangxian.png")
		
	elseif tonumber(nextPt_Info.level_limit) > ModelPlayer.getLevel() then 
		showLevelLimit:setVisible(true)
		limitlvlas:setVisible(true)
        limitlvlas:setStringValue(tostring(nextPt_Info.level_limit))
        showLevelLimit:loadTexture("roleup_dengjibuzu.png")

		btn:unregisterEventScript()
		Lewis:spriteShaderEffect(btn:getVirtualRenderer(),"buff_gray.fsh",true)

	elseif tonumber(nextPt_Info.battle_soul) > ModelPlayer.getBattleSoul() then 
		showLevelLimit:setVisible(true)
        showLevelLimit:loadTexture("roleup_zhanhunbuzu.png")

		btn:unregisterEventScript()
		Lewis:spriteShaderEffect(btn:getVirtualRenderer(),"buff_gray.fsh",true)
	else 
		btn:registerEventScript(handle_onClick)
	end
end

local function initButtonEvent(rootView)
	UpdateImproveBtnStatus()
	rootView:getChildByName("potentdesc"):registerEventScript(handle_onClick)
	
	-- if mAmuletInfo ~= nil then
		rootView:getChildByName("usepro"):registerEventScript(handle_onClick)
	-- else
		-- Lewis:spriteShaderEffect(rootView:getChildByName("usepro"):getVirtualRenderer(),"buff_gray.fsh",true)
	-- end
	rootView:getChildByName("qn_comeback"):registerEventScript(handle_onClick)	
end 

local function initAndUpadteAmulet()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	--[[
	-- 6002 为护符ID
	mAmuletInfo = ModelBackpack.getItemByTempId(6002)
	local labelatlas = LayerRoleUpPotent.RootView:getChildByName("roleup_number")
	tolua.cast(labelatlas,"UILabelAtlas")
	if mAmuletInfo ~= nil then
		labelatlas:setStringValue(tostring(mAmuletInfo.amount))
    else
        isUsePro = 0

        labelatlas:setStringValue(tostring(0))
		
		local showIcon = LayerRoleUpPotent.RootView:getChildByName("showfuhuicon")
		showIcon:removeAllChildren()
		
        local unUseIcon = LayerRoleUpPotent.RootView:getChildByName("unuse_item")
		unUseIcon:setVisible(true)

        -- local widget = LayerRoleUpPotent.RootView:getChildByName("showfuhuicon")
		-- tolua.cast(widget,"UIImageView")
        -- widget:loadTexture("touming.png")

        local useAmuletbtn = LayerRoleUpPotent.RootView:getChildByName("usepro")
		tolua.cast(useAmuletbtn,"UIImageView")
		useAmuletbtn:loadTexture("gem_e_05.png")
        -- useAmuletbtn:unregisterEventScript()
        -- Lewis:spriteShaderEffect(useAmuletbtn:getVirtualRenderer(),"buff_gray.fsh",true)
	end
	]]--
end 

local function handle_potence_advance_result(resp)
	if resp.result == 1 then 
		setNextPotence()
		UpdateLoadBar()
		UpdateImproveBtnStatus()
		initAndUpadteAmulet()
		showRole()
		Toast.show(GameString.get("ROLEUPSSUCCESS"))
	else
		setNextPotence()
		UpdateImproveBtnStatus()
		initAndUpadteAmulet()
		Toast.show(GameString.get("ROLEUPFAIL"))
	end
end
--- 当前是否可以提升潜能
LayerRoleUpPotent.getRoleUpable = function()
	local nextPt_Info = mPotenceTb.map[tostring(ModelPlayer.getPotenceLevel()+1)]
	if nextPt_Info == nil or 
	tonumber(nextPt_Info.level_limit) > ModelPlayer.getLevel() or
	tonumber(nextPt_Info.battle_soul) > ModelPlayer.getBattleSoul()	then 
		return false
	end 
	return true
end 

LayerRoleUpPotent.initDate = function()
	isUsePro = 0
end 

LayerRoleUpPotent.initView = function(rootview)
	setNextPotence()
	playRoleActionByAdvanceLel(ModelPlayer.getAdvancedLevel())
	createCirCleLoadBar()
	initAndUpadteAmulet()
	initButtonEvent(rootview)
end 

LayerRoleUpPotent.updateAmulet = function()
	if LayerRoleUpPotent.RootView == nil then
		return
	end
	initAndUpadteAmulet()
end

LayerRoleUpPotent.init = function(rootview)
	LayerRoleUpPotent.RootView = rootview
	LayerRoleUpPotent.initDate()
	LayerRoleUpPotent.initView(rootview)
	
	ResourceManger.LoadSinglePicture("effect_082d")
	ResourceManger.LoadSinglePicture("effect_082u")
	TipModule.onUI(rootview, "ui_roleuppotent")
end 

LayerRoleUpPotent.destroy = function()
	isUsePro = 0 --不用 1 用
    mPlayerNode = nil
    lastAdvance_lv = nil 
    LayerRoleUpPotent.RootView = nil
end

NetSocket_registerHandler(NetMsgType["msg_notify_potence_advance_result"], notify_potence_advance_result, handle_potence_advance_result)
