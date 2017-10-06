/****************************************************************************
*** 渠道基类,具体渠道继承本类
****************************************************************************/
@interface ChannelBase : NSObject

/**
 * 初始化
 */
-(BOOL)initSDK:(NSString*)initMsg;

/**
 * 登录
 */
-(BOOL)loginSDK:(NSString*)loginMsg;

/*
 * 切换
 */
-(BOOL)switchSDK:(NSString*)switchMsg;

/**
 * 支付
 */
-(BOOL)paySDK:(NSDictionary*)payDict;

/**
 * 暂停
 */
-(BOOL)pauseSDK:(NSString*)pauseMsg;

/**
 * 继续
 */
-(BOOL)resumeSDK:(NSString*)resumeMsg;

/**
 * 退出
 */
-(BOOL)exitSDK:(NSString*)exitMsg;

/**
 * 获取app id
 */
-(NSString*)getAppId;

/**
 * 获取app key
 */
-(NSString*)getAppKey;

/**
 * 获取渠道id
 */
-(NSString*)getChannelId;

/**
 * 获取uid
 */
-(NSString*)getUid;

/**
 * 获取token
 */
-(NSString*)getToken;

/**
 * 发送消息:type - 消息类型;msg - 消息
 */
-(void)sendMessage:(NSNumber*)type msg:(NSString*)msgStr;

/**
 * 打开url:url - url地址;exitApp - 打开url时是否关闭应用标识
 */
-(void)openURL:(NSString*)url exitApp:(BOOL)exitAppFlag;

/**
 * 复制字符串
 */
-(void)copyString:(NSString*)str;

@end

