----------------------------------------------------------------------
-- 作者：李慧琴
-- 日期：2014-4-29
-- 描述：战斗（界面和状态）信息显示界面
----------------------------------------------------------------------
local fightInfoLayerRoot = nil			---当前界面root节点
local mSkillTb = {}				--技能信息
local mBuffTb = nil
local dataCell = nil
LayerGameFightInfo = {
}
LayerAbstract:extend(LayerGameFightInfo)

LayerGameFightInfo.onClick = function(weight)
	local weightName = weight:getName()
	if weightName == "Button_23" then		 	--返回多角色界面
		UIManager.pop("UI_GameFightInfo")
		FightDateCache.setData("fd_game_pause", false)
	end
end

local function getBuffNodeById(cell, data, index)
	if nil == dataCell then
		dataCell = GUIReader:shareReader():widgetFromJsonFile("GameFightInfo_2.json")
	end
	local mCell = dataCell:clone()
	dataCell:retain()
	
	local buff_icon = data:getBuffConfig("buff_icon")
	local  image = tolua.cast(mCell:getChildByName("Icon_bg"), "UIImageView")		-- 图标
	image:loadTexture(buff_icon, UI_TEX_TYPE_PLIST)
	
	local buff_name = data:getBuffConfig("buff_name")
	local name = tolua.cast(mCell:getChildByName("Label_name"), "UILabel")			-- 名字
	name:setText(buff_name)
	
	local duration = data:getBuffConfig("duration")
	local labelDuration = tolua.cast(mCell:getChildByName("Label_duration"), "UILabel")	-- 剩余回合数
	labelDuration:setText(duration)
	
	local buff_id = data:getBuffConfig("buff_id")
	local quality = data:getBuffConfig("quality")
	local level = data:getBuffConfig("level")
	local des = tolua.cast(mCell:getChildByName("Label_intro"), "UILabel")			-- 描述
	des:setTextAreaSize(CCSizeMake(338, 70))
	des:setText(SkillMgr.getBuffDescription(buff_id, quality, level,data:getBuffConfig("talentlv")))			--这里的值是固定的，需要接口，待改变
	
	local buff_type = data:getBuffConfig("buff_type") 
	local mark = tolua.cast(mCell:getChildByName("buff_mark"), "UIImageView")	-- 角标
	if tonumber(buff_type) == 1 then
		mark:loadTexture("status_up.png")
	elseif tonumber(buff_type) == 2 then
		mark:loadTexture("status_down.png")
	else
		mark:setVisible(false)
	end
	
	return mCell
end

--加载四个技能信息
local function loadFourSkill()
	for key, value in pairs(mSkillTb.skills) do
		local skill = ModelSkill.getSkill(value)
		if skill then
			local skillBaseInfo = SkillConfig.getSkillBaseInfo(skill.temp_id)
			local panel = fightInfoLayerRoot:getWidgetByName(string.format("skillPanel_%d", key))
			local image = tolua.cast(panel:getChildByName(string.format("Icon_%d", key)), "UIImageView")		--图标
			CommonFunc_AddGirdWidget_Rune(value, skill.value, nil, image)		
			local name = tolua.cast(panel:getChildByName(string.format("name_%d", key)), "UILabel")			--名字
			name:setText(skillBaseInfo.name)
			local des = tolua.cast(panel:getChildByName(string.format("intro_%d", key)), "UILabel")			--描述
			des:setText(SkillMgr.getDescription(skill.temp_id, skill.value))
		end
	end
end

--加载两个状态信息
local function loadTwoStatus()
	local player = RoleMgr.getConfig("rmc_player_object")
	local buff = player:getDataInfo("buff")
	for i = 1, 2 do
		local value = buff.units[i]
		if value.id ~= 0 then
			local  buffInfo = SkillConfig.getSkillBuffInfo(value.id)
			local  panel = fightInfoLayerRoot:getWidgetByName(string.format("statePanel_%d",i))
			local  image = panel:getChildByName(string.format("Icon_%d",i))		--图标
			tolua.cast(image,"UIImageView")
			image:loadTexture(buffInfo.buff_icon,UI_TEX_TYPE_PLIST)
			local name = panel:getChildByName(string.format("name_%d",i))			--名字
			tolua.cast(name,"UILabel")
			name:setText(buffInfo.buff_name)
			local des = panel:getChildByName(string.format("intro_%d",i))			--描述
			tolua.cast(des,"UILabel")
			des:setText(SkillMgr.getBuffDescription(value.id, value.quality, value.level))			--这里的值是固定的，需要接口，待改变
		end
	end
end

LayerGameFightInfo.init = function (bundle)
	mBuffTb = bundle
	FightDateCache.setData("fd_game_pause", true)
	fightInfoLayerRoot = UIManager.findLayerByTag("UI_GameFightInfo")
	setOnClickListenner("Button_23")
	mSkillTb = ModelSkill.getSkillGroup()
	-- loadFourSkill()
	-- loadTwoStatus()
	local scrollView = tolua.cast(fightInfoLayerRoot:getWidgetByName("ScrollView_list"), "UIScrollView")
	scrollView:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	scrollView:removeAllChildren()
	if #mBuffTb == 0 then
		if nil == dataCell then
			dataCell = GUIReader:shareReader():widgetFromJsonFile("GameFightInfo_2.json")
		end
		local mCell = dataCell:clone()
		dataCell:retain()
		local  imageAll = tolua.cast(mCell:getChildByName("ImageView_126"), "UIImageView")		-- 不为空时应显示的所有控件
		imageAll:setVisible(false)
		local labelnull = tolua.cast(mCell:getChildByName("Label_null"), "UILabel")			-- 为空时显示的提示信息
		labelnull:setVisible(true)
		
		scrollView:addChild(mCell)
		local mScrollViewWidth = scrollView:getInnerContainerSize().width				-- 列表宽
		local mScrollViewHeight = scrollView:getInnerContainerSize().height			-- 列表高
		cclog(mScrollViewWidth, mScrollViewHeight)
		mCell:setAnchorPoint(ccp(0.5, 0.5))
		mCell:setPosition(ccp(218, 444))
	else
		UIScrollViewEx.show(scrollView, mBuffTb, getBuffNodeById, "V", 436, 112, 0, 1, 4, true, nil, true, true)
	end
end

LayerGameFightInfo.destroy = function()
	fightInfoLayerRoot = nil
	mBuffTb = nil
	dataCell = nil
end
