/**********************************************************************
* Author:	jaron.ho
* Date:		2014-05-10
* Brief:	used in lua for system time
**********************************************************************/
#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

extern int luaopen_systemtime(lua_State* L);

#ifdef __cplusplus
}
#endif
#include "tolua++.h"
