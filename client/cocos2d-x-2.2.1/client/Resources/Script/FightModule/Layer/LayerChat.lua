--region LayerChat.lua
--Author : shenl
--Date   : 2014/9/19
--UI/战斗 全服聊天界面

LayerChat = setmetatable({},{__mode='k'})
LayerChat["jsonFile"] = "WorldChat_1.json"

LayerChat.rootView = nil
local edBox = nil  -- 对话框
local MsgTb = {}  -- 输入的内容
local Block = {}  -- 屏蔽ID
local worldChat = nil  -- 聊天按钮

-- 上次最后一条消息的纵坐标
local lastMsgY = 0
-- 最后一条消息是否是自己
local lastSelf = false
-- 最后一条消息高度
local lastHeight = 0
-- 记录传递的参数控件
local OpenModel = {}
--每条聊天内容最大字数
local chatStringMax = 30
--聊天最大条数
local chatListMax = 50
--聊天时间间隔
local chatTalkTime = 5
--聊天文本框的宽度
local chatTextWidth = 540
--间隔高度
local chatIntervalHeight = 18
-- 每日免费条数
local chatDailyFree = 5
-- 消息类型
local CHAT_TYPE_SELF = "mt_chat_notice_self"  -- 自己
local CHAT_TYPE_ELSE = "mt_chat_notice_other"  -- 别人
local CHAT_TYPE_SYS = "mt_sys_notice"  -- 系统公告
local CHAT_TYPE_GM = "mt_game_notice"  -- 游戏公告
local CHAT_TYPE_NOTICE = "mt_normal_notice"  -- 普通公告
--颜色
local colorSelfName = ccc3(255,0,0)
local colorElseName = ccc3(255,255,0)
local colorContent = ccc3(0,255,0)
local colorSys = ccc3(0,0,255)

--打开方式
--[[
    "UI"    --通过战斗场景打开
    "WAR"   --通过UI打开
]]--

---------------------------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		if OpenModel.from == "Game" then
			local function callFunc()
				UIManager.pop("UI_WorldChat")
			end
			
			LayerChat.rootView:setVisible(false)
			worldChat:setVisible(true)
			local time_move = 0.3
			local action_move = CCMoveBy:create(time_move,ccp(51,0))
			local action_callFunc = CCCallFunc:create(callFunc)
			local action = CCSequence:createWithTwoActions(action_move,action_callFunc)
			worldChat:runAction(action)
		else
			worldChat:setVisible(true)
			UIManager.pop("UI_WorldChat")
		end
	end
end

---------------------------------------------------------------------------------------------
-- 点击发送按钮
local function sendChatEvent(types,widget)
	if types == "releaseUp" then
		if true == ChatLogic.isShutup() then
			Toast.show(GameString.get("WORLD_CHAT_ERROR_4"))
			return
		end
		
		local msg = edBox:getText()
		local times = ChatLogic.getLeftTimes()
		if LayerChat.IsSeedChatReg(msg) == false then
			return
		end
		
		-- 发送消息
		local function send()
			-- 时间间隔
			if 0 ~= ChatLogic.limitChatRate() then
				Toast.show(GameString.get("WORLD_CHAT_ERROR_3"))
				return
			end
			ChatLogic.requestChatInWorldChannel(msg)
		end
		
		-- 剩余次数为0
		if times == 0 then
			local function SendReBorn()
				--魔石不足
				if CommonFunc_payConsume(2, CHAT_PAY_EMONEY) then
					return
				end
				if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
					UIManager.pop(UIManager.getTopLayerName())
				end
				send()
			end
			local structConfirm = 
			{
				strText = GameString.get("TIMESUP", CHAT_PAY_EMONEY, CHAT_BUY_TIMES),
				buttonCount = 2,
				isPop = false,
				buttonName = {GameString.get("sure"), GameString.get("cancle")},
				buttonEvent = {SendReBorn, nil},		--回调函数
				buttonEvent_Param = {nil, nil}			--函数参数
			}
			UIManager.push("UI_ComfirmDialog", structConfirm)
			return
		end
		
		send()
	end
end

-------------------------------------------------------------------------------------------
-- 点击角色姓名
local function nameClickFunc(types,widget)
	if types == "releaseUp" then
		local key = widget:getTag()
		local id = MsgTb[key].data.speaker_id
		ChatLogic.requestGetRoleDetailInfo(id)
	end
end

-------------------------------------------------------------------------------------------
-- 获取角色信息
local function handleRoleDetailInfo(roleInfo)
	UIManager.push("UI_RoleInfo",roleInfo)
end

--------------------------------------------------------------------------------------------
-- 获取消息发送状态
local function handleSend(bool)
	if LayerChat.rootView == nil then
		return
	end
	if bool == true then
		edBox:setText("")
		-- 剩余次数
		local Label_times = tolua.cast(LayerChat.rootView:getWidgetByName("Label_times"),"UILabel")
		local times = ChatLogic.getLeftTimes()
		Label_times:setText(string.format(GameString.get("REMAINTIMES",times)))
	end
end

------------------------------------------------------------------------------------------------
-- 点击滚动层回调函数
local function scrollCallFunc(types,widget)
	if types == "releaseUp" then
		tolua.cast(widget,"UIScrollView")
		-- local height = widget:getInnerContainer():getSize().height
		local pos = widget:getInnerContainer():getPosition()
		lastMsgY = pos.y
		-- cclog("------------------------------------->height"..height)
		-- cclog("------------------------------------->lastMsgY"..lastMsgY)
		-- cclog("------------------------------------->ratio"..ratio)
	end
end

-------------------------------------------------------------------------------------------
-- 获取消息
local function handlePost()
	if LayerChat.rootView == nil then
		return
	end
	local scroll = tolua.cast(LayerChat.rootView:getWidgetByName("ScrollView_chat"),"UIScrollView")
	scroll:removeAllChildren()
	-- NoticeLogic.popNotice()
	MsgTb = LayerChat.getHistory()
	if MsgTb ~= nil then
		for key,val in pairs(MsgTb) do
			LayerChat.createCell(key)
		end
		
		local height = scroll:getInnerContainer():getSize().height
		local kuangH = scroll:getSize().height
		local pos = scroll:getInnerContainer():getPosition()
		-- if lastSelf == true then
		scroll:jumpToBottom()
		lastMsgY = 0
		-- else
			-- if lastMsgY >= -80 then
				-- scroll:jumpToBottom()
				-- lastMsgY = 0
			-- else
				-- lastMsgY = lastMsgY - lastHeight
				-- if math.abs(lastMsgY) > height - kuangH then
					-- scroll:jumpToTop()
					-- lastMsgY = kuangH - height
				-- else
					-- scroll:getInnerContainer():setPosition(ccp(pos.x, lastMsgY))
				-- end
			-- end
		-- end
		-- cclog("------------------------------------->"..height - kuangH)
		-- cclog("------------------------------------->lastMsgY"..lastMsgY)
	end
end

--------------------------------------------------------------------------------------------
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
    
    local size = label:getContentSize()
    -- print("size",size.width,size.height)
end

------------------------------------------------------------------------------------------
--是否满足条件发送聊天请求
LayerChat.IsSeedChatReg = function(strText)
    if strText == "" or strText == nil then
        Toast.show(GameString.get("WORLD_CHAT_ERROR_1"))  --发送聊天内容不能为空
        return false
    elseif Calculate_Str_len(strText) > chatStringMax then
        Toast.show(GameString.get("WORLD_CHAT_ERROR_2"))  --聊天内容不能超过30个字符
        return false
    end
    return true
end

-------------------------------------------------------------------------------------
-- 添加cell
LayerChat.addScrollView = function(layout)
    local scroll = tolua.cast(LayerChat.rootView:getWidgetByName("ScrollView_chat"),"UIScrollView")
    scroll:addChild(layout)
    LayerChat.updateScrollViewSize(scroll)
end

-------------------------------------------------------------------------------------
-- 删除cell
LayerChat.delScrollView = function(index)
    print("删除cell")
    local scroll = tolua.cast(LayerChat.rootView:getWidgetByName("ScrollView_chat"),"UIScrollView")
    local array = scroll:getChildren()
    local node = array:objectAtIndex(index-1)
    tolua.cast(node,"UIWidget")
    node:removeFromParent()
    LayerChat.updateScrollViewSize(scroll)
end

--------------------------------------------------------------------------------------
-- 更新滚动层尺寸
LayerChat.updateScrollViewSize = function(scroll) 
    local scrollSize = scroll:getSize()
	
    --遍历cell
    local sumheight = 0  --总高度
    local array = scroll:getChildren()
	
    for i=0,array:count()-1 do
        local node = array:objectAtIndex(i)
        tolua.cast(node,"UIWidget")
        sumheight = sumheight + node:getSize().height
    end
	
    if scrollSize.height < sumheight then
		scroll:setInnerContainerSize(CCSize(scrollSize.width, sumheight))
	else
		scroll:setInnerContainerSize(CCSize(scrollSize.width, scroll:getContentSize().height))
    end
	
    -- print("~~~~~~scroll",scrollSize.width,sumheight)
    
    --关联拖动条
    -- local Slider_110 = self:cast("Slider_110")
    -- CommonFunc_getSlider(Slider_110,scroll)
    
    -- if Slider_110:getPercent() >= 90 then
        -- scroll:jumpToBottom()
        -- Slider_110:setPercent(100)
    -- end
    
    scroll:doLayout()
end

----------------------------------------------------------------------------------------------
-- 分析
LayerChat.analyzeChatData = function(typedef)
    local cloneName = nil
    if typedef == CHAT_TYPE_SELF then
        cloneName = "Panel_Cell_Self"
    elseif typedef == CHAT_TYPE_ELSE then
        cloneName = "Panel_Cell_Else"
    elseif typedef == CHAT_TYPE_SYS then
        cloneName = "Panel_Cell_Sys"
	elseif typedef == CHAT_TYPE_GM or typedef == CHAT_TYPE_NOTICE then
		cloneName = "Panel_Cell_GM"
    else
        assert(false,"消息类型错误")
    end
	
    return cloneName
end

-------------------------------------------------------------------------------------
-- 创建cell
LayerChat.createCell = function(key)
	if LayerChat.rootView == nil then
		return
	end
	
	local typedef = NoticeLogic.checkType(MsgTb[key])
	local cloneName = LayerChat.analyzeChatData(typedef)
		
	local widgetBackup = LayerChat.rootView:getWidgetByName(cloneName)
    local cloneUI = widgetBackup:clone()
	widgetBackup:retain()
	
    if typedef == CHAT_TYPE_SELF then
        cloneUI = LayerChat.createCellSelf(cloneUI,key)
    elseif typedef == CHAT_TYPE_ELSE then
        cloneUI = LayerChat.createCellElse(cloneUI,key)
    elseif typedef == CHAT_TYPE_SYS or typedef == CHAT_TYPE_GM or typedef == CHAT_TYPE_NOTICE then
        cloneUI = LayerChat.createCellSys(cloneUI,key,typedef)
    end
	
	if key == #MsgTb then
		lastHeight = cloneUI:getSize().height
		if typedef == CHAT_TYPE_SELF then
			lastSelf = true
		elseif typedef ~= CHAT_TYPE_SELF then
			lastSelf = false
		end
	end
	
    --计算cell size
    local Label_text = tolua.cast(CommonFunc_getNodeByName(cloneUI,"Label_text"),"UILabel")
    LableAutoConverterCustom(Label_text, chatTextWidth)
    LayerChat.updatePanelCloneSize(cloneUI,typedef)
	
    LayerChat.addScrollView(cloneUI)
    return cloneUI
end

---------------------------------------------------------------------------------------------
-- 更新克隆的控件尺寸
LayerChat.updatePanelCloneSize = function(cloneUI,typedef)
	if typedef == CHAT_TYPE_SELF or typedef == CHAT_TYPE_ELSE then
		local label = CommonFunc_getNodeByName(cloneUI,"Label_text")
		local name = CommonFunc_getNodeByName(cloneUI,"ImageView_title")
		local width = cloneUI:getContentSize().width
		local height = label:getContentSize().height + name:getSize().height
		cloneUI:setSize(CCSize(width,height + chatIntervalHeight))
	elseif typedef == CHAT_TYPE_SYS or typedef == CHAT_TYPE_GM or typedef == CHAT_TYPE_NOTICE then
		local label = CommonFunc_getNodeByName(cloneUI,"Label_text")
		local width = cloneUI:getContentSize().width
		local height = label:getContentSize().height
		cloneUI:setSize(CCSize(width,height + chatIntervalHeight))
	end
end

-----------------------------------------------------------------------------------------------
-- 自己发言
LayerChat.createCellSelf = function(cloneUI,key)
    local ImageView_title = CommonFunc_getNodeByName(cloneUI,"ImageView_title")
	ImageView_title:setTag(key)
    -- ImageView_title:registerEventScript(nameClickFunc)
	
    local Label_name = tolua.cast(CommonFunc_getNodeByName(cloneUI,"Label_name"),"UILabel")
    local Label_text = tolua.cast(CommonFunc_getNodeByName(cloneUI,"Label_text"),"UILabel")
    Label_name:setText(MsgTb[key].data.speaker)
    Label_text:setText(MsgTb[key].data.msg)
    return cloneUI
end

-----------------------------------------------------------------------------------------------
--其他人发言
LayerChat.createCellElse = function(cloneUI,key)
    local ImageView_title = CommonFunc_getNodeByName(cloneUI,"ImageView_title")
	ImageView_title:setTag(key)
    ImageView_title:registerEventScript(nameClickFunc)
	
    local Label_name = tolua.cast(CommonFunc_getNodeByName(cloneUI,"Label_name"),"UILabel")
    local Label_text = tolua.cast(CommonFunc_getNodeByName(cloneUI,"Label_text"),"UILabel")
	Label_text:setTag(key)
	Label_text:setTouchEnabled(true)
	Label_text:registerEventScript(nameClickFunc)
    Label_name:setText(MsgTb[key].data.speaker)
    Label_text:setText(MsgTb[key].data.msg)
    return cloneUI
end

----------------------------------------------------------------------------------------------
-- 系统消息
function LayerChat.createCellSys(cloneUI,key,typedef)
    local Label_text = tolua.cast(CommonFunc_getNodeByName(cloneUI,"Label_text"),"UILabel")
	if typedef == CHAT_TYPE_SYS then
		Label_text:setText(GameString.get("CHAT_SYSTEM")..MsgTb[key].data)
	elseif typedef == CHAT_TYPE_GM or typedef == CHAT_TYPE_NOTICE then
		Label_text:setText(GameString.get("CHAT_NOTICE")..MsgTb[key].data)
	end
    return cloneUI
end

----------------------------------------------------------------------------------------------
-- 刷新聊天框
LayerChat.updateChatView = function()
	handlePost()
end

----------------------------------------------------------------------------------------------
-- 界面初始化
LayerChat.initView = function()
    -- button (send_chat)
     local sendChat = LayerChat.rootView:getWidgetByName("send_chat")
     sendChat:registerEventScript(sendChatEvent)
	
	-- Button_close
	local closeBtn = LayerChat.rootView:getWidgetByName("Button_close")
	closeBtn:registerEventScript(clickCloseBtn)
	
	local label_one = tolua.cast(LayerChat.rootView:getWidgetByName("system_msg_1"),"UILabel")
	label_one:setText(GameString.get("SYSTEM_MSG_1"))
	local label_two = tolua.cast(LayerChat.rootView:getWidgetByName("system_msg_2"),"UILabel")
	label_two:setText(GameString.get("SYSTEM_MSG_2"))
	local label_three = tolua.cast(LayerChat.rootView:getWidgetByName("system_msg_3"),"UILabel")
	label_three:setText(GameString.get("SYSTEM_MSG_3"))
	
	-- 聊天滚动框
	local scroll = tolua.cast(LayerChat.rootView:getWidgetByName("ScrollView_chat"),"UIScrollView")
	scroll:registerEventScript(scrollCallFunc)
    scroll:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	scroll:removeAllChildren()
	
	-- 剩余次数
	local Label_times = tolua.cast(LayerChat.rootView:getWidgetByName("Label_times"),"UILabel")
	local times = ChatLogic.getLeftTimes()
	Label_times:setText(string.format(GameString.get("REMAINTIMES",times)))
	
    -- editbox
    local edBox_bg = LayerChat.rootView:getWidgetByName("chat_content_bg")
	edBox = CommonFunc_createCCEditBox(ccp(0.5,0.5),ccp(0,0),CCSizeMake(416,35),"touming.png",10,chatStringMax,GameString.get("InputChatContent"),kEditBoxInputModeAny,kKeyboardReturnTypeDefault)
	edBox_bg:addRenderer(edBox, 50)
	
	if MsgTb ~= nil then
		for key,val in pairs(MsgTb) do
			LayerChat.createCell(key)
		end
		scroll:jumpToBottom()
	end
end

--------------------------------------------------------------------------------------------------
LayerChat.init = function(_OpenModel)
	LayerChat.rootView =  UIManager.findLayerByTag("UI_WorldChat")
	-- LayerChat.rootView:setPosition(ccp(0,200))
	if _OpenModel ~= nil then
		OpenModel = _OpenModel
		worldChat = OpenModel.rootView:getWidgetByName("world_chat")
		worldChat:setVisible(false)
		if OpenModel.from == "Game" then
			local ImageView = LayerChat.rootView:getWidgetByName("ImageView_31")
			ImageView:setPosition(ccp(320,520))
		end
	end
	-- MsgTb = NoticeLogic.getHistory()
	LayerChat.initView()
end

LayerChat.destroy = function()
    LayerChat.rootView = nil
	OpenModel = {}
	worldChat = nil
	lastSelf = false
	lastMsgY = 0
	lastHeight = 0
	-- MsgTb = {}
end

-- 获取历史记录
LayerChat.getHistory = function()
	local historyTable = {}
	for key, val in pairs(MsgTb) do
		if "mt_chat_notice_other" == NoticeLogic.checkType(val) then
			if false == ChatLogic.isShield(val.data.speaker_id) then
				table.insert(historyTable, val)
			end
		else
			table.insert(historyTable, val)
		end
	end
	return historyTable
end

-- 保存到历史消息队列
LayerChat.pushChatNotice = function(msgData)
	local removeCount = #MsgTb - chatListMax + 1
	for i=1, removeCount do
		table.remove(MsgTb, 1)
		if not tolua.isnull(LayerChat.rootView) then
			LayerChat.delScrollView(1)
		end
	end
	table.insert(MsgTb, msgData)
	if LayerChat.rootView == nil then
		return
	end
	LayerChat.createCell(#MsgTb)
	local scroll = tolua.cast(LayerChat.rootView:getWidgetByName("ScrollView_chat"),"UIScrollView")
	local height = scroll:getInnerContainer():getSize().height
	local kuangH = scroll:getSize().height
	local pos = scroll:getInnerContainer():getPosition()
	if lastSelf == true then
		scroll:jumpToBottom()
		lastMsgY = 0
	else
		if lastMsgY >= -80 then
			scroll:jumpToBottom()
			lastMsgY = 0
		else
			lastMsgY = lastMsgY - lastHeight
			if math.abs(lastMsgY) > height - kuangH then
				scroll:jumpToTop()
				lastMsgY = kuangH - height
			else
				scroll:getInnerContainer():setPosition(ccp(pos.x, lastMsgY))
			end
		end
	end
end

-- 下线 清空信息
local function handleClearData()
	MsgTb = {}
end
EventCenter_subscribe(EventDef["ED_CLEAR_DATA"], handleClearData)

----------------------------------------------------------------------------------------------------
-- EventCenter_subscribe(EventDef["ED_POST"], handlePost)
EventCenter_subscribe(EventDef["ED_CHAT_IN_WORLD"], handleSend)
EventCenter_subscribe(EventDef["ED_ROLE_DETAIL_INFO"], handleRoleDetailInfo)
