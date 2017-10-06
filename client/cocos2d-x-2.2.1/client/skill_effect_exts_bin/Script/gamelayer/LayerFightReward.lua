
-------------------------------------
--作者：李慧琴
--说明：战斗奖励界面
--时间：2014-1-23
-------------------------------------
LayerFightReward = {
}
local mLayerFightRewardRoot = nil
local  reward1Bg  = nil                     -- 奖励一背景
local reward2Bg   = nil                     -- 奖励二背景
local reward3Bg   = nil                     -- 奖励三背景
local responseInfo  = nil                   --保存传递过来的信息
local curOnclick = 0		               --当前点击ID
local  sureBtn                             --确定按钮
LayerAbstract:extend(LayerFightReward)

LayerFightReward.onClick = function(widget)
   local widgetName = widget:getName()
    if "Button_33" == widgetName then  -- 确认键
		sureBtn:setEnabled(true)
         local boolYN = LayerTempBackpack.IsPushLayer()
         if boolYN == false then			 
              UIManager.retrunMainLayer("fightOver")
	     elseif  boolYN == true then
		     UIManager.pop("UI_FightReward")
             UIManager.push("UI_TempPack")
         end
    end
end


local function getButtonByIndex(index) 
	if index == 1 then 
		return reward1Bg
	elseif index == 2 then 
		return reward2Bg
	elseif index == 3 then 
		return reward3Bg 
	end
end


--翻牌效果回调函数(刚显示时的翻转)
local function  objectResetCallBack(sender)
        print("***************我加载背景框了**********")
	    reward1Bg:loadTexture("fightreward_item_back.png",UI_TEX_TYPE_PLIST)
		reward2Bg:loadTexture("fightreward_item_back.png",UI_TEX_TYPE_PLIST)
        reward3Bg:loadTexture("fightreward_item_back.png",UI_TEX_TYPE_PLIST)
end

--[[
local function setBackground()
	print("返回的信息的个数：",#responseInfo.ratio_items)
	 for key,value in pairs(responseInfo.ratio_items) do
         print("*********测试:************服务端返回的战斗奖励信息:key,value:",key,value)
	    local   itemInfo =  LogicTable.getItemById(value)  --通过奖励的物品列表，获得物品的信息
	    local   strPath =  CommonFunc_GetQualityPath(tonumber(itemInfo.quality)) --找到品质框的图片路径
		rewardBg =  mLayerFightRewardRoot:getWidgetByName(string.format("ImageView_%d",62+key))  
        tolua.cast(rewardBg,"UIImageView")
		
		if rewardBg ~= nil then
	      rewardBg:loadTexture(strPath)
	    end
		
		itemBg = mLayerFightRewardRoot:getWidgetByName(string.format("ImageView_%d",66+key))  
	    tolua.cast(itemBg,"UIImageView")
		 if itemBg ~= nil then
	        itemBg:loadTexture("Icon/"..itemInfo.icon)	
		 end	
    end	
	reward1Bg:runAction(turnBack(objectResetCallBack))
	reward2Bg:runAction(turnBack(objectResetCallBack))
	reward3Bg:runAction(turnBack(objectResetCallBack))
end
]]--

--获得最终要显示的id是信息的第几个
local  function  searchIndex ()
   
	for key,value in pairs(responseInfo.ratio_items) do
		if value == responseInfo.final_item then
			print("获得最终要显示的id是信息的第几个",key)
			 return  key  
		end		
	end	
end

--为返回的信息，重新排序(根据点击的位置)
local   function  changeTb (curOnclick)
	 --print("^^^^^^^^^^^^^^^^^^changeTb",curOnclick)
	local  tempResponseInfo ={}
	local  index = searchIndex()     --获得最终要显示的id是信息的第几个
	if curOnclick == index then
		 tempResponseInfo = responseInfo.ratio_items
	else 
	--  print("我要重新赋值了")
	    for key,value in pairs(responseInfo.ratio_items) do
			if curOnclick == key then
			--	print("为点击的赋值")
			   tempResponseInfo[key] =  responseInfo.final_item
			elseif key == index then
			  --  print("为最终物品的原始位置赋值")
				--print(responseInfo.ratio_items[index])
			   tempResponseInfo[key] =  responseInfo.ratio_items[curOnclick]
			else
			  --  print("为没变的赋值")
			   tempResponseInfo[key] =  responseInfo.ratio_items[key]
			end
	    end	
		
	end
	  --测试
	--[[
	for key,value in pairs(tempResponseInfo) do
		print("变化后的，表中的信息为：",key,value)
		
	end
	]]--
	
	 return  tempResponseInfo
end



local function  clickCallBack (sender)	
	
	  local   itemInfo =  LogicTable.getItemById(responseInfo.final_item)  --通过奖励的物品列表，获得物品的信息
	  local   strPath =  CommonFunc_GetQualityPath(tonumber(itemInfo.quality)) --找到品质框的图片路径  	
	  --  print("被点击的图片的路径：",strPath)
	 local itemBg = nil
    if curOnclick==1 then	 
	    reward1Bg:loadTexture(strPath)     --这里换为各自奖励的背景框
	  	itemBg = mLayerFightRewardRoot:getWidgetByName("ImageView_67")    
    elseif curOnclick==2 then
       reward2Bg:loadTexture(strPath)
       itemBg = mLayerFightRewardRoot:getWidgetByName("ImageView_68") 
    elseif curOnclick==3 then
       reward3Bg:loadTexture(strPath)
       itemBg = mLayerFightRewardRoot:getWidgetByName("ImageView_69") 
   end
	tolua.cast(itemBg,"UIImageView")
	if itemBg ~= nil then
	    itemBg:loadTexture("Icon/"..itemInfo.icon)	
		--print("************被点击的图片的路径：",itemInfo.icon)
    end
end

--没有点击的图片的回调函数
local function NoClickCallBack(sender)	
	local  tempResponseInfo = changeTb(curOnclick)
    for key,value in pairs(tempResponseInfo) do
	    local   itemInfo =  LogicTable.getItemById(value)  --通过奖励的物品列表，获得物品的信息
	    local   strPath =  CommonFunc_GetQualityPath(tonumber(itemInfo.quality)) --找到品质框的图片路径
		
		if key ~=curOnclick then
		   rewardBg =  mLayerFightRewardRoot:getWidgetByName(string.format("ImageView_%d",62+key))    --背景框
           tolua.cast(rewardBg,"UIImageView")
           if rewardBg ~= nil then
	         rewardBg:loadTexture(strPath)
           end

		   print("没有点击的图片，加载路径：背景框：",strPath)
		   itemBg = mLayerFightRewardRoot:getWidgetByName(string.format("ImageView_%d",66+key))        --背景
	       tolua.cast(itemBg,"UIImageView")
           if itemBg ~= nil then
	         itemBg:loadTexture("Icon/"..itemInfo.icon)
           end
		   print("图片：",itemInfo.icon)
	    end		
    end	
end

--CCOrbitCamera * CCOrbitCamera::create(float t, float radius, float deltaRadius, float angleZ, float deltaAngleZ, float angleX, float deltaAngleX)
--参数分别为旋转的时间，起始半径，半径差，起始z角，旋转z角差，起始x角，旋转x角差



--翻牌效果

function  turnBack(callBackFunc)
    local orbit1=CCOrbitCamera:create(0.3,1,0,0,90,0,0)
    local callBack=CCCallFuncN:create(callBackFunc)
    local orbit2=CCOrbitCamera:create(0.3,1,0,270,90,0,0)

    local array=CCArray:createWithCapacity(10)
    array:addObject(orbit1)
    array:addObject(callBack)
    array:addObject(orbit2)
    local action = CCSequence:create(array)
   return action
end


local function turnDelayBack()
	 local delay = CCDelayTime: create(0.5)
	 local orbit1=CCOrbitCamera:create(0.3,1,0,0,90,0,0)
    local callBack=CCCallFuncN:create(NoClickCallBack)
    local orbit2=CCOrbitCamera:create(0.3,1,0,270,90,0,0)
	 
	 local array=CCArray:createWithCapacity(10)
	array:addObject(delay)
    array:addObject(orbit1)
    array:addObject(callBack)
    array:addObject(orbit2)
    local action = CCSequence:create(array)
   return action

end
local function btnCallBack()
	  sureBtn:setEnabled(true)
	  sureBtn:setVisible(true)
end

local function delayAction(index)
--	local action = CCSequence:createWithTwoActions(CCDelayTime:create(3.0),turnBack(NoClickCallBack))
	if index == 1 then 
		print("我延迟调用了")
		 reward2Bg:runAction(turnDelayBack())
		 reward3Bg:runAction(turnDelayBack())
		
	elseif index == 2 then 
		 reward1Bg:runAction(turnDelayBack())
		 reward3Bg:runAction(turnDelayBack())
	elseif index == 3 then 
		reward1Bg:runAction(turnDelayBack())
		reward2Bg:runAction(turnDelayBack())
	end
	reward1Bg:setTouchEnabled(false)
	reward2Bg:setTouchEnabled(false)
	reward3Bg:setTouchEnabled(false)
	sureBtn = mLayerFightRewardRoot:getWidgetByName("Button_33")   -- 奖励一背景
    tolua.cast(sureBtn,"UIButton")
	local action = CCSequence:createWithTwoActions(CCDelayTime:create(1.0),CCCallFuncN:create(btnCallBack))
	sureBtn:runAction(action)
	
end



local function clicks(type,widget)
   local widgetName = widget:getName()  	
  if type == "releaseUp" then
        if "ImageView_63" == widgetName then  -- 奖励一
                  print("奖励一:只能抽奖一次")
				curOnclick = 1
         elseif "ImageView_64" == widgetName then  -- 奖励二
                print("奖励二:只能抽奖一次")
			    curOnclick  = 2
         elseif "ImageView_65" == widgetName then  -- 奖励三
                   print("奖励三:只能抽奖一次")
				curOnclick = 3
         end
		 getButtonByIndex(curOnclick):runAction(turnBack(clickCallBack))
         getButtonByIndex(curOnclick):setTouchEnabled(false)
		 delayAction(curOnclick)
		
	end


end


LayerFightReward.init = function(bundle)
     mLayerFightRewardRoot=UIManager.findLayerByTag("UI_FightReward")
     responseInfo = bundle
    --测试
    for key,value in pairs(bundle) do
       print("key,value",key,value)
    end
     print("最终要显示的物品id:",bundle.final_item)
     sureBtn = mLayerFightRewardRoot:getWidgetByName("Button_33")   -- 确认
     tolua.cast(sureBtn,"UIButton")
	sureBtn:setEnabled(false)
     setOnClickListenner("Button_33")  -- 确认键(如果字可以交互的话，按钮有部分就点不到了)
      reward1Bg= mLayerFightRewardRoot:getWidgetByName("ImageView_63")   -- 奖励一背景
      tolua.cast(reward1Bg,"UIImageView")
      reward1Bg:registerEventScript(clicks)
      reward2Bg= mLayerFightRewardRoot:getWidgetByName("ImageView_64")   -- 奖励二背景
      tolua.cast(reward2Bg,"UIImageView")
      reward2Bg:registerEventScript(clicks)
      reward3Bg= mLayerFightRewardRoot:getWidgetByName("ImageView_65")    -- 奖励三背景
      tolua.cast(reward3Bg,"UIImageView")
      reward3Bg:registerEventScript(clicks)	  
	 -- setBackground()
      objectResetCallBack()
end







  
