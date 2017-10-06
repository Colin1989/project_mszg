
-------------------------------------
--作者：shenl
--说明：副本群选择界面(主界面->战斗)
--时间：2014-1-5
-------------------------------------
LayerLevelSelcet = {}

local mLayerLevelSelcetRoot = nil 
local mBackgroundPannel = nil  --副本群
local mMaxGroundId = nil
local mCurGroundId = nil

--local mCopyRoot1 = nil
--local mCopyRoot2 = nil 
 
function  Handle_Change_Copy(type,widget)

  if type =="releaseUp" then
	local name =widget:getName() 
	if name == "lastcopy_btn" then 
		if CopyDateCache.lastAble(mCurGroundId) then 
			mCurGroundId = mCurGroundId - 1
			initPveCopy(mCurGroundId)
		end		
	elseif name == "nextcopy_btn" then	
		if CopyDateCache.NextAble(mCurGroundId,mMaxGroundId) then 
			mCurGroundId = mCurGroundId + 1
			initPveCopy(mCurGroundId)
		end
	end
	cclog(name)
   end
end

-- 切换副本群 
local function setBackgroundPannel(groupId)
	mBackgroundPannel:removeAllChildren()
	if groupId == 101 then 	
		if 	mCopyRoot1 == nil then 		
			print("Create --------------------------------------->mCopyRoot1")
			mCopyRoot1=GUIReader:shareReader():widgetFromJsonFile("fuben1.ExportJson")  --副本1
		end
		local copy1 = mCopyRoot1:clone()
		mCopyRoot1:retain()
		mBackgroundPannel:addChild(copy1)	--]]
		--local copy1 = LoadWidgetFromJsonFile("fuben1.ExportJson")
		mBackgroundPannel:addChild(copy1)
	elseif groupId == 102 then 
		if 	mCopyRoot2 == nil then 	
			print("Create --------------------------------------->mCopyRoot2")							
			mCopyRoot2=GUIReader:shareReader():widgetFromJsonFile("fuben2_1.ExportJson")  --副本2
		end
		local copy2 = mCopyRoot2:clone()
		mCopyRoot2:retain()--]]
		--local copy1 = LoadWidgetFromJsonFile("fuben1.ExportJson")
		mBackgroundPannel:addChild(copy2)
	end

	

	local last = mBackgroundPannel:getChildByName("lastcopy_btn")
	last:registerEventScript(Handle_Change_Copy)
	if CopyDateCache.lastAble(mCurGroundId) == false then 
		last:setVisible(false)
	end
	
	
	local next_one = mBackgroundPannel:getChildByName("nextcopy_btn")
	next_one:registerEventScript(Handle_Change_Copy)
	if CopyDateCache.NextAble(mCurGroundId,mMaxGroundId) == false then 
		next_one:setVisible(false)
	end
	
end


local function  onItemClick(type,widget)

  if type =="releaseUp" then
      local name =widget:getName()  --判断是点击了那个按钮
	  --print("widget:getTag()",widget:getTag())
      UIManager.push("UI_CopyTips",widget:getTag())
   end
end


--星星控件 命名规则 copy%dGrayStar_1_%d
local  function  showStar(key,Group_id,starNumber)
       local grayStar1,grayStar2,grayStar3
       grayStar1 =  mBackgroundPannel:getChildByName( string.format("copy%dGrayStar_1_%d",Group_id - 100,key) )
       grayStar2 = mBackgroundPannel:getChildByName( string.format("copy%dGrayStar_2_%d",Group_id - 100,key))
       grayStar3 = mBackgroundPannel:getChildByName( string.format("copy%dGrayStar_3_%d",Group_id - 100,key))
       -- tolua.cast(grayStar1,"UIImageView")
              if starNumber==1 then
                     grayStar1:setVisible(true)
               elseif starNumber == 2 then
                    grayStar1:setVisible(true)
                    grayStar2:setVisible(true)
               elseif starNumber ==3 then
                    grayStar1:setVisible(true)
                    grayStar2:setVisible(true)
                    grayStar3:setVisible(true)
               end
end

-- 设置当前副本群视图
--精英副本		copy%djyPanel_%d
--红旗			copy%dQi_%d		
--副本入口按钮	copy%dBtn_%d
local function setCurGroupItem(Group_id)
	local curPtGroup,curJYGroup = CopyDateCache.getCurGroupLength(Group_id)
	
	--普通副本
	for key,curCopyId in pairs(curPtGroup) do
		--注册事件						
		local copyBtnName=string.format("copy%dBtn_%d",Group_id-100,key)   
     
		local copyBtn=mBackgroundPannel:getChildByName(copyBtnName)

		copyBtn:setTag(curCopyId)
		copyBtn:registerEventScript(onItemClick)
		-- 设置红旗
		local flagImaName=string.format("copy%dQi_%d",Group_id-100,key)            
        local flagView=mBackgroundPannel:getChildByName(flagImaName)
        tolua.cast(flagView,"UIImageView")

		local str = CopyDateCache.showFlag(curCopyId,Group_id)
		--print("Flag----------------",str)
		if str  == "red_flag" then 
			flagView:setVisible(true)
			flagView:loadTexture("flag_red.png",UI_TEX_TYPE_PLIST)  
		elseif  str == "visiable"  then 
			flagView:setVisible(false)  --设置灰色红旗隐藏
		end
		-- 设置星星
		showStar(key,Group_id,CopyDateCache.getScoreById(curCopyId))
	end
	--精英副本

	for jyKey,jyCurCopyId in pairs(curJYGroup) do
		if 	CopyDateCache.IsLockCurJy(jyCurCopyId,Group_id) then --解锁了？

			local copyJyBtnName=string.format("copy%djyPanel_%d",Group_id-100,jyKey) 
			 local jyView=mBackgroundPannel:getChildByName(copyJyBtnName)
			jyView:setVisible(true)
			if CopyDateCache.Hitable(jyCurCopyId) then	--次数用尽了？			
				jyView:setTag(jyCurCopyId)
				jyView:registerEventScript(onItemClick)
			else
				--print("这个精英副本不能点，而且要变灰")
				local Sprite = jyView:getVirtualRenderer()
				tolua.cast(Sprite,"CCSprite")
				Proxy:spriteGray(Sprite,true)	
			end
		end
	end
end

--GroupId 副本群ID
function initPveCopy(GroupId)	
		setBackgroundPannel(GroupId)
		setCurGroupItem(GroupId)
end
	


-- 选择游戏战斗模式
local function  onGameTypeChooseClick(type,widget)

  if type =="releaseUp" then
    local name =widget:getName()  --判断是点击了那个按钮
	if name == "copy_2"  then 	-- 推塔
		--如果是第一次进来 就请求数据
		--if FightDateCache.pushTower().resp == nil then 
			local tb = req_push_tower_info()
			NetHelper.sendAndWait(tb, NetMsgType["msg_notify_push_tower_info"])
		--else
		--先这么做应该是切场景图片
			--mBackgroundPannel:removeAllChildren()
			--LayerTowerbg.init(mBackgroundPannel)
		--end
	elseif name == "copy_1" then 
		initPveCopy(mCurGroundId)
	end
	
   end
end
function Handle_req_push_tower_info(resp)
	--tb.play_times = 0
    --tb.max_times = 0
    --tb.max_floor = 0
	FightDateCache.setPushTowerDate(resp)
	mBackgroundPannel:removeAllChildren()
	LayerTowerbg.init(mBackgroundPannel)
	
end


LayerLevelSelcet.init = function (RootView)
	local function initFightBgPannelEvent() 
		local Btn_zhuxian = mLayerLevelSelcetRoot:getChildByName("copy_1")
		Btn_zhuxian:registerEventScript(onGameTypeChooseClick)
	
		local Btn_tuita = mLayerLevelSelcetRoot:getChildByName("copy_2")
		Btn_tuita:registerEventScript(onGameTypeChooseClick)
	end


	mLayerLevelSelcetRoot = RootView
	mBackgroundPannel = mLayerLevelSelcetRoot:getChildByName("Panel_copyroot")
	tolua.cast(mBackgroundPannel,"UILayout")
	initFightBgPannelEvent()
	
	mMaxGroundId = CopyDateCache.getCurShowGroup() + 0	--获取当前应该展示的副本
	mCurGroundId = mMaxGroundId
	initPveCopy(mCurGroundId)	-- 当前初始化

end
NetSocket_registerHandler(NetMsgType["msg_notify_push_tower_info"], notify_push_tower_info(), Handle_req_push_tower_info)
