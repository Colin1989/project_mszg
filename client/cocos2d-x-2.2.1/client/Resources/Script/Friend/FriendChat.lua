
-------------------------------------
--作者：李慧琴
--说明：好友聊天界面
--时间：2014-3-7
-------------------------------------

FriendChat = {}

local 	mFriendChatRoot = nil      	--当前界面的根节点
local 	friendId                  	--判断当前聊天的好友
local  	inputText                  	--隐藏的输入框
local 	label                       --显示的lbl
local 	moveUp                    	--整个上移的部分
local 	scrollview                 	--可滚动的scrollview
local  	tempMsg     				--保存上一次的发送的信息
local  	length  = 0
local  	otherName      				--对方的名字
local   slider

LayerAbstract:extend(FriendChat)

local function clicks(type1,widget) 
	widgetName = widget:getName()
	if type1 == "releaseUp" then
		if widgetName == "sendBtn"  then
			tempMsg = inputText:getText()
			if tempMsg == "" then
				Toast.Textstrokeshow(GameString.get("InputChatContent"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			else
				FriendDataCache.req_sendChat(friendId,inputText:getText())   --请求发送信息
			end	
		elseif widgetName =="closeBtn" then
			UIManager.pop("UI_FriendChat")
			FriendDataCache.deleteTb_receive(friendId)         --删除已经点击的发送消息的标志（数据）
			LayerFriendList.setUI("friendImage")
			FriendDataCache.setMainFlag()
		end
	end
end

FriendChat.init = function(bundle)

	friendId = bundle.friendId
    mFriendChatRoot = UIManager.findLayerByTag("UI_FriendChat")
	
    local sendBtn = mFriendChatRoot:getWidgetByName("sendBtn")   	--发送消息
    tolua.cast(sendBtn,"UIButton")
    sendBtn:registerEventScript(clicks)
    local close = mFriendChatRoot:getWidgetByName("closeBtn")    	--关闭
    tolua.cast(close,"UIButton")
    close:registerEventScript(clicks)  
	otherName =  mFriendChatRoot:getWidgetByName("Label_71") 
	tolua.cast(otherName,"UILabel")
	local str = FriendDataCache.findName_receiveChat(friendId)
	otherName:setText(string.format(GameString.get("FriendName",str)))
	
	inputBack =   mFriendChatRoot:getWidgetByName("background")    		
	tolua.cast(inputBack,"UIImageView")
	inputText =  CommonFunc_createCCEditBox(ccp(0.5,0.5),ccp(-40,-283), CCSizeMake(434,40),"touming.png",
				10,30,GameString.get("InputChatContent"),kEditBoxInputModeAny,kKeyboardReturnTypeDefault)
	inputText:setTouchEnabled(true)
	inputBack:addRenderer(inputText,30)
	
	slider = mFriendChatRoot:getWidgetByName("Slider_65")           --滑动条
	slider:setEnabled(true)
	slider:setTouchEnabled(true)
	tolua.cast(slider,"UISlider")
	slider:registerEventScript(                            		   --根据滑动条的值，设置滚动条的位置
		function(type,widget)
		   if type == "releaseUp" then   --percentChanged	
			   local percent = slider:getPercent()   
               local contair = scrollview:getInnerContainer()  
					local height = contair:getSize().height
				 	local pos = scrollview:getInnerContainer():getPosition()		
					 contair:setPosition(ccp(0, - percent/100*(height-475)))
				        pos = scrollview:getInnerContainer():getPosition()
				   end 
	           end
	)
			 	
    scrollview =  mFriendChatRoot:getWidgetByName("ScrollView_46")  
	tolua.cast(scrollview,"UIScrollView")
	scrollview:jumpToTop()    --自带的方法，很好用哦
	scrollview:setTouchEnabled(true)
	scrollview:registerEventScript(
					function(typename,widget) 
						local contair = scrollview:getInnerContainer()
						local height = contair:getSize().height
						local pos = contair:getPosition()
						local kuangH = scrollview:getSize().height

						local Ratio = math.abs(pos.y)/(height-kuangH) * 100
						--cclog(string.format("height:%d,pos.y:%d,kuangH:%d,Ratio:%d",height,pos.y,kuangH,Ratio,pos.x))
						slider:setPercent(Ratio)								
					end)	
								
	FriendChat.showMessage(friendId)            ---也就是退出聊天界面后，再一次进入聊天界面的情况

end

-------------别人说的话(左边)
local function  createLeft(itemPanel,name,msg)
	local anchorPoint = ccp(0.5,0.5)
	--箭头
	bling  = CommonFunc_createUIImageView(anchorPoint, ccp(61,101), CCSizeMake(36,36), "friends_Modify_12.png", nil, 8)
	itemPanel:addChild(bling)	
	--底板
	jian  = CommonFunc_createUIImageView(anchorPoint, ccp(243,70), CCSizeMake(338,124), "friends_Modify_10.png", nil, 5)
	jian:setScale9Enabled(true)
	jian:setTextureRect(CCRectMake(0,0,338,124))
	itemPanel:addChild(jian)	
	--往里面添加好友说的话，
	local label = CommonFunc_createUILabel(anchorPoint, ccp(243,67), nil, 23, ccc3(253,245,95), string.format("[%s]:%s",name,msg), nil, 5)   
    label:setSize(CCSizeMake(299,92))
	label:setTextAreaSize(CCSizeMake(299,100))
	label:setTextVerticalAlignment(kCCVerticalTextAlignmentCenter) 
	label:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	itemPanel:addChild(label)	
	--local   width = label:getSize().width
	--local  	height = label:getSize().height
	--label:setTextAreaSize(CCSizeMake(299,height))
	--label:setPosition(ccp(bling:getPosition().x+bling:getSize().width/2+150+7,bling:getSize().height+20))
	--jian:setSize(CCSizeMake(width+20,height+20))	
	--jian:setPosition(ccp(bling:getPosition().x+bling:getSize().width/2+150,bling:getSize().height+20))
	--itemPanel:setSize(CCSizeMake(530,height+16))
	return  itemPanel
end

--自己说的话（右边）
local function createRight(itemPanel,name,msg)
	local anchorPoint = ccp(0.5,0.5)
	--箭头
	bling  = CommonFunc_createUIImageView(anchorPoint,ccp(463,101), CCSizeMake(36,36), "friends_Modify_13.png", nil, 6)
	itemPanel:addChild(bling)	
	--底板
	jian  = CommonFunc_createUIImageView(anchorPoint, ccp(281,70), CCSizeMake(338,124), "friends_Modify_11.png", nil, 5)                   
	jian:setScale9Enabled(true)
	jian:setTextureRect(CCRectMake(0,0,338,124))
	itemPanel:addChild(jian)	
	--往里面添加好友说的话， 
	local label = CommonFunc_createUILabel(anchorPoint,ccp(278,69),nil, 23, ccc3(253,245,95),string.format("[%s]:%s",name,msg), nil, 5)   
	label:setSize(CCSizeMake(308,92))
	label:setTextAreaSize(CCSizeMake(308,100))
	label:setTextVerticalAlignment(kCCVerticalTextAlignmentCenter)
	label:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	itemPanel:addChild(label)
	--local   width = label:getSize().width
	--local  	height = label:getSize().height
	--cclog("执行前",height,width)
	--label:setTextAreaSize(CCSizeMake(302,height))
	--cclog("执行后：",height,width)
	--label:setPosition(ccp(bling:getPosition().x - bling:getSize().width/2 - 150 + 22-15 ,bling:getSize().height+20))
	--jian:setSize(CCSizeMake(width+ 15 ,height+10))
	--jian:setPosition(ccp(bling:getPosition().x - bling:getSize().width/2 - 150 - 2 ,bling:getSize().height+20))
	--itemPanel:setSize(CCSizeMake(530,height+30))
	return  itemPanel
end

FriendChat.showMessage = function(id)
    local  msgTb =  FriendDataCache.initCurChatMsg_receiveChat(friendId)    --保存要显示的信息
	scrollview:removeAllChildren()              							--把之前已经赋值过的东西删除掉
	local scrollItem ={}
	for key,value in pairs(msgTb) do
		local  itemPanel = UILayout:create()                				--整个大的容器
		itemPanel:setSize(CCSizeMake(530,135))
		itemPanel:setAnchorPoint(ccp(0.5,0.5))
		--itemPanel:setBackGroundColor(ccc3(120,230,120))
		--itemPanel:setBackGroundColorType(LAYOUT_COLOR_SOLID)
		local label
		local ownName = ModelPlayer.getNickName()
	    local str = FriendDataCache.findName_receiveChat(friendId)     		--对方的名字，为了防止不在好友界面，收到的请求（不知别的会不会错）
		if value.name == ownName then	
		    itemPanel =  createRight (itemPanel,value.name,value.msg) 
        else
			itemPanel =  createLeft (itemPanel,str,value.msg) 
		end
		table.insert(scrollItem,itemPanel)
		setListViewAdapter(FriendChat,scrollview,CommonFunc_InvertedTable(scrollItem),"V")
		scrollview:jumpToBottom()
	end
	inputText:setText("")
end

--记得判断是不是发给同一个人
FriendChat.sendData =function()
   local temp = {}
   temp.name = ModelPlayer.getNickName()
   temp.msg =  tempMsg
   return temp
end



