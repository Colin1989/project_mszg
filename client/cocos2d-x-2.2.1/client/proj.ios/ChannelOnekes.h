/****************************************************************************
 *** 自有
 ****************************************************************************/
#import "ChannelBase.h"
#import <StoreKit/StoreKit.h>
#import "SdkUtil.h"

@interface ChannelOnekes : ChannelBase<SKProductsRequestDelegate,SKPaymentTransactionObserver>

-(BOOL)initSDK:(NSString*)initMsg;

-(BOOL)paySDK:(NSDictionary*)payDict;

-(NSString*)getChannelId;

-(BOOL) isAddListen;

@end
