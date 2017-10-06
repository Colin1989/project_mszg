----------------------------------------------------------------------
-- 作者：李慧琴
-- 日期：2014-3-31
-- 描述：用户协议界面
----------------------------------------------------------------------
LayerRegisterProtocal = {}
LayerAbstract:extend(LayerRegisterProtocal)
local mRootView = nil
local mScrollView = nil
local mSlider = nil
-- local registerProtocal = nil
local chatTextWidth = 500			-- 文本框的宽度
----------------------------------------------------------------------
LayerRegisterProtocal.onClick = function(widget)
	local weightName = widget:getName()
	if weightName == "Button_close" then		
		UIManager.pop("UI_RegisterProtocal")
	end
end
----------------------------------------------------------------------
--根据滑动条的值，设置滚动条的位置
local function sliderAction(typeName, widget)
	local percent = mSlider:getPercent() 	
    local container = mScrollView:getInnerContainer()  
	local height = container:getSize().height
	local kuangH = mScrollView:getSize().height
	container:setPosition(ccp(0, -((100-percent)/100*(height - kuangH))))
end
----------------------------------------------------------------------
--根据滚动条的值，设置滑动条的位置
local function scrollAction(typeName, widget)
	local container = mScrollView:getInnerContainer()
	local height = container:getSize().height
	local pos = container:getPosition()
	local kuangH = mScrollView:getSize().height
	local ratio = math.abs(pos.y)/(height - kuangH) * 100
	mSlider:setPercent(100 - ratio)	
end

--文本模式 auto -> custom
local function LableAutoConverterCustom(label,textWidth)
    local AutoSize = label:getContentSize()
    -- print("AutoSize",AutoSize.width,AutoSize.height)
    local line = AutoSize.width / textWidth
    --取上限值 2.1 取 3.0
    line = math.ceil(line)
    -- print("line",line)
    label:ignoreContentAdaptWithSize(true)
    label:setTextAreaSize(CCSize(textWidth,line*AutoSize.height))
    label:setSize(CCSize(textWidth,line*AutoSize.height))
	
	-- local size = label:getContentSize()
    -- print("size",size.width,size.height)
end

--------------------------------------------------------------------------------------
-- 更新滚动层尺寸
LayerRegisterProtocal.updateScrollViewSize = function(scroll)
    local scrollSize = scroll:getSize()
	
    -- 遍历cell
    local sumheight = 0  --总高度
    local array = scroll:getChildren()
    for i=0,array:count()-1 do
        local node = array:objectAtIndex(i)
        tolua.cast(node,"UIWidget")
		local x = node:getPosition().x
		local y = node:getPosition().y
        sumheight = sumheight + node:getSize().height
    end
	
	if scrollSize.height < sumheight then
		scroll:setInnerContainerSize(CCSize(scrollSize.width,sumheight))
	-- else
		-- scroll:setInnerContainerSize(CCSize(scrollSize.width, scroll:getContentSize().height))
    end
    
    -- 关联拖动条
    -- local Slider_110 = self:cast("Slider_110")
    -- CommonFunc_getSlider(Slider_110,scroll)
    
    -- if Slider_110:getPercent() >= 90 then
        -- scroll:jumpToBottom()
        -- Slider_110:setPercent(100)
    -- end
    
    scroll:doLayout()
	LayerRegister.removeLoading()
end

-------------------------------------------------------------------------------------
-- 添加cell
LayerRegisterProtocal.addScrollView = function(node)
    local scroll = tolua.cast(mRootView:getWidgetByName("ScrollView_content"), "UIScrollView")
    scroll:addChild(node)
    -- scroll:addRenderer(node)
    LayerRegisterProtocal.updateScrollViewSize(scroll)
end

---------------------------------------------------------------------------------------------
-- 更新控件尺寸
LayerRegisterProtocal.updatePanelSize = function(node)
	local label = CommonFunc_getNodeByName(node,"Label_text")
	local width = label:getContentSize().width
	local height = label:getContentSize().height
	node:setSize(CCSize(width,height))
end

----------------------------------------------------------------------
-- 创建用户协议文本UI
local function createTextLabel(text)
	local totalLine = 1
	local x = 0
	local y = 0
	local maxHight = 0
	local node = UILayout:create()
	local label = CCLabelBMFont:create(text, "register_protocal.fnt")
	label:setAnchorPoint(ccp(0.0, 0.0))
	node:addRenderer(label, 20)
	local labelSize = label:getContentSize()
	if labelSize.height > maxHight then
		maxHight = labelSize.height
	end
	-- 换行
	if x + labelSize.width > chatTextWidth then
		x = 0
		y = y - maxHight
		maxHight = 0
		totalLine = totalLine  + 1
	end
	
	local width = label:getContentSize().width
	local height = label:getContentSize().height
	node:setSize(CCSize(width,height))
	
	-- x = x + labelSize.width/2
	-- label:setPosition(ccp(x, y))
	-- x = x + labelSize.width/2
	-- LayerRegisterProtocal.updatePanelSize(node)
	LayerRegisterProtocal.addScrollView(node)
	
	-- return node
end

----------------------------------------------------------------------
-- 初始化
LayerRegisterProtocal.init = function ()
	mRootView = UIManager.findLayerByTag("UI_RegisterProtocal")
	setOnClickListenner("Button_close")
	-- 滚动层
	mScrollView = tolua.cast(mRootView:getWidgetByName("ScrollView_content"), "UIScrollView")
	mScrollView:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	mScrollView:removeAllChildren()
	
	local allProtocal = LogicTable.getRegisterProtocal()
	createTextLabel(allProtocal[1].text)
end
----------------------------------------------------------------------

