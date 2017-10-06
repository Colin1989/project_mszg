--region LayerNoticeActivity.lua
--Author : songcy
--Date   : 2014/11/12

LayerNoticeActivity = {}
LayerAbstract:extend(LayerNoticeActivity)

local mRootView = nil

local activityCache = nil				-- ����滺��
local topData = {}						-- ��Ҫ�ö�������
local mCurPage = 1						-- �ö���ǰҳ
local mNexPage = 1						-- �ö���һҳ
local mPointDensity = 60				-- ����

-- ��õ�����
local function getPointCoordinates(tb, widget)
	if tb == nil then
		return
	end
	tolua.cast(widget, "UIImageView")
	local mPointTb = {}
	local mPointNum = #tb
	local mWidth = widget:getInnerContainer()
end

-- ����鿴��פ��������
local function onClickLocalDetail(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local detail_id = widget:getTag()
	local tb = LogicTable.getUpdateNoticeById(detail_id)
	EventCenter_post(EventDef["ED_NOTICE_ITEM_DETAIL"], tb)
end
-- ����鿴����
local function onClickDetail(typeName, widget)
	if typeName ~= "releaseUp" then
		return
	end
	local detail_id = widget:getTag()
	if LayerNoticeDetail.IsExistDetail(detail_id) == false then
		local tb = req_notice_item_detail()
		tb.id = widget:getTag()
		NetHelper.sendAndWait(tb, NetMsgType["msg_notify_notice_item_detail"])		-- ������ϸ��Ϣ
	else
		local key, tb = LayerNoticeDetail.IsExistDetail(detail_id)
		EventCenter_post(EventDef["ED_NOTICE_ITEM_DETAIL"], tb)
		-- LayerNotice.setDetailUI()
	end
end

-- �����ö�ͼƬ�����ƶ�������UI
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

-- ��ҳ�ö�ͼƬ����
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
-- �����ö�ͼƬ
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
-- ������������������
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
-- ��������
local function GetArrayLength(array)
    local n=0
    while array[n+1] do
		n=n+1
	end
    return n
end

-- 
local function partion(array,left,right,compareFunc)
    local key = array[left] -- �ڱ�  һ������ıȽϻ�׼
    local index = left
    array[index],array[right] = array[right],array[index] -- �����һ��Ԫ�ؽ���
    local i = left
    while i< right do
        if compareFunc(key, array[i]) then
            array[index],array[i] = array[i],array[index]-- ���ֲ����Ϲ��� ���н���
            index = index + 1
        end
        i = i + 1
    end
    array[right],array[index] = array[index],array[right] -- ���ڱ��Ż�
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

-- �����������ȼ���߻�ʱ��������򣬷���false��data_1���ȼ��ϸߣ���֮data_2���ȼ���
local function getMaxPriority(data_1, data_2)
	if data_1 == nil then
		return false
	end
	if data_1.form == true then		-- data_1Ϊ���ع���
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
-- ɾ�����ڹ���
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
-- ������������Ŀ
local function createActivityCell(cell, data, index)
	if mRootView == nil then
		return
	end
	
	local node = CommonFunc_getImgView("public2_bg_22.png")
	node:setScale9Enabled(true)
	node:setCapInsets(CCRectMake(15, 15, 1, 1))
	node:setSize(CCSizeMake(528, 118))
	
	-- ͼ��
	local icon = CommonFunc_getImgView("touming.png")
	icon:setPosition(ccp(-208, 0))
	node:addChild(icon)
	
	-- ͼ�걳����
	local iconBg = CommonFunc_getImgView("uibag_bg_framer.png")
	iconBg:setPosition(ccp(0, 0))
	icon:addChild(iconBg)
	
	if data.icon == 0 or data.icon == nil then
		icon:setVisible(false)
	else
		local temp = LogicTable.getResourcesNoticeById(data.icon)
		icon:loadTexture(temp.icon)
	end
	
	-- �Ǳ�
	if tonumber(data.mark_id) ~= 0 then
		local temp = LogicTable.getMarkNoticeById(data.mark_id)
		local mark = CommonFunc_getImgView(temp.mark)
		mark:setPosition(ccp(-232, 24))
		mark:setAnchorPoint(ccp(0.5, 0.5))
		node:addChild(mark)
	end
	
	-- ���ⱳ��
	local titleBg = CommonFunc_getImgView("public2_bg_05.png")
	titleBg:setScale9Enabled(true)
	titleBg:setCapInsets(CCRectMake(15, 15, 1, 1))
	titleBg:setSize(CCSizeMake(411, 94))
	titleBg:setPosition(ccp(50, 0))
	node:addChild(titleBg)
	
	-- �����ı�
	local labelTitle = CommonFunc_getLabel(data.title, 20)
	labelTitle:setPosition(ccp(-195, 26))
	labelTitle:setAnchorPoint(ccp(0.0, 0.5))
	titleBg:addChild(labelTitle)
	
	-- �������ı�
	if data.sub_title ~= nil and tostring(data.sub_title) ~= "null" then
		local labelSubTitle = CommonFunc_getLabel(data.sub_title, 20)
		labelSubTitle:setPosition(ccp(-195, -8))
		labelSubTitle:setAnchorPoint(ccp(0.0, 0.5))
		titleBg:addChild(labelSubTitle)
	end
	
	-- �鿴����
	local labelDetail = CommonFunc_getLabel(GameString.get("NOTICE_SYSTEM_TIP_3"), 20)
	labelDetail:setPosition(ccp(150, -30))
	labelDetail:setAnchorPoint(ccp(0.5, 0.5))
	titleBg:addChild(labelDetail)
	labelDetail:setTouchEnabled(true)
	labelDetail:setTag(data.id)
	
	if data.form == true then			-- ���ع���
		labelDetail:registerEventScript(onClickLocalDetail)
	else
		labelDetail:registerEventScript(onClickDetail)
	end
	
	return node
end

-- ����������б�
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

-- �����ö�������
LayerNoticeActivity.adjustScrollView = function(scrollView, eventType)
	-- local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_top"), "UIScrollView")
    -- �ر�CCScrollView�е��Ե���
    -- scrollView:unscheduleAllSelectors()
    -- local x = scrollView:getContentOffset().x
    -- cclog("---------------------------->x:",x,"------>y:",scrollView:getContentOffset().y)
    -- local offset = x % 574
	-- cclog("-------------->offset:",offset)
	-- �����ٶ�
	-- local velocity = 500
    -- ����λ��
    -- local adjustPos = nil
    -- ��������ʱ��
    -- local adjustAnimDelay = nil
    -- ���һ����������󻬶��Ǹ�
    -- if offset < -240 then
		-- ������һҳλ�ã�ʱ��
        -- adjustPos = ccpSub(scrollView:getContentOffset(), ccp(574 + offset, 0))
        -- adjustAnimDelay = (574 + offset) / velocity
    -- else
        -- ���㵱ǰҳλ�ã�ʱ��
        -- adjustPos = ccpSub(scrollView:getContentOffset(), ccp(offset, 0))
        -- ����Ҫȡ����ֵ�������ڵ�һҳ���󷭶���ʱ����֤adjustAnimDelayΪ����
        -- adjustAnimDelay = math.abs(offset) / velocity
	-- end
	
	-- ����λ��
    -- scrollView:setContentOffsetInDuration(adjustPos, adjustAnimDelay)
	
	local absPageIndex = mCurPage - mNexPage
	local offset = absPageIndex * 574
	adjustPos = ccpAdd(scrollView:getPosition(), ccp(absPageIndex, 0))
	adjustAnimDelay = math.abs(absPageIndex) / velocity
	scrollView:setContentOffsetInDuration(adjustPos, adjustAnimDelay)
end

-----------------------------------------��ʼ��---------------------------
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

-------------------------------------------����---------------------------
LayerNoticeActivity.destroy = function()
	mRootView = nil
	-- activityCache = nil
end

-------------------------------------------����---------------------------
LayerNoticeActivity.setRootNil = function()
	mRootView = nil
end

---------------------------------------------------------------------------
-- ��ȡ�����б��Ƿ�Ϊ��
LayerNoticeActivity.activityCacheIsNil = function()
	if activityCache == nil or #activityCache == 0 then
		return true
	end
	return false
end

---------------------------------------------------------------------------
-- ��ȡ�����б�
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
EventCenter_subscribe(EventDef["ED_NOTICE_LIST"], handleNoticeList)				-- ��ȡ�����б�

-- ���ӻ����
local function handleAddNoticeItem(param)
	if activityCache == nil then
		activityCache = {}
	end
	insertSort(activityCache, param, getMaxPriority)
end
EventCenter_subscribe(EventDef["ED_ADD_NOTICE_ITEM"], handleAddNoticeItem)		-- ���ӹ���

-- ɾ�������
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
EventCenter_subscribe(EventDef["ED_DEL_NOTICE_ITEM"], handleDelNoticeItem)		-- ɾ������

local function handleClearData()
	activityCache = nil
	topData = {}
end
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)