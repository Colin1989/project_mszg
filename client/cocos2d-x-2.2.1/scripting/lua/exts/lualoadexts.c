#include "lualoadexts.h"
#include "luasocket.h"
#include "mime.h"
#include "lpack.h"
#include "luaxml.h"
#include "luacsv.h"
#include "luarc4.h"
#include "luamd5.h"
#include "luarpacketcrypto.h"
#include "luastringfilter.h"
#include "luatime.h"

static luaL_Reg luax_preload_list[] = 
{
	{"socket.core", luaopen_socket_core},
	{"mime.core", luaopen_mime_core},
	{NULL, NULL}
};

void luax_initpreload(lua_State *L)
{
	luaL_Reg* lib = luax_preload_list;
	luaL_findtable(L, LUA_GLOBALSINDEX, "package.preload", sizeof(luax_preload_list)/sizeof(luax_preload_list[0]) - 1);
	for (; lib->func; lib++)
	{
		lua_pushstring(L, lib->name);
		lua_pushcfunction(L, lib->func);
		lua_rawset(L, -3);
	}
	lua_pop(L, 1);
	
	luaopen_pack(L);
	luaopen_xml(L);
	luaopen_csv(L);
	luaopen_rc4(L);
	luaopen_md5(L);
	luaopen_packetcrypto(L);
	luaopen_stringfilter(L);
	luaopen_systemtime(L);
}

