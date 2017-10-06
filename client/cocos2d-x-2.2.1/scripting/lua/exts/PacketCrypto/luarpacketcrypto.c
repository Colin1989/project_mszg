/**********************************************************************
* Author:	jaron.ho
* Date:		2014-03-25
* Brief:	used in lua for packet crypto
**********************************************************************/
#include "luarpacketcrypto.h"
#include "PacketCrypto.h"
#include <memory.h>
#include <stdlib.h>


#define XOR_KEY		0x2FDB3CED		// 此密钥应与客户端保持一致,定期更换
#define SHIFT_KEY	0xAFD33C8D		// 此密钥应与客户端保持一致,定期更换
static unsigned char s_encode_count = 0;

int packet_crypto_init(lua_State* L)
{
	s_encode_count = 0;
	PacketCryptoInit();
	return 0;
}

int packet_crypto_encode(lua_State* L)
{
	const char *data = (char*)luaL_checkstring(L, 1);
	unsigned long dataSize = (unsigned long)luaL_checklong(L, 2);
	unsigned int destSize = 0;
	char *dest = NULL;

	if (NULL == data)
		return 0;

	dest = PacketCryptoEncode(data, dataSize, &destSize, XOR_KEY, SHIFT_KEY, ++s_encode_count);
	if (NULL == dest)
	{
		lua_pushstring(L, "");
	}
	else
	{
		lua_pushlstring(L, dest, destSize);
		free(dest);
		dest = NULL;
	}
	return 1;
}

int packet_crypto_decode(lua_State* L)
{
	const char *p = (char*)luaL_checkstring(L, 1);
	unsigned long dataSize = (unsigned long)luaL_checklong(L, 2);
	char *data = NULL, *dest = NULL;
	unsigned int destSize = 0;
	unsigned char encode_count = 0;

	if (NULL == p)
		return 0;

	data = (char*)malloc((dataSize + 1)*sizeof(char));
	memset(data, 0, dataSize + 1);
	memcpy(data, p, dataSize);
	dest = PacketCryptoDecode(data, dataSize, &destSize, XOR_KEY, SHIFT_KEY, &encode_count);
	if (NULL == dest)
	{
		lua_pushstring(L, "");
	}
	else
	{
		lua_pushlstring(L, dest, destSize);
		free(dest);
		dest = NULL;
	}
	if (data)
	{
		free(data);
		data = NULL;
	}
	return 1;
}

int luaopen_packetcrypto(lua_State* L)
{
	lua_register(L, "packet_crypto_init", packet_crypto_init);
	lua_register(L, "packet_crypto_encode", packet_crypto_encode);
	lua_register(L, "packet_crypto_decode", packet_crypto_decode);
	return 0;
}
