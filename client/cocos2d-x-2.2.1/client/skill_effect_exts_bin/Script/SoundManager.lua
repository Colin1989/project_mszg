----------------------------------
-- 作者：lihq
-- 日期：2013-11-22
-- 描述：声音管理器
----------------------------------

----------------------------------------------------------------------
-- 功  能：播放背景音乐，调用时会停止当前的背景音乐
-- 参  数：fileName - 音乐文件名
-- 返回值：无返回值
function SoundManger_playBackgroundSound(fileName)
    
    SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true) -- 停止当前的背景音乐
    -- 播放背景音乐
    SimpleAudioEngine:sharedEngine():playBackgroundMusic(fileName, true)
end
----------------------------------------------------------------------
-- 功  能：停止播放背景音乐
-- 参  数：无参数
-- 返回值：无返回值
function SoundManger_stopBackGroundSound()
   SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
end
----------------------------------------------------------------------
-- 功  能：播放特效音乐
-- 参  数：fileName - 特效音乐文件名; loop - 设置是否循环
-- 返回值：返回特效音乐id
function SoundManger_playEffectSound(fileName , loop)
    return SimpleAudioEngine:sharedEngine():playEffect(fileName, loop)
end
----------------------------------------------------------------------
-- 功  能：停止播放特效音乐
-- 参  数：effectId - 特效音乐id
-- 返回值：无返回值
function SoundManger_stopEffectSound(effectId)
     SimpleAudioEngine:sharedEngine():stopEffect(effectId)
end
----------------------------------------------------------------------
-- 功  能：停止播放特效音乐
-- 参  数：无
-- 返回值：无返回值
function SoundManger_stopAllEffectSounds()
     SimpleAudioEngine:sharedEngine():stopAllEffects()
end
----------------------------------------------------------------------

