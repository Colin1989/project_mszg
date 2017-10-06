
-------------------------------------------------
--	文件内容：	背包UI界面管理
--	叶江涛		2014/3/5		
-------------------------------------------------

BackpackUIManage = {
}

local mRoot = nil 
local mBackpackRoot = nil

--堆栈 tag,layer
local mStackTable = {}

--镶嵌宝石需要用到的信息数据
BackpackUIManage.gemInlay = {}
BackpackUIManage.gemInlay.equipment_id = nil
BackpackUIManage.gemInlay.gem_temp_id = nil
BackpackUIManage.gemInlay.gem_id = nil

local UITable = {
	["UI_Bag"] = {					--装备信息
		jsonFile = "Backpack_Bag.ExportJson",
		tb = LayerBackpack
	},
	["UI_equip"] = {					--装备信息
		jsonFile = "Backpack_Base.ExportJson",
		tb = LayerEquipDetails
	},
	["UI_playerInfo"] = {				--玩家信息
		jsonFile = "Backpack_Player.ExportJson",
		tb = LayerPlayerInfo
	},
	["UI_gemInfo"] = {					--宝石信息
		--jsonFile = "Gem_Info.ExportJson",
		jsonFile = "Backpack_Base.ExportJson",
		tb = LayerGemInfo
	},
	["UI_gemCompound"] = {				--宝石合成
		jsonFile = "Gem_Compound.ExportJson",
		tb = LayerGemCompound
	},
	["UI_gemInlay"] = {					--宝石镶嵌
		jsonFile = "Gem_Inlay.ExportJson",
		tb = LayerGemInlay
	},
	
	["UI_runeMain"] = {					--符文主界面
		jsonFile = "Rune_main.ExportJson",
		tb = LayerRuneMain
	},
	["UI_runePut"] = {					--符文穿戴
		jsonFile = "Rune_1.ExportJson",
		tb = LayerRunePut
	},
	["UI_runeGamble"] = {				--符文占卜
		jsonFile = "Rune_ZB.ExportJson",
		tb = LayerRuneGamble
	},
	["UI_runeCharge"] = {				--符文充能
		jsonFile = "Rune_Charge.ExportJson",
		tb = LayerRuneCharge
	},
	["UI_runeConvert"] = {				--符文兑换
		jsonFile = "Rune_convert.ExportJson",
		tb = LayerRuneConvert
	},
	["UI_runeInfo"] = {					--符文信息
		jsonFile = "Backpack_Base.ExportJson",
		tb = LayerRuneInfo
	},
	["UI_itemInfo"] = {					--符文信息
		jsonFile = "Backpack_Base.ExportJson",
		tb = LayerItemInfo
	}
}
function BackpackUIManage.setBackpackTitle(strTitle)
	if mBackpackRoot == nil then
		print("设置背包标题失败")
		return
	end
	local label = mBackpackRoot:getChildByName("Label_1048")
	tolua.cast(label,"UILabel")
	label:setText(strTitle)
end

function BackpackUIManage.init(BackpackRoot)
	print("BackpackUIManage.init()")
	
	mRoot = LayerMain.getContendPanel()
	--mBackpackRoot = BackpackRoot
	--mStackTable = {}
end

--删除所有界面
--会出现 mBackpackRoot 拖动控件出错
function BackpackUIManage.removeAllUIlayer()
	mRoot = nil
	mBackpackRoot = nil
	mStackTable = {}
end


function BackpackUIManage.getCurrentLayer()
	
	--Layer类型 equip,rune,gem
	local mLayerType = "equip"
	
	local strlayer = mStackTable[#mStackTable].tag
	
	if strlayer == "UI_equip" or strlayer == "UI_playerInfo" 
		or strlayer == nil then
	
		mLayerType = "equip"
	elseif strlayer == "UI_gemInfo" or strlayer == "UI_gemCompound"
		or strlayer == "UI_gemInlay" then
		
		mLayerType = "gem"
	elseif strlayer == "UI_runeMain" or strlayer == "UI_runePut"
		or strlayer == "UI_runeGamble" or strlayer == "UI_runeCharge"
		or strlayer == "UI_runeConvert" or strlayer == "UI_runeInfo" then
		
		mLayerType = "rune"
	end
	
	print("strlayer,mLayerType:",strlayer,mLayerType)
	return strlayer,mLayerType
end

function BackpackUIManage.switchLayer(strLayer,param,bClear)
	if BackpackUIManage.IsLayerExist(strLayer) == false then
		BackpackUIManage.addLayer(strLayer,param)
	else
		BackpackUIManage.closeLayer(strLayer)
	end
	
end


--bClear 是否清除上一个界面
function BackpackUIManage.addLayer(strLayer,param,bClear)
	print("增加界面strLayer,bClear",strLayer,bClear)
	if bClear == true then
		print("清除上面一个层")
		BackpackUIManage.closeLayer()
	end
	
	local bShield = true --是否屏蔽上一层
	local jsonLayer = GUIReader:shareReader():widgetFromJsonFile(UITable[strLayer].jsonFile)
	CommonFunc_SetWidgetTouch(jsonLayer,true)
	local hideTable = {} --需要隐藏的控件列表
	local parentLayer = nil 
	
	local stack = {}
	stack.tag = strLayer
	stack.parentLayer = nil --add 到 mRoot的节点  jsonLayer的父节点
	stack.jsonLayer = jsonLayer
	stack.hideTable = hideTable --需要隐藏的控件列表
	table.insert(mStackTable,stack)
	
	if strLayer == "UI_Bag" and mBackpackRoot == nil then 
		mRoot:addChild(jsonLayer)
	end
	
	UITable[strLayer].tb.init(jsonLayer,param)
	 
	if strLayer == "UI_Bag" then
		mBackpackRoot = jsonLayer
		bShield = false
		
	elseif strLayer == "UI_playerInfo" then
		bShield = false
		
		jsonLayer:setPosition(ccp(32,25))
			
		local node = mBackpackRoot:getChildByName("Panel_720")
		--CommonFunc_SetWidgetTouch(node,false)
		table.insert(hideTable,node)
			
		local btn = mBackpackRoot:getChildByName("Button_0")
		tolua.cast(btn,"UIButton")
		btn:setTitleText("背包")

	elseif strLayer == "UI_gemInfo" then
		CommonFunc_SetWidgetTouch(mBackpackRoot,false)
		
	elseif strLayer == "UI_gemInlay" then
		local bState,layerVal = BackpackUIManage.IsLayerExist("UI_playerInfo")
		if bState == true then
			CommonFunc_SetWidgetTouch(layerVal.jsonLayer,false)
			local node = mBackpackRoot:getChildByName("Panel_720")
			CommonFunc_SetWidgetTouch(node,true)
		end
		
		bShield = false
		local node = mBackpackRoot:getChildByName("Panel_847")
		CommonFunc_SetWidgetTouch(node,false)
		BackpackUIManage.setBackpackTitle("我的宝石")
		
		mBackpackRoot:addChild(jsonLayer)
		
		parentLayer = mBackpackRoot
		LayerBackpack.mod_BagLayer("gem")
		
		
	elseif strLayer == "UI_runeMain" then
		mBackpackRoot = GUIReader:shareReader():widgetFromJsonFile("Backpack_Bag.ExportJson")
		LayerBackpack.init(mBackpackRoot)
		CommonFunc_SetWidgetTouch(mBackpackRoot,false)
		mRoot:addChild(mBackpackRoot)
		
	elseif strLayer == "UI_runeCharge" then
		jsonLayer:setPosition(ccp(0,300))
		CommonFunc_SetWidgetTouch(mBackpackRoot,true)
		
		local node = mBackpackRoot:getChildByName("Panel_847")
		--CommonFunc_SetWidgetTouch(node,false)
		table.insert(hideTable,node)
		
		BackpackUIManage.setBackpackTitle("我的符文")
				
		LayerBackpack.mod_BagLayer("rune")
		
		parentLayer = mBackpackRoot
		
		bShield = false
	elseif strLayer == "UI_runePut" then
		CommonFunc_SetWidgetTouch(mBackpackRoot,true)
		BackpackUIManage.setBackpackTitle("我的符文")
		local node = mBackpackRoot:getChildByName("Panel_847")
		--CommonFunc_SetWidgetTouch(node,false)
		table.insert(hideTable,node)
		
		LayerBackpack.mod_BagLayer("rune")
		
		parentLayer = mBackpackRoot
	end
	
	if strLayer ~= "UI_Bag" then --临时添加
		if parentLayer == nil then
			mRoot:addChild(jsonLayer)
		else
			parentLayer:addChild(jsonLayer)
			--mRoot:addChild(parentLayer)
		end
	end
	
	--屏蔽当前层的部分控件
	for key,val in pairs(hideTable) do
		CommonFunc_SetWidgetTouch(val,false)
	end
	
	--屏蔽之前的层
	local tempLayer = nil
	if bShield == true then
		local _index = #mStackTable-1
		if  _index >=1 then
			if mStackTable[_index].parentLayer ~= nil then
				tempLayer = mStackTable[_index].parentLayer
				print("parentLayer")
			else
				tempLayer = mStackTable[_index].jsonLayer
				print("jsonLayer")
			end
			
			print("屏蔽的层：",mStackTable[_index].tag)
			CommonFunc_SetWidgetTouch(tempLayer,false)
			
		end
			
	end
		
	local stack = {}
	stack.tag = strLayer
	stack.parentLayer = parentLayer
	stack.jsonLayer = jsonLayer
	stack.hideTable = hideTable
	--临时
	--CommonFunc_SetWidgetTouch(parentLayer,true)
	CommonFunc_SetWidgetTouch(jsonLayer,true)
	
	mStackTable[#mStackTable] = stack
end


function BackpackUIManage.closeLayer(strLayer)
	
	local index = nil
	--暂时
	strLayer = nil
	if strLayer == nil then
		index = #mStackTable
		strLayer = mStackTable[index].tag
	else
		for key,val in pairs(mStackTable) do
			if val.tag == strLayer then
				table.remove(mStackTable,key)
				index = key
				break
			end
		end
	end
	
	--模拟调用析构函数
	--[[
	local function DestoryFunc(strLayer)
		if UITable[strLayer].onExit ~= nil then
			print("--模拟调用析构函数 ",strLayer)
			UITable[strLayer].onExit()
		end
	end
	DestoryFunc(strLayer)
	]]
	
	--删除
	print("删除界面UI~~~~~~~~~~~~~~~REMOVE:",strLayer)
	if mStackTable[index].parentLayer ~= nil then
		mStackTable[index].parentLayer:removeChild(mStackTable[index].jsonLayer)
	else
		mRoot:removeChild(mStackTable[index].jsonLayer)
	end
	table.remove(mStackTable)
	
	--显示激活下一个
	index = #mStackTable
	if index ~= 0 then
		print("显示激活",mStackTable[index].tag)
		--if mStackTable[index].parentLayer ~= nil then
			CommonFunc_SetWidgetTouch(mStackTable[index].parentLayer,true)
		--else
			CommonFunc_SetWidgetTouch(mStackTable[index].jsonLayer,true)
		--end
		--屏蔽当前层的部分控件
		for key,val in pairs(mStackTable[index].hideTable) do
			CommonFunc_SetWidgetTouch(val,false)
		end
	else
		print("mStackTable 表已经空了")
	end
	
	
	if strLayer == "UI_playerInfo" then 
		local node = mBackpackRoot:getChildByName("Panel_720")
		CommonFunc_SetWidgetTouch(node,true)
			
		local btn = mBackpackRoot:getChildByName("Button_0")
		tolua.cast(btn,"UIButton")
		btn:setTitleText("详细信息")
		
	elseif strLayer == "UI_gemInfo" then
		--CommonFunc_SetWidgetTouch(mBackpackRoot,true)
		
	elseif strLayer == "UI_gemInlay" then
		local bState,layerVal = BackpackUIManage.IsLayerExist("UI_playerInfo")
		if bState == true then
			CommonFunc_SetWidgetTouch(layerVal.jsonLayer,true)
			local node = mBackpackRoot:getChildByName("Panel_720")
			CommonFunc_SetWidgetTouch(node,false)
		end
	
		local node = mBackpackRoot:getChildByName("Panel_847")
		CommonFunc_SetWidgetTouch(node,true)
		BackpackUIManage.setBackpackTitle("我的背包")
		
		LayerBackpack.mod_BagLayer("equip")
		
	elseif strLayer == "UI_runeMain" then
		mRoot:removeChild(mBackpackRoot)
		mBackpackRoot = nil
		
	elseif strLayer == "UI_runePut" then
		print("退出符文装备")
		CommonFunc_SetWidgetTouch(mBackpackRoot,false)
		
			
	elseif strLayer == "UI_runeCharge" then
		LayerRuneCharge.onExit()
		if BackpackUIManage.IsLayerExist("UI_runeMain") == false then
			local node = mBackpackRoot:getChildByName("Panel_847")
			CommonFunc_SetWidgetTouch(node,true)
			BackpackUIManage.setBackpackTitle("我的背包")
			
		else
			
			
		end
		
		LayerBackpack.mod_BagLayer("equip")
	end
		
	
	
	
end


--判断该Layer是否存在
function BackpackUIManage.IsLayerExist(strLayer)
	for key,val in pairs(mStackTable) do
		if val.tag == strLayer then
			return true,val
		end
	end
	return false
end



---获得重新排列后的背包数据表"gemBag" "runeBag" "allBag"
function BackpackUIManage.getSortBagTable(index)
	local tempTable = {}
	local allBag = LayerBackpack.getTableItemAll()
	local _currentLayer,layerType = BackpackUIManage.getCurrentLayer()
	
	for key,val in pairs(allBag) do
		--print("itemtype",val.itemtype,"typeBag",typeBag,type(val.itemtype))
		
		if val.itemtype == item_type["gem"] and layerType == "gem" then
			table.insert(tempTable,val)
		
		elseif val.itemtype == item_type["sculpture"] and layerType == "rune" then
			if _currentLayer == "UI_runeCharge" then
				local runeID = LayerRuneCharge.getRuneID()
				--排除当前需要充能的符文
				if runeID ~= val.id then
					table.insert(tempTable,val)
				end
			else
				table.insert(tempTable,val)
			end
			
		end
		
	end
	
	if layerType == "gem" then
		
		local function sort_func_1(a,b) -- 按等级排序 --按售价
			local a_attr,a_base = ModelPlayer.getPackItemArr(a.id)
			local b_attr,b_base = ModelPlayer.getPackItemArr(b.id)
			
			--相同等级的宝石售价一样
			if a_base.sell_price == b_base.sell_price then
				return a_base.id > b_base.id
			else 
				return a_base.sell_price > b_base.sell_price
			end
		end
		
		local function sort_func_2(a,b) -- 按类型
			local a_attr,a_base = ModelPlayer.getPackItemArr(a.id)
			local b_attr,b_base = ModelPlayer.getPackItemArr(b.id)
			
			if a_attr.type == b_attr.type then
				return a_attr.id > b_attr.id
			else
				return a_attr.type > b_attr.type
			end
		end
		
		
		if index == 1 then
			table.sort(tempTable,sort_func_1)
		elseif index == 2 then
			table.sort(tempTable,sort_func_2)
		elseif index == 3 then
			table.sort(tempTable,sort_func_2)
		end
	
	
	--elseif _currentLayer == "UI_runePut" then
	elseif layerType == "rune" then
		local function sort_func_1(a,b) -- 按类型排序 
			local a_attr,a_base = ModelRune.getRuneAppendAttr(a.id)
			local b_attr,b_base = ModelRune.getRuneAppendAttr(b.id)
			
			if a_attr.skill_group == b_attr.skill_group then
				return a_attr.id > b_attr.id
			else
				return a_attr.skill_group > b_attr.skill_group
			end
		end
		
		local function sort_func_2(a,b) -- 按品质排序 
			local a_attr,a_base = ModelRune.getRuneAppendAttr(a.id)
			local b_attr,b_base = ModelRune.getRuneAppendAttr(b.id)
			
			if a_base.quality == b_base.quality then
				return a_base.id > b_base.id
			else
				return a_base.quality > b_base.quality
			end
		end
		
		local function sort_func_3(a,b) -- 按等级排序 
			local a_attr,a_base = ModelRune.getRuneAppendAttr(a.id)
			local b_attr,b_base = ModelRune.getRuneAppendAttr(b.id)
			
			if a_attr.level == b_attr.level then
				return a_attr.id > b_attr.id
			else
				return a_attr.level > b_attr.level
			end
		end
		
		local function sort_func_4(a,b) -- 按售价排序 
			local a_attr,a_base = ModelRune.getRuneAppendAttr(a.id)
			local b_attr,b_base = ModelRune.getRuneAppendAttr(b.id)
			
			if a_base.sell_price == b_base.sell_price then
				return a_base.id > b_base.id
			else
				return a_base.sell_price > b_base.sell_price
			end
		end
	
		if index == 1 then
			table.sort(tempTable,sort_func_1)
		elseif index == 2 then
			table.sort(tempTable,sort_func_2)
		elseif index == 3 then
			table.sort(tempTable,sort_func_3)
		elseif index == 4 then
			table.sort(tempTable,sort_func_4)
		end
	end
	
	return tempTable
end


------------------------------------------------------------------------------------


--发送 出售
function BackpackUIManage.callback_seed_sale_item(id,amount)
	local function seed_sale_item(param)
		--local id = param[1]
		--local amount = param[2]
		
		local tb = req_sale_item()
		tb.inst_id = id
		tb.amount = amount
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_sale_item_result"])
	end
	
	local structConfirm = {
				strText = "是否确定出售物品",
				buttonCount = 2,
				buttonEvent = {seed_sale_item,nil}, --回调函数
				buttonEvent_Param = {{id,amount},nil} --函数参数
			}
	UIManager.push("UI_ComfirmDialog",structConfirm)
end


--收到 售出
local function Handle_sale_item_result_msg(resp)	
	
	if resp.result == common_result["common_success"] then --成功
		--BackpackUIManage.removeAllUIlayer()
		
		CommonFunc_CreateDialog(string.format("成功售出,获得%d",resp.gold))
		local strLayer = BackpackUIManage.getCurrentLayer()
		BackpackUIManage.closeLayer(strLayer)
		LayerBackpack.setScrollViewData()
	--elseif resp.result == common_result["common_failed"] then 
		
	end
end


--发送 镶嵌宝石
function BackpackUIManage.seed_equipment_mountgem_result(gem_id)
	--判断是否符合镶嵌条件
	local equipment_id = LayerGemInlay.getCurrentEquipID()
	local addAttr = ModelEquip.getEquipRandomAttr(equipment_id)
	local gem_temp_id = ModelPlayer.findBagItemIdById(gem_id)
	print("gem_id:",gem_id,"gem_temp_id",gem_temp_id)
	local gem_type_2 = ModelGem.getGemAttr(gem_temp_id).type
	
	local structConfirm = {
		strText = ""
	}
	--判断同类型的宝石
	for key,val in pairs(addAttr.gems) do
		local gem_type_1 = ModelGem.getGemAttr(val).type
		if gem_type_1 == gem_type_2 then
			structConfirm.strText = "无法镶嵌同类型的宝石"
			
			UIManager.push("UI_ComfirmDialog",structConfirm)
			return
		end
	end
	
	local tb = req_equipment_mountgem()
	tb.equipment_id = equipment_id
	tb.gem_id = gem_id
	print("tb.equipment_id=",tb.equipment_id)
	print("tb.gem_id=",tb.gem_id)
	
	--
	BackpackUIManage.gemInlay.gem_id = gem_id
	
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_equipment_mountgem_result"])
	
end

--收到 镶嵌宝石
local function Handle_equipment_mountgem_result_msg(resp)	
	print("收到 镶嵌宝石",resp.mountgem_result)
	local structConfirm = {
		strText = ""
	}

	if resp.mountgem_result == common_result["common_success"] then --鎴愬姛
		structConfirm.strText = "镶嵌成功"

		LayerGemInlay.win_gemInlay()
	elseif resp.mountgem_result == common_result["common_failed"] then 
		structConfirm.strText = "镶嵌失败"	
	end
	
	BackpackUIManage.closeLayer("UI_gemInfo")
	UIManager.push("UI_ComfirmDialog",structConfirm)
end

--发送 卸下宝石
function BackpackUIManage.seed_gem_unmounted_result(gem_temp_id)
	--判断是否符合镶嵌条件
	local emoney = ModelGem.getGemAttr(gem_temp_id).unmounted_price
	if CommonFunc_IsConsume(emoney) == false then
		return false
	end
	
	local tb = req_gem_unmounted()
	tb.equipment_id = LayerGemInlay.getCurrentEquipID()
	tb.gem_temp_id = gem_temp_id
	
	print("tb.equipment_id=",tb.equipment_id)
	print("tb.gem_temp_id=",tb.gem_temp_id)
	
	--
	BackpackUIManage.gemInlay.gem_temp_id = gem_temp_id
	
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_gem_unmounted_result"])
end

local function Handle_gem_unmounted_result_msg(resp)	
	local structConfirm = {
		strText = "成功卸下",
		buttonCount = 0
	}
	
	if resp.result == common_result["common_success"] then --鎴愬姛
		LayerGemInlay.win_Gem_unmounted()
		BackpackUIManage.closeLayer("UI_gemInfo")
	elseif resp.result == common_result["common_failed"] then 
		structConfirm.strText = "卸下失败"
		
	end
	
	--更新控件	
	UIManager.push("UI_ComfirmDialog",structConfirm)
	
	
end



--注册卖出事件
NetSocket_registerHandler(NetMsgType["msg_notify_sale_item_result"], notify_sale_item_result(), Handle_sale_item_result_msg)


--注册镶嵌宝石事件
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_mountgem_result"], notify_equipment_mountgem_result(), Handle_equipment_mountgem_result_msg)

--注册卸下宝石事件
NetSocket_registerHandler(NetMsgType["msg_notify_gem_unmounted_result"], notify_gem_unmounted_result(), Handle_gem_unmounted_result_msg)