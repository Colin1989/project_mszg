/**********************************************************************
* 作者：hezhr
* 时间：2013-11-17
* 描述：AES加密解密算法实现
**********************************************************************/
#ifndef _AES_H_
#define _AES_H_


class AES
{
public:
	/*
	功	能：构造函数
	参	数：key - 秘钥
	返回值：无返回值
	*/
	AES(unsigned char* key);

	virtual ~AES();

public:
	/*
	功	能：加密单条字符串
	参	数：input - 要加密的字符串
	返回值：unsigned char*
	*/
	unsigned char* encrypt(unsigned char* input);

	/*
	功	能：解密单条字符串
	参	数：input - 要解密的字符串
	返回值：unsigned char*
	*/
	unsigned char* decrypt(unsigned char* input);

	// 至此已经实现了AES加密与解密的原型,在使用的时候一般处理的是字符串等,而不是直接传入128位的数据,所以要封装一下对外部数据的加解密处理

	/*
	功	能：加密数据（如果是对整个文本数据进行加密,则选择此函数）
	参	数：input - 要加密的数据,加密时传进的指针要预留够16整数倍字节的空间,因为加密操作直接修改原数据,不足128位可能造成内存溢出
			length - 要加密的数据长度,如果使用默认值,则作为字符串处理,以'\0'为结尾计算长度
	返回值：void*
	*/
	void* encrypt(void* input, int length = 0);

	/*
	功	能：解密数据（如果是对真个文本数据进行解密,则选择此函数）
	参	数：input - 要解密的数据；length - 
	返回值：void*
	*/
	void* decrypt(void* input, int length);

private:
	void keyExpansion(unsigned char* key, unsigned char w[][4][4]);		// 密钥扩展
	unsigned char ffMul(unsigned char a, unsigned char b);				// 有限域GF(2^8)上的乘法

	void subBytes(unsigned char state[][4]);							// 字节替代
	void shiftRows(unsigned char state[][4]);							// 行移位
	void mixColumns(unsigned char state[][4]);							// 列混淆
	void addRoundKey(unsigned char state[][4], unsigned char k[][4]);	// 轮密钥加

	void invSubBytes(unsigned char state[][4]);							// 逆字节替代
	void invShiftRows(unsigned char state[][4]);						// 逆行移位
	void invMixColumns(unsigned char state[][4]);						// 逆列混淆

private:
	unsigned char mSbox[256];
	unsigned char mInvSbox[256];
	unsigned char mW[11][4][4];
};


#endif	// _AES_H_


