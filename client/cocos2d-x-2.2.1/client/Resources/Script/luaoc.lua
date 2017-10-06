local luaoc = {}

function luaoc.callStaticMethod(className, methodName, args)
	print("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\"", className, methodName, tostring(args))
	local ok, ret = CCLuaObjcBridge.callStaticMethod(className, methodName, args)
	if not ok then
		local msg = string.format("error: [%s] ", tostring(ret))
		if ret == -1 then
			print(msg.."INVALID PARAMETERS")
		elseif ret == -2 then
			print(msg.."CLASS NOT FOUND")
		elseif ret == -3 then
			print(msg.."METHOD NOT FOUND")
		elseif ret == -4 then
			print(msg.."EXCEPTION OCCURRED")
		elseif ret == -5 then
			print(msg.."INVALID METHOD SIGNATURE")
		else
			print(msg.."UNKNOWN")
		end
	end
	return ok, ret
end

return luaoc
