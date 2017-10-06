--region LayerContact.lua
--Author : songcy
--Date   : 2014/11/17


LayerContact = {}
local mRootNode = nil


-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_Contact")
	end
end
----------------------------------------------------------------------
-- 初始化
LayerContact.init = function()
	mRootNode = UIManager.findLayerByTag("UI_Contact")
	
	--关闭按钮
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("ImageView_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
end
----------------------------------------------------------------------
-- 销毁
LayerContact.destroy = function()
	mRootNode = nil
end