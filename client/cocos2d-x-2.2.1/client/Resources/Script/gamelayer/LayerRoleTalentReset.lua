----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-20
-- Brief:	天赋重置界面
----------------------------------------------------------------------
LayerRoleTalentReset={}
local mRootNode = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_RoleTalent_Reset")
	end
end
-- 点击确定按钮
local function clickSureBtn(typeName, widget)
	if "releaseUp" == typeName then
		local costEmoney = RoleTalent_Reset_Emoney
		if TalentLogic.getLeftTime() == 0 then
			costEmoney = 0
		end
		if CommonFunc_payConsume(2, costEmoney) then
			return
		end
		TalentLogic.requestResetTalent()
		UIManager.pop("UI_RoleTalent_Reset")
	end
end
----------------------------------------------------------------------
-- 初始化
LayerRoleTalentReset.init = function()
	mRootNode = UIManager.findLayerByTag("UI_RoleTalent_Reset")
	
	--关闭按钮
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("close"), "UIButton")			-- 关闭按钮
	closeBtn:registerEventScript(clickCloseBtn)
	--确定按钮
	local sureBtn = tolua.cast(mRootNode:getWidgetByName("sure"), "UIButton")			-- 关闭按钮
	sureBtn:registerEventScript(clickSureBtn)
	--取消按钮
	local cancleBtn = tolua.cast(mRootNode:getWidgetByName("cancle"), "UIButton")			-- 关闭按钮
	cancleBtn:registerEventScript(clickCloseBtn)
	
	--花费魔石
	local costLbl = tolua.cast(mRootNode:getWidgetByName("Label_costEmoney"),"UILabel")			-- 关闭按钮
	if TalentLogic.getLeftTime() == 0 then
		costLbl:setText(0)
	else
		costLbl:setText(tostring(RoleTalent_Reset_Emoney))
	end
	
end
----------------------------------------------------------------------
-- 销毁
LayerRoleTalentReset.destroy = function()
	mRootNode = nil
end
----------------------------------------------------------------------


