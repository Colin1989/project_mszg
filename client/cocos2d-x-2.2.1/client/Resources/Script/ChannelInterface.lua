--------------------
--渠道商接入（模板1）
-------------------
--[[

local ChannelID = {
	"ANDROID_UC" = 1,
	"IOS_UC", = 2,
	"IOS_APPSTORE" = 3
}
ChannelInterface = {}
--ChannelInterface.isEnable = true -- 是否启用该模板
function ChannelInterface:extend(ChannelInstance)
    ChannelInstance = ChannelInstance or {}
    setmetatable(ChannelInstance, self)
    self.__index = self;
end


--欢迎界面
function ChannelInterface:welcome()
	
end 
-- 登入
function ChannelInterface:login()

end 

--支付
function ChannelInterface:pay()

end 

--社区
function ChannelInterface:community()

end 

-- 获取渠道ID
function ChannelInterface:getChannelId()

end

]]--








