----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-04-14
-- Brief:	timer
----------------------------------------------------------------------
local mTimerList = {}
----------------------------------------------------------------------
local function insertTimer(tm)
	table.insert(mTimerList, tm)
end
----------------------------------------------------------------------
local function removeTimer(tm)
	for key, val in pairs(mTimerList) do
		if tm == val then
			table.remove(mTimerList, key)
			break
		end
	end
end
----------------------------------------------------------------------
-- called every frame
function UpdateTimer()
	for key, val in pairs(mTimerList) do
		val.update()
	end
end
----------------------------------------------------------------------
-- clear timer list
function ClearTimer()
	mTimerList = {}
end
----------------------------------------------------------------------
-- create a timer
function CreateTimer(interval, count, runCF, overCF, param)
	-- private member variables
	local mTotalCount = count			-- number of intervals, if count <= 0, timer will repeat forever
	local mCurrentCount = 0				-- current interval count
	local mInterval = interval			-- interval duration in seconds
	local mStartTime = 0.0				-- start time for the current interval in seconds
	local mRunning = false				-- status of the timer
	local mIsPause = false				-- is timer paused
	local mRunCallFunc = runCF			-- called when current count changed
	local mOverCallFunc = overCF		-- called when timer is complete
	local mParam = param				-- parameter
	local tm = {}
	-- public methods
	tm.update = function()
		if false == mRunning then
			return
		end
		local currTime = system_gettime()
		if true == mIsPause then
			mStartTime = currTime
			return
		end
		if mTotalCount <= 0 or mCurrentCount < mTotalCount then
			local deltaTime = math.abs(currTime - mStartTime)
			if deltaTime >= mInterval then
				local runCount = math.floor(deltaTime/mInterval)
				mCurrentCount = mCurrentCount + runCount
				for i=1, runCount do
					if "function" == type(mRunCallFunc) then
						mRunCallFunc(tm)
					end
				end
				mStartTime = currTime
			end
		else
			tm.stop(true)
		end
	end
	tm.start = function(executeFlag)
		if true == mRunning then
			return
		end
		mRunning = true
		mIsPause = false
		mCurrentCount = 0
		mStartTime = system_gettime()
		if "function" == type(mRunCallFunc) and true == executeFlag then
			mRunCallFunc(tm)
		end
		insertTimer(tm)
	end
	tm.stop = function(executeFlag)
		if false == mRunning then
			return
		end
		mRunning = false
		if "function" == type(mOverCallFunc) and true == executeFlag then
			mOverCallFunc(tm)
		end
		removeTimer(tm)
	end
	tm.pause = function(doPause)
		if true == doPause then
			mIsPause = true
		else
			mIsPause = false
			mStartTime = system_gettime()
		end
	end
	tm.getTotalCount = function() return mTotalCount end
	tm.getCurrentCount = function() return mCurrentCount end
	tm.isRunning = function() return mRunning end
	tm.setParam = function(param) mParam = param end
	tm.getParam = function() return mParam end
	return tm
end
----------------------------------------------------------------------
-- test code
--[[
local function timer1_CF1(tm, count)
	cclog("========== timer1 === param: "..tm.getParam().." === systime: "..system_gettime())
	tm.setParam("count_"..tm.getCurrentCount())
end
local function timer1_CF2(tm)
	cclog("========== timer1 is complete")
end
local timer1 = CreateTimer(1, 0, timer1_CF1, timer1_CF2)
timer1.setParam("hahaha")
timer1.start()
]]

