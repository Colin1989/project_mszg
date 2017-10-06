----------------------------------------------------------------------
-- 作者：shenl
-- 日期：2013-12-24
-- 描述：角色选择模块
----------------------------------------------------------------------
local RoleChoiceLayerRoot = nil 
local CurrRandomName = nil

local mEditorBoxName		--验证码输入框
--[[
local mCheckFlag = 2		--表示验证码是否正确
local mCode					--输入的验证码
]]--
local 	lastOnclickId = 1 -- 上次点击的ID

local 	 mRoleBackData = {} --pos ,z,scale
local 	 emun_SelectRole = 2 -- 1~4
local 	 mRoleWidget = {} --widget,index
local 	 sureButton		--就是你了按钮

LayerRoleChoice = {
}

local mCircleParticle = nil

LayerAbstract:extend(LayerRoleChoice)

--预先加载32图
function LayerRoleChoice.loadResource()
	local textureCache = CCTextureCache:sharedTextureCache()
	--textureCache:addImage("herochoose_bg_2.png")
end

function LayerRoleChoice.onExit()
	mCircleParticle = nil
end

--备份之前选择角色序号 1，2，3，4
local mSelectIndexBack = 1

math.randomseed(os.clock())

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
	--cclog("RandomName:",CurrRandomName) --- 最终的随机名字
	return CurrRandomName
end

LayerRoleChoice.getLayerRoot= function()
  return RoleChoiceLayerRoot
end

--查看两个信息的详细信息
local function clickImgInfo(widget)
	local position,direct = CommonFuncJudgeInfoPosition(widget)
	local tb = SkillConfig.getSkillBaseInfo(widget:getTag())
	tb.position = position
	tb.direct = direct
	UIManager.push("UI_JobInfo",tb)
end
-- 长按点击回调(职业特长)
local function longClickCallback_job()
	UIManager.pop("UI_JobInfo")
end

--根据英雄id，设置界面属性
local function setHeroAttribute(id)
	lastOnclickId = id
	--加载角色表role_tplt.xml
	local  initData = ModelPlayer.getRoleRow(id)
	--获得简介、技能1，技能2
	local description= RoleChoiceLayerRoot:getWidgetByName("herochoose_heroinfo")
	tolua.cast(description,"UILabel")
	description:setText(initData.describe)
	--角色属性
	--获得生命、攻击、速度
	local attribute= ModelPlayer.getRoleUpgradeRow(id,1)
	local hp= RoleChoiceLayerRoot:getWidgetByName("LoadingBar_357")
	tolua.cast(hp,"UILoadingBar")
	--注意比例的切换x/100=attribute.life/150
	hp:setPercent(attribute.life*100/300.0)

	local attack= RoleChoiceLayerRoot:getWidgetByName("LoadingBar_358")
	tolua.cast(attack,"UILoadingBar")
	attack:setPercent(attribute.atk*100/25.0)

	-- local speed= RoleChoiceLayerRoot:getWidgetByName("LoadingBar_359")
	-- tolua.cast(speed,"UILoadingBar")
	-- speed:setPercent(attribute.speed*100/100.0)
			
    --更换技能图标
	local skillInfo1 = SkillConfig.getSkillBaseInfo(tonumber(initData.skill1))
	local skillInfo2 = SkillConfig.getSkillBaseInfo(tonumber(initData.skill2))
	--Log(skillInfo1)
	--Log(skillInfo2)
    if skillInfo1~= nil and skillInfo2 ~= nil then
		local skill1=RoleChoiceLayerRoot:getWidgetByName("herochoose_skill1info")
		tolua.cast(skill1,"UILabel")
		skill1:setText(skillInfo1.description)
		--设置换行用\n
		local skill2=RoleChoiceLayerRoot:getWidgetByName("herochoose_skill2info")
		tolua.cast(skill2,"UILabel")
		skill2:setText(skillInfo2.description)
		local imageSkill1=RoleChoiceLayerRoot:getWidgetByName("herochoose_skillback1")
		tolua.cast(imageSkill1,"UIImageView")
		imageSkill1:setTouchEnabled(true)
		imageSkill1:setTag(tonumber(initData.skill1))
		--imageSkill1:registerEventScript(clickImgInfo)
		UIManager.registerEvent(imageSkill1, nil, clickImgInfo, longClickCallback_job)
		
		imageSkill1:loadTexture(skillInfo1.icon)
		local imageSkill2=RoleChoiceLayerRoot:getWidgetByName("herochoose_skillback2")
		tolua.cast(imageSkill2,"UIImageView")
		imageSkill2:setTouchEnabled(true)
		imageSkill2:setTag(tonumber(initData.skill2))
		--imageSkill2:registerEventScript(clickImgInfo)
		UIManager.registerEvent(imageSkill2, nil, clickImgInfo, longClickCallback_job)
		imageSkill2:loadTexture(skillInfo2.icon)
	end
end

local function setNodeTag(widget,iTag)
	widget:getRenderer():setTag(iTag)
end

local function getNodeTag(widget)
	return widget:getRenderer():getTag()
end

local function showSelectedParticle(widget)

	local pos = widget:getWorldPosition()
	if mCircleParticle == nil then
		local btnParticle = CCParticleSystemQuad:create("btn_selected_particle.plist")
		RoleChoiceLayerRoot:addChild(btnParticle, 100)
		mCircleParticle = btnParticle
	end
	
	mCircleParticle:setPosition(pos)
	mCircleParticle:resetSystem()
	LuaAction.ellipseBy(mCircleParticle, 2.1, 50, 50)
end

--设置角色选择按钮
local function setRoleButtonTouch(bTouch,index)
	for i=1,4 do
		local btn = RoleChoiceLayerRoot:getWidgetByName("Button_select_role_"..i)
		if index ~= nil then
			if i == index then
				btn:setTouchEnabled(false)
				btn:setVisible(true)
				showSelectedParticle(btn)
			else
				btn:setVisible(false)
				btn:setTouchEnabled(true)
			end
		end
		
		if bTouch == false then
			btn:setTouchEnabled(false)
		end
	end
end

LayerRoleChoice.onClick = function(weight)
	local weightName = weight:getName()
	--print("LayerRoleChoice.onClick ********",weightName)
	if (weightName == "herochoose_namechoose") then --随机名字
		mEditorBoxName:setText( RandomName())
		return
	end
	
	if (weightName == "back") then					--返回登录界面
		LuaAction.removeTarget(mCircleParticle)
		mCircleParticle = nil
        UIManager.pop("UI_RollChoice")
		return
    end
	
	--邀请码
	if weightName == "Button_invite" then
		UIManager.push("UI_InviteCodeInput")
	end

	--创建角色
	if weightName == "herochoose_sure" then

		local valueStr = mEditorBoxName:getText()
		if Calculate_Str_len(valueStr) > 7 then
			Toast.show(GameString.get("ROLE_CREATE_STR_01"))
			return
		end
		--print("***************",lastOnclickId,valueStr)
        loginDataCache.reqCreaterole(lastOnclickId,valueStr)
		
		weight:setTouchEnabled(false)
		local function actionDone()
			weight:setTouchEnabled(true)
		end
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(0.5))
		arr:addObject(CCCallFunc:create(actionDone))
		weight:runAction(CCSequence:create(arr))
		
		return
     end
	
	for i=1,4 do
		if weightName == "Button_select_role_"..i then
			LayerRoleChoice.clickRoleButton(i)
			Audio.playEffectByTag(7)
			return
		end
	end
end

LayerRoleChoice.clickRoleButton = function(index)
	LayerRoleChoice.StopRoleAction()
	local countType = "-"
	if index > mSelectIndexBack then
		countType = "-"
	else
		countType = "+"
	end
	if mSelectIndexBack == 1 and index == 4 then
		countType = "+"
	elseif mSelectIndexBack == 4 and index == 1 then
		countType = "-"
	end
	LayerRoleChoice.PlayAnime(index,countType)
	setRoleButtonTouch(false,index)
	setHeroAttribute(index)
	mSelectIndexBack = index
end

LayerRoleChoice.getSureButton = function()
	return sureButton
end
--------------------------------------------------------------------------------------------------------------
LayerRoleChoice.init = function()
	mSelectIndexBack = 1
	mRoleBackData = {}
	mRoleWidget = {}
	RoleChoiceLayerRoot = UIManager.findLayerByTag("UI_RollChoice")
	setOnClickListenner("Button_invite")			--验证码待打开？？？？？？？
	

    --获得筛子按钮
	setOnClickListenner("herochoose_namechoose")
	setOnClickListenner("herochoose_sure")

    local btnBack = RoleChoiceLayerRoot:getWidgetByName("back")
    btnBack:setEnabled(false)
	--setOnClickListenner("back")
	
	sureButton= RoleChoiceLayerRoot:getWidgetByName("herochoose_sure")
	tolua.cast(sureButton,"UIButton")
    setHeroAttribute(1)
	
	--名字
	local nameBg = RoleChoiceLayerRoot:getWidgetByName("herochoose_name")
	mEditorBoxName = CommonFunc_createCCEditBox(ccp(0.5,0.5),ccp(5,1), CCSizeMake(210,35),"touming.png",
				4,7,GameString.get("Public_input_name"),kEditBoxInputModeSingleLine,kKeyboardReturnTypeDefault)
	mEditorBoxName:setTouchEnabled(true)
	mEditorBoxName:setPlaceholderFontSize(30)
	nameBg:addRenderer(mEditorBoxName,10)
	mEditorBoxName:setText( RandomName())


	local imageSkill1=RoleChoiceLayerRoot:getWidgetByName("herochoose_skillback1")
	CommonFunc_SetQualityFrame(imageSkill1,1)

	local imageSkill2=RoleChoiceLayerRoot:getWidgetByName("herochoose_skillback2")
	CommonFunc_SetQualityFrame(imageSkill2,1)
	
	local  lightBg = RoleChoiceLayerRoot:getWidgetByName("ImageView_138")
    tolua.cast(labelName,"UIImageView")
	local lightBgSprite = lightBg:getVirtualRenderer() 
	
	local emitter = CCParticleSystemQuad:create("role_choose_light_bg.plist")
    lightBgSprite:addChild(emitter)
    emitter:setPosition(ccp(181, 0))
	
	--z轴 3,5,2,1
	local zTable = {1,5,3,2}
	local tableTag = {4,1,2,3}
	for i=1,4 do 
		setOnClickListenner("Button_select_role_"..i)
		
		local widget = RoleChoiceLayerRoot:getWidgetByName("role_typ_"..i)
		setNodeTag(widget,tableTag[i])
		
		local val = {}
		val.widget = widget
		val.index = i
		table.insert(mRoleWidget,val)
		
		local pos = widget:getPosition()
		mRoleBackData[i] = {}
		mRoleBackData[i].pos = ccp(pos.x,pos.y)
		mRoleBackData[i].z = zTable[i]--widget:getZOrder()
		mRoleBackData[i].scale = widget:getScale()
		
		LayerRoleChoice.PlayRoleWait(i)
		if i ~= 2 then
			widget:setColor(ccc3(50,50,50))
		end
	end
	
	setRoleButtonTouch(true,1)
end

--复位数据Z轴
local function ResetData_Z(strTag)
	local ztable = {}
	ztable_1 = {1,5,3,2}
	ztable_2 = {3,5,2,1}
	for key,val in pairs(mRoleWidget) do
		local index = val.index
		--val.widget:setZOrder(mRoleBackData[index].z)
		if strTag == "-" then
			val.widget:setZOrder(ztable_1[index])
		else
			val.widget:setZOrder(ztable_2[index])
		end
	end
end	

--复位数据
local function ResetData()
	for key,val in pairs(mRoleWidget) do
		local index = val.index
		--cclog("key,ZOrder",key,mRoleBackData[index].z)
		val.widget:setZOrder(mRoleBackData[index].z)
		val.widget:setScale(mRoleBackData[index].scale)
		val.widget:setPosition(mRoleBackData[index].pos)
	end
end

--判断条件是否满足
local function FullSelect_condition(iTag)
	for key,val in pairs(mRoleWidget) do
		if getNodeTag(val.widget) == iTag and val.index == 2 then
			return true
		end
	end
	return false
end

--当前位置
function LayerRoleChoice.getRoleWidget(index)
	index = index or 2
	for key,val in pairs(mRoleWidget) do
		--cclog("当前位置",val.index)
		if val.index == index then
			return val.widget
		end
	end
end

--暂停指定角色动画
function LayerRoleChoice.StopRoleAction()
	for key,val in pairs(mRoleWidget) do
		val.widget:getVirtualRenderer():stopAllActions()
	end
end

--人物待机动画
function LayerRoleChoice.PlayRoleWait(roleIndex)
	--固定第二个人物播放动画
	local widget = LayerRoleChoice.getRoleWidget(roleIndex)
	local index = getNodeTag(widget)
	--玩家动画
	local role_tplt = ModelPlayer.getRoleRow(index)
	local role_Ani = ResourceManger.getAnimationFrameById(role_tplt.icon)

	ResourceManger.LoadSinglePicture(role_Ani.name)
	local strPath = string.format("%s_%s",role_Ani.name,role_Ani.wait).."_%03d.png"
	local action = createAnimation_forever_returnAction(strPath,role_Ani.wait_frame,0.1)
	local node = widget:getVirtualRenderer()
	node:runAction(action)
end

--播放动画
function LayerRoleChoice.PlayAnime(selectIndex,countType)
	local function convertIndex(_index,strCount)
		if strCount == "+" then
			_index = _index + 1
			_index = (_index - 1)%(#mRoleWidget)+1
		else
			_index = _index - 1
			if _index == 0 then
				_index = #mRoleWidget
			end
		end
		return _index
	end
	
	--动作执行次数
	local iEndAnimeCount = 0
	local function EndAnime(sender)
		cclog("EndAnime")
		iEndAnimeCount = iEndAnimeCount + 1
		if iEndAnimeCount == #mRoleWidget then		
			iEndAnimeCount = 0
			cclog("动作全部执行完毕")
			ResetData()
			
			if FullSelect_condition(selectIndex) == true then
				setRoleButtonTouch(true,lastOnclickId)
				LayerRoleChoice.PlayRoleWait()
				cclog("选择角色成功")
				return 
			end
			
			LayerRoleChoice.PlayAnime(selectIndex,countType)
		end
	end
	
	--旋转动画
	local function Anime(index)
		local iTime = 0.4
		if index == 2 then
			iTime = 0.4
		end
		local pos = mRoleBackData[index].pos
		local Action_1 = CCMoveTo:create(iTime,pos)
		local scale = mRoleBackData[index].scale
		local Action_2 = CCScaleTo:create(iTime,scale)
		local action = CCSpawn:createWithTwoActions(Action_1,Action_2)
		action = CCSequence:createWithTwoActions(action,CCCallFuncN:create(EndAnime))
		if index == 2 then
			action = CCSpawn:createWithTwoActions(action,CCTintTo:create(iTime,255,255,255))
			--return CCEaseSineOut:create(action)
		else
			action = CCSpawn:createWithTwoActions(action,CCTintTo:create(iTime,50,50,50))
			--return CCEaseSineOut:create(action)
		end
		return action
	end
	ResetData_Z(countType)
	for key,val in pairs(mRoleWidget) do
		local iTag = 0
		iTag = convertIndex(val.index,countType)
		val.index = iTag
		local action = Anime(iTag)
		val.widget:runAction(action)
	end
end

--获取选取的是哪个职业
LayerRoleChoice.getSelectedRoleType = function()
	return lastOnclickId
end

LayerRoleChoice.destroy = function()
	RoleChoiceLayerRoot = nil
	LuaAction.removeTarget(mCircleParticle)
	mCircleParticle = nil
end

