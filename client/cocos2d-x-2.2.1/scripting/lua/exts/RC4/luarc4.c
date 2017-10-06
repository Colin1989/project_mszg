/**********************************************************************
* Author:	jaron.ho
* Date:		2014-03-25
* Brief:	used in lua for crypto with algorithm RC4
**********************************************************************/
#include "luarc4.h"
#include "RC4.h"
#include <memory.h>
#include <stdlib.h>


int lua_rc4_crypto(lua_State* L)
{
	const char *data = (char*)luaL_checkstring(L, 1);
	unsigned long dataSize = (unsigned long)luaL_checklong(L, 2);
	const char *key = (char*)luaL_checkstring(L, 3);
	char *input = NULL;

	if (NULL == data || 0 == dataSize)
		return 0;

	if (NULL == key)
	{
		lua_pushstring(L, data);
		return 1;
	}

	input = (char*)malloc((dataSize + 1)*sizeof(char));
	memset(input, 0, dataSize + 1);
	memcpy(input, data, dataSize);
	rc4_crypto(input, dataSize, key);
	lua_pushstring(L, input);
	free(input);
	input = NULL;
	return 1;
}

int luaopen_rc4(lua_State* L)
{
	lua_register(L, "rc4_crypto", lua_rc4_crypto);
	return 0;
}
