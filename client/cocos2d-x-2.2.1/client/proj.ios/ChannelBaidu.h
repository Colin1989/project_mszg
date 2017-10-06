/****************************************************************************
 *** 百度
 ****************************************************************************/
#import "ChannelBase.h"
#import <NdComPlatform/NdComPlatform.h>
#import <NdComPlatform/NdComPlatformAPIResponse.h>
#import <NdComPlatform/NdCPNotifications.h>
@interface ChannelBaidu : ChannelBase {
    NSString *_uid;
    NSString *_token;
}

-(BOOL)initSDK:(NSString*)initMsg;

-(BOOL)loginSDK:(NSString*)loginMsg;

-(BOOL)switchSDK:(NSString*)switchMsg;

-(BOOL)paySDK:(NSDictionary*)payDict;

-(BOOL)pauseSDK:(NSString*)pauseMsg;

-(BOOL)resumeSDK:(NSString*)resumeMsg;

-(BOOL)exitSDK:(NSString*)exitMsg;

-(NSString*)getChannelId;

-(NSString*)getUid;

-(NSString*)getToken;

-(void)sendMessage:(NSNumber*)type msg:(NSString*)msgStr;

@end
