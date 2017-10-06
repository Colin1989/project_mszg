----------------------------------------------------------------------
-- 作者：李晓军
-- 日期：2014-3-5
-- 描述：宝石合成
----------------------------------------------------------------------
LayerGemCompound = {
}

local mLayerRoot = nil
local mID = nil					-- 宝石在背包中的实例ID
local mTempID = nil				-- 宝石在背包中的模板ID
local mNextItemID = nil			-- 升级后的宝石物品ID
local mNextGemName = ""			-- 升级后的宝石名
local mUseProtection = false	-- 是否使用保护符
local mProtectionId = 6001		-- 保护符,物品id
local mProtectionItem = nil		-- 保护符物品
local mIsMallSell = false       -- 商城是否有出售

-- 获取一键补齐表
local function getOneKeyTable()
	local tb = {}
	local row = {}
	row.id = tostring(mTempID)
	row.amount = 5
	table.insert(tb, row)
	
	return tb
end

local function checkCanCompoundAndShowTips()
	local status = BackpackLogic.gemCompoundStatus(mTempID, false)
	if 1 == status or 2 == status then
		-- local tb = getOneKeyTable()
		-- UIManager.push("UI_OneKeyCompletion", tb)
		Toast.Textstrokeshow(GameString.get("Gem_hint_3"),ccc3(255,255,255),ccc3(0,0,0),30)
	elseif 3 == status then
		Toast.Textstrokeshow(GameString.get("Gem_hint_4"),ccc3(255,255,255),ccc3(0,0,0),30)
	-- elseif 4 == status then
		-- Toast.Textstrokeshow(GameString.get("Gem_hint_5"),ccc3(255,255,255),ccc3(0,0,0),30)
	end
	return 0 == status
end

local function onClickEvent(typeName,widget)
	if typeName == "releaseUp" then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		 
		if widgetName == "Button_47" then	-- 使用/取消 保护符
			mProtectionItem = ModelBackpack.getItemByTempId(mProtectionId)
			if nil == mProtectionItem then	-- 背包中没有保护符
				-- local structConfirm = 
				-- {
					-- strText = GameString.get("Gem_hint_1"),
					-- buttonCount = 2,
					-- buttonName = {GameString.get("Buy"), GameString.get("cancle")},
					-- buttonEvent = {LayerMain.switchLayer, nil},	-- 回调函数
					-- buttonEvent_Param = {"mainbtn_shop", nil}
				-- }
				-- UIManager.push("UI_ComfirmDialog", structConfirm)
				CommonFunc_payConsume(3, 1, mProtectionId, One_Time_Purchase)
				return
			else
				-- 保护符图标
				local protectImageView = mLayerRoot:getChildByName("ImageView_protect")
				tolua.cast(protectImageView, "UIImageView")
				-- 保护符按钮
				local protectBtn = mLayerRoot:getChildByName("Button_47")
				tolua.cast(protectBtn, "UIButton")
				-- 保护符数量
				local protectAmountLabel = mLayerRoot:getChildByName("Label_protect_count_2438")
				tolua.cast(protectAmountLabel, "UILabelAtlas")
				
				mUseProtection = not mUseProtection
				if true == mUseProtection then
					protectBtn:loadTextureNormal("gem_e_08.png")
					protectAmountLabel:setVisible(nil ~= mProtectionItem)
					protectAmountLabel:setStringValue(mProtectionItem.amount)
					local widget = CommonFunc_AddGirdWidget(mProtectionId, 0)
					protectImageView:addChild(widget)
				else
					protectBtn:loadTextureNormal("gem_e_05.png")
					protectAmountLabel:setVisible(false)
					protectImageView:removeAllChildren()
				end
			end
		elseif widgetName == "Button_HC" then
			if true == checkCanCompoundAndShowTips() then
				local gemItem = ModelBackpack.getItemByTempId(mTempID)
				local gemCompoundRow = ModelGem.getGemCompoundRow(gemItem.itemid)
				if CommonFunc_payConsume(1, gemCompoundRow.gold) then
					return
				end
				BackpackLogic.requestGemCompund(mTempID, mUseProtection)
			end
		elseif widgetName == "Button_one_key_hc" then
			if true == checkCanCompoundAndShowTips() then
				local gemItem = ModelBackpack.getItemByTempId(mTempID)
				local gemCompoundRow = ModelGem.getGemCompoundRow(gemItem.itemid)
				if CommonFunc_payConsume(1, gemCompoundRow.gold) then
					return
				end
				local function oneKeyCompound()
					BackpackLogic.requestOneTouchGemCompound(mTempID, mUseProtection)
				end
				if true == mUseProtection then
					oneKeyCompound()
				else
					local structConfirm = 
					{
						strText = GameString.get("Gem_hint_9"),
						buttonCount = 2,
						buttonEvent = {oneKeyCompound, nil}
					}
					UIManager.push("UI_ComfirmDialog", structConfirm)
				end
			end
		elseif widgetName == "Button_completion" then
			local tb = getOneKeyTable()
			UIManager.push("UI_OneKeyCompletion", tb)
		end
	end
end

-- 更新控件
local function updateWidget()
	if nil == mLayerRoot then
		return
	end
	
	local gemAmount1 = 0
	local gemAmount2 = 0
	local gemItem = ModelBackpack.getItemByTempId(mTempID)
	if gemItem then
		gemAmount1 = gemItem.amount
	end
	local nextGemItem = ModelBackpack.getItemByTempId(mNextItemID)
	if nextGemItem then
		gemAmount2 = nextGemItem.amount
	end
	--Log(gemItem)
	-- 宝石数量1
	local gemAmountLabel1 = mLayerRoot:getChildByName("Label_gem1_amount")
	tolua.cast(gemAmountLabel1, "UILabelAtlas")
	gemAmountLabel1:setStringValue(tostring(gemAmount1))
	gemAmountLabel1:setZOrder(1000)
	-- 宝石数量2
	local gemAmountLabel2 = mLayerRoot:getChildByName("Label_gem2_amount")
	tolua.cast(gemAmountLabel2, "UILabelAtlas")
	gemAmountLabel2:setStringValue(tostring(gemAmount2))
	gemAmountLabel2:setZOrder(1000)
	-- 保护符图标
	local protectImageView = mLayerRoot:getChildByName("ImageView_protect")
	tolua.cast(protectImageView,"UIImageView")
	protectImageView:removeAllChildren()
	-- 保护符按钮
	local protectBtn = mLayerRoot:getChildByName("Button_47")
	tolua.cast(protectBtn, "UIButton")	
	protectBtn:registerEventScript(onClickEvent)
	-- 保护符数量
	local protectAmountLabel = mLayerRoot:getChildByName("Label_protect_count_2438")
	tolua.cast(protectAmountLabel, "UILabelAtlas")
	protectAmountLabel:setZOrder(1000)
	
	mProtectionItem = ModelBackpack.getItemByTempId(mProtectionId)
	--if nil == mProtectionItem then	-- 当前背包中没有保护符
		protectBtn:loadTextureNormal("gem_e_05.png")
		protectAmountLabel:setVisible(false)
		mUseProtection = false
	--else
	--[[
		protectBtn:loadTextureNormal("gem_e_08.png")
		protectAmountLabel:setStringValue(tostring(mProtectionItem.amount))
		protectAmountLabel:setVisible(true)
		mUseProtection = true
		local widget = CommonFunc_AddGirdWidget(mProtectionId, 0)
		protectImageView:addChild(widget)	
	end
	]]--
	-- 材料补齐按钮
	local completionBgImage = tolua.cast(mLayerRoot:getChildByName("ImageView_979"), "UIImageView")
	local completionBtn = mLayerRoot:getChildByName("Button_completion")
	local status = BackpackLogic.gemCompoundStatus(mTempID, false)
	if 0 == status or not LayerOneKeyCompletion.isExists(getOneKeyTable()) then
		Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		Lewis:spriteShaderEffect(completionBgImage:getVirtualRenderer(),"buff_gray.fsh",true)
		completionBtn:setTouchEnabled(false)
	else
		Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		Lewis:spriteShaderEffect(completionBgImage:getVirtualRenderer(),"buff_gray.fsh",false)
		completionBtn:setTouchEnabled(true)
	end
end

-- 一键补齐后刷新材料显示
local function handle_req_oneKeyForGemCompound(success)
	if nil == mLayerRoot then
		return
	end
	if false == success then
		return
	end
	cclog("---------------------------------->handle_req_oneKeyForGemCompound")
	updateWidget()
end

EventCenter_subscribe(EventDef["ED_UPDATE_FOR_ONE_KEY"], handle_req_oneKeyForGemCompound)

-- 初始化
function LayerGemCompound.init(root, param)
	mLayerRoot = root
	
	--没有宝石字
	local Label_no =  mLayerRoot:getChildByName("Label_no")
	Label_no:setVisible(true)
	--没有宝石的panel
	local panel_no =  mLayerRoot:getChildByName("Panel_no")
	panel_no:setVisible(false)
	--各个按钮
	local compoundBtn = mLayerRoot:getChildByName("Button_HC")
	local oneKeyCompoundBtn = mLayerRoot:getChildByName("Button_one_key_hc")	
	local completionBtn = mLayerRoot:getChildByName("Button_completion")
	local protectBtn = mLayerRoot:getChildByName("Button_47")
	local completionBgImage = tolua.cast(mLayerRoot:getChildByName("ImageView_979"), "UIImageView")
	local onekeyBgImage = tolua.cast(mLayerRoot:getChildByName("ImageView_932"), "UIImageView")
	Lewis:spriteShaderEffect(compoundBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(oneKeyCompoundBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(protectBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(completionBgImage:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(onekeyBgImage:getVirtualRenderer(),"buff_gray.fsh",true)
	
	
	mID =  param.id
	print(param.id,type(param.id),param.itemtype)
	if tonumber(param.id) == 0 then
		--print("我没有任何物品********************")
		return
	end
	if nil ~= param.itemtype and tonumber(param.itemtype) == 0 then
		--print("我没有宝石********************")
		return
	end
	
	
	Label_no:setVisible(false)
	panel_no:setVisible(true)
	Lewis:spriteShaderEffect(compoundBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	Lewis:spriteShaderEffect(oneKeyCompoundBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	Lewis:spriteShaderEffect(protectBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	Lewis:spriteShaderEffect(completionBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	Lewis:spriteShaderEffect(completionBgImage:getVirtualRenderer(),"buff_gray.fsh",false)
	Lewis:spriteShaderEffect(onekeyBgImage:getVirtualRenderer(),"buff_gray.fsh",false)
	compoundBtn:setTouchEnabled(true)
	oneKeyCompoundBtn:setTouchEnabled(true)
	protectBtn:setTouchEnabled(true)
	completionBtn:setTouchEnabled(true)
	
	mUseProtection = false
	mIsMallSell = false
	-- 当前宝石信息
	local itemId = ModelBackpack.getItemTempId(mID)
	local itemRow = LogicTable.getItemById(itemId)
	local gemAttrRow = ModelGem.getGemAttrRow(itemId)
	local gemCompoundRow = ModelGem.getGemCompoundRow(itemRow.sub_id)
	
	local tmpTbProductsInfo = LogicTable.getProductData()
	for key, value in pairs(tmpTbProductsInfo) do
		if value.item_id == tostring(itemId) then
			mIsMallSell = true
		end
	end
	
	-- 合成后的宝石信息
	local nextItemRow = itemRow
	local nextGemAttrRow = gemAttrRow
	mTempID = itemId
	mNextItemID = itemId
	mNextGemName = itemRow.name
	if gemCompoundRow.related_id > 0 then	-- 不是最高级
		nextItemRow = LogicTable.getItemById(gemCompoundRow.related_id)
		nextGemAttrRow = ModelGem.getGemAttrRow(nextItemRow.sub_id)
		mNextItemID = gemCompoundRow.related_id
		mNextGemName = nextItemRow.name
	end
	-- 宝石属性值
	for i=1, 1 do
		-- 合成前属性值
		local strGemAttrValue = CommonFunc_getAttrDescTable(gemAttrRow)
		local valLabel1 = mLayerRoot:getChildByName("Label_val_"..i)
		tolua.cast(valLabel1, "UILabel")
		if nil == strGemAttrValue[i] then
			valLabel1:setVisible(false)
		else
			valLabel1:setText(strGemAttrValue[i])
			valLabel1:setVisible(true)
		end
		-- 合成后属性值
		local strGemAttrValue = CommonFunc_getAttrDescTable(nextGemAttrRow)
		local valLabel2 = mLayerRoot:getChildByName("Label_val_"..(i+3))
		tolua.cast(valLabel2, "UILabel")
		if nil == strGemAttrValue[i] then
			valLabel2:setVisible(false)
		else
			valLabel2:setText(strGemAttrValue[i])
			valLabel2:setVisible(true)
		end
	end
	-- 合成前宝石图标
	local gemImageView1 = mLayerRoot:getChildByName("ImageView_gem1")
	CommonFunc_AddGirdWidget(itemRow.id, 1, nil, nil, gemImageView1)
	-- 合成后宝石图标
	local gemImageView2 = mLayerRoot:getChildByName("ImageView_gem2")
	CommonFunc_AddGirdWidget(nextItemRow.id, 1, nil, nil, gemImageView2)
	-- 合成前宝石名称
	local gemNameLabel1 = mLayerRoot:getChildByName("Label_gem1")
	tolua.cast(gemNameLabel1, "UILabel")
	gemNameLabel1:setText(itemRow.name)
	-- 合成后宝石名称
	local gemNameLabel2 = mLayerRoot:getChildByName("Label_gem2")
	tolua.cast(gemNameLabel2, "UILabel")
	gemNameLabel2:setText(nextItemRow.name)
	-- 合成金币消耗
	local priceLabel = mLayerRoot:getChildByName("LabelAtlas_price")
	tolua.cast(priceLabel, "UILabelAtlas")
	priceLabel:setStringValue(tostring(gemCompoundRow.gold))
	-- 合成需要
	local needLabel = mLayerRoot:getChildByName("Label_need")
	tolua.cast(needLabel, "UILabel")
	needLabel:setText(GameString.get("Gem_hint_6", itemRow.name))
	-- 合成成功率
	local successLabel = mLayerRoot:getChildByName("Label_probability") 
	tolua.cast(successLabel, "UILabel")
	successLabel:setText(GameString.get("Gem_hint_7", gemCompoundRow.success_rate))
	-- 合成按钮
	local status = BackpackLogic.gemCompoundStatus(itemId, true)	
	compoundBtn:registerEventScript(onClickEvent)
	-- compoundBtn:setTouchEnabled((true == mIsMallSell) and (1 == status or 2 == status) or 0 == status)
	-- compoundBtn:setBright((true == mIsMallSell) and (1 == status or 2 == status) or 0 == status)
	compoundBtn:setTouchEnabled(true)
	-- 一键合成按钮
	oneKeyCompoundBtn:registerEventScript(onClickEvent)
	-- oneKeyCompoundBtn:setTouchEnabled((true == mIsMallSell) and (1 == status or 2 == status) or 0 == status)
	-- oneKeyCompoundBtn:setBright((true == mIsMallSell) and (1 == status or 2 == status) or 0 == status)
	oneKeyCompoundBtn:setTouchEnabled(true)
	-- 补齐材料
	completionBtn:registerEventScript(onClickEvent)
	-- 使用保护符按钮
	protectBtn:registerEventScript(onClickEvent)
	-- 最高等级提示图标
	local maxLevelImageView = mLayerRoot:getChildByName("ImageView_maxLevelTip")
	
	maxLevelImageView:setVisible(3 == status)
	--
	updateWidget()
	TipModule.onUI(root, "ui_gemcompound")
end

-- 销毁
function LayerGemCompound.destroy()
	mLayerRoot = nil
end

function LayerGemCompound.onExit()
end

-- 合成事件
local function handleGemCompoundResult(data)
	local str = nil
	if true == data.success then		-- 成功
		str = GameString.get("Gem_hint_8", data.gem_count, mNextGemName)
	else 
		str = GameString.get("Gem_hint_2", data.lost_gem_amount)
	end
	Toast.Textstrokeshow(str,ccc3(255,255,255),ccc3(0,0,0),30)
	updateWidget()
end

--注册合成事件
EventCenter_subscribe(EventDef["ED_GEM_COMPOUND"], handleGemCompoundResult)
