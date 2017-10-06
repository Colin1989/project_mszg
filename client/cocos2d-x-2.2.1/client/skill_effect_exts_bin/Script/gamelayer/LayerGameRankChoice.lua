--/**
-- *  @Brief: 竞技场入口选择
-- *  @Created by fjut on 14-03-12
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerGameRankChoice = {}
local rootNode = nil

-- json file
local guiJsonFile = "GameRankChoice_1.ExportJson"
-- 5个图片按钮
local tbImg = {"img_pws", "img_2", "img_3", "img_4", "img_5"}
local tbLabel = 
{
	-- 
}
 
 -- 图片点击响应
local function imgCall(clickType, sender)
	if clickType == "pushDown" then
		sender:setScale(0.8)
	elseif 	clickType == "cancelUp" then
		sender:setScale(1.0)
	end
	
	if clickType ~= "releaseUp" then
		return
	end
	sender:setScale(1.0)
	cclog("LayerGameRankChoice imgcall: "..sender:getName())
	
	local name = sender:getName()
	if name == tbImg[1] then 
		LayerMain.switchPannel(LayerGameRank)
	elseif name == tbImg[2] then
		--LayerMain.switchPannel(LayerAssistance)
		--UIManager.push("UI_Assistance") 
	elseif name == tbImg[3] then
	
	elseif name == tbImg[4] then
	
	elseif name == tbImg[5] then
	
	elseif name == tbImg[6] then
	
	else
		--[[
		local tb = req_register()
		tb.account = "1212"
		tb.channelid = 0
		tb.platformid = 0
		tb.password = "123"
		NetSocket_send(tb)
		--]]
	end	
	
end

 -- 图片点击响应
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	cclog("LayerGameRankChoice imgcall: "..sender:getName())
	if sender:getName() == "btn_close" then
		LayerMain.switchPannel(LayerMain)
	elseif sender:getName() == "btn_add" then 
		cclog("btn_add")
	elseif sender:getName() == "btn_getReward" then 
		cclog("btn_getReward")
	end
end

 -- 动态UI
local function loadDynamicUI(node)
	-- 军衔
	local labelRank = CommonFunc_getLabelByName(node, "label_rank")
	labelRank:setText(789)
	-- 经验
	local labelExp = CommonFunc_getLabelByName(node, "label_exp")
	labelExp:setText(456)
	-- 积分
	local labelScore = CommonFunc_getLabelByName(node, "label_score")
	labelScore:setText(123)
end


-- 初始化静态UI
local function initUI()
	-- 图片点击Event
	for i = 1, #tbImg, 1 do
		local img = rootNode:getChildByName(tbImg[i])
		img:registerEventScript(imgCall)
	end
	
	-- 关闭btn event
	local btnClose = rootNode:getChildByName("btn_close")
    btnClose:registerEventScript(btnCall)

	-- 动态UI
	loadDynamicUI(rootNode)
end
	
LayerGameRankChoice.init = function()
	-- add gui
	rootNode = GUIReader:shareReader():widgetFromJsonFile(guiJsonFile)
	if rootNode == nil then
		cclog("LayerGameRankChoice init nil") 
		return nil
	end	

	initUI()
	
	return rootNode
end










