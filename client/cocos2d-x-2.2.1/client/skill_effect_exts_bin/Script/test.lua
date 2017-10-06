

function testlayer()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()


	
        local layerFarm = UILayer:create()

        -- add in farm background
		local bg = CCTMXTiledMap:create("map_fengdi.tmx")				--遮罩层
		bg:setPosition(ccp(visibleSize.width/2,visibleSize.height/2));
        layerFarm:addChild(bg)


        -- handing touch events
        local touchBeginPoint = nil

        local function onTouchBegan(x, y)
            touchBeginPoint = {x = x, y = y}
            return true
        end

        local function onTouchMoved(x, y)

            if touchBeginPoint then
                local cx, cy = layerFarm:getPosition()
                layerFarm:setPosition(cx + x - touchBeginPoint.x,
                                      cy + y - touchBeginPoint.y)
                touchBeginPoint = {x = x, y = y}
            end
        end

        local function onTouchEnded(x, y)
            print("onTouchEnded: %0.2f, %0.2f", x, y)
            touchBeginPoint = nil
        end

        local function onTouch(eventType, x, y)
            if eventType == "began" then   
                return onTouchBegan(x, y)
            elseif eventType == "moved" then
                return onTouchMoved(x, y)
            else
                return onTouchEnded(x, y)
            end
        end

        layerFarm:registerScriptTouchHandler(onTouch)
        layerFarm:setTouchEnabled(true)


		return layerFarm
		--g_sceneRoot:addChild(layerFarm)
end


local function onItemClick(parentScrollView,pos)
	print(pos)
end

local function setListViewAdapter(scrollView,ArrayDate,style)  --默认横的
	
	local DateLength = #ArrayDate
	local widgetWidth = 0;widgetHeight = 0
	for key,widget in pairs(ArrayDate) do 
		
		if style =="V" then		--竖的
			widgetHeight  = widgetHeight + widget:getSize().height
			widget:setAnchorPoint(ccp(0,(-1)*(key -1)))
			widget:setTag(DateLength - key)
		elseif style =="H" then  --横的
			widgetWidth  = widgetWidth + widget:getSize().width
			widget:setAnchorPoint(ccp((-1)*(key -1),0))
			widget:setTag(key-1)
		end
		widget:setTouchEnabled(true)
		widget:registerEventScript(function (EventType,widge)
			if EventType == "releaseUp" then
				onItemClick(scrollView,widget:getTag())
			end
		end)
		scrollView:addChild(widget)
	end
	
	if style =="V" then	
		scrollView:setDirection(SCROLLVIEW_DIR_VERTICAL)
		scrollView:setInnerContainerSize(CCSizeMake(scrollView:getSize().width,widgetHeight));
	elseif style == "H" then 
		scrollView:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		scrollView:setInnerContainerSize(CCSizeMake(widgetWidth,scrollView:getSize().height));
	end
end

function test2()
	local LayerRoot = UILayer:create()
	LayerRoot:addWidget(GUIReader:shareReader():widgetFromJsonFile("mainui_23.ExportJson"))
	
	g_uiRoot:addChild(LayerRoot)
end

-- UILayout 拖拽层测试
function test()	
	local LayerRoot = UILayer:create()
	LayerRoot:addWidget(GUIReader:shareReader():widgetFromJsonFile("mainui_23.ExportJson"))
	
	
	--test SocllView 
	local ScrollView =  LayerRoot:getWidgetByName("ScrollView_117")
	tolua.cast(ScrollView,"UIScrollView")
	
	print("ScrollView:size",ScrollView:getSize().width,"height",ScrollView:getSize().height)


	local BtnTable = {}
	
	
	for key = 1,5,1 do
		local imageView = UIImageView:create()
		imageView:loadTexture("monster2.png")
		table.insert(BtnTable,imageView)
	end
--[[	local imageView1 = UIImageView:create()
	imageView1:loadTexture("monster2.png")
	table.insert(BtnTable,imageView1)
	
	local imageView2 = UIImageView:create()
	imageView2:loadTexture("monster2.png")
	table.insert(BtnTable,imageView2)--]]

	--ScrollView:setClippingEnabled(true)
	setListViewAdapter(ScrollView,BtnTable,"H")
	
	--ScrollView:setInnerContainerSize(CCSizeMake(500,300)); --设置可以滑动范围
	
	
	
	local uiLayout =  LayerRoot:getWidgetByName("Panel_119")   --容器层
	--print("UILayout",UILayout)  			
	tolua.cast(uiLayout,"UILayout")
	--print("getContentSize",)

	local dragPanel = UIDragPanel:create()			--拖拽层
    dragPanel:setTouchEnabled(true);
    dragPanel:setBackGroundImageScale9Enabled(true);

    dragPanel:setSize(uiLayout:getContentSize());        

	

	local itemContent = GUIReader:shareReader():widgetFromJsonFile("drapview_1.ExportJson")
	itemContent:setAnchorPoint(ccp(0.5,0.5))		
	local imageView = UIImageView:create();    
	imageView:setTouchEnabled(true);
	imageView:loadTexture("bg.jpg")
	imageView:addChild(itemContent)
	
	--local sprite = CCSprite:create("bg.jpg")
	--sprite:setColor(ccc3(255,0,0))
	--imageView:addRenderer(sprite,10)
	local function onClickEvent(widget,Type)	
		print(Type)
	end
	
	local button = itemContent:getChildByName("Button_124_1")
	button:registerEventScript(onClickEvent)
  
    dragPanel:addChild(imageView);	        
    dragPanel:setInnerContainerSize(itemContent:getSize())		--设置他可滑动的范围  !! 关键
	
	print("w:",imageView:getContentSize().width,"h:",imageView:getContentSize().height)
	
    innerSize = dragPanel:getInnerContainerSize();
    imageView:setPosition(ccp(innerSize.width / 2, innerSize.height / 2));  

	uiLayout:addChild(dragPanel)
	g_uiRoot:addChild(LayerRoot)
end

function testNet() 
	-- lua  多线程下载文件  （~测试）
	require "socket"
	mHost = "www.w3.org"
	file = "/TR/REC-html32.html"
	print(2^10)
	
	testfile = io.open("testNet.txt","w")
	
	local c = assert(socket.connect(mHost, 80))
	local count = 0
	if c == nil	then print("connect  error!!!") end
	c:send("GET"..file.."HTTP/1.0\r\n\r\n")
	while true do 
		--print("partial____before",partial)
		local s, status,partial = c:receive(2^10)
		count = count + #(s or partial)
		--print("partial",partial,"status",status)
		--print("s:",s)
		--print("status:",status)
		--print("partial:",partial)
		io.write(s or partial)
		print("testPrint",s or partial)
		testfile:write(s or partial)
		if status == "closed" then break end
	end
	testfile:close()
	print("close socket",count)
	c:close()
	
int main(int argc,char** argv)
{
	
}	
	
--[[	local function Receive(connection)
		connection:settimeout(0)
		local s,status,partial = connection:receive(3)
		print("s:",s)
		if status == "timeout" then 
			coroutine.yield(connection)
		end
		return s or partial,status
	end
	
	local function downLoad(host,file)
		--local c = assert(socket.connect("10.0.0.194", 8001))
		local c = assert(socket.connect(host, 80))
		local count = 0 -- 记入收到的字节数数
	--c:settimeout(3)
		c:send("GET"..file.."HTTP/1.0\r\n\r\n")

		while true do
			local s, status,partial = Receive(c)
			count = count + #(s or partial)
			if status == "close" then break end 
		end
		c:close()
	end
	
	
	
	local threads = {}
	
	local function get ()
		-- create coroutine 
		local co = coroutine.create( function downLoad() end)
			table.insert(threads,co)
		end
	end
	
	local function dispatch()
		local i = 1
		local = connection = {}
		while true do 
			if threads[i] == nil then
				if threads[i] == nil then break 
				i = 1
				end
			end
			local status,res = coroutine.resume(threads[i])
			if not res then  -- 这个线程 已经完成了？
				table.remove(threads,i)
			else
				i = i + 1
				connections[#connections + 1] = res
				if #connections == #threads then
					socket.select(connections)
				end
			end
		end
	end--]]
	

	--print("s:",s)
	--print("status:",status)
	--print("partial:",partial)
	--get()
	
end
