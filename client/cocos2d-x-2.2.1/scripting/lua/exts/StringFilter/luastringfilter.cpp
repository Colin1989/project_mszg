/**********************************************************************
* Author:	jaron.ho
* Date:		2014-04-10
* Brief:	used in lua for string filter
**********************************************************************/
#include "luastringfilter.h"
#include "StringFilter.h"
#include "Cocos2dxLuaLoader.h"

using namespace cocos2d;

static StringFilter s_string_filter;

int string_filter_init(lua_State* L)
{
	const char *filename = (char*)luaL_checkstring(L, 1);
	if (NULL == filename)
	{
		const char *szBuf = "error in function 'string_filter_init', filename is nil";
		showError(szBuf);
		CCLOG("%s", szBuf);

		return 0;
	}
    const std::string &filedata = decrypt_file(filename, check_need_decrypt());
	bool res = s_string_filter.parse(filedata.c_str());
	lua_pushboolean(L, res ? 1 : 0);
	return 1;
}

int string_filter_shield(lua_State* L)
{
	const char *str = (char*)luaL_checkstring(L, 1);
	if (NULL == str)
		return 0;

	const char *mask = (char*)luaL_checkstring(L, 2);
	const std::string &dest = s_string_filter.censor(str, NULL == mask ? '*' : *mask);
	lua_pushstring(L, dest.c_str());
	return 1;
}

int luaopen_stringfilter(lua_State* L)
{
	lua_register(L, "string_filter_init", string_filter_init);
	lua_register(L, "string_filter_shield", string_filter_shield);
	return 0;
}
