
-------------------------------------
--作者：李慧琴
--说明：战斗结算界面
--时间：2014-1-23
-------------------------------------

LayerFightOver = {
}

local  	starsNumber = 0
local 	mLayerFightOverRoot = nil      --当前界面的根节点
local  	passInfo = nil                --保存传递的信息
local  mGoldTimer = nil
local  curGold = 0
local  addGold = 0
local  goldStep = 0
local  mExpTimer = nil
local  curExp = 0
local  addExp = 0
local  expStep = 0

LayerAbstract:extend(LayerFightOver)

function LayerFightOver.destroy()
	local root = UIManager.findLayerByTag("UI_FightOver")
	if root ~= nil then
		root:removeFromParentAndCleanup(true)
		root = nil
	end
	mLayerFightOverRoot = nil
end

--预先加载32图
function LayerFightOver.loadResource()
	--herochoose_bg_2.png
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_02.png")
end

local function expTimerOverCF(tm)
	mExpTimer = nil
	if nil ~= mLayerFightOverRoot then
		local expLabel = mLayerFightOverRoot:getWidgetByName("Label_37")
		tolua.cast(expLabel,"UILabel")
		expLabel:setText(addExp)
	end
end
local function expTimerRunCF(tm)
	if curExp + expStep <= addExp then
		curExp = curExp + expStep
	else
		curExp = addExp
	end
	if nil ~= mLayerFightOverRoot then
		local expLabel = mLayerFightOverRoot:getWidgetByName("Label_37")
		tolua.cast(expLabel,"UILabel")
		expLabel:setText(curExp)
	end
end

local function goldTimerOverCF(tm)
	mGoldTimer = nil
	if nil ~= mLayerFightOverRoot then
		local coinLabel = mLayerFightOverRoot:getWidgetByName("Label_35")
		tolua.cast(coinLabel,"UILabel")
		coinLabel:setText(addGold)
	end
end
local function goldTimerRunCF(tm)
	if curGold + goldStep <= addGold then
		curGold = curGold + goldStep
	else
		curGold = addGold
	end
	if nil ~= mLayerFightOverRoot then
		local coinLabel = mLayerFightOverRoot:getWidgetByName("Label_35")
		tolua.cast(coinLabel,"UILabel")
		coinLabel:setText(curGold)
	end
end

local function DropcloseUI()
	local node = mLayerFightOverRoot:getWidgetByName("fightover_parent")
	--mLayerFightOverRoot:getWidgetByName("fight_light"):setVisible(false)
	local distance = 1300
	local array = CCArray:create()
	array:addObject(CCEaseBackIn:create(CCMoveBy:create(0.5,CCPointMake(0,(-1)*distance))))
	array:addObject(CCCallFuncN:create(function() 
		UIManager.pop("UI_FightOver")
		if 6 == FightDateCache.getData("fd_game_mode") then
			starsNumber = 0
		end
        if starsNumber ~= 3 then
			LayerLvUp.setEnterLvMode(1)
			if UIManager.popBounceWindow("UI_TempPack") ~= true then
				if UIManager.popBounceWindow("UI_LvUp") ~= true then 
					FightMgr.onExit()
					UIManager.retrunMain()
					FightMgr.cleanup()
					CopyDelockLogic.enterCopyDelockLayer()
				end		
			end
        elseif starsNumber == 3 then 
            UIManager.push("UI_FightReward",passInfo)  -- 进入奖励界面
        end
	end))
	
	local action = CCSequence:create(array)
	node:runAction(action)--CCRepeatForever:create(action))

end 

LayerFightOver.onClick = function(widget)
    local widgetName = widget:getName()
    if "Button_38" == widgetName then  					-- 确认键
		DropcloseUI()
    end
end

--[[
--点击图片查看详细信息
local function iconClick(clickType,sender)
	if clickType ~= "releaseUp" then
		return
	end	
	CommonFunc_showInfo(0, sender:getTag(), 0, nil, 1)
end
]]--



local function showItem(itemBg, value)
	addQuaIconByRewardId(value.id,itemBg,value.amount,nil)
	
	--长按功能
	itemBg:setTouchEnabled(true)
	local function clickSkillIcon(itemBg)
		showLongInfoByRewardId(value.id,itemBg)
	end
	
	local function clickSkillIconEnd(itemBg)
		longClickCallback_reward(value.id,itemBg)
	end
	
	UIManager.registerEvent(itemBg, nil, clickSkillIcon, clickSkillIconEnd)
	
end

LayerFightOver.openBox = function(delay, itemBg, value,effectNode,boxSprite)
	ResourceManger.LoadSinglePicture("monster_death2")
	local function delayDone(sender)
		local bgEffect = createAnimation_signal("monster_death2_%02d.png", 8, 0.1)
		bgEffect:setAnchorPoint(ccp(0.5,0.5))
		bgEffect:setPosition(ccp(47,47))
		effectNode:addChild(bgEffect)
	end
	
	local function openBoxDone(sender)
		showItem(itemBg, value)
	end
	
	local function deleteThis(sender)
		sender:getParent():removeChild(sender,true)
	end
	
	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(delay))			--延迟时间
	arr:addObject(CCCallFuncN:create(delayDone))		--放金光
	arr:addObject(CCFadeTo:create(0.3, 128))			--金光淡退
	arr:addObject(CCCallFuncN:create(openBoxDone))		--展现物品
    arr:addObject(CCCallFuncN:create(deleteThis))		--删除多余的东西
	boxSprite:runAction( CCSequence:create(arr))
end


LayerFightOver.setOpenBoxAction = function(scrollItem,k,id)
	--装备图标
	local panel = CommonFunc_createUILayout(ccp(0,0),ccp(0,0), CCSizeMake(94,98), nil,1)
	local icon = CommonFunc_createUIImageView(ccp(0,0), ccp(0,0), CCSizeMake(94,94), "touming.png", string.format("headbackground_%d",k), 1)	
	panel:addChild(icon)
	table.insert(scrollItem,panel) 
	icon:setTouchEnabled(true)
	icon:setTag(id)
	
	local effectNode = CCLayer:create()
	icon:addRenderer(effectNode, 0)
	

	--local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
	--local spFrame = frameCache:spriteFrameByName("touming.png")
	--local boxSprite = CCSprite:createWithSpriteFrame(spFrame)		--闭着的箱子
	local boxSprite = CCSprite:create("touming.png")		--闭着的箱子
	boxSprite:setAnchorPoint(ccp(0.5,0.5))
	effectNode:addChild(boxSprite, 1)
	return icon,effectNode,boxSprite
end


local function setItemIcon(pickItemTable)

	local scrollView = mLayerFightOverRoot:getWidgetByName("ScrollView_160")  	--显示战斗的副本名字
    tolua.cast(scrollView,"UIScrollView")
	local delay = 0.7
	local scrollItem ={}
	for k,v in pairs(pickItemTable) do
		local icon,effectNode,boxSprite = LayerFightOver.setOpenBoxAction (scrollItem,k,v.id)
		LayerFightOver.openBox(delay, icon, v,effectNode, boxSprite)	
		delay = delay + 0.25
	end
	setAdapterGridView(scrollView,scrollItem,3,0)
end


--先把所有id相同的，叠加起来
local function joinTheSameId(pickItemTable)
	local tempPickItemTable = {}
	local function insertPickItemTable(pickItem)
		for key, val in pairs(tempPickItemTable) do
			if pickItem.id == val.id then
				tempPickItemTable[key].amount = val.amount + pickItem.amount
				return
			end
		end
		local tempPickItem = {}
		tempPickItem.id = pickItem.id
		tempPickItem.amount = pickItem.amount
		table.insert(tempPickItemTable, tempPickItem)
	end
	for key, val in pairs(pickItemTable) do
		insertPickItemTable(val)
	end
	return tempPickItemTable
end

--根据奖励类型，判断可否叠加，把allNumTb分开来
LayerFightOver.splitUnOverlayItem = function (pickTb)
	local finalNumTb = {}
	local allNumTb = joinTheSameId(pickTb)
	for key,value in pairs(allNumTb) do
		
		local tempTb = {}
		local rewardTb = LogicTable.getRewardItemRow (value.id)
		if rewardTb.type == 7 then		--物品
			--获得物品可否叠加
			local itemRow = LogicTable.getItemById(rewardTb.temp_id)
			if value.amount <= tonumber(itemRow.overlay_count) then	 --个数小于等于可堆叠个数
				table.insert(finalNumTb,value)
			else
				local amount = value.amount
				local cicNum = math.ceil(value.amount/tonumber(itemRow.overlay_count))
				--个数大于可堆叠个数，就让他们分开显示
				for i=1 ,cicNum,1 do
					local secTempTb ={}
					secTempTb.id = value.id
					if amount > tonumber(itemRow.overlay_count) then
						amount = amount - tonumber(itemRow.overlay_count)
						secTempTb.amount = tonumber(itemRow.overlay_count)
						table.insert(finalNumTb,secTempTb)
					else
						secTempTb.amount = amount
						table.insert(finalNumTb,secTempTb)
					end
				end
			end	
		elseif rewardTb.type == 8 then	--符文
			tempTb.id = value.id
			tempTb.amount = 1
			for i=1 ,value.amount,1 do
				table.insert(finalNumTb,tempTb)
			end
		else --1-金币 2-经验 3-魔石 4-体力 5-战绩（原来叫积分） 6-荣誉 9-召唤石 10-体力可溢出 11-分组积分 12-战魂值
			table.insert(finalNumTb,value)
		end
	end
	return finalNumTb
end


local DROPTIME = 0.6
--主板
local function PlayDropAction(node)

	local distance = 800
	local pos = node:getPosition()
	local newPos = ccp(pos.x,pos.y + distance)	
	local array = CCArray:create()
	array:addObject( CCPlace:create(newPos) )
	array:addObject( CCShow:create() )
	array:addObject(CCEaseBackInOut:create(CCMoveBy:create(DROPTIME,CCPointMake(0,(-1)*distance))))
	--array:addObject(CCCallFuncN:create(function() end))
	
	local action = CCSequence:create(array)
	node:runAction(action)--CCRepeatForever:create(action))
    node:setVisible(false)
end

local FLAGTIME = 0.3
--旗帜
local function PlayflagAnction(node)
	node:setScaleX(0.1);
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(DROPTIME) )
	array:addObject( CCShow:create() )
	--array:addObject(CCCallFuncN:create(function() end))
	array:addObject( CCScaleTo:create(0.2,1.2,1.0))
	array:addObject( CCScaleTo:create(0.1,1.0))
	node:runAction(CCSequence:create(array))
end 
--盾牌
local SHIELDTIME = 0.3
local function PlayshieldAnction(node)
	node:setScaleY(0.1);
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(DROPTIME+FLAGTIME) )
	array:addObject( CCShow:create() )
	--array:addObject(CCCallFuncN:create(function() end))
	array:addObject( CCScaleTo:create(0.2,1.0,1.5))
	array:addObject( CCScaleTo:create(0.1,1.0))
	node:runAction(CCSequence:create(array))
end 
--剑
local WEAPONTIME = 0.2
local function PlayWeaPonAnction(node,dirction,delayTime)
	local delatX = 20
	if dirction == "left" then 
		delatX = -delatX
	else 
		delatX = delatX
	end 
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(delayTime) )
	array:addObject( CCShow:create() )

	local spawnAction = CCSpawn:createWithTwoActions(
	CCScaleTo:create(0.1,1.2),
	CCMoveBy:create(0.1,ccp(delatX,20)))
	array:addObject( spawnAction )
	
	local spawnAction2 = CCSpawn:createWithTwoActions(
	CCScaleTo:create(0.1,1.0),
	CCMoveBy:create(0.1,ccp(-delatX,-20)))
	array:addObject( spawnAction2 )

	node:runAction(CCSequence:create(array))
end 

local function PlayBgLight(node)
	local array = CCArray:create()
	local btnParticle = CCParticleSystemQuad:create("gamesettle.plist")
	btnParticle:setPosition(ccp(0,20))
	node:addRenderer(btnParticle, 2)
	array:addObject( CCDelayTime:create(DROPTIME+FLAGTIME) )
	array:addObject( CCShow:create() )
	local spawnAction = CCSpawn:createWithTwoActions(
	CCRotateBy:create(1.0, 60),
	CCFadeIn:create(1.0))
	array:addObject( spawnAction )
	array:addObject(CCCallFunc:create(function() 
		local rotate = CCRotateBy:create(6.0, 360)
		node:runAction(CCRepeatForever:create(rotate))
	end))
	node:runAction(CCSequence:create(array))
end 

local function PlayStarBlink(totalStart)
	for k=1,totalStart do 
		local node = mLayerFightOverRoot:getWidgetByName("fight_over_star"..k)
		local action = CCBlink:create(math.random(1,10)*1000, 9999);
		node:runAction(action)
	end 
end 
function  playScoreStars(starsNumber)      --设置显示几颗星
	for k=1,starsNumber do 
		local x= -200 
		local y= 250

		local node = mLayerFightOverRoot:getWidgetByName("fightoverstar"..k)
		local pos = node:getPosition()
		local newPos = ccp(pos.x + x ,pos.y + y)	
		node:setScale(0.1)
		local array = CCArray:create()
		array:addObject( CCDelayTime:create(0.3+0.3*k) )
		array:addObject( CCPlace:create(newPos) )
		array:addObject( CCShow:create() )
		
		local spawnAction = CCSpawn:createWithTwoActions(
		CCScaleTo:create(0.5,1.5),
		CCRotateBy:create(0.5, 180))
		array:addObject( spawnAction )
		
		local spawnAction3 = CCSpawn:createWithTwoActions(
		CCScaleTo:create(0.2,1.0),
		CCRotateBy:create(0.2, 180))
		array:addObject( spawnAction3 )
		
		local spawnAction2 = CCSpawn:createWithTwoActions(
		CCRotateBy:create(0.3, 90),
		CCMoveBy:create(0.3,ccp(-x,-y)))
		array:addObject(CCCallFunc:create(function() 
			 Lewis:spriteShaderEffect(node:getVirtualRenderer(),"star_tips.fsh", true)
			 if k == starsNumber then 
				playBeamEffect(mLayerFightOverRoot:getWidgetByName("fight_victory_text"),"fight_win.png","role_upgrade_beam.png")
				local goldCD = math.ceil(addGold / goldStep)
				mGoldTimer = CreateTimer(0.01, goldCD, goldTimerRunCF, goldTimerOverCF)
				mGoldTimer.start()
				local expCD = math.ceil(addExp / expStep)
				mExpTimer = CreateTimer(0.01, expCD, expTimerRunCF, expTimerOverCF)
				mExpTimer.start()
			end
		end))

		array:addObject( spawnAction2 )
		
		node:runAction(CCSequence:create(array))

	end
end

LayerFightOver.init = function(bundle)
	local mode = FightDateCache.getData("fd_game_mode")
	mLayerFightOverRoot = UIManager.findLayerByTag("UI_FightOver")
	PlayDropAction(mLayerFightOverRoot:getWidgetByName("fightover_parent"))
	PlayflagAnction(mLayerFightOverRoot:getWidgetByName("fightover_flag"))
	PlayshieldAnction(mLayerFightOverRoot:getWidgetByName("fightover_shield"))
	PlayWeaPonAnction(mLayerFightOverRoot:getWidgetByName("fightover_leftweapon"),"left",DROPTIME+FLAGTIME+SHIELDTIME-0.1)
	PlayWeaPonAnction(mLayerFightOverRoot:getWidgetByName("fightover_rightweapon"),"right",DROPTIME+FLAGTIME+SHIELDTIME-0.1)
	
	PlayWeaPonAnction(mLayerFightOverRoot:getWidgetByName("fightover_left1"),"left",DROPTIME+FLAGTIME+SHIELDTIME+0.1)
	PlayWeaPonAnction(mLayerFightOverRoot:getWidgetByName("fightover_right1"),"right",DROPTIME+FLAGTIME+SHIELDTIME+0.2)
	PlayWeaPonAnction(mLayerFightOverRoot:getWidgetByName("fight_left2"),"left",DROPTIME+FLAGTIME+SHIELDTIME+0.3)
	PlayWeaPonAnction(mLayerFightOverRoot:getWidgetByName("fightover_right2"),"right",DROPTIME+FLAGTIME+SHIELDTIME+0.4)
	--PlayBgLight(mLayerFightOverRoot:getWidgetByName("fight_light"))
	
	setOnClickListenner("Button_38")
	--PlayStarBlink(7)
	passInfo = bundle
	local threeStarBg = tolua.cast(mLayerFightOverRoot:getWidgetByName("ImageView_82"), "UIImageView")
	local winTip = tolua.cast(mLayerFightOverRoot:getWidgetByName("ImageView_256"), "UIImageView")
	if mode == 6 then
		threeStarBg:setVisible(false)
		winTip:setVisible(true)
	else
		winTip:setVisible(false)
		threeStarBg:setVisible(true)
		starsNumber = bundle.score
		CopyDateCache.upDate_CopyInfo(LayerCopyTips.getId(), starsNumber)
		playScoreStars(starsNumber)
	end
	--掉落物品
	local finalNumTb = LayerFightOver.splitUnOverlayItem(bundle.Pickup_items)
	setItemIcon(finalNumTb)
	--显示战斗的副本名字
    local copyNameLabel = mLayerFightOverRoot:getWidgetByName("Label_28")
    tolua.cast(copyNameLabel,"UILabel")
    copyNameLabel:setText(bundle.name)
	--获得的金币
	local coins = FightDateCache.getData("fd_coin_count") + bundle.gold
    local coinLabel = mLayerFightOverRoot:getWidgetByName("Label_35")
    tolua.cast(coinLabel,"UILabel")
	coinLabel:setText(string.format("%s",0))
	addGold = FightDateCache.getData("fd_coin_count") + bundle.gold
	goldStep = math.ceil(coins / 180) + 1
	--获得的经验
    local expLabel = mLayerFightOverRoot:getWidgetByName("Label_37")
    tolua.cast(expLabel,"UILabel")
	expLabel:setText(string.format("%s",0))
	addExp = tonumber(bundle.exp)
	expStep = math.ceil(tonumber(addExp) / 180) + 1
	if mode == 6 then
		local goldCD = math.ceil(addGold / goldStep)
		mGoldTimer = CreateTimer(0.01, goldCD, goldTimerRunCF, goldTimerOverCF)
		mGoldTimer.start()
		local expCD = math.ceil(addExp / expStep)
		mExpTimer = CreateTimer(0.01, expCD, expTimerRunCF, expTimerOverCF)
		mExpTimer.start()
	end
	Audio.playEffectByTag(5)
	if mode ~= 6 then
		--通关事件
		local copyId = FightDateCache.getData("fd_copy_id")
		EventCenter_post(EventDef["ED_PASS_LOCATION"], {locationId=copyId, stars=bundle.score})
	end
end

LayerFightOver.destroy = function()
	local root = UIManager.findLayerByTag("UI_FightOver")
	if root then
		root:removeFromParentAndCleanup(true)
	end
	mLayerFightOverRoot = nil
	mGoldTimer = nil
	mExpTimer = nil
	curGold = 0
	addGold = 0
	goldStep = 0
	curExp = 0
	addExp = 0
	expStep = 0
end

function addQuaIconByRewardId(id,widget,amount,func)
	local rewardTb = LogicTable.getRewardItemRow(id)
	if rewardTb.type == 7 then			--物品
		CommonFunc_AddGirdWidget(rewardTb.temp_id, amount,nil,func,widget)
		widget:setAnchorPoint(ccp(0,0))
		--品质框
		local qual = widget:getChildByName("UIImageView_quality")
		tolua.cast(qual,"UIImageView")
		qual:setAnchorPoint(ccp(0,0))
		qual:setPosition(ccp(-6,-6))
		--左上角数值
		local num = widget:getChildByName("UILabelAtlas_num")
		if num ~= nil then
			tolua.cast(num,"UILabelAtlas")
			num:setAnchorPoint(ccp(0.5,0.5))
			num:setPosition(ccp(7,80))
			
		end

		--右下角数值
		local countLabel = widget:getChildByName("UILabelAtlas_count")
		if countLabel ~= nil then
			tolua.cast(countLabel,"UILabelAtlas")
			countLabel:setAnchorPoint(ccp(1.0,0.5))
			countLabel:setPosition(ccp(85,18))
		end
	elseif rewardTb.type == 8 then		--符文
		CommonFunc_AddGirdWidget_Rune(rewardTb.temp_id, 0, func, widget)
		--品质框
		local qual = widget:getChildByName("UIImageView_quality")
		tolua.cast(qual,"UIImageView")
		qual:setAnchorPoint(ccp(0,0))
		qual:setPosition(ccp(-6,-6))
		--左上角数值
		local num = widget:getChildByName("UILabelAtlas_num")
		if num ~= nil then
			tolua.cast(num,"UILabelAtlas")
			num:setAnchorPoint(ccp(0.5,0.5))
			num:setPosition(ccp(7,80))
		end
	else							
		LayerFightReward_AddGirdWidget(rewardTb.icon,amount,func,widget)
		
		local qual = widget:getChildByName("UIImageView_quality")
		tolua.cast(qual,"UIImageView")
		qual:setAnchorPoint(ccp(0,0))
		qual:setPosition(ccp(-2,-4))
		local countLabel = widget:getChildByName("LabelAtlas_ItemCount")
		tolua.cast(countLabel,"UILabelAtlas")
		if countLabel ~= nil then
			countLabel:setAnchorPoint(ccp(1.0,0.5))
			countLabel:setPosition(ccp(81,14))
		end	
		local qual = widget:getChildByName("UIImageView_quality")
		tolua.cast(qual,"UIImageView")
		if qual ~= nil then
			qual:setAnchorPoint(ccp(0.03,0.01)) 
		end
	end

end

function playBeamEffect(parent,stencliFile,valueFile,times)
	local titleImg = parent

	local clipper = CCClippingNode:create()
	clipper:setPosition( ccp(0,0) )
	clipper:setAlphaThreshold(0.05)
	

	local stencil = CCSprite:create(stencliFile)--"fight_win.png")"role_upgrade_beam.png")
	stencil:setAnchorPoint( ccp(0.5, 0.5) )
	stencil:setPosition( ccp(clipper:getContentSize().width / 2, clipper:getContentSize().height / 2) )

	clipper:setStencil(stencil)
	titleImg:addRenderer(clipper,10)

	local spr = CCSprite:create(valueFile)--"role_upgrade_beam.png")
	spr:setAnchorPoint( ccp(0.5, 0.5) )
	spr:setOpacity(200)
	spr:setPosition( ccp(clipper:getContentSize().width / 2 - titleImg:getSize().width/2, clipper:getContentSize().height / 2) )
	clipper:addChild(spr)
	
	local array = CCArray:create()
	array:addObject( CCShow:create() )
	array:addObject( CCMoveBy:create(0.6,ccp(titleImg:getSize().width+spr:getContentSize().width,0)) )
	array:addObject( CCPlace:create(ccp(clipper:getContentSize().width / 2 - titleImg:getSize().width/2- titleImg:getSize().width/2, clipper:getContentSize().height / 2)) )
	array:addObject( CCHide:create() )
	array:addObject( CCDelayTime:create(0.5) )
	local action = CCSequence:create(array)
	if times ~= nil and type(times) == "number" and times > 0 then
		spr:runAction(CCRepeat:create(action, times))
	else
		spr:runAction(CCRepeatForever:create(action))
	end
end
















