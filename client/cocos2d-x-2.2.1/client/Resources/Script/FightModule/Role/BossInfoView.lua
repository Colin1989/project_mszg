--region BossInfoView.lua
--Author : Administrator
--Date   : 2014/10/22
--此文件由[BabeLua]插件自动生成

BossInfoView = class(MonsterInfoView)

local cell_width = FIGHT_GRID_WIDTHlocal cell_height = FIGHT_GRID_HEIGHT



function BossInfoView:ctor()
 
end 

function BossInfoView:setViewVisible(pRet)
    self.mRootView:setVisible(pRet)
end 

--创建怪物名字function BossInfoView:createName()	local name = self.mRole:getConfig("role_nick_name")	local color = ccc3(255, 255, 255)		--名字	local label = CommonFunc_createCCLabelTTF(ccp(0.5, 0.5), nil, nil, 30, color, name)	self.mRootView:addChild(label, 2)	label:setPosition(ccp(cell_width / 2, cell_height + 60))		--名字框	local bg = CCScale9Sprite:create("monster_name_bg.png")	self.mRootView:addChild(bg)	local size = label:getContentSize()	size.width = size.width + 20	bg:setCapInsets(CCRectMake(11,11,11,11))	bg:setPreferredSize(size)	bg:setAnchorPoint(ccp(0.5,0.5))    bg:setPosition(ccp(cell_width / 2, cell_height + 60))end
--BOSS buff Icon
function BossInfoView:initBuff()	--buff	local unit = self.mBuffView["buff"]	unit.labelPos 		= ccp(194, 80)	unit.labelScale		= 1.0	unit.startPos 		= ccp(cell_width / 2, cell_height / 2)	unit.iconPos		= ccp(cell_width + 40, cell_height - 120)	unit.iconScale 		= 1.0    unit.buffIconPos    = ccp(170, 80)    unit.bufficonScale 	= 1.5	--debuff	unit = self.mBuffView["debuff"]	unit.labelPos 		= ccp(194, 18)	unit.labelScale		= 1.0	unit.startPos 		= ccp(cell_width / 2, cell_height / 2)	unit.iconPos		= ccp(cell_width + 70, cell_height - 120)	unit.iconScale 		= 1.0    unit.buffIconPos    = ccp(170, 18)    unit.bufficonScale 	= 1.5	--;self:createBuffLabel()end

--攻击力视图function BossInfoView:createAttackLabel()	-- 攻击力图标	local sprite = CCSprite:createWithSpriteFrameName("monsterattack.png") 	self.mRootView:addChild(sprite)    sprite:setScale(1.5)	sprite:setPosition(ccp(cell_width * 0-60, -50))	sprite:setAnchorPoint(ccp(0.5, 0.0))		--攻击力数字	local attribute = self.mRole.mData.mAttribute	local atk = attribute:getByIndex(2)	local label = CCLabelAtlas:create(string.format("%d", atk), "num_black.png", 24, 32, 48)	label:setScale(1.2)	label:setAnchorPoint(ccp(0.0, 0.0))	label:setPosition(ccp(12, 0))	label:setPosition(ccp(cell_width * 0.1-60, -50))    self.mRootView:addChild(label, 1)	self.mLabels[2] = label	self.mOriginals[2] = atkend

--类型图标function BossInfoView:createCategoryIcon()	local config = self.mRole:getConfig("role_config")	local iconType = config.type	if iconType == nil then return end	if iconType < 2 then return end	local sprite = CCSprite:createWithSpriteFrameName(string.format("monstersign_%d.png", iconType))	sprite:setPosition(ccp(0+27-67, cell_height - 44+61))    sprite:setScale(1.5)	self.mRootView:addChild(sprite)end

--生命条function BossInfoView:createLifeBar()	-- 背景	local bg = CCSprite:createWithSpriteFrameName("monsterlife.png")	self.mRootView:addChild(bg)	bg:setPosition(ccp(25, -45))	bg:setAnchorPoint(ccp(0.0, 0.0))	bg:setScale(2.0)	local progress = CCSprite:create("monsterlife2.png")	self.mRootView:addChild(progress)	progress:setPosition(ccp(25+3, -45+2))	progress:setAnchorPoint(ccp(0.0, 0.0))    progress:setScale(2.0)	self.mLifeBar = progressend
--技能进度条function BossInfoView:createSkillProgress()    local function playBreathLamp(node)
	    local array = CCArray:create()
	    array:addObject(CCFadeOut:create(0.2))
	    array:addObject(CCFadeIn:create(0.2))
        node:runAction(CCRepeatForever:create(CCSequence:create(array)))    end	local skill = self.mRole.mData.mSkill	local tb = skill:getTB()	local idx = 1      for key,value in pairs(tb) do         if value.isValid and value.maxCD > 0 then--只创建主动技能            --技能背景            local bgCircle = CCSprite:createWithSpriteFrameName("monster_skill_bg"..value.skill_classification..".png")            bgCircle:setPosition(ccp(cell_width-30+70, cell_height - 1.5*bgCircle:getContentSize().height*(key-1)-20+40))            self.mRootView:addChild(bgCircle)            self.mSkillCircleProgressTB[key] = bgCircle            bgCircle:setScale(1.5)            --技能背景冷却呼吸灯            local bgCircleLight = CCSprite:createWithSpriteFrameName("monsterwhite.png")            bgCircleLight:setPosition(ccp(cell_width-30+70, cell_height - 1.5*bgCircle:getContentSize().height*(key-1)-20+40))            self.mRootView:addChild(bgCircleLight)            self.mSkillCircleLightTB[key]=bgCircleLight            bgCircleLight:setVisible(false)            playBreathLamp(bgCircleLight)            bgCircleLight:setScale(1.5)            --技能数值	        local skill_label = CCLabelAtlas:create(string.format("%d", 10), "num_black.png", 24, 32, 48)            skill_label:setAnchorPoint(ccp(0.5,0.5))            skill_label:setPosition(ccp(cell_width-29+70, cell_height - 1.5*bgCircle:getContentSize().height*(key-1)-21+40))            self.mRootView:addChild(skill_label)            self.mSkillCircleNumberTB[key] = skill_label            skill_label:setScale(0.8)        end    endend
--endregion
