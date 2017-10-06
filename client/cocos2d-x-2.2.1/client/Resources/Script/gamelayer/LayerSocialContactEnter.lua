----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-09-19
-- Brief:	社交界面入口
----------------------------------------------------------------------

local mSocContEnLayerRoot = nil	-- 好友邀请码界面根节点
local mClickWidget = nil		--表示当前选中的控件
local mSocialContactSwitchDatas = nil 	--保存社交列表的数据
						
LayerSocialContactEnter = {}
LayerAbstract:extend(LayerSocialContactEnter)
----------------------------------------------------------------------
-- 点击按钮响应事件
local function clickBtn(typeName, widget)
	if mClickWidget == widget then
		return
	end
	if "releaseUp" == typeName then
		local weightName = widget:getName()
		mClickWidget = widget
		if weightName == "close" then				--关闭按钮
			LayerMain.pullPannel(LayerSocialContactEnter)
		elseif weightName == "cellBg_1" then		--好友
			FriendDataCache.setImageStrByMainFlag() --？？？？？？？？？？？？？？？？？？？？？？？？
			setConententPannelJosn(LayerFriendList,"FriendBackground_1.json",weightName)
		elseif weightName == "cellBg_2" then		--邀请码
			mClickWidget = nil
			UIManager.push("UI_InviteCode")
			--setConententPannelJosn(LayerInviteCode, "InvetFriendCode_1.json",weightName)
		elseif weightName == "cellBg_3" then		--友情奖励
			setConententPannelJosn(LayerFriendPoint, "FriendPoint.json", weightName)
		elseif weightName == "cellBg_4" then		--公会
			
		end	
		
	end
end
----------------------------------------------------------------------
--判断每一项的tip是否显示
local function juegeItemTipVisible(id)
	if 1 == id then			-- 好友
		return FriendDataCache.existTip()
	elseif 2 == id then		-- 邀请码
		return LayerInviteCode.judgeHasTipInviteCode()
	elseif 3 == id then		-- 友情奖励
		return FriendPointLogic.existAward()
	elseif 4 == id then		-- 公会
		return false
	end
end
----------------------------------------------------------------------
--创建每一项
local function createIConItem(cell, socialEnterSwitchRow, index)
	ItemInfo = socialEnterSwitchRow
	-- 背景
	local text = string.format("cellBg_%d",ItemInfo.id)
	local cellBg = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(0,0),CCSizeMake(122, 104),"public2_bg_07.png",text,5)
	cellBg:setScale9Enabled(true)
	cellBg:setTouchEnabled(true)
	cellBg:registerEventScript(clickBtn)
	cellBg:setCapInsets(CCRectMake(20, 20, 1, 1))
	local imgBg = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(0,0),CCSizeMake(248, 248),"roleup_juesebg.png","imgBg",5)
	cellBg:addChild(imgBg)
	imgBg:setScaleX(0.5)
	imgBg:setScaleY(0.4)
	--各个界面图片
	local img = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(1,2),nil,ItemInfo.icon,"img",5)
	if index == 1 then
		img:setPosition(ccp(1,5))
	end
	cellBg:addChild(img)
	
	local tipText = string.format("tipImg_%d",ItemInfo.id)
	local tipImg = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(46,39),CCSizeMake(34, 34),
					"qipaogantanhao.png",tipText,5)
	cellBg:addChild(tipImg)
	tipImg:setZOrder(20)
	tipImg:setVisible(juegeItemTipVisible(ItemInfo.id))	--测试
	
	local maskImg = CommonFunc_createUIImageView(ccp(0.5,0.5),ccp(0,1),CCSizeMake(123, 100),"social_mask.png","maskImg",5)
	img:addChild(maskImg)
	if ItemInfo.open == 1 then
		maskImg:setVisible(false)
	else
		maskImg:setVisible(true)
	end
	return cellBg
end

--设置几个功能图标
local function setScrollIcon()
	if nil == mSocialContactSwitchDatas then
		mSocialContactSwitchDatas = LogicTable.getSocialContactTable()
	end
	mSocialContactSwitchDatas = LogicTable.getSocialContactTable()
	local scroll = tolua.cast(mSocContEnLayerRoot:getChildByName("ScrollView_65"), "UIScrollView")
	scroll:setZOrder(50)
	-- 社交列表
	local dataTable = {}
	for key, val in pairs(mSocialContactSwitchDatas) do
		table.insert(dataTable, val)
	end
	UIScrollViewEx.show(scroll,dataTable,createIConItem,"H", 122, 104, 12, 1, 4, true, nil, true, true)
end
----------------------------------------------------------------------
LayerSocialContactEnter.init = function(rootView)
	mSocContEnLayerRoot = rootView
	
	local closeBtn = tolua.cast(mSocContEnLayerRoot:getChildByName("close"), "UIImageView")			-- 关闭按钮
	closeBtn:registerEventScript(clickBtn)
	
	local nameLbl = tolua.cast(mSocContEnLayerRoot:getChildByName("nameLbl"), "UILabel")			--
	nameLbl:setText(ModelPlayer.getNickName())
	local pubLbl = tolua.cast(mSocContEnLayerRoot:getChildByName("pubLbl"), "UILabel")	--
	pubLbl:setText("无")
	
	local textFriendCount = string.format("%d/%d",FriendDataCache.getLengthOfListItem_list(),Friend_Max_Count)
	local friendCount = tolua.cast(mSocContEnLayerRoot:getChildByName("friendCount"), "UILabel")	
	friendCount:setText(textFriendCount)	
	
	--local fightCount = string.format("%d/%d",#LayerInviteCode.getInviteCodeInfo().prentice_list,Invite_Code_Max_Friend)
	local fightFriendCount = tolua.cast(mSocContEnLayerRoot:getChildByName("fightFriendCount"), "UILabel")	--
	fightFriendCount:setText(tostring(FriendDataCache.getFightFriendCount()))	

	setScrollIcon()
	
	TipModule.onUI(rootView, "ui_socialenter")
end
----------------------------------------------------------------------
LayerSocialContactEnter.destroy = function()
   mSocContEnLayerRoot = nil
   
   
end 
----------------------------------------------------------
--当有好友的信息时，设置好友按钮显示感叹号
LayerSocialContactEnter.showFriendTip = function(str)
	if mSocContEnLayerRoot == nil then
		return
	end

    local friendImageView = tolua.cast(mSocContEnLayerRoot:getChildByName("cellBg_1"), "UIImageView")
	local firendTip = friendImageView:getChildByName("tipImg_1")
	if CopyDateCache.getCopyStatus(LIMIT_FRIEND.copy_id) ~= "pass"  then
		firendTip:setVisible(false)
		return
	end
	
	firendTip:setVisible(str)
end

--当有邀请码的信息时，设置邀请码显示感叹号
LayerSocialContactEnter.showInviteTip = function(str)
	if mSocContEnLayerRoot == nil then
		return
	end
    local inviteImageView = tolua.cast(mSocContEnLayerRoot:getChildByName("cellBg_2"), "UIImageView")
	local inviteTip = inviteImageView:getChildByName("tipImg_2")
	inviteTip:setVisible(str)
end



--[[
	if nil == firendTip then
		firendTip = UIImageView:create()
		firendTip:setAnchorPoint(ccp(0.5, 0.5))
		firendTip:setPosition(ccp(62, 46))
		firendTip:setZOrder(10000)
		firendTip:setName("friend_tip")
		firendTip:loadTexture("friends_notice2.png")
		friendImageView:addChild(firendTip)
    end
	
    if str == "true" then
		print("显示出来***LayerSocialContactEnter.showUnreadInfo*******")
		firendTip:setVisible(true)
	elseif str == "false" then
		print("显示false***LayerSocialContactEnter.showUnreadInfo*******")
		firendTip:setVisible(false)
	end
	]]--