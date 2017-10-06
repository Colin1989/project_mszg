
--符文详细信息

local mLayerRoot = nil
local mID = nil
local mbCurrent = true --是否在身上
local mPosition = nil
LayerRuneInfo = {
}


local function onClickEvent(typeName,widget)
	print("LayerRuneInfo",typeName)
	if typeName == "releaseUp" then
		local widgetName = widget:getName()
		if widgetName == "Button_Close" then
			BackpackUIManage.closeLayer("UI_runeInfo")
		elseif widgetName == "Button_1" then--充能
			BackpackUIManage.closeLayer("UI_runeInfo")
			BackpackUIManage.addLayer("UI_runeCharge",mID)
				
		elseif widgetName == "Button_2" then--出售
			BackpackUIManage.callback_seed_sale_item(mID,1)
			
		elseif widgetName == "Button_4" then 
			if mPosition ~= nil then	--卸下
				LayerRunePut.seed_sculpture_takeoff_msg(mPosition)
			else --穿上
				LayerRunePut.seed_sculpture_puton_msg(mID)
				
			end
		
		end

	end
	
end

function LayerRuneInfo.init(root,param)
	mLayerRoot = root
	print("LayerRuneInfo.init id",param.id,type(param.id))
	mID = param.id
	mPosition = param.position
	
	if type(mID) == "number" then--说明 param.id为物品ID 转化为实例ID
		mID = ModelPlayer.findBagByItemid(mID).id
	end
	
	--local itemID = ModelPlayer.findBagItemIdById(mID)
	--local BaseAttr = LogicTable.getItemById(itemID)
	local rune_attr,BaseAttr = ModelRune.getRuneAppendAttr(mID)
	--local attr,BaseAttr = ModelRune.getRuneAppendAttr(mID)
	
	local RootPanel = GUIReader:shareReader():widgetFromJsonFile("Gem_Info.ExportJson")
	RootPanel:setAnchorPoint(ccp(0.0,0.0))
	RootPanel:setPosition(ccp(67,200))
	mLayerRoot:addChild(RootPanel)
	
	--1 2 4 充能 出售 卸下
	local btnTag = {1,2,4}
	local btnName = nil
	if mPosition ~= nil then
		btnTag = {1,4}
		btnName = {"充能","卸下"}
	else
		btnTag = {1,2,4}
		btnName = {"充能","出售","穿上"}
	end
	
	
	--如果符文镶嵌页面不存活的话 则判断当前页面为背包界面
	if BackpackUIManage.IsLayerExist("UI_runePut") == false then
		btnTag = {1,2}
		btnName = {"充能","出售"}
	end
	
	--表示从符文占卜界面进入
	if BackpackUIManage.IsLayerExist("UI_runeGamble") == true 
	or BackpackUIManage.IsLayerExist("UI_playerInfo") == true then
		btnTag = {}
		btnName = {}
		print("--表示从符文占卜界面进入")
	end
	
	
	
	local btn = nil
	local label = nil
	local ImageView = nil
	
	btn = mLayerRoot:getChildByName("Button_Close")
	btn:registerEventScript(onClickEvent)
	
	for i=1,5 do
		btn = mLayerRoot:getChildByName("Button_"..i)
		tolua.cast(btn,"UIButton")
		btn:setVisible(false)
	end
	
	for key,val in pairs(btnTag) do
		btn = mLayerRoot:getChildByName("Button_"..val)
		tolua.cast(btn,"UIButton")
		btn:registerEventScript(onClickEvent)
		btn:setVisible(true)
		btn:setTitleText(btnName[key])
	end
	
	label = mLayerRoot:getChildByName("Label_1")
	tolua.cast(label,"UILabel")
	--label:setText("冷却时间5秒")
	label:setText(string.format("冷却时间%d回合",rune_attr.skill_cd))

	
	label = mLayerRoot:getChildByName("Label_2")
	label:setVisible(false)
	label = mLayerRoot:getChildByName("Label_3")
	label:setVisible(false)
	
	
	label = mLayerRoot:getChildByName("Label_binding") --
	tolua.cast(label,"UILabel")
	if BaseAttr.bind_type == 1 then
		label:setText("未绑定")
	else
		label:setText("已绑定")
	end
	
	
	ImageView = mLayerRoot:getChildByName("ImageView_head")
	tolua.cast(ImageView,"UIImageView")
	ImageView:loadTexture("Icon/"..BaseAttr.icon)
	--添加品质框
	CommonFunc_AddQualityNode(ImageView,BaseAttr.quality)
	
	label = mLayerRoot:getChildByName("Label_name")
	tolua.cast(label,"UILabel")
	label:setText(BaseAttr.name)
	
	label = mLayerRoot:getChildByName("Label_info")
	tolua.cast(label,"UILabel")
	label:setText(BaseAttr.describe)
	
	label = mLayerRoot:getChildByName("LabelAtlas_price")
	tolua.cast(label,"UILabelAtlas")
	label:setStringValue(BaseAttr.sell_price)
end



