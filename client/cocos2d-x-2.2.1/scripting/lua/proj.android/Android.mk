LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := cocos_lua_static

LOCAL_MODULE_FILENAME := liblua

LOCAL_SRC_FILES := ../cocos2dx_support/CCLuaBridge.cpp \
		  ../cocos2dx_support/platform/android/CCLuaJavaBridge.cpp \
		  ../cocos2dx_support/platform/android/org_cocos2dx_lib_Cocos2dxLuaJavaBridge.cpp \
          ../cocos2dx_support/CCLuaEngine.cpp \
          ../cocos2dx_support/CCLuaStack.cpp \
          ../cocos2dx_support/CCLuaValue.cpp \
          ../cocos2dx_support/Cocos2dxLuaLoader.cpp \
          ../cocos2dx_support/LuaCocos2d.cpp \
          ../cocos2dx_support/CCBProxy.cpp \
		  ../cocos2dx_support/Proxy.cpp \
		  ../cocos2dx_support/Lewis.cpp \
		  ../cocos2dx_support/save_xml.cpp \
          ../cocos2dx_support/Lua_extensions_CCB.cpp \
          ../cocos2dx_support/Lua_web_socket.cpp \
          ../cocos2dx_support/lua_cocos2dx_extensions_manual.cpp \
          ../tolua/tolua_event.c \
          ../tolua/tolua_is.c \
          ../tolua/tolua_map.c \
          ../tolua/tolua_push.c \
          ../tolua/tolua_to.c \
          ../cocos2dx_support/tolua_fix.c \
		  ../exts/luasocket/auxiliar.c \
		  ../exts/luasocket/buffer.c \
		  ../exts/luasocket/except.c \
		  ../exts/luasocket/inet.c	\
		  ../exts/luasocket/io.c	\
		  ../exts/luasocket/luasocket.c \
		  ../exts/luasocket/mime.c \
		  ../exts/luasocket/options.c \
		  ../exts/luasocket/select.c \
		  ../exts/luasocket/tcp.c \
		  ../exts/luasocket/timeout.c \
		  ../exts/luasocket/udp.c \
		  ../exts/luasocket/unix.c \
		  ../exts/luasocket/usocket.c \
		  ../exts/luaxml/luaxml.cpp \
		  ../exts/luaxml/rapidxml/rapidxml.hpp \
		  ../exts/luaxml/rapidxml/rapidxml_iterators.hpp \
		  ../exts/luaxml/rapidxml/rapidxml_print.hpp \
		  ../exts/luaxml/rapidxml/rapidxml_utils.hpp \
		  ../exts/luacsv/luacsv.cpp \
		  ../exts/AES/AES.cpp \
		  ../exts/RC4/RC4.c \
		  ../exts/RC4/luarc4.c \
		  ../exts/MD5/MD5.cpp \
		  ../exts/MD5/luamd5.cpp \
		  ../exts/PacketCrypto/PacketCrypto.c \
		  ../exts/PacketCrypto/luarpacketcrypto.c \
		  ../exts/lualoadexts.c \
		  ../exts/StringFilter/TrieNode.cpp \
		  ../exts/StringFilter/Trie.cpp \
		  ../exts/StringFilter/StringFilter.cpp \
		  ../exts/StringFilter/luastringfilter.cpp \
		  ../exts/luatime/luatime.c
		  
          
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../luajit/include \
                           $(LOCAL_PATH)/../tolua \
                           $(LOCAL_PATH)/../cocos2dx_support \
						   $(LOCAL_PATH)/../cocos2dx_support/platform/android \
						   $(LOCAL_PATH)/../exts \
						   $(LOCAL_PATH)/../exts/lpack \
						   $(LOCAL_PATH)/../exts/luasocket \
						   $(LOCAL_PATH)/../exts/luaxml \
						   $(LOCAL_PATH)/../exts/luaxml/rapidxml \
						   $(LOCAL_PATH)/../exts/luacsv \
						   $(LOCAL_PATH)/../exts/AES \
						   $(LOCAL_PATH)/../exts/RC4 \
						   $(LOCAL_PATH)/../exts/MD5 \
						   $(LOCAL_PATH)/../exts/PacketCrypto \
						   $(LOCAL_PATH)/../exts/StringFilter \
						   $(LOCAL_PATH)/../exts/luatime
          
          
LOCAL_C_INCLUDES := $(LOCAL_PATH)/ \
                    $(LOCAL_PATH)/../luajit/include \
                    $(LOCAL_PATH)/../tolua \
                    $(LOCAL_PATH)/../cocos2dx_support \
					$(LOCAL_PATH)/../cocos2dx_support/platform/android \
                    $(LOCAL_PATH)/../../../cocos2dx \
                    $(LOCAL_PATH)/../../../cocos2dx/include \
                    $(LOCAL_PATH)/../../../cocos2dx/platform \
                    $(LOCAL_PATH)/../../../cocos2dx/platform/android \
                    $(LOCAL_PATH)/../../../cocos2dx/kazmath/include \
                    $(LOCAL_PATH)/../../../CocosDenshion/include \
                    $(LOCAL_PATH)/../../../extensions \
					$(LOCAL_PATH)/../cocos2dx_support \
					$(LOCAL_PATH)/../exts \
					$(LOCAL_PATH)/../exts/lpack \
					$(LOCAL_PATH)/../exts/luasocket \
					$(LOCAL_PATH)/../exts/luaxml \
					$(LOCAL_PATH)/../exts/luaxml/rapidxml \
					$(LOCAL_PATH)/../exts/luacsv \
					$(LOCAL_PATH)/../exts/AES \
					$(LOCAL_PATH)/../exts/RC4 \
					$(LOCAL_PATH)/../exts/MD5 \
					$(LOCAL_PATH)/../exts/PacketCrypto \
					$(LOCAL_PATH)/../exts/StringFilter \
					$(LOCAL_PATH)/../exts/luatime

LOCAL_WHOLE_STATIC_LIBRARIES := luajit_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

include $(BUILD_STATIC_LIBRARY)

$(call import-module,scripting/lua/luajit)
$(call import-module,extensions)
