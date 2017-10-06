
-------------------------------------
--作者：李慧琴
--说明：战斗结算界面
--时间：2014-1-23
-------------------------------------

LayerFightOver = {
}

local  starsNumber = 0

local mLayerFightOverRoot = nil      --当前界面的根节点
local  passInfo = nil                --保存传递的信息
LayerAbstract:extend(LayerFightOver)

LayerFightOver.onClick = function(widget)
    local widgetName = widget:getName()
    if "Button_38" == widgetName then  -- 确认键
          
        if starsNumber ~= 3  then
			 local boolYN = LayerTempBackpack.IsPushLayer()
            if boolYN == false then
			   UIManager.pop("UI_FightOver")
               UIManager.retrunMainLayer("fightOver")
			 elseif  boolYN == true then
		        UIManager.pop("UI_FightOver")
                 UIManager.push("UI_TempPack")
             end
         
        elseif  starsNumber== 3 then
             print("我有三颗星")
       
              UIManager.pop("UI_FightOver")
              UIManager.push("UI_FightReward",passInfo)  -- 进入奖励界面
            

        end

       --  UIManager.push("UI_FightReward",passInfo)  -- 进入奖励界面   ----------记得改回来？？？？？？？？？？？？？？？？

     end
end


function  changeStars(starsNumber)      --设置显示几颗星
    local darkStar1= mLayerFightOverRoot:getWidgetByName("ImageView_29")
    local yellowStar1= mLayerFightOverRoot:getWidgetByName("ImageView_huang")
    local darkStar2= mLayerFightOverRoot:getWidgetByName("ImageView_30")
    local yellowStar2= mLayerFightOverRoot:getWidgetByName("ImageView_huang2")
    local darkStar3= mLayerFightOverRoot:getWidgetByName("ImageView_31")
    local yellowStar3= mLayerFightOverRoot:getWidgetByName("ImageView_huang3")
   if starsNumber == 1  then
        darkStar1:setVisible(false)
        yellowStar1:setVisible(true)
   elseif starsNumber == 2 then
        darkStar1:setVisible(false)
        yellowStar1:setVisible(true)
        darkStar2:setVisible(false)
        yellowStar2:setVisible(true)
    elseif starsNumber == 3 then
        darkStar1:setVisible(false)
        yellowStar1:setVisible(true)
        darkStar2:setVisible(false)
        yellowStar2:setVisible(true)
        darkStar3:setVisible(false)
        yellowStar3:setVisible(true)
    elseif starsNumber == 0 then

    end
end


local  collectNumber = 2     --保存收集到的物品个数

local function setItemIcon(pickItemTable)	
	local tb={}      --保存相同的物品的id和个数
    local items = LogicTable.getAllItems()
	 for key,value in pairs(items) do

            local temp = {}
			local num = 0
		 for k,v in pairs(pickItemTable) do
		     if tostring(value.id) == tostring(v) then
			    temp.id = v
				num = num +1 
				temp.num =num   
			 end	
		 end 	
		if temp.id ~= nil and temp.num ~= nil then	
		  table.insert(tb,temp)   
		 end
    end 
	
	print("tb的个数：",#tb)
	if #tb ~= 0 then
	for key,value in pairs(tb) do
		print("插入物品表的id：",value.id)
	 	local q = LogicTable.getItemById(value.id)
	    local pzResfile = CommonFunc_GetQualityPath(tonumber(q.quality))
		--品质
		local ViewName = string.format("item%d",key)
		local pzBg= mLayerFightOverRoot:getWidgetByName(ViewName)
		 tolua.cast(pzBg,"UIImageView")
		pzBg:loadTexture(pzResfile)
		--图片
		local ImageViewName = string.format("pz%d",key)
		local itemPic= mLayerFightOverRoot:getWidgetByName(ImageViewName)
		tolua.cast(itemPic,"UIImageView")
		itemPic:loadTexture("Icon/"..q.icon)
		--个数
		local numName =string.format("stk%d",key)
		local num = mLayerFightOverRoot:getWidgetByName(numName)
		num:setVisible(true)
		tolua.cast(num,"UILabel")
        print("个数：",value.num)
		if tonumber(value.num) <10 then
		  num:setText(string.format("X0%d",value.num))
		elseif tonumber(value.num) >=10 then
		   num:setText(string.format("X%d",value.num))
		end	
        num:setColor(ccc3(175,20,255))
		
	end
	end
	
end

LayerFightOver.init = function(bundle)
      passInfo = bundle
      starsNumber = bundle.score

    mLayerFightOverRoot=UIManager.findLayerByTag("UI_FightOver")
    setOnClickListenner("Button_38")
    changeStars(bundle.score)    --改变星星的数量，（值由服务器给出）
	setItemIcon(bundle.Pickup_items)
	for key,value in pairs(bundle.Pickup_items) do
	   print("********************服务端返回的物品信息*********：",key,value)
	end
    --layoutCollections()
    local  copyNameLabel= mLayerFightOverRoot:getWidgetByName("Label_28")  --显示战斗的副本名字
    tolua.cast(copyNameLabel,"UILabel")
    copyNameLabel:setText(bundle.name)
    local coinLabel= mLayerFightOverRoot:getWidgetByName("Label_35")       --获得的金币
    tolua.cast(coinLabel,"UILabel")
    coinLabel:setText(bundle.gold)
    local expLabel= mLayerFightOverRoot:getWidgetByName("Label_37")        --获得的经验
    tolua.cast(expLabel,"UILabel")
    expLabel:setText(bundle.exp)

end

