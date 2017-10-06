#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

extern void PacketCryptoInit();
extern char* PacketCryptoEncode(const char* data, unsigned int dataLen, unsigned int* destLen, unsigned long xorKey, unsigned long shiftKey, unsigned char encodeCount);
extern char* PacketCryptoDecode(char* data, unsigned int dataLen, unsigned int* destLen, unsigned long xorKey, unsigned long shiftKey, unsigned char* encodeCount);

#ifdef __cplusplus
}
#endif


