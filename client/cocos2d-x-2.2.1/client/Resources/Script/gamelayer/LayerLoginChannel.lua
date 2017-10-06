----------------------------------------------------------------------
-- 作者：jaron.ho
-- 日期：2014-11-15
-- 描述：渠道登录界面
----------------------------------------------------------------------
LayerLoginChannel = {}
LayerAbstract:extend(LayerLoginChannel)
local mEditBoxAccount = nil			-- 账号输入框
local mEditBoxPassword = nil		-- 密码输入框
local mAccount = ""					-- 账号
local mPassword = ""				-- 密码
----------------------------------------------------------------------
-- 点击
LayerLoginChannel.onClick = function(widget)
	local widgetName = widget:getName()
	if "Button_login" == widgetName then		-- 登录按钮
		ChannelProxy.login()
	end
end
----------------------------------------------------------------------
-- 初始化
LayerLoginChannel.init = function()
	local root = UIManager.findLayerByTag("UI_LoginChannel")
	setOnClickListenner("Button_login")
end
----------------------------------------------------------------------

