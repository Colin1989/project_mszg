/**********************************************************************
* Author:	jaron.ho
* Date:		2014-02-14
* Brief:	资源下载
**********************************************************************/
#include "ResDownload.h"
#include "CCLuaEngine.h"


std::string getDownloadPath(const std::string& dir)
{
	std::string downloadPath = CCFileUtils::sharedFileUtils()->getWritablePath() + dir + "/";	// 这里必须用反斜杠
	// step1: 创建搜索目录
	FileDownload::createDir(downloadPath);
	// step2: 设置搜索路径
	std::vector<std::string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
	std::vector<std::string>::iterator iter = std::find(searchPaths.begin(), searchPaths.end(), downloadPath);
	if (searchPaths.end() != iter)
	{
		searchPaths.erase(iter);
	}
	searchPaths.insert(searchPaths.begin(), downloadPath);
	CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);
	return downloadPath;
}

void createNativeFile(const std::string& path, const std::string& filename)
{
	if (ResourceUpdate::existFile(path + filename))
		return;

	unsigned long length = 0;
	char *buffer = (char*)CCFileUtils::sharedFileUtils()->getFileData(filename.c_str(), "rb", &length);
	if (NULL == buffer)
		return;

	std::string str(buffer);
	str = str.substr(0, length);
	ResourceUpdate::writeDataToFile(str.c_str(), str.size(), path + filename);
	delete buffer;
	buffer = NULL;
}

/**********************************************************************
************************** c++调lua接口
**********************************************************************/

const char* lua_callGlobalFunc(lua_State* L, const char* globalFuncName, const char* sig, ...)
{
	static char errorbuffer[512];
	memset(errorbuffer, 0, sizeof(errorbuffer));
	if (NULL == L || NULL == globalFuncName || 0 == strcmp(globalFuncName, "") || NULL == sig)
	{
		sprintf(errorbuffer, "invalid args");
		return errorbuffer;
	}
	lua_getglobal(L, globalFuncName);		// get function
	va_list vl; 
	va_start(vl, sig);
	int narg = 0;							// number of arguments
	while (*sig)							// push arguments
	{
		switch (*sig++)
		{
		case 'i': lua_pushnumber(L, va_arg(vl, int)); break;					// int argument
		case 'l': lua_pushnumber(L, va_arg(vl, long)); break;					// long argument
		case 'd': lua_pushnumber(L, va_arg(vl, double)); break;					// double argument
		case 's': lua_pushstring(L, va_arg(vl, const char*)); break;			// string argument
		case 'b': lua_pushboolean(L, va_arg(vl, int) > 0); break;				// bool argument
		case '>': goto endwhile;
		default: sprintf(errorbuffer, "invalid option (%c)", *(sig - 1)); return errorbuffer;
		}
		narg++;
		luaL_checkstack(L, 1, "too many arguments");
	} endwhile:
	int nres = strlen(sig);					// number of expected results
	if (0 != lua_pcall(L, narg, nres, 0))	// call function
	{
		sprintf(errorbuffer, "error running function '%s': %s", globalFuncName, lua_tostring(L, -1));
		return errorbuffer;
	}
	nres = -nres;							// stack index of first result
	while (*sig)							// get results
	{
		switch (*sig++)
		{
		case 'i': if (lua_isnumber(L, nres)) { *va_arg(vl, int*) = (int)lua_tonumber(L, nres); } break;						// int result
		case 'l': if (lua_isnumber(L, nres)) { *va_arg(vl, long*) = (long)lua_tonumber(L, nres); } break;					// long result
		case 'd': if (lua_isnumber(L, nres)) { *va_arg(vl, double*) = (double)lua_tonumber(L, nres); } break;				// double result
		case 's': if (lua_isstring(L, nres)) { *va_arg(vl, const char**) = lua_tostring(L, nres); } break;					// string result
		case 'b': if (lua_isboolean(L, nres)) { *va_arg(vl, bool*) = 0 == lua_toboolean(L, nres) ? false : true; } break;	// bool result
		default: sprintf(errorbuffer, "invalid option (%c)", *(sig - 1)); return errorbuffer;
		}
		nres++;
	}
	va_end(vl);
	return errorbuffer;
}

static int interface_create_dir(lua_State* L)
{
	const char *dirName = (char*)luaL_checkstring(L, 1);
	bool res = FileDownload::createDir(dirName);
	lua_pushboolean(L, res ? 1: 0);
	return 1;
}

static int interface_remove_dir(lua_State* L)
{
	const char *dirName = (char*)luaL_checkstring(L, 1);
	FileDownload::removeDir(dirName);
	return 0;
}

void lua_open_interface(lua_State* L)
{
	// 透露接口给lua
	static const luaL_reg R[] =
	{
		{"createDir",			interface_create_dir},
		{"removeDir",			interface_remove_dir},
		{NULL,	NULL}
	};
	luaL_openlib(L, "Interface", R, 0);
}

/**********************************************************************
************************** 资源下载模块
**********************************************************************/

ResDownload::ResDownload(const std::string& downloadDir)
{
	mFileDownload.setStoragePath(downloadDir);
	mFileDownload.setConnectTimeout(0);
	mFileDownload.setDownloadTimeout(0);
	mFileDownload.setListener(this);
	mLuaState = NULL;
}

ResDownload::~ResDownload(void)
{
}

void ResDownload::onProgress(FileDownloadCode code, const std::string& fileURL, const std::string& buffer, double totalToDownload, double nowDownloaded)
{
	if (FDC_FILE_PROGRESS == code)
	{
		lua_callGlobalFunc(mLuaState, mProgressFuncName.c_str(), "ssdd", fileURL.c_str(), buffer.c_str(), totalToDownload, nowDownloaded);
	}
	else if (FDC_LIST_PROGRESS == code)
	{
		lua_callGlobalFunc(mLuaState, mTotalProgressFuncName.c_str(), "ssdd", fileURL.c_str(), buffer.c_str(), totalToDownload, nowDownloaded);
	}
}

void ResDownload::onSuccess(FileDownloadCode code, const std::string& fileURL, const std::string& buffer)
{
	if (FDC_FILE_SUCCESS == code)
	{
		lua_callGlobalFunc(mLuaState, mSuccessFuncName.c_str(), "ss", fileURL.c_str(), buffer.c_str());
	}
	else if (FDC_LIST_SUCCESS == code)
	{
		lua_callGlobalFunc(mLuaState, mTotalSuccessFuncName.c_str(), "ss", fileURL.c_str(), buffer.c_str());
	}
}

void ResDownload::onError(FileDownloadCode code, const std::string& fileURL, const std::string& buffer)
{
	if (FDC_LIST_ERROR == code)
	{
		lua_callGlobalFunc(mLuaState, mErrorFuncName.c_str(), "ss", fileURL.c_str(), buffer.c_str());
	}
}

void ResDownload::listen(void)
{
	mFileDownload.listenMessage();
}

void ResDownload::excute(const std::vector<std::string>& fileUrlVec)
{
	if (fileUrlVec.empty())
		return;

	mFileDownload.download(fileUrlVec);
}

void ResDownload::openLua(lua_State* L)
{
	mLuaState = L;
}

void ResDownload::registerLuaHandler(ResDownloadListenerType listenerType, const std::string& globalFuncName)
{
	switch (listenerType)
	{
	case RDLT_PROGRESS: mProgressFuncName = globalFuncName; break;
	case RDLT_SUCCESS: mSuccessFuncName = globalFuncName; break;
	case RDLT_TOTAL_PROGRESS: mTotalProgressFuncName = globalFuncName; break;
	case RDLT_TOTAL_SUCCESS: mTotalSuccessFuncName = globalFuncName; break;
	case RDLT_ERROR: mErrorFuncName = globalFuncName; break;
	}
}

static ResDownload *sResDownload = NULL;

static int res_download_listen(lua_State* L)
{
	if (sResDownload)
	{
		sResDownload->listen();
	}
	return 0;
}

static int res_download_excute(lua_State* L)
{
	const char *fileUrl = (char*)luaL_checkstring(L, 1);
	std::vector<std::string> urlVec;
	urlVec.push_back(fileUrl);
	if (sResDownload)
	{
		sResDownload->excute(urlVec);
	}
	return 0;
}

static int res_download_addListener(lua_State* L)
{
	int listenerType = (int)luaL_checknumber(L, 1);
	const char *globalFuncName = (char*)luaL_checkstring(L, 2);
	if (sResDownload)
	{
		sResDownload->registerLuaHandler((ResDownloadListenerType)listenerType, NULL == globalFuncName ? "" : globalFuncName);
	}
	return 0;
}

void lua_open_resdownload(lua_State* L, const std::string& path)
{
	if (sResDownload)
		return;

	// 透露接口给lua
	static const luaL_reg R[] =
	{
		{"listen",			res_download_listen},
		{"excute",			res_download_excute},
		{"addListener",		res_download_addListener},
		{NULL,	NULL}
	};
	luaL_openlib(L, "ResDownload", R, 0);
	// 实例化
	std::string downloadDir = getDownloadPath(path);
	sResDownload = new ResDownload(downloadDir);
	sResDownload->openLua(L);
}

/**********************************************************************
************************** 资源更新模块
**********************************************************************/

ResUpdate::ResUpdate(const std::string& downloadDir, const std::string& nativeVersionFile, const std::string& nativeMd5File)
{
	mResourceUpdate = new ResourceUpdate(downloadDir, 0, 0, nativeVersionFile, nativeMd5File, this);
	mLuaState = NULL;
}

ResUpdate::~ResUpdate(void)
{
	if (mResourceUpdate)
	{
		delete mResourceUpdate;
		mResourceUpdate = NULL;
	}
}

void ResUpdate::onCheckVersionFailed(const std::string& errorBuffer)
{
	lua_callGlobalFunc(mLuaState, mCheckVersionFailedFuncName.c_str(), "s", errorBuffer.c_str());
}

void ResUpdate::onNewVersion(const std::string& curVersion, const std::string& newVersion)
{
	lua_callGlobalFunc(mLuaState, mNewVersionFuncName.c_str(), "ss", curVersion.c_str(), newVersion.c_str());
}

void ResUpdate::onNoNewVersion(const std::string& curVersion)
{
	lua_callGlobalFunc(mLuaState, mNoNewVersionFuncName.c_str(), "s", curVersion.c_str());
}

void ResUpdate::onCheckUpdateListFailed(const std::string errorBuffer)
{
	lua_callGlobalFunc(mLuaState, mCheckUpdateListFailedFuncName.c_str(), "s", errorBuffer.c_str());
}

void ResUpdate::onUpdateList(long updateCount, long updateSize)
{
	lua_callGlobalFunc(mLuaState, mUpdateListFuncName.c_str(), "ll", updateCount, updateSize);
}

void ResUpdate::onNoUpdateList(void)
{
	lua_callGlobalFunc(mLuaState, mNoUpdateListFuncName.c_str(), "");
}

void ResUpdate::onPogress(const std::string& fileURL, double totalSize, double curSize)
{
	lua_callGlobalFunc(mLuaState, mProgressFuncName.c_str(), "sdd", fileURL.c_str(), totalSize, curSize);
}

void ResUpdate::onSuccess(const std::string& fileURL)
{
	lua_callGlobalFunc(mLuaState, mSuccessFuncName.c_str(), "s", fileURL.c_str());
}

void ResUpdate::onTotalProgress(const std::string& fileURL, int totalCount, int curCount)
{
	lua_callGlobalFunc(mLuaState, mTotalProgressFuncName.c_str(), "sii", fileURL.c_str(), totalCount, curCount);
}

void ResUpdate::onTotalSuccess(void)
{
	lua_callGlobalFunc(mLuaState, mTotalSuccessFuncName.c_str(), "");
}

void ResUpdate::onError(const std::string& fileURL, const std::string& errorBuffer)
{
	lua_callGlobalFunc(mLuaState, mErrorFuncName.c_str(), "ss", fileURL.c_str(), errorBuffer.c_str());
}

void ResUpdate::listen(void)
{
	if (mResourceUpdate)
	{
		mResourceUpdate->listen();
	}
}

void ResUpdate::checkVersion(const std::string& url, const std::string& versionCheckFile, const std::string& md5CheckFile)
{
	if (mResourceUpdate)
	{
		mResourceUpdate->checkVersion(url, versionCheckFile, md5CheckFile);
	}
}

void ResUpdate::checkUpdate(void)
{
	if (mResourceUpdate)
	{
		mResourceUpdate->checkUpdate();
	}
}

void ResUpdate::startUpdate(void)
{
	if (mResourceUpdate)
	{
		mResourceUpdate->startUpdate();
	}
}

void ResUpdate::record(void)
{
	if (mResourceUpdate)
	{
		mResourceUpdate->record();
	}
}

void ResUpdate::openLua(lua_State* L)
{
	mLuaState = L;
}

void ResUpdate::registerLuaHandler(ResUpdateListenerType listenerType, const std::string& globalFuncName)
{
	switch (listenerType)
	{
	case RULT_CHECK_VERSION_FAILED: mCheckVersionFailedFuncName = globalFuncName; break;
	case RULT_NEW_VERSION: mNewVersionFuncName = globalFuncName; break;
	case RULT_NO_NEW_VERSION: mNoNewVersionFuncName = globalFuncName; break;
	case RULT_CHECK_UPDATE_LIST_FAILED: mCheckUpdateListFailedFuncName = globalFuncName; break;
	case RULT_UPDATE_LIST: mUpdateListFuncName = globalFuncName; break;
	case RULT_NO_UPDATE_LIST: mNoUpdateListFuncName = globalFuncName; break;
	case RULT_PROGRESS: mProgressFuncName = globalFuncName; break;
	case RULT_SUCCESS: mSuccessFuncName = globalFuncName; break;
	case RULT_TOTAL_PROGRESS: mTotalProgressFuncName = globalFuncName; break;
	case RULT_TOTAL_SUCCESS: mTotalSuccessFuncName = globalFuncName; break;
	case RULT_ERROR: mErrorFuncName = globalFuncName; break;
	}
}

static ResUpdate *sResUpdate = NULL;

static int res_update_listen(lua_State* L)
{
	if (sResUpdate)
	{
		sResUpdate->listen();
	}
	return 0;
}

static int res_update_check_version(lua_State* L)
{
	const char *url = (char*)luaL_checkstring(L, 1);
	const char *checkVersionFile = (char*)luaL_checkstring(L, 2);
	const char *checkMd5File = (char*)luaL_checkstring(L, 3);
	if (sResUpdate)
	{
		sResUpdate->checkVersion(url, checkVersionFile, checkMd5File);
	}
	return 0;
}

static int res_update_check_update(lua_State* L)
{
	if (sResUpdate)
	{
		sResUpdate->checkUpdate();
	}
	return 0;
}

static int res_update_start_update(lua_State* L)
{
	if (sResUpdate)
	{
		sResUpdate->startUpdate();
	}
	return 0;
}

static int res_update_record(lua_State* L)
{
	if (sResUpdate)
	{
		sResUpdate->record();
	}
	return 0;
}

static int res_update_addListener(lua_State* L)
{
	int listenerType = (int)luaL_checknumber(L, 1);
	const char *globalFuncName = (char*)luaL_checkstring(L, 2);
	if (sResUpdate)
	{
		sResUpdate->registerLuaHandler((ResUpdateListenerType)listenerType, NULL == globalFuncName ? "" : globalFuncName);
	}
	return 0;
}

void lua_open_resupdate(lua_State *L, const std::string& path, const std::string& nativeVersion, const std::string& nativeFileList)
{
	if (sResUpdate)
		return;

	// 透露接口给lua
	static const luaL_reg R[] =
	{
		{"listen",			res_update_listen},
		{"checkVersion",	res_update_check_version},
		{"checkUpdate",		res_update_check_update},
		{"startUpdate",		res_update_start_update},
		{"record",			res_update_record},
		{"addListener",		res_update_addListener},
		{NULL,	NULL}
	};
	luaL_openlib(L, "ResUpdate", R, 0);
	// 实例化
	std::string downloadDir = getDownloadPath(path);
	createNativeFile(downloadDir, nativeVersion);
	createNativeFile(downloadDir, nativeFileList);
	sResUpdate = new ResUpdate(downloadDir, nativeVersion, nativeFileList);
	sResUpdate->openLua(L);
}

