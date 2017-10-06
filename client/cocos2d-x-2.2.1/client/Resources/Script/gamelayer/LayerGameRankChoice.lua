--/**
-- *  @Brief: 竞技场入口选择
-- *  @Created by fjut on 14-03-12
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerGameRankChoice = {}
local rootNode = nil

-- 5个图片按钮
local tbBtn = {"btn_pws", "btn_xls", "btn_fenzu", "btn_jx", "btn_jssc", "btn_ckly", "btn_xzqh"}

 -- 图片点击响应
local function imgCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	local name = sender:getName()
	-- 排位赛
	if name == tbBtn[1]then 
		if tonumber(LIMIT_RANK_GAME.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_RANK_GAME.copy_id) ~= "pass"  then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_RANK_GAME.copy_id),LIMIT_RANK_GAME.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerGameRank, "GameRank_1.json", name)
	-- 训练赛
	elseif name == tbBtn[2] then
		if tonumber(LIMIT_TRAIN_GAME.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_TRAIN_GAME.copy_id) ~= "pass"  then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_TRAIN_GAME.copy_id),LIMIT_TRAIN_GAME.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerGameTrain, "GaneTrain_1.json", name)
	-- 军衔
	elseif name == tbBtn[4] then
		-- setConententPannelJosn(LayerMiltitary, "MilitaryPanel.json", name)
	-- 竞技商城
	elseif name == tbBtn[5] then
		if tonumber(LIMIT_CHAL_SHOP.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_CHAL_SHOP.copy_id) ~= "pass"  then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_CHAL_SHOP.copy_id),LIMIT_CHAL_SHOP.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		setConententPannelJosn(LayerScoreShopMall, "GameRankShopMall_1.json", name)
	-- 天梯分组赛
	elseif name == tbBtn[3] then
		if tonumber(LIMIT_LADDERMATCH.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_LADDERMATCH.copy_id) ~= "pass"  then
			Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_LADDERMATCH.copy_id),LIMIT_LADDERMATCH.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			return
		end
		-- setConententPannelJosn(ladderMatch, "ladderMatch_1.json", name)
		setConententPannelJosn(LayerGameMatch, "GameMatch_1.json", name)
	-- 竞技物品兑换
	elseif name == tbBtn[6] then
		-- if tonumber(LIMIT_CHAL_CONVERT.copy_id) ~= 1 and CopyDateCache.getCopyStatus(LIMIT_CHAL_CONVERT.copy_id) ~= "pass"  then
			-- Toast.Textstrokeshow(GameString.get("Public_Pass_Copy",CopyDelockLogic.showNumberFBQById(LIMIT_CHAL_CONVERT.copy_id),LIMIT_CHAL_CONVERT.fbName), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
			-- return
		-- end
		-- setConententPannelJosn(LayerCommodityConvert, "CommodityConvert.json", name)
	-- 勋章强化
	elseif name == tbBtn[7] then
		if LayerGameMedal.getMedalId() == nil then
			Toast.show(GameString.get("GAME_MEDAL_TIP_3"))
			return
		end
		setConententPannelJosn(LayerGameMedal, "GameMedal_1.json", name)
	end
end

 -- 图片点击响应
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	TipModule.onClick(sender)
	if sender:getName() == "btn_close" then
		LayerMain.pullPannel(LayerGameRankChoice)
	elseif sender:getName() == "btn_add" then 
		cclog("btn_add")
	elseif sender:getName() == "btn_getReward" then 
		cclog("btn_getReward")
	end
end

-- 初始化静态UI
local function initUI()
	-- 图片点击Event
	for i = 1, #(tbBtn), 1 do
		local btn = rootNode:getChildByName(tbBtn[i])
		btn:registerEventScript(imgCall)
	end
	--分组赛是否有新信息
	-- local  b3 = ladderMatchfenzu.isShowTip()
	-- if b3  then
		-- local imgFlag = CommonFunc_getImgView("qipaogantanhao.png")
		-- imgFlag:setPosition(ccp(85, 25))
		-- local node = rootNode:getChildByName(tbBtn[3])
		-- node:addChild(imgFlag)
	-- end

	-- 训练赛是否还有礼包未领取或挑战次数未用完
	local b1 = LayerGameTrain.getIsRewardCanGet()
	if b1 and CopyDelockLogic.judgeYNEnterById(LIMIT_TRAIN_GAME.copy_id)== true then
		local imgFlag = CommonFunc_getImgView("qipaogantanhao.png")
		imgFlag:setPosition(ccp(85, 25))
		local node = rootNode:getChildByName(tbBtn[2])
		node:addChild(imgFlag)
	end
	
	-- 排位赛奖励是否可以领取
	local b2 = LayerGameRank.getIsRewardCanGet()
	-- 排位赛消息数量
	local numTips = LayerMainEnter.getMsgTipsNum()
	if b2 or numTips > 0 and CopyDelockLogic.judgeYNEnterById(LIMIT_RANK_GAME.copy_id)== true then
		local imgFlag = CommonFunc_getImgView("qipaogantanhao.png")
		imgFlag:setPosition(ccp(85, 25))
		local node = rootNode:getChildByName(tbBtn[1])
		node:addChild(imgFlag)
	end
	
	-- 竞技兑换是否可以兑换
	-- local b6 = LayerCommodityConvert.isShowTip()
	-- if b6 then
		-- local imgFlag = CommonFunc_getImgView("qipaogantanhao.png")
		-- imgFlag:setPosition(ccp(85, 25))
		-- local node = rootNode:getChildByName(tbBtn[6])
		-- node:addChild(imgFlag)
	-- end
	
	-- 勋章是否可以强化或者进阶
	local b7 = LayerGameMedal.isStrengthShowTip()		-- 勋章是否可以强化
	local b8 = LayerGameMedal.isUpgradeShowTip()		-- 勋章是否可以进阶
	if b7 or b8 then
		local imgFlag = CommonFunc_getImgView("qipaogantanhao.png")
		imgFlag:setPosition(ccp(85, 25))
		local node = rootNode:getChildByName(tbBtn[7])
		node:addChild(imgFlag)
	end
	
	-- 关闭btn event
	local btnClose = rootNode:getChildByName("btn_close")
    btnClose:registerEventScript(btnCall)
	-- 军衔
	-- local miltitaryName = GameString.get("PUBLIC_NONE")
	-- if MiltitaryLogic.getMiltitaryLevel() > 0 then
		-- local miltitaryRankRow = LogicTable.getMiltitaryRankRow(MiltitaryLogic.getMiltitaryLevel())
		-- miltitaryName = miltitaryRankRow.name
	-- end
	-- local labelRank = CommonFunc_getLabelByName(rootNode, "label_rank")
	-- labelRank:setText(miltitaryName)
	-- 挑战者硬币
	mCoinInfo = ModelBackpack.getItemByTempId(1007) -- 1007 为挑战者硬币ID
	local labelRank = CommonFunc_getLabelByName(rootNode, "label_rank")
	if mCoinInfo ~= nil then
		labelRank:setText(string.format("%d", mCoinInfo.amount))
	else
		labelRank:setText(string.format("%d", 0))
	end
	-- 荣誉值
	-- local labelExp = CommonFunc_getLabelByName(rootNode, "label_exp")
	-- labelExp:setText(string.format("%d", ModelPlayer.getHonour() or 0))
	-- 积分
	local labelScore = CommonFunc_getLabelByName(rootNode, "label_score")
	labelScore:setText(string.format("%d", ModelPlayer.getPoint() or 0))
	-- 军衔消息提示
	-- if true == MiltitaryLogic.existAward() then
		-- local miltitaryTip = CommonFunc_getImgView("qipaogantanhao.png")
		-- miltitaryTip:setPosition(ccp(85, 25))
		-- local node = rootNode:getChildByName(tbBtn[4])
		-- node:addChild(miltitaryTip)
	-- end
	TipModule.onUI(rootNode, "ui_gamerankchoice")
end
	
LayerGameRankChoice.init = function(rootView)
	-- add gui
	rootNode = rootView
	if rootNode == nil then
		cclog("LayerGameRankChoice init nil") 
		return nil
	end	

	initUI()
	
	return rootNode
end

LayerGameRankChoice.destroy = function()
	cclog("LayerGameRankChoice destroy!")
end







