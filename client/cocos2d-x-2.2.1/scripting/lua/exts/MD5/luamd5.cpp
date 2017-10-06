/**********************************************************************
* Author:	jaron.ho
* Date:		2014-06-1
* Brief:	used in lua for md5
**********************************************************************/
#include "luamd5.h"
#include "MD5.h"


int lua_md5_crypto(lua_State* L)
{
	const char *data = (char*)luaL_checkstring(L, 1);
	unsigned int dataSize = (unsigned int)luaL_checknumber(L, 2);
	if (NULL == data || 0 == dataSize)
		return 0;
	
	char *str = MD5_sign((unsigned char*)data, dataSize);
	lua_pushstring(L, str);
	return 1;
}

int luaopen_md5(lua_State* L)
{
	lua_register(L, "md5_crypto", lua_md5_crypto);
	return 0;
}
