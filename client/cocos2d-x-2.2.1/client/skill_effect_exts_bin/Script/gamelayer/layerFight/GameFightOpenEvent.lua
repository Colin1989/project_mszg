
local mGameEvent = XmlTable_load("event_tplt.xml") 
FigthEvent={}





FigthEvent.getGameEventDetailById = function(id)


	local EventinitDate = XmlTable_getRow(mGameEvent,"id",id)
		local initDate = {}
	for k, v in pairs(EventinitDate) do
		if "id" == v.name then
			initDate.id = v.value	
		elseif "type" == v.name then
			initDate.type = v.value
		elseif "skill" == v.name then
			initDate.skill = v.value
		elseif "number" == v.name then
			initDate.number = v.value
		elseif "icon" == v.name then
			initDate.icon = v.value
		end
	end
		print("事件eventType:",initDate.type)
	return initDate
end



--GridId 格子ID,id 事件ID
FigthEvent.Create =function(GridId,id)
	local  EventDate =  FigthEvent.getGameEventDetailById(id)
	if EventDate == nil then 
		cclog("事件ID不存在 策划填错了,错误ID：",id)
		return
	end
	local EventType =  tonumber(EventDate.type)
	--create gold
	local function createGoldInMap(GridId)
		FactoryGameSprite.createGoldInScene(GridId,EventDate.icon)
	end
	--create blood_bottle 
	local function createBloodBottleInMap(GridId)
		FactoryGameSprite.createBloodInScene(GridId,EventDate.icon)
	end
--[[
@ EventType 事件类型
1-金币，2-血瓶，3-陷阱，4-可点击友方，5-不可点击友方	
]]--
	local changeMapstatue = nil
	local otherDate = nil
	--EventType = 3
	if EventType == 1 then --gold
		createGoldInMap(GridId)
		changeMapstatue = g_Const_Sprite.Type.gold
		otherDate = tonumber(EventDate.number)
	elseif EventType == 2 then --Blood_bottle 
		createBloodBottleInMap(GridId)
		changeMapstatue = g_Const_Sprite.Type.blood 
		otherDate = tonumber(EventDate.skill)
		
	elseif EventType == 3 then --trap 陷阱ID
		changeMapstatue = g_Const_Sprite.Type.background  --中完陷阱 就设为 background??
		otherDate = nil
		FactoryGameSprite.createItem(GridId,nil,"trap")	--创建陷阱标记
		print("what the hell+++++++++++++++++++++++++++++++++"..EventDate.skill)
		propUseSkill("trap", EventDate.skill + 0, "propUseSkill")
		--local userData = {}
		--GameSkillMgr.makeUser
		--GameSkillMgr.startBuff(ModelPlayer.getPlayerNode(), 2)
	elseif EventType == 4 then 	
		
	elseif EventType == 5 then 
	
	end
	
	return changeMapstatue,otherDate
end

-- 点击金币
FigthEvent.HandleOnClickGold =function(Gridid,number)
	--date
	--cclog("获得金币：",number)
	FightDateCache.setcurReward("gold",number)
	--render
	GameUiLayer.updateGoldNum()
	local Itemnode = g_sceneRoot:getChildByTag(Gridid+mSpriteMask)
	FightAnimation_moveItem(Itemnode)
end

-- 点击血瓶
FigthEvent.HandleOnClickBlood =function(Gridid,skillid)
	--date 
	cclog("加血技能ID：",skillid)		--TOOD:加血走技能
	--render
	local Itemnode = g_sceneRoot:getChildByTag(Gridid+mSpriteMask)
	FightAnimation_moveItem(Itemnode)
	propUseSkill("blood_bottle", skillid + 0, "propUseSkill")
end

















