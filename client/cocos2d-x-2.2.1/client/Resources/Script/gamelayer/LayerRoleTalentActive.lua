----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-20
-- Brief:	天赋激活时的界面
----------------------------------------------------------------------
LayerRoleTalentActive ={}
local mRootNode = nil
local mBundle = nil
----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_RoleTalent_Active")
	end
end
-------------------------------------------------------------------------------
-- 点击升级按钮
local function clickLvUpBtn(typeName, widget)
	if "releaseUp" == typeName then
		TalentLogic.requestlelUpTalent(mBundle.talentId)
	end
end
----------------------------------------------------------------------
--点击显示碎片信息
local function iconClick(clickType,widget)
	if clickType ~= "releaseUp" then
		return
	end
	CommonFunc_showInfo(0, widget:getTag(), 0, nil, 1)
end
------------------------------------------------------------------
--加载升级的界面
local function addLevelUpUI(levelUpInfo,fragInfo)
--Log(fragInfo)	
	--升级碎片Icon
	local fragIcon = tolua.cast(mRootNode:getWidgetByName("Icon_frag"),"UIImageView")
	fragIcon:loadTexture(fragInfo.icon)	
	fragIcon:setTag(fragInfo.id)
	fragIcon:setTouchEnabled(true)
	fragIcon:registerEventScript(iconClick)
	Log(levelUpInfo.skill_piece_id,ModelSkill.getFragCount(tonumber(levelUpInfo.skill_piece_id)))
	--升级碎片数量
	local curFragNum = ModelSkill.getFragCount(tonumber(levelUpInfo.skill_piece_id))	  --当前的碎片数量
	local num = tolua.cast(mRootNode:getWidgetByName("num"),"UILabel")
	num:setText(string.format("%d/%d",curFragNum,levelUpInfo.skill_piece_num))
	if tonumber(curFragNum) < tonumber(levelUpInfo.skill_piece_num) then
		num:setColor(ccc3(255,0,0))
	end
end

--加载满级的界面
local function addLevelFullUI(curLevel,talentInfo)
	--图片上的等级
	local levelIcon = tolua.cast(mRootNode:getWidgetByName("level2_full"),"UILabelAtlas")	
	levelIcon:setStringValue(ModelSkill.getTalentLevel(mBundle.talentId))
	--图片
	local icon = tolua.cast(mRootNode:getWidgetByName("icon_full"),"UIImageView")	
	icon:loadTexture(talentInfo.icon)
end
----------------------------------------------------------------------
--加载公用的部分
local function addPub(curLevel,talentInfo)
	--图片上的等级
	local levelIcon = tolua.cast(mRootNode:getWidgetByName("level2"),"UILabelAtlas")	
	levelIcon:setStringValue(curLevel)
	--图片
	local icon = tolua.cast(mRootNode:getWidgetByName("icon"),"UIImageView")	
	icon:loadTexture(talentInfo.icon)
	--名字
	local name = tolua.cast(mRootNode:getWidgetByName("name"),"UILabel")	
	name:setText(talentInfo.name)
	--等级
	local level = tolua.cast(mRootNode:getWidgetByName("level"),"UILabel")	
	level:setText(curLevel)				
	--最高等级
	local maxLlevel = tolua.cast(mRootNode:getWidgetByName("max_level"),"UILabel")	
	maxLlevel:setText(GameString.get("Public_talent_maxLel",talentInfo.max_level))
	
	--根据id所在层和等级，查找需要的碎片
	if  string.len(curLevel) == 1 then
		curLevel = tostring(0)..curLevel
	end
	curLevel = tonumber(talentInfo.level_up_id..curLevel)
	
	local levelUpInfo = LogicTable.getTalentlelUpTableRow(curLevel)
	local fragInfo = SkillConfig.getSkillFragInfo(levelUpInfo.skill_piece_id)
	--描述（当前等级的）
	local curInfo = LogicTable.getTalentlelUpTableRow(curLevel)
	local des = tolua.cast(mRootNode:getWidgetByName("des"),"UILabel")
	des:setTextAreaSize(CCSizeMake(350, 70))
	des:setText(levelUpInfo.describe)
	
	
	--升级按钮
	local levelUpBtn = tolua.cast(mRootNode:getWidgetByName("levelup"), "UIButton")			-- 关闭按钮
	--满级的panel
	local fullPanel = tolua.cast(mRootNode:getWidgetByName("Panel_full"),"UILayout")	
	--可升级的panel
	local levelUpPanel = tolua.cast(mRootNode:getWidgetByName("Panel_lelUp"),"UILayout")
	levelUpBtn:registerEventScript(clickLvUpBtn)
	if  tonumber(ModelSkill.getTalentLevel(mBundle.talentId)) >= tonumber(talentInfo.max_level) then
		fullPanel:setVisible(true)
		levelUpPanel:setVisible(false)
		levelUpBtn:setTouchEnabled(false)
		addLevelFullUI(curLevel,talentInfo)
		local fragIcon = tolua.cast(mRootNode:getWidgetByName("Icon_frag"),"UIImageView")
		fragIcon:setTouchEnabled(false)
	else
		fullPanel:setVisible(false)
		levelUpPanel:setVisible(true)
		levelUpBtn:setTouchEnabled(true)
		
		addLevelUpUI(levelUpInfo,fragInfo)
	end	
end
--------------------------------------------------------------------------
--设置UI界面
local function  setUI()
	if mRootNode == nil then
		return
	end
	
	local talentInfo = LogicTable.getTalentTableRow(mBundle.talentId)
	local curLevel = ModelSkill.getTalentLevel(mBundle.talentId)		
	addPub(curLevel,talentInfo)
end
-------------------------------升级动画----------------------------------
--计算偏离位置
local function calOffsetPos(raduis, angle)
	angle = angle / 180.0 * 3.14
	local x = math.sin(angle) * raduis
	local y = math.cos(angle) * raduis
	return ccp(x, y)
end

local function removeSelf(node)
	node:removeFromParentAndCleanup(true)
end

--widget从一个地方飞到另外一个地方的动画
LayerRoleTalentActive.widgetFlyAction = function(startWidget,endWidget,rootNode)
	if rootNode == nil then
		return
	end
	local fromPos = startWidget:getWorldPosition()
	local destPos = endWidget:getWorldPosition()
	
	local total = math.random(7, 24)
	local delayTime = 0.0
	local moveTime = 0.6
	
	startWidget:stopAllActions()
	endWidget:stopAllActions()
	--local btnParticle = CCParticleSystemQuad:create("effect_045.plist")
	--print(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("effect_045_01.png"))
	--local  textrue = CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("effect_045.plist");  

	for i = 1, total do
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("effect_077.plist")
		local sprite = CCSprite:createWithSpriteFrameName("effect_077_07.png")
		--local sprite = CCSprite:createWithSpriteFrameName("effect_045_01.png")		--eff_white_star.png
		--local sprite = CCSprite:create("eff_white_star.png")
		rootNode:addChild(sprite,100)
		
		local offsetPos = calOffsetPos(math.random(60, 90), math.random(0, 360))
		local arr = CCArray:create()
		arr:addObject(CCHide:create())
		arr:addObject(CCDelayTime:create(delayTime))
		arr:addObject(CCShow:create())
		arr:addObject(CommonFunc_curMoveAction(moveTime, fromPos, destPos))
		arr:addObject(CCCallFuncN:create(removeSelf))
		sprite:runAction(CCSequence:create(arr))
		
		local delta = math.random(8, 14) / 100
		delayTime = delayTime + delta
		moveTime = moveTime - delta / 3
	end
end

-- 升级的动画					
local  function lvUpAction()
	if nil == mRootNode then
		return
	end
	--白图片
	local whiteIcon = tolua.cast(mRootNode:getWidgetByName("whiteIcon"),"UIImageView")
	--闪光图片
	local blinkIcon = tolua.cast(mRootNode:getWidgetByName("blinkIcon"),"UIImageView")
	--icon上的白图片
	local blinkWhiteIcon = tolua.cast(mRootNode:getWidgetByName("icon_blink_white"),"UIImageView")
	
	--出现白色图片
	local show = CCShow:create()
	local fadeIn = CCFadeIn:create(0.3)				
	local come = CCSpawn:createWithTwoActions(show,fadeIn)
	--消失白色图片飞粒子
	local function fly()
		LayerRoleTalentActive.widgetFlyAction(whiteIcon,blinkIcon,mRootNode)
	end
	
	--local fadeOut = CCFadeOut:create(0.1)	
	local hide = CCHide:create()
	local out = CCSpawn:createWithTwoActions(hide,CCCallFuncN:create(fly))
	
	--显示升级成功
	local function lvUpScu()
		Toast.Textstrokeshow(GameString.get("Public_talent_lelup"), ccc3(255,255,255), ccc3(0,0,0), 30)
	end
	
	--黄光渐现渐出
	local function blinkAction()
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(1.3))
		arr:addObject(CCShow:create())
		arr:addObject(CCFadeIn:create(0.5))
		arr:addObject(CCFadeOut:create(1.0))
		arr:addObject(CCCallFuncN:create(lvUpScu))
		blinkIcon:runAction(CCSequence:create(arr))
	end
	
	--icon上的白光出现再消失
	local function iconWhiteAction()
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(1.0))
		arr:addObject(CCShow:create())
		arr:addObject(CCFadeIn:create(0.5))
		arr:addObject(CCFadeOut:create(0.5))
		blinkWhiteIcon:runAction(CCSequence:create(arr))
	end
	
	--白图片渐现，粒子飞上去（白图片消失），粒子消失的同时,icon上的白光出现再消失（闪现黄光），黄光渐弱，提示升级成功
	local arr = CCArray:create()
	arr:addObject(come)
	arr:addObject(CCDelayTime:create(0.3))
	arr:addObject(out)
	arr:addObject(CCCallFuncN:create(iconWhiteAction))
	arr:addObject(CCCallFuncN:create(blinkAction))
	whiteIcon:runAction(CCSequence:create(arr))
end
----------------------------------------------------------------------
-- 初始化
LayerRoleTalentActive.init = function(bundle)
	mRootNode = UIManager.findLayerByTag("UI_RoleTalent_Active")
	mBundle = bundle
	--关闭按钮
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("close"), "UIButton")			-- 关闭按钮
	closeBtn:registerEventScript(clickCloseBtn)
	
	

	setUI()

	--lvUpAction()		--测试
end
----------------------------------------------------------------------
-- 销毁
LayerRoleTalentActive.destroy = function()
	mRootNode = nil
end
----------------------------------------------------------------------

EventCenter_subscribe(EventDef["ED_ROLETALENT_LEVELUP"], setUI)
EventCenter_subscribe(EventDef["ED_ROLETALENT_LEVELUP"], lvUpAction)
