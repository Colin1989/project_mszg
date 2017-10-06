
--临时背包 背包溢出

local mLayerTempBackRoot = nil

LayerTempBackpack = {
}

--背包格子数
local mGridCountMax = 50
--开放的格子数
local mGridCountOpen = 20

--每一行格子数量
local mRowCount = 3
--背包格子大小
local mGridHeight = 106
local mGridWidth = 106

--
local mExceededTable = nil


	
local function onClickEvent(typeName,widget)
	
		if typeName == "releaseUp" then
			local widgetName = widget:getName()	
			if widgetName == "Button_Clear" then
				UIManager.retrunMainLayer("bag")
			elseif widgetName == "Button_BACK" then
				UIManager.pop("UI_TempPack")
				UIManager.retrunMainLayer("fightOver")
			elseif widgetName == "Button_expansion" then
				UIManager.retrunMainLayer("bag")
				LayerBackpack.SeedExtend_packFunction()
			end
			
			
		end
		
end

function LayerTempBackpack.destory()
	
end

--判断是否加载界面
function LayerTempBackpack.IsPushLayer()
	if mExceededTable == nil then
		return false
	end

	--UIManager.push("UI_TempPack",mExceededTable)
		
	return true
end

function LayerTempBackpack.init(bundle)
	print("LayerTempBackpack.init()")
	bundle=mExceededTable
	mExceededTable = nil
	mLayerTempBackRoot = UIManager.findLayerByTag("UI_TempPack")
	
	local ScrollView = mLayerTempBackRoot:getWidgetByName("ScrollView_833")
	tolua.cast(ScrollView,"UIScrollView") 
	ScrollView:setBounceEnabled(false)
	ScrollView:removeAllChildren()
	
	-- 计算拖动层尺寸高度
	local contair = ScrollView:getInnerContainer()
	local iHeight = math.ceil(#bundle/mRowCount)
	
	
	--临时 如果只显示一行的话坐标会出错
	if iHeight == 1 then 
		iHeight = 2
	end
	
	iHeight = mGridHeight*iHeight
	contair:setSize( CCSize(mGridWidth*mRowCount,iHeight) )
	ScrollView:setInnerContainerSize(contair:getSize())
	
	for i=1,#bundle do
		local iRow = math.floor((i-1)/mRowCount)--行
		local iCol = math.floor((i-1)%mRowCount)--列
		local iX = iCol*mGridWidth+mGridWidth/2 + 12
		local iY = iHeight-(iRow*mGridHeight+mGridHeight/2)
		
		local gridImage = UIImageView:create() --格子
		gridImage:setPosition(ccp(iX,iY))
		gridImage:setTouchEnabled(false)
		gridImage:loadTexture("frame_white.png")
		
		local val = bundle[i]
		if val == nil then 
			break
		end
		
		print("val.item_id",val.item_id)
		local attr = LogicTable.getItemById(val.item_id)
		local path = CommonFunc_GetQualityPath(attr.quality)
		
		local itemImage = UIImageView:create() 
		itemImage:setTouchEnabled(false)
		itemImage:loadTexture("Icon/" .. attr.icon)
		gridImage:addChild(itemImage)
		
		--品质框
		local qualityImage = UIImageView:create()
		qualityImage:loadTexture(path)
		gridImage:addChild(qualityImage)
		
		--物品数量显示
		if val.count ~= 1 then 
			local ItemCountLabel = UILabelAtlas:create()
			ItemCountLabel:setProperty("01234567890", "GUI/labelatlasimg.png", 24, 32, "0")
			ItemCountLabel:setStringValue(string.format("X%d",val.count))
			ItemCountLabel:setPosition(ccp(20,-30))
			gridImage:addChild(ItemCountLabel)
		end
		
		
		ScrollView:addChild(gridImage)
	end
	
	
	--按钮事件
	local btn = mLayerTempBackRoot:getWidgetByName("Button_Clear")
	btn:registerEventScript(onClickEvent)	
	
	btn = mLayerTempBackRoot:getWidgetByName("Button_BACK")
	btn:registerEventScript(onClickEvent)	
	
	btn = mLayerTempBackRoot:getWidgetByName("Button_expansion")
	btn:registerEventScript(onClickEvent)	
	
end



--收到背包满的消息，加载临时背包界面
local function Handle_player_pack_exceeded_result_msg(resp)
	print("收到背包满的消息，加载临时背包界面")
	mExceededTable = CommonFunc_ItemStatistics(resp.new_extra)
	
	--UIManager.push("UI_TempPack",mExceededTable)
	
end

--注册装备穿上事件
NetSocket_registerHandler(NetMsgType["msg_notify_player_pack_exceeded"], notify_player_pack_exceeded(), Handle_player_pack_exceeded_result_msg)
