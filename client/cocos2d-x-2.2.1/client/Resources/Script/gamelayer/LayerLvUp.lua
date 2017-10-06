----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2014-3-19
-- 描述：玩家升级界面
----------------------------------------------------------------------

local mLayerLvUpRoot = nil			---当前界面root节点
local mEnterMode = 2 				--一表示是从副本进入的升级界面,2表示不是

---test function
local mLastScrollView = nil
local mCurScrollView = nil
local mArrowScrollView = nil
-- 上一级界面传入的参数
local mParam = nil

--每个延迟间隔0.15s
local INTERV = 0.15

--参数 Finish_Callback 滑出以后的回调（无给参数）
function removeScroll_FlyOut(scrollView,newTable)
	-- 添加每个ITEM的动画
	local function  runEscapeAction(widget,index,totalLength)
		local S_width = scrollView:getContentSize().width
	
		local delayTime = CCDelayTime:create((index-1)*INTERV)
		local easeMove = CCEaseExponentialIn:create(CCMoveBy:create((totalLength - (index - 1))*INTERV,CCPointMake(S_width,0)))
		--cclog("DelayTime:",(index-1)*0.1,"easeMoveTiem",(totalLength - (index - 1))*0.1)
		local array = CCArray:create()
		array:addObject(delayTime)
		array:addObject(easeMove)
		if index == totalLength then 
			local function removeAllItem()		--完全飞出的回调
				
				scrollView:removeAllChildren()
				cclog("all flyout ----------Ready-------in",newTable,#newTable)
				ScrollView_FlyIN (scrollView , newTable )
			end
			array:addObject(CCCallFunc:create(removeAllItem))
		end 
		widget:runAction(CCSequence:create(array))	
	end
	
	local m_childArray = scrollView:getChildren()
	local ArrayLength = m_childArray:capacity()
	for i = 1 ,ArrayLength - 1 do
		local pChild = tolua.cast(m_childArray:objectAtIndex(i - 1),"UIWidget")
		runEscapeAction (pChild,i,ArrayLength - 1)
	end
end

function ScrollView_FlyIN(lastScrollView, curScrollView, arrowScrollView, tbCell, interal)
	lastScrollView:removeAllChildren()
	curScrollView:removeAllChildren()
	arrowScrollView:removeAllChildren()
	local m_childArray = lastScrollView:getChildren()
	local ArrayLength = m_childArray:capacity()
	--cclog("%%%%%%%%%????????飞进来时scroll的长度%%%%%",ArrayLength)
	--if ArrayLength > 1 then 
		--removeScroll_FlyOut(scrollView,tbCell)
		--return
	--end
	
	local nSumHeight = 0   -- 列表总高度
	local nTableCount = table.maxn(tbCell)  -- 列表的总的Item数
	local nCurrentHeight = 0
	-- for nIndex = 1 ,nTableCount, 1 do
		-- nSumHeight = nSumHeight + tbCell[nIndex]:getSize().height
	-- end
	for key, val in pairs(tbCell) do
		nSumHeight = nSumHeight + val.lastItem:getSize().height
	end
	local lastContair = lastScrollView:getInnerContainer()
	local curContair = curScrollView:getInnerContainer()
	local arrowContair = arrowScrollView:getInnerContainer()
	--scrollView:setBounceEnabled(true)-- 回弹
	--scrollView:setInertiaScrollEnabled(true)
	if(nSumHeight > lastScrollView:getContentSize().height) then
		lastContair:setSize(CCSize(lastContair:getSize().width, nSumHeight))
	else
		nSumHeight = lastScrollView:getContentSize().height
	end
	local nLastPosX = lastContair:getSize().width/2
	local nCurPosX = curContair:getSize().width/2
	local nArrowPosX = arrowContair:getSize().width/2
	-- for nTable = 1 ,nTableCount, 1 do
		-- local nPosY = nSumHeight - nCurrentHeight - tbCell[nTable]:getSize().height/2
		-- cclog("===========nPosY "..nPosY)
		-- tbCell[nTable]:setPosition(ccp(nLastPosX * 3, nPosY))
		-- tbCell[nTable]:setAnchorPoint(ccp(0.5,0.5))
		-- nCurrentHeight = nCurrentHeight + tbCell[nTable]:getSize().height + interal
		-- scrollView:addChild(tbCell[nTable])
		
		-- local moveAction = CCMoveTo:create(0.2 + nTable*0.5,ccp( nLastPosX , nPosY))
		-- tbCell[nTable]:runAction(CCEaseExponentialOut:create(moveAction))
	-- end
	
	
	local delay = 0.3
	for key, val in pairs(tbCell) do
		local function clearCallBack_1(sender)
			playBeamEffect(val.arrowItem,"jiantou.png","role_upgrade_beam.png",1)
		end
		local function clearCallBack_2(sender)
			local curLabel = val.curItem:getChildByName("cur")
			local arr1 = CCArray:create()
			arr1:addObject(CCScaleTo:create(0.05, 0.75))
			arr1:addObject(CCDelayTime:create(0.2))
			arr1:addObject(CCScaleTo:create(0.05, 0.7))
			curLabel:runAction(CCSequence:create(arr1))
			
			local lightLabel = val.curItem:getChildByName("light")
			local arr2 = CCArray:create()
			arr2:addObject(CCFadeIn:create(0.05))
			arr2:addObject(CCDelayTime:create(0.2))
			arr2:addObject(CCFadeOut:create(0.05))
			lightLabel:runAction(CCSequence:create(arr2))
		end
		local nPosY = nSumHeight - nCurrentHeight - val.lastItem:getSize().height/2 - 10
		cclog("==============nLastPosX"..nLastPosX.."===========nPosY "..nPosY)
		-- val.lastItem:setPosition(ccp(nLastPosX * 3, nPosY))
		val.lastItem:setPosition(ccp(0, nPosY))
		nCurrentHeight = nCurrentHeight + val.lastItem:getSize().height + interal
		lastScrollView:addChild(val.lastItem)
		
		val.arrowItem:setPosition(ccp(-nArrowPosX, nPosY))
		cclog("--------------------------------->",nArrowPosX,"--->",nPosY)
		arrowScrollView:addChild(val.arrowItem)
		local arr1 = CCArray:create()
		arr1:addObject(CCDelayTime:create(delay))
		
		local spawnAction = CCSpawn:createWithTwoActions(
		CCMoveTo:create(0.15, ccp(nArrowPosX, nPosY)),
		CCFadeIn:create(0.15))
		arr1:addObject(spawnAction)
		cclog("---------------------------------------->key:"..key)
		arr1:addObject(CCCallFuncN:create(clearCallBack_1))
		-- local moveAction = CCMoveTo:create(0.3 + nTable*0.5,ccp(nArrowPosX, nPosY))
		val.arrowItem:runAction(CCSequence:create(arr1))
		
		val.curItem:setPosition(ccp(0, nPosY))
		curScrollView:addChild(val.curItem)
		local curLabel = val.curItem:getChildByName("cur")
		local arr2 = CCArray:create()
		arr2:addObject(CCDelayTime:create(delay + 0.2))
		arr2:addObject(CCScaleTo:create(0.15, 1.4))
		arr2:addObject(CCScaleTo:create(0.15, 0.7))
		arr2:addObject(CCCallFuncN:create(clearCallBack_2))
		curLabel:runAction(CCSequence:create(arr2))
		
		delay = delay + 0.5
	end
end

LayerLvUp = {
}
LayerAbstract:extend(LayerLvUp)

--预先加载32图
function LayerLvUp.loadResource()
	--herochoose_bg_2.png
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_02.png")
end

local function DropcloseUI()
	local node = mLayerLvUpRoot:getWidgetByName("uiroot_action")
	mLayerLvUpRoot:getWidgetByName("lvup_bglight"):setVisible(false)
	local distance = 1300
	local array = CCArray:create()
	array:addObject(CCEaseBackIn:create(CCMoveBy:create(0.5,CCPointMake(0,(-1)*distance))))
	array:addObject(CCCallFuncN:create(function() 
		UIManager.pop("UI_LvUp")	
		if UIManager.isAllUIEnabled() == false then --如果在战斗界面
			FightMgr.onExit()
			FightMgr.cleanup()
			UIManager.retrunMain()
		end
		--LayerMain.pullPannel()			--回主城
		CopyDelockLogic.enterCopyDelockLayer()
		
		--------------------------------------------------------------------------------------------------
		-- LayerLvUp.setEnterLvMode(2)
		-- UIManager.push("UI_LvUp")
	end))

	local action = CCSequence:create(array)
	node:runAction(action)--CCRepeatForever:create(action))

end 

LayerLvUp_onClick = function(EventType,weight)
	if EventType ~= "releaseUp" then 
		return
	end 
 	local weightName = weight:getName()
    if weightName == "LvUp" then
		DropcloseUI()	
	end
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
--皇冠
local HEADTIME = 0.3
local function PlayHeadAnction(node)
	node:setScaleY(0.1);
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(DROPTIME+FLAGTIME) )
	array:addObject( CCShow:create() )
	--array:addObject(CCCallFuncN:create(function() end))
	array:addObject( CCScaleTo:create(0.2,1.0,1.5))
	array:addObject( CCScaleTo:create(0.1,1.0))
	node:runAction(CCSequence:create(array))
end 
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
	CCScaleTo:create(0.1,1.1),
	CCMoveBy:create(0.1,ccp(delatX,20)))
	array:addObject( spawnAction )
	
	local spawnAction2 = CCSpawn:createWithTwoActions(
	CCScaleTo:create(0.1,1.0),
	CCMoveBy:create(0.1,ccp(-delatX,-20)))
	array:addObject( spawnAction2 )

	node:runAction(CCSequence:create(array))
end 

--背景光
local function PlayBgLight(node)
	local btnParticle = CCParticleSystemQuad:create("gamesettle.plist")
	btnParticle:setPosition(ccp(0,20))
	node:addRenderer(btnParticle, 2)
	
	local array = CCArray:create()
	array:addObject( CCDelayTime:create(DROPTIME+0.3) )
	array:addObject( CCShow:create() )
	
	local spawnAction = CCSpawn:createWithTwoActions(
	CCRotateBy:create(1.0, 60),
	CCFadeIn:create(1.0))
	array:addObject( spawnAction )
	--array:addObject( CCFadeIn:create(1.0))
	array:addObject(CCCallFunc:create(function() 
		local rotate = CCRotateBy:create(6.0, 360)
		node:runAction(CCRepeatForever:create(rotate))
		
		playBeamEffect(mLayerLvUpRoot:getWidgetByName("ImageView_164"),"shengjila.png","role_upgrade_beam.png")
	
	end))
	node:runAction(CCSequence:create(array))
end 

LayerLvUp.setEnterLvMode = function(mode)	
	mEnterMode = mode
end 

LayerLvUp.getEnterLvMode = function()
	return mEnterMode
end 

LayerLvUp.init = function(param)
	-- param = {lastNum = 9, curNum = 10,}
	mLayerLvUpRoot = UIManager.findLayerByTag("UI_LvUp")
	
	PlayDropAction(mLayerLvUpRoot:getWidgetByName("uiroot_action"))
	PlayflagAnction(mLayerLvUpRoot:getWidgetByName("lv_up_flag"))
	PlayHeadAnction(mLayerLvUpRoot:getWidgetByName("lvup_head"))
	PlayWeaPonAnction(mLayerLvUpRoot:getWidgetByName("lvup_leftweapon"),"left",DROPTIME+FLAGTIME-0.1)
	PlayWeaPonAnction(mLayerLvUpRoot:getWidgetByName("lvup_rightweapon"),"right",DROPTIME+FLAGTIME-0.1)
	PlayBgLight(mLayerLvUpRoot:getWidgetByName("lvup_bglight"))
	
	mParam = param
	
	for key,value in pairs(param) do
		cclog("升级界面，传过来的值是*************************",key,value)
	end
	
	Audio.playEffectByTag(88)
	local function isShow(lastNum,curNum) -- 判断是否数值有变动
		lastNum = tonumber(lastNum)	
		curNum = tonumber(curNum)
		
		if curNum - lastNum > 0 then 
			return true,lastNum,curNum
		else
			return nil
		end 
	end	
	
	-- local function createItem(lastNum,curNum)
		-- local widget =  LoadWidgetFromJsonFile("LvUpItem_1.ExportJson")
		-- local lable1 = widget:getChildByName("lvuplable1")		
		-- tolua.cast(lable1,"UILabel")
		-- lable1:setText(lastNum)
	
		-- local lable2 = widget:getChildByName("lvuplable2")		
		-- tolua.cast(lable2,"UILabel")
		-- lable2:setText( string.format("-> %d",curNum))
		
		-- widget:setScale(2.4)
		-- return widget
	-- end
	
	local function createItem(constName, lastNum, curNum)
		local node1 = UILayout:create()
		node1:setSize(CCSizeMake(200, 30))
		node1:setTag(tonumber(lastNum))
		local lastPosX = node1:getSize().width/2
		local lastPosY = node1:getSize().height/2
		
		local lastLabel = UILabel:create()
		lastLabel:setText(GameString.get(constName))
		lastLabel:setFontSize(25)
		lastLabel:setAnchorPoint(ccp(0, 0.5))
		lastLabel:setColor(ccc3(255,255,255))
		-- lastLabel:setTag(tonumber(lastNum))
		node1:addChild(lastLabel)
		
		local lastNumPosX = lastLabel:getSize().width
		
		local lastNumLabel = CommonFunc_getAtlas("01234567890", "num_black.png", 24, 32, 0)
		lastNumLabel:setScale(0.7)
		lastNumLabel:setStringValue(tostring(lastNum))
		-- lastNumLabel:setSize(CCSizeMake(200, 30))
		lastNumLabel:setAnchorPoint(ccp(0, 0.5))
		lastNumLabel:setPosition(ccp(lastNumPosX, 0))
		node1:addChild(lastNumLabel)
		
		local node2 = UILayout:create()
		-- node2:setSize(CCSizeMake(130, 30))
		-- node2:setAnchorPoint(ccp(0, 0.5))
		node2:setTag(tonumber(curNum))
		-- node2:setScale(0)
		
		local curLabel = CommonFunc_getAtlas("01234567890", "num_green.png", 24, 32, 0)
		curLabel:setStringValue(tostring(curNum))
		-- curLabel:setSize(CCSizeMake(130, 30))
		-- curLabel:setText(tostring(curNum))
		-- curLabel:setFontSize(25)
		curLabel:setName("cur")
		curLabel:setAnchorPoint(ccp(0, 0.5))
		curLabel:setPosition(ccp(0, 0))
		curLabel:setScale(0)
		-- curLabel:setTag(tonumber(curNum))
		node2:addChild(curLabel)
		
		local lightLabel = CommonFunc_getAtlas("01234567890", "num_black.png", 24, 32, 0)
		lightLabel:setStringValue(tostring(curNum))
		lightLabel:setName("light")
		lightLabel:setAnchorPoint(ccp(0, 0.5))
		lightLabel:setPosition(ccp(0, 0))
		lightLabel:setScale(0.75)
		lightLabel:setOpacity(0)
		node2:addChild(lightLabel)
		
		local node3 = UILayout:create()
		node3:setSize(CCSizeMake(69, 30))
		node3:setOpacity(0)
		
		local arrowImage = UIImageView:create()
		arrowImage:loadTexture("jiantou.png")
		arrowImage:setAnchorPoint(ccp(0.5, 0.5))
		arrowImage:setPosition(ccp(0, 0))
		-- arrowImage:setRotation(-90)
		node3:addChild(arrowImage)
		
		-- return node1, curLabel, arrowImage
		return node1, node2, node3
	end
	
	local lableLv = mLayerLvUpRoot:getWidgetByName("curLevel")		--当前等级		
	tolua.cast(lableLv,"UILabel")
	lableLv : setText(tostring(param.curNum))
	
	mLastScrollView = mLayerLvUpRoot:getWidgetByName("lastPanel")
	tolua.cast(mLastScrollView,"UIScrollView")
	
	mCurScrollView = mLayerLvUpRoot:getWidgetByName("curPanel")
	tolua.cast(mCurScrollView,"UIScrollView")
	
	mArrowScrollView = mLayerLvUpRoot:getWidgetByName("arrowPanel")
	tolua.cast(mArrowScrollView,"UIScrollView")
	
	local sureBtn = mLayerLvUpRoot:getWidgetByName("LvUp")
	sureBtn:registerEventScript(LayerLvUp_onClick)
	
	
	local lastAttr = ModelPlayer.getRoleUpgradeRow(ModelPlayer.getRoleType(),param.lastNum)	
	local curAttr = ModelPlayer.getRoleUpgradeRow(ModelPlayer.getRoleType(),param.curNum)	
	
	-- local lastAttr = ModelPlayer.getRoleUpgradeRow(1,9)
	-- local curAttr = ModelPlayer.getRoleUpgradeRow(1,10)
	
	local widgetItemTb = {}
	
	-- 添加变动的数值展示
	local function AddChanageAttrShow(constName,attrKey)
		local result,lastNum,curNum = isShow(lastAttr[attrKey],curAttr[attrKey]) 
		if result == true then 	--攻击
			-- local UILableItem = createItem(GameString.get(constName,lastNum),curNum)
			local row = {}
			row.lastItem, row.curItem, row.arrowItem = createItem(constName, lastNum, curNum)
			table.insert(widgetItemTb, row)
		end
	end
	
	AddChanageAttrShow("ATK5","atk")
	AddChanageAttrShow("LIF5","life")
	AddChanageAttrShow("SPE5","speed")
	AddChanageAttrShow("HIT5","hit_ratio")
	AddChanageAttrShow("CRT5","critical_ratio")
	AddChanageAttrShow("MIS5","miss_ratio")
	AddChanageAttrShow("RXP5","tenacity")
	
	ScrollView_FlyIN(mLastScrollView, mCurScrollView, mArrowScrollView, widgetItemTb, 0)
	
end

LayerLvUp.destroy = function()
	mLayerLvUpRoot = nil
end 


