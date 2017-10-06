----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-03-31
-- 描述：一些Action
----------------------------------------------------------------------

LuaAction = {}

local mUpdateID = nil
local mTargets = {}
local mUpdateFunc = {}

--获取目标
local function getTarget(node)
	for key, value in pairs(mTargets) do
		if value.node == node then
			return value, key
		end
	end
	return nil
end

--初始化
function LuaAction.init()
	mUpdateID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(LuaAction.update, 0, false)
end

--反初始化
function LuaAction.onExit()
	if mUpdateID then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(mUpdateID)
		mUpdateID = nil
	end
	mTargets = {}
end

--更新动作
function LuaAction.update(dt)
	for key, value in pairs(mTargets) do
		local func = mUpdateFunc[value.name]
		if func ~= nil then
			func(value, dt)
		end
	end
end

--移除目标
function LuaAction.removeTarget(node)
	local target, key = getTarget(node)
	if target == nil then
		return
	end
	table.remove(mTargets, key)
	print("remove target", key, #mTargets)
end

---------------------------------------------------------------------------------
--------------------------------圆周运动-----------------------------------------
---------------------------------------------------------------------------------
function LuaAction.ellipseBy(node, duration, longAxis, shortAxis)
	local target = getTarget(node)
	if target == nil then
		target = {}
		target.timer = 0
		table.insert(mTargets, target)
	end
	target.name = "ellipseBy"
	target.node = node
	target.duration = duration
	local x, y = node:getPosition()
	target.dots = ccp(x, y)
	target.longAxis = longAxis
	target.shortAxis = shortAxis
	target.radianDelta = 3.1415926 * 2 / duration
end

--更新函数
local function ellipseByUpdate(target, dt)
	target.timer = target.timer + dt
	local radian = target.radianDelta * target.timer
	local x = target.longAxis * math.sin(radian)
	local y = target.shortAxis * math.cos(radian)
	x = target.dots.x + x
	y = target.dots.y + y
	target.node:setPosition(ccp(x, y))
end

---------------------------------------------------------------------------------
--------------------------------矩形运动-----------------------------------------
---------------------------------------------------------------------------------
function LuaAction.rectangleBy(node, duration, width, height)
	local target = getTarget(node)
	if target == nil then
		target = {}
		target.timer = 0
		table.insert(mTargets, target)
	end
	target.name = "ellipseBy"
	target.node = node
	target.duration = duration
	local x, y = node:getPosition()
	target.dots = ccp(x, y)
	target.width = width
	target.height = height
	target.speed = (width + height) / duration
end

--更新函数
local function rectangleByUpdate(target, dt)
	target.timer = target.timer + dt
	x = target.dots.x + x
	y = target.dots.y + y
	target.node:setPosition(ccp(x, y))
end

mUpdateFunc["ellipseBy"] = ellipseByUpdate