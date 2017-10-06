/**********************************************************************
* Author:	jaron.ho
* Date:		2014-03-21
* Brief:	used in lua for parse .csv file
**********************************************************************/
#pragma once

#ifdef __cplusplus
extern "C"
{
#endif
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"

	extern int luaopen_csv(lua_State* L);
#ifdef __cplusplus
}
#endif
#include "tolua++.h"
