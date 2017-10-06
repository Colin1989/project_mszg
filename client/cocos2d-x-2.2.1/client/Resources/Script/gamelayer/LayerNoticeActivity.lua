--region LayerNoticeActivity.lua
--Author : songcy
--Date   : 2014/11/12

LayerNoticeActivity = {}
LayerAbstract:extend(LayerNoticeActivity)

local mRootView = nil

local activityCache = nil				-- 活动公告缓存
local topData = {}						-- 需要置顶的数据
local mCurPage = 1						-- 置顶当前页
local mNexPage = 1						-- 置顶下一页
local mPointDensity = 60				-- 点间距

-- 获得点坐标
local function getPointCoordinates(tb, widget)
	if tb == nil then
		return
	end
	tolua.cast(widget, "UIImageView")
	local mPointTb = {}
	local mPointNum = #tb
	local mWidth = widget:getInnerContainer()
end

-- 点击查看常驻公告详情
local function onClickLocalDetail(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local detail_id = widget:getTag()
	local tb = LogicTable.getUpdateNoticeById(detail_id)
	EventCenter_post(EventDef["ED_NOTICE_ITEM_DETAIL"], tb)
end
-- 点击查看详情
local function onClickDetail(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local detail_id = widget:getTag()
	if LayerNoticeDetail.IsExistDetail(detail_id) == false then
		local tb = req_notice_item_detail()
		tb.id = widget:getTag()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_notice_item_detail"])		-- 请求活动详细信息
	else
		local key, tb = LayerNoticeDetail.IsExistDetail(detail_id)
		EventCenter_post(EventDef["ED_NOTICE_ITEM_DETAIL"], tb)
		-- LayerNotice.setDetailUI()
	end
end

-- 控制置顶图片左右移动按键的UI
local function controlTopBtn()
	local leftBtn = tolua.cast(mRootView:getChildByName("ImageView_left"), "UIImageView")
	local rightBtn = tolua.cast(mRootView:getChildByName("ImageView_right"), "UIImageView")
	if #topData == 1 then
		leftBtn:setTouchEnabled(false)
		rightBtn:setTouchEnabled(false)
		return
	end
	if mCurPage == 1 then
		leftBtn:setTouchEnabled(false)
		rightBtn:setTouchEnabled(true)
	elseif mCurPage == #topData then
		leftBtn:setTouchEnabled(true)
		rightBtn:setTouchEnabled(false)
	else
		leftBtn:setTouchEnabled(true)
		rightBtn:setTouchEnabled(true)
	end
end

-- 单页置顶图片生产
local function getTopPictureById(cell, data, index)
	local node = UILayout:create()
	node:setSize(CCSizeMake(500, 215))
	local size = node:getSize()
	local topRow = LogicTable.getResourcesNoticeById(data.top_pic)
	local topPicture = CommonFunc_getImgView(string.format(topRow.picture))
	topPicture:setPosition(ccp(size.width*0.5, size.height*0.5))
	topPicture:setTag(data.id)
	topPicture:setTouchEnabled(true)
	topPicture:registerEventScript(onClickDetail)
	node:addChild(topPicture)
	return node
end

local callbackPosX = nil
-- 生成置顶图片
local function createTopPic()
	local function scrollCallback(scrollView, eventType)
		local width = scrollView:getInnerContainer():getSize().width
		local pos = scrollView:getInnerContainer():getPosition()
		local kuangW = scrollView:getSize().width
		local ratio = math.abs(pos.x)/(width - kuangW) * 100
		if eventType == "pushDown" then
			callbackPosX = pos.x
		end
		if eventType == "releaseUp" then
			local movePosition = pos.x - callbackPosX
			if movePosition < 0 then
				if pos.x < -20 then
					scrollView:jumpToRight()
				else
					scrollView:jumpToLeft()
				end
			elseif movePosition > 0 then
				if pos.x > -285 then
					scrollView:jumpToLeft()
				else
					scrollView:jumpToRight()
				end
			end
		end
	end
	
	local topScrollView = tolua.cast(mRootView:getChildByName("ScrollView_top"), "UIScrollView")
	-- topScrollView:registerEventScript(LayerNoticeActivity.adjustScrollView)
	UIScrollViewEx.show(topScrollView, topData, getTopPictureById, "H", 500, 215, 0, 1, 2, true, nil, true, false)
end

----------------------------------------------------------------------------------------------------
-- 根据排序规则插入数据
local function insertSort(array, data, compareFunc)
	if array == nil then
		return
	end
	if #array == 0 then
		table.insert(array, data)
	end
	for key, val in pairs(array) do
		if compareFunc(val, data) then
			table.insert(array, key, data)
			break
		end
	end
end

-----------------------------------------------------------------------------------------------------
-- 快速排序
local function GetArrayLength(array)
    local n=0
    while array[n+1] do
		n=n+1
	end
    return n
end

-- 
local function partion(array,left,right,compareFunc)
    local key = array[left] -- 哨兵  一趟排序的比较基准
    local index = left
    array[index],array[right] = array[right],array[index] -- 与最后一个元素交换
    local i = left
    while i< right do
        if compareFunc(key, array[i]) then
            array[index],array[i] = array[i],array[index]-- 发现不符合规则 进行交换
            index = index + 1
        end
        i = i + 1
    end
    array[right],array[index] = array[index],array[right] -- 把哨兵放回
    return index
end

-- 
local function quick(array,left,right,compareFunc)
    if(left < right ) then
        local index = partion(array,left,right,compareFunc)
        quick(array,left,index-1,compareFunc)
        quick(array,index+1,right,compareFunc)
    end
end 

-- 
local function quickSort(array,compareFunc)
    quick(array,1,GetArrayLength(array),compareFunc)
end

-- 根据数据优先级最高或时间最大排序，返回false则data_1优先级较高，反之data_2优先级高
local function getMaxPriority(data_1, data_2)
	if data_1 == nil then
		return false
	end
	if data_1.form == true then		-- data_1为本地公告
		return true
	end
	if data_1.priority == data_2.priority then
		-- return SystemTime.dateToTime
		return SystemTime.dateToTime(data_1.create_time) < SystemTime.dateToTime(data_2.create_time)
	else
		return data_1.priority < data_2.priority
	end
end

------------------------------------------------------------------------------------------------------
-- 删除过期公告
local function deleteOverdueNotice(array)
	local currTime = system_gettime()
	for key, val in pairs(array) do
		if array.form ~= true then
			local endTime = SystemTime.dateToTime(val.end_time)
			if endTime ~= nil and endTime <= currTime then
				table.remove(array, key)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------
-- 创建公告子项目
local function createActivityCell(cell, data, index)
	if mRootView == nil then
		return
	end
	
	local node = CommonFunc_getImgView("public2_bg_22.png")
	node:setScale9Enabled(true)
	node:setCapInsets(CCRectMake(15, 15, 1, 1))
	node:setSize(CCSizeMake(528, 118))
	
	-- 图标
	local icon = CommonFunc_getImgView("touming.png")
	icon:setPosition(ccp(-208, 0))
	node:addChild(icon)
	
	-- 图标背景框
	local iconBg = CommonFunc_getImgView("uibag_bg_framer.png")
	iconBg:setPosition(ccp(0, 0))
	icon:addChild(iconBg)
	
	if data.icon == 0 or data.icon == nil then
		icon:setVisible(false)
	else
		local temp = LogicTable.getResourcesNoticeById(data.icon)
		icon:loadTexture(temp.icon)
	end
	
	-- 角标
	if tonumber(data.mark_id) ~= 0 then
		local temp = LogicTable.getMarkNoticeById(data.mark_id)
		local mark = CommonFunc_getImgView(temp.mark)
		mark:setPosition(ccp(-232, 24))
		mark:setAnchorPoint(ccp(0.5, 0.5))
		node:addChild(mark)
	end
	
	-- 标题背景
	local titleBg = CommonFunc_getImgView("public2_bg_05.png")
	titleBg:setScale9Enabled(true)
	titleBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	titleBg:setSize(CCSizeMake(411, 94))
	titleBg:setPosition(ccp(50, 0))
	node:addChild(titleBg)
	
	-- 标题文本
	local labelTitle = CommonFunc_getLabel(data.title, 20)
	labelTitle:setPosition(ccp(-195, 26))
	labelTitle:setAnchorPoint(ccp(0.0, 0.5))
	titleBg:addChild(labelTitle)
	
	-- 副标题文本
	if data.sub_title ~= nil and tostring(data.sub_title) ~= "null" then
		local labelSubTitle = CommonFunc_getLabel(data.sub_title, 20)
		labelSubTitle:setPosition(ccp(-195, -8))
		labelSubTitle:setAnchorPoint(ccp(0.0, 0.5))
		titleBg:addChild(labelSubTitle)
	end
	
	-- 查看详情
	local labelDetail = CommonFunc_getLabel(GameString.get("NOTICE_SYSTEM_TIP_3"), 20)
	labelDetail:setPosition(ccp(150, -30))
	labelDetail:setAnchorPoint(ccp(0.5, 0.5))
	titleBg:addChild(labelDetail)
	labelDetail:setTouchEnabled(true)
	labelDetail:setTag(data.id)
	
	if data.form == true then			-- 本地公告
		labelDetail:registerEventScript(onClickLocalDetail)
	else
		labelDetail:registerEventScript(onClickDetail)
	end
	
	return node
end

-- 创建活动公告列表
local function createActivityList()
	if mRootView == nil then
		return
	end
	deleteOverdueNotice(activityCache)
	local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_list"), "UIScrollView")
	UIScrollViewEx.show(scrollView, activityCache, createActivityCell, "V", 528, 118, 0, 1, 3, true, nil, true, true)
	
	topData = {}
	for key, val in pairs(activityCache) do
		if val.top_pic ~= nil and tonumber(val.top_pic) ~= 0 then
			table.insert(topData, val)
			if #topData == 1 then
				break
			end
		end
	end
	if #topData ~= 0 then
		createTopPic()
	end
	local leftBtn = tolua.cast(mRootView:getChildByName("ImageView_left"), "UIImageView")
	
	local rightBtn = tolua.cast(mRootView:getChildByName("ImageView_right"), "UIImageView")
	
end

-- 控制置顶滚动层
LayerNoticeActivity.adjustScrollView = function(scrollView, eventType)
	-- local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_top"), "UIScrollView")
    -- 关闭CCScrollView中的自调整
    -- scrollView:unscheduleAllSelectors()
    -- local x = scrollView:getContentOffset().x
    -- cclog("---------------------------->x:",x,"------>y:",scrollView:getContentOffset().y)
    -- local offset = x % 574
	-- cclog("-------------->offset:",offset)
	-- 动画速度
	-- local velocity = 500
    -- 调整位置
    -- local adjustPos = nil
    -- 调整动画时间
    -- local adjustAnimDelay = nil
    -- 向右滑动是正向左滑动是负
    -- if offset < -240 then
		-- 计算下一页位置，时间
        -- adjustPos = ccpSub(scrollView:getContentOffset(), ccp(574 + offset, 0))
        -- adjustAnimDelay = (574 + offset) / velocity
    -- else
        -- 计算当前页位置，时间
        -- adjustPos = ccpSub(scrollView:getContentOffset(), ccp(offset, 0))
        -- 这里要取绝对值，否则在第一页往左翻动的时，保证adjustAnimDelay为正数
        -- adjustAnimDelay = math.abs(offset) / velocity
	-- end
	
	-- 调整位置
    -- scrollView:setContentOffsetInDuration(adjustPos, adjustAnimDelay)
	
	local absPageIndex = mCurPage - mNexPage
	local offset = absPageIndex * 574
	adjustPos = ccpAdd(scrollView:getPosition(), ccp(absPageIndex, 0))
	adjustAnimDelay = math.abs(absPageIndex) / velocity
	scrollView:setContentOffsetInDuration(adjustPos, adjustAnimDelay)
end

-----------------------------------------初始化---------------------------
LayerNoticeActivity.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		return
	end
	-- createActivityList()
	if activityCache == nil then
		local tb = req_notice_list()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_notice_list"])
	else
		createActivityList()
	end
end

-------------------------------------------销毁---------------------------
LayerNoticeActivity.destroy = function()
	mRootView = nil
	-- activityCache = nil
end

-------------------------------------------销毁---------------------------
LayerNoticeActivity.setRootNil = function()
	mRootView = nil
end

---------------------------------------------------------------------------
-- 获取公告列表是否为空
LayerNoticeActivity.activityCacheIsNil = function()
	if activityCache == nil or #activityCache == 0 then
		return true
	end
	return false
end

---------------------------------------------------------------------------
-- 获取公告列表
local function handleNoticeList(param)
	quickSort(param, getMaxPriority)
	activityCache = param
	if activityCache == nil then
		activityCache = {}
	end
	local allNotice = LogicTable.getAllUpdateNotice()
	for key, val in pairs(allNotice) do
		if tonumber(val.type) == 2 then
			table.insert(activityCache, val)
		end
	end
	createActivityList()
end
EventCenter_subscribe(EventDef["ED_NOTICE_LIST"], handleNoticeList)				-- 获取公告列表

-- 增加活动公告
local function handleAddNoticeItem(param)
	if activityCache == nil then
		activityCache = {}
	end
	insertSort(activityCache, param, getMaxPriority)
end
EventCenter_subscribe(EventDef["ED_ADD_NOTICE_ITEM"], handleAddNoticeItem)		-- 增加公告

-- 删除活动公告
local function handleDelNoticeItem(param)
	if activityCache == nil then
		return
	end
	for key, val in pairs(activityCache) do
		if tonumber(val.id) == tonumber(param.del_id) then
			table.remove(activityCache, key)
			break
		end
	end
end
EventCenter_subscribe(EventDef["ED_DEL_NOTICE_ITEM"], handleDelNoticeItem)		-- 删除公告

local function handleClearData()
	activityCache = nil
	topData = {}
end
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)