--region LayerContact.lua
--Author : songcy
--Date   : 2014/11/17


LayerContact = {}
local mRootNode = nil


-- ����رհ�ť
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_Contact")
	end
end
----------------------------------------------------------------------
-- ��ʼ��
LayerContact.init = function()
	mRootNode = UIManager.findLayerByTag("UI_Contact")
	
	--�رհ�ť
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("ImageView_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
end
----------------------------------------------------------------------
-- ����
LayerContact.destroy = function()
	mRootNode = nil
end