/****************************************************************************
 *** 同步推
 ****************************************************************************/
#import "ChannelBase.h"
#import <TBPlatform/TBPlatform.h>
#import "SdkUtil.h"
@interface ChannelTB : ChannelBase<TBBuyGoodsProtocol> {
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
