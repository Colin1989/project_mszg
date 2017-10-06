
-------------------------------------
--作者：李慧琴
--说明：好友列表界面
--时间：2014-2-28
-------------------------------------

LayerFriendList = {}

local mLayerFriendListRoot = nil 

local   curPage = 1            --保存当前是第几页
local   downImage              --上翻图片
local   upImage                --下翻图片
local   friendsTb              --每页，好友列表的数据
local   addFriendsTb           -- 每页，添加好友列表的数据
local   imgStr = "friendImage"  --保存点击的是哪个按钮
local   addFriendsIdTb         --保存id ，为了同意添加对方为好友而
local   contentPanel           --底部的中间的部分
local   maxPage = 1           --保存总共是多少页
local    addFriend              --显示好友列表的图片
local    addBtn                  --添加好有的界面
local  myFriend                 --我的好友题目
local   searchPanel             --搜索的panel
--切换按钮界面 （str = imgStr）
local function setJson(str)
	contentPanel:removeAllChildren()
	if str ==  "friendImage" then
	    local  root1 = GUIReader:shareReader():widgetFromJsonFile("friendlist_1.ExportJson")
		 tolua.cast(root1,"UIWidget")
		 contentPanel:addChild(root1)
	elseif str == "addImage" then
	    local  root2 = GUIReader:shareReader():widgetFromJsonFile("friendListItem_1.ExportJson")
		tolua.cast(root2,"UIWidget")
		root2:setAnchorPoint(ccp(0,0))
		contentPanel:addChild(root2)
	end		
end

--设置按钮是否灰化显示

local function grayYN(num)
   if curPage == 1 and curPage == maxPage then
	     --print("1")
	    upImage:setTouchEnabled(false)
        upImage:loadTexture("touming.png",UI_TEX_TYPE_PLIST)     -- 灰色
        downImage:loadTexture("touming.png",UI_TEX_TYPE_PLIST)   --灰色
		downImage:setTouchEnabled(false)
   elseif curPage == maxPage then
         --print("2")
         downImage:setTouchEnabled(false)
		 downImage:loadTexture("touming.png",UI_TEX_TYPE_PLIST)   --灰色
         upImage:setTouchEnabled(true)
		  upImage:loadTexture("public_left.png",UI_TEX_TYPE_PLIST)     -- 正常
   elseif curPage < maxPage and curPage ~= 1 then
        --print("3")
           upImage:setTouchEnabled(true)
		   upImage:loadTexture("public_left.png",UI_TEX_TYPE_PLIST)     -- 正常
		   downImage:setTouchEnabled(true)
		   downImage:loadTexture("public_right.png",UI_TEX_TYPE_PLIST)   --正常
    elseif curPage < maxPage and curPage == 1 then
	      --print("4")
           upImage:setTouchEnabled(false)
		   upImage:loadTexture("touming.png",UI_TEX_TYPE_PLIST)     -- 灰色
           downImage:setTouchEnabled(true)
		   downImage:loadTexture("public_left.png",UI_TEX_TYPE_PLIST)   --正常
   end 	
end


--搜索好友按钮触发的方法
local function  searchFriend(type,widget)    
	if type =="releaseUp" then
		 local  inputText =   mLayerFriendListRoot:getChildByName("inputTextField")   --输入的角色名
         tolua.cast(inputText,"UITextField")
		if  inputText:getStringValue()== nil then
			 Toast.show("请输入好友的名字")
		elseif inputText:getStringValue()~= nil then
	        FriendDataCache.reqSearchFriends_search( inputText:getStringValue())   --先搜索，再添加
		end
	end	
end




--设置两个点击按钮，出现界面的公共信息
local function publicItem(itemBg,key,value)
	--[[
	print("设置公共的信息",key,value)
	
	for k,v in pairs(value) do
		print("设置公共信息中的值",k,v)
	end
	]]--
       local head = itemBg:getChildByName(string.format("head%d",key))               --获得头像(注意一下类型)
       tolua.cast(head,"UIImageView")
       head:loadTexture( ModelPlayer.getRoleInitDetailMessageById(value.head).heroicon)
        local  nickName = itemBg:getChildByName(string.format("nickName_%d",key))     --获得角色名
        tolua.cast(nickName,"UILabel")
        nickName:setText(value.nickname)		
        local  level = mLayerFriendListRoot:getChildByName(string.format("levellabel_%d",key))            --显示等级
        tolua.cast(level,"UILabel")
		level:setText(value.level)
       
end


--点击好友列表触发的方法
local  function  clickFriendItem(type,widget)
	
	widgetName =widget:getName()
	 local tb = {}    --保存当前点击的页数（为了获得当前页的信息）和点击的是第几个
	if type == "releaseUp"  then
	
	for key,value in pairs(friendsTb) do
	  if widgetName == string.format("Panel_list_%d",key) then
	
		 FriendDataCache.deleteTb_receive(value.friend_id)         --删除已经点击的发送消息的标志（数据）
		 table.insert(tb,key)
	     table.insert(tb,curPage)
		 UIManager.push("UI_FriendInfo",tb)
	  end
	end	
	
    end
end


--点击添加对方为好友触发的方法
local function onAddItemClick (type,widget)
	 print("onAddItemClick")
	 widgetName =widget:getName()
if type == "releaseUp" then
	for key,value in pairs(addFriendsIdTb) do
		print("点击添加对方为好友触发的方法addFriendsTb",key,value)
		if  FriendDataCache.getLengthOfListItem_list() >= 6   then
		         Toast.show("您的好友个数已经达到上线")
		end						
	  if widgetName == string.format("agreeBtn_%d",key) then    --同意添加对方为好友
		  print("判断是点击了第几个",key)
		   if  FriendDataCache.getLengthOfListItem_list() >= 6   then
		         Toast.show("您的好友个数已经达到上线")
				  FriendDataCache.changeUnreadInfo_process(key)
		           LayerFriendList.setUI(imgStr,curPage)
		  else  
		           FriendDataCache.processRequest_process(value,answer_type["agree"])   --好友id？？？？
		           FriendDataCache.changeUnreadInfo_process(key)
		           LayerFriendList.setUI(imgStr,curPage)	
		  end		
	  elseif   widgetName == string.format("refuseBtn_%d",key) then   --拒绝添加对方为好友
	       if  FriendDataCache.getLengthOfListItem_list() >= 6   then
		         Toast.show("您的好友个数已经达到上线")
				 FriendDataCache.changeUnreadInfo_process(key) 
                 LayerFriendList.setUI(imgStr,curPage)
		   else 
              FriendDataCache.processRequest_process(value,answer_type["defuse"]) 
		      FriendDataCache.changeUnreadInfo_process(key) 
			--  FriendDataCache.delete_search(key) (不是同一个客户端)
              LayerFriendList.setUI(imgStr,curPage)
		    end
	  end
	end
 end
end



local function  setItemVYN(imageType,curPage)
        
	    setJson(imageType)
	    grayYN(curPage)
    if imageType == "friendImage"  then
           friendsTb={}
		   friendsTb =  FriendDataCache.getCurPageInfo_list(curPage)
           local index  = FriendDataCache.receiveTb_receive()  --保存发送消息的好友的id
		print("保存发送消息的好友的消息id个数：",#index)
		print("此页的item个数",#friendsTb)
		if friendsTb ~= nil then
          for key,value in pairs(friendsTb) do             
           local itemBg = mLayerFriendListRoot:getChildByName(string.format("Panel_list_%d",key))   --加载每个朋友信息项
           tolua.cast(itemBg,"UILayout")
		   itemBg:setVisible(true)
             if  FriendDataCache.getOnLineNum_list(value.friend_id) == "true" then               --要不要加双引号呢
                 itemBg:setBackGroundImage("public3_friend_02.png",UI_TEX_TYPE_PLIST)            
			 else 
			    itemBg:setBackGroundImage("public3_friend_01.png",UI_TEX_TYPE_PLIST)            
             end
				for k,v in pairs(index) do
					print("遍历了k,v",k,v)
					if v ==  value.friend_id then
					print("*******2222222222222222******我要显示图标了*****************")
					 local  icons = mLayerFriendListRoot:getChildByName (string.format("notice_%d",key ))
	                  tolua.cast(icons,"UIImageView")
	                  icons:setVisible(true)
					end
				end
		
		local  power = mLayerFriendListRoot:getChildByName(string.format("power_%d",key))            --显示战斗力（有待变更）
       tolua.cast(power,"UILabel")
	   local _, poInfo = FriendDataCache.getFriendInfo_list(key,curPage)
       power:setText(poInfo)	
		   publicItem(itemBg,key,value)                            --设置各种属性
		   itemBg:registerEventScript(clickFriendItem)             --为item注册事件
          end
		end
    elseif imageType == "addImage" then	
	      addFriendsTb,addFriendsIdTb,addFriendsPower ={},{},{}
	      addFriendsTb,addFriendsIdTb,addFriendsPower  =  FriendDataCache.getCurPageInfo_process (curPage)
         local search = mLayerFriendListRoot:getChildByName("searchBtn")   --请求添加别人为好友
         tolua.cast(search,"UIButton")
         search:registerEventScript(searchFriend) 
		print("添加好友页面，item个数",#addFriendsTb)
	   if addFriendsTb ~= nil then   
        for key,value in pairs(addFriendsTb) do
          local  itemContent = contentPanel:getChildByName(string.format("Panel_add_%d",key))
          itemContent:setVisible(true)
    	local  power = mLayerFriendListRoot:getChildByName(string.format("power_%d",key))            --显示战斗力
        tolua.cast(power,"UILabel")
       power:setText(addFriendsPower[key])
		   publicItem(itemContent,key,value)  
          local agree = contentPanel:getChildByName(string.format("agreeBtn_%d",key))
          tolua.cast(agree,"UIButton")
          agree:registerEventScript(onAddItemClick)
          local refuse = contentPanel:getChildByName(string.format("refuseBtn_%d",key))
          tolua.cast(refuse,"UIButton")
          refuse:registerEventScript(onAddItemClick)  
         end
	    end
    end
end


--获取当前点击在不在好友列表界面或者是好友添加界面
LayerFriendList.getCurFriendStatus = function()
   return  imgStr
end


--设置界面 ， str = imgStr,page = curPage
LayerFriendList.setUI = function(str,page)
	 local length =  FriendDataCache.getLengthOfUnreadInfo_process ()      --(1)更改未读消息--更改好友个数(根据系统消息，已经更改)
	       print("LayerFriendList.setUI****************同意后的未读数提示：",length)
	 LayerFriendList.showUnreadInfo(length)                                 	
    local onLineNum =  mLayerFriendListRoot:getChildByName("num")          -- 设置好友人数和好友上限
    tolua.cast(onLineNum,"UILabel")
	onLineNum:setText(string.format("%d/6",FriendDataCache.getLengthOfListItem_list()))   	
	if str == "friendImage"	 then							
   	   maxPage = FriendDataCache.getLengthOfEverPage_list() 		
	          print("******LayerFriendList.setUI中******friendImage************最大的页数：",maxPage)	
    elseif str == "addImage"  then
	    maxPage =FriendDataCache.getLengthOfEverPage_process() 		
	          print("******LayerFriendList.setUI中*****addImage*************最大的页数：",maxPage)	
	end	
	 local pageNum =  mLayerFriendListRoot:getChildByName("pageNum")          --设置当前页数
     tolua.cast(pageNum,"UILabel")		
	pageNum:setText(string.format("%d/%d",curPage,maxPage))
	 setItemVYN(str,page)                                               --刷新界面	
end





local function enterAnotherUI(type,widget)
   widgetName =  widget :getName()
if type == "releaseUp" then
   if widgetName == "friendImage" then         --好友按钮
	     --设置题目
		    
			searchPanel:setEnabled(false)
			--searchPanel：setVisible(false)
			--searchPanel：setTouchEnabled(false)
			
		    myFriend:loadTexture("friends_text_09.png",UI_TEX_TYPE_PLIST)
		   
		   addFriend :loadTexture("friends_listfriend_01.png",UI_TEX_TYPE_PLIST)         --换为选中图片      
           addBtn :loadTexture("friends_add_02.png",UI_TEX_TYPE_PLIST)                
	      curPage =1
		  imgStr =  "friendImage"               --为了方便上下翻时，确定是点击了两个好友和添加中的哪一个
		 LayerFriendList.setUI(imgStr,curPage)
		-- setItemVYN(imgStr,curPage)
    elseif widgetName == "addImage" then           --添加按钮
	        searchPanel:setEnabled(true)
			searchPanel:setVisible(true)
			searchPanel:setTouchEnabled(true)
			
	        myFriend:loadTexture("friends_text_10.png",UI_TEX_TYPE_PLIST)
	       addFriend :loadTexture("friends_listfriend_02.png",UI_TEX_TYPE_PLIST)              
           addBtn :loadTexture("friends_addlight_02.png",UI_TEX_TYPE_PLIST)
	       curPage =1
		   imgStr =  "addImage" 
		LayerFriendList.setUI(imgStr,curPage)             	 
		--setItemVYN(imgStr,curPage)
    elseif widgetName == "upImiage"  then            --上翻按钮        
           curPage=curPage-1 
		LayerFriendList.setUI(imgStr,curPage)
		 -- setItemVYN(imgStr,curPage)                                        
    elseif widgetName == "downImage" then           --下翻按钮
	print("我向下翻了")
		   curPage=curPage +1 
		LayerFriendList.setUI(imgStr,curPage)
		--  setItemVYN(imgStr,curPage)
    end
end
end



--显示未读的消息个数（当有好友请求时）
LayerFriendList.showUnreadInfo = function(num)     
    local unReadNum  =  mLayerFriendListRoot:getChildByName("unreadLabel")   
    tolua.cast(unReadNum  ,"UIImageView") 
	 unReadNum:setVisible(true)
	if num == 0 then
		unReadNum:setVisible(false)
	elseif num~= 0 then
	   unReadNum:setVisible(true)
	end     	
	
end



LayerFriendList.init = function (RootView)
 
print("LayerFriendList.init ")
	mLayerFriendListRoot = RootView
   
    if FriendDataCache.getLengthOfListItem_list() == 0 then
	   print("我要请求好友列表了*************************")
       FriendDataCache.reqGetFriends_list()     --刚进入应该发送请求好友列表
    end
	
    
    addFriend =  mLayerFriendListRoot:getChildByName("friendImage")  --获得好友按钮(会换为图片，而不是btn')
    tolua.cast(addFriend,"UIImageView")
	-- addFriend :loadTexture("friends_listfriend_01.png.png",UI_TEX_TYPE_PLIST)         --换为选中图片
    addFriend:registerEventScript(enterAnotherUI)
     addBtn=  mLayerFriendListRoot:getChildByName("addImage")         --获得添加按钮
    tolua.cast(addBtn,"UIImageView")
    addBtn:registerEventScript(enterAnotherUI)   
    upImage =  mLayerFriendListRoot:getChildByName("upImiage")              --获得上翻按钮
    tolua.cast(upImage,"UIImageView")
    upImage:registerEventScript(enterAnotherUI)
    downImage =  mLayerFriendListRoot:getChildByName("downImage")           --获得下翻按钮
    tolua.cast(downImage,"UIImageView")
    downImage:registerEventScript(enterAnotherUI)
	
	contentPanel = mLayerFriendListRoot:getChildByName("Panel_51") 
	tolua.cast(contentPanel,"UILayout")
	
	 myFriend = mLayerFriendListRoot:getChildByName("ImageView_56")          --切换后的题目
     tolua.cast(myFriend,"UIImageView")
	 
	searchPanel = mLayerFriendListRoot:getChildByName("Panel_search")          --搜索panel
     tolua.cast(searchPanel,"UILayout")

	   LayerFriendList.setUI("friendImage",1)    
end












--重新刷新时，重新加载json，注意观察节点数的变化？？？？？？？？？？？？？？




--没有收到回调，就设置了界面
--差人物技能设置





--第一次请求和不是第一次的优化
--手动添加item--差动态添加横条


--[[
LayerFriendList.showUnreadChatInfo = function (id,page)
    local index  = FriendDataCache.receiveTb_receive()
	      
    local  icons = mLayerFriendListRoot:getChildByName (string.format("notice_%d",index ))
	tolua.cast(icons,"UIImageView")
	icons:setVisible(true)
end
]]--



--[[
--判断是不是点击了同样的按钮,参数为点击按钮的名字（imgStr），当前页数
local function isSame(str,curPage)
	print("进入判断是不是点击了同一个")
	local curOnclick = 0
	
	if str == "friendImage"  then
	    curOnclick = 1
		print("999curOnclick",curOnclick)
	elseif str == "addImage"  then
	      curOnclick = 2
		print("666curOnclick",curOnclick)
	end
	
	print("11",curOnClick,lastOnClickId)
	if curOnClick ~= lastOnClickId then
			print(curOnClick,lastOnClickId)
		lastOnClickId = curOnclick
		print("22","现在点击的是：这次点击的是：",str,lastOnClickId,curOnclick)
			print(curOnClick,lastOnClickId)
	elseif curOnclick == lastOnClickId then
	   	print("33",curOnClick,lastOnClickId)
	   print("***********上次和这次点击的相同******************")
	
	   return
	end
end

]]--



    --[[
    --获得滚动条(数值有待更改)？？？？？？？？？？？？？？？？？？？？？？
    local slider = mLayerFriendListRoot:getChildByName("Slider")
    tolua.cast(slider,"UISlider")
    slider:registerEventScript(enterAnotherUI)
    --获得添加好友按钮
     local addFriend = itemContent:getChildByName("addFriend")
    tolua.cast(addFriend,"UIButton")
    head:registerEventScript(enterAnotherUI)

   --设置是否在线(暂时先不做)
   local onOffLine = itemContent:getChildByName("onOffLine")
   tolua.cast(onOffLine,"UIImageView")
    --onOffLine:loadTexture("points_nopass.png") --缺少图片
   onOffLine:registerEventScript(enterAnotherUI)
     ]]--
     
	
	--[[
       local levelText = itemBg:getChildByName(string.format("levelText_%d",key))--图片旁边显示等级
        tolua.cast(levelText,"UILabel")
        levelText:setText(value.level)
		]]--
	
	
	     --local ownName =  searchPanel:getChildByName("ownName")   --自己的角色名
                     ----- tolua.cast(ownName,"UILabel")
		             ----- ownName:setText(ModelPlayer.getNickName()) 
					
					

--[[
--点击每个item触发的方法（好友界面才行啊）(先做为push，后再改为是中间一块)
local function setOnClickEvent(itemContent,key,value)
     
     
    --UIManager.push("UI_FriendInfo")  --值如何传过去呢？

end

]]--


	--[[
         searchPanel =   mLayerFriendListRoot:getChildByName("Panel_search")
		 tolua.cast(searchPanel,UILayout)
		 searchPanel:setVisible(true)
		 searchPanel:setTouchEnabled(true)   
		]]--
		
	
		     --[[
	     if  searchPanel ~= nil then
			print("把搜索隐藏掉")
			searchPanel:setVisible(false)
			searchPanel:setTouchEnabled(false)
			searchPanel:setEnabled(false)
		 end
		]]--
		
		
		
		--未读提示的更改（同意或拒绝的时候更改）
	--unReadNums = FriendDataCache.getLengthOfUnreadInfo_process()      --缺少未处理消息的个数 （缺少跳动动画）
	
	


--local  unReadNums           --保存未读取的消息的个数
--local    searchPanel         ---搜索panel
--local lastOnClickId = 0
--local  panelAdd              --添加对方为好友的中间的panel
--local    itemContent         --好友列表中间的panel
	
