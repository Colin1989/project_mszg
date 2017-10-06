-------------------------------------------------------
-- 扩展列表控件
-- create by jaron.ho on 2014-08-07 17:30
-------------------------------------------------------
UIScrollViewEx = {}
----------------------------------------------------------------------
-- 创建扩展列表控件,返回值(总行数,已创建的单元格列表)
-- mScrollView:		列表控件
-- mDataTable:		顺序数据表,如:{"aaa","bbb","ccc","ddd"}
-- mCreateCellFunc:	单元格创建函数,如:function(cell, data, index)
-- mDirection:		滚动方向,如:"H"水平滚动;"V"垂直滚动
-- mCellW:			格子宽,如:120
-- mCellH:			格子高,如:120
-- mMargin:			间隔(如果垂直滑动,则表示垂直间隔;如果水平滑动,则表示水平间隔),如:10
-- mBlockSize:		块大小(如果垂直滑动,则表示每行个数;如果水平滑动,则表示每列个数),如:3
-- mInitBlocks:		初始显示块数(如果垂直滑动,则表示行数;如果水平滑动,则表示列数),如:2
-- mDynamic:		是否动态创建,如:true,false
-- mScrollCF:		滚动回调函数,如:function(scrollView)
-- cleanChildren:	是否清空子节点,如:true,false
-- bounceEnalbed:	是否开启回弹,如:true,false
----------------------------------------------------------------------
UIScrollViewEx.show = function(mScrollView, mDataTable, mCreateCellFunc, mDirection, mCellW, mCellH, mMargin, mBlockSize, mInitBlocks, mDynamic, mScrollCF, cleanChildren, bounceEnalbed)
	assert("table" == type(mDataTable) and "function" == type(mCreateCellFunc) and ("H" == mDirection or "V" == mDirection))
	mScrollView:unregisterEventScript()
	mScrollView:setInnerContainerSize(mScrollView:getSize())
	mScrollView:setTouchEnabled(true)
	mScrollView:setVisible(true)
	mScrollView:setEnabled(true)
	if "H" == mDirection then		-- 水平滚动
		mScrollView:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
	elseif "V" == mDirection then	-- 垂直滚动
		mScrollView:setDirection(SCROLLVIEW_DIR_VERTICAL)
	end
	mScrollView:setBounceEnabled(bounceEnalbed or false)
	if true == cleanChildren then
		mScrollView:removeAllChildren()
	else
		local cells = mScrollView:getChildren()
		for i=0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "UIWidget")
			cell:setVisible(false)
			cell:setTouchEnabled(false)
			cell:stopAllActions()
		end
	end
	local mScrollViewWidth = mScrollView:getInnerContainerSize().width				-- 列表宽
	local mScrollViewHeight = mScrollView:getInnerContainerSize().height			-- 列表高
	local mXPosTable = {}															-- x轴坐标
	local mYPosTable = {}															-- y轴坐标
	local mTotalBlocks = 0															-- 总块数
	local mInitedBlocks = 0															-- 已初始化的块数
	local mCells = {}																-- 单元格
	local mViewBlocksH = math.ceil(mScrollView:getSize().width/(mCellW + mMargin))	-- 水平可视块数
	local mViewBlocksV = math.ceil(mScrollView:getSize().height/(mCellH + mMargin))	-- 垂直可视块数
	----------------------------------------------------------------------
	-- 初始化参数
	local function init()
		mTotalBlocks = math.ceil(#mDataTable/mBlockSize)
		if "H" == mDirection then		-- 水平滚动
			-- 计算x轴坐标
			local scrollViewWidth = mTotalBlocks*mCellW + (mTotalBlocks+1)*mMargin
			if mScrollViewWidth < scrollViewWidth then
				mScrollViewWidth = scrollViewWidth
			end
			for i=1, mTotalBlocks do
				mXPosTable[i] = i*mMargin + (i-1)*mCellW + mCellW/2
			end
			-- 计算y轴坐标
			local marginV = 0
			if mScrollViewHeight > mCellH * mBlockSize then
				marginV = (mScrollViewHeight%(mCellH * mBlockSize))/(mBlockSize + 1)
			end
			for i=1, mBlockSize do
				mYPosTable[i] = mScrollViewHeight - (i*marginV + (i-1)*mCellH + mCellH/2)
			end
		elseif "V" == mDirection then	-- 垂直滚动
			-- 计算x轴坐标
			local marginH = 0
			if mScrollViewWidth > mCellW * mBlockSize then
				marginH = (mScrollViewWidth%(mCellW * mBlockSize))/(mBlockSize + 1)
			end
			for i=1, mBlockSize do
				mXPosTable[i] = i*marginH + (i-1)*mCellW + mCellW/2
			end
			-- 计算y轴坐标
			local scrollViewHeight = mTotalBlocks*mCellH + (mTotalBlocks+1)*mMargin
			if mScrollViewHeight < scrollViewHeight then
				mScrollViewHeight = scrollViewHeight
			end
			for i=1, mTotalBlocks do
				mYPosTable[i] = mScrollViewHeight - (i*mMargin + (i-1)*mCellH + mCellH/2)
			end
		end
		-- 设置列表宽高
		mScrollView:setInnerContainerSize(CCSizeMake(mScrollViewWidth, mScrollViewHeight))
	end
	----------------------------------------------------------------------
	-- 获取指定块数据,blockNum:从1开始
	local function getBlockData(blockNum)
		blockNum = blockNum - 1
		local startIndex = blockNum*mBlockSize + 1
		local endIndex = startIndex + mBlockSize - 1
		if startIndex > #mDataTable then
			return {}
		end
		if endIndex > #mDataTable then
			endIndex = #mDataTable
		end
		local blockData = {}
		for i=startIndex, endIndex do
			table.insert(blockData, {["data"]=mDataTable[i], ["index"]=i})
		end
		return blockData
	end
	----------------------------------------------------------------------
	-- 获取指定块单元格,blockNum:从1开始
	local function getBlockCell(blockNum)
		blockNum = blockNum - 1
		local startIndex = blockNum * mBlockSize
		local endIndex = startIndex + mBlockSize - 1
		local cells = mScrollView:getChildren()
		if startIndex >= cells:count() then
			return {}
		end
		if endIndex >= cells:count() then
			endIndex = cells:count() - 1
		end
		local blockCell = {}
		for i=startIndex, endIndex do
			table.insert(blockCell, tolua.cast(cells:objectAtIndex(i), "UIWidget"))
		end
		return blockCell
	end
	----------------------------------------------------------------------
	-- 显示格子,blockNum:从1开始
	local function showBlockCells(blockNum)
		local blockData = getBlockData(blockNum)
		local blockCell = getBlockCell(blockNum)
		for key, val in pairs(blockData) do
			local xPos, yPos = 0, 0
			if "H" == mDirection then		-- 水平滚动
				xPos = mXPosTable[blockNum]
				yPos = mYPosTable[key]
			elseif "V" == mDirection then	-- 垂直滚动
				xPos = mXPosTable[key]
				yPos = mYPosTable[blockNum]
			end
			local cell = mCreateCellFunc(blockCell[key], val["data"], val["index"])
			if nil == cell:getParent() then
				mScrollView:addChild(cell)
			end
			cell:setAnchorPoint(ccp(0.5, 0.5))
			cell:setPosition(ccp(xPos, yPos))
			cell:setVisible(true)
			table.insert(mCells, cell)
		end
	end
	----------------------------------------------------------------------
	-- 初始显示块
	local function initBlockCells()
		for i=1, mInitBlocks do
			mInitedBlocks = mInitedBlocks + 1
			showBlockCells(mInitedBlocks)
		end
	end
	----------------------------------------------------------------------
	-- 是否需要初始化单元格
	local function isNeedInitCell(initBlock)
		if initBlock >= mTotalBlocks then
			return false
		end
		if "H" == mDirection then		-- 水平滚动
			local cellPosX = mXPosTable[initBlock] - mCellW/2
			local scrollViewPosX = math.abs(mScrollView:getInnerContainer():getPosition().x)
			return cellPosX >= scrollViewPosX
		elseif "V" == mDirection then	-- 垂直滚动
			local cellPosY = mYPosTable[initBlock] - mCellH/2
			local scrollViewPosY = math.abs(mScrollView:getInnerContainer():getPosition().y)
			return cellPosY >= scrollViewPosY
		end
		return false
	end
	----------------------------------------------------------------------
	-- 根据索引值获取坐标
	local function getPos(index)
		local xPos, yPos = 0, 0
		if "H" == mDirection then		-- 水平滚动
			xPos = mXPosTable[math.ceil((index + 1)/mBlockSize)]
			yPos = mYPosTable[(index%mBlockSize) + 1]
		elseif "V" == mDirection then	-- 垂直滚动
			xPos = mXPosTable[(index%mBlockSize) + 1]
			yPos = mYPosTable[math.ceil((index + 1)/mBlockSize)]
		end
		return xPos, yPos
	end
	----------------------------------------------------------------------
	-- 单元格是否需要隐藏
	local function isNeedHide(xPos, yPos)
		if "H" == mDirection then		-- 水平滚动
			local leftScrollViewPosX = math.abs(mScrollView:getInnerContainer():getPosition().x)
			local rightScrollViewPosX = leftScrollViewPosX + mScrollView:getSize().width
			return xPos < leftScrollViewPosX - mCellW*mViewBlocksH/2 or xPos > rightScrollViewPosX + mCellW*mViewBlocksH/2
		elseif "V" == mDirection then	-- 垂直滚动
			local bottomScrollViewPosY = math.abs(mScrollView:getInnerContainer():getPosition().y)
			local topScrollViewPosY = bottomScrollViewPosY + mScrollView:getSize().height
			return yPos < bottomScrollViewPosY - mCellH*mViewBlocksV/2 or yPos > topScrollViewPosY + mCellH*mViewBlocksV/2
		end
		return false
	end
	----------------------------------------------------------------------
	-- 动态显示/隐藏单元格
	local function dynamicShowCell()
		local cells = mScrollView:getChildren()
		local cellCount = cells:count()
		if cellCount > #mDataTable then
			cellCount = #mDataTable
		end
		for i=0, cellCount - 1 do
			local xPos, yPos = getPos(i)
			local cell = tolua.cast(cells:objectAtIndex(i), "UIWidget")
			if 0 == cell:getActionManager():numberOfRunningActionsInTarget(cell:getRenderer()) then
				cell:setPosition(ccp(xPos, yPos))
			end
			if isNeedHide(xPos, yPos) then
				cell:setVisible(false)
			else
				cell:setVisible(true)
			end
		end
	end
	----------------------------------------------------------------------
	-- 列表滚动事件
	local function eventHandler(eventType, widget)
		if "scrolling" == eventType then
			if true == isNeedInitCell(mInitedBlocks) then
				mInitedBlocks = mInitedBlocks + 1
				showBlockCells(mInitedBlocks)
			end
			dynamicShowCell()
		end
		if "function" == type(mScrollCF) then
			mScrollCF(mScrollView, eventType)
		end
	end
	----------------------------------------------------------------------
	init()
	if false == mDynamic then
		mInitBlocks = mTotalBlocks
	end
	initBlockCells()
	mScrollView:registerEventScript(eventHandler)
	if "H" == mDirection then		-- 水平滚动
		mScrollView:jumpToLeft()
	elseif "V" == mDirection then	-- 垂直滚动
		mScrollView:jumpToTop()
	end
	return mTotalBlocks, mCells
end
----------------------------------------------------------------------

