----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-24
-- Brief:	创建角色界面，职业的详细信息
----------------------------------------------------------------------
LayerJobInfo={}
local mRootNode = nil

----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_JobInfo")
	end
end
----------------------------------------------------------------------
-- 初始化
LayerJobInfo.init = function(bundle)
	mRootNode = UIManager.findLayerByTag("UI_JobInfo")
	
	--关闭按钮
	--local closeBtn = tolua.cast(mRootNode:getWidgetByName("close"), "UIButton")			
	--closeBtn:registerEventScript(clickCloseBtn)
	--整个panel
	local panel = tolua.cast(mRootNode:getWidgetByName("ImageView_job"), "UILayout")			
	panel:registerEventScript(clickCloseBtn)
	
	CommonFunc_Add_Info_EnterAction(bundle,panel)

	--图片
	--local icon = tolua.cast(mRootNode:getWidgetByName("icon"),"UIImageView")			-- 关闭按钮
	--icon:loadTexture(bundle.icon)
	--名字
	local name = tolua.cast(mRootNode:getWidgetByName("name"),"UILabel")
	name:setText(bundle.name)
	
	--职业
	local job = tolua.cast(mRootNode:getWidgetByName("job"),"UILabel")
	local types = 1
	if ModelPlayer.getRoleType() == 0 then
		types =  LayerRoleChoice.getSelectedRoleType()
	else
		types = ModelPlayer.getRoleType()
	end
	local textJob = string.format(GameString.get("Public_job",CommonFunc_GetRoleTypeString(types)))
	job:setText(textJob)
	--描述
	local des = tolua.cast(mRootNode:getWidgetByName("des"),"UILabel")
	des:setText(bundle.description)
	
end
----------------------------------------------------------------------
-- 销毁
LayerJobInfo.destroy = function()
	mRootNode = nil
end
----------------------------------------------------------------------


