--------------------
--�����̽��루ģ��1��
-------------------
--[[

local ChannelID = {
	"ANDROID_UC" = 1,
	"IOS_UC", = 2,
	"IOS_APPSTORE" = 3
}
ChannelInterface = {}
--ChannelInterface.isEnable = true -- �Ƿ����ø�ģ��
function ChannelInterface:extend(ChannelInstance)
    ChannelInstance = ChannelInstance or {}
    setmetatable(ChannelInstance, self)
    self.__index = self;
end


--��ӭ����
function ChannelInterface:welcome()
	
end 
-- ����
function ChannelInterface:login()

end 

--֧��
function ChannelInterface:pay()

end 

--����
function ChannelInterface:community()

end 

-- ��ȡ����ID
function ChannelInterface:getChannelId()

end

]]--








