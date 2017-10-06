
-------------------------------------
--作者：李慧琴
--说明：战斗奖励界面
--时间：2014-1-23
-------------------------------------
LayerFightReward = {
}
local	mLayerFightRewardRoot = nil
local  	reward1Bg 	 = nil            -- 奖励一背景
local 	reward2Bg    = nil            -- 奖励二背景
local 	reward3Bg    = nil            -- 奖励三背景
local 	responseInfo = nil            --保存传递过来的信息
local 	curOnclick 	 = 0		      --当前点击ID
local  	sureBtn                       --确定按钮
local   allTb ={"false","false","false"}
local   secondItem ={}				--第二个物品的信息
local 	times = 1					--表示是第几次进入某个判断
local 	needMoney = 0				--本副本第二次购买需要花费的魔石
local	mPositionTb = {}			--保存三张牌的原始位置
local	mHight = 0
LayerAbstract:extend(LayerFightReward)

--预先加载32图
function LayerFightReward.loadResource()
	--herochoose_bg_2.png
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_01.png")
end

-------------------------------------------翻牌-------动画-----------------------------------------------------
--CCOrbitCamera * CCOrbitCamera::create(float t, float radius, float deltaRadius, float angleZ, float deltaAngleZ, float angleX, float deltaAngleX)
--参数分别为旋转的时间，起始半径，半径差，起始z角，旋转z角差，起始x角，旋转x角差

--翻牌效果
function  turnBack(callBackFunc)
    local orbit1=CCOrbitCamera:create(0.3,1,0,0,90,0,0)
    local callBack=CCCallFuncN:create(callBackFunc)
    local orbit2=CCOrbitCamera:create(0.3,1,0,270,90,0,0)
    local array=CCArray:createWithCapacity(10)
    array:addObject(orbit1)
    array:addObject(callBack)
    array:addObject(orbit2)
    local action = CCSequence:create(array)
	return action
end

--[[
 function turnDelayBack()
	local delay = CCDelayTime: create(0.5)
	local orbit1=CCOrbitCamera:create(0.3,1,0,0,90,0,0)
    local callBack=CCCallFuncN:create(NoClickCallBack)
    local orbit2=CCOrbitCamera:create(0.3,1,0,270,90,0,0) 
	local array=CCArray:createWithCapacity(10)
	array:addObject(delay)
    array:addObject(orbit1)
    array:addObject(callBack)
    array:addObject(orbit2)
    local action = CCSequence:create(array)
    return action
end
]]--
--------------------------------------------------------界面展示-------------------------------------------
--返回点击的物品的widget
local function getButtonByIndex(index) 
	if index == 1 then 
		return reward1Bg
	elseif index == 2 then 
		return reward2Bg
	elseif index == 3 then 
		return reward3Bg 
	end
end

--翻牌效果回调函数(刚显示时的翻转)（界面展示）
local function  objectResetCallBack(sender)
	reward1Bg:removeAllChildren()
	reward2Bg:removeAllChildren()
	reward3Bg:removeAllChildren()
	reward1Bg:loadTexture("fightreward_item_back.png")
	reward2Bg:loadTexture("fightreward_item_back.png")
	reward3Bg:loadTexture("fightreward_item_back.png")
end

--刚显示时，加载品质框和物品（界面展示）
local function setBackground()
	for key,value in pairs(responseInfo.ratio_items) do
		rewardBg =  mLayerFightRewardRoot:getWidgetByName(string.format("ImageView_%d",66+key))    --背景框
		tolua.cast(rewardBg,"UIImageView")
		FightOver_addQuaIconByRewardId(value.reward_id,rewardBg,value.amount)
		rewardBg:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.0),turnBack(objectResetCallBack)))	
    end	
	local function touch()
		reward1Bg:setTouchEnabled(true)
		reward2Bg:setTouchEnabled(true)
		reward3Bg:setTouchEnabled(true)
	end		
	rewardBg:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2.0),CCCallFuncN:create(touch)))
end

--没被点击的图片，上下移动的动作
local function  moveUpAndDownAction()
	local action1 = CCMoveBy:create(1.0,ccp(0,20))
	local action2 = CCMoveBy:create(1.0,ccp(0,-20))
	local action3 = CCDelayTime:create(0.5)
	local action4 = CCSequence:createWithTwoActions(action1, action2) 
	local action5 = CCRepeatForever:create(CCSequence:createWithTwoActions(action4,action3))
	return action5
end

--上下移动完后，返回自己原来的位置
local function backToPosition()
	for key,value in pairs(allTb) do
		if value == "false" then
			local widget = getButtonByIndex(key)
			widget:stopAllActions()
			local action1 = CCMoveTo:create(0.1,ccp(mPositionTb[key].x,mHight))					--回到原来的位置？？？？？？？？？？
			widget:runAction(action1)	
		end
	end
end

--没被点击的图片，上下移动
local  function  moveUpAndDown(cancle)
	if cancle == 2 then
		for key, value in pairs(allTb) do
			if curOnclick == key then
				 allTb[key] = "false"
			end
		end
	end
	local count = 0
	for key,value in pairs(allTb) do
		if value == "false" then
			count =count+1
		end
	end	
	for key,value in pairs(allTb) do
		if value == "false" then
			local widget =getButtonByIndex(key)
			if count == 2 then	
				widget:setTouchEnabled(true)
			elseif count == 1 then
				reward1Bg:setTouchEnabled(false)
				reward2Bg:setTouchEnabled(false)
				reward3Bg:setTouchEnabled(false)
			end
			local action =moveUpAndDownAction()
			widget:runAction(action) 
		end
	end
	
end


--[[
--点击图片信息，查看对应的信息
local function ItemInfoAction(types,widget)
	if types == "releaseUp" then
		CommonFunc_showInfo(0, widget:getTag(), 0, nil, 1)
	end
end
]]--

--为背面后，点击图片触发的函数，再次转过来（界面展示）
local function  clickCallBack (sender)

	local clickCount = 0
	for key,value in pairs(allTb)do
		if value == "true" then
			clickCount = clickCount +1
		end
	end
	local itemID,amount
	if clickCount == 1 then					-- 点击第一次翻牌时
		itemID = responseInfo.final_item.reward_id	--	奖励id
		amount = responseInfo.final_item.amount
	elseif  clickCount == 2 then			-- 花魔石进入时
		itemID = secondItem.reward_id
		amount = secondItem.amount
	end
	local  curWidget = getButtonByIndex(curOnclick)
	curWidget:removeAllChildren()
	curWidget:setTag(itemID)
	
	FightOver_addQuaIconByRewardId(itemID,curWidget,amount)
	
	if clickCount == 1 then
		for key,value in pairs(allTb)do
			local  curWidget = getButtonByIndex(key)
			curWidget:setTouchEnabled(true)	
			if value == "true" then
				--长按功能
				local function clickSkillIcon(curWidget)
					showLongInfoByRewardId(itemID,curWidget)
				end
				
				local function clickSkillIconEnd(curWidget)
					longClickCallback_reward(itemID,curWidget)
				end
				
				UIManager.registerEvent(curWidget, nil, clickSkillIcon, clickSkillIconEnd)
			
				--curWidget:registerEventScript(ItemInfoAction)
			end
		end
	end
	
	--飘字展示获得的物品
	local rewardItemInfo = LogicTable.getRewardItemRow(itemID)
	Toast.Textstrokeshow(string.format("%s%s%d",GameString.get("PUBLIC_HUO_DE"),rewardItemInfo.name,amount),ccc3(255,255,255),ccc3(0,0,0),30)
	

	turnPanel = mLayerFightRewardRoot:getWidgetByName("Panel_turn")   --更换提示
	turnPanel:setVisible(true)
	
	local  text9 = turnPanel:getChildByName("Label_32_Copy4")
	tolua.cast(text9,"UILabel")
	text9:setText(tonumber(needMoney))
	
	text = mLayerFightRewardRoot:getWidgetByName("ImageView_160")   --更换提示
	text:setVisible(false)	
	moveUpAndDown(1)
	
	if clickCount ==2 then	
		backToPosition()
		
		for key,value in pairs(allTb)do
			local  curWidget = getButtonByIndex(key)
			if value == "true" then	
				curWidget:setTouchEnabled(true)
				--curWidget:registerEventScript(ItemInfoAction)
				
				--长按功能
				local function clickSkillIcon(curWidget)
					showLongInfoByRewardId(itemID,curWidget)
				end
				
				local function clickSkillIconEnd(curWidget)
					longClickCallback_reward(itemID,curWidget)
				end
				
				UIManager.registerEvent(curWidget, nil, clickSkillIcon, clickSkillIconEnd)
				
				
			else
				curWidget:setTouchEnabled(false)	
			end
		end
		turnPanel = mLayerFightRewardRoot:getWidgetByName("Panel_turn")   --更换提示
		text = mLayerFightRewardRoot:getWidgetByName("ImageView_160")   --更换提示
		turnPanel:setVisible(false)
		text:setVisible(true)
	end
end

--[[
--没有被点击的图片加载对应的图片（界面展示）
function  NoClickCallBack()
	local  cur = 0 
	for k,v in pairs(allTb)do	
		if v == "false" then
			cur = k
			local count1,count2 = 1,1
			local tempResponseInfo = responseInfo.ratio_items
			for key,value in pairs(responseInfo.ratio_items) do
				if #tempResponseInfo ~= 2 then
					if value.item_info   ==  responseInfo.final_item.item_info and value.type == responseInfo.final_item.type and count1 ==1  then
						table.remove(tempResponseInfo,key)	
						count1 =count1 +1
					end	
				end
				if tonumber( value.item_info )== tonumber(secondItem.item_info) and count2 == 1  and value.type == responseInfo.final_item.type  then 	--注意类型转换
					table.remove(tempResponseInfo,key)
					count2 = count2 + 1
				end
			end	
			local  curWidget = getButtonByIndex(cur)
			curWidget:removeAllChildren()
			--设置购买获得的物品图片
			local  function  setData(key)
				if times == key and tempResponseInfo[key] ~= nil then
					addImageByType(tempResponseInfo[key].item_info,tempResponseInfo[key].type,curWidget)
					LayerFightReward.setTips(tempResponseInfo[key].type,tempResponseInfo[key].item_info)
				end
			end
			setData(times)
			times =times+1
			allTb[k]="No"
			return
		end	
	end
end
]]--
--------------------------------------------------------数据处理-------------------------------------------
--[[
--点击完后，另外一个或两个转过来
local  function  delayAction()
	for key,value in pairs(allTb)do
		if value == "false" then
			local  curWidget = getButtonByIndex(key)
			curWidget:runAction(turnDelayBack())		
		end
	end
end
]]--

--点击确认键后，判断背包满
local  function popLayer()
	UIManager.pop("UI_FightReward")
	LayerLvUp.setEnterLvMode(1)
	if UIManager.popBounceWindow("UI_TempPack") ~= true then 
		if UIManager.popBounceWindow("UI_LvUp") ~= true then 	
			FightMgr.cleanup()
			FightMgr.onExit()
			UIManager.retrunMain()
			CopyDelockLogic.enterCopyDelockLayer()
		end
	end 
end

--确认键触发的函数													？？？？？？？？？？？修改，，，，，修改
LayerFightReward.onClick = function(widget)
    local widgetName = widget:getName()
	if "Button_33" == widgetName then  -- 确认键
		sureBtn:setEnabled(true)
		backToPosition()
		popLayer()
		--[[
		delayAction()				--判断另外的一个或两个是否翻转过来
		local action = CCSequence:createWithTwoActions(CCDelayTime:create(2.0),CCCallFuncN:create(popLayer))
		sureBtn:runAction(action)
]]--		
	end
end

--处理抽奖的结果
local function  Handle_req_game_lottery(resp)
	if resp.result == common_result["common_success"]  then		--抽奖成功
		secondItem = resp.second_item
		if nil == mLayerFightRewardRoot then
			return
		end
		local widget = getButtonByIndex(curOnclick)
		widget:runAction(turnBack(clickCallBack))
		reward1Bg:setTouchEnabled(false)
	    reward2Bg:setTouchEnabled(false)
		reward3Bg:setTouchEnabled(false)
	elseif  resp.result == common_result["common_failed"]  then	--抽奖失败
		--Toast.show("魔石不足")
	elseif resp.result == common_result["common_error"]  then	--抽奖出错
		--Toast.show("抽奖出错")
	end 	
end

--请求花费魔石，购买抽奖次数
local  function  reqLottery()
	local tb = req_game_lottery()
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_game_lottery"])
end

--确认按钮的回调函数
local function btnCallBack()
	sureBtn:setEnabled(true)
	sureBtn:setVisible(true)
end

--根据点击的图片，设置相关的数值
local function  setCurClickIndex(widgetName)
	if "ImageView_67" == widgetName then  		-- 奖励一
		curOnclick = 1
	elseif "ImageView_68" == widgetName then  	-- 奖励二
		curOnclick  = 2
	elseif "ImageView_69" == widgetName then  	-- 奖励三
		curOnclick = 3
	end
	for key,value in pairs(allTb) do
		if tonumber( curOnclick) == key then
			 allTb[key] = "true"
		end
	end
end

--点击三个物品，控制的总的函数
local function clicks(type,widget)
	local widgetName = widget:getName()  	
	if type == "releaseUp" then		
		if curOnclick == 0 then
			setCurClickIndex(widgetName)
			reward1Bg:setTouchEnabled(false)
			reward2Bg:setTouchEnabled(false)
			reward3Bg:setTouchEnabled(false)
			getButtonByIndex(curOnclick):runAction(turnBack(clickCallBack))
			sureBtn = mLayerFightRewardRoot:getWidgetByName("Button_33")   -- 奖励一背景
			tolua.cast(sureBtn,"UIButton")
			local action = CCSequence:createWithTwoActions(CCDelayTime:create(1.0),CCCallFuncN:create(btnCallBack))
			sureBtn:runAction(action)	
		else
			backToPosition()
			setCurClickIndex(widgetName)
			reward1Bg:setTouchEnabled(false)
			reward2Bg:setTouchEnabled(false)
			reward3Bg:setTouchEnabled(false)
			local structConfirm ={
			strText =GameString.get("TurnCard",needMoney),		
			buttonCount = 2,
			buttonName = { GameString.get("sure"), GameString.get("cancle")},
			buttonEvent ={reqLottery,moveUpAndDown},
			buttonEvent_Param = {nil,2}
			}
			UIManager.push("UI_ComfirmDialog",structConfirm)    --处理删除好友结果		
		end		
	end
end

function LayerFightReward.destroy()
	local root = UIManager.findLayerByTag("UI_FightReward")
	if root ~= nil then
		root:removeFromParentAndCleanup(true)
		root = nil
	end
	mLayerFightRewardRoot = nil
end

local DROPTIME = 0.6
--主板
local function PlayDropAction(node)

	local distance = 1000
	local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.2))
	array:addObject(CCEaseBackInOut:create(CCMoveBy:create(DROPTIME,CCPointMake(0,(-1)*distance))))
	array:addObject(CCCallFuncN:create(function() 
        playBeamEffect(mLayerFightRewardRoot:getWidgetByName("ImageView_73"),"fightreward_title_03.png","role_upgrade_beam.png")
    end))
	local action = CCSequence:create(array)
	node:runAction(action)--CCRepeatForever:create(action))
end

LayerFightReward.init = function(bundle)
    mLayerFightRewardRoot=UIManager.findLayerByTag("UI_FightReward")

    PlayDropAction(mLayerFightRewardRoot:getWidgetByName("ImageView_151"))

    responseInfo = bundle
	curOnclick = 0
	secondItem ={}	
	times =1
	allTb ={"false","false","false"}
	
	--根据副本的id，去获取花费的魔石

	local copyId = FightDateCache.getData("fd_copy_id")
	local  copyInfo = LogicTable.getCopyById(copyId)   --缺副本id			--这里的id有待改变？？？、？、、
	local  awardInfo =  LogicTable.getCopyAwardById(copyInfo.award)
	needMoney = awardInfo.need_emoney
	
    sureBtn = mLayerFightRewardRoot:getWidgetByName("Button_33")   -- 确认
    tolua.cast(sureBtn,"UIButton")
	sureBtn:setEnabled(false)
    setOnClickListenner("Button_33")  					-- 确认键(如果字可以交互的话，按钮有部分就点不到了)
    reward1Bg= mLayerFightRewardRoot:getWidgetByName("ImageView_67")   -- 奖励一背景
    tolua.cast(reward1Bg,"UIImageView")
	reward1Bg:setTouchEnabled(false)
    reward1Bg:registerEventScript(clicks)
	
	
    reward2Bg= mLayerFightRewardRoot:getWidgetByName("ImageView_68")   -- 奖励二背景
    tolua.cast(reward2Bg,"UIImageView")
	reward2Bg:setTouchEnabled(false)
    reward2Bg:registerEventScript(clicks)
    reward3Bg= mLayerFightRewardRoot:getWidgetByName("ImageView_69")    -- 奖励三背景
    tolua.cast(reward3Bg,"UIImageView")
	reward3Bg:setTouchEnabled(false)
    reward3Bg:registerEventScript(clicks)
	mPositionTb ={}
	table.insert(mPositionTb,reward1Bg:getPosition())
	table.insert(mPositionTb,reward2Bg:getPosition())
	table.insert(mPositionTb,reward3Bg:getPosition())
	setBackground()
	mHight = reward1Bg:getPosition().y
end

--添加固定图片的品质框和物品
function  LayerFightReward_AddGirdWidget(itemStr,amount,callBackFunc,widget)
	if widget == nil then
		widget = UIImageView:create()	
		widget:setName("UIImageView_Gird")
	else
		tolua.cast(widget,"UIImageView")	
	end
	widget:loadTexture(itemStr)
	if callBackFunc ~= nil then
		widget:registerEventScript(callBackFunc)
		widget:setTouchEnabled(true)
	else
		widget:setTouchEnabled(false)
	end
	--添加品质框
	local image = UIImageView:create()
	image:loadTexture("frame_white.png")		--固定的通用的品质框
	image:setName("UIImageView_quality")
	widget:addChild(image)
	--添加数量
	if amount <= 1 then 
	
	else
		path ="GUI/labelatlasimg.png"
		local label = UILabelAtlas:create()
		label:setProperty("01234567890",path, 24, 32, "0")
		label:setStringValue(string.format("X%d",amount))
		label:setAnchorPoint(ccp(1.0,0.5))
		label:setPosition(ccp(40,-32))
		label:setScale(0.65)
		label:setName("LabelAtlas_ItemCount")
		if widget ~= nil then
			widget:addChild(label)
		end
	end
	return widget
end

NetSocket_registerHandler(NetMsgType["msg_notify_game_lottery"],  notify_game_lottery, Handle_req_game_lottery)







  
