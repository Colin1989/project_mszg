---------------
---发送http请求
---@author shenl
---------------

local mhttpMsgRegistry = {} -- HTTP消息注册表

local function getMd5String(sortTb,paramTb)
	local str = ""
	for key,value in pairs(sortTb) do
		if value ~= "sign" then -- 防止2次加密
			str = str..tostring(paramTb[value])
		end
	end 
	local md5String = md5_crypto(str, string.len(str))
	return md5String
end 

local function makeFinalParam(FinalParamTb)
	local index = 1
	local mParam = ""
	for k,v in pairs(FinalParamTb) do
		if index == 1 then 
			mParam = mParam..k.."="..tostring(v)
		else
			mParam = mParam.."&"..k.."="..tostring(v)
		end
		index = index + 1
	end
	return mParam
end


local function set_PostParam (paramTb) 
	local indexTb = {}
	for key,value in pairs(paramTb) do
		table.insert(indexTb,key)
	end 	
	table.sort(indexTb, function(a, b) 
		return a < b
	end)	
	local md5Str = getMd5String(indexTb,paramTb)
	paramTb["sign"] = md5Str
	
	local finalKeyValueParam = makeFinalParam(paramTb)
	return finalKeyValueParam
end

NetHttp = {}

local function showSys(errorCode)

	local errorTb = LogicTable.getErrorById(errorCode)
	
	if errorTb == nil then		
		Toast.show("系统出错")
		return 
	end
	
	Toast.show(errorTb.text)
end 

NetHttp.send_ByPost =  function(msgId,param,callback,failCallBack,timeOutCallBack)
	local proxy = Proxy:new()
	local finalParam = set_PostParam(param)
	local url = mhttpMsgRegistry[msgId]
	
	NetSendLoadLayer.show()
	
	if url == nil then 
		print("Http_Message:"..msgId.."no registration !")
		return 
	end 
	print("Send_Http-------->:","Url:",url,"Param:",finalParam)
	proxy:HttpSendInScript(g_rootNode,url,finalParam,function(josnStr)
	
		NetSendLoadLayer.dismiss()
		print("Http Recv-------->:",josnStr)
		if josnStr == nil or josnStr == "" then 
			print("Http_Error_no_host_or_timeOut");
			if timeOutCallBack~= nil and type(timeOutCallBack) == "function" then 
				timeOutCallBack()
			end
			return
		end
		local resp = CommonFunc_decodeJsonStr(josnStr)
		if resp["success"] == true then 
			if callback~= nil and type(callback) == "function" then 
				callback(resp)	
			end 
		else
			print("Http_Error_code!!!",resp.code)
			showSys(resp.code)
			if failCallBack~= nil and type(failCallBack) == "function" then 
				failCallBack(resp)
			end 
		end
	end)
end 



NetHttp.initMsg = function()

end

--msgId : 消息
NetHttp.register =  function(addr,msgId)

	local url = string.format(addr,msgId)
	print("NetHttp->Message->register:",url)
	mhttpMsgRegistry[msgId] = url
	table.insert(mhttpMsgRegistry,tb)
end




--[[
NetHttp.sendAndWati_ByPost = function(url,param,callback)
	NetHttp.send_ByPost("http://10.0.0.49:8081/txz/pass/regist.html",
	--NetHttp.send_ByPost("http://10.0.0.163:8080/txz/pass/regist.html",
	regisiterParam,
	function(resp)
		CommonFunc_CreateDialog( GameString.get("RegisSuc"))
	end)
end 
]]--






















