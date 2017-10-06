------------------------------------------------------------------------
-- ս����¼
------------------------------------------------------------------------

LayerCombatLog = {}
local mRootNode = nil

-- ����رհ�ť
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_CombatLog")
	end
end

-- show ��Ϣ����scrollview
local function showMsgScrollView(tb)
	if nil == mRootNode then
		return
	end
	local scrollViewMsg = CommonFunc_getNodeByName(mRootNode, "scrollView_msg", "UIScrollView")
	if tb == nil or #tb <= 0 then
		cclog("��Ϣ����scrollview ����Ϊ0")
		scrollViewMsg:setTouchEnabled(false)
		return
	end

	local cellOffsetPosX = 0
	scrollViewMsg:setTouchEnabled(true)
	scrollViewMsg:removeAllChildren()
	
	for k, value in next, (tb) do
		cclog("����:"..value.name.." ��Ӯ:"..value.result.." ������:"..value.new_rank) 
		local strText = GameString.get("GameRank_MSG_FAIL")
		value.new_rank = (value.new_rank == nil) and 0 or value.new_rank
		local strRank = GameString.get("GameRank_MSG_PM", value.new_rank)
		local color = ccc3(0, 255, 0)
		if value.result == game_result["game_win"] then 
			color = ccc3(255, 0, 0)
			strText = GameString.get("GameRank_MSG_SUCESS")
			strRank = GameString.get("GameRank_MSG_DROP", value.new_rank)
		end
		local str = (value.bIsSelf) and "GameRank_MSG_TIPS2" or "GameRank_MSG_TIPS1"
		if value.bIsSelf then
			if value.result == game_result["game_win"] then
				strRank = GameString.get("GameRank_MSG_RISE", value.new_rank)
				color = ccc3(0, 255, 0)
				-- ��ս�Ķ�������С���Լ�������, ������Ӯ����������
				if value.up then
					strRank = GameString.get("GameRank_MSG_PM", value.new_rank)
				end
				strText = GameString.get("GameRank_MSG_SUCESS1")
			else
				local myRank = LayerGameRank.getMyRank()
				color = ccc3(255, 0, 0)
				strRank = GameString.get("GameRank_MSG_PM", myRank)
			end	
		end
		
		local strLabel = GameString.get(str, value.name, strText)..strRank
		local label = CommonFunc_getLabel(strLabel, 22, color)
		label:setAnchorPoint(ccp(0, 0.5))
		scrollViewMsg:setInnerContainerSize(CCSize(scrollViewMsg:getSize().width, (#tb)*label:getContentSize().height))
		local h = scrollViewMsg:getInnerContainerSize().height - label:getContentSize().height*0.5 - label:getContentSize().height*(k-1)
		label:setPosition(ccp(cellOffsetPosX, h))
		scrollViewMsg:addChild(label)
	end
end

-- ��ʼ��
LayerCombatLog.init = function()
	mRootNode = UIManager.findLayerByTag("UI_CombatLog"):getWidgetByName("Panel_497")
	
	-- �ر�
	local closeBtn = tolua.cast(mRootNode:getChildByName("Button_close"), "UIButton")
	closeBtn:registerEventScript(clickCloseBtn)
	
	local sliderMsg = CommonFunc_getNodeByName(mRootNode, "slider_msg", "UISlider")
	sliderMsg:setPercent(0)
	local scrollViewMsg = CommonFunc_getNodeByName(mRootNode, "scrollView_msg", "UIScrollView")
	scrollViewMsg:registerEventScript(function(typename, widget) 
						local scrollViewInnerCon = scrollViewMsg:getInnerContainer()
						local InnerHei = scrollViewInnerCon:getSize().height
						local InnerPosY = scrollViewInnerCon:getPosition().y
						local scrollHei = scrollViewMsg:getSize().height
						local scrollPosY = scrollViewMsg:getPosition().y
						if "scrolling" == typename then
							local Ratio = math.abs(InnerPosY)/(InnerHei-scrollHei)*100
							sliderMsg:setPercent(100 - Ratio)
						end
					end)
	
	-- show ��Ϣ����scrollview
	local tbMsgInfo = LayerGameRank.getCombatMsg()
	showMsgScrollView(tbMsgInfo)
	
end

-- ����
LayerCombatLog.destroy = function()
	mRootNode = nil
end