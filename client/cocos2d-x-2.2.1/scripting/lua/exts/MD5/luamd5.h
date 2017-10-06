/**********************************************************************
* Author:	jaron.ho
* Date:		2014-06-1
* Brief:	used in lua for md5
**********************************************************************/
#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

extern int luaopen_md5(lua_State* L);

#ifdef __cplusplus
}
#endif
#include "tolua++.h"
