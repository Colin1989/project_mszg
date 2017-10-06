/****************************************************************************
*** 渠道,定义接口提供给lua调用
****************************************************************************/
#import "Channel.h"
#import "CCLuaEngine.h"
#import "ResDownload.h"
#ifdef CHANNEL_OWN
    #import "ChannelOnekes.h"
#endif
#ifdef CHANNEL_BAIDU
    #import "ChannelBaidu.h"
#endif
#ifdef CHANNEL_PGY
#endif
#ifdef CHANNEL_AB
#endif
#ifdef CHANNEL_PP
    #import "ChannelPP.h"
#endif
#ifdef CHANNEL_KY
    #import "ChannelKY.h"
#endif
#ifdef CHANNEL_TB
    #import "ChannelTB.h"
#endif
#ifdef CHANNEL_ITOOLS
#endif
#ifdef CHANNEL_HM
#endif
#ifdef CHANNEL_I4
#endif
#ifdef CHANNEL_APPSTORE
	#import "AppStoreIap.h"
#endif



static ChannelBase *sChannel = nil;      // 当前渠道,全局静态变量

@implementation Channel

+(void)initChannel {
    if (sChannel) {
        return;
    }
#ifdef CHANNEL_OWN             // 自有
    sChannel = [[ChannelOnekes alloc] init];
#endif
#ifdef CHANNEL_BAIDU           // 百度
    sChannel = [[ChannelBaidu alloc] init];
#endif
#ifdef CHANNEL_PGY             // 苹果园
#endif
#ifdef CHANNEL_AB              // 爱贝
#endif
#ifdef CHANNEL_PP              // pp助手
    sChannel = [[ChannelPP alloc] init];
#endif
#ifdef CHANNEL_KY              // 快用助手
    sChannel = [[ChannelKY alloc] init];
#endif
#ifdef CHANNEL_TB              // 同步推
    sChannel = [[ChannelTB alloc] init];
#endif
#ifdef CHANNEL_ITOOLS          // itools
#endif
#ifdef CHANNEL_HM              // 海马平台
#endif
#ifdef CHANNEL_I4              // 爱思助手
#endif
#ifdef CHANNEL_APPSTORE			// APPSTORE
	
#endif
    if (sChannel) {
        [sChannel retain];
        [sChannel autorelease];
    }
}

+(void)runScripts:(BOOL)isLoginOK isShowLoginFlag:(BOOL)isShowLogin {
	NSString *is_login_ok = isLoginOK ? @"true" : @"false";
	NSString *is_show_login = isShowLogin ? @"true" : @"false";
	NSString *param = [[NSString alloc] initWithFormat:@"{\"is_login_ok\":%@,\"is_show_login\":%@}", is_login_ok, is_show_login];
    lua_callGlobalFunc(CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState(), "runScripts", "s", [param UTF8String]);
}

+(ChannelBase*)getInst {
    return sChannel;
}

+(BOOL)init:(NSDictionary*)paramDict {
    NSString *msg = @"";
    if (paramDict) {
        msg = [paramDict objectForKey:@"msg_str"];
    }
    return [sChannel initSDK:msg];
}

+(BOOL)login:(NSDictionary*)paramDict {
    NSString *msg = @"";
    if (paramDict) {
        msg = [paramDict objectForKey:@"msg_str"];
    }
    return [sChannel loginSDK:msg];
}

+(BOOL)switchAccount:(NSDictionary*)paramDict {
    NSString *msg = @"";
    if (paramDict) {
        msg = [paramDict objectForKey:@"msg_str"];
    }
    return [sChannel switchSDK:msg];
}

+(BOOL)pay:(NSDictionary*)paramDict {
    return[sChannel paySDK:paramDict];
}

+(BOOL)pause:(NSDictionary*)paramDict {
    NSString *msg = @"";
    if (paramDict) {
        msg = [paramDict objectForKey:@"msg_str"];
    }
    return [sChannel pauseSDK:msg];
}

+(BOOL)resume:(NSDictionary*)paramDict {
    NSString *msg = @"";
    if (paramDict) {
        msg = [paramDict objectForKey:@"msg_str"];
    }
    return [sChannel resumeSDK:msg];
}

+(NSString*)getAppId {
    return [sChannel getAppId];
}

+(NSString*)getAppKey {
    return [sChannel getAppKey];
}

+(NSString*)getChannelId {
    return [sChannel getChannelId];
}

+(NSString*)getUid {
    return [sChannel getUid];
}

+(NSString*)getToken {
    return [sChannel getToken];
}

+(void)sendMessage:(NSDictionary*)paramDict {
    NSString *type = [paramDict objectForKey:@"msg_type"];
    NSString *msg = [paramDict objectForKey:@"msg_str"];
    [sChannel sendMessage:[NSNumber numberWithInt:[type intValue]] msg:msg];
}

+(void)openURL:(NSDictionary*)paramDict {
    NSString *url = [paramDict objectForKey:@"url_str"];
    NSString *exitApp = [paramDict objectForKey:@"exit_app"];
    [sChannel openURL:url exitApp:[exitApp boolValue]];
}

+(void)copyString:(NSDictionary*)paramDict {
	NSString *strTmp = [paramDict objectForKey:@"copy_str"];
    [sChannel copyString:strTmp];
}

@end

