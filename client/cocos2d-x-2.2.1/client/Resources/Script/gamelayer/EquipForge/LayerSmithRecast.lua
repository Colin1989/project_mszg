----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-13
-- Brief:	铁匠铺主界面（装备重铸）
----------------------------------------------------------------------
local mLayerRoot = nil	-- 界面根节点
local m_eqData = nil		--当前选中装备的的装备信息
-- 材料是否足够
local m_bMaterialIsEnough = true
-- 不能重铸
local m_bCanRecast = true
-- 操作状态, 未重铸-"TYPE_NOTRECAST", 重铸-"TYPE_RECAST", 保存-"TYPE_SAVE"
local m_curType = "TYPE_NOTRECAST"
local m_tempData = nil
local m_tempData = nil
local mcurEquipList = nil			--当前身上装备的所有实例ID
local m_Index = 1			--当前选中的装备的Index

LayerSmithRecast = {}
LayerAbstract:extend(LayerSmithRecast)
-----------------------------------------界面动画-------------------------------------------------------------
--箭头的永久动画
local function arrowForeverAction()
	--箭头
	local arrow = tolua.cast(mLayerRoot:getChildByName("ImageView_arrow"), "UIImageView")
	local x = arrow:getPosition().x
	local y = arrow:getPosition().y
	
	-- 执行动作
	local function actionDone()
		arrow:setPosition(ccp(x - 15,y))
	end
	
    local arr = CCArray:create()
	local action1 = CCMoveTo:create(0.6,ccp(x + 15,y))
	arr:addObject(action1)
	--重复
	local action3 = CCRepeatForever:create(CCSequence:createWithTwoActions(CCSequence:create(arr), CCCallFunc:create(actionDone)))
	arrow:runAction(action3)
end
-------------------------------------------补齐材料---------------------------
-- 获取一键补齐表
local function getOneKeyTable()
	local equipRow = ModelEquip.getEquipRow(m_eqData.temp_id)
	local recastRow = LogicTable.getRecastNeedMaterialById(equipRow.recast_id)
	local tb = {}
	for k, v in pairs(recastRow) do
		local row = {}
		row.id = v.temp_id
		row.amount = tonumber(v.amount)
		
		table.insert(tb, row)
	end
	return tb
end

-- 重铸所需材料														--？？？？？？？？？不能重铸如何表现？？？？？
local function showNeedMaterialUI()
	m_bCanRecast = true
	local equipRow = ModelEquip.getEquipRow(m_eqData.temp_id)
	-- 不能重铸
	if 0 == equipRow.recast_id then
		m_bCanRecast = false
		cclog("不能重铸!")
		-- 所需费用
		local labelCoin = tolua.cast(mLayerRoot:getChildByName("label_coin"),"UILabel" )
		labelCoin:setText(tostring(0))
		--不能重铸的时候，补齐材料不能点击
		local completionBtn = mLayerRoot:getChildByName("Button_completion")
		local completionWord = completionBtn:getChildByName("ImageView_10479")
		Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		Lewis:spriteShaderEffect(completionWord:getVirtualRenderer(),"buff_gray.fsh",true)
		completionBtn:setTouchEnabled(false)
		return
	end
	
	local tb = LogicTable.getRecastNeedMaterialById(equipRow.recast_id)
	if tb == nil then
		m_bCanRecast = false
		cclog("不能重铸!")
		return
	end
	
	local isChange = false
	m_bMaterialIsEnough = true			-----？？？？？？？？？？？？
	for k = 1,#(tb),1 do
		local panel = mLayerRoot:getChildByName(string.format("materialImg_%d",k))
		panel:setVisible(true)
		
		--图片                       --？？？？？？？？？？有待修改
		local icon = panel:getChildByName("icon")
		CommonFunc_AddGirdWidget(tb[k].temp_id, 0, 0, nil, icon)

		--为图片添加长按事件
		icon:setTouchEnabled(true)
		-- 物品详细信息
		local function showItemDetailCall(icon)
			local position,direct = CommonFuncJudgeInfoPosition(icon)
			local tempTb = {}
			tempTb.itemId = tb[k].temp_id
			tempTb.position = position
			tempTb.direct = direct
			UIManager.push("UI_ItemInfo_Long",tempTb)
		end
		UIManager.registerEvent(icon, nil, showItemDetailCall, CommonFunc_longEnd_item)
		
		--材料名字
		local name = tolua.cast( panel:getChildByName("name"),"UILabel")
		local materialInfo = LogicTable.getItemById(tb[k].temp_id)
		name:setText(materialInfo.name)
		
		--数量
		local numLbl = tolua.cast( panel:getChildByName("num"),"UILabel")
		local num = ModelBackpack.getItemByTempId(tb[k].temp_id)
		num = (num == nil) and 0 or tonumber(num.amount)
		if num < tb[k].amount then
			m_bMaterialIsEnough = false
			numLbl:setColor(ccc3(255, 0, 0))
		else
			numLbl:setColor(ccc3(255, 255, 255))
		end
		numLbl:setText(string.format("%d/%d", num, tb[k].amount))
		
		if isChange == false then
			local completionBtn = mLayerRoot:getChildByName("Button_completion")
			local completionWord = completionBtn:getChildByName("ImageView_10479")
			if m_bMaterialIsEnough == true or not LayerOneKeyCompletion.isExists(getOneKeyTable()) then
				Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",true)
				Lewis:spriteShaderEffect(completionWord:getVirtualRenderer(),"buff_gray.fsh",true)
				completionBtn:setTouchEnabled(false)
			else
				isChange = true
				Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",false)
				Lewis:spriteShaderEffect(completionWord:getVirtualRenderer(),"buff_gray.fsh",false)
				completionBtn:setTouchEnabled(true)
			end
		end
	end
	
	-- 所需费用
	local coinNum = LogicTable.getRecastInfoById(m_eqData.temp_id).need_gold
	local labelCoin = tolua.cast(mLayerRoot:getChildByName("label_coin"),"UILabel" )
	labelCoin:setText(tostring(coinNum))
end

-- 一键补齐后刷新材料显示
local function handle_req_oneKeyForRecast(success)
	if nil == mLayerRoot then
		return
	end
	if false == success then
		return
	end
	cclog("---------------------------------->handle_req_oneKeyForRecast")
	showNeedMaterialUI()
end

EventCenter_subscribe(EventDef["ED_UPDATE_FOR_ONE_KEY"], handle_req_oneKeyForRecast)
------------------------------------------------重铸前后UI----------------------------------------
-- 显示重铸前装备UI
local function showBeforeRecastUI()
	-- data
	local equip, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfo(m_eqData.equipment_id)
	-- 随机武器属性(上限3个)
	local a, maxRandomAttr = ModelEquip.getRandomMfRuleRange(equip.mf_rule)
	m_randomWeaponAttr, m_valueType, m_value = CommonFunc_getAttrDescTable(randomEquip)
	local randomWeaponAttrName = {"label_pro1", "label_pro2", "label_pro3"}
	--Log(equip, maxRandomAttr, m_randomWeaponAttr)
	for i = 1, 3 do
		local labelRandomWeaponAttr = CommonFunc_getLabelByName(mLayerRoot, randomWeaponAttrName[i])	
		if nil == m_randomWeaponAttr[i] then
			labelRandomWeaponAttr:setVisible(false)
		else
			labelRandomWeaponAttr:setVisible(true)
			local maxAttrInfo = ModelEquip.getRandomAttrInfo(maxRandomAttr[i])
			Log("---------------------------- i: "..i, maxAttrInfo)
			labelRandomWeaponAttr:setText(string.format("%s(%s)", m_randomWeaponAttr[i], maxAttrInfo.attr_value))
		end
	end
	-- 战斗力
	local labelAtlasPower = CommonFunc_getNodeByName(mLayerRoot, "label_power1", "UILabel")
	labelAtlasPower:setText(tostring(equip.combat_effectiveness))
	
end

-- 获取锻造前type属性的值
local function getProValByType(type)
	for k = 1, #(m_valueType), 1 do
		if tostring(type) == tostring(m_valueType[k]) then
			return tonumber(m_value[k])
		end
	end
	
	return nil
end

-- 显示重铸后装备UI
LayerSmithRecast.showAfterRecastUI = function()
	-- data
	local equip, baseEquip, strengthenEquip, randomEquip, gemEquip = ModelEquip.getEquipInfoEx(m_tempData)
	-- 随机武器属性(上限3个) -- 属性字符串, 增加的属性值, 升降指示标记图
	local _, maxRandomAttr = ModelEquip.getRandomMfRuleRange(equip.mf_rule)
	m_tmpRandomWeaponAttr, m_tmpValueType, m_tmpValue = CommonFunc_getAttrDescTable(randomEquip)
	local randomWeaponAttrName = {"label_pro5", "label_pro6", "label_pro7"}
	
	for i = 1, 3 do
		-- 属性字符串
		local labelRandomWeaponAttr = CommonFunc_getLabelByName(mLayerRoot, randomWeaponAttrName[i])	
		if nil == m_tmpRandomWeaponAttr[i] then
			labelRandomWeaponAttr:setVisible(false)
		else
			labelRandomWeaponAttr:setVisible(true)
			local maxAttrInfo = ModelEquip.getRandomAttrInfo(maxRandomAttr[i])
			local str = string.format("%s(%s)", m_tmpRandomWeaponAttr[i], maxAttrInfo.attr_value)
			labelRandomWeaponAttr:setText(str)
		end
	end
	-- 战斗力
	local labelAtlasPower = CommonFunc_getNodeByName(mLayerRoot, "labelAtlas_power2", "UILabel")
	labelAtlasPower:setText(tostring(equip.combat_effectiveness))
	local equip1 = ModelEquip.getEquipInfo(m_eqData.equipment_id)
	local powerOffset = tonumber(equip.combat_effectiveness) - tonumber(equip1.combat_effectiveness)
	
	-- 遮挡
	local imgBg2 = CommonFunc_getNodeByName(mLayerRoot, "img_bg_after") 
	local imgShielder = CommonFunc_getNodeByName(mLayerRoot, "img_not_tips")  
	-- 初始化未重铸
	if m_curType == "TYPE_NOTRECAST" then
		imgBg2:setVisible(false)
		imgShielder:setVisible(true)
	-- 重铸中
	elseif m_curType == "TYPE_RECAST" then
		imgBg2:setVisible(true)
		imgShielder:setVisible(false)
	-- 保存状态	
	elseif m_curType == "TYPE_SAVE" then
		imgBg2:setVisible(false)
		imgShielder:setVisible(true)
	end
end
----------------------------------------------------------点击事件----------------------------------------------
-- 点击补齐材料按钮
local function clickCompletionBtn(typeName, widget)
	if "releaseUp" == typeName then
		local tb = getOneKeyTable()
		UIManager.push("UI_OneKeyCompletion", tb)
	end
end

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	-- 重铸
	if sender:getName() == "btn_recast" then 
		if not m_bCanRecast then
			Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL_CANNOT_RECAST_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		-- 材料不足
		if not m_bMaterialIsEnough then
			Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_FAIL1_NOT_MATERIAL_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		-- 金币不足
		local coinNum = LogicTable.getRecastInfoById(m_eqData.temp_id).need_gold
		if CommonFunc_payConsume(1, coinNum) then
			return
		end
		
		local tb = req_equipment_recast()
		tb.inst_id = m_eqData.equipment_id
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_equipment_recast_result"]) 
	-- 保存结果
	elseif sender:getName() == "btn_save" then 
		if m_curType == "TYPE_NOTRECAST" then
			Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_RECAST_FIRST_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		
		local tb = req_save_recast_info()
		tb.equipment_id = m_eqData.equipment_id
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_save_recast_info_result"]) 
	end	
end

local function pubClick(widget)
	local widgetName = widget:getName()
	local index =string.sub(widgetName,-1,-1)
	m_eqData = ModelEquip.getEquipInfo(mcurEquipList[tonumber(index)])
	m_Index = index
	
	local scrollView = tolua.cast(mLayerRoot:getChildByName("ScrollView_recast"), "UIScrollView")
	for i = 1,6 do
		local selectImg = tolua.cast(scrollView:getChildByName(string.format("selectBg_%d",i)), "UIImageView")
		selectImg:setVisible(false)
	end
	
	local selectImg = tolua.cast(scrollView:getChildByName(string.format("selectBg_%d",index)), "UIImageView")
	selectImg:setVisible(true)
	
	LayerSmithRecast.initUI()
end

--点击装备图片
local function clickEquipt(widget)
	pubClick(widget)
end

--点击没有的装备的图片
local function noEquipClick(types,widget)
	if types == "releaseUp" then
		pubClick(widget)
	end
end

------------------------------------------------------------------------------------------
-- 初始化静态UI
LayerSmithRecast.initUI = function()
	m_curType = "TYPE_NOTRECAST"
	m_tempData = m_eqData
	
	local img_noEquip = tolua.cast(mLayerRoot:getChildByName("Img_noEquip"), "UIImageView")
	local lbl_noEquip = tolua.cast(mLayerRoot:getChildByName("Label_get"), "UILabel")
	local img_hasEquip = tolua.cast(mLayerRoot:getChildByName("Img_hasEquip"), "UIImageView")
	if nil == m_eqData then
		img_noEquip:setVisible(true)
		lbl_noEquip:setVisible(true)
		local getText = GameString.get("EQUIPTRAIN_GET_01")
		if tonumber(m_Index) >= 1 and tonumber(m_Index) <= 4 then
			getText = GameString.get("EQUIPTRAIN_GET_01")
			img_noEquip:loadTexture("text_weizhuangbei.png")
		elseif tonumber(m_Index) == 5 then
			getText = GameString.get("EQUIPTRAIN_GET_02")
			img_noEquip:loadTexture("text_wufachongzhu.png")
			lbl_noEquip:setVisible(false)
		elseif tonumber(m_Index) == 6 then
			getText = GameString.get("EQUIPTRAIN_GET_03")
			img_noEquip:loadTexture("text_weizhuangbei.png")
		end
		lbl_noEquip:setText(getText)
		img_hasEquip:setVisible(false)
	elseif tonumber(m_Index) == 5 then
		img_noEquip:setVisible(true)
		lbl_noEquip:setVisible(false)
		img_noEquip:loadTexture("text_wufachongzhu.png")
		img_hasEquip:setVisible(false)
	else
		img_noEquip:setVisible(false)
		lbl_noEquip:setVisible(false)
		img_hasEquip:setVisible(true)
		-- 开始重铸
		local btnRecast = CommonFunc_getNodeByName(mLayerRoot, "btn_recast", "UIButton")
		btnRecast:registerEventScript(btnCall)
		-- 保存结果
		local btnSave = CommonFunc_getNodeByName(mLayerRoot, "btn_save", "UIButton")
		btnSave:registerEventScript(btnCall)
		-- 补齐材料
		local completionBtn = mLayerRoot:getChildByName("Button_completion")
		completionBtn:registerEventScript(clickCompletionBtn)
		
		for k = 1,3,1 do
			local panel = mLayerRoot:getChildByName(string.format("materialImg_%d",k))
			panel:setVisible(false)
		end
						
		-- 重铸所需材料
		showNeedMaterialUI()
		
		-- 显示重铸前装备UI
		showBeforeRecastUI()
		-- 显示重铸后装备UI
		LayerSmithRecast.showAfterRecastUI()
	
	end
	
	
end
----------------------------------------------------------------------
LayerSmithRecast.init = function(rootView)
	mLayerRoot = rootView
	

	arrowForeverAction()		
	
	--创建装备列表
	local scrollView = tolua.cast(mLayerRoot:getChildByName("ScrollView_recast"), "UIScrollView")
	mcurEquipList = ModelEquip.getCurrEquipList()
	local data = {}
	for i= 1,6,1 do
		local ItemData = {}
		if nil == mcurEquipList[i] then
			ItemData.icon = string.format("equip_none_0%d.png",i)
		else
			ItemData.instId = mcurEquipList[i]
		end
		ItemData.index = i
		table.insert(data,ItemData)
	end
	
	--创建列表单元格
	local function createCell(ItemData)
		local cellBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(84,84), "touming.png", "bg",1 )
		local selectBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(172,172), "firpiont_bg2_hover.png",
				string.format("selectBg_%d",ItemData.index),1 )
		selectBg:setScale(0.9)
		selectBg:setVisible(false)
		cellBg:addChild(selectBg)
		local iconBg
		if nil == ItemData.instId then
			iconBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(84,84),
			string.format("equip_none_0%d.png",ItemData.index), string.format("equip_%d",ItemData.index),1 )
			iconBg:registerEventScript(noEquipClick)
		else
			local equip, baseEquip, strenghenEquip = ModelEquip.getEquipInfo(ItemData.instId) -- ItemData.instId 装备的实例id
			local itemRow = LogicTable.getItemById(equip.id)    --equip.id 装备模板id
			iconBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(84,84), "touming.png", "bg",1 )
			CommonFunc_AddGirdWidget(equip.id, 1, equip.strengthen_level, nil, iconBg)	
			iconBg:setTag(equip.id)
			iconBg:setName(string.format("equip_%d",ItemData.index))
			--长按事件 --点击事件
			-- 物品详细信息
			local function showItemDetailCall(cellBg)
				local position,direct = CommonFuncJudgeInfoPosition(cellBg)
				local tb = {}
				tb.instId = ItemData.instId
				tb.itemId = equip.id
				tb.position = position
				tb.direct = direct
				UIManager.push("UI_EquipInfo",tb)
			end
			UIManager.registerEvent(iconBg, clickEquipt, showItemDetailCall, CommonFunc_longEnd_equip)
		end
		iconBg:setTouchEnabled(true)
		cellBg:addChild(iconBg)
		if ItemData.index == m_Index then
			selectBg:setVisible(true)
		end
		return cellBg
	end
	UIEasyScrollView:create(scrollView,data,createCell,6, true,4,1,false,100)
	
	m_eqData = ModelEquip.getEquipInfo(mcurEquipList[1])
	LayerSmithRecast.initUI()
	--TipModule.onUI(root, "ui_equipforgerecast")
		
end
----------------------------------------------------------------------
LayerSmithRecast.destroy = function()
   mLayerRoot = nil
   mcurEquipList = nil	
   m_Index = 1
end 

------------------------------------------------------网络信息------------------------
-- 重铸rec
local function handle_req_equipRecast(resp)

	if resp.result ~= common_result["common_success"] then
		return
	end
	Toast.Textstrokeshow(GameString.get("EQUIPTRAIN_SUCCESS1_TIPS"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	m_tempData = resp.new_info
	m_curType = "TYPE_RECAST"
	-- 重铸所需材料
	showNeedMaterialUI()
	-- 显示重铸后装备UI
	LayerSmithRecast.showAfterRecastUI()	
	
	--播放重铸成功动画
	--playRecastAction()
end

-- 保存重铸rec
local function handle_req_equipRecastSave(resp)
	if resp.result ~= common_result["common_success"] then
		return
	end
	ModelEquip.replaceEquipInfo(m_tempData)
	m_curType = "TYPE_NOTRECAST"
	-- 重铸所需材料
	showNeedMaterialUI()
	-- 显示重铸前装备UI
	showBeforeRecastUI()
	-- 显示重铸后装备UI
	LayerSmithRecast.showAfterRecastUI()
end

-- 重铸
NetSocket_registerHandler(NetMsgType["msg_notify_equipment_recast_result"], notify_equipment_recast_result, handle_req_equipRecast)
-- 保存重铸
NetSocket_registerHandler(NetMsgType["msg_notify_save_recast_info_result"], notify_save_recast_info_result, handle_req_equipRecastSave)

