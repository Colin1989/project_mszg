LayerTowerSettle = {}

local mLayerTowerSettleRoot = nil


local mInitType = ""	-- "nextLayer" 为下一层事件
local mGameMap = {}

LayerAbstract:extend(LayerTowerSettle)

--预先加载32图
function LayerTowerSettle.loadResource()
	--herochoose_bg_2.png
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_01.png")
end

local function DropcloseUI()
	local node = mLayerTowerSettleRoot:getWidgetByName("tower_parent")
	mLayerTowerSettleRoot:getWidgetByName("tower_bg_light"):setVisible(false)
	local distance = 1300
	local array = CCArray:create()
	array:addObject(CCEaseBackIn:create(CCMoveBy:create(0.5,CCPointMake(0,(-1)*distance))))
	array:addObject(CCCallFuncN:create(function() 
			UIManager.pop("UI_TowerSettle")
			FightMgr.onExit()
			UIManager.retrunMain()
			FightMgr.cleanup()
	end))
	
	local action = CCSequence:create(array)
	node:runAction(action)--CCRepeatForever:create(action))

end 


LayerTowerSettle.onClick  = function(weight)
	local weightName = weight:getName()
--		local weightName = weight:getName()
	if weightName == "push_sure_btn" then
		if UIManager.popBounceWindow("UI_TempPack") == true then 
			cclog("Open bag Full Event")
		else
			DropcloseUI()
		end
		
	end
	
end

local function getColor(index) 
	if index == 4 then 		--黄色
		return ccc3(255,228,0)
	elseif index == 6 then	--绿色
		return ccc3(0,240,6)
	elseif index == 3 then 	--红色
		return ccc3(227,0,0)
	elseif index == 2 then  --紫色
		return ccc3(175,20,255)
	elseif index == 1 then  --橙色
		return ccc3(243,114,0)
	elseif index == 5 then  --蓝色
		return ccc3(0,187,255)
	end
end

-- 获得统计展示
local function setScollView(scrollView,awardsTb)
	local ScrollItem = {}
	
	for k,v in pairs(awardsTb) do

		local item = CommonFunc_AddGirdWidget(v.temp_id,tonumber(v.amount))
		table.insert(ScrollItem, item)
	end
	
	setAdapterGridView(scrollView,ScrollItem,3,0)
	
	local slider = mLayerTowerSettleRoot:getWidgetByName("Slider_147")
	CommonFunc_setScrollPosition(scrollView,slider)
end 


local DROPTIME = 0.6
--主板
local function PlayDropAction(node)

	local distance = 1000
	local array = CCArray:create()
	array:addObject(CCEaseBackInOut:create(CCMoveBy:create(DROPTIME,CCPointMake(0,(-1)*distance))))
	--array:addObject(CCCallFuncN:create(function() end))
	local action = CCSequence:create(array)
	node:runAction(action)--CCRepeatForever:create(action))
end

--旗帜
local FLAGTIME = 0.3
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
	array:addObject( CCScaleTo:create(0.2,1.5))
	array:addObject( CCScaleTo:create(0.1,1.0))
	node:runAction(CCSequence:create(array))
end 
--飞剑
local FLYWEAPONTIME = 0.8
local function PlayFlyWeapon(node)
	local arrSpawn = CCArray:create()
	arrSpawn:addObject(CCRotateBy:create(1.0, 90))
	arrSpawn:addObject(CCFadeIn:create(0.8))
	arrSpawn:addObject(CCEaseBackInOut:create(CCMoveTo:create(0.8, ccp(42,403))))
	
	--fat_pig:runAction(CCSpawn:create(arrSpawn))	
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(DROPTIME) )
	array:addObject( CCShow:create() )
	array:addObject( CCSpawn:create(arrSpawn) )
	array:addObject( CCMoveBy:create(0.2,ccp(0,-40) ) )
	--array:addObject( CCMoveBy:create(0.1,ccp(0,50) )  )
	node:runAction(CCSequence:create(array))
end 
--背景光
local function PlayBgLight(node)
	local btnParticle = CCParticleSystemQuad:create("gamesettle.plist")
	btnParticle:setPosition(ccp(0,20))
	node:addRenderer(btnParticle, 2)

	local array = CCArray:create()
	array:addObject( CCDelayTime:create(DROPTIME+SHIELDTIME) )
	array:addObject( CCShow:create() )
	
	local spawnAction = CCSpawn:createWithTwoActions(
	CCRotateBy:create(1.0, 60),
	CCFadeIn:create(1.0))
	array:addObject( spawnAction )
	--array:addObject( CCFadeIn:create(1.0))
	array:addObject(CCCallFunc:create(function() 
		local rotate = CCRotateBy:create(6.0, 360)
		node:runAction(CCRepeatForever:create(rotate))
		playBeamEffect(mLayerTowerSettleRoot:getWidgetByName("tower_text"),"tower_title_02.png","role_upgrade_beam.png")
	end))
	node:runAction(CCSequence:create(array))
end 

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


LayerTowerSettle.init = function (bundle)
	mLayerTowerSettleRoot = UIManager.findLayerByTag("UI_TowerSettle")
	
	PlayDropAction(mLayerTowerSettleRoot:getWidgetByName("tower_parent"))
	PlayflagAnction(mLayerTowerSettleRoot:getWidgetByName("tower_flag"))
	PlayshieldAnction(mLayerTowerSettleRoot:getWidgetByName("tower_sheild"))
	PlayFlyWeapon(mLayerTowerSettleRoot:getWidgetByName("tower_weapon"))
	
	PlayWeaPonAnction(mLayerTowerSettleRoot:getWidgetByName("tower_right_flag2"),"right",DROPTIME+FLAGTIME+FLYWEAPONTIME)
	PlayWeaPonAnction(mLayerTowerSettleRoot:getWidgetByName("tower_right_flag1"),"right",DROPTIME+FLAGTIME+FLYWEAPONTIME+0.1)
	PlayBgLight(mLayerTowerSettleRoot:getWidgetByName("tower_bg_light"))
	local function initView() 
		local Label_gold = mLayerTowerSettleRoot:getWidgetByName("Label_107")	--金币
		tolua.cast( Label_gold,"UILabel")
		
		LayerGameUI.updateRealCoins()
		local config = FightConfig.getConfig("fc_push_tower_sever_data")
		local cache = FightConfig.getConfig("fc_push_tower_cache_data")
		cache.gold = cache.gold + bundle.gold
		Label_gold:setText(string.format("%d", cache.gold ))
		
		--当前层数
		local completeLayerStr = mLayerTowerSettleRoot:getWidgetByName("pushtowerlabel1")
		tolua.cast( completeLayerStr,"UILabel")
		completeLayerStr:setText(string.format("%d层", cache.hasPassFloorCnt))
		--最高层数
		local completeLayerStr = mLayerTowerSettleRoot:getWidgetByName("pushtowerlabel2")
		tolua.cast( completeLayerStr,"UILabel")
		
		if cache.hasPassFloorCnt > config.max_floor then
			completeLayerStr:setText(string.format("%d层", cache.hasPassFloorCnt))
		else
			completeLayerStr:setText(string.format("%d层", config.max_floor))
		end 
		
	end

	
	setOnClickListenner("push_sure_btn")	
	--[[
	local ScrollItem = {}
	
	local scrollView = mLayerTowerSettleRoot:getWidgetByName("ScrollView_pannel")
	tolua.cast(scrollView,"UIScrollView")
	]]--

	initView()
	--setScollView(scrollView,awardsTb)
	
end
