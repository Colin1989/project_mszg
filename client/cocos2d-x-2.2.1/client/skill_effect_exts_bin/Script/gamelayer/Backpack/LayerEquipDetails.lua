
----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-1-23
-- 描述：主界面->背包子界面->装备详情页面  不用继承Abstract 因为不属于UI跟节点
----------------------------------------------------------------------
local mLayerEquipRoot = nil

LayerEquipDetails = {
}
-- 装备栏点击
gEquipBagID = nil	--当前选中背包
gEquipCurrentID = nil	--当前装备

--删除装备详情页面
LayerEquipDetails.onExit = function()
	BackpackUIManage.closeLayer("UI_equip")
end

--出售装备 无调用 暂时先放着，装备在身上的装备无法直接售出
LayerEquipDetails.sellEquip = function()
	local price = 0
	
	-- 点击背包
	if gEquipBagID ~= nil then 
		--local item = ModelPlayer.getPackItemBaseArr(gEquipBagID)
		--price = item.sell_price
	
	elseif gEquipCurrentID ~= nil then--点击装备栏
		--local item = ModelPlayer.getPackItemBaseArr(gEquipCurrentID)
		local equipType = ModelEquip.getEquipType(gEquipCurrentID)
		ModelPlayer.UserEquipTable[equipType] = nil

	end

	return price
end

--判断是否符合条件能穿上装备
LayerEquipDetails.IsDress = function(id)
	print("LayerEquipDetails.IsDress()")
	
	local weaponType = nil 
	_,_,weaponType = ModelEquip.getEquipType(id) 

	
	if weaponType ~= 0 and weaponType ~= ModelPlayer.roletype then 
		print("职业不符 ModelPlayer.roletype",ModelPlayer.roletype)
		return false
	end
	
	local attr = ModelPlayer.getPackItemArr(id)
	
	--用户级别不够
	if ModelPlayer.level < attr.equip_use_level  then
		print("级别不符level",ModelPlayer.level,"equip_use_level",attr.equip_use_level)
		return false
	end
	
	
	return true
end

--穿上装备
LayerEquipDetails.dressEquip = function()
	
	--[[
	if gEquipCurrentID ~= nil then --当身上有装备时
		--先脱下装备
		print("先脱下装备")
		LayerEquipDetails.unfixEquip(gEquipCurrentID)
	end
	]]
	
	--再穿上
	local equipType = ModelEquip.getEquipType(gEquipBagID)
	ModelPlayer.UserEquipTable[equipType] = gEquipBagID
	
	--删除背包中的物品
	--LayerBackpack.delBagItem(gEquipBagID,true)
	
	local attr = ModelPlayer.getPackItemBaseArr(gEquipBagID)
	LayerBackpack.updataEquip(equipType,true)
	
end

--脱下装备
LayerEquipDetails.unfixEquip = function(EquipID)
	
	if EquipID == nil then 
		return
	end
	
	for key,val in pairs(ModelPlayer.UserEquipTable) do
			
		if val == EquipID then
			local equipType = ModelEquip.getEquipType(EquipID)
			
			LayerBackpack.updataEquip(equipType,false)
			--LayerBackpack.addBagItem(EquipID)
			ModelPlayer.UserEquipTable[equipType] = nil
			return
		end
	end
	
end


function onClickEvent2(typeName,widget)
	if typeName == "releaseUp" then
		print("typeName:",typeName)
		local widgetName = widget:getName()
		print("typeName:",typeName,"widgetName:",widgetName)		
		
		if widgetName == "Button_Close" then --详细信息	
			LayerEquipDetails.onExit()
		elseif widgetName == "Button_1" then --分解 出售
			BackpackUIManage.callback_seed_sale_item(gEquipBagID,1)

		elseif widgetName == "Button_5" then --宝石
			LayerEquipDetails.onExit()
			BackpackUIManage.addLayer("UI_gemInlay",gEquipBagID or gEquipCurrentID)
			
		elseif widgetName == "Button_4" then --强化
		
		elseif widgetName == "Button_2" then --穿上or卸下
		
			if gEquipBagID == nil then --卸下	
				--判断背包空间是否充足
				if LayerBackpack.IsPackFull(true) == true then
					return
				end
				
				--发送消息
				local tb1 = req_equipment_takeoff()
				tb1.position = ModelEquip.getEquipType(gEquipCurrentID)
				print("卸下装备:",tb1.position)
				NetHelper.sendAndWait(tb1, NetMsgType["msg_notify_equipment_takeoff_result"])
				

			else --穿上
				
				--发送消息
				local tb = req_equipment_puton()
				tb.equipment_id = gEquipBagID
				NetHelper.sendAndWait(tb, NetMsgType["msg_notify_equipment_puton_result"])
				
			end
			
			
		elseif widgetName == "Button_3" then --解除绑定
		
		
		end
	end
end



--计算差值并 创建文字控件 
local function DifferenceValue(root)
	print("DifferenceValue()")
	
	local function CreateDifferenceControl(root,difference,pos)
		print("CreateDifferenceControl() difference:",difference)
		
		local label = UILabel:create()
		label:setPosition(ccp(pos.x+160,pos.y))
		if difference == 0 then
			--label:setText("+0")
			label:setVisible(false)
			
		elseif difference > 0 then
			label:setText(string.format("+%d",difference))
			label:setColor(ccc3(114,255,0))
		elseif difference < 0 then 
			label:setText(string.format("-%d",difference))	
			label:setColor(ccc3(219,38,5))
		end
		
		local node = root:getChildByName("ImageView_Select_0")
		node:addChild(label)
	end

	if gEquipCurrentID ~= nil and gEquipBagID ~= nil then 
		local BagAttr = ModelPlayer.getPackItemArr(gEquipBagID)
		local EquipAttr = ModelPlayer.getPackItemArr(gEquipCurrentID)
		
		local difference = 0
		
		--等级
		--[[
		difference = BagAttr.equip_level - EquipAttr.equip_level
		local node = mLayerEquipRoot:getWidgetByName("Label_9")
		local pos = node:getPosition()
		CreateDifferenceControl(difference,pos)
		]]
		
		--攻击
		difference = BagAttr.atk - EquipAttr.atk
		local node = root:getChildByName("Label_9")
		local pos = node:getPosition()
		CreateDifferenceControl(root,difference,pos)
		
		--命中
		difference = BagAttr.hit_ratio - EquipAttr.hit_ratio
		local node = root:getChildByName("Label_4")
		local pos = node:getPosition()
		CreateDifferenceControl(root,difference,pos)
		
		
		--暴击
		difference = BagAttr.critical_ratio - EquipAttr.critical_ratio
		local node = root:getChildByName("Label_10")
		--tolua.cast(root,"UILabel")
		local pos = node:getPosition()
		CreateDifferenceControl(root,difference,pos)
		
	end	
end

-- onCreate
LayerEquipDetails.init = function (root)
	print("LayerEquipDetails.init()")
	mLayerEquipRoot = root
	
	--注册按钮事件
	local btn = mLayerEquipRoot:getChildByName("Button_Close")--关闭				
	btn:registerEventScript(onClickEvent2)
		
	for i=1,5 do
		btn = mLayerEquipRoot:getChildByName("Button_"..i)--分解 宝石 强化 穿上 解除绑定					
		btn:registerEventScript(onClickEvent2)
	end
		
	--按钮显示是穿上还是卸下
	btn = mLayerEquipRoot:getChildByName("Button_2")
	tolua.cast(btn,"UIButton")
	if gEquipBagID == nil then
		btn:setTitleText("卸下")
	else
		if LayerEquipDetails.IsDress(gEquipBagID) == false then 
			print("装备条件不符")	
			btn:setTouchEnabled(false)
			btn:loadTextureNormal("shortbutton_gray.png")
			btn:setTitleColor(ccc3(255,255,255))
		else
			btn:setTouchEnabled(true)
			btn:loadTextureNormal("sureback.png")
		end
		
		btn:setTitleText("穿上")
	end
	
	
	--分解物品
	btn = mLayerEquipRoot:getChildByName("Button_1")
	tolua.cast(btn,"UIButton")
	if gEquipBagID == nil and gEquipCurrentID ~= nil then --点击装备栏
		LayerEquipDetails.CreateDetails(gEquipCurrentID,ccp(67,200),true)
		
		btn:loadTextureNormal("shortbutton_gray.png")
		btn:setTitleColor(ccc3(255,255,255))
		btn:setTouchEnabled(false)
		
	elseif gEquipBagID ~= nil then --点击背包中的物品
		btn:loadTextureNormal("sureback.png")
		btn:setTouchEnabled(true)
		
		if gEquipCurrentID ~= nil then --已装备物品 开始对比
			LayerEquipDetails.CreateDetails(gEquipCurrentID,ccp(67,200),true)
			LayerEquipDetails.CreateDetails(gEquipBagID,ccp(367,200),false)
		else
			LayerEquipDetails.CreateDetails(gEquipBagID,ccp(67,200),false)
		end
	end
	

end

-- 根据传入信息判断字体颜色 strIndex 索引字段 index 索引值
local function getColour(strIndex,index)
		
	if strIndex == "quality" then --品质判断
		if index == quality_type["white"] then 
			return ccc3(255,255,255)
		elseif index == quality_type["green"] then 
			return ccc3(114,255,0)
		elseif index == quality_type["blue"] then
			return ccc3(0,187,255)
		elseif index == quality_type["purple"] then
			return ccc3(175,20,255)
		elseif index == quality_type["orange"] then
			return ccc3(255,144,0)
		end
	elseif strIndex == "level" then --等级
		if ModelPlayer.level >= index then 
			return ccc3(255,255,255)
		else 
			return ccc3(219,38,5)
		end
	elseif strIndex == "roletype" then --职业
		if ModelPlayer.roletype == index or  index == 0 then 
			return ccc3(255,255,255)
		else
			return ccc3(219,38,5)
		end
	end
end

--创建道具详情面板
LayerEquipDetails.CreateDetails = function(id,pos,bCurrent)
	
	local str = nil
	local data,BaseData = ModelPlayer.getPackItemArr(id)
	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	local addData = ModelEquip.getEquipRandomAttr(id)
	print("END~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	--当前装备信息 节点
	local root = GUIReader:shareReader():widgetFromJsonFile("Backpack_Equip.ExportJson")
	root:setAnchorPoint(ccp(0.0,0.0))
	root:setPosition(pos)
	mLayerEquipRoot:addChild(root)
	
	--对比
	if bCurrent == false then
		DifferenceValue(root)
	end
	
	--临时先把战斗力 宝石加成数据隐藏
	local label = nil 
	--[[
	for i=1,4 do 
		lable = root:getChildByName("gem"..i)	
		lable:setVisible(false)
	end
	label = root:getChildByName("ability_add")
	lable:setVisible(false)
	label = root:getChildByName("ImageView_ability")
	lable:setVisible(false)
	]]
	---------------------------------------------------------------
	
	
	--当前穿戴 标志
	lable = root:getChildByName("ImageView_CurrentTag")
	tolua.cast(lable,"UIImageView")	
	lable:setVisible(bCurrent)
	
	--装备类型
	lable = root:getChildByName("Label_7")
	tolua.cast(lable,"UILabel")	
	_,str = ModelEquip.getEquipType(id)
	local strPath,strQuality = CommonFunc_GetQualityPath(BaseData.quality) 
	lable:setText(string.format("%s:%s",strQuality,str))
	lable:setColor(ccc3(255,255,255))
	
	--装备图标
	lable = root:getChildByName("ImageView_Head")
	tolua.cast(lable,"UIImageView")	
	lable:loadTexture("Icon/" .. BaseData.icon)
	--装备品质框
	CommonFunc_AddQualityNode(lable,BaseData.quality)
	
	
	--装备名称
	lable = root:getChildByName("Label_0")
	tolua.cast(lable,"UILabel")
	local strengLevel = data.strengthen_id%10
	local equipName = nil
	if strengLevel == 0 then
		equipName = data.name
	else
		equipName = data.name.."\n强化+"..tostring(strengLevel)
	end
	lable:setText(equipName)
	lable:setColor(getColour("quality",BaseData.quality))
	
	
	--宝石槽
	--local RandomAttr = ModelEquip.getEquipRandomAttr(id)
	for i=1,3 do
		local view_price = root:getChildByName("ImageView_price"..i)
		tolua.cast(view_price,"UIImageView")
		
		--宝石孔数量
		--if i <= addData.gem_trough then
		if i <= data.gem_trough then
			if i <= #addData.gems then
				local gemID = addData.gems[i]
				local gemAttr = ModelGem.getGemAttr(gemID)
				view_price:loadTexture("Icon/"..gemAttr.small_icon)
				view_price:setVisible(true)
				
			else
				view_price:loadTexture("Icon/gem_blank.png")
			end
				
		else
			view_price:setVisible(false)
		end
		
	end
	
	--[[
	local function getBaseAttrString()
		local equipType = math.floor(data.type/10)
		local str = ""
		if equipType== equipment_type["weapon"]  then
			return string.format("攻击:%d",data.atk)
		elseif equipType == equipment_type["armor"] then 
			return string.format("生命:%d",data.life)
		elseif equipType == equipment_type["necklace"] then 
			--strEquip = "项链"
		elseif equipType == equipment_type["ring"] then 
			--strEquip = "戒指"
		elseif equipType == equipment_type["jewelry"] then 
			--strEquip = "饰品"
		elseif equipType == equipment_type["medal"] then 
			--strEquip = "勋章"
		end
		
		return str
	end
	]]
	
	--职业
	lable = root:getChildByName("Label_2")
	tolua.cast(lable,"UILabel")
	local roletype = 0
	_,_,roletype,str = ModelEquip.getEquipType(id)
	lable:setText("职业:"..str)
	lable:setColor(getColour("roletype",roletype))
		
	--能力数值
	local strEquipAbility = CommonFunc_getGemValueString(data)
	--基础属性
	lable = root:getChildByName("Label_9")	
	tolua.cast(lable,"UILabel")	
	lable:setText(strEquipAbility[1])
	

	--随机武器属性
	local strRandom = CommonFunc_getGemValueString(addData)
	local tWidgetName = {"Label_4","Label_10","Label_5"}
	for i = 1,3 do
		lable = root:getChildByName(tWidgetName[i])	
		tolua.cast(lable,"UILabel")	
		if strRandom[i] ~= nil then
			lable:setVisible(true)
			lable:setText(strRandom[i])
		else
			lable:setVisible(false)
		end
	end
	
	
	--镶嵌宝石数值统计
	local gem_ability = {}
	for key,val in pairs(addData.gems) do
		local attrTemp = ModelGem.getGemAttr(val)
		local strTable = CommonFunc_getGemValueString(attrTemp)
		
		for k,v in pairs(strTable) do
			table.insert(gem_ability,v)
		end
	end
	
	--宝石数值
	for i=1,4 do
		lable = root:getChildByName("gem"..i)	
		tolua.cast(lable,"UILabel")	
		
		if gem_ability[i] ~= nil then
			lable:setText(gem_ability[i])
			lable:setVisible(true)
		else
			lable:setVisible(false)
		end
		
	end
	
			
	--装备描述
	lable = root:getChildByName("Label_6")	
	tolua.cast(lable,"UILabel")	
	lable:setText(BaseData.describe)
	lable:setColor(ccc3(255,144,0))
	
	
	--装备等级
	lable = root:getChildByName("Label_8")	
	tolua.cast(lable,"UILabel")	
	lable:setText("等级" .. data.equip_use_level)
	lable:setColor(getColour("level",data.equip_use_level))
	
	--售价
	lable = root:getChildByName("LabelAtlas_price")	
	tolua.cast(lable,"UILabelAtlas")	
	lable:setStringValue(tostring(BaseData.sell_price))
	
	
	--是否绑定
	lable = root:getChildByName("ImageVies_binding")
	tolua.cast(lable,"UIImageView")
	if BaseData.bind_type == 1 then	
		lable:loadTexture("uiiteminfo_associate.png")
	else
		lable:loadTexture("uiiteminfo_associate.png")
	end
	
end


--穿上装备
local function Handle_equipment_puton_result_msg(resp)
	print("收到穿上装备",resp.puton_result)
	if resp.puton_result == common_result["common_success"] then --成功
		LayerEquipDetails.dressEquip()
		LayerEquipDetails.onExit()
		LayerBackpack.setScrollViewData()
	elseif resp.puton_result == common_result["common_failed"] then 
	
	end
	
end

--卸下装备
local function Handle_equipment_takeoff_result_msg(resp)
	print("收到卸下装备",resp.takeoff_result)
	if resp.takeoff_result == common_result["common_success"] then --成功
		LayerEquipDetails.unfixEquip(gEquipCurrentID)
		LayerEquipDetails.onExit()
		LayerBackpack.setScrollViewData()
	elseif resp.takeoff_result == common_result["common_failed"] then 
	
	
	end
	
end

--售出
local function Handle_sale_item_result_msg(resp)
	if resp.result == common_result["common_success"] then --成功
		LayerEquipDetails.sellEquip()
		LayerEquipDetails.onExit()
		LayerBackpack.setScrollViewData()
	elseif resp.result == common_result["common_failed"] then 
		
		
	end
	
end

--注册装备穿上事件
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_puton_result"], notify_equipment_puton_result(), Handle_equipment_puton_result_msg)

--注册装备脱下事件
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_takeoff_result"], notify_equipment_takeoff_result(), Handle_equipment_takeoff_result_msg)

--注册卖出事件
--NetSocket_registerHandler(NetMsgType["msg_notify_sale_item_result"], notify_sale_item_result(), Handle_sale_item_result_msg)

