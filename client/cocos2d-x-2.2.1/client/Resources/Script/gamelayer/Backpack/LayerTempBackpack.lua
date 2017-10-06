-- 临时背包
LayerTempBackpack = {}
local mRowCount = 3			-- 每一行格子数量
local mGridWidth = 106		-- 背包格子宽
local mGridHeight = 106		-- 背包格子高
local chatTextWidth = 418

LayerAbstract:extend(LayerTempBackpack)

-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_TempPack")
		if UIManager.popBounceWindow("UI_LvUp") ~= true then 
			if UIManager.isAllUIEnabled() == false then --如果在战斗界面
				LayerLvUp.setEnterLvMode(1)
				
				FightMgr.onExit()
				UIManager.retrunMain()
				CopyDelockLogic.enterCopyDelockLayer()
			end
		end 		
	end
end

-- 点击清理按钮
local function clickClearBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_TempPack")
		if UIManager.popBounceWindow("UI_LvUp") ~= true then
			FightMgr.onExit()
			LayerBackpack.returnItemUI()
		end
	end
end

-- 初始化
function LayerTempBackpack.init(bundle)
	local rootNode = UIManager.findLayerByTag("UI_TempPack")
	local scrollView = tolua.cast(rootNode:getWidgetByName("ScrollView_833"), "UIScrollView")
	scrollView:setBounceEnabled(false)
	scrollView:removeAllChildren()
	-- 计算拖动层尺寸高度
	local container = scrollView:getInnerContainer()
	local iHeight = math.ceil(#bundle/mRowCount)
	-- 如果只显示一行的话坐标会出错
	if 1 == iHeight then
		iHeight = 2
	end
	iHeight = mGridHeight*iHeight
	container:setSize(CCSize(mGridWidth*mRowCount, iHeight))
	scrollView:setInnerContainerSize(container:getSize())
	-- 显示物品信息
	for i=1, #bundle do
		local val = bundle[i]
		if nil == val then
			break
		end
		local iRow = math.floor((i-1)/mRowCount)	-- 行
		local iCol = math.floor((i-1)%mRowCount)	-- 列
		local iX = iCol*mGridWidth + mGridWidth/2 + 12
		local iY = iHeight-(iRow*mGridHeight + mGridHeight/2)
		-- 格子
		local gridImage = UIImageView:create()
		gridImage:setPosition(ccp(iX, iY))
		gridImage:setTouchEnabled(false)
		gridImage:loadTexture("frame_white.png")
		-- 图标
		local itemRow = LogicTable.getItemById(val.item_id)
		local itemImage = UIImageView:create() 
		itemImage:setTouchEnabled(false)
		itemImage:loadTexture(itemRow.icon)
		gridImage:addChild(itemImage)
		-- 品质框
		local path = CommonFunc_getQualityInfo(itemRow.quality).image
		local qualityImage = UIImageView:create()
		qualityImage:loadTexture(path)
		gridImage:addChild(qualityImage)
		-- 数量
		if 1 ~= val.count then
			local countLabel = UILabelAtlas:create()
			countLabel:setProperty("01234567890", "labelatlasimg.png", 24, 32, "0")
			countLabel:setStringValue(string.format("X%d", val.count))
			countLabel:setPosition(ccp(20, -30))
			gridImage:addChild(countLabel)
		end
		scrollView:addChild(gridImage)
	end
	
	-- 关闭按钮
	local closeBtn = rootNode:getWidgetByName("Button_BACK")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 清理按钮
	local clearBtn = rootNode:getWidgetByName("Button_Clear")
	clearBtn:registerEventScript(clickClearBtn)
end

-- 销毁
function LayerTempBackpack.destroy()
end

-- 处理通知背包溢出网络消息事件
local function handleNotifyPlayerPackExceededResult(packet)
	cclog("收到背包满的消息，加载临时背包界面")
	local tb = {}
	tb.targetName = "UI_TempPack"
	tb.param = packet.new_extra
	UIManager.addBouncedWindow(tb)
end

-- 注册网络消息事件
NetSocket_registerHandler(NetMsgType["msg_notify_player_pack_exceeded"], notify_player_pack_exceeded, handleNotifyPlayerPackExceededResult)

