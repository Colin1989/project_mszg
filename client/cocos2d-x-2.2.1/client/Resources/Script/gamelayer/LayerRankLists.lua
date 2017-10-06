--/**
-- *  @Brief: 排行榜
-- *  @Created by fjut on 14-04-26
-- *  @Copyright 2014 XmTT. All rights reserved.
-- */

LayerRankLists = {}
local rootNode = nil

-- radio 增量
local m_radioBtnTagAdd = 1000
-- 选中的radio
local m_selectedRadioBtn = nil
-- 分页layout tag 增量
local m_layerTagAdd = 20000
-- 分页标题label tag 增量
local m_labelTagAdd = 30000
-- 分页个数
local m_radioNum = 2
-- 分页index(from 1)
local m_radioIndex = 1
-- 每种类型数据tb
local m_tbData = {}
-- color
local bCellColor = true

-- 获取某类型数据
local function getDataByType(type)
	local tb = {}
	--cclog("总类型个数:"..#(m_tbData))
	for k, v in next, (m_tbData) do
		if v.type == type then
			tb = v
			break
		end
	end

	return tb
end

-- 自己排名, type: 1, 2, 3, 4
local function setRankLabelByType(type)
	-- 自己排行
	local labelMyRank = CommonFunc_getLabelByName(rootNode, "labelAtlas_rankVal", nil, true)
	local tbData = getDataByType(m_radioIndex)
	local num = (tbData.myrank == nil) and 0 or tbData.myrank
	labelMyRank:setStringValue(string.format("%d", num))
end
		
-- 获取cell node 
local function getCellNodeById(tb)
	local node = UILayout:create()
	node:setSize(CCSizeMake(474, 40)) 
	-- bg
	local bgStr = (bCellColor) and "rinklist_modify_02.png" or "rinklist_modify_03.png"
	bCellColor = not bCellColor
	local size = node:getSize()
	local imgBg = CommonFunc_getImgView(bgStr)
	imgBg:setPosition(ccp(size.width*0.5 - 25, size.height*0.5))
	node:addChild(imgBg)
	-- 排名
	local altasPng = (bCellColor) and "num_black.png" or "num_gold.png"
	local labelRank = CommonFunc_getAtlas("01234567890", altasPng, 24, 32, 0)
	labelRank:setPosition(ccp(-203, 0))
	labelRank:setStringValue(tostring(tb.rank))
	labelRank:setScale(0.75)
	imgBg:addChild(labelRank)
	-- 玩家昵称
	local labelName = CommonFunc_getLabel(tb.name, 22)
	labelName:setPosition(ccp(-85, 0))
	imgBg:addChild(labelName)
	-- 等级(战力, 副本)
	local labelPro = CommonFunc_getAtlas("01234567890", altasPng, 24, 32, 0)
	labelPro:setPosition(ccp(45, 0))
	labelPro:setStringValue(tostring(tb.value))
	labelPro:setScale(0.7)
	imgBg:addChild(labelPro)
	-- 所在公会
	local labelGild = CommonFunc_getLabel(CommonFunc_GetRoleTypeString(tb.type), 24) 
	labelGild:setPosition(ccp(160, 0))
	imgBg:addChild(labelGild)

	return node
end

-- 获取cell node tb
local function getCellNodeTbByTypeIndex(typeIndex)
	-- 获取某类别的排行数据
	local tbData = getDataByType(typeIndex)
	-- node tb
	local tbCellNode = {}
	for k, v in next, (tbData.top_hundred) do
		local cellLayout = getCellNodeById(v)
		table.insert(tbCellNode, cellLayout)
	end

	return tbCellNode
end

-- 创建下拉列表
local function getScrollView(typeIndex)
	bCellColor = true
	local tbCellNode = getCellNodeTbByTypeIndex(typeIndex)
	local scrollView = CommonFunc_getScrollView(CCSizeMake(474, 474), tbCellNode, "V", -15, 30, nil)
	
	return scrollView
end

-- add scrollView
local function addScrollView()
	local layout = rootNode:getChildByTag(m_layerTagAdd + m_radioIndex)
	local tbData = getDataByType(m_radioIndex)
	if #(tbData.top_hundred) > 0 then
		cclog("创建cell个数:"..#(tbData.top_hundred))
		local scroll = getScrollView(m_radioIndex)
		scroll:setPosition(ccp(82, 66))
		layout:addChild(scroll)
	end	
end

-- 设置数据
local function setData(data)
	for k, v in next, (m_tbData) do
		if v.type == data.type then
			v.myrank = data.myrank
			v.top_hundred = data.top_hundred
			return
		end
	end
	-- 还未添加过
	-- 标记为请求过了
	-- todo
	table.insert(m_tbData, data)
	cclog("添加的排行榜种类:"..#(m_tbData))
end

-- 排行数据
local function handle_req_RankLists(resp)
	if nil == rootNode or resp == nil or #(resp.top_hundred) <= 0 then
		cclog("rec error !")
		return
	end
	
	cclog("网络数据返回类型:"..resp.type)
	cclog("网络数据返回类型个数:"..#(resp.top_hundred))
	
	-- 保存数据
	setData(resp)
	-- 自己排行
	setRankLabelByType(m_radioIndex)
	-- 创建layout
	addScrollView()
end

-- net 请求
-- type:["battle_power_rank"]= 1, ["role_level_rank"] = 2
local function netReq(type)
	-- 请求过了 
	if getDataByType(type).type ~= nil then
		-- 创建layout
		cclog("已经请求")
		addScrollView()
		return
	end
	cclog("没请求")
	
	local tb = req_get_rank_infos()
	tb.type = type
	cclog("网络请求:"..type)
	NetHelper.sendAndWait(tb, NetMsgType["msg_notify_rank_infos"]) 
end

NetSocket_registerHandler(NetMsgType["msg_notify_rank_infos"], notify_rank_infos, handle_req_RankLists)

-- 小标题更新
local function updateLabelTitleByIndex(index)
	-- Game_Rank_Lists_t1 = "排名"
	-- Game_Rank_Lists_t2 = "玩家昵称"
	-- Game_Rank_Lists_t3 = "等级"
	-- Game_Rank_Lists_t4 = "所在公会"
	-- Game_Rank_Lists_t5 = "战力"
	-- Game_Rank_Lists_t6 = "副本"
	local strValue = {GameString.get("Game_Rank_Lists_t1"), GameString.get("Game_Rank_Lists_t2"), GameString.get("Game_Rank_Lists_t3"), GameString.get("Game_Rank_Lists_t4") }
	local label = rootNode:getChildByTag(m_labelTagAdd + 3)
	local str = (index == 1) and GameString.get("Game_Rank_Lists_t5") or GameString.get("Game_Rank_Lists_t3")
	tolua.cast(label, "UILabel")
	label:setText(tostring(str))
end

-- 切换显示分页(index from 1)
local function switchLayer(layerIndex)
	m_radioIndex = layerIndex  
	for k = 1, m_radioNum, 1 do 
		local layout = rootNode:getChildByTag(m_layerTagAdd + k)
		if k == layerIndex then
			if layout == nil then
				-- layout
				layout = UILayout:create()
				layout:setTag(m_layerTagAdd + layerIndex)
				rootNode:addChild(layout)
				cclog("创建layout标签index:"..m_radioIndex)
				-- net
				netReq(layerIndex)
			else
				layout:setEnabled(true)
				layout:setVisible(true)
			end	
		else
			if layout ~= nil then
				layout:setEnabled(false)
				layout:setVisible(false)
			end
		end
	end
	-- 排名更新
	setRankLabelByType(layerIndex)
	-- 小标题更新
	updateLabelTitleByIndex(layerIndex)
end



local m_tbRadioBtnInfo =
{
{["normal"] ="text_rank_zhanli_d.png",["current"] ="text_rank_zhanli_h.png"},
{["normal"] ="text_rank_level_d.png",["current"] = "text_rank_level_h.png"}
}

-- 分页按钮切换action
local function radioBtnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	-- 已经选中
	if m_selectedRadioBtn == sender then
	    return
	end
	m_selectedRadioBtn = sender
	switchLayer(sender:getTag() - m_radioBtnTagAdd)
	
	for k = 1, m_radioNum, 1 do 
		local btn = rootNode:getChildByTag(k + m_radioBtnTagAdd)
		local nameImage = btn:getChildByName("textImg")
		tolua.cast(nameImage,"UIImageView")
		local pos = btn:getPosition()
		if btn ~= sender then
			btn:setBright(true)
			btn:setPosition(ccp(pos.x, 260))
			nameImage:loadTexture(m_tbRadioBtnInfo[k].normal)
			nameImage:setPosition(ccp(0,1 ))
		else
			btn:setBright(false)
			btn:setPosition(ccp(pos.x, 265))
			nameImage:loadTexture(m_tbRadioBtnInfo[k].current)
			nameImage:setPosition(ccp(0,-2))
		end	
	end
end

-- 按钮call
local function btnCall(clickType, sender)
	if clickType ~= "releaseUp" then
		return
	end
	
	if sender:getName() == "btn_close" then
		LayerMain.pullPannel(LayerRankLists)
	end
end

-- 初始化静态UI
local function initUI()
	-- 战力排行
	local btnPower = CommonFunc_getNodeByName(rootNode, "btn_power")
	btnPower:setTag(m_radioBtnTagAdd + 1)
    btnPower:registerEventScript(radioBtnCall)
	-- 等级排行
	local btnLv = CommonFunc_getNodeByName(rootNode, "btn_lv")
	btnLv:setTag(m_radioBtnTagAdd + 2)
    btnLv:registerEventScript(radioBtnCall)
	-- 竞技排行
	local btnCompet = CommonFunc_getNodeByName(rootNode, "btn_compet")
	btnCompet:setTouchEnabled(false)
	btnCompet:setVisible(false)
	-- 副本排行
	local btnTrans = CommonFunc_getNodeByName(rootNode, "btn_transcription")
	btnTrans:setTouchEnabled(false)
	btnTrans:setVisible(false)
	-- 关闭
	local btnClose= CommonFunc_getNodeByName(rootNode, "btn_close")
    btnClose:registerEventScript(btnCall)
	-- 小标题背景
	local imgBg = CommonFunc_getImgView("rinklist_modify_01.png")
	imgBg:setPosition(ccp(320, 556))
	rootNode:addChild(imgBg)
	-- 小标题
	local posX = {-192, -72, 45, 162}
	local strValue = {GameString.get("Game_Rank_Lists_t1"), GameString.get("Game_Rank_Lists_t2"), GameString.get("Game_Rank_Lists_t3"), GameString.get("Game_Rank_Lists_t4") }
	for k = 1, 4, 1 do
		local label = CommonFunc_getLabel(strValue[k], 23, ccc3(255, 255, 68))
		label:setPosition(ccp(posX[k], 0))
		label:setTag(m_labelTagAdd + k)
		imgBg:addChild(label)
	end	
	
	-- 显示首页
	m_selectedRadioBtn = btnPower
	m_selectedRadioBtn:setBright(false)
	m_selectedRadioBtn:setPosition(ccp(m_selectedRadioBtn:getPosition().x, 265))
end

-- init	
LayerRankLists.init = function(rootView)
	rootNode = rootView
	if rootNode == nil then
		cclog("LayerRankLists init fail !")
		return
	end
	
	initUI()
	-- 显示战力
	switchLayer(rank_type["battle_power_rank"])
	
	return rootNode
end

-- public
LayerRankLists.destroy = function()
	rootNode = nil
end

-- 注销清除data
LayerRankLists.purge = function()
	rootNode = nil
	m_tbData = {}
end

-- 3点更新
SystemTime.createDailyTimer(15, 0, 0, LayerRankLists.purge)

