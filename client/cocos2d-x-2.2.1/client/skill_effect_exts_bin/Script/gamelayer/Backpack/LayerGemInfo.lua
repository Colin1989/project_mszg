
----------------------------------------------------------------------
--宝石信息界面
----------------------------------------------------------------------
local mLayerGemInfoRoot = nil



LayerGemInfo = {
}

--判断是由哪个路口进入
--1 背包入口时 按钮显示  合成，出售
--2 镶嵌入口时 按钮显示  合成，出售，镶嵌
--3 点击已镶嵌宝石图标入口时， 卸下
local mLayerType = 1

--实例ID
--当 mLayerType == 1 2 mGemID为实例ID
--当 mLayerType == 3   mGemID为物品ID
local mGemID = nil 


function LayerGemInfo.IsCompoundMeet(id)
	local bagAttr = ModelPlayer.findBagItemAttr(id)
	local gemAttr = ModelGem.getGemCompoundTable(bagAttr.itemid)
	
	local structConfirm = {
		strText = "",
		buttonCount = 0
	}
	
	if bagAttr.amount < 5 then 
		structConfirm.strText = "合成宝石数量不足"
		UIManager.push("UI_ComfirmDialog",structConfirm)
		return false
	end
	
	--当前宝石已经是最高级
	if gemAttr.related_id == 0 then
		structConfirm.strText = "当前宝石已经是最高级"
		UIManager.push("UI_ComfirmDialog",structConfirm)
	end
	
	return true
end

function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		print("LayerGemInfo typeName:",typeName)
		local widgetName = widget:getName()
			
		if widgetName == "Button_Close" then
			BackpackUIManage.closeLayer("UI_gemInfo")	
		end
		
		if mLayerType == 3 then
			if widgetName == "Button_1" then --卸下
				BackpackUIManage.seed_gem_unmounted_result(mGemID)
				--BackpackUIManage.seed_equipment_mountgem_result(mGemID)
			end
		else
			
			if widgetName == "Button_1" then --合成
				if LayerGemInfo.IsCompoundMeet(mGemID) == true then
					BackpackUIManage.closeLayer("UI_gemInfo")
					BackpackUIManage.addLayer("UI_gemCompound",mGemID)
				end

			elseif widgetName == "Button_2" then --出售
				UIManager.push("UI_Sell",mGemID)
				
			elseif widgetName == "Button_3" then --镶嵌				
				--发送镶嵌请求
				BackpackUIManage.seed_equipment_mountgem_result(mGemID)
			end
			
		end
	end
	
	
end

function LayerGemInfo.onExit()
	BackpackUIManage.closeLayer("UI_gemInfo")
end

function LayerGemInfo.getCurrentGem_Temp_ID()
		
end

--function LayerGemInfo.init(root,id)
--param={gemid,equipid,layerType}
function LayerGemInfo.init(root,param)
	print("LayerGemInfo.init()")
	mLayerGemInfoRoot = root
	mGemID = param[1]
	mLayerType = param[2]
	
	local RootPanel = GUIReader:shareReader():widgetFromJsonFile("Gem_Info.ExportJson")
	RootPanel:setAnchorPoint(ccp(0.0,0.0))
	RootPanel:setPosition(ccp(67,200))
	mLayerGemInfoRoot:addChild(RootPanel)
	
	local attr,BaseAttr = nil 
	if mLayerType == 3 then
		BaseAttr = LogicTable.getItemById(mGemID)
		attr = ModelGem.getGemAttr(BaseAttr.sub_id)
	else 
		attr,BaseAttr = ModelPlayer.getPackItemArr(mGemID)
		--local bagAttr = ModelPlayer.findBagItemAttr(mGemID)
	end
	
	
	local btn = nil
	
	local buttonName = {
		{"合成","出售"},
		{"合成","出售","镶嵌"},
		{"卸下"}
	} 
	print("#buttonName[mLayerType]",#buttonName[mLayerType])
	for i=1,5 do
		btn = mLayerGemInfoRoot:getChildByName("Button_"..i)--出售
		tolua.cast(btn,"UIButton")
		if i <= #buttonName[mLayerType] then 		
			btn:registerEventScript(onClickEvent)
			print(string.format("buttonName[%d][%d]=",mLayerType,i),buttonName[mLayerType][i])
			btn:setTitleText(buttonName[mLayerType][i])
			btn:setVisible(true)
		else
			btn:setVisible(false)
		end
		
	end
	
	btn = mLayerGemInfoRoot:getChildByName("Button_Close")
	btn:registerEventScript(onClickEvent)
	
	
	local ImageView = mLayerGemInfoRoot:getChildByName("ImageView_head")
	tolua.cast(ImageView,"UIImageView")
	ImageView:loadTexture("Icon/"..BaseAttr.icon)
	--添加品质框
	CommonFunc_AddQualityNode(ImageView,BaseAttr.quality)
	
	--[[
	local label = mLayerGemInfoRoot:getChildByName("Label_gemcount")
	tolua.cast(label,"UILabel")
	label:setText(string.format("X%d",bagAttr.amount))	
	]]
	
	label = mLayerGemInfoRoot:getChildByName("Label_name")
	tolua.cast(label,"UILabel")
	label:setText(attr.name)
	
	label = mLayerGemInfoRoot:getChildByName("Label_ability")--
	tolua.cast(label,"UILabel")
	--label:setText(attr.name)
	
	label = mLayerGemInfoRoot:getChildByName("Label_binding") --
	tolua.cast(label,"UILabel")
	if BaseAttr.bind_type == 1 then
		label:setText("未绑定")
	else
		label:setText("已绑定")
	end
	
	label = mLayerGemInfoRoot:getChildByName("Label_info")
	tolua.cast(label,"UILabel")
	label:setText(BaseAttr.describe)
	
	label = mLayerGemInfoRoot:getChildByName("LabelAtlas_price")
	tolua.cast(label,"UILabelAtlas")
	label:setStringValue(BaseAttr.sell_price)
	
	local strGemAttrValue = CommonFunc_getGemValueString(attr)
	
	for i = 1,3 do
		lable = root:getChildByName("Label_"..i)	
		tolua.cast(lable,"UILabel")	
		if strGemAttrValue[i] ~= nil then
			lable:setVisible(true)
			lable:setText(strGemAttrValue[i])
		else
			lable:setVisible(false)
		end
	end
end



