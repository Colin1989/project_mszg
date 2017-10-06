/**********************************************************************
* Author:	jaron.ho
* Date:		2014-03-21
* Brief:	RC4 algorithm
**********************************************************************/
#include "RC4.h"
#include <stdio.h>
#include <string.h>


//----------------------------------------------------------------------
char* rc4_crypto(char* input, unsigned long length, const char* psz_key)
{
	unsigned int keySize = 0;
	int sbox[256], key[256];
	int i = 0, j = 0, x = 0, y = 0, k = 0, temp = 0;
	unsigned long index = 0;

	if (NULL == input || 0 == length || NULL == psz_key)
		return input;

	keySize = strlen(psz_key);
	if (0 == keySize)
		return input;

	for (i=0; i<256; ++i)
	{
		key[i] = psz_key[i % keySize];
		sbox[i] = i;
	}

	for (i=0, j=0; i<256; ++i)
	{
		j = (sbox[i] + key[i] + j) % 256;
		temp = sbox[i];
		sbox[i] = sbox[j];
		sbox[j] = temp;
	}

	for (index=0; index<length; ++index)
	{
		x = (x + 1) % 256;
		y = (y + sbox[x]) % 256;
		temp = sbox[x];
		sbox[x] = sbox[y];
		sbox[y] = temp;
		k = sbox[(sbox[x] + sbox[y]) % 256];
		input[index] ^= k;
	}
	return input;
}
//----------------------------------------------------------------------

