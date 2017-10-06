-------------------------------------------------------
-- 描述：列表UIScrollView(自动显示隐藏)
-------------------------------------------------------
function AddFuns(me, class)
	for k, v in pairs(class) do
		me[k] = v
	end
end

UIEasyScrollView = {}

-- scrollView		: ui列表控件
-- tbCell 			: { [1] = ? ,[2] = ? } 
-- createCellFunc 	: 创建单元函数		
-- initItemNum 		: 默认创建行数	def = 5
-- dynamicCreate	: 是否动态创建	def = false
-- cellMargin		: 间距		def = 4
-- row				: 列数		def = 1
-- isAnimation 		: 侧滑动作	def = true
-- cellH			: 单元格高
function UIEasyScrollView:create(scrollView, tbCell, createCellFunc, initItemNum, dynamicCreate, cellMargin, row, isAnimation, cellH)
	
	local self = scrollView or UIScrollView:create()
	AddFuns(self, UIEasyScrollView)
	
	self:reset()
	--attr
	self.row = row or 1
--	if row ~= 1 and row ~= nil then
--		dynamicCreate = false
--	end
	self.createCellFunc = createCellFunc
	self.tbCell = tbCell
	self.cellMargin = cellMargin or 4	--间距
	self.initItemNum = initItemNum		--初始数量
	self.isAnimation = isAnimation
	self.cellH = cellH
	
	if isAnimation == nil then 
		isAnimation = true
	end 

	
	self:init()
	self:initListItem( )
	
	if dynamicCreate == nil or dynamicCreate == true then
		self:initEvent()
	end
	
	return self
end

--初始化列表属性
function UIEasyScrollView:init()
	
	local cellNum = 0
	
	for key, var in pairs(self.tbCell) do
		cellNum = cellNum + 1
	end
	
	self:setTouchEnabled(true)
	self:setBounceEnabled(false)
	
	for key, var in pairs(self.tbCell) do
		if var ~= nil then
			local view = self.createCellFunc(var)
			local viewSize = view:getSize()
			local height = self.cellH or viewSize.height
			local width = self:getInnerContainerSize().width
			
			self.cellPosX = {}
			for var=1, self.row do
				local cellWidth = width / self.row
				self.cellPosX[var] = cellWidth / 2 + cellWidth*(var-1)
			end
			self.cellHeight = height + self.cellMargin
			self.showCount = (math.ceil( self:getSize().height / self.cellHeight )+1 )*self.row
			local height = self.cellHeight * math.ceil(cellNum / self.row) + self.cellMargin
			self:setInnerContainerSize( CCSizeMake(width,height) )   --inerSize.height = 
			break
		end
	end
	
end

--初始化列表初始条目
function UIEasyScrollView:initListItem()
	
	local size = self:getInnerContainerSize()
	
	self.cellIndex = 1
	
	local actionDistance = 0
	
	if self.isAnimation ~= false then 
		actionDistance = size.width
	end 
	
	for key, var in pairs(self.tbCell) do
		if self.cellIndex <= self.initItemNum then
			local view = self.createCellFunc(var)
			local viewSize = view:getSize()
			local height = self.cellH or viewSize.height
			
			local index = self.cellIndex%self.row
			if self.cellIndex%self.row == 0 then
				index = self.row
			end
			local posX = self.cellPosX[index] + actionDistance
			
			local col = math.ceil(self.cellIndex / self.row)
			local posY = (size.height - (height/2 + self.cellMargin)) - (col - 1) * (height + self.cellMargin)
			view:setPosition(ccp( posX ,posY) )
			self:addChild(view)
			local mTime = (self.cellIndex-1)*0.2
			if mTime >= 1.2 then
				mTime = 1.2
			end
			local moveAction = CCMoveBy:create(0.1 + mTime,ccp(-size.width , 0))
			if self.isAnimation ~= false then 
				view:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1),CCEaseExponentialOut:create(moveAction)))
			end 
			
			self.cellIndex = self.cellIndex + 1
		end
	end
	
	self:jumpToTop()
end

--初始化列表事件
function UIEasyScrollView:initEvent(  )
--	self:isNeedToReleaseCell(  )
	local function eventHandler(eventType)
		if eventType == "scrolling" then
			if self:isNeedToCreateCell() then
				self:createNewCell()
			end
			
			self:isNeedToReleaseCell()
		end
	end
	self:registerEventScript(eventHandler)
end

--是否需要新建cell
function UIEasyScrollView:isNeedToCreateCell(  )

	local pos = self:getInnerContainer():getPosition()
	local views = self:getChildren()

	local lastView = views:objectAtIndex(views:count()-1)
	local y = tolua.cast(lastView,"UIWidget"):getPosition().y
	
	local absy = math.abs(pos.y)
--	print("absy   "..absy.." "..y.."  self.cellIndex  "..self.cellIndex)
	if ((absy < y + 40 and absy > y - 40) or absy <= y) and self:getCellByIndex(self.cellIndex) then
		return true
	end
	return false
end

--创建新cell
function UIEasyScrollView:createNewCell(  )
	local size = self:getInnerContainerSize()
	local view = self.createCellFunc(self:getCellByIndex(self.cellIndex))
	local viewSize = view:getSize()
	local height = self.cellH or viewSize.height
	
--	print("self.cellIndex  "..self.cellIndex.."   self.row  "..self.row)
	local index = self.cellIndex%self.row
	if index == 0 then
		index = self.row
	end
	local posX = self.cellPosX[ index]
	local col = math.ceil(self.cellIndex / self.row)
	local posY = (size.height - (height/2 + self.cellMargin)) - (col - 1) * (height + self.cellMargin)
	view:setPosition(ccp(posX, posY))
	self:addChild(view)
	
	self.cellIndex = self.cellIndex + 1
end

--是否有可隐藏的item
function UIEasyScrollView:isNeedToReleaseCell(  )
	local x1 = self:getInnerContainer():getPosition().y
	local x2 =  self:getInnerContainerSize().height
	if x1 < -x2 + self:getSize().height then
		x1 = -x2 + self:getSize().height
	elseif x1 > 0 then
		x1 = 0
	end
	local x =  x1 + x2
	local index = math.ceil( x / self.cellHeight ) * self.row
	local views = self:getChildren()
	local count = views:count()
	
	for var=1, count do
		if var < index - self.showCount or var > index then
			local view = views:objectAtIndex(var-1)
			tolua.cast(view,"UIWidget")
			view:setVisible(false)
		else
--			print("show index  "..var)
			tolua.cast(views:objectAtIndex(var-1),"UIWidget"):setVisible(true)
		end
	end
--	print("count  "..self.showCount.. "  index  "..index)
	
end

--释放cell
--function UIEasyScrollView:releaseCell(  )
--
--	local views = self:getChildren()
--	
--	for var=1, views:count() do
--		local view = views:objectAtIndex(var-1)
--		
--	end
--	
--end


function UIEasyScrollView:getCellByIndex(  )
	local i = 1
	for key, var in pairs(self.tbCell) do
		if i == self.cellIndex then
			return var		
		end 
		i = i + 1
	end
end

--function UIEasyScrollView:updateCellByIndex(  )
--
--	local views = self:getChildren()
--	local lastView = views:objectAtIndex( id + 1 )
--
--end

function UIEasyScrollView:sort( fnSortList )
	self.tbCell:sortMore(unpack(fnSortList))
	self:reset()
	self:init()
	self:initListItem( initItemNum )
	self:initEvent()
end

function UIEasyScrollView:_reBuildList( )
	
end


function UIEasyScrollView:reset( )
	self:unregisterEventScript()
	self:removeAllChildren()
	self:setInnerContainerSize(self:getSize())
end

   