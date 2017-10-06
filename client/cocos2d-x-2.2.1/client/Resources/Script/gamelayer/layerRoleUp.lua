require "layerRoleUpPotent"
require "layerRoleUpDesc"

LayerRoleUp = setmetatable({},{__mode='k'})

LayerRoleUp.jsonFile = "RoleUp_1.json"
LayerRoleUp.RootView = nil



local function updateShowRole()
	local role_appence = LayerRoleUp.RootView:getChildByName("role_appearance")
	local role_tplt = ModelPlayer.getRoleUpAppence(ModelPlayer.getRoleType(),ModelPlayer.getAdvancedLevel())
	local role_Ani = ResourceManger.getAnimationFrameById(role_tplt.icon)
	ResourceManger.LoadSinglePicture(role_Ani.name)	
	local strPath = string.format("%s_%s", role_Ani.name, role_Ani.wait).."_%03d.png"
	local playerNode = createAnimation_forever(strPath, role_Ani.wait_frame, 0.1)
	role_appence:getVirtualRenderer():removeAllChildrenWithCleanup(true)
	role_appence:addRenderer(playerNode,23)
end


local function handle_onClick(typeName,widget) 
	if typeName == "releaseUp" then
		TipModule.onClick(widget)
		local curName = widget:getName()		
		if curName == "cancle_yxst" then 
			LayerMain.pullPannel(LayerRoleUp)
		--英雄潜能
		elseif curName == "rp_bt1" then 
			CopyDelockLogic.judgeYNEnterById(LIMIT_HERO_STREN.copy_id)
			setConententPannelJosn(LayerRoleUpPotent,LayerRoleUpPotent.jsonFile,LayerRoleUpPotent.jsonFile)
		elseif curName == "rp_bt3" then  	--英雄天赋
			setConententPannelJosn(LayerRoleTalent,LayerRoleTalent.jsonFile,LayerRoleTalent.jsonFile)
		end 
	end 
end

local function setUILabelTest(name,test)
		local label = LayerRoleUp.RootView:getChildByName(name)
		tolua.cast(label,"UILabel")
		label:setText(test)
end 

local function setPlayerAttr()

	setUILabelTest("name",ModelPlayer.getNickName()) 
	setUILabelTest("rt_qineng",string.format("%.2f",ModelPlayer.getPotenceLevel()/100)) 
	
	local rt_level = MiltitaryLogic.getMiltitaryLevel()
	if rt_level == 0 then 
		setUILabelTest("rt_jj","无") 
	else 
		setUILabelTest("rt_jj",LogicTable.getMiltitaryRankRow(rt_level).name) 
	end
		
	setUILabelTest("rt_zf",ModelPlayer.getBattleSoul()) 
		
	local attr = ModelPlayer.getPlayerAttr()
	setUILabelTest("rtr_life",tostring(attr.life)) 
	setUILabelTest("rt_speed",tostring(attr.speed)) 
	setUILabelTest("rp_atk",tostring(attr.atk))
	
	setUILabelTest("rt_crit",tostring(attr.critical_ratio)) 
	setUILabelTest("rt_rxing",tostring(attr.tenacity)) 
	setUILabelTest("rt_miss",tostring(attr.miss_ratio)) 
	setUILabelTest("rt_hit",tostring(attr.hit_ratio))  
end 




local function initButton()
	local grayImg = LayerRoleUp.RootView:getChildByName("icon_mask")
	LayerRoleUp.RootView:getChildByName("cancle_yxst"):registerEventScript(handle_onClick)
	LayerRoleUp.RootView:getChildByName("rp_bt1"):registerEventScript(handle_onClick)
	if CopyDelockLogic.judgeYNEnterById(LIMIT_TALENT.copy_id) then
		LayerRoleUp.RootView:getChildByName("rp_bt3"):setTouchEnabled(true)
		LayerRoleUp.RootView:getChildByName("rp_bt3"):registerEventScript(handle_onClick)
		grayImg:setVisible(false)
	else
		LayerRoleUp.RootView:getChildByName("rp_bt3"):setTouchEnabled(false)
		grayImg:setVisible(true)
	end
	
	LayerRoleUp.RootView:getChildByName("rp_bt3"):registerEventScript(handle_onClick)
	Lewis:spriteShaderEffect(LayerRoleUp.RootView:getChildByName("rp_bt2"):getVirtualRenderer(),"buff_gray.fsh",true)
	--Lewis:spriteShaderEffect(LayerRoleUp.RootView:getChildByName("rp_bt3"):getVirtualRenderer(),"buff_gray.fsh",true)
end 

LayerRoleUp.init = function(rootView)
	LayerRoleUp.RootView = rootView
	
	--英雄潜能提示
	local yn_Tip = LayerRoleUp.RootView:getChildByName("roleup_qn_tips")
	yn_Tip:setVisible(LayerRoleUpPotent.getRoleUpable())
	--英雄天赋提示
	local fu_Tip = LayerRoleUp.RootView:getChildByName("roleup_tf_tips")
	fu_Tip:setVisible(LayerRoleTalent.getTip())
	
	initButton()
	setPlayerAttr()
	updateShowRole()
	TipModule.onUI(rootView, "ui_roleup")
end 


LayerRoleUp.destroy = function()
	
end