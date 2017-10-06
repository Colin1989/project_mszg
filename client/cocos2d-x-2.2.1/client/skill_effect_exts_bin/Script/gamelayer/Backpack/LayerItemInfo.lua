
--物品详情

LayerItemInfo = {}

local mLayerRoot = nil
local mID = nil
local mItemID = nil

local function onClickEvent(typeName,widget)
	print("LayerItemInfo",typeName)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		if widgetName == "Button_Close" then
			BackpackUIManage.closeLayer("UI_itemInfo")
		elseif widgetName == "Button_1" then--分解 
			--BackpackUIManage.callback_seed_sale_item(mID,1)
			UIManager.push("UI_Sell",mID)
		end
	end
	
end


function LayerItemInfo.init(root,param)
	mLayerRoot = root
	mItemID = param.itemid
	mID = param.id
	local RootPanel = GUIReader:shareReader():widgetFromJsonFile("Gem_Info.ExportJson")
	RootPanel:setAnchorPoint(ccp(0.0,0.0))
	RootPanel:setPosition(ccp(67,200))
	mLayerRoot:addChild(RootPanel)
	
	local baseAttr = LogicTable.getItemById(mItemID)
	local btn = nil
	local label = nil
	local ImageView = nil
	
	btn = mLayerRoot:getChildByName("Button_1")
	btn:registerEventScript(onClickEvent)
	btn = mLayerRoot:getChildByName("Button_Close")
	btn:registerEventScript(onClickEvent)
	
	
	if BackpackUIManage.IsLayerExist("UI_runeGamble") == true 
	or BackpackUIManage.IsLayerExist("UI_playerInfo") == true  then
		btn = mLayerRoot:getChildByName("Button_1")
		--btn:setVisible(false)
		CommonFunc_SetWidgetTouch(btn,false)
	end
	
	for i=2,5 do
		btn = mLayerRoot:getChildByName("Button_"..i)
		--tolua.cast(btn,"UIButton")
		--btn:setVisible(false)
		CommonFunc_SetWidgetTouch(btn,false)
	end
	
	
	label = mLayerRoot:getChildByName("Label_binding") --
	tolua.cast(label,"UILabel")
	if baseAttr.bind_type == 1 then
		label:setText("未绑定")
	else
		label:setText("已绑定")
	end
	
	ImageView = mLayerRoot:getChildByName("ImageView_head")
	tolua.cast(ImageView,"UIImageView")
	ImageView:loadTexture("Icon/"..baseAttr.icon)
	--添加品质框
	CommonFunc_AddQualityNode(ImageView,baseAttr.quality)
	
	label = mLayerRoot:getChildByName("Label_name")
	tolua.cast(label,"UILabel")
	label:setText(baseAttr.name)
	
	label = mLayerRoot:getChildByName("Label_info")
	tolua.cast(label,"UILabel")
	label:setText(baseAttr.describe)
	
	label = mLayerRoot:getChildByName("LabelAtlas_price")
	tolua.cast(label,"UILabelAtlas")
	label:setStringValue(baseAttr.sell_price)
	
	for i = 1,3 do
		lable = root:getChildByName("Label_"..i)	
		lable:setVisible(false)
	end
	
	
	
end