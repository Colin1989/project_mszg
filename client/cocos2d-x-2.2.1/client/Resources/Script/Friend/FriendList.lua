-------------------------------------
--作者：李慧琴
--说明：好友列表界面
--时间：2014-2-28
-------------------------------------

LayerFriendList = {}
local   widgetTable = {}
local 	mLayerFriendListRoot = nil 
local   friendsTb               --每页，好友列表的数据
local   addFriendsTb            -- 每页，添加好友列表的数据
local   imgStr = "friendImage"  --保存点击的是哪个按钮
local   addFriendsIdTb          --保存id ，为了同意添加对方为好友而
local   addFriend               --显示好友列表的图片
local   addBtn                  --添加好有的界面
local   myFriend                --我的好友题目
local   searchPanel             --搜索的panel
local   inputText           	--输入框
local   contentScrollView		--中间的滚动条

local 	mNewDay = true				-- 新的一天(领取体力12点置0)
local 	anchorPoint = ccp(0.5,0.5)
---------------------------------------------------------------------------------
--点击好友列表触发的方法
local  function  clickFriendItem(types,widget)
	widgetName =widget:getName()
	local tb = {}    --保存当前点击的页数（为了获得当前页的信息）和点击的是第几个
	if types == "releaseUp"  then
		for key,value in pairs(friendsTb) do
			if widgetName == string.format("Panel_list_%d",key) then	--聊天
				local index  = FriendDataCache.receiveTb_receive()  --保存发送消息的好友的id
				for k,v in pairs(index) do
					if v ==  value.friend_id then
						local  tb={}
						tb.friendId= value.friend_id
						UIManager.push("UI_FriendChat",tb)
						return
					end
				end
				table.insert(tb,key)
				FriendDataCache.deleteTb_receive(value.friend_id)         --删除已经点击的发送消息的标志（数据）
				UIManager.push("UI_FriendInfo",tb)	
			elseif widgetName == string.format("deleteBtn_%d",key) then	  --原删除好友，变为赠送体力
				--FriendInfo.deleteFriend (value.friend_id)
				FriendDataCache.reqSendPower(value.friend_id)
				widget:setTouchEnabled(false)
				Lewis:spriteShaderEffect(widget:getVirtualRenderer(), "buff_gray.fsh",true)
			elseif widgetName == string.format("chatBtn_%d",key) then
				--print("*******好友*********************",key,value.friend_id)
				local tb ={}
				tb.friendId = value.friend_id
				FriendDataCache.deleteTb_receive(value.friend_id)         --删除已经点击的发送消息的标志（数据）
				UIManager.push("UI_FriendChat",tb)
			elseif widgetName == string.format("getHpBtn_%d",key) then	  -- 领取体力
				FriendDataCache.reqGetHp(value.friend_id)
				widget:setVisible(false)
				widget:setTouchEnabled(false)
				LayerFriendList.hpFlyAction(widget)
			end
		end	
    end
end

--点击添加对方为好友触发的方法
local function onAddItemClick (type,widget)
	widgetName =widget:getName()
	if type == "releaseUp" then
		for key,value in pairs(addFriendsIdTb) do	
			--双方互发好友请求，且一方同意，的情况
			 for k,v in pairs(FriendDataCache.getFriendInfo_list()) do
				if v.friend_id == value then
					Toast.Textstrokeshow(GameString.get("IsFriAlready"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
					FriendDataCache.changeUnreadInfo_process(key)
					LayerFriendList.setUI(imgStr)
					return
				end
			end
				
			if widgetName == string.format("agreeBtn_%d",key) then    		--同意添加对方为好友
				FriendDataCache.processRequest_process(value,answer_type["agree"])   --好友id？？？？
			elseif   widgetName == string.format("refuseBtn_%d",key) then  	 --拒绝添加对方为好友
				FriendDataCache.processRequest_process(value,answer_type["defuse"]) 
				--FriendDataCache.changeUnreadInfo_process(key) 
				--  FriendDataCache.delete_search(key) (不是同一个客户端)
				LayerFriendList.setUI(imgStr)
			end
			FriendDataCache.changeUnreadInfo_process(key)
		end
	end
end

--搜索好友按钮头像和加为好友触发的方法
local function  searchFriendIconClick(clicktype,widget)  
	widgetName =  widget:getName()	
	if clicktype =="releaseUp" then	
		if widgetName == "headbackground_1" then 
			UIManager.push("UI_FriendInfo")
		elseif widgetName == "addBtn_search" then
			FriendDataCache.add_search(FriendDataCache.info_search().friend_id)
		end
	end	
end
----------------------------------------------------------------------------------------------------------------------
--根据好友id，设置notice是否显示
local function  setNoticeStr (id)
	local index  = FriendDataCache.receiveTb_receive()  --保存发送消息的好友的id
	for k,v in pairs(index) do
		if v ==  id then
			return "true"
		end
	end	
	return "false"
end

--根据收到的聊天信息，加载某条信息的信息提示
LayerFriendList.showChatNotice = function()
	if mLayerFriendListRoot == nil then
		return
	end
	friendsTb={}
	friendsTb = FriendDataCache.getFriendInfo_list()
	for key,value in pairs(friendsTb) do 
		local  panel = mLayerFriendListRoot:getChildByName(string.format("Panel_list_%d",key))
		if panel == nil then
			print("****showChatNotice************",key,#friendsTb)
			return
		end
		local  iconWidget = panel:getChildByName(string.format("notice_%d",key))
		local  chatNotice  = setNoticeStr(value.friend_id)
		if chatNotice == "true"  then 
			iconWidget:setVisible(true)
		elseif  chatNotice == "false"  then 
			iconWidget:setVisible(false)
		end 
	end	
end

--显示好有列表界面的信息
local function setFriendImageUI()
	friendsTb={}
	friendsTb = FriendDataCache.getFriendInfo_list()

	if friendsTb ~= nil then
		--创建列表单元格
		local function createCell(cellBg, ItemData, index)
			local head = ModelPlayer.getProfessionIconByType(ItemData.head,ItemData.advanced_level) 		--表示头像
			local info, poInfo = FriendDataCache.getCurFriendInfo_list(index)   		--战斗力
			local chatNotice  = setNoticeStr(ItemData.friend_id)					--是否有聊天的信息
			if ItemData.is_comrade == 0 then										--战力图标标志(服务端给)
				powerIconFlag = false
			else
				powerIconFlag = true
			end						
			local getHpFlag = FriendDataCache.isSendedHpById(ItemData.friend_id)	--领取体力按钮标志
			local cellBg = LayerFriendList.FriendListScrollItem(ItemData.nickname,ItemData.level,poInfo,head,chatNotice,imgStr,index,powerIconFlag,getHpFlag,info)
			return cellBg
		end
		UIScrollViewEx.show(contentScrollView, friendsTb, createCell, "V", 571, 135, 3, 1, 5, true, nil, true, true)	
	end
	
	if #FriendDataCache.receiveTb_receive() ~= 0 then 	--在线的聊天消息
		LayerFriendList.showChatNotice()
	end	
end

--显示添加好友列表界面的信息
local function setAddImageUI()
	addFriendsTb,addFriendsIdTb,addFriendsPower ={},{},{}
	addFriendsTb,addFriendsIdTb,addFriendsPower  =  FriendDataCache.getCurPageInfo_process ()
	if addFriendsTb ~= nil then   
		--print("setAddImageUI**********************",#addFriendsTb)
		--创建列表单元格
		local function createCell(cellBg, ItemData, index)
			local	head = ModelPlayer.getProfessionIconByType(ItemData.head,ItemData.advanced_level) 		--表示头像
			cellBg = LayerFriendList.FriendAddScrollItem (ItemData.nickname,ItemData.level,addFriendsPower[index],head,"false","addImage",index)
			return cellBg
		end
		UIScrollViewEx.show(contentScrollView, addFriendsTb, createCell, "V", 571, 135, 3, 1, 5, true, nil, true, true)
	end
end

--设置搜索界面的信息显示
LayerFriendList.setSearchUI = function()
	local  	searchInfo = FriendDataCache.info_search ()
	
	local 	scrollItem ={}
	local	head = ModelPlayer.getProfessionIconByType(searchInfo.head,searchInfo.advanced_level) 		--表示头像
	local   panel = LayerFriendList.FriendSearchScrollItem(searchInfo.nickname,searchInfo.level,searchInfo.battle_prop.power,head,"false","searchImage",1)
	table.insert(scrollItem,panel) 
	setAdapterGridView(contentScrollView,scrollItem,1,0)
	
	--[[
	--创建列表单元格
	local function createCell(cellBg, ItemData, index)
		local	head = ModelPlayer.getProfessionIconByType(searchInfo.head,searchInfo.advanced_level) 		--表示头像
		local   cellBg = LayerFriendList.FriendSearchScrollItem(searchInfo.nickname,searchInfo.level,searchInfo.battle_prop.power,head,"false","searchImage",1)
		return cellBg
	end
	UIScrollViewEx.show(contentScrollView, friendsTb, createCell, "V", 642, 152, 3, 1, 5, true, nil, true, true)
	]]--
end
----------------------------------------------------------------------------------------------------
--添加按钮回调方法
local function  addImageClick()
	searchPanel:setEnabled(true)
	searchPanel:setVisible(true)
	searchPanel:setTouchEnabled(true)
	
	back = mLayerFriendListRoot:getChildByName("inputbackground")
	tolua.cast(back,"UIImageView")
	--back:setTouchEnabled(false)

	inputText = mLayerFriendListRoot:getChildByName("inputTextField")   --输入的角色名
    tolua.cast(inputText,"UITextField")	
	inputText:setPlaceHolder(GameString.get("InputFriName"))
	inputText:setMaxLengthEnabled(true)                --记得到时候打开
	inputText:setMaxLength(6)
	inputText:setTouchEnabled(true)
	setTextFieldFocus(inputText)
	myFriend:loadTexture("friends_text_10.png")
	addFriend:loadTexture("friends_listfriend_02.png")              
	addBtn:loadTexture("friends_addlight_02.png")
	imgStr = "addImage"   
end

--好友按钮回调方法
local function friendImageClick()
	searchPanel:setEnabled(false)
	myFriend:loadTexture("friends_text_09.png") 	--设置题目 
	addFriend:loadTexture("friends_listfriend_01.png")         --换为选中图片      
    addBtn:loadTexture("friends_add_02.png")                
	imgStr = "friendImage"               --为了方便上下翻时，确定是点击了两个好友和添加中的哪一个
end

--搜索按钮回调方法
local function searchImageClick()
	if  inputText:getStringValue()== "" then
		CommonFunc_CreateDialog( GameString.get("InputFriName"))
	elseif inputText:getStringValue()~= "" then
		imgStr = "searchImage"
		FriendDataCache.reqSearchFriends_search( inputText:getStringValue())   --先搜索，再添加
	end
end

--点击页面各个按钮触发的方法（翻页，好友，添加，搜索）		
local function enterAnotherUI(type,widget)
	widgetName =  widget :getName()
	if type == "releaseUp" then
		if widgetName == "friendImage" then         --好友按钮
			friendImageClick()
		elseif widgetName == "addImage" then        --添加按钮
			addImageClick()   
		elseif widgetName == "searchBtn"  then      --搜索按钮  
			searchImageClick()		
		elseif widgetName == "close"  then      	--关闭按钮  
			setConententPannelJosn(LayerSocialContactEnter,"SocialContact.json",weightName)
		end
		LayerFriendList.setUI(imgStr)
	end
end
----------------------------------------------------------------------------------------------------------------------
--切换好友列表和添加列表
local function  setItemVYN(imageType) 
    contentScrollView:removeAllChildren()
	if imageType == "friendImage"  then
		friendImageClick()
        setFriendImageUI()
    elseif imageType == "addImage" then
		addImageClick()
		setAddImageUI()
	elseif imageType == "searchImage" then

    end
end

--显示未读的消息个数（当有好友请求时）
LayerFriendList.showUnreadInfo = function(num)  
	if mLayerFriendListRoot == nil then
		return
	end
    local unReadNum  =  mLayerFriendListRoot:getChildByName("unreadLabel")   
    tolua.cast(unReadNum  ,"UIImageView") 
	unReadNum:setVisible(true)
	if num == 0 then
		unReadNum:setVisible(false)
	elseif num~= 0 then
	   unReadNum:setVisible(true)
	end     		
end

--设置界面（设置列表） ， str = imgStr
LayerFriendList.setUI = function(str)
	if mLayerFriendListRoot == nil then
		return
	end
	local length =  FriendDataCache.getLengthOfUnreadInfo_process ()      --(1)更改未读消息--更改好友个数(根据系统消息，已经更改)
	LayerFriendList.showUnreadInfo(length)                                 	
    local onLineNum =  mLayerFriendListRoot:getChildByName("LabelAtlas_82")          -- 设置好友人数和好友上限
    tolua.cast(onLineNum,"UILabelAtlas")
	onLineNum:setStringValue(string.format("%d/%d",FriendDataCache.getLengthOfListItem_list(),Friend_Max_Count)) 
 	FriendDataCache.setMainFlag()  -----?????????????
	setItemVYN(str)                                               --刷新界面	
end

------------------------------------------------------------------------------------------------
--获取当前点击在不在好友列表界面或者是好友添加界面
LayerFriendList.getCurFriendStatus = function()
	return  imgStr
end

--设置界面信息
LayerFriendList.setCurFriendStatus = function(str)
	imgStr = str
end

LayerFriendList.init = function (RootView)
	mLayerFriendListRoot = RootView
	--FriendDataCache.showSystemMsg_list()                            --显示提示消息
	
	closeBtn =  mLayerFriendListRoot:getChildByName("close")  --获得好友按钮(会换为图片，而不是btn')
    tolua.cast(closeBtn,"UIImageView")
	closeBtn:setTouchEnabled(true)
	closeBtn:registerEventScript(enterAnotherUI)
    addFriend =  mLayerFriendListRoot:getChildByName("friendImage")  --获得好友按钮(会换为图片，而不是btn')
    tolua.cast(addFriend,"UIImageView")
    addFriend:registerEventScript(enterAnotherUI)
    addBtn=  mLayerFriendListRoot:getChildByName("addImage")       --获得添加按钮
    tolua.cast(addBtn,"UIImageView")
    addBtn:registerEventScript(enterAnotherUI)   
	contentScrollView = mLayerFriendListRoot:getChildByName("ScrollView_67") --中间的滚动条
	tolua.cast(contentScrollView,"UIScrollView")
	myFriend = mLayerFriendListRoot:getChildByName("ImageView_56")  	--切换后的题目
    tolua.cast(myFriend,"UIImageView") 
	searchPanel = mLayerFriendListRoot:getChildByName("Panel_search") 	--搜索panel
    tolua.cast(searchPanel,"UILayout") 
	local search = searchPanel:getChildByName("searchBtn") 				--搜索好友按钮
    search:registerEventScript(enterAnotherUI) 
	
	LayerFriendList.setUI(LayerFriendList.getCurFriendStatus()) 

end

--------------------------------------------------------------------------------------------------------------
-- 创建好友列表界面，，，，参数为：imgStr(是否在线),名字,等级，战斗力，图片，判断panle或头像的点击事件,表示是第几个 
LayerFriendList.FriendListScrollItem = function(nameTxt,levelTxt,powerStr,headStr,noticeStr,imageStr,key,powerIconStr,getHpStr,info)	
	local color = ccc3(255,255,255)
	local itemPanel =  CommonFunc_createUILayout(anchorPoint,nil, CCSizeMake(571,135), nil,1)
	itemPanel:setBackGroundImage("public3_friend_01.png") 
	local  headbackground = CommonFunc_createUIImageView(anchorPoint, ccp(68,66), CCSizeMake(94,94), 
							headStr, string.format("headbackground_%d",key), 1)
	itemPanel:addChild(headbackground)
	if imageStr == "friendImage" then
		itemPanel:setName(string.format("Panel_list_%d",key))
		headbackground:setTouchEnabled(false)
		itemPanel:setTouchEnabled(true)
		itemPanel:registerEventScript(clickFriendItem)             --为item注册事件
	elseif imageStr == "addImage" then
		itemPanel:setName(string.format("Panel_add_%d",key))
		itemPanel:setTouchEnabled(false)
		headbackground:setTouchEnabled(false)	
	elseif imageStr == "searchImage" then
		itemPanel:setTouchEnabled(false)
		headbackground:setTouchEnabled(true)
		headbackground:registerEventScript(searchFriendIconClick)     --为头像注册事件
	end
	local  name = CommonFunc_createUILabel(anchorPoint, ccp(237,104), nil, 20,color, nameTxt, 1, 1)	--名字
    itemPanel:addChild(name)
	local  level = CommonFunc_createUILabel(anchorPoint,ccp(215,30), nil, 20,color, levelTxt, 1, 1)	--等级
    itemPanel:addChild(level)
	local  power = CommonFunc_createUILabel(anchorPoint,ccp(215,67), nil, 20,color, powerStr, 1, 1)	--战斗力
    itemPanel:addChild(power)
	local  notice = CommonFunc_createUIImageView(anchorPoint,ccp(109,101), CCSizeMake(28,28), 
			"friends_notice.png",string.format("notice_%d",key ), 1)
	notice:setVisible(false)
    itemPanel:addChild(notice)
	if imgStr == "friendImage" then			--添加 删除好友和聊天 按钮
		--现在的删除好友，改为赠送体力
		local deleteBtn = CommonFunc_createUIButton(anchorPoint,ccp(476,97),CCSizeMake(140,58),26,
				ccc3(255,225,68),"",string.format("deleteBtn_%d",key),"public_newbuttom_6.png","public_newbuttom_6.png",1)
		deleteBtn:registerEventScript(clickFriendItem)												
		itemPanel:addChild(deleteBtn)
		local imgDel = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(96,27), "text_songtili.png", "delZhi",1 )
		deleteBtn:addChild(imgDel)
		if info[1].my_send_status == send_hp_status["send_hp_none"] or info[1].my_send_status == 0 then
			Lewis:spriteShaderEffect(deleteBtn:getVirtualRenderer(), "buff_gray.fsh",false)
			deleteBtn:setTouchEnabled(true)
			deleteBtn:registerEventScript(clickFriendItem)
		else
			deleteBtn:setTouchEnabled(false)
			Lewis:spriteShaderEffect(deleteBtn:getVirtualRenderer(), "buff_gray.fsh",true)
		end
		
		
		
		local chatBtn = CommonFunc_createUIButton(anchorPoint,ccp(476,37),CCSizeMake(140,58),26,
				ccc3(255,225,68),"",string.format("chatBtn_%d",key),"public_newbuttom.png","public_newbuttom.png",1)
		local imgChat = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(96,27), "friends_text_05.png", "chatZhi",1 )
		chatBtn:addChild(imgChat)
		chatBtn:registerEventScript(clickFriendItem)												
		itemPanel:addChild(chatBtn)
		--战力图标（缺少判断条件*************）
		local  powerIcon = CommonFunc_createUIImageView(anchorPoint,ccp(45,45), CCSizeMake(34,34), 
				"uiiteminfo_zhanyou.png",string.format("power_%d",key ), 1)
		powerIcon:setVisible(powerIconStr)
		itemPanel:addChild(powerIcon)
		
		--领取体力
		local getHPBtn = CommonFunc_createUIButton(anchorPoint,ccp(355,45),CCSizeMake(71,71),26,
					ccc3(255,225,68),"",string.format("getHpBtn_%d",key),"laddermatch_button_get.png","laddermatch_button_get.png",1)
		getHPBtn:setVisible(getHpStr)
		itemPanel:addChild(getHPBtn)
		local imgGetHp = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(52,52), "text_gettili.png", "getHpZhi",1 )
		getHPBtn:addChild(imgGetHp)
		
		local imgTipHp = CommonFunc_createUIImageView(anchorPoint, ccp(33,33), CCSizeMake(34,34), "qipaogantanhao.png", "tip",1 )
		getHPBtn:addChild(imgTipHp)
		if getHpStr == false then
			getHPBtn:setTouchEnabled(false)
		else
			getHPBtn:registerEventScript(clickFriendItem)	
		end
	end
	return  itemPanel
end

--计算偏离位置
local function calOffsetPos(raduis, angle)
	angle = angle / 180.0 * 3.14
	local x = math.sin(angle) * raduis
	local y = math.cos(angle) * raduis
	return ccp(x, y)
end

local function removeSelf(node)
	node:removeFromParentAndCleanup(true)
end

--体力飞行动画
LayerFriendList.hpFlyAction = function(widget)
	destPos = ccp(187,800)
	if mLayerFriendListRoot == nil then
		return
	end
	
	local fromPos = widget:getWorldPosition()
	fromPos = ccpSub(fromPos,ccp(0,152))
	
	local total = math.random(7, 12)
	local delayTime = 0.0
	local moveTime = 0.6
	
	
	mLayerFriendListRoot:getRenderer():stopAllActions()
	for i = 1, total do
		local sprite = CCSprite:create("icon_small_tili.png")
		mLayerFriendListRoot:getRenderer():addChild(sprite, 100)
		
		local offsetPos = calOffsetPos(math.random(60, 90), math.random(0, 360))
		local arr = CCArray:create()
		arr:addObject(CCHide:create())
		arr:addObject(CCDelayTime:create(delayTime))
		arr:addObject(CCShow:create())
		arr:addObject(CommonFunc_curMoveAction(moveTime, fromPos, destPos))
		arr:addObject(CCCallFuncN:create(removeSelf))
		sprite:runAction(CCSequence:create(arr))

		local delta = math.random(8, 14) / 100
		delayTime = delayTime + delta
		moveTime = moveTime - delta / 3
	end
end

--创建添加好友列表界面
LayerFriendList.FriendAddScrollItem = function(nameTxt,levelTxt,powerStr,headStr,noticeStr,imageStr,key)
	local  panel = LayerFriendList.FriendListScrollItem(nameTxt,levelTxt,powerStr,headStr,noticeStr,imageStr,key)
	--同意按钮
	local agreeBtn
	if  FriendDataCache.getLengthOfListItem_list() >=  Friend_Max_Count   then
		agreeBtn = CommonFunc_createUIButton(anchorPoint,ccp(476,97),CCSizeMake(127,53),26,
				ccc3(255,225,68),"",string.format("agreeBtn_%d",key),"shortbutton_gray.png","shortbutton_gray.png",1)
		agreeBtn:setTouchEnabled(false)
	else
		agreeBtn = CommonFunc_createUIButton(anchorPoint,ccp(476,97),CCSizeMake(127,53),26,
				ccc3(255,225,68),"",string.format("agreeBtn_%d",key),"public_newbuttom.png","public_newbuttom.png",1)
		agreeBtn:registerEventScript(onAddItemClick)	
	end
	local imgAgree = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(96,27), "text_agree.png", "agreeZhi",1 )
	agreeBtn:addChild(imgAgree)
	panel:addChild(agreeBtn)
	--拒绝按钮
	local refuseBtn = CommonFunc_createUIButton(anchorPoint,ccp(476,37),CCSizeMake(127,53),26,
				ccc3(255,225,68),"",string.format("refuseBtn_%d",key),"public_newbuttom_4.png","public_newbuttom_4.png",3)
	local imgRefuse = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(96,27), "text_refuse.png", "refuseZhi",1 )
	refuseBtn:addChild(imgRefuse)
	refuseBtn:registerEventScript(onAddItemClick)												
	panel:addChild(refuseBtn)
	return panel
end

--创建搜索好友界面
LayerFriendList.FriendSearchScrollItem = function(nameTxt,levelTxt,powerStr,headStr,noticeStr,imageStr,key)
	local  panel = LayerFriendList.FriendListScrollItem(nameTxt,levelTxt,powerStr,headStr,noticeStr,imageStr,key)
	local  btn = CommonFunc_createUIButton(anchorPoint,ccp(476,67),CCSizeMake(140,58),26,
				ccc3(255,225,68),"","addBtn_search","public_newbuttom.png","public_newbuttom.png",1)
	btn:registerEventScript(searchFriendIconClick)
	local img = CommonFunc_createUIImageView(anchorPoint, ccp(0,0), CCSizeMake(96,27), "text_becomefriend.png", "zhi",1 )
	btn:addChild(img)
	panel:addChild(btn)
	return panel
end
--------------------------------------------------------------------------------------------------------------
LayerFriendList.destroy = function()
	mLayerFriendListRoot = nil
	initUIViewDate()
end

LayerFriendList.purge = function()
	firstEnter = true
end

--12点更新领取和送体力情况
local function updateFriendUI()
	LayerSocialContactEnter.showInviteTip(LayerInviteCode.judgeHasTipInviteCode())
	LayerMore.showSocialContactTip()
	LayerMain.showMoreTip()
	if ( LayerFriendList.getCurFriendStatus() == "friendImage" ) then
        LayerFriendList.setUI("friendImage")          -- 必须得判断为在当前的好友界面，否则会出错
	end
	if (LayerFriendList.getCurFriendStatus() == "addImage" ) then
        LayerFriendList.setUI("addImage")              --点击了添加界面，又点击好友的情况   
	end	
end

--获得当前界面的根节点
LayerFriendList.getLayerRoot = function()
	return mLayerFriendListRoot, "mLayerFriendListRoot"
end

EventCenter_subscribe(EventDef["ED_FRIEND_LIST"],updateFriendUI)
