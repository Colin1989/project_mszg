
-------------------------------------
--作者：李慧琴
--说明：好友聊天界面
--时间：2014-3-7
-------------------------------------

FriendChat = {}

local mFriendChatRoot = nil      --当前界面的根节点
local  friendId                  --判断当前聊天的好友
 local  inputText                  --隐藏的输入框
local label                        --显示的lbl
 local moveUp                    --整个上移的部分
local scrollview                 --可滚动的scrollview
local  tempMsg     --保存上一次的发送的信息
local  length  = 0
local  otherName      --对方的名字

LayerAbstract:extend(FriendChat)

local function clicks(type1,widget)
   
  widgetName = widget:getName()
 if type1 == "releaseUp" then
     if widgetName == "sendBtn"  then
       
	   local str = FriendDataCache.getOnLineNum_list(friendId)
	  if str == "true" then     --不在线    --如果不在线，聊天做灰色处理
		 Toast.show("该好友不在线,不能发送聊天信息")
	  elseif  str == "false" then
	
		  if  length == 0  then	
			 Toast.show("请输入要发送的内容")
		  else
		       tempMsg = inputText:getStringValue()
		      if  length <= 30*3 then
		            if moveUp ~= nil  then                        --防止没有点击输入就发送的情况
			           moveUp:setPosition(ccp(-70,-300))              --发送完数据后返回原来的位置
			        end
			       print("请求聊天前的id",friendId)
		           FriendDataCache.req_sendChat(friendId,inputText:getStringValue())   --请求发送信息
			        if label~= nil and inputText~= nil then
			            label:setText("")
			            inputText:setText("")
			        end
		       elseif length > 30  then	          --为了测试，先改为5个字
			        Toast.show("不能超过30个字")
		       end	
		   end
	    end
     elseif widgetName =="closeBtn" then
         UIManager.pop("UI_FriendChat")
     end
  end

end



--把输入的字写到lbl里，并监听输入框的输入
local function onTouchBegan(type,widget)
	  
	
	print("type",type)
    moveUp =  mFriendChatRoot:getWidgetByName("inputback")     --输入时，输入框上移????????
    tolua.cast(label,"UIImageView")
	
	if type =="attachWithIME" then
		   print("我要上移了attachWithIme")		
		 moveUp:setPosition(ccp(-2,240))
				
	--elseif type == "detachWithIME" then
	     --  print("我要下移了detachWithIme")		                        
	  --   moveUp:setPosition(ccp(5,-230))              --发送完数据后返回原来的位置
				
	elseif type =="insertText" or type == "deleteBackward" then
	          print("我开始插入了insertText,deleteBackward")
		
		 local str= inputText:getStringValue()
		      print("我输入的内容",inputText:getStringValue())

         label =   mFriendChatRoot:getWidgetByName("Label_47")     --显示文字的lbl
	    tolua.cast(label,"UILabel")
		if str~= nil then
			label:setText(str)
		end	
		 length = label:getStringLength()
		      print("我输入的长度length:",length)
			
	end
		
end




FriendChat.init = function(bundle)
      
	friendId = bundle
    mFriendChatRoot = UIManager.findLayerByTag("UI_FriendChat")

    local sendBtn = mFriendChatRoot:getWidgetByName("sendBtn")   --发送消息
    tolua.cast(sendBtn,"UIButton")
    sendBtn:registerEventScript(clicks)
	
    local close = mFriendChatRoot:getWidgetByName("closeBtn")    --关闭
    tolua.cast(close,"UIButton")
    close:registerEventScript(clicks)  
	
	    inputText =  mFriendChatRoot:getWidgetByName("input")     --隐藏的输入框	
	    tolua.cast(inputText,"UITextField")
		inputText:setMaxLength(30)
		inputText:registerEventScript(onTouchBegan)
    
			 
		
     scrollview =  mFriendChatRoot:getWidgetByName("ScrollView_46")  
	 tolua.cast(scrollview,"UIScrollView")
	-- scrollview:removeAllChildren()              --把之前已经赋值过的东西删除掉
	 FriendChat.showMessage(friendId)            ---也就是退出聊天界面后，再一次进入聊天界面的情况
	
	  otherName =  mFriendChatRoot:getWidgetByName("Label_71") 
	  tolua.cast(otherName,"UILabel")
	  local str = FriendDataCache.findName_receiveChat(friendId)
	  print("对方的名字：",str)
	  otherName:setText(string.format("和%s的聊天",str))
end




FriendChat.showMessage = function(id)
      print("FriendChat.showMessage",id)
   local  msgTb =  FriendDataCache.initCurChatMsg_receiveChat(friendId)       --保存要显示的信息
    print ("信息的个数：",#msgTb)              --------------还是位置问题啊？？？？？？？
	scrollview:removeAllChildren()              --把之前已经赋值过的东西删除掉
	 local scrollItem ={}
	for key,value in pairs(msgTb) do
		  --print("chat表数据：",key,value)
		local label =UILabel:create()  --往里面添加好友说的话，   
        label:setSize(CCSizeMake(560,50))
		label:setFontSize(30)
		local ownName = ModelPlayer.getNickName()
		label:setText(string.format("[%s]:%s",value.name,value.msg))
		label:setTextHorizontalAlignment(kCCTextAlignmentRight)
		if value.name == ownName then	
			label:setColor(ccc3(253,245,95))                     
		end
	
		table.insert(scrollItem,label)
		setListViewAdapter(FriendChat,scrollview,CommonFunc_InvertedTable(scrollItem),"V")
	end
end


--记得判断是不是发给同一个人
FriendChat.sendData =function()
   print("FriendChat.sendData")
   local temp = {}
   temp.name = ModelPlayer.getNickName()
   temp.msg =  tempMsg
print("发送的信息：FriendChat",temp.msg)                       ---------这个需要测试一下啊？？？？？？？？
   return temp
end









--scrollview的封装


--LayerMain。lua89行，是在当前界面，才要进行内容刷新---------------

--聊天字数限制在30个字,最多显示10条




--lbl的监听（已经完成）
--整体上移