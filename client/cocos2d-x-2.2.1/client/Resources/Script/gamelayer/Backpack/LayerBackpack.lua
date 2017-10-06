----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-1-21
-- 描述：主界面->背包子界面  不用继承Abstract 因为不属于UI跟节点
----------------------------------------------------------------------
LayerBackpack = {}

local mUILayerRetain = {}
local mUILayerData = {["all"] = {}, ["up"] = {}, ["down"] = {}}
local mLayerRoot = nil				-- 界面根节点
local mPanelUp = nil				-- 上面界面根节点
local mPanelDown = nil				-- 下面界面根节点
local mFighting = 0					-- 战斗力改变值
local mNewAppendEquips = {}			-- 新增装备信息
local mListenNewAppendEquip = true	-- 监听新增装备信息

-- addPosition加载位置
local UILayerNameTable = {
	["UI_equip_body"] = {				-- 身上装备
		jsonFile = "Backpack_body_equip.json",
		tb = LayerEquipBody,
		addPosition = "up"
	},
	["UI_Bag"] = {						-- 背包信息
		jsonFile = nil,
		tb = nil,
		addPosition = "down"
	},
	["UI_playerInfo"] = {				-- 玩家信息
		jsonFile = "Backpack_Player.json",
		tb = LayerPlayerInfo,
		addPosition = "down"
	},
	["UI_skillInfo"] = {				-- 技能信息
		jsonFile = "Backpack_Skill.json",
		tb = LayerBagSkill,
		addPosition = "down"
	},
	["UI_gemCompound"] = {				-- 宝石合成
		jsonFile = "Backpack_Gem_Compound.json",
		tb = LayerGemCompound,
		addPosition = "up"
	},
	--[[
	["UI_gemCompound"] = {				-- 宝石合成
		jsonFile = "Gem_Compound.json",
		tb = LayerGemCompound,
		addPosition = "all"
	},
	["UI_gemInlay"] = {					-- 宝石镶嵌
		jsonFile = "Gem_Inlay.json",
		tb = LayerGemInlay,
		addPosition = "up"
	},
	["UI_strengthen"] = {				-- 装备强化
		jsonFile = "Backpack_Strengthen.json",
		tb = LayerStrengthen,
		addPosition = "all"
	},
	["UI_equip_info_new"] = {			-- 装备信息
		jsonFile = "Backpack_Equip_01.json",
		tb = LayerEquipInfo_01,
		addPosition = "up"
	},
	
	["UI_gem_info_new"] = {				-- 宝石信息
		jsonFile = "GemInfo_01.json",
		tb = LayerGemInfo_01,
		addPosition = "up"
	},
	
	]]--
	
	["UI_equip_comparison"] = {			-- 装备对比信息
		jsonFile = "Backpack_Equip_03.json",
		tb = LayerEquipInfo_03,
		addPosition = "all"
	},
	["UI_item_info_new"] = {			-- 物品信息
		jsonFile = "ItemInfo_01.json",
		tb = LayerItemInfo_01,
		addPosition = "up"
	}
}

local function createUILayer(jsonFile)
	if nil == mUILayerRetain[jsonFile] then
		local jsonRoot = GUIReader:shareReader():widgetFromJsonFile(jsonFile)
		jsonRoot:setVisible(false)
		jsonRoot:setTouchEnabled(false)
		mUILayerRetain[jsonFile] = jsonRoot
	end
	local widget = mUILayerRetain[jsonFile]:clone()
	mUILayerRetain[jsonFile]:retain()
	widget:setVisible(true)
	widget:setTouchEnabled(true)
	return widget
end

-- 删除指定位置的界面
local function deleteUILayer(position, newLayerName, doAction)
	if nil == mLayerRoot or nil == mUILayerData then
		return
	end
	local data = mUILayerData[position]
	if nil == data then
		return
	end
	mUILayerData[position] = nil
	if "table" == type(data.tb) and "function" == type(data.tb.destroy) then
		data.tb.destroy(newLayerName)
	end
	local function callbackDelLayer()
		if data.layer then
			data.layer:removeFromParent()
		end
	end
	if true == doAction and "table" == type(data.tb) and "function" == type(data.tb.Action_onExit) then
		data.tb.Action_onExit(callbackDelLayer)
	else
		callbackDelLayer()
	end
end

-- 切换界面
function LayerBackpack.switchUILayer(layerName, param)
	if nil == mLayerRoot or nil == mUILayerData then
		return
	end
	local val = UILayerNameTable[layerName]
	local position = val.addPosition
	-- 删除之前的界面
	deleteUILayer("all", layerName, true)
	if "up" == position then
		deleteUILayer("up", layerName, true)
	elseif "down" == position then
		deleteUILayer("down", layerName, true)
	end
	if nil == val.jsonFile then
		return
	end
	-- 创建
	local widget = createUILayer(val.jsonFile)
	widget:setZOrder(2)
	mUILayerData[position] = {layer=widget, tb=val.tb, layerName=layerName}
	-- 设置位置
	if "all" == position then
		mPanelUp:setVisible(false)
		mPanelDown:setVisible(false)
		mLayerRoot:addChild(widget)
	else
		mPanelUp:setVisible(true)
		mPanelDown:setVisible(true)
		if "up" == position then
			mPanelUp:addChild(widget)
		elseif "down" == position then
			mPanelDown:addChild(widget)
		end
	end
	-- 调用初始函数
	if "function" == type(val.tb.init) then
		val.tb.init(widget, param)
	end
	-- 执行过场动作
	if "function" == type(val.tb.Action_onEnter) then
		val.tb.Action_onEnter()
	else
		local pos = CommonFunc_GetPos(widget)
		if "all" == position then
			widget:setPosition(ccp(pos.x, pos.y + 500))
			Animation_MoveTo_Rebound(widget, 0.5, pos)
		elseif "up" == position then
			-- 默认左移动画
			widget:setPosition(ccp(pos.x + 500, pos.y))
			Animation_MoveTo_Rebound(widget, 0.6, pos)
		end
	end
end

-- 获得当前层名字
function LayerBackpack.getUILayerName(position)
	if nil == mLayerRoot or nil == mUILayerData then
		return nil
	end
	local data = mUILayerData[position]
	if nil == data then 
		return nil
	end
	return data.layerName
end

-- 设置标签状态
local function setTagButtonStatus(btnName)
	local btnNameTb = {"Button_Hero", "Button_Skill", "Button_Equip", "Button_Gem", "Button_Item"}
	local normalBtnPngTb = {"herobag_buttom_d.png", "herobag_buttom_d.png", "herobag_buttom_d.png", "herobag_buttom_d.png", "herobag_buttom_d.png"}
	local activeBtnPngTb = {"herobag_buttom_h.png", "herobag_buttom_h.png", "herobag_buttom_h.png", "herobag_buttom_h.png", "herobag_buttom_h.png"}
	local normalNamePngTb = {"herobag_text_hero_d.png", "herobag_text_skill_d.png", "herobag_text_equipment_d.png", "herobag_text_gem_d.png", "herobag_text_item_d.png"}
	local activeNamePngTb = {"herobag_text_hero_h.png", "herobag_text_skill_h.png", "herobag_text_equipment_h.png", "herobag_text_gem_h.png", "herobag_text_item_h.png"}
	for key, val in pairs(btnNameTb) do
		local btn = tolua.cast(mLayerRoot:getChildByName(val), "UIButton")
		local label = tolua.cast(btn:getChildByName("Label_btnName"), "UIImageView")
		local btnTexture = nil
		local nameTexture = nil
		if btnName == val then				-- 按钮选中状态
			btnTexture = activeBtnPngTb[key]
			btn:setTouchEnabled(false)
			btn:setTag(1)
			nameTexture = activeNamePngTb[key]
			label:setPosition(ccp(0, 23))
		else								-- 按钮非选中状态
			btnTexture = normalBtnPngTb[key]
			btn:setTouchEnabled(true)
			btn:setTag(0)
			nameTexture = normalNamePngTb[key]
			label:setPosition(ccp(0, 25))
		end
		btn:loadTextures(btnTexture, btnTexture, btnTexture)
		label:loadTexture(nameTexture)
	end
end

-- 切换标签(模拟点击标签按钮)
local function changeTag(btnName, isClick)
	if nil == mLayerRoot then
		return
	end
	setTagButtonStatus(btnName)
	if true == isClick then
		LayerBackpack.switchUILayer("UI_equip_body")
	end
	if "Button_Hero" == btnName then
		LayerBackpack.switchUILayer("UI_playerInfo")
	elseif "Button_Skill" == btnName then
		LayerBackpack.switchUILayer("UI_skillInfo")
	else
		LayerBackpack.switchUILayer("UI_Bag")
		if "Button_Equip" == btnName then
			LayerBag.switchBag("equip")
		elseif "Button_Gem" == btnName then
			LayerBag.switchBag("gem")

			--Log(LayerBag.getGemData())
			local param = {}
			param.id = LayerBag.getGemData()[1].id or 0
			if tonumber(LayerBag.getGemData()[1].itemtype) ~= 3 then
				param.itemtype =  0
			else
				param.itemtype = LayerBag.getGemData()[1].itemtype 
			end
			
			LayerBackpack.switchUILayer("UI_gemCompound",param)
		elseif "Button_Item" == btnName then
			LayerBag.switchBag("item")
		end
	end
end

-- 点击英雄按钮
local function clickHeroButton(typeName, widget)
	if "releaseUp" ~= typeName or 1 == widget:getTag() then
		return
	end
	TipModule.onClick(widget)
	changeTag(widget:getName(), true)
end

-- 点击技能按钮
local function clickSkillButton(typeName, widget)
	if "releaseUp" ~= typeName or 1 == widget:getTag() then
		return
	end
	TipModule.onClick(widget)
	changeTag(widget:getName(), true)
end

-- 点击装备按钮
local function clickEquipButton(typeName, widget)
	if "releaseUp" ~= typeName or 1 == widget:getTag() then
		return
	end
	TipModule.onClick(widget)
	changeTag(widget:getName(), true)
end

-- 点击宝石按钮
local function clickGemButton(typeName, widget)
	if "releaseUp" ~= typeName or 1 == widget:getTag() then
		return
	end
	TipModule.onClick(widget)
	changeTag(widget:getName(), true)
end

-- 点击物品按钮
local function clickItemButton(typeName, widget)
	if "releaseUp" ~= typeName or 1 == widget:getTag() then
		return
	end
	TipModule.onClick(widget)
	changeTag(widget:getName(), true)
end

-- 初始化
function LayerBackpack.init(root, param)
	mUILayerData = {["all"] = {}, ["up"] = {}, ["down"] = {}}
	mLayerRoot = root
	mPanelUp = root:getChildByName("Panel_up")
	mPanelDown = root:getChildByName("Panel_dwon")
	-- 英雄按钮
	local heroBtn = root:getChildByName("Button_Hero")
	heroBtn:registerEventScript(clickHeroButton)
	heroBtn:setTag(0)
	-- 技能按钮
	local skillBtn = root:getChildByName("Button_Skill")
	skillBtn:registerEventScript(clickSkillButton)
	skillBtn:setTag(0)
	-- 装备按钮
	local equipBtn = root:getChildByName("Button_Equip")
	equipBtn:registerEventScript(clickEquipButton)
	equipBtn:setTag(0)
	-- 宝石按钮
	local gemBtn = root:getChildByName("Button_Gem")
	gemBtn:registerEventScript(clickGemButton)
	gemBtn:setTag(0)
	-- 物品按钮
	local itemBtn = root:getChildByName("Button_Item")
	itemBtn:registerEventScript(clickItemButton)
	itemBtn:setTag(0)
	-- 创建背包界面
	local bagLayerRoot = LoadWidgetFromJsonFile("Backpack_Bag.json")
	LayerBag.init(bagLayerRoot)
	mPanelDown:addChild(bagLayerRoot)
	-- 初始化标签
	changeTag("Button_Hero", true)
	-- 玩家动画
	local role_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel())
	local role_Ani = ResourceManger.getAnimationFrameById(role_tplt.icon)
	ResourceManger.LoadSinglePicture(role_Ani.name)	
	local strPath = string.format("%s_%s", role_Ani.name, role_Ani.wait).."_%03d.png"
	local playerNode = createAnimation_forever(strPath, role_Ani.wait_frame, 0.1)
	local node = root:getChildByName("ImageView_Hero")
	node:setScale(1.4)
	node:getVirtualRenderer():removeAllChildrenWithCleanup(true)
	node:addRenderer(playerNode, 0)
	-- 加载特效资源
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("effect_063u.plist")
	mListenNewAppendEquip = false
	LayerBackpack.showNewAppenEquipTip()
	TipModule.onUI(root, "ui_backpack")
end

-- 销毁
function LayerBackpack.destroy()
	LayerBag.destroy()
	for key, val in pairs(mUILayerData) do
		deleteUILayer(key, nil, false)
	end
	mUILayerData = nil
	mLayerRoot = nil
	mPanelUp = nil
	mPanelDown = nil
	mListenNewAppendEquip = true
	mNewAppendEquips = {}
	LayerMain.showNewAppenEquipTip()
end

-- 获取背包根节点
function LayerBackpack.getRoot()
	return mLayerRoot
end

-- 切换标签按钮
function LayerBackpack.switchTag(btnName)
	changeTag(btnName)
end

-- 返回技能标签页
function LayerBackpack.returnSkillUI()
	UIManager.retrunMain("bag")
	changeTag("Button_Skill")
end

-- 返回装备标签页
function LayerBackpack.returnEquipUI()
	UIManager.retrunMain("bag")
	changeTag("Button_Equip")
end

-- 返回宝石标签页
function LayerBackpack.returnGemUI()
	UIManager.retrunMain("bag")
	changeTag("Button_Gem")
end

-- 返回物品标签页
function LayerBackpack.returnItemUI()
	UIManager.retrunMain("bag")
	changeTag("Button_Item")
end

-- 战斗力飘字
local function Play_Action_fighting(iFighting)
	if nil == mLayerRoot then
		return
	end
	iFighting = iFighting or 0
	if 0 == iFighting then
		return
	end
	
	local initPosY = 60		-- 初始位置
	local desPosY = 60		-- 移动位置
	local dTime = 1.0
	
	local heroImageView = mLayerRoot:getChildByName("ImageView_Hero")
	local layout = UILayout:create()
	heroImageView:addChild(layout)
	-- 播放特效
	local bgEffect = createAnimation_signal("effect_063u_%02d.png", 14, dTime/14)
	layout:getVirtualRenderer():addChild(bgEffect)
	-- 飘字
	local childLayout = UILayout:create()
	layout:addChild(childLayout)
	-- 战斗力图片
	local fightingImageView = UIImageView:create()
	fightingImageView:loadTexture("fighting.png")
	fightingImageView:setAnchorPoint(ccp(1.0, 0.5))
	fightingImageView:setPosition(ccp(-20, 0))
	childLayout:addChild(fightingImageView)
	-- 战斗力对比箭头
	local arrowImageView = UIImageView:create()
	if iFighting > 0 then
		arrowImageView:loadTexture("equipped_strengthen_modify04.png")
		initPosY = 0
		desPosY = 60
	else
		arrowImageView:loadTexture("equipped_strengthen_modify06.png")
		initPosY = 60
		desPosY = 0
	end
	childLayout:addChild(arrowImageView)
	-- 战斗力数值
	local labelAtlas = UILabelAtlas:create()
	labelAtlas:setProperty("01234567890", "labelatlasimg.png", 24, 32, "0")
	if iFighting > 0 then
		labelAtlas:setColor(ccc3(0,255,0))
	else
		labelAtlas:setColor(ccc3(255,0,0))
	end
	labelAtlas:setStringValue(tostring(math.abs(iFighting)))
	labelAtlas:setAnchorPoint(ccp(0.0, 0.5))
	labelAtlas:setPosition(ccp(20, 0))
	childLayout:addChild(labelAtlas)
	-- 飘字动画
	childLayout:setPosition(ccp(0,initPosY))
	local moveAction = CCMoveTo:create(dTime,ccp(0,desPosY))
	local fadeoutAction = CCFadeIn:create(dTime)
	local spawnAction = CCSpawn:createWithTwoActions(moveAction,fadeoutAction)
	local function callback()
		layout:stopAllActions()
		layout:removeFromParent()
	end
	local callfuncAction = CCCallFunc:create(callback)
	local action = CCSequence:createWithTwoActions(spawnAction,callfuncAction)
	childLayout:runAction(action)
end

function LayerBackpack.setFightingNum(iFighting)
	mFighting = iFighting
end

-- 发送镶嵌宝石
function LayerBackpack.seed_equipment_mountgem_result(gem_id)
	BackpackLogic.requestEquipmentMountgem(LayerGemInlay.getCurrentEquipID(), gem_id)
end

-- 发送卸下宝石
function LayerBackpack.seed_gem_unmounted_result(gem_temp_id)
	BackpackLogic.requestGemUnmounted(LayerGemInlay.getCurrentEquipID(), gem_temp_id)
end

-- 装备一键强化
function LayerBackpack.oneKeyStrenghten(equipInstId)
	local function sureOneKeyStrengthen()
		BackpackLogic.requestOneTouchEquipmentStrengthen(equipInstId)
	end
	local structConfirm = 
	{
		strText = GameString.get("Equip_STR_05"),
		buttonCount = 2,
		buttonEvent = {sureOneKeyStrengthen, nil}		--回调函数
	}
	UIManager.push("UI_ComfirmDialog", structConfirm)
end

-- 发送物品单个出售
function LayerBackpack.callback_seed_sale_item(id, amount, itemType)
	local function seed_sale_item()
		-- BackpackLogic.requestSaleItem(id, amount)
		local tb = {}
		table.insert(tb, id)
		BackpackLogic.requestSaleItems(tb)
	end
	
	local tipStr = GameString.get("BAG_STR_07")
	if item_type["equipment"] == itemType then
		local equip = ModelEquip.getEquipInfo(id)
		if #equip.gems > 0 then
			tipStr = GameString.get("EQUIPTRAIN_STR_05")
		end
	end
	local structConfirm = 
	{
		strText = tipStr,
		buttonCount = 2,
		buttonEvent = {seed_sale_item, nil},	--回调函数
		buttonEvent_Param = {nil, nil}			--函数参数
	}
	UIManager.push("UI_ComfirmDialog", structConfirm)
end

-- 发送物品批量出售
function LayerBackpack.seedSellItems(table_id)
	local function seed_sale_items()
		BackpackLogic.requestSaleItems(table_id)
		LayerBackpack.switchUILayer("UI_equip_body")
	end
	
	local structConfirm = 
	{
		strText = GameString.get("BAG_STR_07"),
		buttonCount = 2,
		buttonEvent = {seed_sale_items, nil}	--回调函数
	}
	UIManager.push("UI_ComfirmDialog", structConfirm)
end

-- 显示装备标签角标
function LayerBackpack.showNewAppenEquipTip()
	if nil == mLayerRoot then
		return
	end
	local newAppendEquipTipIcon = mLayerRoot:getChildByName("backpack_new_append_equip_tip")
	if nil == newAppendEquipTipIcon then
		newAppendEquipTipIcon = CommonFunc_getImgView("qipaogantanhao.png")
		newAppendEquipTipIcon:setName("backpack_new_append_equip_tip")
		newAppendEquipTipIcon:setPosition(ccp(374, 330))
		mLayerRoot:addChild(newAppendEquipTipIcon)
	end
	if true == LayerBackpack.existNewAppendEquip() then
		newAppendEquipTipIcon:setVisible(true)
	else
		newAppendEquipTipIcon:setVisible(false)
	end
end

-- 是否有新增装备
function LayerBackpack.existNewAppendEquip()
	return CommonFunc_GetTableCount(mNewAppendEquips) > 0
end

-- 是否为新增装备
function LayerBackpack.isNewAppendEquip(instId)
	if nil == instId or nil == mNewAppendEquips[instId] then
		return false
	end
	return true
end

-- 收到背包数据更新
local function handleUpdateBackpack(data)
	-- 保存新增的装备
	for key, val in pairs(data.updateitems) do
		if data_type["append"] == data.updatetype then
			if item_type["equipment"] == val.itemtype and true == mListenNewAppendEquip then
				mNewAppendEquips[val.id] = val
			end
		elseif data_type["delete"] == data.updatetype then
			mNewAppendEquips[val.id] = nil
		end
	end
	LayerBag.switchBag(nil)
	LayerMain.showNewAppenEquipTip()
	LayerBackpack.showNewAppenEquipTip()
end

-- 收到装备强化
local function handleEquipmentStrengthen(data)
	TipModule.onNet("msg_notify_equipment_strengthen_result")
	if true == data.success then
		LayerBag.switchBag(nil)
	end
	if true == data.isBatch then
		local structConfirm = 
		{
			strText = GameString.get("Equip_STR_06", (data.successCount + data.failedCount), data.successCount, data.failedCount, data.coinCost),
			buttonCount = 1,
			buttonEvent = {nil}	--回调函数
		}
		UIManager.push("UI_ComfirmDialog", structConfirm)
	end
end

-- 收到宝石镶嵌
local function handleGemMount(success)
	LayerBackpack.switchUILayer("UI_gemInlay")
	if true == success then
		Toast.Textstrokeshow(GameString.get("BAG_STR_04"),ccc3(255,255,255),ccc3(0,0,0),30)
		Audio.playEffectByTag(62)
		
		UIManager.pop("UI_Smith_GemInlayInfo")	
	end
end

-- 收到宝石卸下
local function handleGemUnmount(success)
	if true == success then
		Toast.Textstrokeshow(GameString.get("BAG_STR_05"),ccc3(255,255,255),ccc3(0,0,0),30)
	end
	if "UI_gemInlay" == LayerBackpack.getUILayerName("up") then
		if true == success then
			LayerGemInlay.gemUnmountOk()
			--铁匠铺（锻造）里面的宝石镶嵌中的卸下
			LayerSmithGemInlay.initUI()
		end
	else
		LayerBackpack.switchUILayer("UI_gemInlay")
	end
end

-- 收到物品单个售出
local function handleItemSale(data)	
	if true == data.success then
		Toast.Textstrokeshow(GameString.get("BAG_STR_03", data.gold), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		LayerBackpack.switchUILayer("UI_equip_body")
	end
end

-- 收到物品批量售出
local function handleItemsSale(data)
	if true == data.success then
		Toast.Textstrokeshow(GameString.get("BAG_STR_03", data.gold), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	end
end

-- 收到装备穿上
local function handleEquipmentPuton(success)
	TipModule.onNet("msg_notify_equipment_puton_result")
	if false == success then
		return
	end
	Play_Action_fighting(mFighting)
end

-- 收到装备脱下
local function handleEquipmentTakeoff(success)
	if false == success then
		return
	end
	Play_Action_fighting(-mFighting)
end

-- 收到装备分解
local function handleEquipResolve(data)
	if nil == mLayerRoot or false == data.success then
		return
	end
	if "UI_equip_info_new" == LayerBackpack.getUILayerName("up") then
		LayerBackpack.switchUILayer("UI_equip_body")
	end
	for key, val in pairs(data.infos) do 
		local row = LogicTable.getItemById(val.material_id)
		Toast.Textstrokeshow(GameString.get("ShopMall_PUR_GET", row.name, val.amount), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	end
	for k1, v1 in pairs(data.equip_infos) do
		for k2, v2 in pairs(v1.gems) do
			local row = LogicTable.getItemById(v2)
			Toast.Textstrokeshow(GameString.get("ShopMall_PUR_GET", row.name, 1), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		end
	end
end

-- 游戏事件注册
EventCenter_subscribe(EventDef["ED_UPDATE_BACKPACK"], handleUpdateBackpack)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_STRENGTHEN"], handleEquipmentStrengthen)
EventCenter_subscribe(EventDef["ED_GEM_MOUNT"], handleGemMount)
EventCenter_subscribe(EventDef["ED_GEM_UNMOUNT"], handleGemUnmount)
EventCenter_subscribe(EventDef["ED_ITEM_SALE"], handleItemSale)
EventCenter_subscribe(EventDef["ED_ITEMS_SALE"], handleItemsSale)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_PUTON"], handleEquipmentPuton)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_TAKEOFF"], handleEquipmentTakeoff)
EventCenter_subscribe(EventDef["ED_EQUIPMENT_RESLOVE"], handleEquipResolve)

