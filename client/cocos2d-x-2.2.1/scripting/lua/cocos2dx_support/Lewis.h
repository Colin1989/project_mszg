#pragma once
#include "cocos2d.h"

USING_NS_CC;

class Lewis
{
public:
	static CCParticleSystemQuad* createSkillFrameParticle(int numberOfParticles, CCSize frameSize);
	static void spriteShaderEffect(CCNode* pSprite, const char* pszShaderFileName, bool bEffect);
	static CCSprite* createShaderSprite(const char* pszFileName, const char* sfragFileName, bool bFrame);
	static void shaderSpriteResetTime(CCSprite* pShaderSprite);
};

