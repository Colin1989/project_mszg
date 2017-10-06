----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2013-11-19	
-- Brief:	event dispathcer system
----------------------------------------------------------------------
local mEventMap = {}	-- 事件映射表
local mDataMap = {}		-- 数据映射表
----------------------------------------------------------------------
-- 功  能:	注册事件
-- 参  数:	eventId(number或string类型)-事件标识;func(function类型)-事件回调函数;priority(number类型)-触发优先级顺序
-- 返回值:	none
function EventCenter_subscribe(eventId, func, priority)
	assert("number" == type(eventId) or "string" == type(eventId), "EventCenter -> subscribe() -> eventId is not number or string, it's type is "..type(eventId))
	assert("function" == type(func), "EventCenter -> subscribe(eventId, func) -> func is not function, it's type is "..type(func))
	for k1, v1 in pairs(mEventMap) do
		if eventId == v1.eventId then	-- 事件已注册
			for k2, v2 in pairs(v1.handlers) do
				if func == v2 then		-- 处理函数已注册
					return
				end
			end
			table.insert(v1.handlers, {func=func, priority=priority or 1})
			return
		end
	end
	-- 事件未注册
	local event = {}				-- 构造一个事件
	event.eventId = eventId			-- 事件标识
	local evtHandlers = {}			-- 构造事件的处理函数集
	table.insert(evtHandlers, {func=func, priority=priority or 1})
	event.handlers = evtHandlers	-- 处理函数
	table.insert(mEventMap, event)
end
----------------------------------------------------------------------
-- 功  能:	取消事件注册
-- 参  数:	eventId(number或string类型)-事件标识;func(function类型)-要取消注册的事件回调函数
-- 返回值:	none
function EventCenter_unsubscribe(eventId, func)
	assert("number" == type(eventId) or "string" == type(eventId), "EventCenter -> unsubscribe() -> eventId is not number or string, it's type is "..type(eventId))
	for k1, v1 in pairs(mEventMap) do
		if eventId == v1.eventId then		-- 事件已注册
			if nil == func then				-- 移除事件
				table.remove(mEventMap, k1)
				return
			end
			for k2, v2 in pairs(v1.handlers) do
				if func == v2.func then		-- 移除事件处理函数
					table.remove(v1.handlers, k2)
					return
				end
			end
		end
	end
end
----------------------------------------------------------------------
-- 功  能:	发布事件
-- 参  数:	eventId(number或string类型)-事件标识;param(任意类型)-参数
-- 返回值:	none
function EventCenter_post(eventId, param)
	assert("number" == type(eventId) or "string" == type(eventId), "EventCenter -> post() -> eventId is not number or string, it's type is "..type(eventId))
	for k1, v1 in pairs(mEventMap) do
		if eventId == v1.eventId then	-- 事件已注册
			table.sort(v1.handlers, function(a, b) return a.priority > b.priority end)
			for k2, v2 in pairs(v1.handlers) do
				v2.func(param)			-- 执行事件对应处理函数
			end
			return
		end
	end
end
----------------------------------------------------------------------
-- 功  能:	设置数据（若dataId已存在，则替换原来的数据）
-- 参  数:	dataId(number或string类型)-数据标识;data(任意类型)-数据
-- 返回值:	none
function DataCenter_setData(dataId, data)
	assert("number" == type(dataId) or "string" == type(dataId), "DataCenter -> setData() -> dataId is not number or string, it's type is "..type(dataId))
	for k, v in pairs(mDataMap) do
		if dataId == v.dataId then		-- 数据已存在
			v.data = data
			return
		end
	end
	-- 数据不存在
	local d = {}	-- 构建数据
	d.dataId = dataId
	d.data = data
	table.insert(mDataMap, d)
end
----------------------------------------------------------------------
-- 功  能:	获取数据
-- 参  数:	dataId(number或string类型)-数据标识
-- 返回值:	数据(若dataId不存在,则返回nil)
function DataCenter_getData(dataId)
	assert("number" == type(dataId) or "string" == type(dataId), "DataCenter -> getData() -> dataId is not number or string, it's type is "..type(dataId))
	for k, v in pairs(mDataMap) do
		if dataId == v.dataId then		-- 数据已存在
			return v.data
		end
	end
	return nil
end
----------------------------------------------------------------------

