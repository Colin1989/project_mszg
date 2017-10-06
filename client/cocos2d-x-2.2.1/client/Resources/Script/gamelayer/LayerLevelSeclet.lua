
-------------------------------------
--作者：shenl
--说明：副本群选择界面(主界面->战斗)
--时间：2014-1-5
-------------------------------------


LayerLevelSelcet = {}

local BtnList = {}

local mLayerLevelSelcetRoot = nil 
--local mBackgroundPannel = nil  --副本群

local mContentPannel = nil

local mJy_newFlag = nil 	--新精英 BOSS 本解锁气泡

--------------
--返回按钮
local mCanCleBtn = nil


local TAG1 = 20148191
local TAG2 = 20148192



LayerLevelSelcet.destroy = function()
	mLayerLevelSelcetRoot = nil
	mContentPannel = nil
	mShowMyStone = nil
end

LayerLevelSelcet.getView =function()
	local Date = {}
	Date.CanCleBtn = mCanCleBtn
	Date.Jy_newFlag = mJy_newFlag  -- 精英气泡
	return Date
end

-- 记录标签页状态
local mType = 1

LayerLevelSelcet.getType = function()
	return mType
end 

LayerLevelSelcet.setType = function(Type)
	mType = Type
end 

local function copyMaskParticle(widget, pos)

	local size = widget:getSize()  

    --size.width = size.width - 15
    --size.height = size.height - 15
    local delatW = 30

    local width = size.width -delatW
    local height = size.height 

	local speed = 0.6
    
    --去掉粒子特效
    --[[
	local particle1 = CCParticleSystemQuad:create("copy_select.plist")
	widget:addRenderer(particle1, 100)
	particle1:setPosition(ccp(pos.x - size.width/2 + delatW/2 , pos.y))
    particle1:setTag(TAG1)
	
    
	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(speed, ccp(width, 0)))
	arr:addObject(CCMoveBy:create(speed/4, ccp(delatW/2, -height/2)))
    arr:addObject(CCMoveBy:create(speed/4, ccp(-delatW/2, -height/2)))
	arr:addObject(CCMoveBy:create(speed, ccp(-width, 0)))
	arr:addObject(CCMoveBy:create(speed/4, ccp(-delatW/2, height/2)))
    arr:addObject(CCMoveBy:create(speed/4, ccp(delatW/2, height/2)))
	particle1:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	
    
	local particle2 = CCParticleSystemQuad:create("copy_select.plist")
	widget:addRenderer(particle2, 100)
    particle2:setTag(TAG2)
	particle2:setPosition(ccp(pos.x + size.width / 2 - delatW/2 , pos.y - size.height))
	
	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(speed, ccp(-width, 0)))
	arr:addObject(CCMoveBy:create(speed/4, ccp(-delatW/2, height/2)))
    arr:addObject(CCMoveBy:create(speed/4, ccp(delatW/2, height/2)))
	arr:addObject(CCMoveBy:create(speed, ccp(width, 0)))
	arr:addObject(CCMoveBy:create(speed/4, ccp(delatW/2, -height/2)))
    arr:addObject(CCMoveBy:create(speed/4, ccp(-delatW/2, -height/2)))
	particle2:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	]]--
end



local function OnClick_CopyMode(widget)
	TipModule.onClick(widget)
	local name =widget:getName() 
	if name == "copy_main" then 
		--LayerCopy.init(mContentPannel)
		mType = 1
		LayerCopy.createCopyGroupByMode(1) --1:普通副本群
	elseif name == "copy_jy" then 
		mType = 2
		mJy_newFlag:setVisible(false)  -- 精英气泡
		LayerCopy.createCopyGroupByMode(2) --2:精英副本群
    end
end

local function Onclick_otherCopy(typeName,widget)
    if typeName ~= "releaseUp" then  return end 
	TipModule.onClick(widget)
    local name =widget:getName()
    if name == "copy_tower" then    --推塔
	    if CopyDateCache.getCopyStatus(LIMIT_TOWER.copy_id) ~= "pass" and tonumber(LIMIT_TOWER.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_TOWER.copy_id),LIMIT_TOWER.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		    return
		end
        setConententPannelJosn(LayerTowerbg,"PowerCopyBg.json","PowerCopyBg.json")
	elseif name == "copy_boss" then     --BOSS 
		if CopyDateCache.getCopyStatus(LIMIT_ENTER_BOSS.copy_id) ~= "pass" and tonumber(LIMIT_ENTER_BOSS.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ENTER_BOSS.copy_id),LIMIT_ENTER_BOSS.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
        setConententPannelJosn(LayerChenallBoss,LayerChenallBoss.josnFile,LayerChenallBoss.josnFile)
	elseif name == "copy_xukong" then   --虚空
		if CopyDateCache.getCopyStatus(LIMIT_ACTIVITY_COPY.copy_id) ~= "pass" and tonumber(LIMIT_ACTIVITY_COPY.copy_id) ~= 1 then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_ACTIVITY_COPY.copy_id),LIMIT_ACTIVITY_COPY.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerActivityCopyGroup, "ActivityCopyGroup.json", widgetName)
	end

end 

function SetTabBtn(BtnList)	
	mSingleChooseBtnActionDone = false
	local function handle_onClick(typeName,widget) 
		if typeName == "releaseUp" then
			TipModule.onClick(widget)
			local curName = widget:getName()
			
			if curName == "copy_jy" and  CopyDateCache.getCopyStatus(LIMIT_EQUIP_JYFB.copy_id) ~= "pass"
				and tonumber(LIMIT_EQUIP_JYFB.copy_id) ~= 1 then
				Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_EQUIP_JYFB.copy_id),LIMIT_EQUIP_JYFB.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30) 
				return
			end
			
			
			local curValue = nil
			for key,value in pairs(BtnList) do	--取消原来亮的东西
				if value.isBright == true then
					if curName == value.name then -- 如果连续同时按一个按钮 不触发事件
						return
					end
					tolua.cast(value.widget,"UIImageView")
					value.widget:loadTexture(value.N_image)
					value.isBright = false
					
                    --value.widget:getRenderer():removeChildByTag(TAG1,true)
                    --value.widget:getRenderer():removeChildByTag(TAG2,true)
				end
				if curName == value.name then
					curValue = value
				end
			end
			tolua.cast(widget,"UIImageView")
			widget:loadTexture(curValue.H_image)
			curValue.isBright = true
			OnClick_CopyMode(widget)
            copyMaskParticle(widget, ccp(0,0))
		end
	end
	
	for k,v in pairs(BtnList) do
		v.widget:registerEventScript(handle_onClick)
	end
end

local function ceateBtnList(widgetName,N_ImageName,H_ImageName,isBright)
	local widgetSingle = {}
	widgetSingle.isBright = isBright
	widgetSingle.name = widgetName
	widgetSingle.N_image = N_ImageName
	widgetSingle.H_image = H_ImageName
	
	widgetSingle.widget = mContentPannel:getChildByName(widgetName)
	
	if isBright == true then
		tolua.cast(widgetSingle.widget,"UIImageView")
		widgetSingle.widget:loadTexture(widgetSingle.H_image)
		copyMaskParticle(widgetSingle.widget, ccp(0,0))
	else
		tolua.cast(widgetSingle.widget,"UIImageView")
		widgetSingle.widget:loadTexture(widgetSingle.N_image)
		--widgetSingle.widget:getRenderer():removeChildByTag(TAG1,true)
		--widgetSingle.widget:getRenderer():removeChildByTag(TAG2,true)
	end
	-- table.insert(BtnList,widgetSingle)
	table.insert(BtnList,widgetSingle)
end

-- local function initTopButtonList()
LayerLevelSelcet.initTopButtonList = function(mode)
	local function changeBtnList(widgetTb,isBright)
		-- local widgetTb = {}
		widgetTb.isBright = isBright
		-- widgetTb.name = widgetName
		-- widgetTb.N_image = N_ImageName
		-- widgetTb.H_image = H_ImageName
		
		-- widgetTb.widget = mContentPannel:getChildByName(widgetName)
		
		if isBright == true then
			tolua.cast(widgetTb.widget,"UIImageView")
			widgetTb.widget:loadTexture(widgetTb.H_image)
            copyMaskParticle(widgetTb.widget, ccp(0,0))
		else
			tolua.cast(widgetTb.widget,"UIImageView")
			widgetTb.widget:loadTexture(widgetTb.N_image)
			--widgetTb.widget:getRenderer():removeChildByTag(TAG1,true)
            --widgetTb.widget:getRenderer():removeChildByTag(TAG2,true)
		end
		-- table.insert(BtnList,widgetTb)
	end
	
	mType = mode
	if #BtnList == 0 then
		if mode == 2 then
			ceateBtnList("copy_main","fuben_pt_d.png","fuben_pt_h.png",false)
			ceateBtnList("copy_jy",	"fuben_jy_d.png","fuben_jy_h.png",true)

		else
			ceateBtnList("copy_main","fuben_pt_d.png","fuben_pt_h.png",true)
			ceateBtnList("copy_jy",	"fuben_jy_d.png","fuben_jy_h.png",false)
		end
	else
		if mode == 2 and BtnList[2].isBright == false then
			changeBtnList(BtnList[1],false)
			changeBtnList(BtnList[2],true)
		elseif mode == 1 and BtnList[1].isBright == false then
			changeBtnList(BtnList[1],true)
			changeBtnList(BtnList[2],false)
		end
		
	end
	SetTabBtn(BtnList)

    local widget = mContentPannel:getChildByName("copy_boss")
    widget:registerEventScript(Onclick_otherCopy)
    widget = mContentPannel:getChildByName("copy_tower")
    widget:registerEventScript(Onclick_otherCopy)
    widget = mContentPannel:getChildByName("copy_xukong")
    widget:registerEventScript(Onclick_otherCopy)
	
	if LayerChenallBoss.existAward() then			-- BOSS挑战
		local bossTip = mContentPannel:getChildByName("copy_boss_tip")
		bossTip:setVisible(true)
	end
	
	if LayerTowerbg.existAward() then				-- 魔塔
		local towerTip = mContentPannel:getChildByName("copy_tower_tip")
		towerTip:setVisible(true)
	end 

end 


LayerLevelSelcet.init = function (RootView)
	mType = 1
	mContentPannel = RootView
	BtnList = {}
	-- initTopButtonList()
	-- LayerLevelSelcet.initTopButtonList()
	
	--initBossStonePannel()
	mCanCleBtn = RootView:getChildByName("copy_cancle")

	
	--mcurFBView = RootView:getChildByName("groupview")
	--mcurFbLabel = RootView:getChildByName("groupname")
	
	mCanCleBtn:registerEventScript(function (EventType,widget)
		if EventType == "releaseUp" then 
			TipModule.onClick(widget)
			LayerCopy.init(mContentPannel)
			LayerCopy.createCopyGroupByMode(mType) 
		end 
	end)
	mCanCleBtn:setEnabled(false)

	--mGetBossStonePannel:setEnabled(false)
	--mCurBossStonePannel:setEnabled(false)

	--tolua.cast(mcurFbLabel,"UILabel")
	--新精英 BOSS 本解锁气泡
	mJy_newFlag =  RootView:getChildByName("jy_new") 	
	--mBoss_newFlag =  RootView:getChildByName("boss_new") 
	TipModule.onUI(RootView, "ui_levelselect")
	LayerCopy.init(RootView)
	
	LayerCopy.createCopyGroupByMode(1) --1:普通副本群
end





















