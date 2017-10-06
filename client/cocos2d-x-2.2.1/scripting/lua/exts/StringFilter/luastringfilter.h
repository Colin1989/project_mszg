/**********************************************************************
* Author:	jaron.ho
* Date:		2014-04-10
* Brief:	used in lua for string filter
**********************************************************************/
#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

extern int luaopen_stringfilter(lua_State* L);

#ifdef __cplusplus
}
#endif
#include "tolua++.h"
