-------------------------------------
--作者：shenl
--说明：竞技场挑战失败界面
--时间：2014-3-19
-------------------------------------
LayerJJcFail = {}
LayerAbstract:extend(LayerJJcFail)

--预先加载32图
function LayerJJcFail.loadResource()
	--herochoose_bg_2.png
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_01.png")
end

local function btnClicks(typeName, widget)
	if "releaseUp" == typeName then
		local widgetName = widget:getName()
		FightMgr.onExit()
		FightMgr.cleanup()
		if widgetName == "equipup" then				--装备强化按钮
			if 0 == widget:getTag() then
				FightMgr.onExit()
				FightMgr.cleanup()
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_EQIP_STREN)
				return
			end
			UIManager.pop("UI_JJCFailed")
			LayerTipFunction.gotoTipFunction(1001)
		elseif widgetName == "gemuse" then			--宝石镶嵌按钮
			if 0 == widget:getTag() then
				FightMgr.onExit()
				FightMgr.cleanup()
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_GEM_INLAY)
				return
			end
			UIManager.pop("UI_JJCFailed")
			LayerTipFunction.gotoTipFunction(1007)
		elseif widgetName == "skillup" then			--技能升级按钮
			if 0 == widget:getTag() then
				FightMgr.onExit()
				FightMgr.cleanup()
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_SKILL)
				return
			end
			UIManager.pop("UI_JJCFailed")
			LayerTipFunction.gotoTipFunction(1005)
		elseif widgetName == "potentup" then		--潜能升级按钮
			if 0 == widget:getTag() then
				FightMgr.onExit()
				FightMgr.cleanup()
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_HERO_STREN)
				return
			end
			UIManager.pop("UI_JJCFailed")
			LayerTipFunction.gotoTipFunction(1004)
		elseif widgetName == "goddessbless" then	--女神祝福按钮
			UIManager.pop("UI_JJCFailed")
			FightMgr.onExit()
			FightMgr.cleanup()
			UIManager.retrunMain()
			LayerTipFunction.gotoTipFunction(1018)
		elseif widgetName == "equipput" then		-- 更换装备按钮
			UIManager.pop("UI_JJCFailed")	
			FightMgr.onExit()
			FightMgr.cleanup()
			LayerBackpack.returnEquipUI()
		elseif widgetName == "jjc_sure" then		--确定按钮
			FightMgr.onExit()
			FightMgr.cleanup()
			UIManager.pop("UI_JJCFailed")
			UIManager.retrunMain(LayerGameRank, false)
		end
	end
end

-- 初始化
LayerJJcFail.init = function(tb)
	local root = UIManager.findLayerByTag("UI_JJCFailed")
	-- 荣誉或分组积分图标
	local honorImage = tolua.cast(root:getWidgetByName("flag1"), "UIImageView")
	-- 战绩图标
	local zhanjiImage = tolua.cast(root:getWidgetByName("flag2"), "UIImageView")
	-- 获得荣誉
	local getrongyu = tolua.cast(root:getWidgetByName("Label_44"), "UILabel")
    getrongyu:setText(tostring(tb.coins))
	-- 获得积分
	local getscore = tolua.cast(root:getWidgetByName("Label_44_0"), "UILabel")
    getscore:setText(tostring(tb.point))
	-- 确认按钮
	local jjc_sure = tolua.cast(root:getWidgetByName("jjc_sure"), "UIImageView")
    jjc_sure:registerEventScript(btnClicks)
	-- 装备强化按钮
    local equipup = tolua.cast(root:getWidgetByName("equipup"), "UIImageView")
    equipup:registerEventScript(btnClicks)
	local equipupMask = tolua.cast(root:getWidgetByName("equipupMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_EQIP_STREN.copy_id) then
		equipup:setTag(1)
		equipupMask:setVisible(false)
	else
		equipup:setTag(0)
		equipupMask:setVisible(true)
	end
	-- 宝石镶嵌按钮
    local gemuse = tolua.cast(root:getWidgetByName("gemuse"), "UIImageView")
    gemuse:registerEventScript(btnClicks)
	local gemuseMask = tolua.cast(root:getWidgetByName("gemuseMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_GEM_INLAY.copy_id) then
		gemuse:setTag(1)
		gemuseMask:setVisible(false)
	else
		gemuse:setTag(0)
		gemuseMask:setVisible(true)
	end
	-- 技能升级按钮
    local skillup = tolua.cast(root:getWidgetByName("skillup"), "UIImageView")
    skillup:registerEventScript(btnClicks)
	local skillupMask = tolua.cast(root:getWidgetByName("skillupMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_SKILL.copy_id) then
		skillup:setTag(1)
		skillupMask:setVisible(false)
	else
		skillup:setTag(0)
		skillupMask:setVisible(true)
	end
	-- 潜能升级按钮
	local potentup = tolua.cast(root:getWidgetByName("potentup"), "UIImageView")
	potentup:setTouchEnabled(true)
    potentup:registerEventScript(btnClicks)
	local potentupMask = tolua.cast(root:getWidgetByName("potentupMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_HERO_STREN.copy_id) then
		potentup:setTag(1)
		potentupMask:setVisible(false)
	else
		potentup:setTag(0)
		potentupMask:setVisible(true)
	end
	-- 女神祝福按钮
	local goddessbless = tolua.cast(root:getWidgetByName("goddessbless"), "UIImageView")
    goddessbless:registerEventScript(btnClicks)
	local goddessblessMask = tolua.cast(root:getWidgetByName("goddessblessMask"), "UIImageView")
	goddessblessMask:setVisible(false)
	-- 更换装备按钮
	local equipput = tolua.cast(root:getWidgetByName("equipput"), "UIImageView")
    equipput:registerEventScript(btnClicks)
	--
	local gameMode = FightDateCache.getData("fd_game_mode")
	if gameMode == 3 then  	
		LayerGameRank.setChallengeMsg(false)
		honorImage:setVisible(true)
		zhanjiImage:setVisible(true)
	elseif gameMode == 5 then
        --先注释掉
        --[[
		local data1 = LogicTable.getRewardItemRow(tb.awards[1].temp_id)
		local data2 = LogicTable.getRewardItemRow(tb.awards[2].temp_id)
		
		local data1Name = LogicTable.getRewardTypeDate(data1.type).name
		local data2Name = LogicTable.getRewardTypeDate(data2.type).name
		
		local reWardDesp1 = tolua.cast(root:getWidgetByName("Label_43"), "UILabel")
		reWardDesp1:setText(GameString.get("PUBLIC_HUO_DE")..data1Name)
		
		local reWardDesp2 = tolua.cast(root:getWidgetByName("Label_43_0"), "UILabel")
		reWardDesp2:setText(GameString.get("PUBLIC_HUO_DE")..data2Name)
		
		getrongyu:setText(tostring(tb.awards[1].amount))
		getscore:setText(tostring(tb.awards[2].amount))
		
		honorImage:setVisible(false)
		zhanjiImage:setVisible(true)
        ]]--
	end
	--
end

-- 销毁
function LayerJJcFail.destroy()
	local root = UIManager.findLayerByTag("UI_JJCFailed")
	if root then
		root:removeFromParentAndCleanup(true)
	end
end

