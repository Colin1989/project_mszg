----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-13
-- Brief:	铁匠铺主界面（宝石镶嵌）
----------------------------------------------------------------------
local mLayerRoot = nil	-- 界面根节点
local mcurEquipList = nil			--当前身上装备的所有实例ID
local m_eqData = nil		--当前选中装备的的装备信息
local m_Index = 1			--当前选中的装备的Index

LayerSmithGemInlay = {}
LayerAbstract:extend(LayerSmithGemInlay)

-------------------------------------------------------------------------------
--点击卸下宝石
local function clickUnloadGem(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		widget:setTouchEnabled(false)
		local widgetName = widget:getName()
		local index =tonumber(string.sub(widgetName,-1,-1))
		
		for i = 1,3,1 do
			local gemPanel = tolua.cast(mLayerRoot:getChildByName(string.format("Panel_Gem_%d",i)), "UILayout")
			local unloadBtn = tolua.cast(gemPanel:getChildByName(string.format("unload_%d",i)), "UIButton")
			unloadBtn:setTouchEnabled(false)
		end
		
		BackpackLogic.requestGemUnmounted(m_eqData.equipment_id, m_eqData.gems[index])
	end
end
--------------------------------------------------------------------
--初始化宝石信息
local function initGemInfo()

	local Img_noEquip = tolua.cast(mLayerRoot:getChildByName("Img_noEquip"), "UIImageView")
	local lbl_noEquip = tolua.cast(mLayerRoot:getChildByName("Label_get"), "UILabel")
	local Panel_hasEquip = tolua.cast(mLayerRoot:getChildByName("Panel_hasEquip"), "UILayout")

	m_eqData = ModelEquip.getEquipInfo(mcurEquipList[m_Index])
	if nil == m_eqData then
		Img_noEquip:setVisible(true)
		lbl_noEquip:setVisible(true)
		
		local getText = GameString.get("EQUIPTRAIN_GET_01")
		if m_Index >= 1 and m_Index <= 4 then
			getText = GameString.get("EQUIPTRAIN_GET_01")
		elseif m_Index == 5 then
			getText = GameString.get("EQUIPTRAIN_GET_02")
		elseif m_Index == 6 then
			getText = GameString.get("EQUIPTRAIN_GET_03")
		end
		lbl_noEquip:setText(getText)
		
		Panel_hasEquip:setVisible(false)
	else
		Img_noEquip:setVisible(false)
		lbl_noEquip:setVisible(false)
		Panel_hasEquip:setVisible(true)
		local holeNum = m_eqData.gem_trough			--装备孔的个数
		local gemIds = m_eqData.gems				--装备中的宝石ID
		
		for i= 1,3,1 do
			local holePanel = tolua.cast(mLayerRoot:getChildByName(string.format("Panel_%d",i)), "UILayout")
			holePanel:setVisible(false)
		end

		for i = 1,holeNum,1 do
			--显示孔的个数
			local holePanel = tolua.cast(mLayerRoot:getChildByName(string.format("Panel_%d",i)), "UILayout")
			holePanel:setVisible(true)
			--镶嵌了宝石的panel
			local gemPanel = tolua.cast(mLayerRoot:getChildByName(string.format("Panel_Gem_%d",i)), "UILayout")
			--没有镶嵌宝石的情况
			local noGemPanel =  tolua.cast(mLayerRoot:getChildByName(string.format("bg_noInlay_%d",i)), "UILayout")
			if  nil == gemIds[i] then
				gemPanel:setVisible(false)
				noGemPanel:setVisible(true)
			else
				gemPanel:setVisible(true)
				noGemPanel:setVisible(false)
				--镶嵌了的宝石Id
				local gemId = gemIds[i]
				local baseAttr = LogicTable.getItemById(gemId)
				local gemAttr = ModelGem.getGemAttrRow(baseAttr.sub_id)
				
				--图片
				local icon = tolua.cast(gemPanel:getChildByName(string.format("ImageView_head_%d",i)), "UIImageView")
				CommonFunc_AddGirdWidget(baseAttr.id, 1, nil, nil, icon)
				--名字
				local nameLabel = tolua.cast(gemPanel:getChildByName(string.format("name_%d",i)), "UILabel")
				nameLabel:setText(gemAttr.name)
				--卸下
				local unloadBtn = tolua.cast(gemPanel:getChildByName(string.format("unload_%d",i)), "UIButton")
				unloadBtn:setTouchEnabled(true)
				unloadBtn:registerEventScript(clickUnloadGem)
				--宝石的属性
				local strGemAttrValue = CommonFunc_getAttrDescTable(gemAttr)
				local att = tolua.cast(gemPanel:getChildByName(string.format("att_%d",i)), "UILabel")
				att:setText(strGemAttrValue[1])
			end	
		end
	end
end
-------------------------------------------------点击事件--------------------------------------
--点击宝石图片
local function clickGem(widget)
	TipModule.onClick(widget)
	local widgetName = widget:getName()
	
	local index = tonumber(string.sub(widgetName,string.len("gem_grid_")+1,string.len(widgetName)))
	local tb = {}
	tb.temp_id =  ModelBackpack.getPackGem()[tonumber(index)].itemid
	tb.equipInfo = m_eqData
	tb.instId = ModelBackpack.getPackGem()[tonumber(index)].id
	UIManager.push("UI_Smith_GemInlayInfo",tb)
end

local function pubClick(widget)
	local widgetName = widget:getName()
	local index = tonumber(string.sub(widgetName,7,string.len(widgetName)))
	
	m_eqData = ModelEquip.getEquipInfo(mcurEquipList[tonumber(index)])
	m_Index = index
	
	local scrollView = tolua.cast(mLayerRoot:getChildByName("ScrollView_GemInlay"), "UIScrollView")
	for i = 1,6 do
		local selectImg = tolua.cast(scrollView:getChildByName(string.format("selectBg_%d",i)), "UIImageView")
		selectImg:setVisible(false)
	end
	
	local selectImg = tolua.cast(scrollView:getChildByName(string.format("selectBg_%d",m_Index)), "UIImageView")
	selectImg:setVisible(true)
	
	initGemInfo()
end

--点击装备图片
local function clickEquipt(widget)
	TipModule.onClick(widget)
	pubClick(widget)
end

--点击没有的装备的图片
local function noEquipClick(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		pubClick(widget)
	end
end

----------------------------------------------------------------------------
--创建装备列表
local function createEquipList()
	local scrollView = tolua.cast(mLayerRoot:getChildByName("ScrollView_GemInlay"), "UIScrollView")
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
	UIEasyScrollView:create(scrollView,data,createCell,6, true,6,1,false,100)
end

--创建宝石列表
local function crerateGemList()
	local scrollViewGem = tolua.cast(mLayerRoot:getChildByName("ScrollView_Gem"), "UIScrollView")
	local gemData = ModelBackpack.getPackGem()
	if #gemData == 0 then
		return
	end
	local data = {}
	for key,val in pairs(gemData) do
		local ItemData =val
		ItemData.index = key
		table.insert(data,ItemData)
	end
	
	
	--创建列表单元格
	local function createCell(celll,ItemData,index)
		local cellBg = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(0,0), CCSizeMake(84,84), "touming.png", "bg",1 )
		CommonFunc_AddGirdWidget(ItemData.itemid, ItemData.amount, 0, nil, cellBg)	
		cellBg:setTag(ItemData.itemid)
		cellBg:setName(string.format("gem_grid_%d",ItemData.index))
		cellBg:setTouchEnabled(true)
		--长按事件 --点击事件									--????????有待添加
			-- 物品详细信息
			local function showItemDetailCall(cellBg)
				local position,direct = CommonFuncJudgeInfoPosition(cellBg)
				local tb = {}
				tb.itemId = ItemData.itemid
				tb.position = position
				tb.direct = direct
				
				UIManager.push("UI_GemInfo_Long",tb)
			end
			UIManager.registerEvent(cellBg, clickGem, showItemDetailCall, CommonFunc_longEnd_gem)
		return cellBg
	end
	UIScrollViewEx.show(scrollViewGem,data,createCell,"V",84, 90,5,5,3,true,nil,true,true)
end
----------------------------------------------------------------------
--初始化宝石信息
LayerSmithGemInlay.initUI = function()
	if mLayerRoot == nil then
		return
	end
	
	mcurEquipList = ModelEquip.getCurrEquipList()

	--创建装备列表
	createEquipList()
	
	crerateGemList()
  
	initGemInfo()

end
----------------------------------------------------------------------
LayerSmithGemInlay.init = function(rootView)
	mLayerRoot = rootView
	
	LayerSmithGemInlay.initUI()
	TipModule.onUI(rootView, "ui_smithgeminlay")
end
----------------------------------------------------------------------
LayerSmithGemInlay.destroy = function()
   mLayerRoot = nil
   mcurEquipList = nil		
   m_Index = 1
end
----------------------------------------------------------------------
-- 获取第一个宝石的控件名
LayerSmithGemInlay.getGemWidgetName = function()
	local gemData = ModelBackpack.getPackGem()
	for key, val in pairs(gemData) do
		local widgetName = "gem_grid_"..key
		if tolua.cast(mLayerRoot:getChildByName(widgetName), "UIImageView") then
			return widgetName
		end
	end
end
----------------------------------------------------------------------=======
----------------------------------------------------------------------
--设置默认选中的装备
LayerSmithGemInlay.setIndex = function (index)
	m_Index = index
end
