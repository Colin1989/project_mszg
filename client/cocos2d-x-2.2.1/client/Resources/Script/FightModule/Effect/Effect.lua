----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	特效基类
----------------------------------------------------

Effect = class()

--构造
function Effect:ctor()
	self.mCallbackFunc		= nil		--回调函数
	self.mParam				= nil		--回调参数
end

--设置回调
function Effect:setCallback(func, param)
	self.mCallbackFunc 	= func
	self.mParam			= param
end

--特效持续时间
function Effect:duration()
end

--开始播放
function Effect:play()
end

--特效结束
function Effect:over()
	if self.mCallbackFunc == nil then
		return
	end
	self.mCallbackFunc(self.mParam)
end












