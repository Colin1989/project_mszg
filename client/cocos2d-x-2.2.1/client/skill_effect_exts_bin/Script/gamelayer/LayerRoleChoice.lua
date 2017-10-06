----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-24
-- 描述：角色选择模块
----------------------------------------------------------------------
local RoleChoiceLayerRoot = nil 
local CurrRandomName = nil
--4个英雄按钮
local mThiefButton = nil 
local msoliderButton = nil 
local mshamanButton = nil
local mshushiButton = nil

local lastOnclickId = 1 -- 上次点击的ID

local function RandomName()
          local randomNumber = math.random(0,100);
          local firstName,secondName;
          local SecondNameTable = {}

          local tb1 = LogicTable.getRadomNameTable(10001)
          local tb2 = LogicTable.getRadomNameTable(10002)
          local tb3 = LogicTable.getRadomNameTable(10003)

          if(randomNumber <= tb1.probability*100) then 
            firstName = tb1.content[math.random(1,#tb1.content)]
            SecondNameTable = LogicTable.getRadomSecondNameTable(tb1.relate_id).content
            secondName = (SecondNameTable[math.random(1,#SecondNameTable)])
          elseif (randomNumber> tb1.probability*100) and (randomNumber<= (tb1.probability+tb2.probability)*100) then
            firstName =(tb2.content[math.random(1,#tb2.content)])
            SecondNameTable = LogicTable.getRadomSecondNameTable(tb2.relate_id).content
            secondName = (SecondNameTable[math.random(1,#SecondNameTable)])
          else
            firstName =(tb3.content[math.random(1,#tb3.content)])
            SecondNameTable = LogicTable.getRadomSecondNameTable(tb3.relate_id).content
            secondName = (SecondNameTable[math.random(1,#SecondNameTable)])
          end
          CurrRandomName = (firstName..secondName)
          print("RandomName:",CurrRandomName) --- 最终的随机名字
		 return CurrRandomName
end

local function Handle_req_createRoll(resp)
  print("===Handle_createRoll=== result: "..resp.result)
  --if resp.result == create_role_result["create_role_success"] then
  if resp.result == create_role_result["create_role_success"] then
        print("创建成功!!")
        UIManager.destroy("UI_RollChoice")
        UIManager.destroy("UI_Login")
        UIManager.push("UI_Main","init")
  elseif resp.result == create_role_result["create_role_nologin"] then
    
  elseif resp.result == create_role_result["create_role_typeerror"] then

  elseif resp.result == create_role_result["create_role_failed"] then
		print("创建失败!!")
  end
  
end

LayerRoleChoice = {
}

LayerAbstract:extend(LayerRoleChoice)

LayerRoleChoice.getLayerRoot= function()
  return RoleChoiceLayerRoot
end


--根据英雄id，设置界面属性
local function setHeroAttribute(id)

      --加载角色表role_tplt.xml
       local  initData=ModelPlayer.getRoleInitDetailMessageById(id)
      --获得简介、技能1，技能2
        --这个交互没打开，会出现是空的问题，其实是有值的
         local description= RoleChoiceLayerRoot:getWidgetByName("herochoose_heroinfo")
         tolua.cast(description,"UILabel")
         description:setText(initData.describe)

     --获得生命、攻击、速度
         local attribute= ModelPlayer.getPlayerInitDateByTypeAndLv(id,1)
        local hp= RoleChoiceLayerRoot:getWidgetByName("herochoose_shuxing1")
        tolua.cast(hp,"UILoadingBar")
        --注意比例的切换x/100=attribute.life/150
        hp:setPercent(attribute.life*100/150.0)

        local attack= RoleChoiceLayerRoot:getWidgetByName("herochoose_shuxing2")
        tolua.cast(attack,"UILoadingBar")
        attack:setPercent(attribute.atk*100/10.0)

        local speed= RoleChoiceLayerRoot:getWidgetByName("herochoose_shuxing3")
        tolua.cast(speed,"UILoadingBar")
        speed:setPercent(attribute.speed*100/10.0)

      --更换技能图标（有待更改，还没有数据）
	print(initData.skill1,initData.skill2,type(initData.skill1),type(initData.skill2))
	   GameSkillConfig.loadBaseInfo()
	   local  skillInfo1 = GameSkillConfig.getSkillBaseInfo( tonumber(initData.skill1))
	   local   skillInfo2 = GameSkillConfig.getSkillBaseInfo(tonumber(initData.skill2))
	if skillInfo1 ~= nil and skillInfo2 ~= nil then
	    for key,value in pairs(skillInfo1)do
		  print("获得的技能信息",key,value)
		end
	end
      if  skillInfo1~= nil and skillInfo2 ~= nil then
         local skill1=RoleChoiceLayerRoot:getWidgetByName("herochoose_skill1info")
         tolua.cast(skill1,"UILabel")
         skill1:setText(skillInfo1.description)
        --设置换行用\n
         local skill2=RoleChoiceLayerRoot:getWidgetByName("herochoose_skill2info")
         tolua.cast(skill2,"UILabel")
         skill2:setText(skillInfo2.description)
		
		
        local imageSkill1=RoleChoiceLayerRoot:getWidgetByName("herochoose_skill1")
        tolua.cast(imageSkill1,"UIImageView")
        imageSkill1:loadTexture(skillInfo1.icon_file_name)

        local imageSkill2=RoleChoiceLayerRoot:getWidgetByName("herochoose_skill2")
        tolua.cast(imageSkill2,"UIImageView")
        imageSkill2:loadTexture(skillInfo2.icon_file_name)
	 end
end

local function getButtonByIndex(index) 
	if index == 1 then 
		return mThiefButton
	elseif index == 2 then 
		return msoliderButton
	elseif index == 3 then 
		return mshamanButton
	elseif index == 4 then 
		return mshushiButton 
	end
end

LayerRoleChoice.onClick = function(weight)
	local weightName = weight:getName()
	
	if (weightName == "herochoose_namechoose") then --随机名字
		        --设置随机的名字
        local  labelName=RoleChoiceLayerRoot:getWidgetByName("herochoose_heroname")
        tolua.cast(labelName,"UITextField")
        labelName:setText( RandomName())
		return
	end
	
	if(weightName == "herochoose_sure") then
        local  labelName=RoleChoiceLayerRoot:getWidgetByName("herochoose_heroname")
        tolua.cast(labelName,"UITextField")

        local req = req_create_role()
        req.roletype = lastOnclickId		--fixme 创建角色强制为萨满
        req.nickname = labelName:getStringValue()
        print("req.nickname",req.nickname)
        NetSocket_send(req)
		return
     end
	
	local curOnclick = 0		--当前点击ID
	if(weightName == "herochoose_thief") then
        curOnclick = 1
    elseif(weightName == "herochoose_soldier") then
        curOnclick  = 2
    elseif(weightName == "herochoose_shaman") then
        curOnclick = 3
    elseif(weightName == "herochoose_shushi") then
        curOnclick=4     
    end
	if curOnclick ~= lastOnclickId then 
		getButtonByIndex(curOnclick):setVisible(false)
		getButtonByIndex(lastOnclickId):setVisible(true)
		lastOnclickId = curOnclick
		setHeroAttribute(curOnclick)
	end
end

LayerRoleChoice.init = function() 
  --注册消息
  NetSocket_registerHandler(NetMsgType["msg_notify_create_role_result"], notify_create_role_result(), Handle_req_createRoll)

  RoleChoiceLayerRoot = UIManager.findLayerByTag("UI_RollChoice")

    --获得筛子按钮
	setOnClickListenner("herochoose_namechoose")
		
	mThiefButton = RoleChoiceLayerRoot:getWidgetByName("herochoose_thief") 
	msoliderButton = RoleChoiceLayerRoot:getWidgetByName("herochoose_soldier") 
	mshamanButton = RoleChoiceLayerRoot:getWidgetByName("herochoose_shaman")
	mshushiButton = RoleChoiceLayerRoot:getWidgetByName("herochoose_shushi")
	
	setOnClickListenner("herochoose_sure")
	setOnClickListenner("herochoose_thief")
	setOnClickListenner("herochoose_soldier")
	setOnClickListenner("herochoose_shaman")
	setOnClickListenner("herochoose_shushi")

    mThiefButton:setVisible(false)

    setHeroAttribute(1)
	local  labelName=RoleChoiceLayerRoot:getWidgetByName("herochoose_heroname")
    tolua.cast(labelName,"UITextField")
    labelName:setText( RandomName())
end