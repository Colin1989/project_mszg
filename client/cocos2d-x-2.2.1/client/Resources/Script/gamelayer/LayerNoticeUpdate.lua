--region LayerNoticeUpdate.lua
--Author : songcy
--Date   : 2014/11/12

LayerNoticeUpdate = {}
LayerAbstract:extend(LayerNoticeUpdate)

local mRootView = nil
local updateNotice = nil

--聊天文本框的宽度
local chatTextWidth = 500

--文本模式 auto -> custom
local function LableAutoConverterCustom(label,textWidth)
    local AutoSize = label:getContentSize()
    print("AutoSize",AutoSize.width,AutoSize.height)
    local line = AutoSize.width / textWidth
    --取上限值 2.1 取 3.0
    line = math.ceil(line)
    print("line",line)
    label:ignoreContentAdaptWithSize(true)
    label:setTextAreaSize(CCSize(textWidth,line*AutoSize.height))
    label:setSize(CCSize(textWidth,line*AutoSize.height))
    
    -- local size = label:getContentSize()
    -- print("size",size.width,size.height)
end

--------------------------------------------------------------------------------------
-- 更新滚动层尺寸
LayerNoticeUpdate.updateScrollViewSize = function(scroll) 
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
    end
    -- print("~~~~~~scroll",scrollSize.width,scrollSize.height,sumheight)
    
    -- 关联拖动条
    -- local Slider_110 = self:cast("Slider_110")
    -- CommonFunc_getSlider(Slider_110,scroll)
    
    -- if Slider_110:getPercent() >= 90 then
        -- scroll:jumpToBottom()
        -- Slider_110:setPercent(100)
    -- end
    
    scroll:doLayout()
end

-------------------------------------------------------------------------------------
-- 添加cell
LayerNoticeUpdate.addScrollView = function(node)
    local scroll = tolua.cast(mRootView:getChildByName("ScrollView_list"),"UIScrollView")
    scroll:addChild(node)
    LayerNoticeUpdate.updateScrollViewSize(scroll)
end

---------------------------------------------------------------------------------------------
-- 更新克隆的控件尺寸
LayerNoticeUpdate.updatePanelCloneSize = function(node)
	local label = CommonFunc_getNodeByName(node,"Label_text")
	local width = label:getContentSize().width
	local height = label:getContentSize().height
	node:setSize(CCSize(width,height))
end

--------------------------------------------------------------------------------------
-- 创建更新公告文本UI
LayerNoticeUpdate.createTextLabel = function()
	local node = UILayout:create()
	-- node:setAnchorPoint(ccp(0.0, 1.0))
	local label = UILabel:create()
	label:setName("Label_text")
	label:setAnchorPoint(ccp(0.0, 0.0))
	label:setFontSize(25)
	label:setText(updateNotice.text)
	label:setFontName("fzzdh.TTF")
	LableAutoConverterCustom(label, chatTextWidth)
	-- label:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	-- label:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	node:addChild(label)
	
	LayerNoticeUpdate.updatePanelCloneSize(node)
	LayerNoticeUpdate.addScrollView(node)
	
	return node
end

-----------------------------------------初始化---------------------------
LayerNoticeUpdate.init = function(rootView)
	mRootView = rootView
	if mRootView == nil then
		return
	end
	updateNotice = nil
	local allNotice = LogicTable.getAllUpdateNotice()
	for key, val in pairs(allNotice) do
		if tonumber(val.type) == 1 then
			updateNotice = val
			break
		end
	end
	-- 主标题
	local title = tolua.cast(mRootView:getChildByName("Label_title"), "UILabel")
	title:setText(updateNotice.title)
	-- 返回
	local backBtn = tolua.cast(mRootView:getChildByName("Button_back"), "UIButton")
	backBtn:setVisible(false)
	-- 前往
	local goBtn = tolua.cast(mRootView:getChildByName("Button_go"), "UIButton")
	goBtn:setVisible(false)
	-- 滚动列表
	local scrollView = tolua.cast(mRootView:getChildByName("ScrollView_list"), "UIScrollView")
	scrollView:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	scrollView:removeAllChildren()
	-- scrollView:registerEventScript(clickScrollView)
	
	LayerNoticeUpdate.createTextLabel()
end

-------------------------------------------销毁---------------------------
LayerNoticeUpdate.destroy = function()
	mRootView = nil
end

-------------------------------------------销毁---------------------------
LayerNoticeUpdate.setRootNil = function()
	mRootView = nil
end