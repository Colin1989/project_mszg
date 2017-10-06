/****************************************************************************
 *** 渠道基类,具体渠道继承本类
 ****************************************************************************/
#import "ChannelBase.h"
@implementation ChannelBase


-(BOOL)initSDK:(NSString*)initMsg {
    return YES;
}

-(BOOL)loginSDK:(NSString*)loginMsg {
    return YES;
}

-(BOOL)switchSDK:(NSString*)switchMsg {
    return YES;
}

-(BOOL)paySDK:(NSDictionary*)payDict {
    return YES;
}

-(BOOL)pauseSDK:(NSString*)pauseMsg {
    return YES;
}

-(BOOL)resumeSDK:(NSString*)resumeMsg {
    return YES;
}

-(BOOL)exitSDK:(NSString*)exitMsg {
    return YES;
}

-(NSString*)getAppId {
    return [[NSString alloc] initWithString:@""];
}

-(NSString*)getAppKey {
    return [[NSString alloc] initWithString:@""];
}

-(NSString*)getChannelId {
    return [[NSString alloc] initWithString:@""];
}

-(NSString*)getUid {
    return [[NSString alloc] initWithString:@""];
}

-(NSString*)getToken {
    return [[NSString alloc] initWithString:@""];
}

-(void)sendMessage:(NSNumber*)type msg:(NSString*)msgStr {
}

-(void)openURL:(NSString*)url exitApp:(BOOL)exitAppFlag {
    NSString *utf8Str = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:utf8Str]];
    if (exitAppFlag) {
        exit(0);
    }
}

-(void)copyString:(NSString*)str {
    if (!str || 0 == [str length]) {
        CFStringRef strRef = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
        CFRelease(strRef);
        str = [(NSString*)strRef autorelease];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = str;
}

@end

