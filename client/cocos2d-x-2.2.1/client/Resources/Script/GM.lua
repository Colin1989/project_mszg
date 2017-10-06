----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2014-5-13
-- 描述：GM工具
----------------------------------------------------------------------
LayerGM = {}
LayerAbstract:extend(LayerGM)
local mCmdTextField = nil			-- 命令输入框
local mValueTextField = nil			-- 命令参数输入框

local mGmText = {"经验","金币","魔石","召唤石","战绩（积分）","荣誉","物品","符文",
				"碎片","充值(Windows--4001--4006)","战魂","友情点","副本(全开启:0)","天梯积分","vip经验"}

-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_GM")
	end
end

-- 点击确定按钮
local function clickSureBtn(typeName, widget)
	if "releaseUp" == typeName then
		local cmdType = mCmdTextField:getTag()
		local valueStr = mValueTextField:getStringValue()
		-- 过滤
		if gm_opt_type["gm_opt_item"] == cmdType then
			if false == LogicTable.IsExistItemID(valueStr) then
				CommonFunc_CreateDialog( GameString.get("GM_ItemIdError"))
				return
			end
		end
		-- 请求
		if nil ~= cmdType and "" ~= valueStr then
			LayerGM.requestGmOptition(cmdType, valueStr)
		end
	end
end

-- 点击命令选项
local function clickCmdItem(typeName, widget)
	if "releaseUp" == typeName then
		local cmdItem = tolua.cast(widget, "UILabel")
		mCmdTextField:setTag(cmdItem:getTag())
		mCmdTextField:setText(cmdItem:getStringValue())
	end
end

-- 初始化
LayerGM.init = function()
	local rootNode = UIManager.findLayerByTag("UI_GM")
	-- 关闭按钮
	local closeBtn = tolua.cast(rootNode:getWidgetByName("close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	-- 确定按钮
	local sureBtn = tolua.cast(rootNode:getWidgetByName("sure"), "UIButton")
	sureBtn:registerEventScript(clickSureBtn)
	-- 输入框
	mCmdTextField = tolua.cast(rootNode:getWidgetByName("TextField_23"), "UITextField")
	mValueTextField = tolua.cast(rootNode:getWidgetByName("TextField_24"), "UITextField")
	-- 命令滚动条
	local scrollView = tolua.cast(rootNode:getWidgetByName("ScrollView_29"), "UIScrollView")
	local cmdItemList = {}
	for key, value in pairs(gm_opt_type) do
		local cmdItem = UILabel:create()
		cmdItem:setFontSize(40)
		cmdItem:setColor(ccc3(0, 0, 139))
		cmdItem:setTag(value)
		--cmdItem:setText(key)
		cmdItem:setText(mGmText[value])
		cmdItem:setTouchEnabled(true)
		cmdItem:registerEventScript(clickCmdItem)
		table.insert(cmdItemList, cmdItem) 
	end
	setAdapterGridView(scrollView, cmdItemList, 1, 0)
end

-- 请求GM命令
LayerGM.requestGmOptition = function(optType, optValue)
	local req = req_gm_optition()
	req.opt_type = tonumber(optType)
	req.value = tonumber(optValue)
	NetHelper.sendAndWait(req, nil)
end

