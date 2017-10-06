----------------------------------------------------------------------
-- Date:	2014-09-17
-- Brief:	������ɶ���
----------------------------------------------------------------------
LayerMissionComplete = {}
----------------------------------------------------------------------
local mRootView = nil
local taskRewardInfo = {}  -- ��������Ϣ
local mKey = 0
LayerAbstract:extend(LayerCopyDelock)

local all_DestPos = {
						ccp(302, 884),
						ccp(159, 929),
						ccp(302, 929),
}

-- �������ص�����
local function onClickCallFunc()
	UIManager.pop("UI_MissionComplete")
	if UIManager.popBounceWindow("UI_TempPack") ~= true then
		LayerLvUp.setEnterLvMode(2)
		UIManager.popBounceWindow("UI_LvUp")
	end
end

-- �Ƴ�������ɽ���
local  function popLayer(sender)
	sender:getParent():removeChild(sender, true)
	if mKey == #taskRewardInfo then
		UIManager.pop("UI_MissionComplete")
		if UIManager.popBounceWindow("UI_TempPack") ~= true then
			LayerLvUp.setEnterLvMode(2)
			UIManager.popBounceWindow("UI_LvUp")
		end
	end
end

--���㵱ǰ�����ת���ɶ��ٽ�Ҿ���
local function calCoinSpriteAmount(mAmount)
	local low = 1
	local high = 2
	if mAmount > 5000 then
		low = 8
		high = 12
	elseif mAmount > 1000 then
		low = 5
		high = 7
	elseif mAmount > 500 then
		low = 4
		high = 6
	elseif mAmount > 100 then
		low = 3
		high = 5
	elseif mAmount >= 1 then
		low = 2
		high = 4
	else
		low = mAmount
		high = mAmount
	end
	return math.random(low, high)
end

--����ƫ��λ��
local function calOffsetPos(raduis, angle)
	angle = angle / 180.0 * 3.14
	local x = math.sin(angle) * raduis
	local y = math.cos(angle) * raduis
	return ccp(x, y)
end

--������ҽ��
local function createCoinSprite(pos, index)
	local node = CCNode:create()
	mRootView:addChild(node, 10000)
	node:setPosition(pos)
	
	local sprite = CCSprite:create(string.format("effect_%d_piece.png", index))
	node:addChild(sprite, 1)
	sprite:setScale(math.random(90, 100) / 100)
	
	local particle = CCParticleSystemQuad:create(string.format("effect_%d_tail.plist", index))
	node:addChild(particle)
	particle:setPosition(ccp(0, 0))
	
	return node
end

-- ����Ч��
local function crush(pos, value)
	--��÷����յ�
	local destPos = all_DestPos[value.type]
	local mAmount = tonumber(value.reward_amounts)
	local total = calCoinSpriteAmount(mAmount)
	local unit = math.floor(mAmount / total)
	local delay = 0.0
	for i = 1, total do
		local offset = calOffsetPos(60, math.random(1, 360))
		local newPos = ccp(pos.x + offset.x, pos.y + offset.y)
		local sprite = createCoinSprite(newPos, value.type)
		
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delay))
		arr:addObject(CCShow:create())
		arr:addObject(EffectMgr.curvilinearMotion(1.25, newPos, destPos))
		arr:addObject(CCDelayTime:create(1.0))
		arr:addObject(CCCallFuncN:create(popLayer))
		sprite:runAction(CCSequence:create(arr))
		sprite:setVisible(false)
		local tag = 0
		if i == total then
			tag = mAmount
		else
			tag = unit
			mAmount = mAmount - unit
		end
		sprite:setTag(tag)
		-- delay = delay + math.random(5, 14) / 100
		delay = delay + math.random(1, 5) / 100
	end
end

-- ��Ʒ���б�����ʧ
local function disappear()
	local delay = 0.02
	for key, value in pairs(taskRewardInfo) do
		mKey = key
		local rewardImage = tolua.cast(mRootView:getWidgetByName(string.format("icon_%d",key)),"UIImageView")		--����Icon
		rewardImage:loadTexture(value.icon)
		rewardImage:setOpacity(0)
		CommonFunc_SetQualityFrame(rewardImage)
		
		local qualityImage = tolua.cast(rewardImage:getChildByName("UIImageView_quality"), "UIImageView")
		qualityImage:setOpacity(0)
		qualityImage:runAction(CCFadeIn:create(0.5))
		
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(delay))
		arr:addObject(CCFadeIn:create(0.5))
		-- ���ԭͼ��������Ӻ���
		local function clearCallBack(sender)
			local pos = sender:convertToWorldSpace(ccp(60, 0))
			sender:removeFromParentAndCleanup(true)
			rewardImage:setVisible(false)
			if key == 1 then
				local rewardBg= tolua.cast( mRootView:getWidgetByName("background"),"UIImageView")	-- ������ɱ���
				rewardBg:runAction(CCFadeOut:create(0.7))
			end
			crush(pos, value)
		end
		
		local function CallBackWhite(sender)
			local whiteImage = tolua.cast(mRootView:getWidgetByName(string.format("white_%d",key)),"UIImageView")		--����Icon
			local arr = CCArray:create()
			arr:addObject(CCFadeIn:create(0.5))
			arr:addObject(CCCallFuncN:create(clearCallBack))
			whiteImage:runAction(CCSequence:create(arr))
			
		end
		
		if 1 == value.type or 2 == value.type or 3 == value.type then			-- 1.��� 2.���� 3.ħʯ
			-- arr:addObject(CCDelayTime:create(delay))
			arr:addObject(CCCallFuncN:create(CallBackWhite))
		elseif 7 == value.type or 8 == value.type or 13 == value.type then			-- 7.��Ʒ 8.����(������)13.������Ƭ
			--ͼƬ�ɵ���Ӧ��λ��
			local fromPosition = rewardImage:getWorldPosition()
			local destPosition = LayerMain.getBtnPosition()
			local action = CommonFunc_curMoveAction(1.5,ccp(fromPosition.x,fromPosition.y) ,ccp(destPosition[2].x, destPosition[2].y))
			if key == 1 then
				local rewardBg= tolua.cast( mRootView:getWidgetByName("background"),"UIImageView")	-- ������ɱ���
				rewardBg:runAction(CCFadeOut:create(0.7))
			end
			arr:addObject(CCSpawn:createWithTwoActions(action,CCScaleBy:create(1.0,0.1)) )
			arr:addObject(CCHide:create())
			arr:addObject(CCDelayTime:create(1.0))
			arr:addObject(CCCallFuncN:create(popLayer))
		end
		
		rewardImage:runAction(CCSequence:create(arr))
		delay = delay + 0.5
	end
	
end

--����icon��̬����,���ݴ������ĸ���
local function drawToumingImg(number)
	local delockBg= tolua.cast(mRootView:getWidgetByName("background"),"UIImageView")	--�¹��ܱ���
	local width = delockBg:getSize().width
	local position_y = 585
	local delta = 11			--��ʾ����Icon�м�ľ���
	widget_width = 94			--ͼ����
	local name_position_y = 20

	local detalX =  (width - number* widget_width)/(number + 1)--����ƫ����������
	for i=1,number,1 do
		local position_x = detalX*i + widget_width*(i-1) + widget_width/2		--��ʾ���õ�λ��
		local img = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(position_x,position_y),
					CCSizeMake(94,94), "touming.png",string.format("icon_%d",i),1 )
		local white = CommonFunc_createUIImageView(ccp(0.5,0.5), ccp(position_x,position_y),
					CCSizeMake(94,94), "forge_recast_blickIcon.png",string.format("white_%d",i),3)
		local name = CommonFunc_createUILabel(ccp(0.5,0.5), ccp(position_x - 320,name_position_y), nil, 23,
					ccc3(255, 255, 255),"",i*100, 1)	--����
		
		mRootView:addWidget(img)
		mRootView:addWidget(white)
		delockBg:addChild(name)
	end	
end

LayerMissionComplete.init = function(task)
	taskRewardInfo = {}
	for k, v in pairs(task.reward_ids) do
		local rewardItem = LogicTable.getRewardItemRow(task.reward_ids[k])
		rewardItem.reward_amounts = task.reward_amounts[k]
		
		table.insert(taskRewardInfo, rewardItem)
	end
	mRootView = UIManager.findLayerByTag("UI_MissionComplete")
	
	local rewardPanel = tolua.cast(mRootView:getWidgetByName("rootview"),"UILayout")		-- �������Icon		
	rewardPanel:setEnabled(true)
	
	drawToumingImg(#taskRewardInfo)
	
	for key,value in pairs(taskRewardInfo) do
		-- if key >#taskRewardInfo then
			-- cclog("Խ����*******************",key)
		-- end
		local whiteImage = tolua.cast(mRootView:getWidgetByName(string.format("white_%d",key)),"UIImageView")		--����Icon
		whiteImage:setOpacity(0)
	end	
	
	local rewardBg = tolua.cast(mRootView:getWidgetByName("background"),"UIImageView")			-- ������ɱ���
	-- rewardBg:registerEventScript(onClickCallFunc)
	local arr = CCArray:create()
	arr:addObject(CCFadeIn:create(0.5))
	arr:addObject(CCCallFuncN:create(disappear))
	rewardBg:runAction(CCSequence:create(arr))												-- ����
end

LayerMissionComplete.destroy = function()
	local root = UIManager.findLayerByTag("UI_MissionComplete")
	if root ~= nil then
		root:removeFromParentAndCleanup(true)
		root = nil
	end
	mRootView = nil
	taskRewardInfo = {}
end