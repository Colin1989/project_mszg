
----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-3-5
-- 描述：宝石镶嵌
----------------------------------------------------------------------
mLayerInlayRoot = nil

LayerGemInlay = {
}

local gem_table = {
	equipment_id = 0,
	gem_id = 0,
	gem_temp_id = 0,
	gemData = {}
}

local function onClickEvent(typeName,widget)
	print("LayerGemInlay",typeName)
	if typeName == "releaseUp" then
		
		local widgetName = widget:getName()
		
		for i=1,3 do
			if gem_table.gemData[i] ~= nil then
				local gem_temp_id = gem_table.gemData[i]
				if widgetName == "Button_gem" .. i then --卸下宝石
					BackpackUIManage.seed_gem_unmounted_result(gem_temp_id)
				elseif widgetName == "ImageView_gem" .. i then
					BackpackUIManage.addLayer("UI_gemInfo",{gem_temp_id,3})
				end
			end
			
		end
		
		if widgetName == "Button_close" then
			BackpackUIManage.closeLayer("UI_gemInlay")
		end
		
	end
	
end

--获取当前镶嵌界面的装备
function LayerGemInlay.getCurrentEquipID()
	return gem_table.equipment_id
end


function LayerGemInlay.init(root,id)
	gem_table.equipment_id = id
	mLayerInlayRoot = root
	mLayerInlayRoot:setPosition(ccp(0,348))
	
	local attr,BaseAttr = ModelPlayer.getPackItemArr(id)
	local addAttr = ModelEquip.getEquipRandomAttr(id)
	
	local btn = nil
	local ImageView = nil
	local label = nil
	
	ImageView = mLayerInlayRoot:getChildByName("ImageView_189")
	tolua.cast(ImageView,"UIImageView")
	ImageView:loadTexture("Icon/"..BaseAttr.icon)
	CommonFunc_AddQualityNode(ImageView,BaseAttr.quality)
	
	label = mLayerInlayRoot:getChildByName("Label_188")
	tolua.cast(label,"UILabel")		
	label:setText(attr.name)
	
	label = mLayerInlayRoot:getChildByName("Label_introduce")			
	
	
	for i=1,3 do
		ImageView = mLayerInlayRoot:getChildByName("ImageView_gem"..i)
		tolua.cast(ImageView,"UIImageView")
		
		print("addAttr.gem_trough",addAttr.gem_trough)
		if i > addAttr.gem_trough then	
			--格子锁住的图片
			ImageView:loadTexture("gemx.png",UI_TEX_TYPE_PLIST)
			
			btn = mLayerInlayRoot:getChildByName("Button_gem" .. i)			
			--btn:registerEventScript(onClickEvent)
			btn:setVisible(false)
		end
		ImageView:registerEventScript(onClickEvent)
	end
	
	btn = mLayerInlayRoot:getChildByName("Button_close")	
	btn:registerEventScript(onClickEvent)
	
	
	LayerGemInlay.updateWidget(addAttr)
	
end

--宝石镶嵌成功
function LayerGemInlay.win_gemInlay()
	local addAttr = ModelEquip.getEquipRandomAttr(gem_table.equipment_id)

	local gem_temp_id = BackpackUIManage.gemInlay.gem_temp_id
	table.insert(addAttr.gems,gem_temp_id)
	for key,val in pairs(addAttr.gems) do
		print("gems key",key,val)
	end
	
	print("gem_temp_id:",gem_temp_id)
	--修改装备随机属性
	ModelEquip.mod_EquipRandomAttr(addAttr)
	
	LayerGemInlay.updateWidget(addAttr)
end

--成功卸下宝石
function LayerGemInlay.win_Gem_unmounted()
	local addAttr = ModelEquip.getEquipRandomAttr(gem_table.equipment_id)
	
	local gemID = BackpackUIManage.gemInlay.gem_temp_id
	for key,val in pairs(addAttr.gems) do
		if 	gemID == val then
			table.remove(addAttr.gems,key)
			break
		end
	end
	
	--修改装备随机属性
	ModelEquip.mod_EquipRandomAttr(addAttr)
	
	LayerGemInlay.updateWidget(addAttr)
end

--更新控件
function LayerGemInlay.updateWidget(addAttr)

	gem_table.gemData = addAttr.gems
	
	for i=1,3 do
		btn = mLayerInlayRoot:getChildByName("Button_gem" .. i)			
		tolua.cast(btn,"UIButton")
		
		ImageView = mLayerInlayRoot:getChildByName("ImageView_gem"..i)			
		tolua.cast(ImageView,"UIImageView")
		ImageView:setTouchEnabled(true)
		ImageView:removeAllChildren()
		
		if addAttr.gems[i] ~= nil then
			print("addAttr.gems[i]",addAttr.gems[i],type(addAttr.gems[i]))
			local gemAttr = LogicTable.getItemById(addAttr.gems[i])
			btn:setTouchEnabled(true)
			
			ImageView:loadTexture("Icon/"..gemAttr.icon)
			ImageView:setVisible(true)
			
			--品质框
			CommonFunc_AddQualityNode(ImageView,gemAttr.quality)
		else
			btn:setTouchEnabled(false)

		end
			
	end
	
end


function LayerGemInlay.onExit()
	
	
end

