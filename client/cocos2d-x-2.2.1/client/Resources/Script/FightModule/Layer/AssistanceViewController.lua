----------------------------------------------------
--作者: lewis
--日期: 2014-03-10
--描述:	援助技能
----------------------------------------------------

AssistanceViewController = {}

local AssistanceBtnDelegate = class()
function AssistanceBtnDelegate:selectSkill(id, bOn)
	--不能开启新回合
	if BattleMgr.isNewRoundVaid() == false then
		return false
	end
	local cd = AssistanceViewController.getConfig("cd")
	if cd > 0 then
		return false
	end
	local skill = AssistanceViewController.getConfig("data_skill")
	if bOn == false then
		skill:selectSkill(id, bOn)
		return false
	end
	GuideEvent.selectAssist()
	local ret = skill:selectSkill(id, bOn)
	if ret == "auto" then
		local level = skill:getLevel(id)
		local friend = RoleMgr.getConfig("rmc_friend_object")
		BattleMgr.autoSkill(friend, id, level)
		return true
	end
	return false
end

---------------------------------------------------------------------------
--------------------------------配置数据-----------------------------------
---------------------------------------------------------------------------
local mConfigTB = {}
--初始化配置数据
function AssistanceViewController.initConfig()
	mConfigTB = {}
	mConfigTB["root_view"]				= nil		--根结点
	mConfigTB["skill_btn"]				= nil		--技能按钮
	mConfigTB["offset_x"]				= -100
	mConfigTB["cd"]						= 10
	mConfigTB["data_skill"]				= nil
	mConfigTB["skill_id"]				= 0
	mConfigTB["skill_level"]			= 0
end

--获得数据
function AssistanceViewController.getConfig(name)
	local ret = mConfigTB[name]
	return ret
end

--设置数据
function AssistanceViewController.setConfig(name, value)
	mConfigTB[name] = value
end

---------------------------------------------------------------------------
--------------------------------逻辑数值-----------------------------------
---------------------------------------------------------------------------
--创建援军技能
function AssistanceViewController.create()
	AssistanceViewController.initConfig()
	--不是(关卡模式,活动副本)不存在援军技能
	local fgGameMode = FightDateCache.getData("fd_game_mode")
	if fgGameMode ~= 1 and fgGameMode ~= 6 then
		return
	end
	
	--获得援军技能信息
	local tbSkill = AssistanceLogic.getDonorInfo()
	if tbSkill == nil then
		return
	end

	local id 	= tbSkill.sculpture.temp_id
	local level = tbSkill.sculpture.level
	FightDateCache.setData("fd_friend_role_type", tbSkill.role_type)
	AssistanceViewController.setConfig("skill_id", id)
	AssistanceViewController.setConfig("skill_level", level)
	
	local dataSkill = DataSkill.new()
	dataSkill:addSkill(id, level, 0)
	AssistanceViewController.setConfig("data_skill", dataSkill)
	
	local root = GUIReader:shareReader():widgetFromJsonFile("AssistanceSkill_1.json")
	LayerGameUI.mRootView:addWidget(root)
	AssistanceViewController.setConfig("root_view", root)
	
	-- 按钮
	local btnCall = CommonFunc_getNodeByName(root, "btn_tips", "UIButton")
	btnCall:registerEventScript(AssistanceViewController.btnComeOut)
	
	--背景
	local imgBg = CommonFunc_getNodeByName(root, "imgView_bg", "UIImageView")
	
	local delegate = AssistanceBtnDelegate.new()
	local btn = PlayerSkillBtn.new()
	--layout:convertToWorldSpace(ccp(0, 0))
	btn:init(imgBg, ccp(123, 0), id, level, 5)
	btn:setDelegate(delegate)
	btn:update(1.0, 0)
	AssistanceViewController.setConfig("skill_btn", btn)
	
	AssistanceViewController.updateCD()
end

--更新
function AssistanceViewController.update()
	local root = AssistanceViewController.getConfig("root_view")
	if root == nil then return end
	local cd = AssistanceViewController.getConfig("cd")
	if cd > 0 then
		cd = cd - 1
	end
	AssistanceViewController.setConfig("cd", cd)
	-- 回合次数
	local atlasRound = CommonFunc_getLabelByName(root, "labelAltas_round", nil, true)
	atlasRound:setStringValue(string.format("%d", cd))
	
	--冷却完毕自动弹出
	if cd == 0 and AssistanceViewController.getConfig("offset_x") < 0 then
		AssistanceViewController.layerMoveAction()
	end
end

--弹出按钮
function AssistanceViewController.btnComeOut(clickType, widget)
	if clickType ~= "releaseUp" then
		return
	end
	local cd = AssistanceViewController.getConfig("cd")
	if cd > 0 then
		return
	end
	
	AssistanceViewController.layerMoveAction()
	if AssistanceViewController.getConfig("offset_x") < 0 then
		local btn = AssistanceViewController.getConfig("skill_btn")
		--取消选中
		if btn.mbSelected then
			btn:onEvent()
		end
	end
end

--层移动动作
function AssistanceViewController.layerMoveAction()
	local x = AssistanceViewController.getConfig("offset_x")
	local action = CCMoveBy:create(0.3, ccp(x, 0))
	x = -x
	AssistanceViewController.setConfig("offset_x", x)
	AssistanceViewController.getConfig("root_view"):runAction(action)
	if x > 0 then
		TipModule.onUI(LayerGameUI.mRootView, "ui_assistance_skill")
	end
end

--使用技能
function AssistanceViewController.useSkill()
	local dataSkill = AssistanceViewController.getConfig("data_skill")
	dataSkill:unselectAllSkill()
	AssistanceViewController.setConfig("cd", 10)
	if AssistanceViewController.getConfig("offset_x") > 0 then
		AssistanceViewController.layerMoveAction()
	end
	AssistanceViewController.updateCD()
	local btn = AssistanceViewController.getConfig("skill_btn")
	btn:unSelect()
end

--更新cd
function AssistanceViewController.updateCD()
	local root = AssistanceViewController.getConfig("root_view")
	local cd = AssistanceViewController.getConfig("cd")
	local atlasRound = CommonFunc_getLabelByName(root, "labelAltas_round", nil, true)
	atlasRound:setStringValue(string.format("%d", cd))
end

