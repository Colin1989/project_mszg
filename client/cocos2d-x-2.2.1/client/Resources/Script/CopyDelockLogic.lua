-------------------------------------
--作者：李慧琴
--说明：副本解锁逻辑
--时间：2014-8-19
-------------------------------------
CopyDelockLogic = {}

--底部按钮需要的解锁信息      主城,英雄,任务,好友,商城,设置;

local mOpenDownCopyInfo = {LIMIT_MAIN ,LIMIT_HERO ,LIMIT_MISSION,LIMIT_Social,LIMIT_SHOP,LIMIT_SYSTEM}
local mDownWidgetName ={"mainbtn_main","mainbtn_hero","mainbtn_task","mainbtn_rune","mainbtn_shop","mainbtn_sys"}
local mStartShowUI = false

--中间建筑需要的解锁信息    活动,锻造,历练,公会,符文,排行榜,竞技场		
local mOpenBuildCopyInfo ={LIMIT_ACTIVITY,LIMIT_FORGE,LIMIT_EXP,LIMIT_HERO_UP_LEVEL,LIMIT_SKILL , LIMIT_RANK_LIST,LIMIT_JJC}
local mBuildWidgetName = {"Panel_activity_build","Panel_forge_build","Panel_mission_build","Panel_public_build",
"Panel_inscription_build","Panel_rankingList_build","Panel_jjc_build"}

local mDownCopyInfo = 
{
	["mainbtn_main"] =LIMIT_MAIN ,
	["mainbtn_hero"] =LIMIT_HERO ,
	["mainbtn_task"] =LIMIT_MISSION,
	["mainbtn_rune"] = LIMIT_Social,
	["mainbtn_shop"] = LIMIT_SHOP,
	["mainbtn_sys"] =LIMIT_SYSTEM
}

--中间建筑需要的解锁信息    活动,锻造,历练,公会,符文,排行榜,竞技场		
local mBuildCopyInfo ={["Panel_activity_build"] = LIMIT_ACTIVITY,["Panel_forge_build"] = LIMIT_FORGE,
["Panel_mission_build"] = LIMIT_EXP,["Panel_public_build"] = LIMIT_HERO_UP_LEVEL,["Panel_inscription_build"] = LIMIT_SKILL ,
["Panel_rankingList_build"] = LIMIT_RANK_LIST ,["Panel_jjc_build"] = LIMIT_JJC}


--获得主界面的各个的位置
local buildPosition ={}

--通过副本Id，判断是第几个副本群
CopyDelockLogic.showNumberFBQById = function(fbId)
	local final = 1
	local str = CopyDateCache.getGroupIdByCopyId(fbId) 
	local length = string.len(str)			
	local temp = string.sub(str,length-1,length)		--获得最后两个字符
	local first = string.sub(temp,1,1)					--获得两个字符的第一个字符
	if tonumber(first) == 0 then
		final = string.sub(str,length,length)		--如果第一个字符为0，则去掉第一个字符
	else	
		final = temp	
	end
	return final
end

--显示解锁的副本名字						--各个界面通用的显示信息
CopyDelockLogic.showEnterTipByDelockInfo = function(delockTb)
	if CopyDateCache.getCopyStatus(delockTb.copy_id) ~= "pass" and tonumber(delockTb.copy_id) ~= 1 then
		Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(delockTb.copy_id),delockTb.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		return 
	end
end

--各个界面通用的判断解锁情况(注意副本id为“1”的情况；除了新手，别的都需要排除掉“1”)----------------1表示默认解锁
CopyDelockLogic.judgeYNEnterById = function(copyId)
	if 1 == tonumber(copyId) then
		return true
	end
	local curCopyIdTb = CopyDateCache.getPassCopyId()
	for key,value in pairs(curCopyIdTb) do
		if tonumber(value) == tonumber(copyId) then
			return true
		end
	end
	return false
end

--判断是否在主界面出现解锁界面
CopyDelockLogic.judgeVONInMain = function()
	local curCopyIdTb = CopyDateCache.getPassCopyId()
	local preCopyIdTb = CopyDateCache.getPrePassCopyId()
	if #curCopyIdTb == #preCopyIdTb then	--新手刚进入的时候
		return false
	else
		return true
	end
end 

--进入副本解锁界面									--各个界面通用的进入副本解锁界面
CopyDelockLogic.enterCopyDelockLayer = function()      
	if LayerLvUp.getEnterLvMode() ~= 1 then
		return
	end
	local curCopyId = FightDateCache.getData("fd_copy_id")
	local flag,delockInfo = CopyDelockLogic.showDelockInfoByCopyId(curCopyId)
	if flag == true and CopyDelockLogic.judgeVONInMain() == true then	--判断点击的是不是已经打过的，判断该副本有没有解锁的信息
		mStartShowUI = true
		local temp =  CommonFunc_table_copy_table(CopyDateCache.getPassCopyId())    
		CopyDateCache.setPreCopyId(temp)
		LayerMain.pullPannel()			--回主城
		local function pushAction()
			UIManager.push("UI_CopyDelock",delockInfo)  -- 进入新解锁界面
		end
		local rootNode1 = LayerMain.getLayerRoot()
		local action = CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFuncN:create(pushAction))
		rootNode1:runAction(action)	
	end	
end

CopyDelockLogic.setStartShowUI = function(bShow)
	mStartShowUI = bShow
end

CopyDelockLogic.isStartShowUI = function()
	return mStartShowUI
end

--通过当前的副本id获得解锁的信息和是否显示解锁界面	(战斗结束后) 
CopyDelockLogic.showDelockInfoByCopyId = function(fbId) 
	local flag = false
	local delockTb = {}
	local tb = LogicTable.getAllDelockInfo()
	for key,value in pairs(tb) do
		if tostring(fbId) == value.copy_id then
			local delockInfo = LogicTable.getDelockInfo(tonumber(value.id))
			table.insert(delockTb,delockInfo)
		end
	end
	if #delockTb > 0 then
		flag = true
	else
		flag = false
	end
--	print("CopyDelockLogic.showDelockInfoByCopyI***********",fbId,flag,delockTb)
	return flag,delockTb
end


--判断解锁的副本id，应该飞到的位置、是否显示新（红点）标志、根节点、根节点字符串、控件名					
CopyDelockLogic.judgeFlyToPositionById = function(fbId,index)				--(Delock)
	--保存主界面的所有位置
	local allPositionTb = {}		
	local downPosition = LayerMain.getBtnPosition()
	for key,value in pairs(downPosition) do		
		table.insert(allPositionTb,value)
	end
	for key,value in pairs(buildPosition) do
		table.insert(allPositionTb,value)
	end
	--获得所有的控件名
	local keyTb = {}
	for key,value in pairs(mDownWidgetName) do		
		table.insert(keyTb,value)
	end
	for key,value in pairs(mBuildWidgetName) do
		table.insert(keyTb,value)
	end
	
	local YN,delockInfo = CopyDelockLogic.showDelockInfoByCopyId(fbId)
	local root,rootString = LayerMain.getLayerRoot()
	
	
	if delockInfo[index].id <= 13 and delockInfo[index].id > 6 then				--建筑			(false，这里是为了解锁时，动画先播完再显示红点)
		local root,rootString = LayerMainEnter.getLayerRoot()	
		return allPositionTb[delockInfo[index].id],false,root,rootString,keyTb[ delockInfo[index].id]
	elseif  delockInfo[index].id <= 6 then									--底部
		return allPositionTb[delockInfo[index].id],false,root,rootString,keyTb[delockInfo[index].id]
	--elseif delockInfo[index].id == 28 then				--底部社交(28在别处已经有了)
		--return allPositionTb[6].id,true,root,rootString,keyTb[6]
	elseif  delockInfo[index].id == 23 or delockInfo[index].id == 37 
			or delockInfo[index].id == 38 or delockInfo[index].id == 29 
			or delockInfo[index].id == 30  then			--底部英雄
		return allPositionTb[2],true,root,rootString,keyTb[2]
	elseif delockInfo[index].id == 15 or delockInfo[index].id == 18 or delockInfo[index].id == 16
			 or delockInfo[index].id == 17 or delockInfo[index].id == 28 or delockInfo[index].id == 40 or delockInfo[index].id == 25 then	--建筑副本
		return allPositionTb[9],true,root,rootString,keyTb[9]
--	elseif delockInfo[index].id == 28 then	--建筑活动		
--		return allPositionTb[7],true,root,rootString,keyTb[7]
	elseif delockInfo[index].id == 14 or (delockInfo[index].id >=31 and delockInfo[index].id <= 36) then--英雄殿
		return allPositionTb[10],true,root,rootString,keyTb[10]
	elseif delockInfo[index].id == 19 or delockInfo[index].id == 21 
		   or delockInfo[index].id == 20 or delockInfo[index].id == 22 or delockInfo[index].id == 24 then	--建筑竞技场		
		return allPositionTb[13],true,root,rootString,keyTb[13]	
	elseif delockInfo[index].id == 26 then				--铸造
		return allPositionTb[8],true,root,rootString,keyTb[8]
	elseif  delockInfo[index].id == 39 or delockInfo[index].id == 27 then		--建筑技能
		return allPositionTb[11],true,root,rootString,keyTb[11]
	else
		return allPositionTb[2],true,root,rootString,keyTb[2]
	end	
end

local dowImg = {"mainui_btn_mainui_n.png","mainui_btn_hero_n.png","mainui_btn_task_n.png","mainui_btn_friend_n.png",
				"mainui_btn_busniss_n.png","mainui_btn_setup_n.png"}

--显示红点
CopyDelockLogic.showNewByfbId = function(fbId,index)		--(Delock)
	local flag,delockTb = CopyDelockLogic.showDelockInfoByCopyId(fbId)
	
	for key,value in pairs(delockTb) do
		local position,flag,root,rootString,widgetName = CopyDelockLogic.judgeFlyToPositionById(fbId,key)
		local tipImage,widget,widget_lock
		
		if rootString == "mLayerMainEnterRoot" and index == key then
			tipImage = root:getChildByName((string.format("%s_tip", widgetName)))
			widget = tolua.cast(root:getChildByName(widgetName),"UIImageView")
			widget_lock = tolua.cast(root:getChildByName((string.format("%s_lock", widgetName))),"UIImageView")
			widget_gray = tolua.cast(root:getChildByName((string.format("%s_gray", widgetName))),"UIImageView")
			widget_light = tolua.cast(root:getChildByName((string.format("%s_light", widgetName))),"UIImageView")
			
		--	print("CopyDelockLogic.showNewByfbI**************",widgetName,tipImage,flag)
			if flag == true then    --出现红点（不在主界面）
				tipImage:setVisible(true)
				return
			end
			
			widget:stopAllActions()
		--	widget_lock:stopAllActions()
		--	widget_gray:stopAllActions()
		--	widget_light:stopAllActions()
			--建筑换图（在主界面）
			widget_lock:loadTexture("Lock_01.png")
			widget_lock:setVisible(true)
			widget_lock:setScale(1.0)
			widget_gray:setVisible(true)
			
			local function lockAction()
				--左右摇晃
				local  function lockActionDone()
					widget_lock:loadTexture("Lock_02.png")
				end
				local function leftRightAction()
					local internal = 0.05		--表示旋转持续时间
					local Rotate = CCSequence:createWithTwoActions(CCRotateBy:create(internal,-30),CCScaleBy:create(internal,1.02))
					local Rotate2 = CCSequence:createWithTwoActions(CCRotateBy:create(internal,30),CCScaleBy:create(internal,1.02))
					local scale =  CCSequence:createWithTwoActions(Rotate,Rotate2)
					widget_lock:runAction(CCRepeat:create(scale,4))
				end
				local function showTip()
					tipImage:setVisible(true)
				end
				
				local arr = CCArray:create()
				arr:addObject(CCCallFuncN:create(leftRightAction))
				arr:addObject(CCDelayTime:create(0.8))
				arr:addObject(CCCallFuncN:create(lockActionDone))
				arr:addObject(CCDelayTime:create(0.5))
				arr:addObject(CCHide:create())
				arr:addObject(CCCallFuncN:create(showTip))
				widget_lock:runAction(CCSequence:create(arr))
			end			

			local function buildAction()
				
				local function hideUnuseTexture()
					widget_gray:setVisible(false)
					widget:registerEventScript(enterOtherScene)
				end
				
				local arr = CCArray:create()
				arr:addObject(CCSpawn:createWithTwoActions(CCShow:create(),CCFadeIn:create(1.2)) )
				arr:addObject(CCSpawn:createWithTwoActions(CCCallFuncN:create(hideUnuseTexture),CCFadeOut:create(0.7)))
				widget_light:runAction(CCSequence:create(arr))
			end
		
			local arr =CCArray:create()
			arr:addObject(CCSequence:createWithTwoActions(CCCallFuncN:create(buildAction),CCCallFuncN:create(lockAction)))
			widget_light:runAction(CCSequence:create(arr))
		
		elseif rootString == "mLayerRoot" and index == key then		
			tipImage = root:getWidgetByName((string.format("%s_tip", widgetName)))
			widget = tolua.cast(root:getWidgetByName(widgetName),"UIImageView")
			widget_lock = tolua.cast(root:getWidgetByName((string.format("%s_lock", widgetName))),"UIImageView")
			if flag == true then
				tipImage:setVisible(true)
				return
			end
			widget_lock:setVisible(true)
			
			widget:stopAllActions()
			widget_lock:stopAllActions()
			--左右摇晃
			local  function lockActionDone()
				widget_lock:loadTexture("Lock_02.png")
			end
			local function changeWidgetImg()
				if tonumber(value.id) < 13 then
					widget:loadTexture(dowImg[value.id%13])
				else								--英雄
					widget:loadTexture(dowImg[2])
				end
				LayerMain.bottomBtnListGrey()
			end
			local function widgetAction()
				local action1 = CCSequence:createWithTwoActions(CCShow:create(),CCFadeIn:create(0.5))
				widget:runAction(CCSequence:createWithTwoActions(action1,CCCallFuncN:create(changeWidgetImg)))
			end
			--锁左右摇晃，淡出，并淡入加载图片
			local Rotate = CCSequence:createWithTwoActions(CCRotateBy:create(0.05,-10),CCRotateBy:create(0.05,10))
			local arr = CCArray:create()
			arr:addObject(CCRepeat:create(Rotate,3))
			--arr:addObject(CCDelayTime:create(2.0))
			arr:addObject(CCCallFuncN:create(lockActionDone))
			arr:addObject(CCDelayTime:create(1.0))
			arr:addObject(CCHide:create())
			arr:addObject(CCCallFuncN:create(widgetAction))
			widget_lock:runAction(CCSequence:create(arr))
		end
	end
	
end

--获得底部按钮的解锁副本名和是否已经解锁标志		(main)  （false表示没有锁，true表示锁着呢）
CopyDelockLogic.getNameAndFlagByWidgetName = function(widgetName)
	local name,flag
	name = mDownCopyInfo[widgetName].fbName
	for key,value in pairs(mOpenDownCopyInfo) do
		if  widgetName == mDownWidgetName[key]  then
			zhang = CopyDelockLogic.showNumberFBQById(value.copy_id)
			flag = CopyDelockLogic.judgeYNEnterById(value.copy_id)
			return name,flag,zhang
		end	
	end	
end

CopyDelockLogic.getAllDownFlag = function()
	local flagTb ={}
	for key,value in pairs(mOpenDownCopyInfo) do
		if tonumber(value.copy_id) ~= 1 then
			flag = CopyDelockLogic.judgeYNEnterById(value.copy_id)	
		else
			flag = true
		end 
		table.insert(flagTb,flag)
	end	
	return flagTb
end

--点击未开锁的建筑触发的方法						（build）
CopyDelockLogic.coverClickAction = function(types,widget)
	local widgetName = widget:getName()
	if types == "releaseUp" then
		Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(mBuildCopyInfo[widgetName].copy_id),mBuildCopyInfo[widgetName].fbName),ccc3(255,255,255),ccc3(0,0,0),30)
	end
end

--加载中间建筑物的信息							 	(build）
CopyDelockLogic.loadBuildUnlockInfo = function()
	local root = LayerMainEnter.getLayerRoot()
	if root == nil then
		return
	end
	--如果当前已通关的最后一个副本id > 需要的副本id；加载正常图片；否则加载建设中的图片
	for key,value in pairs(mOpenBuildCopyInfo) do
		local widget = tolua.cast( root:getChildByName(mBuildWidgetName[key]),"UIImageView")
		local widget_lock = tolua.cast(root:getChildByName(string.format("%s_lock",mBuildWidgetName[key])),"UIImageView")
		local widget_gray = tolua.cast(root:getChildByName(string.format("%s_gray",mBuildWidgetName[key])),"UIImageView")
		local widget_light = tolua.cast(root:getChildByName(string.format("%s_light",mBuildWidgetName[key])),"UIImageView")
		table.insert(buildPosition,widget:getWorldPosition())
		if  tonumber(value.copy_id) ~= 1 then
			flag = CopyDelockLogic.judgeYNEnterById(value.copy_id)
		else
			flag = true
		end
		
		widget_light:setVisible(false)
		if flag == true then		--已解锁
			--widget:loadTexture(buildNormalImg[key])				--图片有待改变
			widget:registerEventScript(enterOtherScene)
			widget_lock:setVisible(false)
			widget_gray:setVisible(false)
		else									--未解锁
			--widget:loadTexture(buildSpeImg[key])
			widget:registerEventScript(CopyDelockLogic.coverClickAction)
			widget_lock:setVisible(true)
			widget_gray:setVisible(true)
		end
	end	
end 

--根据等级，加载主界面解锁和未解锁的图标			(主界面·一进入的时候就要调用)
CopyDelockLogic.loadUnLockImage = function()
	CopyDelockLogic.loadBuildUnlockInfo()	
	LayerMain.bottomBtnListGrey()	--加载底部图标
end

--显示/隐藏提示（点击的时候）								--main/mainEnter
CopyDelockLogic.setTipShow = function(root, widgetName, rootString,visible)
	if root == nil then
		return
	end
	local tipImage
	if rootString == "mLayerMainEnterRoot" then
		tipImage = root:getChildByName((string.format("%s_tip", widgetName)))
	elseif rootString == "mLayerRoot" then		
		tipImage = root:getWidgetByName((string.format("%s_tip", widgetName)))
	end
	if tipImage ~= nil then
		--为了解决建筑本身就有信息的情况
		if widgetName == "Panel_activity_build"  and LayerMainEnter.showActivityTip() == true then		--活动
			tipImage:setVisible(true)
		elseif widgetName == "Panel_jjc_build"  and LayerMainEnter.showGameRankMsgTips() == true  then	--竞技场
			tipImage:setVisible(true)
		elseif widgetName == "Panel_public_build"  and LayerMainEnter.showRoleUpTip() == true then	--英雄殿
			tipImage:setVisible(true)
		elseif widgetName == "Panel_inscription_build"  and LayerMainEnter.showSkillTip() == true  then	--技能
			tipImage:setVisible(true)
		elseif widgetName == "mainbtn_task"  and LayerMain.showTaskTip() == true  then	--任务
			tipImage:setVisible(true)
		elseif widgetName == "mainbtn_hero"  and LayerMain.showNewAppenEquipTip() == true  then	--英雄
			tipImage:setVisible(true)
		elseif widgetName == "mainbtn_rune"  and LayerMain.showRuneTip() == true  then	--召唤
			tipImage:setVisible(true)
		elseif widgetName == "mainbtn_sys" and LayerMain.showMoreTip() == true then		--更多
			tipImage:setVisible(true)
		else 
			tipImage:setVisible(false)
		end	
	else
		cclog("********************tipImage为空")
	end
end

CopyDelockLogic.clearData = function()
	
end 

EventCenter_subscribe(EventDef["ED_COPY_INFOS"], CopyDelockLogic.loadUnLockImage)

