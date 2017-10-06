ModelMonster = {}

local mMonster_date = XmlTable_load("monster_tplt.xml") 
ModelMonster.getMonsterById= function(id)
	local res = XmlTable_getRow(mMonster_date, "id", id)
	local monster = {}
	for k, v in pairs(res) do
		if "id" == v.name then
			monster.id = v.value	
		elseif "name" == v.name then
			monster.name = v.value
		elseif "icon" ==	v.name then
			monster.icon = v.value + 0
		elseif "level" == v.name then
			monster.level = v.value + 0	
		elseif "type" == v.name then
			monster.type = v.value + 0	
		elseif "attack_type" == v.name then
		    monster.attack_type = v.value + 0
		elseif "relative_id" == v.name then 
			monster.relative_id = XmlTable_stringSplit(v.value,",")
		elseif "life" == v.name then
			monster.life = v.value + 0		 			
		elseif "atk" == v.name then
			monster.atk = v.value + 0 
		elseif "speed" == v.name then
			monster.speed = v.value + 0		 
		elseif "hit_ratio" == v.name then
			monster.hit_ratio = v.value + 0		
		elseif "critical_ratio" == v.name then
			monster.critical_ratio = v.value + 0		
		elseif "miss_ratio" == v.name then
			monster.miss_ratio = v.value + 0		
		elseif "tenacity" == v.name then
			monster.tenacity = v.value + 0	 				
		elseif "skills" == v.name then
			monster.skills = v.value + 0
		elseif "fly_effect_id" == v.name then
			monster.fly_effect_id = v.value + 0
		elseif "front_effect_id" == v.name then
			monster.front_effect_id = v.value + 0
		elseif "back_effect_id" == v.name then
			monster.back_effect_id = v.value + 0
		end
	end
	
	return monster
end
ModelMonster.initEnemyAttr =function(_date)
	for key2 ,value2 in pairs(_date.sculpture) do
		cclog("init _date2",key2 ,"value2---------->",value2)
	end


	local ememy = {}
	for k,v in pairs (_date) do
		cclog("_- 初始化！！！！！！！！！！！！敌人！！！！！！！！！",k,"((((((",v)
		ememy[k] = v
	end
	--FIXME 技能
	cclog("sculpture-------->" ,type(ememy.sculpture))
	for key,value in pairs(ememy.sculpture) do
		cclog("init Arrt",key,"value---------->",value)
	end
	
	return ememy
end
--是否是主动怪
ModelMonster.isInitiativeMonster = function(id)
	local monster = ModelMonster.getMonsterById(id)
	if monster.attack_type == 1 then
		return true
	end
	return false
end
---是否有涉及关联怪
ModelMonster.isRelaMonster = function(id)
	local monster = ModelMonster.getMonsterById(id)
	if type(monster.relative_id) == "table" then
		if monster.relative_id[1] == "0" then
			print ("没有关联怪")
			return nil
		else
			print ("有关联怪")
			return monster.relative_id
		end
	end
end


ModelMonster.initArrRender = function(monster,Date)
	local arrBatchNode = CCSpriteBatchNode:create("monsterArr.png",10)
	local posX,posY = monster:getPosition()
	
	-- attackicon 
	local sprite = FactoryGameSprite.createSpriteByPlist("monsterattack.png") 
	arrBatchNode:addChild(sprite)
	-- lifeicon
	local lifeIcon = FactoryGameSprite.createSpriteByPlist("monsterlife.png")
	lifeIcon:setPosition(ccp(CELLSIZE_WIDTH,0))
	arrBatchNode:addChild(lifeIcon)
	-- bossicon
	if Date.type == 2 then --银冠怪
		local BossIcon = FactoryGameSprite.createSpriteByPlist("monsterAglv.png")
		BossIcon:setPosition(ccp(CELLSIZE_WIDTH,CELLSIZE_HEIGHT))
		arrBatchNode:addChild(BossIcon)
	elseif Date.type == 3 then --金冠怪
		local BossIcon = FactoryGameSprite.createSpriteByPlist("monsterGoldlv.png")
		BossIcon:setPosition(ccp(CELLSIZE_WIDTH,CELLSIZE_HEIGHT))
		arrBatchNode:addChild(BossIcon)	
	end

	--progressbg
	local progressbg = FactoryGameSprite.createSpriteByPlist("monsterBarBg.png") 
	progressbg:setPosition(ccp(CELLSIZE_WIDTH/2,0))
	if Date.skillCDProgress == nil then
		progressbg:setVisible(false)
	else
		progressbg:setVisible(true)
	end
	arrBatchNode:addChild(progressbg)
	
	arrBatchNode:setPosition(ccp(posX - CELLSIZE_WIDTH/2,posY))
	arrBatchNode:setTag(Date.pos + mSpriteUIMask)
	g_sceneRoot:addChild(arrBatchNode,g_Const_GameLayer.sceneChildLayer.sprite+Date.pos+1)
	
	--skill progress (update)
	local progress = CCSprite:create("monsterBar.png")
	local Texture = progress:getTexture()
	local w =Texture:getContentSize().width;
	local h =Texture:getContentSize().height;

	progress:setPosition(ccp(posX -w/2,posY- h/2))
	progress:setAnchorPoint(ccp(0,0))
	progress:setTag(Date.pos+mSpriteProgressMask)
	progress:setVisible(true)
	g_sceneRoot:addChild(progress,g_Const_GameLayer.sceneChildLayer.sprite+Date.pos+1)
		
	--atk font (update)
	local atkNumber = FactoryGameSprite.createNumberFont(Date.atk)
	atkNumber:setPosition(ccp(posX - CELLSIZE_WIDTH/4 ,posY))
	atkNumber:setTag(Date.pos+mSpriteAktFontMask)
    g_sceneRoot:addChild(atkNumber,g_Const_GameLayer.sceneChildLayer.sprite+Date.pos+1)
	
	--life font (upadate)
	local liftNumber = FactoryGameSprite.createNumberFont(Date.life)
	liftNumber:setPosition(ccp(posX + CELLSIZE_WIDTH/2 ,posY))
	liftNumber:setAnchorPoint(ccp(1,0.5))
	liftNumber:setTag(Date.pos+mSpriteLifeFontMask)
    g_sceneRoot:addChild(liftNumber,g_Const_GameLayer.sceneChildLayer.sprite+Date.pos+1)
end

-- 怪物更新展示
ModelMonster.updateDate = function(curArr, restoreArr)
	--update LeftLife
	local lifefont = g_sceneRoot:getChildByTag(curArr.pos + mSpriteLifeFontMask)
	tolua.cast(lifefont,"CCLabelBMFont")
	lifefont:setString(curArr.life)
	--update LeftAtk
	local atkfont = g_sceneRoot:getChildByTag(curArr.pos + mSpriteAktFontMask)
	tolua.cast(atkfont,"CCLabelBMFont")
	atkfont:setString(curArr.atk)
	if curArr.atk > restoreArr.atk then
		atkfont:setColor(ccc3(0, 255, 0))
	elseif curArr.atk < restoreArr.atk then
		atkfont:setColor(ccc3(255, 0, 0))
	else
		atkfont:setColor(ccc3(255, 255, 255))
	end
	
	local progress = g_sceneRoot:getChildByTag(curArr.pos + mSpriteProgressMask)
	tolua.cast(progress,"CCSprite")
	if curArr.skillCDProgress == nil then
		progress:setVisible(false)
		return
	end
	progress:setVisible(true)
	local Texture = progress:getTexture()
	local w =Texture:getContentSize().width;
	local h =Texture:getContentSize().height;
	progress:setTextureRect(CCRectMake(0, 0, w * curArr.skillCDProgress, h))
end

local frame_speed = 1.0 / 18.0

-- 切换被击打动作
function switchActionToHited(node,resid,callback_func)
	--local monsterAttr = getMonsterDefineAttrById(resid)
	local role_Ani = ResourceManger.getAnimationFrameById(resid)
	local str = string.format("%s_%s",role_Ani.name,role_Ani.hited).."_%03d.png"
	--local str = string.format("monster%d_%s",resid,"hited").."_%03d.png"
	tolua.cast(node,"CCSprite")
	node:stopAllActions()
	local anisentemation = createAnimation(str,role_Ani.hited_frame, 0.1)
	local action = CCSequence:createWithTwoActions(CCAnimate:create(anisentemation),CCCallFuncN:create(callback_func))	
	node:runAction(action)	
end


-- 切换攻击动作
function switchActionToAttack(node,resid,callback_func)
	--local monsterAttr = getMonsterDefineAttrById(resid)
	--local str = string.format("monster%d_%s",resid,"attack").."_%03d.png"
	local role_Ani = ResourceManger.getAnimationFrameById(resid)
	local str = string.format("%s_%s",role_Ani.name,role_Ani.attack).."_%03d.png"
	tolua.cast(node,"CCSprite")
	node:stopAllActions()
	local animation = createAnimation(str,role_Ani.attack_frame, frame_speed)
	local action = CCSequence:createWithTwoActions(CCAnimate:create(animation),CCCallFuncN:create(callback_func))	
	node:runAction(action)	
end

--切换成使用技能动作
function switchActionToUseSkill(node, resid, effectFrameIdx, callback_EffectFrame, callback_ActionDone)
	local role_Ani = ResourceManger.getAnimationFrameById(resid)
	local str = string.format("%s_%s",role_Ani.name,role_Ani.attack).."_%03d.png"
	tolua.cast(node,"CCSprite")
	node:stopAllActions()
	local animation = createAnimation(str,role_Ani.attack_frame, frame_speed)
	local action = CCSequence:createWithTwoActions(CCAnimate:create(animation),CCCallFuncN:create(callback_ActionDone))	
	node:runAction(action)
	
	node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(effectFrameIdx * 0.07), CCCallFuncN:create(callback_EffectFrame)))
end

-- 切换待机动作
function switchActionToWait(node,resid)
	--local monsterAttr = getMonsterDefineAttrById(resid)
	--local str = string.format("monster%d_%s",resid,"wait").."_%03d.png"
	local role_Ani = ResourceManger.getAnimationFrameById(resid)
	local str = string.format("%s_%s",role_Ani.name,role_Ani.wait).."_%03d.png"
	
	
	tolua.cast(node,"CCSprite")
	node:stopAllActions()
	local animation = createAnimation(str,role_Ani.wait_frame,0.1)
	node:runAction(CCRepeatForever:create(CCAnimate:create(animation))) 	
end

--获取技能加成 后的属性
--posid 位置ID BonusType 加成类型;bonusNum 加成数值 bonusNum 
ModelMonster.getSkillBonus =function(posid,BonusType,bonusNum)
	local AttrTb =  CommonFunc_table_copy_table( getDetailMonsterByPosId(posId) )

	if type(BonusType) == "string" then 
		AttrTb[BonusType] = v[BonusType] + bonusNum -- 加成计算 按需求改
		return AttrTb
	end

	if type(BonusType) == "table" then 
		for k,bonus_Num in pairs(bonusNum) do
			AttrTb[k] = bonus_Num + AttrTb[k]	-- 加成计算 按需求改
		end
		return AttrTb
	end
	print("传入参数有误类型")
	return nil
end

