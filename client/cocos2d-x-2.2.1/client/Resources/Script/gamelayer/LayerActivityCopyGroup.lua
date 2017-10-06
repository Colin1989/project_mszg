----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-09-15
-- Brief:	活动副本群界面
----------------------------------------------------------------------
LayerActivityCopyGroup = {}
local mGroupTable = nil
local mCurrGroupId = nil
----------------------------------------------------------------------
local function checkWeekDay(sTime, eTime, cDate)
	local ct = SystemTime.dateToTime(cDate)
	local weekDateTable = SystemTime.getWeekDate(cDate.year, cDate.month, cDate.day)
	local sDate = weekDateTable[sTime[1]]
	sDate.hour = sTime[2]
	sDate.min = sTime[3]
	local st = SystemTime.dateToTime(sDate)
	local eDate = weekDateTable[eTime[1]]
	eDate.hour = eTime[2]
	eDate.min = eTime[3]
	local et = SystemTime.dateToTime(eDate)
	if sTime[1] > eTime[1] then		-- 跨周
		return ct >= st or ct <= et
	end
	return ct >= st and ct <= et
end
----------------------------------------------------------------------
local function checkMonthDay(sTime, eTime, cDate)
	local sDate = {year=cDate.year, month=cDate.month, hour=sTime[2], minute=sTime[3]}
	sDate.day = sTime[1]
	if sDate.day < 0 then
		sDate.day = SystemTime.getMonthDays(cDate.year, cDate.month) + sDate.day + 1
	end
	local st = SystemTime.dateToTime(sDate)
	local eDate = {year=cDate.year, month=cDate.month, hour=eTime[2], minute=eTime[3]}
	eDate.day = eTime[1]
	if eDate.day < 0 then
		eDate.day = SystemTime.getMonthDays(cDate.year, cDate.month) + eDate.day + 1
	end
	if eDate.day < sDate.day then	-- 跨月
		if eDate.month + 1 > 12 then		-- 跨年
			eDate.year = eDate.year + 1
			eDate.month = 1
		else
			eDate.month = eDate.month + 1
		end
		local et = SystemTime.dateToTime(eDate)
		return ct >= st or ct <= et
	end
	local et = SystemTime.dateToTime(eDate)
	return ct >= st and ct <= et
end
----------------------------------------------------------------------
local function checkYearDay(sTime, eTime, cDate)
	local ct = SystemTime.dateToTime(cDate)
	local st = SystemTime.dateToTime({year=cDate.year, month=sTime[1], day=sTime[2], hour=sTime[3], minute=sTime[4]})
	if sTime[1] > eTime[1] then		-- 跨年
		local et = SystemTime.dateToTime({year=cDate.year + 1, month=eTime[1], day=eTime[2], hour=eTime[3], minute=eTime[4]})
		return ct >= st or ct <= et
	end
	local et = SystemTime.dateToTime({year=cDate.year, month=eTime[1], day=eTime[2], hour=eTime[3], minute=eTime[4]})
	return ct >= st and ct <= et
end
----------------------------------------------------------------------
-- 当前时间是否有效
local function isTimeValid(timeType, startTimeTb, endTimeTb)
	-- 周:星期,小时,分钟;月:日数(-1等于每月最后一天),小时,分钟;年:月,日,小时,分钟
	local checkFuncTb = {checkWeekDay, checkMonthDay, checkYearDay}
	local curDate = SystemTime.getServerDate()
	for i=1, #startTimeTb do
		if checkFuncTb[timeType](startTimeTb[i], endTimeTb[i], curDate) then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------
local getInLoad = nil
-- 设置进来的路径
LayerActivityCopyGroup.setInLoad = function(name)
	getInLoad = name
end

----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		if getInLoad == nil then		-- 默认从活动界面进
			--setConententPannelJosn(LayerActivity, "Activity.json", "ActivityUI")
            setConententPannelJosn(LayerLevelSelcet, "CopyBackgournd_1.json", "LayerLevelSelcetUI")
		elseif getInLoad == "main" then
			TipModule.onClick(widget)
			LayerMain.pullPannel()
		end
	end
end
----------------------------------------------------------------------
-- 点击副本群图标
local function clickActivityCopyGroupIcon(typeName, widget)
	if "releaseUp" == typeName then
		local index = widget:getTag()
		local data = mGroupTable[index]
		if isTimeValid(data.time_type, data.begin_time_array, data.end_time_array) then
			mCurrGroupId = data.id
			setConententPannelJosn(LayerActivityCopy, "ActivityCopy.json", "LayerActivityCopy")
		else
			Toast.Textstrokeshow(data.describe, ccc3(255,255,255), ccc3(0,0,0), 30)
		end
	end
end
----------------------------------------------------------------------
-- 创建副本群图标
local function createCopyGroupCell(cell, data, index)
	local node = CommonFunc_getImgView(data.icon)
	node:setTouchEnabled(true)
	node:setTag(index)
	node:registerEventScript(clickActivityCopyGroupIcon)
	return node
end
----------------------------------------------------------------------
-- 初始化
LayerActivityCopyGroup.init = function(rootView)
	if nil == mGroupTable then
		mGroupTable = LogicTable.getActivityCopyGroupTable()
	end
	-- 关闭按钮
	local closeBtn = tolua.cast(rootView:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 副本群列表
	local scrollView = tolua.cast(rootView:getChildByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, mGroupTable, createCopyGroupCell, "V", 542, 283, 15, 1, 2, true, nil, true, true)
end
----------------------------------------------------------------------
-- 销毁
LayerActivityCopyGroup.destroy = function()
	getInLoad = nil
end
----------------------------------------------------------------------
-- 获取当前副本群id
LayerActivityCopyGroup.getGroupId = function()
	return mCurrGroupId
end
----------------------------------------------------------------------
