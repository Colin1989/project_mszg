-------------------------------------
--作者：lewis
--说明：怪物或竞技场敌人信息
--时间：2014-5-22
-------------------------------------

LayerMonsterInfo = {}

local function localPrint(...)
	if true then return end
	lewisPrint("LayerMonsterInfo", ...)
end

LayerAbstract:extend(LayerMonsterInfo)

local mRootView = nil      --当前界面的根节点
local mRoleView = nil
local monster = nil
local mMonsterRoot = nil
local mActionSprite = nil

LayerMonsterInfo.onClick = function(widget)
    local widgetName = widget:getName()
    if "Button_close" == widgetName then  					-- 确认键
		if mActionSprite ~= nil then
			mActionSprite:cleanup()
			mActionSprite = nil
		end
		UIManager.pop("UI_MonsterInfo")
		FightDateCache.setData("fd_game_pause", false)
    end
end

--------------------------------------------------------------------------------------
-- 更新滚动层尺寸
local function updateScrollViewSize(scroll) 
    local scrollSize = scroll:getSize()
	
    -- 遍历cell
    local sumheight = 0  --总高度
    local array = scroll:getChildren()
    for i=0,array:count()-1 do
        local node = array:objectAtIndex(i)
        tolua.cast(node,"UIWidget")
		local x = node:getPosition().x
		local y = node:getPosition().y
        sumheight = sumheight + node:getSize().height
    end
	
    if scrollSize.height < sumheight then
       scroll:setInnerContainerSize(CCSize(scrollSize.width,sumheight))
    end
    -- print("~~~~~~scroll",scrollSize.width,scrollSize.height,sumheight)
    
    scroll:doLayout()
end

-------------------------------------------------------------------------------------
-- 添加cell
local function addScrollView(node)
    local scroll = tolua.cast(mRootView:getWidgetByName("ScrollView_list"), "UIScrollView")
    scroll:addChild(node)
    updateScrollViewSize(scroll)
end

--技能信息
local function skillInfoView(mCell,monster)
	local idx = 1
	local tb = monster:getDataInfo("skill"):getTB()
	local skillIdx = 1
	for idx = 1, 4 do
		local root = mCell:getChildByName("skill_"..idx)
		tolua.cast(root, "UIImageView")
		local labelName = mCell:getChildByName("lable_skill_name_"..idx)
		tolua.cast(labelName, "UILabel")

		local labelLeftCd = mCell:getChildByName("lable_skill_left_"..idx)
		tolua.cast(labelLeftCd, "UILabel")
		while true do
			local unit = tb[skillIdx]
			skillIdx = skillIdx + 1
			if unit ~= nil then
				--被动技能不显示
				if unit.maxCD > 0 then
					root:loadTexture("monsterBar.png")
					labelName:setText(unit.name)
                    local showRound = unit.needCD
                    if showRound < 0 then showRound = 0 end
                    labelLeftCd:setText("("..showRound.."回合)")
					break
				end
			else
				--root:setVisible(false)
				labelName:setVisible(false)
                labelLeftCd:setVisible(false)
				break
			end
		end
	end
end

--属性信息
local function createLabel(mCell, name, value)
	local labelTag = tolua.cast(mCell:getChildByName(name), "UILabel")
	local labelValue = CCLabelAtlas:create(string.format("%d", value), "num_gold.png", 24, 32, 48)
	mCell:addRenderer(labelValue, 100)
	labelValue:setScale(0.7)
	labelValue:setAnchorPoint(ccp(0.0, 0.5))
	labelValue:setPosition(labelTag:convertToWorldSpace(ccp(50, 0)))
end

local function attrInfoView(mCell, monster)
	local iconSprite = mCell:getChildByName("icon")
	tolua.cast(iconSprite, "UIImageView")
	iconSprite:setVisible(false)
	
	--怪物类别
	local monsterType = mCell:getChildByName("Label_140")
	tolua.cast(monsterType, "UILabel")
    --类别ICON
    local monster_info_icon = mCell:getChildByName("monster_info_icon")
    tolua.cast(monster_info_icon, "UIImageView")

	local mt = monster:getConfig("monster_type")
    
	if mt > 0 then
		monsterType:setText(ModelMonster.monsterType(mt))
        if mt > 1 then --普通怪类型为1 不显示
            monster_info_icon:loadTexture(string.format("monstersign_%d.png", mt),UI_TEX_TYPE_PLIST)
        end 
	else
		monsterType:setVisible(false)
	end

	--特殊技能
	local ssLabel = tolua.cast(mCell:getChildByName("Label_skill"), "UILabel")
	ssLabel:setTextAreaSize(CCSizeMake(307, 60))
	local sk = monster:getConfig("specail_skill_id")
	if sk > 0 then
		local sc = SpecialSkill.getConfig(sk)
		if sc ~= nil then
			ssLabel:setText(sc.description)
			ssLabel:setVisible(true)
		else
			--ssLabel:setVisible(false)
            ssLabel:setText("无特殊能力")
		end
	else
		--ssLabel:setVisible(false)
        ssLabel:setText("无特殊能力")
	end
	
	--基本属性
	local attribute = monster:getDataInfo("attr")
	createLabel(mCell, "Label_level", monster:getConfig("role_level"))
	createLabel(mCell, "Label_lfie", attribute:getByName("life"))
	createLabel(mCell, "Label_atk", attribute:getByName("atk"))
	createLabel(mCell, "Label_speed", attribute:getByName("speed"))
end

local function buffInfoView(data)
	
	local node = CommonFunc_getImgView("public2_bg_07.png")
	node:setScale9Enabled(true)
	node:setCapInsets(CCRectMake(19, 21, 1, 1))
	node:setSize(CCSizeMake(436, 112))
	
	-- 图标
	local buff_icon = data:getBuffConfig("buff_icon")
	local icon = CommonFunc_getImgView("touming.png")
	icon:loadTexture(buff_icon, UI_TEX_TYPE_PLIST)
	icon:setPosition(ccp(-165, -2))
	node:addChild(icon)
	
	-- 名字
	local buff_name = data:getBuffConfig("buff_name")
	local name = CommonFunc_getLabel(buff_name, 24)
	name:setPosition(ccp(-125, 38))
	name:setAnchorPoint(ccp(0.0, 0.5))
	node:addChild(name)
	
	-- 剩余回合数
	local duration = data:getBuffConfig("duration")
	local labelDuration = CommonFunc_getLabel(GameString.get("MONSTER_INFO_1",duration), 24)
	labelDuration:setPosition(ccp(3, 38))
	labelDuration:setAnchorPoint(ccp(0.0, 0.5))
	node:addChild(labelDuration)
	
	-- 描述
	local buff_id = data:getBuffConfig("buff_id")
	local quality = data:getBuffConfig("quality")
	local level = data:getBuffConfig("level")
	local des = CommonFunc_getLabel(SkillMgr.getBuffDescription(buff_id, quality, level,data:getBuffConfig("talentlv")), 20)
	des:setTextAreaSize(CCSizeMake(338, 70))
	des:setPosition(ccp(-125, 24))
	des:setAnchorPoint(ccp(0.0, 1.0))
	node:addChild(des)
	
	-- 角标
	local buff_type = data:getBuffConfig("buff_type")
	local mark = CommonFunc_getImgView("touming.png")
	mark:setPosition(ccp(-185, 21))
	node:addChild(mark)
	
	if tonumber(buff_type) == 1 then
		mark:loadTexture("status_up.png")
	elseif tonumber(buff_type) == 2 then
		mark:loadTexture("status_down.png")
	elseif tonumber(buff_type) == 4 then
		labelDuration:setVisible(false)
		mark:setVisible(false)
	else
		mark:setVisible(false)
	end
	
	return node
	
end

local function monsterInfoView(data)
	if mMonsterRoot == nil then
		mMonsterRoot = GUIReader:shareReader():widgetFromJsonFile("MonsterInfo_2.json")
	end
	local mCell = mMonsterRoot:clone()
	mCell:retain()
	local icon = data:getConfig("role_icon_id")
	local name = data:getConfig("role_nick_name")
	-- 怪物icon
	local monsterView = tolua.cast(mCell:getChildByName("icon_monster"), "UIImageView")
	mActionSprite = ActionSprite.new()
	mActionSprite:init(monsterView:getRenderer(), ccp(0, 0), icon, 0)
	-- 怪物名字
	local labelName = mCell:getChildByName("Label_name")
	tolua.cast(labelName, "UILabel")
	labelName:setText(name)
	-- 怪物技能
	skillInfoView(mCell, data)
	-- 怪物四个基本属性
	attrInfoView(mCell, data)
	
	return mCell
end

LayerMonsterInfo.init = function(bundle)
	FightDateCache.setData("fd_game_pause", true)
    mRootView = UIManager.findLayerByTag("UI_MonsterInfo")
	-- setOnClickListenner("bg")
	setOnClickListenner("Button_close")
	monster = RoleMgr.getSummonMonsterByGridId(bundle.gridId,bundle.camp)
	if monster == nil then
		return
	end
	
	-- 滚动列表
	local scrollView = tolua.cast(mRootView:getWidgetByName("ScrollView_list"), "UIScrollView")
	scrollView:setLayoutType(LAYOUT_LINEAR_VERTICAL)
	scrollView:removeAllChildren()
	-- 怪物基本信息
	local monsterInfoCell = monsterInfoView(monster)
	addScrollView(monsterInfoCell)
	-- 怪物Buff信息
	local mBuffTb = monster:getDataInfo("buff")
	if #mBuffTb == 0 then
		
		local node = CommonFunc_getImgView("public2_bg_07.png")
		node:setScale9Enabled(true)
		node:setCapInsets(CCRectMake(19, 21, 1, 1))
		node:setSize(CCSizeMake(436, 112))
		
		local labelNull = CommonFunc_getLabel(GameString.get("MONSTER_INFO_2"), 30)
		labelNull:setPosition(ccp(0, 0))
		node:addChild(labelNull)
		
		-- local  imageAll = mCell:getChildByName("ImageView_126")		-- 不为空时应显示的所有控件
		-- imageAll:setVisible(false)
		-- local labelnull = mCell:getChildByName("Label_null")		-- 为空时显示的提示信息
		-- labelnull:setVisible(true)
		
		addScrollView(node)
	else
		for key, val in pairs(mBuffTb) do
			local monsterBuffCell = buffInfoView(val)
			addScrollView(monsterBuffCell)
		end
	end
end

LayerMonsterInfo.destroy = function()
	mRootView = nil
	monster = nil
	mMonsterRoot = nil
end

function LayerMonsterInfo.onEnter()
	mRootView = nil
end


function LayerMonsterInfo.onExit()
	mRootView = UIManager.findLayerByTag("UI_MonsterInfo")
	if mRootView ~= nil then
		mRootView:removeFromParentAndCleanup(true)
		mRootView = nil
	end
end


