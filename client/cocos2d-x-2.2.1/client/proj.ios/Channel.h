/****************************************************************************
*** 渠道,定义接口提供给lua调用
****************************************************************************/
#import "ChannelBase.h"

@interface Channel : NSObject

/*
 * 初始化渠道实例,函数内部根据渠道包名来实例当前渠道,该接口在最开始调用
 */
+(void)initChannel;

/*
 * 运行脚本:isLoginOK,是否登录成功;isShowLogin,是否显示渠道登录页面
 */
+(void)runScripts:(BOOL)isLoginOK isShowLoginFlag:(BOOL)isShowLogin;

/*
 * 获取渠道实例
 */
+(ChannelBase*)getInst;

/*
 * 下面为提供给lua调用的接口
 */

/*
 * 初始
 */
+(BOOL)init:(NSDictionary*)paramDict;

/*
 * 登录
 */
+(BOOL)login:(NSDictionary*)paramDict;

/*
 * 切换账号
 */
+(BOOL)switchAccount:(NSDictionary*)paramDict;

/*
 * 支付
 */
+(BOOL)pay:(NSDictionary*)paramDict;

/*
 * 暂停
 */
+(BOOL)pause:(NSDictionary*)paramDict;

/*
 * 继续
 */
+(BOOL)resume:(NSDictionary*)paramDict;

/*
 * 获取app id
 */
+(NSString*)getAppId;

/*
 * 获取app key
 */
+(NSString*)getAppKey;

/*
 * 获取渠道id
 */
+(NSString*)getChannelId;

/*
 * 获取uid
 */
+(NSString*)getUid;

/*
 * 获取token
 */
+(NSString*)getToken;

/*
 * 发送消息
 */
+(void)sendMessage:(NSDictionary*)paramDict;

/*
 * 打开url
 */
+(void)openURL:(NSDictionary*)paramDict;

/*
 * 拷贝字符串到系统黏贴板
 */
+(void)copyString:(NSDictionary*)paramDict;

@end

