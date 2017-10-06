
local g_main_layer = nil
local g_front_layer = nil
local g_back_layer = nil

local g_cur_player_sprite = nil
local g_cur_monster_sprite = nil
local g_monster_key = 1
local g_cur_skill_effect_sprite = nil
local g_skill_effect_key = 1

local g_cur_skill_effect_id = -1
local g_skill_effect_exts = {}

g_Role_Animate_Info = {}

GameSkillTestLayer = {}

local monsterPos = ccp(480, 320)
local mCurMousePos = ccp(0, 0)
local idLabel

local function loadSkillEffectExtsInfo()
	local fileName = "skill_effect_exts_tplt.xml"
	local xmlTB = loadXmlFile(fileName)
	print("parse skill buff info")
	for k, v in pairs(xmlTB) do				-- 行
		local row = {}	
		for name, value in pairs(v) do		-- 列
			print("name: "..name.." value "..value)
			if "effect_id" == name then
				row.effect_id = value + 0	
			elseif "offx" == name then
				row.offx = value + 0
			elseif "offy" == name then
				row.offy = value + 0
			end
		end	
		table.insert(g_skill_effect_exts, row)
	end
	print("table g_skill_effect_exts count>>"..#g_skill_effect_exts)
end

loadSkillEffectExtsInfo()

local function saveSkillEffectExtsInfo()
	local xml = Save_Xml:create("skill_effect_exts_tplt.xml")
	
	for key, element in pairs(g_skill_effect_exts) do
		xml:newElement("array")
		local id_v = string.format("%d", element.effect_id)
		local x_v = string.format("%d", element.offx)
		local y_v = string.format("%d", element.offy)
		xml:addSubElement("effect_id", id_v)
		xml:addSubElement("offx", x_v)
		xml:addSubElement("offy", y_v)
	end
	xml:save()
	xml:release()
end

local function getSkillEffectExts(effectID)
	for key, element in pairs(g_skill_effect_exts) do
		if element.effect_id == effectID then
			return element
		end
	end
	
	local newTable = {}
	newTable.effect_id = effectID
	newTable.offx = 0
	newTable.offy = 0
	table.insert(g_skill_effect_exts, newTable)
	return getSkillEffectExts(effectID)
end


local function loadPlistFile(name)
	print("load plist file "..name)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(name)
end

local function onTouchBegan(x, y)
	--print("on touch")
	g_cur_skill_effect_sprite:setPosition(ccp(x, y))
	return true
end

local function onTouchMoved(x, y)
	mCurMousePos.x = x
	mCurMousePos.y = y
    g_cur_skill_effect_sprite:setPosition(ccp(x, y)) 
end

local function onTouchEnded(x, y)

end

--创建怪物图
local function createMonsterSprite()
	local animateInfo = nil
	
	local function getMonsterAnimateInfo(index)
		for key, value in pairs(g_Role_Animate_Info) do
			if key == index then
				return value
			end
		end
		return nil
	end
	if g_cur_monster_sprite ~= nil then
		g_cur_monster_sprite:removeFromParentAndCleanup(true)
		g_cur_monster_sprite = nil
	end
	
	animateInfo = getMonsterAnimateInfo(g_monster_key)
	
	print("plist name +++++++++++++++++++++++++++++"..animateInfo.name)
	loadPlistFile(string.format("%s.plist", animateInfo.name))
	local sprite = CCSprite:createWithSpriteFrameName(string.format("%s_%s", animateInfo.name, "wait").."_001.png")
	g_main_layer:addChild(sprite)
	
	local str = string.format("%s_%s", animateInfo.name, "wait").."_%03d.png"
	local animation = GameSkillConfig.createAnimation(str, animateInfo.wait_frame, 1.0 / 8.0)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	sprite:setPosition(monsterPos)
	g_cur_monster_sprite = sprite
end

--创建选择怪物的按钮
local function createMonsterSelectBtn()
	local menu = CCMenu:create()
	g_main_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))
	
	local function preMonster(sender)
		g_monster_key = g_monster_key - 1
		if g_monster_key < 1 then
			g_monster_key = #g_Role_Animate_Info
		end
		createMonsterSprite()
	end
	local preBtn = CCMenuItemFont:create("pre monster")
    preBtn:registerScriptTapHandler(preMonster)
	menu:addChild(preBtn)
	preBtn:setPosition(ccp(280,320))
	
	local function nextMonster(sender)
		g_monster_key = g_monster_key + 1
		if g_monster_key > #g_Role_Animate_Info then
			g_monster_key = 1
		end
		createMonsterSprite()
	end
	local nextBtn = CCMenuItemFont:create("next monster")
    nextBtn:registerScriptTapHandler(nextMonster)
	menu:addChild(nextBtn)
	nextBtn:setPosition(ccp(680,320))
end


--创建技能效果
local function createSkillEffect()
	local skillEffectInfo = GameSkillConfig.getSkillEffectInfoByKey(g_skill_effect_key)
	if skillEffectInfo == nil then
		g_skill_effect_key = 1
		skillEffectInfo = GameSkillConfig.getSkillEffectInfoByKey(g_skill_effect_key)
	end
	if g_cur_skill_effect_sprite ~= nil then
		g_cur_skill_effect_sprite:removeFromParentAndCleanup(true)
		g_cur_skill_effect_sprite = nil
	end
	loadPlistFile(skillEffectInfo.plist_name)
	local sprite = CCSprite:createWithSpriteFrameName(skillEffectInfo.file_name)
	g_front_layer:addChild(sprite)
	
	idLabel:setString(g_skill_effect_key)
	
	local animation = GameSkillConfig.createAnimation(skillEffectInfo.string_format, skillEffectInfo.image_count, 1.0 / 8.0)
	sprite:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
	
	local extsInfo = getSkillEffectExts(skillEffectInfo.effect_id)
	local x = monsterPos.x + extsInfo.offx
	local y = monsterPos.y + extsInfo.offy
	sprite:setPosition(ccp(x, y))
	g_cur_skill_effect_sprite = sprite
	g_cur_skill_effect_id = skillEffectInfo.effect_id
end

--创建选择技能的按钮
local function createSkillEffectSelectBtn()
	local menu = CCMenu:create()
	g_main_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))
	
	local function preSkillEffect(sender)
		if g_skill_effect_key > 1 then
			g_skill_effect_key = g_skill_effect_key - 1
			createSkillEffect()
		end
	end
	local preBtn = CCMenuItemFont:create("pre skill effect")
    preBtn:registerScriptTapHandler(preSkillEffect)
	menu:addChild(preBtn)
	preBtn:setPosition(ccp(180,120))
	
	local function nextSkillEffect(sender)
		g_skill_effect_key = g_skill_effect_key + 1
		createSkillEffect()
	end
	local nextBtn = CCMenuItemFont:create("next skill effect")
    nextBtn:registerScriptTapHandler(nextSkillEffect)
	menu:addChild(nextBtn)
	nextBtn:setPosition(ccp(780,120))
	
	local function save(sender)
		if g_cur_skill_effect_id == -1 then
			return
		end
		local extsInfo = getSkillEffectExts(g_cur_skill_effect_id)
		extsInfo.offx = mCurMousePos.x - monsterPos.x
		extsInfo.offy = mCurMousePos.y - monsterPos.y
		saveSkillEffectExtsInfo()
	end
	
	local saveBtn = CCMenuItemFont:create("save")
	saveBtn:registerScriptTapHandler(save)
	menu:addChild(saveBtn)
	saveBtn:setPosition(ccp(480,120))
end


function GameSkillTestLayer.create(parentLayer)
	g_back_layer = CCLayer:create()
	parentLayer:addChild(g_back_layer)
	
	g_main_layer = CCLayer:create()
	parentLayer:addChild(g_main_layer)
	
	g_front_layer = CCLayer:create()
	parentLayer:addChild(g_front_layer)
	
	idLabel = CCLabelTTF:create("", "Arial", 24)
    g_main_layer:addChild(idLabel)
    idLabel:setPosition(ccp(480, 560))
	
	createMonsterSprite()
	createMonsterSelectBtn()
	
	createSkillEffect()
	createSkillEffectSelectBtn()
	
	local function onTouch(eventType, x, y)
        if eventType == "began" then   
             return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
	
	g_main_layer:registerScriptTouchHandler(onTouch)
    g_main_layer:setTouchEnabled(true)
end

--加载技能buff配置信息
function loadRoleAnimateInfo()
	local fileName = "animationframe_tplt.xml"
	local xmlTB = loadXmlFile(fileName)
	print("parse skill buff info")
	for k, v in pairs(xmlTB) do				-- 行
		local row = {}	
		for name, value in pairs(v) do		-- 列
			--print("name: "..name.." value "..value)
			if "id" == name then
				row.id = value	
			elseif "name" == name then
				row.name = value
			elseif "wait" == name then
				row.wait = value
			elseif "wait_frame" == name then
				row.wait_frame = value + 0
			elseif "attack" == name then
				row.attack = value 
			elseif "attack_frame" == name then
				row.attack_frame = value + 0	
			elseif "hited" == name then
				row.hited = value	
			elseif "hited_frame" == name then
				row.hited_frame = value + 0		
			end
		end	
		table.insert(g_Role_Animate_Info, row)
	end
	print("table g_Role_Animate_Info count>>"..#g_Role_Animate_Info)
end

loadRoleAnimateInfo()




