

FriendDataCache={}

--好友列表的数据

local  	friends = {}           --保存好友列表返回的好友信息
local  	friendPower ={}         --保存好友的战斗力
local  	friendSculpture ={}     --保存好友的雕纹（技能）
local  	addSysTb = {}		 	--保存追加的系统消息
local  	deleteSysTb = {}		--保存删除的系统消息
local	mbOwnDel = false	  	--是否自己手动删除 true表示自己删除 false表示别人删除
local   mbAgreeFriend = false 	--是否自己加对方为好友， true表示是自己请求加对方 ，false表示别人接受请求
local 	mNewDay = true				-- 新的一天
local 	mDailyTimerFlag = false
local   mFriendStatus = nil		--好友界面的状态

local mOffChatAmounts = 0		--离线收到的聊天数量

FriendDataCache.firstRequest = function()
	return  friends
end

-- 当天到达24:00:00
local function dailyTimerOver()
	mNewDay = true
	for key,value in pairs(friends) do
		value.my_send_status = send_hp_status["send_hp_none"]
		value.friend_send_status = send_hp_status["send_hp_none"]
	end
	EventCenter_post(EventDef["ED_FRIEND_LIST"])
end


FriendDataCache.init_list = function(resp)
	if resp.type == 0 then
	
	elseif resp.type == 1 then      --初始化
	    friends = resp.friends
		for key,value in pairs(friends) do
		 	table.insert(friendPower,value.battle_prop.power)                   --战斗力
			table.insert(friendSculpture,value.battle_prop.sculpture)            --雕纹技能
        end
		mNewDay = false
		if false == mDailyTimerFlag then
			mDailyTimerFlag = true
			SystemTime.createDailyTimer(24, 0, 0, dailyTimerOver)
		end
		mFriendStatus = LayerFriendList.getCurFriendStatus()
	elseif resp.type == 2  then     -- 追加
		--cclog("返回的类型为2：追加")
		local name = nil
		for key,value in pairs(resp.friends) do
			table.insert(friends,value)
			table.insert(friendPower,value.battle_prop.power)                   --战斗力
			table.insert(friendSculpture,value.battle_prop.sculpture)            --雕纹技能
			table.insert(addSysTb,value.friend_id)
			name = value.nickname
		end	
		--FriendDataCache.showSystemMsg_list()
		FriendDataCache.delete_search(resp.friends[1].friend_id)   
		if LayerFriendList.getLayerRoot() ~= nil  and mbAgreeFriend == false  then
			--LayerFriendList.setUI("friendImage")
			Toast.Textstrokeshow(GameString.get("AddSomeFriSuc",name), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		elseif  LayerFriendList.getLayerRoot() ~= nil and mbAgreeFriend == true  then
			--LayerFriendList.setUI("friendImage")
			Toast.Textstrokeshow(GameString.get("AddFriSucess"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		end	
		mbAgreeFriend = false
	elseif resp.type == 3 then      --删除
	    --cclog("返回的类型为3：删除")
		local  name =nil
		for key,value in pairs(friends) do
			table.insert(deleteSysTb,value.friend_id)
			if value.friend_id == resp.friends[1].friend_id then
				table.remove (friends,key) 
				table.remove(friendPower,key)                   --战斗力
				table.remove(friendSculpture,key)            --雕纹技能
				name = value.nickname
			end
		end
		
		if mbOwnDel == false and LayerFriendList.getLayerRoot() ~= nil then
			Toast.Textstrokeshow(GameString.get("DeleteSomeFri",name), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		elseif mbOwnDel == true and LayerFriendList.getLayerRoot() ~= nil then
			Toast.Textstrokeshow(GameString.get("DeleFriSuc"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		end
		mbOwnDel = false
		
		FriendDataCache.delete_search(resp.friends[1].friend_id)	
	elseif resp.type == 4 then      --修改
	    --cclog("返回的类型为4：修改是否在线")
		for key,value in pairs(friends) do
			if value.friend_id == resp.friends[1].friend_id then
				--friends[key] = resp.friends[1] 				--为了好友送体力，做的特殊处理
				friendPower[key] = resp.friends[1].battle_prop.power
				friendSculpture[key] =  resp.friends[1].battle_prop.sculpture             
			end
		end	
	end
	EventCenter_post(EventDef["ED_FRIEND_LIST"])
end

--同时收到多条消息时的处理函数
FriendDataCache.showSystemMsg_list = function()
	if #addSysTb ~= 0 and LayerFriendList.getLayerRoot() ~= nil then		--Toast.show("添加好友成功")
		Toast.Textstrokeshow(GameString.get("AddFriSucess"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		addSysTb={}
		return
	elseif  #deleteSysTb ~= 0 and LayerFriendList.getLayerRoot() ~= nil then	
		--CommonFunc_CreateDialog( GameString.get("DeleFriSuc"))
		Toast.Textstrokeshow(GameString.get("DeleFriSuc"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		deleteSysTb={}
		return
	elseif  #deleteSysTb ~= 0 and #addSysTb ~= 0 and LayerFriendList.getLayerRoot() ~= nil then
			
	end
end

--获取好友列表的长度
FriendDataCache.getLengthOfListItem_list = function()
    return #friends
end

--根据点击的位置，获取好友的整个信息（公共）,战斗力(为了翻页)，雕纹技能(单条信息)
FriendDataCache.getCurFriendInfo_list = function(index)
	local info,power,sclu = {},0,{}
	local friInfo,powerInfo,scluInfo = FriendDataCache.getFriendInfo_list()
	for key,value in pairs(friInfo) do
		if key == index then
			table.insert(info,value)
		end
	end
    for key,value in pairs(powerInfo) do
		if key == index then
			power = value
		end
	end
    for key,value in pairs(scluInfo) do
		if key == index then
			sclu = value
		end
	end
	return info,power,sclu
end

--获取当前页的信息,包括信息（公共）,战斗力(为了翻页)，雕纹技能      /???????????要改变的？？？？？？？？
FriendDataCache.getFriendInfo_list = function()
    local  	temp = {}        	--保存好友的基本信息
	local   tempPower ={}   	--保存好友的战斗力
	local  	tempSclpture={}   	--保存好友的雕纹
	for key,value in pairs(friends) do
		table.insert(temp,value)
		table.insert(tempPower,value.battle_prop.power)	
		table.insert(tempSclpture,value.battle_prop.sculpture)	
	end	
	return temp,tempPower,tempSclpture
end

--获取好友列表请求
FriendDataCache.reqGetFriends_list= function()
    local tb = req_get_friends ()
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_friend_list"])
end

NetSocket_registerHandler(NetMsgType["msg_notify_friend_list"], notify_friend_list, FriendDataCache.init_list)

-----------------------------------搜索好友的数据-------------------------------------------------------------------

local 	searchRoleInfo = {}  --搜索好友返回的角色信息
local  	searchId = {}   --保存已经发送过的好友请求的id

--搜索到的好友的信息
FriendDataCache.info_search = function()
	return searchRoleInfo
end

--搜索好友成功后，发送添加请求的判断
FriendDataCache.add_search = function(friendId)
	if  friendId ~= ModelPlayer.getId()  then  -- roleInfo.status == role_status["online"]
	    for key,value in pairs(friends) do
            if value.friend_id == friendId then
				Toast.Textstrokeshow(GameString.get("IsFriAlready"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			    return
		    end
	    end
		if  FriendDataCache.getLengthOfListItem_list() >= Friend_Max_Count  then
			Toast.Textstrokeshow(GameString.get("YouFriCountExc"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		elseif  FriendDataCache.getLengthOfListItem_list() < Friend_Max_Count  then
			if  #searchId ~= 0 then    --我不是第一次添加好友
			    for  key,value in pairs(searchId) do
					if value == friendId  then
						Toast.Textstrokeshow(GameString.get("ReqFriSendAlre"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)	
						return
					else
					    FriendDataCache.reqAddFriend_add(friendId)
						table.insert(searchId,friendId)
						return
					end
				end
			else 
				FriendDataCache.reqAddFriend_add(friendId )   --我为第一次请求
				table.insert(searchId,friendId)
			end	
		end
		
	elseif friendId == ModelPlayer.getId()  then 	
		Toast.Textstrokeshow(GameString.get("NoAddYou"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)	
	else
		for key,value in pairs(friends) do
            if value.friend_id ==  friendId then
				Toast.Textstrokeshow(GameString.get("IsFriAlready"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)	
				return
		     end
	    end   
	end
end

--根据好友id，判断该好友是否已经是自己的好友(true表示已经是好友，false表示不是自己的好友)
FriendDataCache.judgeIsMyFriend = function(id)
	for key,value in pairs(friends) do
		if value.friend_id == id then
			return true
		end
	end
	return false
end

FriendDataCache.init_search = function(resp)
	if resp.result == common_result["common_success"]  then
		searchRoleInfo  =  resp.role_info
	    LayerFriendList.setSearchUI()  
	elseif  resp.result == common_result["common_failed"]  then
		Toast.Textstrokeshow(GameString.get("NoRoleName"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	elseif resp.result == common_result["common_error"]  then
		Toast.Textstrokeshow(GameString.get("SearFriErr"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	end   
end

--根据id，删除已经同意过的id
FriendDataCache.delete_search = function(index)
	if #searchId ~= 0 then
		for key,value in pairs(searchId)  do
			if value == index  then
				table.remove(searchId,key) 
			end
		end
	end
end

FriendDataCache.reqSearchFriends_search =function(name)
    local tb = req_search_friend ()
    tb.nickname = name          
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_search_friend_result"])
end

NetSocket_registerHandler(NetMsgType["msg_notify_search_friend_result"],  notify_search_friend_result, FriendDataCache.init_search)

--------------删除好友的数据 -----------------------

FriendDataCache.init_delete = function(resp)
    if resp.result == common_result["common_success"]  then	
		if  UIManager.findLayerByTag("UI_FriendInfo") == nil then
			LayerFriendList.setUI("friendImage")
		else
			FriendInfo.delayDelAction()
		end	
	elseif  resp.result == common_result["common_failed"]  then	
		Toast.Textstrokeshow(GameString.get("DeleFriFail"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	elseif resp.result == common_result["common_error"]  then
		Toast.Textstrokeshow(GameString.get("DeleFriErr"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	end
end

--这个请求，什么时候调用呢
FriendDataCache.reqDelFriend_delete=function (id)
    local tb = req_del_friend ()
    tb.friend_id =id        
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_del_friend_result"])
	mbOwnDel = true
end

NetSocket_registerHandler(NetMsgType["msg_notify_del_friend_result"],  notify_del_friend_result, FriendDataCache.init_delete)

--------------添加好友的数据 ------------------------------

FriendDataCache.init_add = function(resp)
    if resp.result == common_result["common_success"]  then	
		Toast.Textstrokeshow(GameString.get("ReqSendSuc"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	elseif  resp.result == common_result["common_failed"]  then	
		--Toast.Textstrokeshow(GameString.get("RefuAddFri"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	elseif resp.result == common_result["common_error"]  then
		--Toast.Textstrokeshow(GameString.get("reqSendErr"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	end
end

FriendDataCache.reqAddFriend_add= function(friendId)  
	if friendId == nil then
		print("加好友时,好友id不能为空啊")
		return
	end
    local tb = req_add_friend ()
    tb.friend_id = friendId       
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_add_friend_result"])
	mbAgreeFriend = true
end

NetSocket_registerHandler(NetMsgType["msg_notify_add_friend_result"],  notify_add_friend_result, FriendDataCache.init_add)
-------------------------------------------离线后收到的请求加好友数量------------------------------------------------------------------------------------
local mOffReqAmounts = 0

--下线后，收到的好友请求的数量
local function handleOffReqsAmounts(packet)
	cclog("*********下线后，收到的好友请求的数量**********",packet.amount)
	mOffReqAmounts = packet.amount
end

--获得下线后好友请求数量
FriendDataCache.getOffReqAmounts = function()
	return  mOffReqAmounts
end

NetSocket_registerHandler(NetMsgType["msg_notify_makefriend_reqs_amount"],  notify_makefriend_reqs_amount,handleOffReqsAmounts)
---------------------------------------------------处理收到的离线好友请求的详细数据-------------------------------------------------
--下线后，收到的好友请求的信息
local 	unReadTb ={}         --保存未读消息的好友id
local 	roleInfo = {}          --是全部的未读消息的信息
local  	rolePower ={}               --保存战斗力

--请求加离线好友
FriendDataCache.reqOffMakeFriendReqs = function()
	local tb = req_get_makefriend_reqs()	
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_makefriend_reqs"])
end

--处理收到的离线好友请求
local function handleReqOffFriendReqs(packet)
	
	local reqTb = {}
	
	--过滤相同的好友id
	local function union_setTable(tb)
		local tempTb = {}
		for key,val in pairs(tb) do	
			tempTb[val.friend_id] = key
		end
		
		local newTb = {} 
		for key,val in pairs(tempTb) do						
			table.insert(newTb,tb[val])				
		end
		return newTb
	end
	
	reqTb = union_setTable(packet.reqs)
	if #reqTb ~= 0 then
		cclog("******过滤相同好友前后的离线好友个数是*******************",#packet.reqs,#reqTb)
	end
	
	for key,value in pairs(reqTb) do
		table.insert(unReadTb,value.friend_id)
		table.insert(roleInfo,value)
		table.insert(rolePower,value.battle_prop.power)
	end
	
	LayerMore.showSocialContactTip()
	LayerMain.showMoreTip()
	if LayerFriendList.getLayerRoot() ~= nil then
		LayerFriendList.setUI("addImage")		
	end
	
end

NetSocket_registerHandler(NetMsgType["msg_notify_makefriend_reqs"],  notify_makefriend_reqs, handleReqOffFriendReqs)
--------------同意添加对方为好友的数据----------------

FriendDataCache.init_process = function(resp)
    table.insert(unReadTb,resp.friend_id)
	table.insert(roleInfo,resp.role_data)
	table.insert(rolePower,resp.role_data.battle_prop.power)
	
	LayerMore.showSocialContactTip()
	LayerMain.showMoreTip()
	LayerFriendList.setUI("addImage") 
	LayerSocialContactEnter.showFriendTip(false)
end

--获得未读消息的个数
FriendDataCache.getLengthOfUnreadInfo_process = function() 
   if unReadTb ~= nil and roleInfo ~= nil then
      return # unReadTb
   elseif unReadTb == nil and roleInfo == nil  then
       return  0
   end
end

-- 删除某条数据
FriendDataCache.changeUnreadInfo_process = function(index)
	for key,value in pairs(unReadTb)  do
		if key ==index  then
			table.remove(unReadTb,key)	
		end
	end
    for key,value in pairs(roleInfo)  do
		if key ==index  then
			table.remove(roleInfo,key)	
			table.remove(rolePower,key)
		end
	end
    return unReadTb,roleInfo,rolePower
end

--获取当前页的信息,
FriendDataCache.getCurPageInfo_process = function()
    local   temp = {}                                     
	local   tempPower ={}
    for key,value in pairs(roleInfo) do                              
        table.insert(temp,value)
		table.insert(tempPower,value.battle_prop.power)
    end
	local tempId ={}
	for key,value in pairs(unReadTb) do 
        table.insert(tempId,value)
    end
   return   temp,tempId,tempPower
end

--同意或拒绝添加好友的请求
FriendDataCache.processRequest_process = function(id , answer)
    local tb = req_proc_reqfor_add_friend()
    tb. friend_id = id
    tb.answer =  answer
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_req_for_add_friend "])
end

--获取当前的item好友id
FriendDataCache.getCurFriendId_process = function (pos) 
	for k,v in pairs(unReadTb) do
		if pos == k then
			return v
		end 
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_req_for_add_friend"],  notify_req_for_add_friend, FriendDataCache.init_process)

-----------------------------------拒绝添加对方为好友-------------------------------------
FriendDataCache.init_defuse = function(resp)
	Toast.Textstrokeshow(GameString.get("RefuAddFri"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	for key ,value in pairs(searchId) do
		if resp.role_id ==value then
			table.remove(searchId,key)
		end
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_add_friend_defuse_msg"],  notify_add_friend_defuse_msg, FriendDataCache.init_defuse)
----------------发送-聊天的数据-----------------------------------------------
local  	sendMsg = nil       	--发送的信息
local 	friID = nil         	 --发送的id

FriendDataCache.init_sendChat = function(resp)
    if resp.result == common_result["common_success"]  then	
		FriendDataCache.setSendShow(friID)              --展示发送的信息
	elseif  resp.result == common_result["common_failed"]  then	
		Toast.Textstrokeshow(GameString.get("NoChatToOffline"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	elseif resp.result == common_result["common_error"]  then
		Toast.Textstrokeshow(GameString.get("SendChatErr"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	end
end

--发送聊天请求
FriendDataCache.req_sendChat = function(fId,msg)
    sendMsg = msg
	friID  = fId
    local tb = req_send_chat_msg ()
    tb.friend_id = fId                   
    tb.chat_msg = msg                     --打印64位数据的方法
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_send_chat_msg_result"])
end

NetSocket_registerHandler(NetMsgType["msg_notify_send_chat_msg_result"],  notify_send_chat_msg_result, FriendDataCache.init_sendChat)

----------------接受-聊天的数据--(在线)-----------------

local totalChatMsg ={}                --保存所有的好友的双方的聊天数据（自己发送的和接受的）
local allReceiveId = {}         		--保存所有的在线的，发来消息好友的id

--返回所有的有发送信息的好友的id
FriendDataCache.receiveTb_receive = function ()
    return allReceiveId
end

--删除某些数据（根据id）                                     
FriendDataCache.deleteTb_receive = function (id)
	mOffChatAmounts = 0
	for key,value in pairs(allReceiveId) do
		if value == id then
			table.remove(allReceiveId,key)
		end
	end
	return allReceiveId
end

--根据好友的id，去查找他的名字
FriendDataCache.findName_receiveChat = function(friendid)
	local name= nil
	for key,value in pairs(friends) do
		if value.friend_id == friendid then
			name = value.nickname             
		end	
	end
    return name
end

--展示第一次自己发送的数据,参数为：要发给谁的好友id
FriendDataCache.setSendShow= function(id)
	if  totalChatMsg[id] == nil then
		totalChatMsg[id] = {} 	
	end  
	local  temp = FriendChat.sendData()
	table.insert(totalChatMsg[id],temp)
	if  UIManager.getTopLayerName() == "UI_FriendChat"  then
	    FriendChat.showMessage(id)   --展示发送的信息
	end
end

--收到消息后的数据处理函数
FriendDataCache.init_receiveChat = function(resp)
	if #allReceiveId == 0 then
		table.insert(allReceiveId,resp.friend_id)
	else
		for key,value in pairs(allReceiveId) do
			if value ~= resp.friend_id then
				table.insert(allReceiveId,resp.friend_id)
			end
		end
	end	
	
	if  totalChatMsg[resp.friend_id] == nil then
		totalChatMsg[resp.friend_id] = {} 
	end  
	
	local temp3={}                        --保存收到的数据
	temp3.name =FriendDataCache.findName_receiveChat(resp.friend_id)
	temp3.msg = resp.chat_msg
	table.insert(totalChatMsg[resp.friend_id],temp3)
	if  UIManager.getTopLayerName() == "UI_FriendChat"  then
		 FriendChat.showMessage(resp.friend_id)
	end	
	LayerMore.showSocialContactTip()
	LayerMain.showMoreTip()
	LayerSocialContactEnter.showFriendTip(true)
	if LayerFriendList.getLayerRoot() ~= nil then 
		LayerFriendList.showChatNotice()	
	end	
end

--根据好友的id，获得当前的对话
FriendDataCache.initCurChatMsg_receiveChat = function(id)     
    local curMsg={}
	for key,value in pairs(totalChatMsg) do
		if key == id and  (#value)  <= Friend_Max_ChatMsg  then        --为了测试，改为了2，应该为10
		   curMsg = value
        elseif  key == id and  #value > Friend_Max_ChatMsg  then    --只展示其中的10条信息（太多会内存爆掉）
		    curMsg={}
			local first = #value - Friend_Max_ChatMsg + 1                --为了测试，改为了2，应该为10
			for k1,v1 in pairs (value) do
				if first<=  #value  and k1 >= first then
					table.insert(curMsg,v1)
				end
			end
	    end	
	end
    return curMsg
end

NetSocket_registerHandler(NetMsgType["msg_notify_receive_chat_msg"],  notify_receive_chat_msg, FriendDataCache.init_receiveChat)


------------------------------------------------离线接收到好友聊天信息----------------------------------------------------
local leaveChatTb = {}

--发送离线好友聊天数据请求
FriendDataCache.req_offline_chat_msg = function()
    local tb = req_msg_list()
    NetHelper.sendAndWait(tb, NetMsgType["msg_notify_msg_list"])
end

--收到消息后的数据处理函数
FriendDataCache.init_receiveOfflineChat = function(resp)
	local tb = resp.msg_list
	leaveChatTb =resp.msg_list
	
	tb = CommonFunc_InvertedTable(tb)
	--获得所有的好友聊天id
	for key,value in pairs(tb) do
		if #allReceiveId == 0 then
			table.insert(allReceiveId,value.role_id)
		else
			for k,v in pairs(allReceiveId) do
				if v ~= value.role_id then
					table.insert(allReceiveId,value.role_id)
				end
			end
		end
		if  totalChatMsg[value.role_id] == nil then
			totalChatMsg[value.role_id] = {} 
		end 
		local temp3={}                        --保存收到的数据
		temp3.name =FriendDataCache.findName_receiveChat(value.role_id)
		temp3.msg = value.msg
		table.insert(totalChatMsg[value.role_id],temp3)
	end
	cclog("离线收到的消息个数是**********************",#tb,#allReceiveId)
	if #tb > 0 then
		LayerMore.showSocialContactTip()
		LayerMain.showMoreTip()
		LayerFriendList.showChatNotice()
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_msg_list"],  notify_msg_list, FriendDataCache.init_receiveOfflineChat)
--------------------------------------------------离线收到的好友聊天个数--------------------------------------------------

--下线后，收到的好友请求的聊天数量
local function handleOffChatAmounts(packet)
	cclog("*********下线后，收到的留言数量**********",packet.count,type(packet.count))
	mOffChatAmounts = packet.count
end

--获得下线后聊天数量
FriendDataCache.getOffChatAmounts = function()
	return  tonumber(mOffChatAmounts)
end

NetSocket_registerHandler(NetMsgType["msg_notify_leave_msg_count"],  notify_leave_msg_count,handleOffChatAmounts)
--------------------------------------------------------------------------------------------------------------------
--判断是否有好友赠送的体力需要领取
local function hasHpSendByFriend()
	local friInfo = FriendDataCache.getFriendInfo_list()
	for key,value in pairs(friInfo) do
		if value.friend_send_status == send_hp_status["send_hp_done"] then
			return true
		end
	end
	return false
end

--设置是否显示好友的消息图标
FriendDataCache.setMainFlag = function()
	LayerMore.showSocialContactTip()
	LayerMain.showMoreTip()
	LayerSocialContactEnter.showFriendTip(true)
end

--更改好友界面中相应选中的按钮
FriendDataCache.setImageStrByMainFlag = function()

	if FriendDataCache.getLengthOfUnreadInfo_process() ~= 0 then
		LayerFriendList.setCurFriendStatus("addImage")
	elseif  #FriendDataCache.receiveTb_receive() ~= 0  then
		LayerFriendList.setCurFriendStatus("friendImage")	
	elseif hasHpSendByFriend()  then 	
		LayerFriendList.setCurFriendStatus("friendImage")
	elseif  FriendDataCache.getLengthOfUnreadInfo_process() ~= 0 and #FriendDataCache.receiveTb_receive() ~= 0  then 
		LayerFriendList.setCurFriendStatus("friendImage")
	elseif  FriendDataCache.getLengthOfUnreadInfo_process() == 0 and #FriendDataCache.receiveTb_receive() == 0  then 
		LayerFriendList.setCurFriendStatus("friendImage")
	else
		LayerFriendList.setCurFriendStatus("friendImage")
	end
end

--判断是否有好友消息
FriendDataCache.existTip = function()
	local flag =false
	if hasHpSendByFriend() then							--好友赠送了体力
		flag = true
	end
	if FriendDataCache.getLengthOfUnreadInfo_process() ~= 0 then	--未读消息
		flag = true
	end
	if  #FriendDataCache.receiveTb_receive() ~= 0  then	 --聊天
		flag = true
	end
	return flag
end
------------------------------------------------好友互送体力------(请求赠送)----------------------------------------------------
--请求发送好友体力
FriendDataCache.reqSendPower = function(friendId)
	local tb = req_send_hp()
	tb.friend_id = friendId
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_send_hp_result"])
end

--处理发送体力的结果
local function handleNotifySendHp(packet)
	--Log("处理发送体力的结果*****",packet)
	if packet.result == common_result["common_success"] then
		Toast.Textstrokeshow(GameString.get("Friend_Send_Hp"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		local friInfo = FriendDataCache.getFriendInfo_list()
		for key,value in pairs(friInfo) do
			if value.friend_id == packet.friend_id then
				value.my_send_status = send_hp_status["send_hp_done"]
			end
		end
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_send_hp_result"],notify_send_hp_result,handleNotifySendHp)
---------------------------------------------------在线收到好友赠送体力------------------------------------------------------------------
--处理收到好友赠送体力(注意添加tips???????????????????????)
local function handleNotifyGetHpFromFriend(packet)
	Log("handleNotifyGetHpFromFriend******",packet.friend_id)
	local friInfo = FriendDataCache.getFriendInfo_list()
	for key,value in pairs(friInfo) do
		if value.friend_id == packet.friend_id then
			value.friend_send_status = send_hp_status["send_hp_done"]
			EventCenter_post(EventDef["ED_FRIEND_LIST"])
		end
	end
end

--根据id，判断是否有好友发来赠送体力
FriendDataCache.isSendedHpById = function(friendId)
	local friInfo,powerInfo,scluInfo = FriendDataCache.getFriendInfo_list()
	for key,value in pairs(friInfo) do
		if value.friend_id == friendId and value.friend_send_status == send_hp_status["send_hp_done"] then
			return true
		end
	end
	return false
end

NetSocket_registerHandler(NetMsgType["msg_notify_get_hp_help_from_friend"],notify_get_hp_help_from_friend,handleNotifyGetHpFromFriend)
---------------------------------------------------请求领取好友赠送的体力---------------------------------------------------------
--请求领取好友赠送的体力
FriendDataCache.reqGetHp = function(friendId)
	local tb = req_reward_hp_from_friend()
	tb.friend_id = friendId
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_reward_hp_from_friend_result"])
end

local function handleGetHp(packet)
	Log("领取体力*****",packet)
	if packet.result == common_result["common_success"] then
		Toast.Textstrokeshow(GameString.get("Friend_Get_Hp",Friend_Send_HP_Num), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
		local friInfo = FriendDataCache.getFriendInfo_list()
		for key,value in pairs(friInfo) do
			if value.friend_id == packet.friend_id then
				value.friend_send_status = send_hp_status["send_hp_got"]
			end
		end
		LayerMore.showSocialContactTip()
		LayerMain.showMoreTip()					--判断社交按钮提示
		LayerSocialContactEnter.showFriendTip(true)
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_reward_hp_from_friend_result"],notify_reward_hp_from_friend_result,handleGetHp)
---------------------------------------------------------------------------------------
--判断战友的数量
FriendDataCache.getFightFriendCount = function()
	local friInfo = FriendDataCache.getFriendInfo_list()
	local index = 0
	for key,value in pairs(friInfo) do
		if value.is_comrade == 1 then
			index = index + 1
		end
	end
	return index
end

FriendDataCache.purgeInfo = function()
	friends = {}
	searchId = {}   --保存已经发送过的好友请求的id
	searchRoleInfo = {}
	totalChatMsg = {}  
	allReceiveId = {}
	leaveChatTb = {}
	mOffChatAmounts = 0
	unReadTb ={}         --保存未读消息的好友id
	roleInfo = {}        --是全部的未读消息的信息
	rolePower ={}        --保存战斗力
	
end




