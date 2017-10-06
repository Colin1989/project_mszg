----------------------------------------------------------------------
-- 作者：lewis hamilton
-- 日期：2014-03-03
-- 描述：技能框
----------------------------------------------------------------------

local g_main_layer = nil
local g_frame_particle = nil
local g_particle_on = 0
local g_old_select_btn = -1
local maskSpriteSize
local g_btn_info = 
{
	{skillID = 0,	isPlayIconEffect = false,	iconSprite  = nil,	frameSprite = nil,	maskSprite = nil,	isCD = false,	isActive = false,},
	{skillID = 0,	isPlayIconEffect = false,	iconSprite  = nil,	frameSprite = nil,	maskSprite = nil,	isCD = false,	isActive = false,},
	{skillID = 0,	isPlayIconEffect = false,	iconSprite  = nil,	frameSprite = nil,	maskSprite = nil,	isCD = false,	isActive = false,},
	{skillID = 0,	isPlayIconEffect = false,	iconSprite  = nil,	frameSprite = nil,	maskSprite = nil,	isCD = false,	isActive = false,},
}

GameSkillBarLayer = {}

local function refreshBtn(idx, percentage)
	if idx < 0 or idx > 4 then 
		print("invalid btn idx") 
		return 
	end
	if percentage < 1.0 then
		--g_btn_info[idx].frameSprite:setVisible(false)
		g_btn_info[idx].maskSprite:setVisible(true)
		g_btn_info[idx].maskSprite:setTextureRect(CCRect(0, 0, maskSpriteSize.width, maskSpriteSize.height * (1.0 - percentage)))
		g_btn_info[idx].isCD = true
		g_btn_info[idx].isActive = false
		g_btn_info[idx].isPlayIconEffect = false
	else
		if g_btn_info[idx].isPlayIconEffect == false then
			--g_btn_info[idx].frameSprite:setVisible(false)
			Lewis:shaderSpriteResetTime(g_btn_info[idx].iconSprite)
			g_btn_info[idx].isPlayIconEffect = true
			function iconEffectCB(node)
				g_btn_info[idx].frameSprite:setVisible(true)
			end
			local action = CCSequence:createWithTwoActions(CCDelayTime:create(0.55), CCCallFuncN:create(iconEffectCB))	
			g_btn_info[idx].iconSprite:runAction(action)
		else
			g_btn_info[idx].frameSprite:setVisible(true)
		end
		g_btn_info[idx].maskSprite:setVisible(false)
		g_btn_info[idx].isCD = false
	end
	if g_particle_on > 0 then
		g_frame_particle:stopSystem()
		g_particle_on = 0
	end
end

local function createFrameParticle()
	if g_frame_particle ~= nil then return end
	g_frame_particle = Lewis:createSkillFrameParticle(350, maskSpriteSize)
	g_main_layer:addChild(g_frame_particle, 2)
	g_frame_particle:setAnchorPoint(ccp(0, 0))
end

local function unSelectSkillBtn(idx)
	g_btn_info[idx].isActive = false
	GameSkillMgr.activeSkillWithIndex(-1)
	g_old_select_btn = -1
	if g_frame_particle ~= nil then
		g_frame_particle:stopSystem()
		g_particle_on = 0
	end
end

local function selectSkillBtn(idx)
	if GameSkillMgr.activeSkillWithIndex(idx) then
		print("select auto start skill btn")
		return
	end
	g_btn_info[idx].isActive = true
	
	if g_old_select_btn > 0 then
		g_btn_info[g_old_select_btn].isActive = false
		GameSkillMgr.activeSkillWithIndex(-1)
		g_old_select_btn = -1
	end
	
	createFrameParticle()
	local frameSprite = g_btn_info[idx].frameSprite
	local x, y = frameSprite:getPosition()
	x = x - maskSpriteSize.width / 2
	y = y - maskSpriteSize.height / 2
	g_frame_particle:setPosition(x, y)
	if g_particle_on  == 0 then
		g_frame_particle:resetSystem()
	end
	g_particle_on = 1
	local colors = {ccc4f(0.76, 0.25, 0.72, 1.0), ccc4f(0.76, 0.25, 0.0, 1.0), ccc4f(0.26, 0.25, 0.92, 1.0), ccc4f(0.26, 0.25, 0.92, 1.0)}
	g_frame_particle:setStartColor(colors[idx])
	--setColor
	
	g_old_select_btn = idx
	print("select btn"..idx)
end

local g_frame_file_table = {"skillframe_purple.png", "skillframe_purple.png",}

local function refreshView()
	local function createControl()
		local menu = CCMenu:create()
		g_main_layer:addChild(menu)
		menu:setPosition(ccp(0, 0))
		
		local function menuCallbackSkillBtn(tag)	
			if (UIManager.UILayerNumber() > 0 ) then 
				return
			end
			
			if GameSceneHandleFight.isunControllable() then
				return
			end
		
			if g_btn_info[tag].isCD == false then
				if g_btn_info[tag].isActive == false then
					selectSkillBtn(tag)
				else
					unSelectSkillBtn(tag)
				end
			end
        end
		
		local x = 300
		local y = 70
		local skillCount = GameSkillMgr.getSkillCount()
		for i = 1, skillCount do
			local skillID = GameSkillMgr.getSkillIDWithIndex(i)
			local skillBaseInfo = GameSkillConfig.getSkillBaseInfo(skillID)
			if skillBaseInfo ~= nil then
			
				local frameFileName = g_frame_file_table[skillBaseInfo.frame_file_name]
				--button
				local btnSprite = CCSprite:createWithSpriteFrameName(frameFileName)
				btnSprite:setOpacity(0)
				local imageSprite = CCMenuItemSprite:create(btnSprite, nil)
				imageSprite:setPosition(x, y)
				imageSprite:registerScriptTapHandler(menuCallbackSkillBtn)
				menu:addChild(imageSprite, 0, i)
			
				--icon
				local iconFileName = skillBaseInfo.icon_file_name
				print("iconFileName "..iconFileName)
				local iconSprite = Lewis:createShaderSprite(skillBaseInfo.icon_file_name, "button_tips.fsh", false)--CCSprite:createWithSpriteFrameName(iconFileName)
				g_main_layer:addChild(iconSprite, 1)
				iconSprite:setPosition(x, y)
				g_btn_info[i].iconSprite = iconSprite
			
				--mask
				local maskSprite = CCSprite:create(iconFileName)	
				g_main_layer:addChild(maskSprite, 1)
				maskSpriteSize = maskSprite:getContentSize()
				--maskSprite:setTextureRect(CCRect(0, 0, maskSpriteSize.width, 50))
				maskSprite:setAnchorPoint(ccp(0, 0))
				maskSprite:setPosition(x - maskSpriteSize.width / 2, y - maskSpriteSize.height / 2)
				maskSprite:setColor(ccc3(0, 0, 0))
				maskSprite:setOpacity(192)
				maskSprite:setVisible(false)
				g_btn_info[i].maskSprite = maskSprite
			
				--frame
				local frameSprite = CCSprite:createWithSpriteFrameName(frameFileName)
				g_main_layer:addChild(frameSprite, 3)
				frameSprite:setPosition(x, y)
				g_btn_info[i].frameSprite = frameSprite
				
				g_btn_info[i].skillID = skillID
				
			end
			x = x + 110
		end
	end
	createControl()
end


function GameSkillBarLayer.create(parentLayer)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("skillframe.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("skillicon.plist")
	if g_main_layer ~= nil then
		g_main_layer:removeFromParentAndCleanup(true)
		g_main_layer = nil
		g_frame_particle = nil
	end
	g_main_layer = CCLayer:create()
	parentLayer:addChild(g_main_layer)
	refreshView()
end

function GameSkillBarLayer.updateBtn(idx, percentage)
	refreshBtn(idx, percentage)
end

function GameSkillBarLayer.refreshData()
	g_old_select_btn = -1
end

