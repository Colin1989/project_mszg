#include "Lewis.h"

using namespace cocos2d;

class CSkillFrameParticle: public CCParticleSun
{
private:
	CC_SYNTHESIZE(CCSize, m_FrameSize, FrameSize);

public:
	static CSkillFrameParticle* create(int numberOfParticles, CCSize frameSize);
	bool myInit(int numberOfParticles, CCSize frameSize);
	bool myAddParticle();
	void myInitParticle(tCCParticle* particle);
	virtual void update(float dt);
};

CSkillFrameParticle* CSkillFrameParticle::create(int numberOfParticles, CCSize frameSize)
{
	CSkillFrameParticle* pRet = new CSkillFrameParticle();
	if (pRet && pRet->myInit(numberOfParticles, frameSize))
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}

bool CSkillFrameParticle::myInit(int numberOfParticles, CCSize frameSize)
{
	m_FrameSize = frameSize;
	CCParticleSun::initWithTotalParticles(numberOfParticles);
	m_tStartColor.r = 0.76f;
	m_tStartColor.g = 0.25f;
	m_tStartColor.b = 0.72f;
	m_tStartColor.a = 1.0f;
	m_tStartColorVar.r = 0.0f;
	m_tStartColorVar.g = 0.0f;
	m_tStartColorVar.b = 0.0f;
	m_tStartColorVar.a = 0.0f;
	m_tEndColor.r = 0.0f;
	m_tEndColor.g = 0.0f;
	m_tEndColor.b = 0.0f;
	m_tEndColor.a = 1.0f;
	m_tEndColorVar.r = 0.0f;
	m_tEndColorVar.g = 0.0f;
	m_tEndColorVar.b = 0.0f;
	m_tEndColorVar.a = 0.0f;
	m_fLife = 0.9f;
	m_fLifeVar = 0.4f;
	return true;
}

bool CSkillFrameParticle::myAddParticle()
{
	if (this->isFull())
	{
		return false;
	}

	tCCParticle * particle = &m_pParticles[ m_uParticleCount ];
	this->myInitParticle(particle);
	++m_uParticleCount;
	return true;
}

void CSkillFrameParticle::myInitParticle(tCCParticle* particle)
{
	CCParticleSun::initParticle(particle);
	// position
	if( m_ePositionType == kCCPositionTypeFree )
	{
		int logicIndex = rand() % 1000;
		const int side_unit_count = 10;
		int side = (logicIndex / side_unit_count) % 4;
		int index = logicIndex % side_unit_count;
		float unit_width = m_FrameSize.width / side_unit_count;
		float unit_height = m_FrameSize.height / side_unit_count;
		CCPoint startPos;
		switch (side)
		{
		case 0:
			{
				startPos = ccp(0, 0);
				startPos.x += unit_width * index;
			}
			break;

		case 1:
			{
				startPos = ccp(m_FrameSize.width, 0);
				startPos.y += unit_height * index;
			}
			break;

		case 2:
			{
				startPos = ccp(m_FrameSize.width, m_FrameSize.height);
				startPos.x -= unit_width * index;
			}
			break;

		case 3:
			{
				startPos = ccp(0, m_FrameSize.height);
				startPos.y -= unit_height * index;
			}
			break;
		}
		particle->startPos = this->convertToWorldSpace(startPos);
	}
	else if ( m_ePositionType == kCCPositionTypeRelative )
	{
		particle->startPos = m_obPosition;
	}
}

void CSkillFrameParticle::update(float dt)
{
	CC_PROFILER_START_CATEGORY(kCCProfilerCategoryParticles , "CCParticleSystem - update");

	if (m_bIsActive && m_fEmissionRate)
	{
		float rate = 1.0f / m_fEmissionRate;
		//issue #1201, prevent bursts of particles, due to too high emitCounter
		if (m_uParticleCount < m_uTotalParticles)
		{
			m_fEmitCounter += dt;
		}

		while (m_uParticleCount < m_uTotalParticles && m_fEmitCounter > rate) 
		{
			this->myAddParticle();
			m_fEmitCounter -= rate;
		}

		m_fElapsed += dt;
		if (m_fDuration != -1 && m_fDuration < m_fElapsed)
		{
			this->stopSystem();
		}
	}

	m_uParticleIdx = 0;

	CCPoint currentPosition = CCPointZero;
	if (m_ePositionType == kCCPositionTypeFree)
	{
		currentPosition = this->convertToWorldSpace(CCPointZero);
	}
	else if (m_ePositionType == kCCPositionTypeRelative)
	{
		currentPosition = m_obPosition;
	}

	if (m_bVisible)
	{
		while (m_uParticleIdx < m_uParticleCount)
		{
			tCCParticle *p = &m_pParticles[m_uParticleIdx];

			// life
			p->timeToLive -= dt;

			if (p->timeToLive > 0) 
			{
				// Mode A: gravity, direction, tangential accel & radial accel
				if (m_nEmitterMode == kCCParticleModeGravity) 
				{
					CCPoint tmp, radial, tangential;

					radial = CCPointZero;
					// radial acceleration
					if (p->pos.x || p->pos.y)
					{
						radial = ccpNormalize(p->pos);
					}
					tangential = radial;
					radial = ccpMult(radial, p->modeA.radialAccel);

					// tangential acceleration
					float newy = tangential.x;
					tangential.x = -tangential.y;
					tangential.y = newy;
					tangential = ccpMult(tangential, p->modeA.tangentialAccel);

					// (gravity + radial + tangential) * dt
					tmp = ccpAdd( ccpAdd( radial, tangential), modeA.gravity);
					tmp = ccpMult( tmp, dt);
					p->modeA.dir = ccpAdd( p->modeA.dir, tmp);
					tmp = ccpMult(p->modeA.dir, dt);
					p->pos = ccpAdd( p->pos, tmp );
				}

				// Mode B: radius movement
				else 
				{                
					// Update the angle and radius of the particle.
					p->modeB.angle += p->modeB.degreesPerSecond * dt;
					p->modeB.radius += p->modeB.deltaRadius * dt;

					p->pos.x = - cosf(p->modeB.angle) * p->modeB.radius;
					p->pos.y = - sinf(p->modeB.angle) * p->modeB.radius;
				}

				// color
				p->color.r += (p->deltaColor.r * dt);
				p->color.g += (p->deltaColor.g * dt);
				p->color.b += (p->deltaColor.b * dt);
				p->color.a += (p->deltaColor.a * dt);

				// size
				p->size += (p->deltaSize * dt);
				p->size = MAX( 0, p->size );

				// angle
				p->rotation += (p->deltaRotation * dt);

				//
				// update values in quad
				//

				CCPoint    newPos;

				if (m_ePositionType == kCCPositionTypeFree || m_ePositionType == kCCPositionTypeRelative) 
				{
					CCPoint diff = ccpSub( currentPosition, p->startPos );
					newPos = ccpSub(p->pos, diff);
				} 
				else
				{
					newPos = p->pos;
				}

				// translate newPos to correct position, since matrix transform isn't performed in batchnode
				// don't update the particle with the new position information, it will interfere with the radius and tangential calculations
				if (m_pBatchNode)
				{
					newPos.x+=m_obPosition.x;
					newPos.y+=m_obPosition.y;
				}

				updateQuadWithParticle(p, newPos);
				//updateParticleImp(self, updateParticleSel, p, newPos);

				// update particle counter
				++m_uParticleIdx;
			} 
			else 
			{
				// life < 0
				int currentIndex = p->atlasIndex;
				if( m_uParticleIdx != m_uParticleCount-1 )
				{
					m_pParticles[m_uParticleIdx] = m_pParticles[m_uParticleCount-1];
				}
				if (m_pBatchNode)
				{
					//disable the switched particle
					m_pBatchNode->disableParticle(m_uAtlasIndex+currentIndex);

					//switch indexes
					m_pParticles[m_uParticleCount-1].atlasIndex = currentIndex;
				}


				--m_uParticleCount;

				if( m_uParticleCount == 0 && m_bIsAutoRemoveOnFinish )
				{
					this->unscheduleUpdate();
					m_pParent->removeChild(this, true);
					return;
				}
			}
		} //while
		m_bTransformSystemDirty = false;
	}
	if (! m_pBatchNode)
	{
		postStep();
	}

	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategoryParticles , "CCParticleSystem - update");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
class CShaderSprite: public CCSprite
{
public:
	static CShaderSprite* create(const char* pszFileName, const char* sfragFileName, bool bFrame);
	bool initWithTexture(CCTexture2D* texture, const CCRect& rect);
	void initProgram();
	void draw();
	void resetTime();

private:
	cocos2d::ccVertex2F m_time;
	cocos2d::ccVertex2F m_center;
	cocos2d::ccVertex2F m_resolution;
	GLuint     m_uniformTime, m_uniformCenter, m_uniformResolution;
	CC_SYNTHESIZE(std::string, m_fragFileName, FragFileName);
};

CShaderSprite* CShaderSprite::create(const char* pszFileName, const char* sfragFileName, bool bFrame)
{
	CShaderSprite* pRet = new CShaderSprite();
	if (pRet)
	{
		pRet->setFragFileName(sfragFileName);
		if (bFrame)
		{
			pRet->initWithSpriteFrameName(pszFileName);
		}
		else
		{
			pRet->initWithFile(pszFileName);
		}
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}

	return pRet;
}

bool CShaderSprite::initWithTexture(CCTexture2D* texture, const CCRect& rect)
{
	if (CCSprite::initWithTexture(texture, rect))
	{
		this->initProgram();
		return true;
	}
	return false;
}

void CShaderSprite::initProgram()
{
	GLchar * fragSource = (GLchar*)CCString::createWithContentsOfFile(m_fragFileName.c_str())->getCString();
	CCGLProgram* pProgram = new CCGLProgram();
	pProgram->initWithVertexShaderByteArray(ccPositionTextureColor_vert, fragSource);
	setShaderProgram(pProgram);
	pProgram->release();

	CHECK_GL_ERROR_DEBUG();

	getShaderProgram()->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
	getShaderProgram()->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
	getShaderProgram()->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);

	CHECK_GL_ERROR_DEBUG();

	getShaderProgram()->link();

	CHECK_GL_ERROR_DEBUG();

	getShaderProgram()->updateUniforms();

	CHECK_GL_ERROR_DEBUG();

	//uniform vec2 center;
	//uniform vec2 resolution;

	m_uniformTime = glGetUniformLocation(getShaderProgram()->getProgram(), "myTime");
	m_uniformCenter = glGetUniformLocation(getShaderProgram()->getProgram(), "center");
	m_uniformResolution = glGetUniformLocation(getShaderProgram()->getProgram(), "resolution");

	CCSize size = this->getTextureRect().size;
	m_resolution.x = size.width;
	m_resolution.y = size.height;
	this->resetTime();
	//m_center = m_resolution.size;

	CHECK_GL_ERROR_DEBUG();
}

void CShaderSprite::draw()
{
	//
	// Uniforms
	//
	m_time.x += 0.015f;
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
	ccBlendFunc blend = getBlendFunc();
	ccGLBlendFunc(blend.src, blend.dst);


	getShaderProgram()->use();
	getShaderProgram()->setUniformsForBuiltins();
	getShaderProgram()->setUniformLocationWith2f(m_uniformCenter, m_center.x, m_center.y);
	getShaderProgram()->setUniformLocationWith2f(m_uniformResolution, m_resolution.x, m_resolution.y);
	getShaderProgram()->setUniformLocationWith2f(m_uniformTime, m_time.x, m_time.y);

	ccGLBindTexture2D(getTexture()->getName());

	//
	// Attributes
	//
#define kQuadSize sizeof(m_sQuad.bl)
	long offset = (long)&m_sQuad;

	// vertex
	int diff = offsetof(ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));

	// texCoods
	diff = offsetof(ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));

	// color
	diff = offsetof(ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));


	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	CC_INCREMENT_GL_DRAWS(1);
}

void CShaderSprite::resetTime()
{
	m_time.x = 0.0f;
	m_time.y = 0.0f;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CCParticleSystemQuad* Lewis::createSkillFrameParticle(int numberOfParticles, cocos2d::CCSize frameSize)
{
	CSkillFrameParticle* particle = CSkillFrameParticle::create(numberOfParticles, frameSize);
	return particle;
}

void Lewis::spriteShaderEffect(cocos2d::CCNode* pSprite, const char* pszShaderFileName, bool bEffect)
{
	if (pszShaderFileName == NULL)
		return;

	if (bEffect)
	{
		CCGLProgram* pProgram = CCShaderCache::sharedShaderCache()->programForKey(pszShaderFileName);
		if (pProgram == NULL)
		{
			GLchar* pszFragSource =	(GLchar*)CCString::createWithContentsOfFile(pszShaderFileName)->getCString();
			pProgram = new CCGLProgram();
			pProgram->initWithVertexShaderByteArray(ccPositionTextureColor_vert, pszFragSource);
			CHECK_GL_ERROR_DEBUG();

			pProgram->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
			pProgram->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
			pProgram->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
			CHECK_GL_ERROR_DEBUG();

			pProgram->link();
			CHECK_GL_ERROR_DEBUG();

			pProgram->updateUniforms();
			CHECK_GL_ERROR_DEBUG();

			CCShaderCache::sharedShaderCache()->addProgram(pProgram, pszShaderFileName);
			pProgram->retain();
		}
		pSprite->setShaderProgram(pProgram);
	}
	else
	{
		pSprite->setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor));
	}
}

CCSprite* Lewis::createShaderSprite(const char* pszFileName, const char* sfragFileName, bool bFrame)
{
	return CShaderSprite::create(pszFileName, sfragFileName, bFrame);
}

void Lewis::shaderSpriteResetTime(CCSprite* pShaderSprite)
{
	CShaderSprite* pRet = static_cast<CShaderSprite*>(pShaderSprite);
	pRet->resetTime();
}
