/****************************************************************************
 *** 同步推
 ****************************************************************************/
#import "ChannelTB.h"
#import "Buffer.h"
#import "cocos2d.h"
#import <CommonCrypto/CommonDigest.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include "Channel.h"

@implementation ChannelTB

-(void)dealloc {
    [super dealloc];
    [_uid release];
    [_token release];
}

-(BOOL)initSDK:(NSString*)initMsg {
    [[TBPlatform defaultPlatform]
     TBInitPlatformWithAppID:141122
     screenOrientation:UIInterfaceOrientationPortrait
     isContinueWhenCheckUpdateFailed:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sdkInitFinished)
                                                 name:kTBInitDidFinishNotification
                                               object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginFinished)
                                                 name:kTBLoginNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout)
                                                 name:kTBUserLogoutNotification
                                               object:nil];
    return YES;
}
- (void)sdkInitFinished{
    [[TBPlatform defaultPlatform] TBSetAutoRotation:NO];
    [Channel runScripts:NO isShowLoginFlag:YES];
}
-(void)logout{
    [Channel runScripts:NO isShowLoginFlag:YES];
}
- (void)loginFinished{
    if ([[TBPlatform defaultPlatform] TBIsLogined]) {
        TBPlatformUserInfo *userInfo =[[TBPlatform defaultPlatform] TBGetMyInfo];
        NSError* error;
        NSString *sidTemp = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) [userInfo sessionID], NULL, NULL, kCFStringEncodingUTF8);
        
        NSDictionary *sendData =[NSDictionary dictionaryWithObjectsAndKeys:
                                 sidTemp, @"sessionID",
                                 [self getChannelId],@"channel_id",
                                 nil];
        NSDictionary *datajson = [SdkUtil postCheckLoginState:sendData
                                    error:error];
     
        if(!datajson){
            return;
        }
        _uid = [datajson objectForKey:@"uid"];
        [_uid retain];
        _token = [datajson objectForKey:@"token"];
        [_token retain];
        [[TBPlatform defaultPlatform]TBShowToolBar:TBToolBarAtMiddleLeft isUseOldPlace:YES];
        [Channel runScripts:YES isShowLoginFlag:NO];
    }
}

-(BOOL)pauseSDK:(NSString*)pauseMsg {
    return YES;
}

-(BOOL)resumeSDK:(NSString*)resumeMsg {
    return YES;
}

-(BOOL)loginSDK:(NSString*)loginMsg {
    [[TBPlatform defaultPlatform] TBLogin:0];
    return YES;
}

-(BOOL)switchSDK:(NSString*)switchMsg {
    //[[TBPlatform defaultPlatform] TBSwitchAccount];
    [[TBPlatform defaultPlatform] TBEnterUserCenter:0];
    return YES;
}

-(BOOL)paySDK:(NSDictionary*)payDict {
    NSString *goodsPrice = [payDict objectForKey:@"goods_price"];
   // NSString *goodsName = [payDict objectForKey:@"goods_name"];
    NSString * billNO= [SdkUtil applyOrderNo:payDict] ;
    if(!billNO){
        //订单获取失败
        NSLog(@"订单获取失败");
        return NO;
    }
    [[TBPlatform defaultPlatform] TBUniPayForCoin:billNO needPayRMB:[goodsPrice intValue] payDescription:nil delegate:self];
    return YES;
}

-(BOOL)exitSDK:(NSString*)exitMsg {
    return YES;
}

-(NSString*)getChannelId {
    return [[NSString alloc] initWithString:@"20071"];
}

-(NSString*)getUid {
    return _uid;
}

-(NSString*)getToken {
    return _token;
}

-(NSString *)getAppId{
    return @"30001";
}

-(NSString *)getAppKey{
    return @"8a808023468dd22001468dd220270000";
}

-(void)sendMessage:(NSNumber*)type msg:(NSString*)msgStr {
}
/**
 * @brief 使⽤用推币直接购买商品成功
 *
 * @param order 订单号
 */
- (void)TBBuyGoodsDidSuccessWithOrder:(NSString*)order{
    NSLog(@"购买成功：%@",order);
    [SdkUtil showAlertTip:@"购买情况" tip:@"购买成功"];
};
/**a
 * @brief 使⽤用推币直接购买商品失败
 *
 * @param order 订单号
 * @param errorType 错误类型，⻅见TB_BUYGOODS_ERROR
 */
- (void)TBBuyGoodsDidFailedWithOrder:(NSString *)order
                          resultCode:(TB_BUYGOODS_ERROR)errorType{
    

    
};
/**
 * @brief 推币余额不⾜足，进⼊入充值⻚页⾯面（开发者需要⼿手动查询订单以获取充值
 购买结果）
 *
 * @param order 订单号
 */
- (void)TBBuyGoodsDidStartRechargeWithOrder:(NSString*)order{
    
};
/**
 * @brief 跳提⽰示框时，⽤用户取消
 *
 * @param order 订单号
 */
- (void)TBBuyGoodsDidCancelByUser:(NSString *)order{
     NSLog(@"购买取消：%@",order);
};
@end
