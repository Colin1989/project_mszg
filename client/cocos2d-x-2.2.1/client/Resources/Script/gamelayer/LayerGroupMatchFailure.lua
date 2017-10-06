--region LayerGroupMatchFailure.lua
--Author : shenl
--Date   : 2015/1/21
LayerGroupMatchFailure = {}
LayerAbstract:extend(LayerGroupMatchFailure)



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
			UIManager.pop("UI_GroupMatchFailure")
			LayerTipFunction.gotoTipFunction(1001)
		elseif widgetName == "gemuse" then			--宝石镶嵌按钮
			if 0 == widget:getTag() then
				FightMgr.onExit()
				FightMgr.cleanup()
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_GEM_INLAY)
				return
			end
			UIManager.pop("UI_GroupMatchFailure")
			LayerTipFunction.gotoTipFunction(1007)
		elseif widgetName == "skillup" then			--技能升级按钮
			if 0 == widget:getTag() then
				FightMgr.onExit()
				FightMgr.cleanup()
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_SKILL)
				return
			end
			UIManager.pop("UI_GroupMatchFailure")
			LayerTipFunction.gotoTipFunction(1005)
		elseif widgetName == "potentup" then		--潜能升级按钮
			if 0 == widget:getTag() then
				FightMgr.onExit()
				FightMgr.cleanup()
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_HERO_STREN)
				return
			end
			UIManager.pop("UI_GroupMatchFailure")
			LayerTipFunction.gotoTipFunction(1004)
		elseif widgetName == "goddessbless" then	--女神祝福按钮
			UIManager.pop("UI_GroupMatchFailure")
			FightMgr.onExit()
			FightMgr.cleanup()
			UIManager.retrunMain()
			LayerTipFunction.gotoTipFunction(1018)
		elseif widgetName == "equipput" then		-- 更换装备按钮
			UIManager.pop("UI_GroupMatchFailure")	
			FightMgr.onExit()
			FightMgr.cleanup()
			LayerBackpack.returnEquipUI()
		elseif widgetName == "jjc_sure" then		--确定按钮
			FightMgr.onExit()
			FightMgr.cleanup()
			UIManager.pop("UI_GroupMatchFailure")
			UIManager.retrunMain(LayerGameRank, false)
		end
	end
end

-- 初始化
LayerGroupMatchFailure.init = function()
	local root = UIManager.findLayerByTag("UI_GroupMatchFailure")
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

end

-- 销毁
function LayerGroupMatchFailure.destroy()
	local root = UIManager.findLayerByTag("UI_JJCFailed")
	if root then
		root:removeFromParentAndCleanup(true)
	end
end

--endregion
