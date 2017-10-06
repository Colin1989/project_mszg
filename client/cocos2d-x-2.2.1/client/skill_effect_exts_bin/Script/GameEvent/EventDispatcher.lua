----------------------------------------------------------------------
-- 作者：hezhr
-- 日期：2013-11-19	
-- 描述：事件分布系统
----------------------------------------------------------------------
local mEventMap = {}	-- 事件映射表
local mDataMap = {}		-- 数据映射表
----------------------------------------------------------------------
-- 功  能：注册事件
-- 参  数：eventId(number或string类型) - 事件标识；func(function类型) - 事件回调函数
-- 返回值：无返回值
function EventCenter_subscribe(eventId, func)
	if "number" ~= type(eventId) and "string" ~= type(eventId) then
		print("EventCenter -> subscribe(eventId, func) -> eventId is not number or string")
		return
	end
	if "function" ~= type(func) then
		print("EventCenter -> subscribe(eventId, func) -> func is not function")
		return
	end

    --引用CCNotificationCenter	pLayer 事件layer  
	--CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(pLayer,func, "eventName")
	--CCNotificationCenter:sharedNotificationCenter():postNotification("eventName",selectedItem)	触发事件
	--CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(pLight,"eventName")  注销事件
	--CCNotificationCenter:sharedNotificationCenter():removeAllObservers(pLayer)  移除所有事件
	
	for k1, v1 in pairs(mEventMap) do
		if eventId == v1.eventId then	-- 事件已注册
			for k2, v2 in pairs(v1.handlers) do
				if func == v2 then		-- 处理函数已注册
					return
				end
			end
			table.insert(v1.handlers, func)
			return
		end
	end
	-- 事件未注册
	local event = {}		-- 构造一个事件
	event.eventId = eventId			-- 事件标识
	local evtHandlers = {}		-- 构造事件的处理函数集
	table.insert(evtHandlers, func)
	event.handlers = evtHandlers	-- 处理函数
	table.insert(mEventMap, event)
end
----------------------------------------------------------------------
-- 功  能：取消事件注册
-- 参  数：eventId(number或string类型) - 事件标识；funcfunc(function类型) - 要取消注册的事件回调函数
-- 返回值：无返回值
function EventCenter_unsubscribe(eventId, func)
	if "number" ~= type(eventId) and "string" ~= type(eventId) then
		print("EventCenter -> unsubscribe(eventId, func) -> eventId is not number or string")
		return
	end
	if "function" ~= type(func) then
		print("EventCenter -> unsubscribe(eventId, func) -> func is not function")
		return
	end
	for k1, v1 in pairs(mEventMap) do
		if eventId == v1.eventId then	-- 事件已注册
			for k2, v2 in pairs(v1.handlers) do
				if func == v2 then		-- 处理函数已注册
					table.remove(v1.handlers, k2)
					return
				end
			end
		end
	end
end
----------------------------------------------------------------------
-- 功  能：取消事件注册
-- 参  数：eventId(number或string类型) - 事件标识
-- 返回值：无返回值
function EventCenter_unsubscribe(eventId)
	if "number" ~= type(eventId) and "string" ~= type(eventId) then
		print("EventCenter -> unsubscribe(eventId) -> eventId is not number or string")
		return
	end
	for k, v in pairs(mEventMap) do
		if eventId == v.eventId then	-- 事件已注册
			table.remove(mEventMap, k)
			return
		end
	end
end
----------------------------------------------------------------------
-- 功  能：发布事件
-- 参  数：eventId(number或string类型) - 事件标识；param(任意类型) - 参数
-- 返回值：无返回值
function EventCenter_post(eventId, param)
	if "number" ~= type(eventId) and "string" ~= type(eventId) then
		print("EventCenter -> post(eventId, param) -> eventId is not number or string")
		return
	end
	for k1, v1 in pairs(mEventMap) do
		if eventId == v1.eventId then	-- 事件已注册
			for k2, v2 in pairs(v1.handlers) do
				if nil ~= v2 then
					v2(param)	-- 执行事件对应处理函数
				end
			end
			return
		end
	end
end
----------------------------------------------------------------------
-- 功  能：设置数据（若dataId已存在，则替换原来的数据）
-- 参  数：dataId(number或string类型) - 数据标识；data(任意类型) - 数据
-- 返回值：无返回值
function DataCenter_setData(dataId, data)
	if "number" ~= type(dataId) and "string" ~= type(dataId) then
		print("DataCenter -> setData(dataId, data) -> dataId is not number or string")
		return
	end
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
-- 功  能：获取数据
-- 参  数：dataId(number或string类型) - 数据标识
-- 返回值：数据（若dataId不存在，则返回nil）
function DataCenter_getData(dataId)
	if "number" ~= type(dataId) and "string" ~= type(dataId) then
		print("DataCenter -> getData(dataId) -> dataId is not number or string")
		return nil
	end
	for k, v in pairs(mDataMap) do
		if dataId == v.dataId then		-- 数据已存在
			return v.data
		end
	end
	return nil
end
----------------------------------------------------------------------

