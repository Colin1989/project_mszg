----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-13
-- Brief:	铁匠铺主界面（宝石进阶信息界面）
----------------------------------------------------------------------
local mLayerRoot = nil	-- 界面根节点
local mBundleInfo = nil


LayerSmithGemInfo = {}
LayerAbstract:extend(LayerSmithGemInfo)

-- 点击
LayerSmithGemInfo.onClick = function(widget)
	TipModule.onClick(widget)
	local widgetName = widget:getName()
	if "rootview" == widgetName or "Panel_20" == widgetName then
		UIManager.pop("UI_Smith_GemInlayInfo")
	end
end

--宝石镶嵌
local function clickInlay(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		BackpackLogic.requestEquipmentMountgem(mBundleInfo.equipInfo.equipment_id,mBundleInfo.instId )
	end
end

--宝石合成
local function clickCoumpund(types,widget)
	if types == "releaseUp" then
		TipModule.onClick(widget)
		local widgetName = widget:getName()
		UIManager.pop("UI_Smith_GemInlayInfo")
		LayerBackpack.returnGemUI()
		local param = {}
		param.id = mBundleInfo.instId
		param.itemtype = 3
		LayerBackpack.switchUILayer("UI_gemCompound", param)
	end
end

-- 初始化
LayerSmithGemInfo.init = function(bundle)

	mBundleInfo = bundle
	
	local root = UIManager.findLayerByTag("UI_Smith_GemInlayInfo")
	setOnClickListenner("rootview")
	setOnClickListenner("Panel_20")
	
	--镶嵌按钮
	local inlayBtn = tolua.cast(root:getWidgetByName("Button_inlay"), "UIButton")
	if nil == mBundleInfo.equipInfo then
		inlayBtn:setTouchEnabled(false)
		Lewis:spriteShaderEffect(inlayBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	else
		inlayBtn:registerEventScript(clickInlay)
		inlayBtn:setTouchEnabled(true)
		Lewis:spriteShaderEffect(inlayBtn:getVirtualRenderer(),"buff_gray.fsh",false)
	end
	
	--合成按钮
	local comoundBtn = tolua.cast(root:getWidgetByName("Button_compound"), "UIButton")
	comoundBtn:registerEventScript(clickCoumpund)
	
	local baseAttr = LogicTable.getItemById(bundle.temp_id)
	local gemAttr = ModelGem.getGemAttrRow(baseAttr.sub_id)
	-- 图标
	local iconImageView = tolua.cast(root:getWidgetByName("ImageView_head"), "UIImageView")
	CommonFunc_AddGirdWidget(baseAttr.id, 1, nil, nil, iconImageView)
	-- 名称
	local nameLabel = tolua.cast(root:getWidgetByName("Label_name"), "UILabel")
	nameLabel:setText(gemAttr.name)
	-- 战斗力
	local abilityLabel = tolua.cast(root:getWidgetByName("Label_ability"), "UILabelAtlas")
	abilityLabel:setStringValue(tostring(gemAttr.combat_effectiveness))
	-- 描述
	local descLabel = tolua.cast(root:getWidgetByName("Label_info"), "UILabel")
	descLabel:setTextAreaSize(CCSizeMake(307, 140))
	descLabel:setText(baseAttr.describe)
	-- 属性
	local strGemAttrValue = CommonFunc_getAttrDescTable(gemAttr)
	for i=1, 3 do
		local attrLable = tolua.cast(root:getWidgetByName("Label_"..i), "UILabel")
		if nil == strGemAttrValue[i] then
			attrLable:setVisible(false)
		else
			attrLable:setVisible(true)
			attrLable:setText(strGemAttrValue[i])
		end
	end	
	TipModule.onUI(rootView, "ui_smithgeminfo")
	
	
	
	--侧边，按钮动画
	inlayBtn:setVisible(false)
	comoundBtn:setVisible(false)

	local function callBack_1()
		Commonfunc_dropAnimation(inlayBtn)
	end
	
	local function callBack_2()
		Commonfunc_dropAnimation(comoundBtn)
	end
	
	local delay = 0.1
	inlayBtn:runAction(CCCallFuncN:create(callBack_1))
	comoundBtn:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFuncN:create(callBack_2)))
end

-- 销毁
LayerSmithGemInfo.destroy = function()
	mLayerRoot = nil
end