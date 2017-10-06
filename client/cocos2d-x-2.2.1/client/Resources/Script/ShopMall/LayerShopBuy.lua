----------------------------------------------------------------------
-- Author:	Lihq
-- Date:	2014-10-28
-- Brief:	商城（积分商城）购买数量
----------------------------------------------------------------------
LayerShopBuy = {}
local mRootNode = nil
local mBundle = nil 		--传过来的信息
local mBuyTimes = 1         --购买的个数

----------------------------------------------------------------------
-- 点击关闭按钮
local function clickCloseBtn(typeName, widget)
	if "releaseUp" == typeName then
		UIManager.pop("UI_ShopBuy")
	end
end
----------------------------------------------------------------------
-- 根据次数，计算花费的金币、战绩、魔石
local function getPriceByNum(num)
	local price = 0
	if ModelPlayer.getVipLevel() > 0  and mBundle.type == 1 then
		 price =(mBundle.vip_discount == 0) and mBundle.price* tonumber(num)
				 or (mBundle.price* tonumber(num)*mBundle.vip_discount*0.01)
	else
		print("getPriceByNum*********",num,mBuyTimes)
		price = tonumber(mBundle.need_amounts)* tonumber(num)
	end
	return price
end
----------------------------------------------------------------------
-- 点击购买按钮
local function clickBuyBtn(typeName, widget)
	if "releaseUp" == typeName then
		local price = getPriceByNum(mBuyTimes)
		if mBundle.type == 1 then		--商城
			if mBuyTimes <= 0 then
				local str = GameString.get("ShopMall_INPUT_RIGHT")
				Toast.Textstrokeshow(str, ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			end
			-- 限制次数
			local num = LayerShopMall.getLastPurchaseTimesById(mBundle.id)
			if num <= 0 then
				-- 提醒
				CommonFunc_CreateDialog(GameString.get("ShopMall_LIMITS_TIPS"))
				return
			end
			local str = (mBundle.price_type == "1") and "ShopMall_BUY1_TIPS" or "ShopMall_BUY_TIPS"
			local strDesc = (mBundle.price_type == "1") and GameString.get("ShopMall_TIPS_JB_FAIL") or GameString.get("ShopMall_TIPS_MS_FAIL")
			if CommonFunc_payConsume(2, price) then
				return
			end
			NetLogic.requestBuyMallItem(mBundle.id, mBuyTimes)
		else		--积分商城
			if tonumber(mBundle.mall_item_type) == 1 and price > ModelPlayer.getPoint() then
				Toast.Textstrokeshow(GameString.get("ShopMall_TIPS_JF_FAIL"), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
				return
			elseif tonumber(mBundle.mall_item_type) == 2 then
				local mCoinInfo = ModelBackpack.getItemByTempId(1007)
				if mCoinInfo == nil or price > mCoinInfo.amount then
					Toast.show(GameString.get("ShopMall_TIPS_YB_FAIL"))
					return
				end
			end
			NetLogic.requestBuyPointMallItem(mBundle.id, mBuyTimes)
		end	
	end
end
----------------------------------------------------------------------
-- 设置购买商品的个数和耗费
local function setBuyNums()
	local price = getPriceByNum(mBuyTimes)
	--购买的个数
	local numLbl =tolua.cast(mRootNode:getWidgetByName("num"),"UILabel")
	numLbl:setText(tostring(mBuyTimes))
	local downBtn = tolua.cast(mRootNode:getWidgetByName("down"), "UIButton")
	local downMoreBtn = tolua.cast(mRootNode:getWidgetByName("down_more"), "UIButton")
	if mBuyTimes <= 1 then
		Lewis:spriteShaderEffect(downBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		downBtn:setTouchEnabled(false)
	else
		Lewis:spriteShaderEffect(downBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		downBtn:setTouchEnabled(true)
	end
	if mBuyTimes <= 10 then
		Lewis:spriteShaderEffect(downMoreBtn:getVirtualRenderer(),"buff_gray.fsh",true)
		downMoreBtn:setTouchEnabled(false)
	else
		Lewis:spriteShaderEffect(downMoreBtn:getVirtualRenderer(),"buff_gray.fsh",false)
		downMoreBtn:setTouchEnabled(true)
	end
	
	--花费的魔石、金币、战绩--设置图标
	local costLbl = tolua.cast(mRootNode:getWidgetByName("cost"), "UILabel")
	local costImg = tolua.cast(mRootNode:getWidgetByName("costImg"),"UIImageView")
	if mBundle.type == 1 then
		if mBundle.price_type == 1 then
			costImg:loadTexture("goldicon_02.png")
		else
			costImg:loadTexture("rmbicon.png")
		end
	else
		costImg:loadTexture(LogicTable.getRewardItemRow(mBundle.need_ids).icon)
		costImg:setScale(0.4)
	end
	costLbl:setText(tostring(price))
	
end
----------------------------------------------------------------------
-- 点击增加减少购买数量
local function clickChangeNumBtn(typeName, widget)
	if "releaseUp" == typeName then
		local widgetName = widget:getName()
		if widgetName == "up" then		
			mBuyTimes = mBuyTimes +1
		elseif widgetName == "down" then
			mBuyTimes = mBuyTimes -1
		elseif widgetName == "up_more" then
			mBuyTimes = mBuyTimes + Shop_Add_More_Times
		elseif widgetName == "down_more" then
			mBuyTimes = mBuyTimes - Shop_Add_More_Times
		end
		if mBuyTimes <= 0 then
			mBuyTimes = 0
		end
		setBuyNums()
	end
end
----------------------------------------------------------------------
-- 初始化
LayerShopBuy.init = function(bundle)
	mRootNode = UIManager.findLayerByTag("UI_ShopBuy")
	
	mBundle = bundle
	--Log("LayerShopBuy.init********",mBundle)
	--关闭按钮
	local closeBtn = tolua.cast(mRootNode:getWidgetByName("close"), "UIButton")			
	closeBtn:registerEventScript(clickCloseBtn)
	--购买按钮
	local buyBtn = tolua.cast(mRootNode:getWidgetByName("buy"), "UIButton")			
	buyBtn:registerEventScript(clickBuyBtn)
	--加一个
	local upBtn = tolua.cast(mRootNode:getWidgetByName("up"), "UIButton")			
	upBtn:registerEventScript(clickChangeNumBtn)
	--减一个
	local downBtn = tolua.cast(mRootNode:getWidgetByName("down"), "UIButton")			
	downBtn:registerEventScript(clickChangeNumBtn)
	--增加多个
	local upMoreBtn = tolua.cast(mRootNode:getWidgetByName("up_more"), "UIButton")			
	upMoreBtn:registerEventScript(clickChangeNumBtn)
	--减少多个
	local downMoreBtn = tolua.cast(mRootNode:getWidgetByName("down_more"), "UIButton")			
	downMoreBtn:registerEventScript(clickChangeNumBtn)
	mBuyTimes = 1
	setBuyNums()
end
----------------------------------------------------------------------
-- 销毁
LayerShopBuy.destroy = function()
	mRootNode = nil
	
end
--------------------------------处理购买商城物品--------------------------------------
-- 购买物品返回
local function Handle_req_purchaseShopMall(success)
	if nil == mRootNode then
		return
	end
	if false == success then
		return
	end
	
	local name = LogicTable.getItemById(mBundle.item_id).name
	local amount = mBundle.item_amount*mBuyTimes
	Toast.Textstrokeshow(GameString.get("ShopMall_PUR_GET",name,amount), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
	-- 更新购买次数
	LayerShopMall.setLastPurchaseTimesById(mBundle.id, mBuyTimes)
	UIManager.pop("UI_ShopBuy")
end

EventCenter_subscribe(EventDef["ED_BUY_MALL_ITEM"], Handle_req_purchaseShopMall)

--------------------------------处理购买积分商城物品--------------------------------------
-- 购买物品返回
local function Handle_req_purchaseScoreMall(success)
	if nil == mRootNode then
		return
	end
	if false == success then
		return
	end
	UIManager.pop("UI_ShopBuy")
	local name = LogicTable.getItemById(mBundle.item_id).name
	
	print("Handle_req_purchaseScoreMall******",mBundle.item_amount,mBuyTimes)
	local amount = mBundle.item_amount*mBuyTimes
	Toast.Textstrokeshow(GameString.get("ShopMall_PUR_GET",name,amount), ccc3(255, 255, 255), ccc3(0, 0, 0), 30)
end

EventCenter_subscribe(EventDef["ED_BUY_POINT_MALL_ITEM"], Handle_req_purchaseScoreMall)
---------------------------------------------------------------------------------