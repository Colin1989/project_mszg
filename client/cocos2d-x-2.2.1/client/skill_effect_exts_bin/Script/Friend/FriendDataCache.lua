

FriendDataCache={}

--好友列表的数据

local  friends ={}           --保存好友列表返回的好友信息
local  everPageNum =  4      --每页保存的最多的item个数    --这个数值
local  maxFriend = 6         --好友上线
local  friendPower ={}        --保存好友的战斗力
local  friendSculpture ={}    --保存好友的雕纹（技能）


FriendDataCache.init_list = function(resp)
	print("FriendDataCache.init_list返回列表，好友类型（增删改查）",resp.type)
	
	if resp.type == 0 then
		  print("返回的类型为0")		
	elseif resp.type == 1 then      --初始化
	      print("返回的类型为1：初始化")
	    friends = resp.friends
		  print("初始化时好友个数：",#friends)
		 for key,value in pairs(friends) do
		 		table.insert(friendPower,value.battle_prop.power)                   --战斗力
				table.insert(friendSculpture,value.battle_prop.sculpture)            --雕纹技能
		 --测试
		--[[ print("返回列表，好友类型（初始化)",key,value)
                    for k,v in pairs(value) do
                         print("返回列表，好友类型（增删改查)2",k,v)   
                    end
				
					for k1,v1 in pairs(value.battle_prop) do
						print("battle_prop:",k1,v1)
					end
					
					print("战斗力：",value.battle_prop.power,value.battle_prop[power])
					for k2,v2 in pairs(value.battle_prop.sculpture) do
						
						print("雕纹：",k2,v2)
					end
                ]]--
        end
	elseif resp.type == 2  then     -- 追加
	      print("返回的类型为2：追加")	
		for key,value in pairs(resp.friends) do
			table.insert(friends,value)
			table.insert(friendPower,value.battle_prop.power)                   --战斗力
			table.insert(friendSculpture,value.battle_prop.sculpture)            --雕纹技能
			 --测试
			--[[
		    print("返回列表，好友类型（初始化)",key,value)
                    for k,v in pairs(value) do
                         print("返回列表，好友类型（增删改查)2",k,v)   
                    end
				
					for k1,v1 in pairs(value.battle_prop) do
						print("battle_prop:",k1,v1)
					end
					
					print("战斗力：",value.battle_prop.power,value.battle_prop[power])
					for k2,v2 in pairs(value.battle_prop.sculpture) do
						
						print("雕纹：",k2,v2)
					end
                    ]]--
		end	
		FriendDataCache.delete_search(resp.friends[1].friend_id)                      ------------------------right?????????????
		print("追加后，好友的长度：",#friends)
	elseif resp.type == 3 then      --删除
	    print("返回的类型为3：删除")
	   for key,value in pairs(friends) do
            if value.friend_id == resp.friends[1].friend_id then
				table.remove (friends,key) 
				table.remove(friendPower,key)                   --战斗力
				table.remove(friendSculpture,key)            --雕纹技能
			end
        end
		FriendDataCache.delete_search(resp.friends[1].friend_id)
		print("删除后，好友的长度：",#friends)
	elseif resp.type == 4 then      --修改
	    print("返回的类型为4：修改是否在线")
		
		for key,value in pairs(friends) do
            if value.friend_id == resp.friends[1].friend_id then
				friends[key] = resp.friends[1] 
				friendPower[key] = resp.friends[1].battle_prop.power
				friendSculpture[key] =  resp.friends[1].battle_prop.sculpture             
			end
		end	
		
		 print("修改后，好友的长度：",#friends)
	end
	 
	
	
    if (LayerMain.getCurStatus() == "mainbtn_friend") and  ( LayerFriendList.getCurFriendStatus() == "friendImage" ) then
		 print("*******我要设置好友列表界面了**  list中——friend****")
         LayerFriendList.setUI("friendImage",1)                 ------ 必须得判断为在当前的好友界面，否则会出错？？？？？？？？？？？？？？
	end
	if (LayerMain.getCurStatus() == "mainbtn_friend") and  ( LayerFriendList.getCurFriendStatus() == "addImage" ) then
		 print("*******我要设置添加列表界面了**  list中**——add**")
         LayerFriendList.setUI("addImage",1)              --------点击了添加界面，又点击好友的情况   
	end
	
end



--获取好友列表的长度
FriendDataCache.getLengthOfListItem_list = function()
      print("FriendDataCache.getLengthOfListItem_list好友列表的长度",#friends)
  if friends == nil then
	   -- print("我为0")
	    return  0
  elseif friends ~= nil then
       --print("我有好友")
	  print("获取好友长度",#friends)
        return #friends
  end 
end


--获取总共多少页
FriendDataCache.getLengthOfEverPage_list = function()
       -- print("获取总共多少页:FriendDataCache.getLengthOfEverPage_list ")
  if FriendDataCache.getLengthOfListItem_list() ~= 0 then
        --  print("FriendDataCache.getLengthOfEverPage_list分页总数：",math.ceil(FriendDataCache.getLengthOfListItem_list() / everPageNum))
     return  tonumber(math.ceil(FriendDataCache.getLengthOfListItem_list() / everPageNum))
  else  
       --  print("我没有好友，只有一页")
       return 1
  end
end



--获取当前页的信息,参数为：是第几页,包括信息（公共）,战斗力(为了翻页)，雕纹技能
FriendDataCache.getCurPageInfo_list = function(curPage)
   print("FriendDataCache.getCurPageInfo_list",curPage)
     local  temp = {}        --保存好友的基本信息
	 local   tempPower ={}   --保存好友的战斗力
	local  tempSclpture={}   --保存好友的雕纹
	
	if curPage> 0 then
       local k = (curPage-1) * everPageNum + 1
	   local maxIndex = curPage*everPageNum
		  for key,value in pairs(friends) do
			 if  key >=k  and  key <= maxIndex then
                table.insert(temp,value)
				table.insert(tempPower,value.battle_prop.power)	
				table.insert(tempSclpture,value.battle_prop.sculpture)	
			 end	
		  end
	  return   temp,tempPower,tempSclpture
	elseif curPage<=0 then
	    Toast.show("已经是第一页了")
	  return
	elseif curPage == FriendDataCache.getLengthOfEverPage_list() then
	     Toast.show("已经是最后一页了")
	   return
	end
end


--根据点击的位置，以及当前是第几页，获取好友的整个信息（公共）,战斗力(为了翻页)，雕纹技能(单条信息)
FriendDataCache.getFriendInfo_list = function(index,page)
   local info = {}
   local power =0
   local  sclu ={}
   local friInfo,powerInfo,scluInfo = FriendDataCache.getCurPageInfo_list(page)
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


--根据好友的id，获得是否在线      --和在线的好友个数
FriendDataCache.getOnLineNum_list = function(id)
   print("FriendDataCache.getOnLineNum_list")
  -- local num = 0
  local changeImage = nil                --是否更换item的背景色
   for key,value in pairs(friends) do
	--[[
	  print("FriendDataCache.getOnLineNum_list",key,value)
	  for k,v in pairs(value) do
	     print(k,v) 
	  end
	
      print("在线好友的个数：",#friends)
	]]--
       if id== value.friend_id and value.status == role_status["offline"] then   
          changeImage = "true"
       elseif  id== value.friend_id  and value.status == role_status["online"] then
          --num = num + 1
          changeImage = "false"
       end
   end

    return changeImage -- , num
end


--获取好友列表请求
FriendDataCache.reqGetFriends_list= function()
    local tb = req_get_friends ()
     NetHelper.sendAndWait(tb, NetMsgType["msg_notify_friend_list"])
end


NetSocket_registerHandler(NetMsgType["msg_notify_friend_list"], notify_friend_list (), FriendDataCache.init_list)


--搜索好友的数据--------------------------------------------------------------------

local roleInfo = {}  --搜索好友返回的角色信息(没用了)？？？？？？？？？
local  searchId = {}   --保存已经发送过的好友请求的id
FriendDataCache.init_search = function(resp)
	
		print("返回搜索好友的结果", resp.result)
	if resp.result == common_result["common_success"]  then
		 roleInfo  =  resp.role_info
       --  table.insert(roleInfo,resp.role_info)

		if resp.role_info.status == role_status["online"] and resp.role_info.friend_id ~= ModelPlayer.getId()  then 
			 for key,value in pairs(friends) do
              if value.friend_id ==   resp.role_info.friend_id then
			     Toast.show("对方已经是您的好友")  
				    return
		      end
	        end
			
			if  FriendDataCache.getLengthOfListItem_list() >= maxFriend  then
		         Toast.show("您的好友个数已经达到上线")
			elseif  FriendDataCache.getLengthOfListItem_list() < maxFriend  then
			       
				if  #searchId ~= 0 then
					print("我不是第一次添加好友")
			       for  key,value in pairs(searchId) do
					  if value == resp.role_info.friend_id  then
						  Toast.show("您的好友请求已经发送") 
						   return
					   else
					      FriendDataCache.reqAddFriend_add(resp.role_info.friend_id )
						  table.insert(searchId,resp.role_info.friend_id)
						  return
					   end
				   end
				else 
				   --print("*****************我为第一次请求*************************************")
				    FriendDataCache.reqAddFriend_add(resp.role_info.friend_id )
				   table.insert(searchId,resp.role_info.friend_id)
				end
				
			 --  FriendDataCache.reqAddFriend_add(resp.role_info.friend_id )
			end
		elseif resp.role_info.status == role_status["offline"] then
		      for key,value in pairs(friends) do
              if value.friend_id ==   resp.role_info.friend_id then
			     Toast.show("对方已经是您的好友")  
				    return
		      end
	        end
		 
		    Toast.show("该角色不在线，不能添加其为好友")       --改为通用的国际化             --判断还得改一下？？？？？？
	    elseif resp.role_info.friend_id == ModelPlayer.getId()  then 	
		     Toast.show("不能添加自己为好友")       --改为通用的国际化	
		   
		end
		
	   
	elseif  resp.result == common_result["common_failed"]  then
	      Toast.show("该角色不存在")  
	elseif resp.result == common_result["common_error"]  then
	      Toast.show("搜索好友有错误")
	end

    
end

--根据id，删除已经同意过的id
FriendDataCache.delete_search = function(index)
 -- print("************************FriendDataCache.delete_search******************************",index,#searchId)
  if #searchId ~= 0 then
     for key,value in pairs(searchId)  do
       print("index，key，search**********",index,key)
	   if value == index  then
		print("我执行了，搜索好友中的删除------------------------------------")
		   table.remove(searchId,key) 
	   end
    end
  end
end


FriendDataCache.reqSearchFriends_search =function(name)
    local tb = req_search_friend ()
    tb.nickname = name           --名字有待更改
     NetHelper.sendAndWait(tb, NetMsgType["msg_notify_search_friend_result"])
end


NetSocket_registerHandler(NetMsgType["msg_notify_search_friend_result"],  notify_search_friend_result (), FriendDataCache.init_search)



--------------删除好友的数据 -----------------------

FriendDataCache.init_delete = function(resp)
    if resp.result == common_result["common_success"]  then	
		Toast.show("删除好友成功")   ------测试后，需要删掉
		UIManager.pop("UI_FriendInfo")
	elseif  resp.result == common_result["common_failed"]  then	
	    Toast.show("删除好友失败")       --改为通用的国际化
	elseif resp.result == common_result["common_error"]  then
	    Toast.show("删除好友出错")       --改为通用的国际化
	end
end



--这个请求，什么时候调用呢
FriendDataCache.reqDelFriend_delete=function (id)
    local tb = req_del_friend ()
    tb.friend_id =id         --好友id有待更改
     NetHelper.sendAndWait(tb, NetMsgType["msg_notify_del_friend_result"])
end


NetSocket_registerHandler(NetMsgType["msg_notify_del_friend_result"],  notify_del_friend_result (), FriendDataCache.init_delete)




--------------添加好友的数据 ------------------------------

FriendDataCache.init_add = function(resp)
     if resp.result == common_result["common_success"]  then	
	      Toast.show("请求添加对方为好友已成功发送")		
	elseif  resp.result == common_result["common_failed"]  then	
	     Toast.show("请求添加对方为好友发送失败")
	elseif resp.result == common_result["common_error"]  then
	     Toast.show("请求添加对方为好友发送出错")       --改为通用的国际化
	end
end

FriendDataCache.reqAddFriend_add= function(friendId)  
	print("FriendDataCache.reqAddFriend_add",friendId)
    local tb = req_add_friend ()
    tb.friend_id = friendId       
     NetHelper.sendAndWait(tb, NetMsgType["msg_notify_add_friend_result"])
end


NetSocket_registerHandler(NetMsgType["msg_notify_add_friend_result"],  notify_add_friend_result (), FriendDataCache.init_add)


--------------同意添加对方为好友的数据----------------
local unReadTb ={}         --保存未读消息的好友id
local roleInfo = {}          --是全部的未读消息的信息
local  rolePower ={}               --保存战斗力
  local   addEveryPageNum = 4             ---- 注意这里 为四个分页（为了测试改为了1个）-----------
FriendDataCache.init_process = function(resp)
	 print("同意添加对方为好友的好友id", resp.friend_id)
     table.insert(unReadTb,resp.friend_id)
	 table.insert(roleInfo,resp.role_data)
	 table.insert(rolePower,resp.role_data.battle_prop.power)
	
	
	  print("roleInfo的个数，rolePower的个数",#roleInfo,#rolePower)
		--测试
     for key,value in pairs(roleInfo)  do
        print("同意添加对方为好友的信息：",key,value)  
		for k,v in pairs(value) do
			print("同意测试：",k,v)
		end
     end 
	 
	 for k,v in pairs(resp.role_data) do
			print("同意：",k,v)
			
	 end
	
	
	LayerMain.showUnreadInfo("true")
	if (LayerMain.getCurStatus() == "mainbtn_friend") and  ( LayerFriendList.getCurFriendStatus() == "addImage" ) then
		  print("*******我要设置添加好友界面了*** 同一添加对方为好友中***")
         LayerFriendList.setUI("addImage",1)                 ------ 必须得判断为在当前的好友界面，否则会出错？？？？？？？？？？？？？？
	end
	if (LayerMain.getCurStatus() == "mainbtn_friend") and  ( LayerFriendList.getCurFriendStatus() == "friendImage" ) then
		  print("*******我要设置添加好友界面了*** 同一添加对方为好友中**好友界面*")
         LayerFriendList.setUI("friendImage",1)                 ------ 为了显示未读的数目
	end
	
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





--获取总共多少页
FriendDataCache.getLengthOfEverPage_process = function()
  if  FriendDataCache.getLengthOfUnreadInfo_process() ~= 0 then
             print("getLengthOfEverPage_process分页总数：",math.ceil(FriendDataCache.getLengthOfUnreadInfo_process()/ addEveryPageNum))
       return  math.ceil(FriendDataCache.getLengthOfUnreadInfo_process()/ addEveryPageNum)
  else
          return 1
   end

end


--获取当前页的信息,参数为：是第几页
FriendDataCache.getCurPageInfo_process = function(curPage)
 print("FriendDataCache.getCurPageInfo_process",curPage)
   

     local  temp = {}                                     
	 local   tempPower ={}
     local  index = (curPage-1) * addEveryPageNum + 1     --新的一页数据，表示从第几个开始
	 local  maxIndex = curPage*addEveryPageNum             --表示到第几个结束
	print("index，getCurPageInfo_process",index)
	print("此时，roleInfo的个数：",#roleInfo)
	
     for key,value in pairs(roleInfo) do                         
		print("FriendDataCache.getCurPageInfo_process:",key,value)
        if key>= index  and key <=maxIndex  then           
			print("为当前页的信息赋值")
           table.insert(temp,value)
		print("为战斗力赋值：",value.battle_prop.power)
		   table.insert(tempPower,value.battle_prop.power)
        end
     end
	
	local tempId ={}
	for key,value in pairs(unReadTb) do
	    if  key>= index  and key <=maxIndex then        
			print("为当前页的信息赋值id")
           table.insert(tempId,value)
        end
	end
	print("FriendDataCache.getCurPageInfo_process各个的个数：",#temp,#tempId,#tempPower)
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
			print ("v",v )
			return v
		end 
	end
end

NetSocket_registerHandler(NetMsgType["msg_notify_req_for_add_friend"],  notify_req_for_add_friend (), FriendDataCache.init_process)

----------------发送-聊天的数据-----------------------------------------------
local  sendMsg = nil       --发送的信息
local friID = nil          --发送的id

FriendDataCache.init_sendChat = function(resp)
    if resp.result == common_result["common_success"]  then	
		--Toast.show("发送聊天数据成功")   ------测试后，需要删掉
		FriendDataCache.setSendShow(friID)              --展示发送的信息
	elseif  resp.result == common_result["common_failed"]  then	
	    Toast.show("请输入要发送的内容,发送聊天数据失败")       --改为通用的国际化
	elseif resp.result == common_result["common_error"]  then
	    Toast.show("发送聊天数据出错")       --改为通用的国际化
	end
end



--发送聊天请求
FriendDataCache.req_sendChat = function(fId,msg)
 print("请求聊天前后的FriendDataCache.req_sendChat",fId,msg)
     sendMsg = msg
	 friID   = fId
    local tb = req_send_chat_msg ()
    tb.friend_id = fId                   
    tb.chat_msg = msg                     --打印64位数据的方法	--string.print_int64("id",id) 
     NetHelper.sendAndWait(tb, NetMsgType["msg_notify_send_chat_msg_result"])
end



NetSocket_registerHandler(NetMsgType["msg_notify_send_chat_msg_result"],  notify_send_chat_msg_result (), FriendDataCache.init_sendChat)




----------------接受-聊天的数据-------------------

local totalChatMsg ={}                --保存所有的好友的双方的聊天数据（自己发送的和接受的）

local  allReceiveId ={}           --保存所有的在线的，发来消息好友的id



--返回所有的有发送信息的好友的id
FriendDataCache.receiveTb_receive = function ()
print("*******************************************************") --------------缺一个，剔除相同的数据？？？？？？？
   local temp = allReceiveId
    for key,value in pairs (temp) do
	   print("我保存，所有的有发送信息的好友的id:个数为：",key,value,#temp)
	end
    return temp
end



--删除某些数据（根据id）                                     
FriendDataCache.deleteTb_receive = function (id)
   print("FriendDataCache.deleteTb_receive",id)
   local temp =  allReceiveId
   for key,value in pairs(temp) do
	  if value == id then
		 table.remove(temp,key)
	  end
	end
	print("***********************删除某条信息后，我的未读消息个数是***********************：",#temp)
	return temp
end

--根据好友的id，去查找他的名字
FriendDataCache.findName_receiveChat = function(friendid)
  local name= nil
    for key,value in pairs(friends) do
	  if value.friend_id == friendid then
		 name = value.nickname              --根据好友的id，去查找他的名字
	  end	
   end
    return name
end


--我为所有的好友创建了空表
FriendDataCache.initGlobleDate_sendChat = function  ()
    print("FriendDataCache.initGlobleDate_sendChat")
    for key,value in pairs(friends) do
		  --print("我创建")
	   totalChatMsg[value.friend_id] = {} 	  --我为所有的好友创建了空表
	 -- print("我创建后的个数：",#totalChatMsg)
    end
end



--展示第一次自己发送的数据,参数为：要发给谁的好友id
FriendDataCache.setSendShow= function(id)
    print("**********************FriendDataCache.setSendShow",id)
		if  totalChatMsg[id] == nil then
			print("我首次创建")
		     totalChatMsg[id] = {} 
			local  temp = FriendChat.sendData ()
            table.insert(totalChatMsg[id],temp)
			print("发送，创建后的个数", #totalChatMsg[id])
			
			 print("----------------------此时，正在运行的层是",UIManager.getRunLayer(),UIManager.getTopLayerName())
			 if  UIManager.getTopLayerName() == "UI_FriendChat"  then
	             FriendChat.showMessage(id)
			 end
		else
		    print("我已经创建过了1111111111")
			print("此时的id：",id)
		    local  temp = FriendChat.sendData ()
            table.insert(totalChatMsg[id],temp)
          
		   print("-----------------此时，正在运行的层是",UIManager.getRunLayer(),UIManager.getTopLayerName())
		    if  UIManager.getTopLayerName() == "UI_FriendChat"  then
			      print("此时不在聊天的界面，我怎么不显示呢？？？？？？")
			    FriendChat.showMessage(id)   --展示发送的信息
			end
	
		end                                       
end



--收到消息后的数据处理函数
FriendDataCache.init_receiveChat = function(resp)
      print("FriendDataCache.init_receiveChat")
	
	 table.insert(allReceiveId,resp.friend_id)
	
	--[[
	for key,value in pairs(allReceiveId)do
		print("我遍历了表id")
		if value ~= resp.friend_id then
			print("我要为你插入信息了***********************")
	       table.insert(allReceiveId,resp.friend_id)
	    end
	end
	]]--
	
		if  totalChatMsg[resp.friend_id] == nil then
			print("我首次创建")
		     totalChatMsg[resp.friend_id] = {} 
			local temp3={}                        --保存收到的数据
		    temp3.name =FriendDataCache.findName_receiveChat(resp.friend_id)
		    temp3.msg = resp.chat_msg
            table.insert(totalChatMsg[resp.friend_id],temp3)
			print("返回创建后的个数：",#totalChatMsg[resp.friend_id])
	
			  print("-------------------------------此时，正在运行的层是",UIManager.getRunLayer(),UIManager.getTopLayerName())
			
			 if  UIManager.getTopLayerName() == "UI_FriendChat"  then
			      print("此时不在聊天的界面，我怎么不显示呢？？？？？？")
			    FriendChat.showMessage(resp.friend_id)
			end

		else
			  print("返回的信息id：",resp.friend_id)
		   	local temp3={}                        --保存收到的数据
		    temp3.name =FriendDataCache.findName_receiveChat(resp.friend_id)
		    temp3.msg = resp.chat_msg
            table.insert(totalChatMsg[resp.friend_id],temp3)
			 print("--------------------------------------此时，正在运行的层是",UIManager.getRunLayer(),UIManager.getTopLayerName())
			 

			 if  UIManager.getTopLayerName() == "UI_FriendChat"  then
			      print("此时不在聊天的界面，我怎么不显示呢？？？？？？")
			    FriendChat.showMessage(resp.friend_id)
			end
			
		end
      
   	 LayerMain.showUnreadInfo("true")
	
	if (LayerMain.getCurStatus() == "mainbtn_friend") and  ( LayerFriendList.getCurFriendStatus() == "friendImage" ) then
		  print("*******我要设置添加好友列表界面了（聊天）******")
         LayerFriendList.setUI("friendImage",1)                 
	end
    

	--测试 
	for key,value in pairs(totalChatMsg) do
		print("便利所有消息中的表",key,value)
		for k,v in pairs(value) do			
			print("便利表中的数据：",k,v)
			for k1,v1  in pairs(v) do
				print("遍历出了名字和消息：",k1,v1)
			end
		end	
	end          
end


--根据好友的id，获得当前的对话
 FriendDataCache.initCurChatMsg_receiveChat = function(id)                   
    local curMsg={}
   for key,value in pairs(totalChatMsg) do
	  print("找到当前对话的数据：",key,value)
	--[[
	   for k1,v1 in pairs (value) do
		  print("当前内容：",k1,v1)
	  end
	]]--
	print("谈话的个数：",#value)
	   if key == id and  (#value)  <= 10  then        --为了测试，改为了2，应该为10
		  --print("我要取我的id的数据")
		   curMsg = value
        elseif  key == id and  #value >10  then    --只展示其中的10条信息（太多会内存爆掉）
		    curMsg={}
		 print("进入10判断了")
		local first = #value - 10 + 1                --为了测试，改为了2，应该为10
		print("我从几开始：",first) 
		   for k1,v1 in pairs (value) do
			 if first<=  #value  and k1 >= first then
			     table.insert(curMsg,v1)
		         print("判断10条内容：",k1,v1)
			 end
	       end
	    end	
	end
    return curMsg
	
end

NetSocket_registerHandler(NetMsgType["msg_notify_receive_chat_msg"],  notify_receive_chat_msg (), FriendDataCache.init_receiveChat)







-----print("为他赋值333：",friID) 这个值为空
--local otherTotalChatMsg = {}          --保存所有的好友的双方的聊天数据（别人发送的和接受的）
--根据好友的id和第几页，判断是当前页中数据的第几个

--根据好友的id，判断是第几页的第几个
--[[
FriendDataCache.getIndex = function(id,num)

   local key
   local temp = FriendDataCache.getCurPageInfo_list (num)
   for key,value in pairs(temp) do
	 if value.friend_id == id then
		  return key
	 end
   end
end
]]--
