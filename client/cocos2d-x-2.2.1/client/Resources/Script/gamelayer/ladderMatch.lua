-- require "ladderMatchfenzu"
require "LayerGameMatch"
require "ladderMatchReward"
require "ladderMatchruler"

ladderMatch = setmetatable({},{__mode='k'})
--ladderMatch = {}
local panelContent = nil --标签页更节点

local curChildTb = nil	--当前
local curUIWidget = nil 
local curTag = 201461
local isAction = false
local BtnList = {}
local  Index = 1	--FIXME 待优化 INDEX判断

local function  setJosnWidget(this,pos)
	--panelContent:removeAllChildren()	
	local contentView = GUIReader:shareReader():widgetFromJsonFile(this.jsonFile)
	contentView:setAnchorPoint(ccp(0.0,0.0))
	contentView:setPosition(pos)
	
	curTag = curTag + 1
	
	contentView:setTag(curTag)
	
	panelContent:addChild(contentView)
	this.init(contentView)
	
	curChildTb = this
	return contentView
end

local function switchLayerByAction(newLayer,mode)
	local detla = 640
	
	if mode == "right" then
		detla = -640
	end
	isAction = true

	local oldWidget = panelContent:getChildByTag(curTag)
	local tempTb = curChildTb
	local arr = CCArray:create()
    arr:addObject(CCEaseBackIn:create(CCMoveBy:create(0.3,CCPointMake(-detla,0))))
    arr:addObject(CCCallFunc:create(function ()
		isAction = false
		tempTb.destroy()	
		panelContent:removeChild(oldWidget)
	end))
	oldWidget:runAction(CCSequence:create(arr))
	
	local widget = setJosnWidget(newLayer,ccp(detla,0))
	widget:runAction(CCEaseBackIn:create(CCMoveBy:create(0.3,CCPointMake(-detla,0))))
	
end 

local function OnClick(widget)
	local name = widget:getName()
	local ret = "left"
	-- if isAction == true then 
		-- cclog("action~~") 
		-- return 
	-- end

	if name == "ladder_fenzu" then
		-- switchLayerByAction(ladderMatchfenzu,"right")
		switchLayerByAction(LayerGameMatch,"right")
		Index = 1
	elseif name == "ladder_ruler"  then 
		if Index > 2 then
			ret = "right"
		end 
		switchLayerByAction(ladderMatchruler,ret)
		Index = 2
	elseif name == "ladder_reward"  then 
		switchLayerByAction(ladderMatchReward)
		Index = 3
	end 
	
end

local function initButtonEvent(rootView)
	local function ceateBtnList(widgetName,isBright) 
		 local widgetSingle = {}
		 widgetSingle.isBright = isBright
		 widgetSingle.name = widgetName
		 widgetSingle.widget = rootView:getChildByName(widgetName)
		 
		if isBright == true then
			tolua.cast(widgetSingle.widget,"UIImageView")
			widgetSingle.widget:loadTexture("laddermatch_buttom_h.png")
		end
		table.insert(BtnList,widgetSingle)
	end	
	ceateBtnList("ladder_fenzu",true)
	ceateBtnList("ladder_ruler",false)
	ceateBtnList("ladder_reward",false)
	
	setLadderMatchTabBtn()
	
	rootView:getChildByName("ladder_close"):registerEventScript(function(typeEvent,widget)
		if typeEvent == "releaseUp" then 
			TipModule.onClick(widget)
			if curChildTb and type(curChildTb.destroy) == "function" then 
				curChildTb.destroy()
			end 
			setConententPannelJosn(LayerGameRankChoice, "GameRankChoice_1.json", "Panel_jjc_build")	
		end 
	end)
end 

function setLadderMatchTabBtn()
	local function handle_onClick(typeName,widget) 
		if typeName == "releaseUp" then
			if isAction == true then 
				cclog("action~~") 
				return 
			end
			TipModule.onClick(widget)
			local curName = widget:getName()
			for key,value in pairs(BtnList) do	--取消原来两的东西
				if value.isBright == true then
					if curName == value.name then -- 如果连续同时按一个按钮 不触发事件
						return
					end
					tolua.cast(widget,"UIImageView")
					value.widget:loadTexture("public_newbuttom.png")
					value.isBright = false
				end 
				if curName == value.name then 
					curValue = value
				end
			end
			tolua.cast(widget,"UIImageView")
			widget:loadTexture("laddermatch_buttom_h.png")
			curValue.isBright = true
			OnClick(widget)
		end
	end

	for k,v in pairs(BtnList) do
		v.widget:registerEventScript(handle_onClick)
	end
end


ladderMatch.init = function(rootView)
	curTag = 201461
	isAction = false
	BtnList = {}
	panelContent = rootView:getChildByName("laddercontent")
	tolua.cast(panelContent,"UILayout")

	initButtonEvent(rootView)
	-- curUIWidget = setJosnWidget(ladderMatchfenzu,ccp(0,0))
	curUIWidget = setJosnWidget(LayerGameMatch,ccp(0,0))
	TipModule.onUI(rootView, "ui_laddermatch")
end


ladderMatch.destroy = function()
	-- ladderMatchfenzu.destroy()
	LayerGameMatch.destroy()
	ladderMatchruler.destroy()
	ladderMatchReward.destroy()
	panelContent = nil	
end 










