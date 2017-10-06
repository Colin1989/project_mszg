-------------------------------------
--作者：李慧琴
--说明：副本解锁界面
--时间：2014-8-19
-------------------------------------
LayerCopyDelock = {}
local 	mLayerCopyDelockRoot = nil      --当前界面的根节点
local   delockInfo = nil				--当前解锁的解锁信息
LayerAbstract:extend(LayerCopyDelock)

--消失掉背景
LayerCopyDelock.onClick = function(widget)
	widget:setTouchEnabled(false)
    local widgetName = widget:getName()
	local delockBg= tolua.cast( mLayerCopyDelockRoot:getWidgetByName("background"),"UIImageView")	--新功能背景
	delockBg:setVisible(false)
	local delay = 0.02
	for key,value in pairs(delockInfo) do
		local delockImage = tolua.cast( mLayerCopyDelockRoot:getWidgetByName(string.format("icon_%d",key)),"UIImageView")		--新功能Icon		

		--图片飞到对应的位置
		local fromPosition = delockImage:getWorldPosition()
		local destPosition = CopyDelockLogic.judgeFlyToPositionById(value.copy_id,key)
		--print("LayerCopyDelock.onClick ************",value.copy_id,key)
		local action = CommonFunc_curMoveAction(1.0,ccp(fromPosition.x,fromPosition.y) ,ccp(destPosition.x,destPosition.y))
		
		local  function popLayer()
			CopyDelockLogic.showNewByfbId(value.copy_id,key)
			if key == #delockInfo then
				CopyDelockLogic.setStartShowUI(false)
				UIManager.pop("UI_CopyDelock")
				TipModule.onMessage("click_copy_delock")
			end	
		end
		
		--图标消失（公用）
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delay))
		arr:addObject( CCSpawn:createWithTwoActions(action,CCScaleBy:create(1.0,0.1)) )
		arr:addObject(CCHide:create())
		arr:addObject(CCDelayTime:create(1.0))
		arr:addObject(CCCallFuncN:create(popLayer))
		delockImage:runAction(CCSequence:create(arr))	
		delay = delay + 2.0
	end	

end

--设置icon动态排列,根据传过来的个数
local function drawToumingImg(number)
	local delockBg= tolua.cast( mLayerCopyDelockRoot:getWidgetByName("background"),"UIImageView")	--新功能背景
	local width = delockBg:getSize().width
	local position_y = 570
	local delta = 11			--表示两个Icon中间的距离
	widget_width = 94			--图标宽度
	local name_position_y = 20

	local detalX =  (width - number* widget_width)/(number + 1)--向左偏移已至居中
	for i=1,number,1 do
		local position_x = detalX*i + widget_width*(i-1) + widget_width/2		--表示放置的位置
		local img = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(position_x,position_y),
					CCSizeMake(94,94), "touming.png",string.format("icon_%d",i),1 )
		local name = CommonFunc_createUILabel(ccp(0.5,0.5), ccp(position_x - 320,name_position_y), nil, 23,
					ccc3(255, 255, 255),"",i*100, 1)	--名字
		mLayerCopyDelockRoot:addWidget(img)
		delockBg:addChild(name)
	end	
end

LayerCopyDelock.init = function(bundle)
	delockInfo = bundle
	
	mLayerCopyDelockRoot = UIManager.findLayerByTag("UI_CopyDelock")
		
	local delockPanel = tolua.cast( mLayerCopyDelockRoot:getWidgetByName("rootview"),"UILayout")		--新功能Icon		
	delockPanel:setEnabled(true)
	delockPanel:setTouchEnabled(true)
	
	drawToumingImg(#delockInfo)
	
	for key,value in pairs(delockInfo) do
		if key >#delockInfo then
			cclog("越界了*******************",key)
		end
		local delockImage = tolua.cast( mLayerCopyDelockRoot:getWidgetByName(string.format("icon_%d",key)),"UIImageView")		--新功能Icon		
		delockImage:loadTexture(value.icon)
		local delockBg = tolua.cast( mLayerCopyDelockRoot:getWidgetByName("background"),"UIImageView")	--新功能背景
		local delockName = tolua.cast(delockBg:getChildByTag(key*100),"UILabel")							--新功能名字		
		delockName:setText(value.name)
		local delockDes = tolua.cast( mLayerCopyDelockRoot:getWidgetByName("des"),"UILabel")		--新功能描述		
		delockDes:setText(value.description)
		if value.copy_id == LIMIT_HERO.copy_id then
			LayerMain.hideHeroTip()
		end
	end	
	
	setOnClickListenner("next")																		--下一步
	setOnClickListenner("background")																--消失背景
end

function LayerCopyDelock.destroy()
	local root = UIManager.findLayerByTag("UI_CopyDelock")
	if root ~= nil then
		root:removeFromParentAndCleanup(true)
		root = nil
	end
	mLayerCopyDelockRoot = nil
end
















