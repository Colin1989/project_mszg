----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-20
-- Brief:	天赋没有激活时的界面
----------------------------------------------------------------------

LayerRoleTalentNoActive = {}
local mRootNode = nil
local mBundle = nil 		--传过来的信息
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_RoleTalent_NoActive")
	end
end
----------------------------------------------------------------------
-- 点击激活按钮
local function clickActiveBtn(typeName, widget)
	if "releaseUp" == typeName then
		TalentLogic.requestActiveTalent(mBundle.talentId)
		UIManager.pop("UI_RoleTalent_NoActive")
		widget:setTouchEnabled(false)
		Lewis:spriteShaderEffect(widget:getVirtualRenderer(), "buff_gray.fsh", true)
	end
end
----------------------------------------------------------------------
-- 初始化
LayerRoleTalentNoActive.init = function(bundle)
	mRootNode = UIManager.findLayerByTag("UI_RoleTalent_NoActive")
	
	mBundle = bundle
	--关闭按钮
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("close"), "UIButton")			-- 关闭按钮
	closeBtn:registerEventScript(clickCloseBtn)
	--激活按钮
	local activeBtn = tolua.cast(mRootNode:getWidgetByName("active"), "UIButton")			-- 关闭按钮
	if bundle.visible == false then
		activeBtn:setVisible(false)
	end
	if bundle.click == true then
		activeBtn:setTouchEnabled(true)
		Lewis:spriteShaderEffect(activeBtn:getVirtualRenderer(), "buff_gray.fsh", false)
		activeBtn:registerEventScript(clickActiveBtn)
	else
		activeBtn:setTouchEnabled(false)
		Lewis:spriteShaderEffect(activeBtn:getVirtualRenderer(), "buff_gray.fsh", true)
	end
	
	local talentInfo = LogicTable.getTalentTableRow(bundle.talentId)
	
	--图片
	local icon = tolua.cast(mRootNode:getWidgetByName("icon"),"UIImageView")	
	icon:loadTexture(talentInfo.icon)
	--名字
	local name = tolua.cast(mRootNode:getWidgetByName("name"),"UILabel")	
	name:setText(talentInfo.name)
	
	--id*100 +  ModelSkill.getTalentLevel(mBundle.talentId)
	local curLevel = ModelSkill.getTalentLevel(mBundle.talentId)	
	--图片上的等级
	local levelIcon = tolua.cast(mRootNode:getWidgetByName("level2"),"UILabelAtlas")	
	levelIcon:setStringValue(curLevel)
	--等级
	local level = tolua.cast(mRootNode:getWidgetByName("level"),"UILabel")	
	level:setText(curLevel)				---等级有待修改？？？？？？？？
	
	if  string.len(curLevel) == 1 then
		curLevel = tostring(0)..curLevel
	end
	local newId = tonumber(talentInfo.level_up_id..curLevel)
	local lvupInfo = LogicTable.getTalentlelUpTableRow(newId)
	
	--最高等级
	local maxLlevel = tolua.cast(mRootNode:getWidgetByName("max_level"),"UILabel")	
	maxLlevel:setText(GameString.get("Public_talent_maxLel",talentInfo.max_level))
	
	--描述
	local des = tolua.cast(mRootNode:getWidgetByName("des"),"UILabel")
	des:setTextAreaSize(CCSizeMake(352, 78))
	des:setText(lvupInfo.describe)
	
	--升级描述
	--local desLel = tolua.cast(mRootNode:getWidgetByName("des_lel"),"UILabel")
	
	
end
----------------------------------------------------------------------
-- 销毁
LayerRoleTalentNoActive.destroy = function()
	mRootNode = nil
end
----------------------------------------------------------------------


