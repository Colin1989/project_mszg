--[[
天梯 奖励
]]--



ladderMatchReward = setmetatable({},{__mode='k'})
local BtnList = {}
local callbackPosX = 0  -- 记录回调函数的横轴坐标变化

ladderMatchReward["jsonFile"] = "ladderMatchReWard_1.json"
ladderMatchReward.rootView = nil

local function setSpecialAwardIcon(id)
	
	local function getRewardNodeById(cell, data, index)
		local node = UILayout:create()
		node:setSize(CCSizeMake(274, 219))
		local size = node:getSize()
		
		if data == 1 then
			local rewardIcon = CommonFunc_getImgView(string.format("laddermatch_dayreward_%d.png", id))
			rewardIcon:setPosition(ccp(size.width*0.5, size.height*0.5))
			node:addChild(rewardIcon)
		elseif data == 2 then
			local rewardIcon = CommonFunc_getImgView(string.format("laddermatch_weekreward_%d.png", id))
			rewardIcon:setPosition(ccp(size.width*0.5, size.height*0.5))
			node:addChild(rewardIcon)
		end
		
		return node
	end
	
	local function scrollCallback(scrollView, eventType)
		local width = scrollView:getInnerContainer():getSize().width
		local pos = scrollView:getInnerContainer():getPosition()
		local kuangW = scrollView:getSize().width
		local ratio = math.abs(pos.x)/(width - kuangW) * 100
		
		if eventType == "pushDown" then
			callbackPosX = pos.x
		end
		if eventType == "releaseUp" then
			local movePosition = pos.x - callbackPosX
			if movePosition < 0 then
				if pos.x < -18 then
					scrollView:jumpToRight()
				else
					scrollView:jumpToLeft()
				end
			elseif movePosition > 0 then
				if pos.x > -267 then
					scrollView:jumpToLeft()
				else
					scrollView:jumpToRight()
				end
			end
		end
	end
	
	local scrollView = tolua.cast(ladderMatchReward.rootView:getChildByName("ScrollView_269"), "UIScrollView")
	UIScrollViewEx.show(scrollView, {1, 2}, getRewardNodeById, "H", 274, 219, 4, 1, 2, true, scrollCallback, true, false)
	
	local m_specialAward_tple = LogicTable.getLadderMatchSpecialAward(id)
	for M=1,4 do
		-- print("Error:!",id,m_specialAward_tple.map[tostring(id*100 + M)],m_specialAward_tple.map[id*100 + M])
		-- local idsTB = CommonFunc_split(m_specialAward_tple.map[tostring(id*100 + M)].weekiy_award_ids,",")
		-- local amountsTB = CommonFunc_split(m_specialAward_tple.map[tostring(id*100 + M)].weekiy_award_amounts,",")
		
		local idsTB = m_specialAward_tple[M].weekiy_award_ids
		local amountsTB = m_specialAward_tple[M].weekiy_award_amounts
		for n=1,3 do
			local k =(M-1)*3 +n
			local uiIcon = ladderMatchReward.rootView:getChildByName("reicon"..k)
			tolua.cast(uiIcon,"UIImageView")
		
			local UINum =  ladderMatchReward.rootView:getChildByName("reicon"..k.."num")
			tolua.cast(UINum,"UILabel")
			if idsTB[n]~= nil and amountsTB[n]~=nil then	
				local Itemdate = LogicTable.getRewardItemRow (idsTB[n])
				uiIcon:loadTexture(Itemdate.icon)
				UINum:setText(tostring(amountsTB[n])) 
				
				uiIcon:setTouchEnabled(true)
				local function clickSkillIcon(uiIcon)
					showLongInfoByRewardId(Itemdate.id,uiIcon)
				end
				
				local function clickSkillIconEnd(uiIcon)
					longClickCallback_reward(Itemdate.id,uiIcon)
				end

				UIManager.registerEvent(uiIcon, nil, clickSkillIcon, clickSkillIconEnd)
				
				
			else
				uiIcon:setVisible(false)
				UINum:setVisible(false)
			end		
		end
	end
end

local function reward_OnClick(widget)
	local name = widget:getName()

	if name == "ladder_reward1" then
		setSpecialAwardIcon(1)
	elseif name == "ladder_reward2" then 
		setSpecialAwardIcon(2)
	elseif name == "ladder_reward3" then 
		setSpecialAwardIcon(3)
	elseif name == "ladder_reward4" then 
		setSpecialAwardIcon(4)
	end 
end 

ladderMatchReward.init = function(rootView)
	--[[
	rootView:getChildByName("ladder_reward1"):registerEventScript(reward_OnClick)
	rootView:getChildByName("ladder_reward2"):registerEventScript(reward_OnClick)
	rootView:getChildByName("ladder_reward3"):registerEventScript(reward_OnClick)
	rootView:getChildByName("ladder_reward4"):registerEventScript(reward_OnClick)
	]]--
	BtnList ={}
	
	local function ceateBtnList(widgetName,isBright) 
		 local widgetSingle = {}
		 widgetSingle.isBright = isBright
		 widgetSingle.name = widgetName
		 widgetSingle.widget = rootView:getChildByName(widgetName)
		 
		if isBright == true then
			tolua.cast(widgetSingle.widget,"UIImageView")
			widgetSingle.widget:loadTexture("laddermatch_group_h.png")
		end
		table.insert(BtnList,widgetSingle)
	end	
	ceateBtnList("ladder_reward1",true)
	ceateBtnList("ladder_reward2",false)
	ceateBtnList("ladder_reward3",false)
	ceateBtnList("ladder_reward4",false)
	
	setLadderMatchRewardTabBtn()
	ladderMatchReward.rootView = rootView
	setSpecialAwardIcon(1)
end

function setLadderMatchRewardTabBtn()
	local function handle_onClick(typeName,widget) 
	if typeName == "releaseUp" then
		local curName = widget:getName()
			for key,value in pairs(BtnList) do	--取消原来两的东西
				if value.isBright == true then
					if curName == value.name then -- 如果连续同时按一个按钮 不触发事件
						return
					end
					tolua.cast(widget,"UIImageView")
					value.widget:loadTexture("laddermatch_group_d.png")
					value.isBright = false
				end 
				if curName == value.name then 
					curValue = value
				end
			end
			tolua.cast(widget,"UIImageView")
			widget:loadTexture("laddermatch_group_h.png")
			curValue.isBright = true
			reward_OnClick(widget)
		end
	end

	for k,v in pairs(BtnList) do
		v.widget:registerEventScript(handle_onClick)
	end
end

ladderMatchReward.destroy = function()
    ladderMatchReward.rootView = nil
end 
