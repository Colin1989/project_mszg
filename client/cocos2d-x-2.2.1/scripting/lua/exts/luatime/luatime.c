/**********************************************************************
* Author:	jaron.ho
* Date:		2014-05-10
* Brief:	used in lua for system time
**********************************************************************/
#include "luatime.h"
#ifdef _WIN32
#include <windows.h>
#else
#include <time.h>
#include <sys/time.h>
#endif


double system_gettime(void)
{
#ifdef _WIN32
	FILETIME ft;
	double t;
	GetSystemTimeAsFileTime(&ft);
	/* Windows file time (time since January 1, 1601 (UTC)) */
	t = ft.dwLowDateTime/1.0e7 + ft.dwHighDateTime*(4294967296.0/1.0e7);
	/* convert to Unix Epoch time (time since January 1, 1970 (UTC)) */
	return (t - 11644473600.0);
#else
	struct timeval v;
	gettimeofday(&v, (struct timezone*)NULL);
	/* Unix Epoch time (time since January 1, 1970 (UTC)) */
	return v.tv_sec + v.tv_usec/1.0e6;
#endif
}

int lua_system_gettime(lua_State* L)
{
	double systime = system_gettime();
	lua_pushnumber(L, systime);

	return 1;
}

int luaopen_systemtime(lua_State* L)
{
	lua_register(L, "system_gettime", lua_system_gettime);
	return 0;
}
