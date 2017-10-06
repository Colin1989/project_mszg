LayerTowerSettle = {}

local mLayerTowerSettleRoot = nil


local mInitType = ""	-- "nextLayer" 为下一层事件
local mGameMap = {}
local mGem = XmlTable_load("gem_attributes.xml")


local function getGemArrBysubId (id)
	local res = XmlTable_getRow(mGem, "id", id)
	local row = {}
	for k, v in pairs(res) do
		if "id" == v.name then
			row.id = v.value	
		elseif "type" == v.name then
			row.type = v.value	+ 0
		end
	end
	return row
end

LayerAbstract:extend(LayerTowerSettle)

LayerTowerSettle.onClick  = function(weight)
	local weightName = weight:getName()
--		local weightName = weight:getName()
	if weightName == "push_sure_btn" then
	    if mInitType == "nextLayer" then 
			UIManager.pop("UI_TowerSettle")
			--Tood 切场动画
			FightDateCache.initGameDate(mGameMap,nil,"pushNext")
			createGameSceneLayer(g_Const_GameStatus.GamePlay,LayerCopyTips.getCurCopyRes_id())
		elseif mInitType == "endLayer" then 
			cclog("推塔总结算->回主菜单")
			UIManager.retrunMainLayer("fightOver")
		end
	end
	
end



--只支持竖方向下滑 -- 再优化   --这个方法要封装出去
function setGridViewAdapter(scrollView,ArrayDate,line)
	
	local function getRightSize(length) 
		if length < 5*line then --再优化 5是代表这个
			return  5+1
		end
		if length % line == 0 then	
			return math.floor(length/line)+1		--偶数
		else 
			return math.floor(length/line)+1 +1	--奇数
		end
	end
	
	local widgetHeight = 0
	local pNext = 1
	local iCount = 0
	for key,widget in pairs(ArrayDate) do 
		
		local widget_height = widget:getSize().height
		local widget_width  = widget:getSize().width
		
		if iCount < line then 	
			iCount = iCount + 1
		else 
			iCount = 1
			pNext = pNext + 1
			widgetHeight  = pNext * widget:getSize().height
		end
		widget:setAnchorPoint(ccp( (-1)*(iCount -1) ,(-1)*(getRightSize(#ArrayDate)- pNext -1) ) )	
		scrollView:addChild(widget)

	end	
	scrollView:setDirection(SCROLLVIEW_DIR_VERTICAL)
	scrollView:setInnerContainerSize(CCSizeMake(scrollView:getSize().width,widgetHeight ));
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

LayerTowerSettle.init = function (bundle)
	local awardsTb		--结算物品表
	local function initView(InitType) 
		if mInitType == "nextLayer" then --结算类型
			--topView
			mLayerTowerSettleRoot:getWidgetByName("ImageView_90"):setVisible(false)
			--goldView
			mLayerTowerSettleRoot:getWidgetByName("Iv_p_s_gold"):setVisible(false)
			--expView
			mLayerTowerSettleRoot:getWidgetByName("Iv_p_s_exp"):setVisible(false)
			--label2
			mLayerTowerSettleRoot:getWidgetByName("pushtowerlabel2"):setVisible(false)
			
			awardsTb = bundle.awards
		elseif mInitType == "endLayer" then 
			local Label_gold = mLayerTowerSettleRoot:getWidgetByName("Label_107")	--金币
			tolua.cast( Label_gold,"UILabel")
			Label_gold:setText(string.format("%d",FightDateCache.pushTower().gold ))
			
			local Label_exp =  mLayerTowerSettleRoot:getWidgetByName("Label_105")	--经验
			tolua.cast( Label_exp,"UILabel")
			Label_exp:setText(string.format("%d",FightDateCache.pushTower().exp ))
			
			awardsTb = FightDateCache.pushTower().awards  --结算总表
				
		end
		
		local completeLayerStr = mLayerTowerSettleRoot:getWidgetByName("pushtowerlabel1")
		tolua.cast( completeLayerStr,"UILabel")
		completeLayerStr:setText(string.format("%03d层",FightDateCache.pushTower().pushLayer - 1))
		
		local completeLayerStr = mLayerTowerSettleRoot:getWidgetByName("pushtowerlabel2")
		tolua.cast( completeLayerStr,"UILabel")
		completeLayerStr:setText(string.format("%03d层",FightDateCache.pushTower().resp.max_floor))
	end

	mLayerTowerSettleRoot = UIManager.findLayerByTag("UI_TowerSettle")
	setOnClickListenner("push_sure_btn")		
	local ScrollItem = {}
	
	local scrollView = mLayerTowerSettleRoot:getWidgetByName("ScrollView_pannel")
	tolua.cast(scrollView,"UIScrollView")
	

	--bundle.result = 0
     mGameMap = bundle.gamemap
    
	
	mInitType = bundle.EventType
	initView(mInitType)
	
	local totalRewards = 0	--本次获得了多少宝石
	for k,v in pairs(awardsTb) do
		local item =  GUIReader:shareReader():widgetFromJsonFile("settle_doubleLabel_commn_1.ExportJson")
		local Label_name = item:getChildByName("Label_left1")
		tolua.cast(Label_name,"UILabel")
		local curItem = LogicTable.getItemById(v.temp_id) 	
		Label_name:setText(	curItem.name )
		
		local itemArr = getGemArrBysubId(curItem.sub_id)
		Label_name:setColor(getColor(itemArr.type) )
		
		local Label_num = item:getChildByName("Label_left2")
		tolua.cast(Label_num,"UILabel")
		Label_num:setText(	string.format("*%03d",tonumber(v.amount) ) )
		if mInitType == "nextLayer" then  --单个关卡即为结算宝石
			totalRewards = totalRewards + v.amount
			FightDateCache.addPushTower(v.temp_id,bundle.gold,bundle.exp)
		end
		table.insert(ScrollItem, item)
	end
	
	FightDateCache.setcurReward("baoshi",totalRewards)
	setGridViewAdapter(scrollView,ScrollItem,2) 
end