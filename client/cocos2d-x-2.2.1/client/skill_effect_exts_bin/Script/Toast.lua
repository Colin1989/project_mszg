----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-3
-- 描述：系统消息提示
----------------------------------------------------------------------

local mWinSize = CCDirector:sharedDirector():getWinSize()
LAYER_ORDER = 200			--toast 渲染层级
Toast = {}

----显示文本 自动消失 
Toast.show = function(text)
	local toast = CCLabelTTF:new()
    toast:init()
    toast:autorelease()
    toast:setFontName("Marker Felt")
    toast:setFontSize(48)
    toast:setString(text)
	
	local action = CCSequence:createWithTwoActions(
	CCDelayTime:create(3.0),
	CCFadeOut:create(1.5))

	toast:setPosition(ccp(mWinSize.width/2,mWinSize.height/2));
	--toast:setAnchorPoint(ccp(-1,-1))
	function FucnC_DeleteThis(sender)
		sender:getParent():removeChild(sender,true)
	end
	
	local action2 = CCSequence:createWithTwoActions(action,CCCallFuncN:create(FucnC_DeleteThis))			
	
	toast:runAction(action2);
    --detalTTf->setScale(2.0f);
	g_rootNode:addChild(toast,LAYER_ORDER)
	
end

----显示任务提示 自动消失
Toast.showTaskTip = function(taskInfo)
	local node = CCNode:create()
	local task = LogicTable.getTaskRow(taskInfo.task_id)
	local str_tb = CommonFunc_split(task.text, "{0}")
	local completeCount = TaskLogic.getTaskCompleteCount(task, taskInfo.args)
	local isFinished = TaskLogic.isTaskFinished(task, taskInfo.args)
	--
	local pos = ccp(0, 0)
	local size = CCSizeMake(0, 0)
	local fontSize = 20
	local color = ccc3(255, 255, 255)
	local label1 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, nil, str_tb[1])
	node:addChild(label1)
	-- 完成数量
	pos.x, pos.y = label1:getPosition()
	size = label1:getContentSize()
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
	else
		color = ccc3(255, 0, 0)		-- 红色
	end
	local label2 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, completeCount.."/"..task.number)
	node:addChild(label2)
	--
	pos.x, pos.y = label2:getPosition()
	size = label2:getContentSize()
	color = ccc3(255, 255, 255)
	local label3 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, str_tb[2])
	node:addChild(label3)
	--
	pos.x, pos.y = label3:getPosition()
	size = label3:getContentSize()
	if true == isFinished then
		color = ccc3(0, 255, 0)		-- 绿色
		local label4 = CommonFunc_createCCLabelTTF(ccp(0, 0.5), ccp(pos.x + size.width, pos.y), nil, fontSize, color, "（已完成）")
		node:addChild(label4)
		pos.x, pos.y = label4:getPosition()
		size = label4:getContentSize()
	end
	--
	local delayTime = CCDelayTime:create(0.6)
	local moveBy = CCMoveBy:create(0.5, ccp(0, 30))
	local callFuncN = CCCallFuncN:create(
		function(sender)
			sender:getParent():removeChild(sender, true)
		end
	)
	local actionArray = CCArray:createWithCapacity(3)
	actionArray:addObject(delayTime)
	actionArray:addObject(moveBy)
	actionArray:addObject(callFuncN)
	node:setPosition(ccp(mWinSize.width/2 - (pos.x + size.width)/2, mWinSize.height/2));
	node:runAction(CCSequence:create(actionArray));
	g_rootNode:addChild(node, LAYER_ORDER)
end

----显示文本跑马灯 自动消失 
Toast.Moveshow = function(text)
	local toast = CCLabelTTF:new()
    toast:init()
    toast:autorelease()
    toast:setFontName("Marker Felt")
    toast:setFontSize(48)
    toast:setString(text)
	
--[[	local action = CCSequence:createWithTwoActions(
	CCDelayTime:create(3.0),				--预留一个闪烁效果
	CCFadeOut:create(1.5))--]]
	local fontWidth = toast:boundingBox().size.width
	
	local action = CCMoveTo:create(3.0, ccp(-1*fontWidth,2*mWinSize.height/3));
	toast:setPosition(ccp(mWinSize.width+fontWidth,2*mWinSize.height/3));
	--toast:setAnchorPoint(ccp(-1,-1))
	function FucnC_DeleteThis(sender)
		sender:getParent():removeChild(sender,true)
	end
	
	local action2 = CCSequence:createWithTwoActions(action,CCCallFuncN:create(FucnC_DeleteThis))			
	
	toast:runAction(action2);
    --detalTTf->setScale(2.0f);
	g_rootNode:addChild(toast,LAYER_ORDER)
end
local function Handle_Error(resp)
	local code = resp.code
	local errorTb = LogicTable.getErrorById(code)
	
	if errorTb == nil then		---先怎么容错
		Toast.show("系统出错")
		return 
	end
	
	print("errorTb.text-------------->",errorTb.text)

	if errorTb.type == "1"	then		-- 普通消息
		local text = string.format(errorTb.text,unpack(resp.Params))
		Toast.show(text)
	elseif errorTb.type == "2"	then 	-- 带对话框
		local text = string.format(errorTb.text,unpack(resp.Params))
		Toast.show(text)
	end
	
end


function Handle_Socket_close (node)
		print("断线了 要重连")
end
-- 心跳查询
local function Handle_headerbeat()
	heartNode = CCNode:create()
	g_rootNode:addChild(heartNode)
	actioN = CCSequence:createWithTwoActions(CCDelayTime:create(5.0),CCCallFuncN:create(Handle_Socket_close))
	heartNode:runAction(actioN)
	print("接收心跳")

end

Toast.initSysMsg=function() 
	NetSocket_registerHandler(NetMsgType["msg_notify_sys_msg"], notify_sys_msg(), Handle_Error)
	--NetSocket_registerHandler(NetMsgType["msg_notify_heartbeat"], notify_heartbeat(), Handle_headerbeat)
end



