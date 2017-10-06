-------------------------------------
--作者：李慧琴
--说明：战斗失败界面
--时间：2014-2-28
-------------------------------------
LayerFightFailed = {}
LayerAbstract:extend(LayerFightFailed)

local mLayerFightFailedRoot = nil      --当前界面的根节点
local mResTimer = nil
local resCD = 0

local function resTimerOverCF(tm)
	mResTimer = nil
	if nil == mLayerFightFailedRoot then
		return
	end
	local resTimerLabel = tolua.cast(mLayerFightFailedRoot:getWidgetByName("Label_time"), "UILabel")
	resTimerLabel:setText(resCD)
	local sureBtn = tolua.cast(mLayerFightFailedRoot:getWidgetByName("sureBtn"), "UIButton")
	local sureWord = sureBtn:getChildByName("ImageView_188")
	Lewis:spriteShaderEffect(sureBtn:getVirtualRenderer(),"buff_gray.fsh",true)
	Lewis:spriteShaderEffect(sureWord:getVirtualRenderer(),"buff_gray.fsh",true)
	sureBtn:setTouchEnabled(false)
end

local function resTimerRunCF(tm)
	if resCD > 0 then
		resCD = resCD - 1
	end
	if nil == mLayerFightFailedRoot then
		return
	end
	local resTimerLabel = tolua.cast(mLayerFightFailedRoot:getWidgetByName("Label_time"), "UILabel")
	resTimerLabel:setText(resCD)
end

-- mResTimer = CreateTimer(1, resCD, resTimerRunCF, resTimerOverCF)
-- mResTimer.start()

local function getRecPrice()
	local times = FightDateCache.getData("fd_respawn_count")
	local ReCoverExpres = LogicTable.getExpressionRow(14)	--复活计算公式
	local valueTable = 
	{
		{name = "Times", value = times}
	}
	local price = ExpressionParse.compute(ReCoverExpres.expression, valueTable)
	return tonumber(price)
end 

local function Handle_req_reborn(resp)
	if nil == mLayerFightFailedRoot then
		return
	end
	if common_result["common_success"] == resp.result then
		UIManager.pop("UI_FightFailed")
		FightMgr.playerRespawn()
	end
end

local function btnClicks(typeName, widget)
	if "releaseUp" == typeName then
		if true == NetSendLoadLayer.isWaitMessage() then
			return
		end
		local widgetName = widget:getName()
		local gameMode = FightDateCache.getData("fd_game_mode")
		if widgetName == "equipStrong" then			--装备强化按钮
			if 0 == widget:getTag() then
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_EQIP_STREN)
				return
			end
			UIManager.pop("UI_FightFailed")	
			FightMgr.onExit()
			FightMgr.cleanup()
			LayerSmithMain.setIndex(1)
			LayerTipFunction.gotoTipFunction(1001)
		elseif widgetName == "jewelInset" then		--宝石镶嵌按钮
			if 0 == widget:getTag() then
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_GEM_INLAY)
				return
			end
			UIManager.pop("UI_FightFailed")	
			FightMgr.onExit()
			FightMgr.cleanup()
			LayerSmithMain.setIndex(2)
			LayerTipFunction.gotoTipFunction(1007)
		elseif widgetName == "skillUpgrate" then	--技能升级按钮
			if 0 == widget:getTag() then
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_SKILL)
				return
			end
			UIManager.pop("UI_FightFailed")	
			FightMgr.onExit()
			FightMgr.cleanup()
			LayerTipFunction.gotoTipFunction(1005)
		elseif widgetName == "potenceUpdate" then	--潜能升级按钮
			if 0 == widget:getTag() then
				CopyDelockLogic.showEnterTipByDelockInfo(LIMIT_HERO_STREN)
				return
			end
			UIManager.pop("UI_FightFailed")	
			FightMgr.onExit()
			UIManager.retrunMain()
			LayerTipFunction.gotoTipFunction(1004)
		elseif widgetName == "goddessBless" then	--女神祝福按钮
			UIManager.pop("UI_FightFailed")	
			FightMgr.onExit()
			FightMgr.cleanup()
			UIManager.retrunMain()
			LayerTipFunction.gotoTipFunction(1018)
		elseif widgetName == "equipPuton" then		-- 更换装备按钮
			UIManager.pop("UI_FightFailed")	
			FightMgr.onExit()
			FightMgr.cleanup()
			LayerBackpack.returnEquipUI()
		elseif "sureBtn" == widgetName then			--弹出金币购买界面  
			if gameMode ~= 3 then
				local function SendCancle()
					mResTimer.pause(false)
				end
				local function SendReBorn()
					if CommonFunc_payConsume(2, getRecPrice()) then
						return
					end
					if UIManager.getTopLayerName() == "UI_ComfirmDialog" then
						UIManager.pop(UIManager.getTopLayerName())
					end
					local tb = req_reborn()
					tb.type = FightDateCache.getRebornType()
					cclog("ChannelProxy.setUmsAgentEvent-------->STAT_RESPAWN")
					ChannelProxy.setUmsAgentEvent("STAT_RESPAWN")
					NetHelper.sendAndWait(tb, NetMsgType["msg_notify_reborn_result"])
				end
				local structConfirm = 
				{
					strText = GameString.get("buyLife", getRecPrice(), FightDateCache.getData("fd_respawn_count")+1),
					buttonCount = 2,
					isPop = false,
					buttonName = {GameString.get("sure"), GameString.get("cancle")},
					buttonEvent = {SendReBorn, SendCancle},		--回调函数
					buttonEvent_Param = {nil, nil}			--函数参数
				}
				UIManager.push("UI_ComfirmDialog", structConfirm)
				mResTimer.pause(true)
			end
		elseif "cancalBtn" == widgetName then		--不复活
			if gameMode == 1 then
				FightEnd.stageFailEnd()
				FightMgr.onExit()
				FightMgr.cleanup()
				UIManager.pop("UI_FightFailed")
				UIManager.retrunMain("Fight_fail")
			elseif gameMode == 2 then				--活动副本
				UIManager.pop("UI_FightFailed")		
				FightEnd.gameSettle(map_settle_result["map_settle_died"])	--推塔死亡,结算方式
			elseif gameMode == 6 then
				FightEnd.activityCopyEnd(2)
				FightMgr.onExit()
				FightMgr.cleanup()
				UIManager.pop("UI_FightFailed")
				UIManager.retrunMain("Fight_fail")
			end
		end
	end
end

--预先加载32图
LayerFightFailed.loadResource = function()
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:addImage("fight_background_02.png")
end

-- 初始化
LayerFightFailed.init = function(bundle)
    mLayerFightFailedRoot = UIManager.findLayerByTag("UI_FightFailed")
	Audio.playEffectByTag(2)
	--副本名
	-- local mode = FightDateCache.getData("fd_game_mode")
	-- local copyBg = tolua.cast(mLayerFightFailedRoot:getWidgetByName("ImageView_46"), "UIImageView")
	-- local copyName = tolua.cast(copyBg:getChildByName("Label_47"), "UILabel")
	-- local curCopyId = FightDateCache.getData("fd_copy_id")
	-- if 1 == mode then
		-- local copyInfo = LogicTable.getCopyById(curCopyId)
		-- copyName:setText(copyInfo.name)
	-- elseif 2 == mode then
		-- copyName:setText(GameString.get("Public_Tower"))
	-- end
	-- 是否显示三星
	-- local threeStarBg = tolua.cast(mLayerFightFailedRoot:getWidgetByName("ImageView_42"), "UIImageView")
	-- local loseTip = tolua.cast(mLayerFightFailedRoot:getWidgetByName("ImageView_179"), "UIImageView")
	-- if 6 == mode then
		-- threeStarBg:setVisible(false)
		-- loseTip:setVisible(true)
		-- local activityCopyRow = LogicTable.getActivityCopyRow(curCopyId)
		-- copyName:setText(activityCopyRow.name)
	-- else
		-- loseTip:setVisible(false)
		-- threeStarBg:setVisible(true)
	-- end
	--装备强化按钮
    local equipStrong = tolua.cast(mLayerFightFailedRoot:getWidgetByName("equipStrong"), "UIImageView")
    equipStrong:registerEventScript(btnClicks)
	local equipStrongMask = tolua.cast(mLayerFightFailedRoot:getWidgetByName("equipStrongMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_EQIP_STREN.copy_id) then
		equipStrong:setTag(1)
		equipStrongMask:setVisible(false)
	else
		equipStrong:setTag(0)
		equipStrongMask:setVisible(true)
	end
	--宝石镶嵌按钮
    local jewelInset = tolua.cast(mLayerFightFailedRoot:getWidgetByName("jewelInset"), "UIImageView")
    jewelInset:registerEventScript(btnClicks)
	local jewelInsetMask = tolua.cast(mLayerFightFailedRoot:getWidgetByName("jewelInsetMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_GEM_INLAY.copy_id) then
		jewelInset:setTag(1)
		jewelInsetMask:setVisible(false)
	else
		jewelInset:setTag(0)
		jewelInsetMask:setVisible(true)
	end
	--技能升级按钮
    local skillUpgrate = tolua.cast(mLayerFightFailedRoot:getWidgetByName("skillUpgrate"), "UIImageView")
    skillUpgrate:registerEventScript(btnClicks)
	local skillUpgrateMask = tolua.cast(mLayerFightFailedRoot:getWidgetByName("skillUpdateMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_SKILL.copy_id) then
		skillUpgrate:setTag(1)
		skillUpgrateMask:setVisible(false)
	else
		skillUpgrate:setTag(0)
		skillUpgrateMask:setVisible(true)
	end
	--潜能升级按钮
	local potentUp = tolua.cast(mLayerFightFailedRoot:getWidgetByName("potenceUpdate"), "UIImageView")
    potentUp:registerEventScript(btnClicks)
	local potentUpMask = tolua.cast(mLayerFightFailedRoot:getWidgetByName("potenceUpdateMask"), "UIImageView")
	if true == CopyDelockLogic.judgeYNEnterById(LIMIT_HERO_STREN.copy_id) then
		potentUp:setTag(1)
		potentUpMask:setVisible(false)
	else
		potentUp:setTag(0)
		potentUpMask:setVisible(true)
	end
	--女神祝福按钮
	local goddessBless = tolua.cast(mLayerFightFailedRoot:getWidgetByName("goddessBless"), "UIImageView")
    goddessBless:registerEventScript(btnClicks)
	local goddessBlessMask = tolua.cast(mLayerFightFailedRoot:getWidgetByName("goddessBlessMask"), "UIImageView")
	goddessBlessMask:setVisible(false)
	--更换装备按钮
	local equipPuton = tolua.cast(mLayerFightFailedRoot:getWidgetByName("equipPuton"), "UIImageView")
    equipPuton:registerEventScript(btnClicks)
	--为了防止事件穿透
    local panel = tolua.cast(mLayerFightFailedRoot:getWidgetByName("Panel_23"), "UILayout")
	panel:setTouchEnabled(true)
	--需要花费金币label
    local coinLabel = tolua.cast(mLayerFightFailedRoot:getWidgetByName("coinLabel"), "UILabel")
    coinLabel:setText(tostring(getRecPrice()))
	--是按钮(花费金币购买)
    local sureBtn = tolua.cast(mLayerFightFailedRoot:getWidgetByName("sureBtn"), "UIButton")
    sureBtn:registerEventScript(btnClicks)
	-- 复活倒计时
	resCD = FIGHT_FAILED_CD
	local resTimerLabel = tolua.cast(mLayerFightFailedRoot:getWidgetByName("Label_time"), "UILabel")
	resTimerLabel:setText(resCD)
	mResTimer = CreateTimer(1, resCD, resTimerRunCF, resTimerOverCF)
	mResTimer.start()
	--否按钮(不花费金币)
    local cancalBtn = tolua.cast(mLayerFightFailedRoot:getWidgetByName("cancalBtn"), "UIButton")
    cancalBtn:registerEventScript(btnClicks)
end

-- 销毁
LayerFightFailed.destroy = function()
	local root = UIManager.findLayerByTag("UI_FightFailed")
	if root then
		root:removeFromParentAndCleanup(true)
	end
	mLayerFightFailedRoot = nil
	if mResTimer ~= nil then
		mResTimer.stop()
	end
	mResTimer = nil
	resCD = 0
end

NetSocket_registerHandler(NetMsgType["msg_notify_reborn_result"], notify_reborn_result, Handle_req_reborn)
