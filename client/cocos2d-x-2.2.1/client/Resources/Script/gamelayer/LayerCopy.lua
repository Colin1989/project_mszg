

LayerCopy = {}
local mRootLayout = nil		--副本更节点

local mRootScrollView = nil 	--中间的SCOLLVIEW  副本群+BOSS本



local mAnimationDate = nil	--播放动画数据

local m_iOnClickGroup = nil 	--当前点击的那个副本群   giveup
local m_iOnClickCopy = nil 		--当前点击的是哪个副本
local mConTentPannel = nil
local mCopyFinger = nil
local SmallIconCaChe = {}
local mCopyMode = 1			-- 1.普通副本,2.精英副本

local CopyIconPath = "copyicon/"

local mPlayOpenDoor_CopyId = nil	--即将要播放开门动画的副本ID 为nil就不播

local function addSmallIconCache(filestr)
	for k,v in pairs(SmallIconCaChe) do 
		if v == filestr then 
			return
		end 
	end
	table.insert(SmallIconCaChe,filestr)
end 


-- 副本群点击事件
local function onItemClick_group(type,widget)
	if type =="releaseUp" then
		TipModule.onClick(widget)
		m_iOnClickGroup = widget:getTag()
		LayerCopy.create_CopyByMode(widget:getTag())
	end
end 

--副本点击事件
local function onItemClick_copy(type,widget)
	if type =="releaseUp" then
		TipModule.onClick(widget)
		m_iOnClickCopy = widget:getTag()
		--cclog("getNextPtCopyId------------------------->",getNextPtCopyId(widget:getTag()))
		UIManager.push("UI_CopyTips",widget:getTag())
		-- 新手引导
	end
 end

--创建文本文字
local function createCopyText(text,pos,size)
	local label =UILabel:create()      --往里面添加好友说的话，   
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPosition(pos)
	label:setFontSize(size)
	label:setText(text)
	label:setFontName("fzzdh.TTF")
	label:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	
	return label
end

local function onItemLocked(type,widget)
	if type == "releaseUp" then
		-- Toast.show(GameString.get("COPY_LOCK")..widget:getTag())
		Toast.show(GameString.get("COPY_LOCK"))
	end
end

local function addFinger(parentView)
    local finger = UIImageView:create()
    finger:loadTexture("guide_finger.png") 
	finger:setPosition(ccp(130,27))
    finger:setRotation(90)
	finger:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.2, ccp(5.0, 0)), CCMoveBy:create(0.2, ccp(-5.0, 0)))))
	parentView:addChild(finger)
	return finger
end

--创建精英副本群icon
function createJYFBGroundIcon(key,groupInfo)
    local groupView = UIImageView:create()
	groupView:setTag(tonumber(groupInfo.id))
	groupView:setName("group_"..key)

    local status = CopyDateCache.getGroupStatusById(groupInfo.id)
    	if status == "lock" then 
		groupView:loadTexture(CopyIconPath.."fuben_jy_close.png")
		groupView:registerEventScript(onItemLocked)
	else 
		if status == "pass" then 
			groupView:addChild(createCopyText(GameString.get("hasPass"),ccp(0,-75+65),18))
		else 
			local str = string.format("%d/%d",CopyDateCache.hasPassByGroup(groupInfo.id,groupInfo.type))
			groupView:addChild(createCopyText(str,ccp(0,-75+65),18))
			mCopyFinger = addFinger(groupView)
		end	 
		groupView:loadTexture(CopyIconPath.."fuben_jy_open.png")
		groupView:registerEventScript(onItemClick_group)	

	end

    --group index
	local indexLabel = CCLabelAtlas:create(tostring(key), CopyIconPath.."group_number.png",53, 68, 48)
	indexLabel:setPosition(ccp(0,15))
    indexLabel:setScale(0.36)
	indexLabel:setAnchorPoint(ccp(0.5,0.5))
	groupView:addRenderer(indexLabel,11)

	local deltax = 0
	if string.len(groupInfo.name)/3 > 5 then 
		deltax = 22
	end 
	groupView:addChild(createCopyText(groupInfo.name,ccp(deltax,-53),22))

	groupView:setTouchEnabled(true)
	return groupView
end 


--创建普通副本群icon
function createFBGroundIcon(key,groupInfo)
	local groupView = UIImageView:create()
	groupView:setTag(tonumber(groupInfo.id))
	groupView:setName("group_"..key)
	
	local status = CopyDateCache.getGroupStatusById(groupInfo.id)
	

	if status == "lock" then 
		groupView:loadTexture(CopyIconPath.."fuben_bg_group_lock.png")
		groupView:registerEventScript(onItemLocked)
	else 
		if status == "pass" then 
			groupView:addChild(createCopyText(GameString.get("hasPass"),ccp(0,-75+65),18))
		else 
			local str = string.format("%d/%d",CopyDateCache.hasPassByGroup(groupInfo.id,groupInfo.type))
			groupView:addChild(createCopyText(str,ccp(0,-75+65),18))
			mCopyFinger = addFinger(groupView)
		end
		
		groupView:loadTexture(CopyIconPath.."fuben_bg_group.png")

		groupView:registerEventScript(onItemClick_group)
		
		--group index
	end

    local indexLabel = CCLabelAtlas:create(tostring(key), CopyIconPath.."group_number.png",53, 68, 48)
    indexLabel:setPosition(ccp(-2,15))
    indexLabel:setScale(0.36)
	indexLabel:setAnchorPoint(ccp(0.5,0.5))
	groupView:addRenderer(indexLabel,11)

	--group Name
	groupView:addChild(createCopyText(groupInfo.name,ccp(0,-55),22))
	groupView:setTouchEnabled(true)	
	return groupView
end

--createFB 
function ceateFbIcon(copyInfo,key)
	--copyRoot
	local copyView = UIImageView:create()

	--copyView:loadTexture(CopyIconPath.."fuben_bg.png")
    

    if copyInfo.type == "1" then 
	    copyView:loadTexture(CopyIconPath.."fuben_bg.png")
    else 
        copyView:loadTexture(CopyIconPath.."fuben_jybg.png")
    end 
   


	copyView:setName("copy_"..key)

	local str = string.format("group%03d",key)
	str = CopyIconPath..str
	
	ResourceManger.LoadSinglePicture(str)
	addSmallIconCache(str)
	
	--copy_icon
	local smallicon = UIImageView:create()
	smallicon:loadTexture(copyInfo.small_icon,UI_TEX_TYPE_PLIST) --read xml
	smallicon:setPosition(ccp(0,15))
	copyView:addChild(smallicon)
	

	
	--name_frame
	local copy_namebar = UIImageView:create()	--by type
	copy_namebar:setPosition(ccp(0,-40))
	copyView:addChild(copy_namebar)
	

	
	--close Door	
	
	local ScissorsView = UIScrollView:create()--拖拽层
	ScissorsView:setDirection(SCROLLVIEW_DIR_NONE);
	
	ScissorsView:setSize(CCSizeMake(225,127))
	ScissorsView:setInnerContainerSize(CCSizeMake(225,127))
	ScissorsView:setPosition(ccp(-120,-50))
	ScissorsView:setTouchEnabled(false)
	ScissorsView:setName(string.format("ScissorsView"..copyInfo.id));
	
	local rightDoor = UIImageView:create()
	rightDoor:loadTexture(CopyIconPath.."fuben_door_right.png")
	rightDoor:setAnchorPoint(ccp(0,0))
	rightDoor:setPosition(ccp(120,0))
	rightDoor:setName(string.format("rightDoor"..copyInfo.id));
	ScissorsView:addChild(rightDoor)
	
	local leftDoor = UIImageView:create()
	leftDoor:loadTexture(CopyIconPath.."fuben_door_left.png")
	leftDoor:setAnchorPoint(ccp(0,0))
	leftDoor:setPosition(ccp(12,0))
	leftDoor:setName(string.format("leftDoor"..copyInfo.id));
	ScissorsView:addChild(leftDoor)
	
	copyView:addChild(ScissorsView)
	--]]--
	--copyStarFrame
	local copyBg = UIImageView:create()

   
    if copyInfo.type == "1" then 
	    copyBg:loadTexture(CopyIconPath.."fuben_frame.png")
    else 
        copyBg:loadTexture(CopyIconPath.."fuben_frame_jy.png")
    end 
	copyView:addChild(copyBg)
	

	--star 
	local starNumber = CopyDateCache.getScoreById(copyInfo.id)	
	local function createStar(pos)
		local star = UIImageView:create()
		star:loadTexture(CopyIconPath.."copy_star.png")
		star:setPosition(pos)
		copyView:addChild(star)
	end
	
	--消耗体力展示
   
   	--copy_name 
	local label_copyName = createCopyText(copyInfo.name,ccp(0,-55),20)
	copyView:addChild(label_copyName)

	local statue,isPlayOpenDoor = CopyDateCache.getCopyStatus(copyInfo.id)

	if statue == "lock" then 
		copyView:registerEventScript(onItemLocked)
	else
		ScissorsView:setVisible(false)

        if copyInfo.type == "1" then
	        if starNumber == 1 then
		        createStar(ccp(-62+3,77-1))
	        elseif starNumber == 2 then 
		        createStar(ccp(-62+3,77-1))
		        createStar(ccp(-1+2,77-1))
	        elseif starNumber == 3 then 
		        createStar(ccp(-62+3,77-1))
		        createStar(ccp(-1+2,77-1))
		        createStar(ccp(60+1,77-1))
	        end
        else
	        if starNumber == 1 then 
		        createStar(ccp(-61+3,75))
	        elseif starNumber == 2 then 
		        createStar(ccp(-61+3,75))
		        createStar(ccp(2,76-1))
	        elseif starNumber == 3 then 
		        createStar(ccp(-61+3,75))
		        createStar(ccp(2,76-1))
		        createStar(ccp(62,76-1))
	        end
        end

        local AngleIcon = UIImageView:create()
        AngleIcon:setPosition(ccp(-98,45))
        if statue == "pass" then 
            AngleIcon:loadTexture("fuben_yitongguan.png")
        elseif statue == "doing" then  
            AngleIcon:loadTexture("fuben_tiaozhanzhong.png")
			mCopyFinger = addFinger(copyView)
        end 
        copyView:addChild(AngleIcon)

		local pRet,lvLimitNum = CopyDateCache.isLvLimit(copyInfo.id)
		local lvLimit = nil
		if pRet	== true then 
			smallicon:setColor(ccc3(128,128,128))
			smallicon:setOpacity(128)
					
			lvLimit =  createCopyText("需要"..lvLimitNum.."级开启",ccp(0,0),32)
			lvLimit:setVisible(true)
			copyView:addChild(lvLimit)
		else
			if nil ~= lvLimit then
				lvLimit:setVisible(false)
			end
			copyView:registerEventScript(onItemClick_copy)
		end
	end
	
	copyView:setTouchEnabled(true)
	return copyView
end



--copyId:即将要打开门的副本ID
 function OpenDoorById(copyId)
	if copyId == nil then 
		return
	end 
	
	local function _HandleAnction(node,distance)
		local moving = CCEaseBackOut:create(CCMoveBy:create(5.5,CCPointMake(distance,0)))
		node:runAction(moving)
	end
	
	local ScissorsView = mConTentPannel:getChildByName(string.format("ScissorsView"..copyId))
	if ScissorsView == nil then return end 
	ScissorsView:setVisible(true)
	
	local rightDoor = mConTentPannel:getChildByName((string.format("rightDoor"..copyId)))
	if rightDoor == nil then 
		return 
	end 
	_HandleAnction(rightDoor,108)
	
	local leftDoor = mConTentPannel:getChildByName((string.format("leftDoor"..copyId)))
	if leftDoor == nil then return end 
	_HandleAnction(leftDoor,-131)
	
	mPlayOpenDoor_CopyId = nil
end


LayerCopy.init = function(context)
	mConTentPannel = context
	
	SmallIconCaChe = {}
	
	mRootScrollView = mConTentPannel:getChildByName("copy_scoll_content")
	mRootLayout	= mConTentPannel:getChildByName("copy_layout_content")
	
	tolua.cast(mRootLayout,"UILayout")
	tolua.cast(mRootScrollView,"UIScrollView")
	
	--cancle button
	mConTentPannel:getChildByName("copy_close"):registerEventScript(
	function (EventType,widget)
		if EventType == "releaseUp" then
			TipModule.onClick(widget)
			LayerMain.pullPannel(LayerLevelSelcet)
		end
	end
	)
end 

--创建副本群	mode:--1:为普通副本群 2:精英副本群
LayerCopy.createCopyGroupByMode = function(mode)
	mCopyMode = mode
	mRootScrollView:registerEventScript(function(eventType, widget)
		-- 为了使列表不发生滚动
		if 1 == GuideMgr.guideStatus() then
			tolua.cast(widget, "UIScrollView"):scrollToTop(0.01, false)
		end
	end)
	mRootScrollView:removeAllChildren()
	mRootScrollView:setEnabled(true)
	mRootLayout:setEnabled(false)
	
	LayerLevelSelcet.getView().CanCleBtn:setEnabled(false)
	
	local AllGroup = LogicTable.getAllCopyGroup()
	local ScrollItem = {}
		--for i = 1,11 do 
	local index = 0
	for key,copyGroup in pairs(AllGroup) do
		if mode == tonumber(copyGroup.type)	then	
			index = index+1
			local imageView = nil
            if tonumber(copyGroup.type) == 1 then 
               imageView =  createFBGroundIcon(index,copyGroup)
            elseif tonumber(copyGroup.type) == 2 then 
               imageView = createJYFBGroundIcon(index,copyGroup) 
            end 
			imageView:setTag(tonumber(copyGroup.id))
			table.insert(ScrollItem,imageView)
		end
	end
	setAdapterGridView(mRootScrollView,ScrollItem,2,0)
	LayerLevelSelcet.initTopButtonList(mode)
	if 1 == mode then
		TipModule.onUI(mRootScrollView, "ui_copygroupnormal")
	elseif 2 == mode then
		TipModule.onUI(mRootScrollView, "ui_copygroupjiying")
	end
	-- 针对新手特殊处理
	if GuideMgr.guideStatus() > 0 and tolua.cast(mCopyFinger, "UIImageView") then
		mCopyFinger:setVisible(false)
	end
end

--获取当前副本模式
LayerCopy.getCopyMode = function()
	return mCopyMode
end

--创建副本	mode:--1:为普通副本 2:精英副本 3:Boss
LayerCopy.create_CopyByMode = function(groupid)

    --[[
    if UIManager.isAllUIEnabled() == false then --如果在战斗界面
        cclog("-------------UIManager.isAllUIEnabled--------------------",LayerCopy.create_CopyByMode,UIManager.isAllUIEnabled())
        return
    end 
    ]]--
	local groupInfo = LogicTable.getCopyGroupById(groupid)
	
	local pyTb,jyTb,BossTb = CopyDateCache.getCurGroupLength(groupid)

	local curFb = {}
	
	LayerLevelSelcet.getView().CanCleBtn:setEnabled(true)

	mRootLayout:removeAllChildren()
	mRootScrollView:setEnabled(false)
	mRootLayout:setEnabled(true)
	
	LayerLevelSelcet.initTopButtonList(tonumber(groupInfo.type))
	if tonumber(groupInfo.type) == 1 then 	--普通副本
		curFb = pyTb
	elseif tonumber(groupInfo.type)  == 2 then 	--精英副本
		curFb = jyTb
	end
	--end 
	local ScrollItem = {}
	for key,value in pairs(curFb) do
		local imageView = nil 
		local copy = LogicTable.getCopyById(value)
		--if tonumber(copy.type) == 3 then 
			--imageView = ceateFbBoosIcon(copy)
		--else 
			imageView = ceateFbIcon(copy,groupid%100)
		--end 
		imageView:setTag(tonumber(copy.id))
		imageView:setName("copy_btn_"..key)
		--imageView:setScale(0.9)
		table.insert(ScrollItem,imageView)
	end
	
	table.sort(ScrollItem,function(valueA,valueB)
		return valueA:getTag() < valueB:getTag()
	end)
	
	--if mode == 3  then --BOSS模式
		--setAdapterGridView(mRootScrollView,ScrollItem,2,0) 
	--else 
		setLayoutGridView(mRootLayout,ScrollItem,2,0)
	--end
	if 1 == tonumber(groupInfo.type) and nil == LayerGameUI.mRootView then
		TipModule.onUI(mRootLayout, "ui_copynormal")
	end
	if 2 == tonumber(groupInfo.type) and nil == LayerGameUI.mRootView then
		TipModule.onUI(mRootLayout, "ui_copyjiying")
	end
	-- 针对新手特殊处理
	if GuideMgr.guideStatus() > 0 and tolua.cast(mCopyFinger, "UIImageView") then
		mCopyFinger:setVisible(false)
	end
end



--FIX
LayerCopy.refresh = function(EventType,Param)
	if EventType == "ED_TaskToCopy" then	--任务中跳转到指定副本
		m_iOnClickCopy = Param
		local copyInfo  = LogicTable.getCopyById(m_iOnClickCopy)
		
        if tonumber(copyInfo.type) == 2 then 
			m_iOnClickGroup = CopyDateCache.getGroupIdByCopyId(Param)
			LayerCopy.create_CopyByMode(m_iOnClickGroup,nil)
		else
			m_iOnClickGroup = CopyDateCache.getGroupIdByCopyId(Param)
			LayerCopy.create_CopyByMode(m_iOnClickGroup,nil)
		end

		
	elseif "Fight_fail" == EventType then 
		--if LayerLevelSelcet.getType() ~= 3 then 
			mRootLayout:setEnabled(true)
			mRootScrollView:setEnabled(false)
		--else 
			--mRootLayout:setEnabled(false)
			--mRootScrollView:setEnabled(true)
			--LayerLevelSelcet.getView().CanCleBtn:setEnabled(false)
	    --end

	else 
        if m_iOnClickCopy == nil then return end --fixme
		mAnimationDate = CopyDateCache.KeepPassCopyAnimationDate(m_iOnClickCopy)
		
		--刷新开门动画			
			--普通 精英 模式
			if mAnimationDate.result == true then 
				--if LayerLevelSelcet.getType() == 3 then --BOSS模式
					--LayerCopy.create_CopyByMode(nil,3)
					--LayerLevelSelcet.getView().ShowMyStone:setText("*"..ModelPlayer.getSummonStone()) 
				--else
					LayerCopy.create_CopyByMode(CopyDateCache.getGroupIdByCopyId(mAnimationDate.newCopyId))
				--end
				
				if mAnimationDate.isNewJyCopyOpen == true and CopyDelockLogic.judgeYNEnterById(LIMIT_EQUIP_JYFB.copy_id) == true then 
					LayerLevelSelcet.getView().Jy_newFlag:setVisible(true)
				end 
				
				if mAnimationDate.isNewBossCopyOpen == true then 
					--LayerLevelSelcet.getView().Boss_newFlag:setVisible(true)
                    --加BOSS活动的感叹号！？
				end
				
				OpenDoorById(mAnimationDate.newCopyId)
			else 
				--if LayerLevelSelcet.getType() == 3 then --BOSS模式
					--LayerLevelSelcet.getView().ShowMyStone:setText("*"..ModelPlayer.getSummonStone()) 
					--LayerCopy.create_CopyByMode(nil,3)
				--else
					LayerCopy.create_CopyByMode(m_iOnClickGroup)
				--end
			end 
		
	end
	
end

LayerCopy.destroy = function()
	--delete small icon
	ResourceManger.releasePlist(SmallIconCaChe)

	m_iOnClickCopy = nil
	mAnimationDate = nil
	mCopyFinger = nil
end

local function handleGuideGroup(start)
	if nil == mCopyFinger or nil == tolua.cast(mCopyFinger, "UIImageView") then
		return
	end
	mCopyFinger:setVisible(not start)
end

function LayerCopy_updateCopyUI()
	if LayerMain.getCurStatus() ~= "Panel_mission_build" then
		return
	end	
	LayerCopy.create_CopyByMode(m_iOnClickGroup)
end

EventCenter_subscribe(EventDef["ED_GUIDE_GROUP"], handleGuideGroup)
--EventCenter_subscribe(EventDef["ED_LV_UP"], LayerCopy_updateCopyUI)