----------------------------------------------------------------------
-- ���ߣ�shenl
-- ���ڣ�2014-3-19
-- �����������������
----------------------------------------------------------------------

---test function
function ScrollView_FlyCell (scrollView , tbCell )
	scrollView:removeAllChildren()
	local nSumHeight = 0   -- �б��ܸ߶�
	local nTableCount = table.maxn(tbCell)  -- �б���ܵ�Item��
	local nCurrentHeight = 0
	for nIndex = 1 ,nTableCount, 1 do
		nSumHeight = nSumHeight + tbCell[nIndex]:getSize().height
	end
	local contair = scrollView:getInnerContainer()
	if(nSumHeight > scrollView:getContentSize().height) then
		contair:setSize( CCSize(contair:getSize().width , nSumHeight) )
	else
		nSumHeight = scrollView:getContentSize().height
	end
	local nPosX = contair:getSize().width/2
	for nTable = 1 ,nTableCount, 1 do
		local nPosY = nSumHeight - nCurrentHeight - tbCell[nTable]:getSize().height/2;
		print("===========nPosY "..nPosY)
		tbCell[nTable]:setPosition(ccp( nPosX * 3, nPosY))
		tbCell[nTable]:setAnchorPoint(ccp(0.5,0.5))
		nCurrentHeight = nCurrentHeight + tbCell[nTable]:getSize().height
		scrollView:addChild(tbCell[nTable])
		local moveAction = CCMoveTo:create(0.2 + nTable*0.5,ccp( nPosX , nPosY))
		tbCell[nTable]:runAction(CCEaseExponentialOut:create(moveAction))
	end
end

local mLayerLvUpRoot = nil			---��ǰ����root�ڵ�

LayerLvUp = {
}
LayerAbstract:extend(LayerLvUp)

LayerLvUp.onClick = function(weight)
	local weightName = weight :getName()
    if weightName == "LvUp" then
		UIManager.pop("UI_LvUp")
		--LayerLvUp.init()
	end

end

-- init
LayerLvUp.init = function (bound)
	local function isShow(lastNum,curNum) -- �ж��Ƿ���ֵ�б䶯
		lastNum = tonumber(lastNum)	
		curNum = tonumber(curNum)
		
		if curNum - lastNum > 0 then 
			return true,lastNum,curNum
		else
			return nil
		end 
	end	
	
	local function createItem(lastNum,curNum)
		--local widget = 	GUIReader:shareReader():widgetFromJsonFile("LvUpItem_1.ExportJson")
		local widget =  LoadWidgetFromJsonFile("LvUpItem_1.ExportJson")
		local lable1 = widget:getChildByName("lvuplable1")		
		tolua.cast(lable1,"UILabel")
		lable1 : setText(lastNum)
		
		local lable2 = widget:getChildByName("lvuplable2")		
		tolua.cast(lable2,"UILabel")
		lable2 : setText( string.format("-> %05d",curNum))
		
		return widget
	end
	
	mLayerLvUpRoot = UIManager.findLayerByTag("UI_LvUp")
	local lableLv = mLayerLvUpRoot:getWidgetByName("curLevel")		--��ǰ�ȼ�		
	tolua.cast(lableLv,"UILabel")
	lableLv : setText(tostring(bound.curNum))
	
	
	local mScrollView = mLayerLvUpRoot:getWidgetByName("levelPanel")
	tolua.cast(mScrollView,"UIScrollView") 
	
	setOnClickListenner("LvUp")--����������ť


	local lastAttr = ModelPlayer.getPlayerInitDateByTypeAndLv(ModelPlayer.roletype,bound.lastNum)	--��һ������
	local curAttr = ModelPlayer.getPlayerInitDateByTypeAndLv(ModelPlayer.roletype,bound.curNum)	--��һ������

	
	--local lastAttr = ModelPlayer.getPlayerInitDateByTypeAndLv(2,19)	--��һ������
	--local curAttr = ModelPlayer.getPlayerInitDateByTypeAndLv(2,20)	--��һ������
	
	
	local widgetItemTb = {}
	
	-- ��ӱ䶯����ֵչʾ
	local function AddChanageAttrShow(constName,attrKey) 
		local result,lastNum,curNum = isShow(lastAttr[attrKey],curAttr[attrKey]) 
		if result == true then 	--����
			local UILableItem = createItem(GameString.get(constName,lastNum),curNum)
			table.insert(widgetItemTb,UILableItem)
		end
	end
	
	AddChanageAttrShow("ATK5","atk")
	AddChanageAttrShow("LIF5","life")
	AddChanageAttrShow("SPE5","speed")
	AddChanageAttrShow("HIT5","hit_ratio")
	AddChanageAttrShow("CRT5","critical_ratio")
	AddChanageAttrShow("MIS5","miss_ratio")
	AddChanageAttrShow("RXP5","tenacity")

	ScrollView_FlyCell(mScrollView,widgetItemTb)
	--setListViewAdapter(LayerLvUp, mScrollView, CommonFunc_InvertedTable(widgetItemTb), "V")
	
end



