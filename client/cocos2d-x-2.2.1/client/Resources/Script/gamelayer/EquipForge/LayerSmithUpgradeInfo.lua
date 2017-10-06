----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-13
-- Brief:	铁匠铺主界面（装备升阶动画界面）
----------------------------------------------------------------------
local mLayerRoot = nil		-- 界面根节点
local mBundleInfo = nil		-- 传过来的信息

local mBg = nil
local mIconImageView = nil
local mSuccessImg = nil
local mLightImg = nil

LayerSmithUpgradeInfo = {}
LayerAbstract:extend(LayerSmithUpgradeInfo)

-- 点击
LayerSmithUpgradeInfo.onClick = function(widget)
	--[[
	TipModule.onClick(widget)
	local widgetName = widget:getName()
	if "rootview" == widgetName  then
		UIManager.pop("UI_Smith_Upgrade_Info")
	end
	]]--
end

--移除掉图片
local function removeActions()

	local function call_Func1(sender)
		UIManager.pop("UI_Smith_Upgrade_Info")
		--进入武器详细信息界面
		local instId = mBundleInfo.instId
		local param = {}
		param.instId = instId
		UIManager.push("UI_Smith_Equip_sure",param)
	end
	
	local function call_Func(sender)
		sender:getParent():removeChild(sender,true)
	end
	
	mSuccessImg:runAction( CCSequence:createWithTwoActions( CCFadeOut:create(0.5), CCCallFuncN:create(call_Func) ) )
	mIconImageView:runAction( CCSequence:createWithTwoActions( CCFadeOut:create(0.5), CCCallFuncN:create(call_Func) ) )
	mBg:runAction( CCSequence:createWithTwoActions( CCFadeOut:create(0.5), CCCallFuncN:create(call_Func1) ) )
end

--创建星星
local function createStars(mLightImg)
	--星星的坐标  -- 1delaytime,2 start point,3 end point(相对) ,4 start scale,5 end scale,6 rotate,7continue time
	local starsConf = {	{0, ccp(-100,20), ccp(-230,20), 2, 0.2, -660, 0.7}, {0.2, ccp(-90,20), ccp(-235,22), 2, 0.3, 630, 0.7},		--2
			{0, ccp(-80,30), ccp(-250,50), 2, 0.2, 630, 0.7},   {0.2, ccp(-70,40), ccp(-200,80), 2, 0.2, 630, 0.7},		--4
			{0, ccp(-65,50), ccp(-200,90), 3, 0.2, -620, 0.7},	{0.2, ccp(-63,50), ccp(-172,95), 2, 0.3, -680, 0.7},	--6
			{0, ccp(-50,40), ccp(-150,150), 3, 0.2, 670, 0.7},	{0.2, ccp(-50,45), ccp(-170,170), 2, 0.2, 670, 0.7},
			{0, ccp(-40,50), ccp(-40,200), 1, 0.3, 640, 0.7}, 	{0.2, ccp(-30,50), ccp(-20,220), 2, 0.2, -660, 0.7 },	--10
			{0.2, ccp(-10,50), ccp(-10,240), 1, 0.4, 650, 1},	{0, ccp(10,50), ccp(150,80), 1, 0.4, 660, 0.8 },
			{0, ccp(100,20), ccp(230,20), 2, 0.2, -660, 0.7 },	{0.2, ccp(90,20), ccp(235,22), 2, 0.3, 630, 0.7},		
			{0, ccp(80,30), ccp(250,50), 2, 0.2, 630, 0.7},		{0.2, ccp(70,40), ccp(200,80), 2, 0.2, 630, 0.7},		   
			{0, ccp(65,50), ccp(200,90), 3, 0.2, -620, 0.7},	{0.2, ccp(63,50), ccp(172,95), 2, 0.3, -680, 0.7},		
			{0, ccp(50,40), ccp(150,150), 3, 0.2, 670, 0.7},	{0.2, ccp(50,45), ccp(170,170), 2, 0.2, 670, 0.7},
			{0, ccp(40,50), ccp(40,200), 1, 0.3, 640, 0.7},     {0.2, ccp(30,50), ccp(20,220), 2, 0.2, -660, 0.7 }		}
			
	local times = 0
	local function call_Func(sender)
		sender:getParent():removeChild(sender,true)
		times = times + 1
		if times >= 22 then
			removeActions()
		end
	end	
	
	--创建闪光的星星
	for key, var in pairs(starsConf) do
		local star = UIImageView:create()
		star:loadTexture("role_upgrade_star.png")
		star:setPosition( var[2])
		star:setScale(var[4])
		star:setOpacity(0)
		
		local array = CCArray:create()
		array:addObject(CCRotateBy:create(var[7],var[6]) )
		array:addObject(CCScaleTo:create(var[7],var[5]) )
		array:addObject(CCFadeIn:create(0) )
		array:addObject(CCEaseSineOut:create(CCMoveBy:create(var[7],var[3]) ))
		
		local action = CCSpawn:create( array )
		local action1 = CCSequence:createWithTwoActions( CCDelayTime:create(var[1]),action)
		local action2 = CCSequence:createWithTwoActions(action1,CCCallFuncN:create(call_Func))
		star:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.25),action2))
		mLightImg:addChild(star)
	end
end

--显示闪光
local function showLightAction()
	local colArray = CCArray:create()
	colArray:addObject(CCTintTo:create(0.5,255,200,200) )
	colArray:addObject(CCTintTo:create(0.5,255,255,255) )
	colArray:addObject(CCFadeOut:create(0.2) )
	local action = CCSequence:create( colArray )
	local action1 = CCSequence:createWithTwoActions( CCScaleTo:create(0.1,1),CCFadeIn:create(0.06))
	local action2 = CCSpawn:createWithTwoActions( action,action1)
	local action3 = CCSequence:createWithTwoActions(CCDelayTime:create(0.05) ,action2)
	mLightImg:runAction(action3)
	--创建星星
	createStars(mLightImg)
end
	
local function initUIActions()
	--进阶后的图片飞出来
	mIconImageView:runAction( CCEaseSineOut:create( CCMoveTo:create(0.4, ccp(338,639))) )
	--进阶成功图片飞出来
	local array2 = CCArray:create()
	array2:addObject( CCDelayTime:create(0.6) )
	array2:addObject( CCShow:create() )
	array2:addObject( CCScaleTo:create( 0.3, 1 ) )
	array2:addObject( CCCallFunc:create(showLightAction) )
	local action3 = CCSequence:create( array2 )
	mSuccessImg:runAction( action3 )
end
	
-- 初始化
LayerSmithUpgradeInfo.init = function(bundle)

	mBundleInfo = bundle
	
	local root = UIManager.findLayerByTag("UI_Smith_Upgrade_Info")
	--setOnClickListenner("rootview")

	
	--黑色背景
	mBg = tolua.cast(root:getWidgetByName("bg"), "UIImageView")
	mBg:setOpacity(0)
	--进阶后的装备图标
	mIconImageView = tolua.cast(root:getWidgetByName("icon"), "UIImageView")
	local instId = bundle.instId
	local equipRow = ModelEquip.getEquipInfo(instId)
	local itemRow = LogicTable.getItemById(equipRow.temp_id)
	mIconImageView:loadTexture(itemRow.icon)
	mIconImageView:setPosition(ccp(320,1000))
	CommonFunc_SetQualityFrame(mIconImageView, itemRow.quality)	-- 装备品质框
	
	--进阶成功的图标
	mSuccessImg = tolua.cast(root:getWidgetByName("successImg"), "UIImageView")
	mSuccessImg:setScale(4)
	mSuccessImg:setVisible(false)
	--闪光图片
	mLightImg = tolua.cast(root:getWidgetByName("lightImg"), "UIImageView")
	mLightImg:setScale(0)
	
	--背景淡入
	local array = CCArray:create()
	array:addObject( CCFadeIn:create(0.3) )
	array:addObject( CCCallFunc:create( initUIActions ) )
	mBg:runAction( CCSequence:create( array ) )
	
end

-- 销毁
LayerSmithUpgradeInfo.destroy = function()
	mLayerRoot = nil
end