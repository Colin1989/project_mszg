/****************************************************************************
 *** pp助手
 ****************************************************************************/
#import "ChannelBase.h"
#import <PPAppPlatformKit/PPAppPlatformKit.h>

@interface ChannelPP : ChannelBase <PPAppPlatformKitDelegate> {
    NSString *_uid;
    NSString *_token;
}


-(BOOL)initSDK:(NSString*)initMsg;

-(BOOL)loginSDK:(NSString*)loginMsg;

-(BOOL)switchSDK:(NSString*)switchMsg;

-(BOOL)paySDK:(NSDictionary*)payDict;

-(BOOL)exitSDK:(NSString*)exitMsg;

-(NSString*)getChannelId;

-(NSString*)getUid;

-(NSString*)getToken;

-(void)sendMessage:(NSNumber*)type msg:(NSString*)msgStr;

@end
