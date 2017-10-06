----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-11-13
-- Brief:	铁匠铺主界面
----------------------------------------------------------------------
local mLayerRoot = nil	-- 好友邀请码界面根节点
local m_selectedRadioBtn = nil		-- 选中的radio
local mpanelContent = nil 			-- 两个小界面的根节点
local mcurUIWidget = nil 			-- 当前展示的小界面(刚进入时)
local mcurChildTb = nil				-- 刚刚展示的小界面
local mClickWidget = nil			-- 刚刚点击的按钮
local mIndex = 1                 	-- 表示默认选中第一个标签页
					
LayerSmithMain = {}
LayerAbstract:extend(LayerSmithMain)

local m_tbRadioBtnInfo =
{
	{["normal"] ="text_qianghua_n.png",["current"] = "text_qianghua_h.png"},
	{["normal"] ="text_xiangqian_n.png",["current"] ="text_xiangqian_h.png"},
	{["normal"] ="text_chognzhu_n.png",["current"] ="text_chognzhu_h.png"},
}

--设置点击切换按钮的图片
local function setSwitchBtnImg(sender)
	-- 已经选中
	if m_selectedRadioBtn == sender then
	    return
	end

	m_selectedRadioBtn = sender
	for k = 1, 3, 1 do 
		local btn = nil
		if k== 1 then
			btn = tolua.cast(mLayerRoot:getChildByName("Tag_Strengthen"), "UIButton")			--我是新人
		elseif k== 2 then
			btn = tolua.cast(mLayerRoot:getChildByName("Tag_GemInlay"),"UIButton")
		elseif k == 3 then
			btn = tolua.cast(mLayerRoot:getChildByName("Tag_Recast"),"UIButton")
		end
		local nameImage = tolua.cast(btn:getChildByName("textImg"),"UIImageView")
		local pos = btn:getPosition()
		if btn ~= sender then
			btn:setBright(true)
			nameImage:loadTexture(m_tbRadioBtnInfo[k].normal)
			nameImage:setPosition(ccp(0,0 ))
		else
			btn:setBright(false)
			nameImage:loadTexture(m_tbRadioBtnInfo[k].current)
			nameImage:setPosition(ccp(0,-4))
		end	
	end
end
----------------------------------------------------------------------
LayerSmithMain.setJosnWidget = function(this,jsonFile)
	if mcurChildTb ~= nil then
		mcurChildTb.destroy()
		mpanelContent:removeAllChildren()
	end
	local contentView = GUIReader:shareReader():widgetFromJsonFile(jsonFile)
	contentView:setAnchorPoint(ccp(0.0,0.0))
	contentView:setPosition(ccp(0,0))
	mpanelContent:addChild(contentView)
	this.init(contentView)
	
	mcurChildTb = this
	return contentView
end
----------------------------------------------------------------------
-- 点击按钮
local function clickBtn(typeName, widget)
	
	if "releaseUp" == typeName then
		TipModule.onClick(widget)
		local weightName = widget:getName()
		if mClickWidget == widget then
			return
		end
		if weightName == "Button_Close" then		--关闭按钮
			LayerMain.pullPannel(LayerSmithMain)
		elseif weightName == "Tag_Strengthen" then	--装备强化
			if CopyDateCache.getCopyStatus(LIMIT_EQIP_STREN.copy_id) ~= "pass"  then
				Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_EQIP_STREN.copy_id),LIMIT_EQIP_STREN.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			end
			mClickWidget = widget
			setSwitchBtnImg(widget)
			LayerSmithMain.setJosnWidget(LayerSmithStrength,"Smith_Equip_Strengthen.json")
		elseif weightName == "Tag_GemInlay" then	--宝石镶嵌
			if CopyDateCache.getCopyStatus(LIMIT_GEM_INLAY.copy_id) ~= "pass" then
				Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_GEM_INLAY.copy_id),LIMIT_GEM_INLAY.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			end
			mClickWidget = widget
			setSwitchBtnImg(widget)
			LayerSmithMain.setJosnWidget(LayerSmithGemInlay,"Smith_Equip_Gem.json")
		elseif weightName == "Tag_Recast" then		--装备重铸
			mClickWidget = widget
			setSwitchBtnImg(widget)
			LayerSmithMain.setJosnWidget(LayerSmithRecast,"Smith_Equip_Recast.json")
		end	
	end
end
----------------------------------------------------------------------
LayerSmithMain.init = function(rootView)
	mLayerRoot = rootView
	mpanelContent = tolua.cast(mLayerRoot:getChildByName("smithContent"),"UILayout")
	
	local closeBtn = tolua.cast(mLayerRoot:getChildByName("Button_Close"), "UIButton")	 -- 关闭按钮
	closeBtn:registerEventScript(clickBtn)
	local strenBtn = tolua.cast(mLayerRoot:getChildByName("Tag_Strengthen"), "UIButton")	 --装备强化
	strenBtn:registerEventScript(clickBtn)
	local gemInlayBtn = tolua.cast(mLayerRoot:getChildByName("Tag_GemInlay"), "UIButton")	 --宝石镶嵌
	gemInlayBtn:registerEventScript(clickBtn)
	local recastBtn = tolua.cast(mLayerRoot:getChildByName("Tag_Recast"), "UIButton")		 --装备重铸
	recastBtn:registerEventScript(clickBtn)
	
	LayerSmithMain.setSelectBtn(mIndex)
	
	TipModule.onUI(rootView, "ui_smithmain")
end
----------------------------------------------------------------------
LayerSmithMain.destroy = function()
	mLayerRoot = nil
	if mcurChildTb == LayerSmithStrength then
		LayerSmithStrength.destroy()
	elseif mcurChildTb == LayerSmithGemInlay then
		LayerSmithGemInlay.destroy()
	elseif mcurChildTb == LayerSmithRecast then
		LayerSmithRecast.destroy()
	end  
	mIndex = 1  
end 
----------------------------------------------------------
--设置默认选中的标签项
LayerSmithMain.setSelectBtn = function()
	if mIndex == 1  then
		LayerSmithMain.setSelectStren()
	elseif mIndex == 2 then
		LayerSmithMain.setSelectGem()
	elseif	mIndex == 3 then
		LayerSmithMain.setSelectRecast()
	end
end 
-----------------------------------------------------
--设置默认选中强化标签项
LayerSmithMain.setSelectStren = function()
	if mLayerRoot == nil then
		return
	end
	local strenBtn = tolua.cast(mLayerRoot:getChildByName("Tag_Strengthen"), "UIButton")	 --装备强化
	m_selectedRadioBtn = strenBtn
	
	local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
	nameImage:loadTexture(m_tbRadioBtnInfo[1].current)
	
	LayerSmithMain.setJosnWidget(LayerSmithStrength,"Smith_Equip_Strengthen.json")
	m_selectedRadioBtn:setBright(false)
end 

--设置默认选中宝石标签项
LayerSmithMain.setSelectGem = function()
	if mLayerRoot == nil then
		return
	end
	local gemInlayBtn = tolua.cast(mLayerRoot:getChildByName("Tag_GemInlay"), "UIButton")	 --宝石镶嵌
	m_selectedRadioBtn = gemInlayBtn
	
	local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
	nameImage:loadTexture(m_tbRadioBtnInfo[2].current)
	
	LayerSmithMain.setJosnWidget(LayerSmithGemInlay,"Smith_Equip_Gem.json")
	m_selectedRadioBtn:setBright(false)
end 

--设置默认选中重铸标签项
LayerSmithMain.setSelectRecast = function()
	if mLayerRoot == nil then
		return
	end
	local recastBtn = tolua.cast(mLayerRoot:getChildByName("Tag_Recast"), "UIButton")	 --装备强化
	m_selectedRadioBtn = recastBtn
	
	local nameImage = tolua.cast(m_selectedRadioBtn:getChildByName("textImg"),"UIImageView")
	nameImage:loadTexture(m_tbRadioBtnInfo[3].current)
	
	LayerSmithMain.setJosnWidget(LayerSmithRecast,"Smith_Equip_Recast.json")
	m_selectedRadioBtn:setBright(false)
end 

--设置默认标签选项值
LayerSmithMain.setIndex = function(index)
	mIndex = index
end

--获得界面的根节点
LayerSmithMain.getLayerRoot = function()
	return mLayerRoot
end