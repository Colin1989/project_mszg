/****************************************************************************
 *** 快用助手
 ****************************************************************************/
#import "ChannelBase.h"
#import "KYSDK.h"
#import "SdkUtil.h"
@interface ChannelKY : ChannelBase<KYSDKDelegate> {
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
