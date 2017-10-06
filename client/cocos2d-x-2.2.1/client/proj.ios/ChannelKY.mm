/****************************************************************************
 *** 快用助手
 ****************************************************************************/
#import "ChannelKY.h"
#import "Buffer.h"
#import "cocos2d.h"
#import <CommonCrypto/CommonDigest.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <stdlib.h>
#import <sys/types.h>
#import <arpa/inet.h>
#import "Config.h"
#import "Channel.h"

@implementation ChannelKY

-(void)dealloc {
    [super dealloc];
    [_uid release];
    [_token release];
}
-(BOOL)initSDK:(NSString*)initMsg {
    [[KYSDK instance] setSdkdelegate:self];
    [Channel runScripts:NO isShowLoginFlag:YES];
    return YES;
}

-(BOOL)loginSDK:(NSString*)loginMsg {
    if (_uid ==nil) {
        [[KYSDK instance] logWithLastUser];
        return YES;
    }
    
    
    return YES;
}
//1.用户登录界面点击“登录”按钮的回调
-(void)loginCallBack:(NSString *)tokenKey{
    NSError *error;
    NSDictionary *sendData =[NSDictionary dictionaryWithObjectsAndKeys:
                             tokenKey, @"tokenKey",
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
    [Channel runScripts:YES isShowLoginFlag:NO];
}

//2.用户登录界面点击“快速试玩”按钮的回调
-(void)quickLogCallBack:(NSString *)tokenKey{
    [self logOutCallBack:tokenKey];
}
//3.注销方法的回调
//场景1：主动调用“注销方法”（userLogOut）
//场景2：点击“7659账号管理”界面“注销”按钮的回调。两者的回调无区分
-(void)logOutCallBack:(NSString *)guid{
    [Channel runScripts:NO isShowLoginFlag:YES];
}
/*--------- 支付的回调 ----------*/
//一切支付结果，以服务器端的通告为准
//1.支付宝完成后回调
-(void)alipayCallBack:(ALIPAYRESULT)alipayresult{
    switch (alipayresult) {
        case PAY_DONE:
            //[SdkUtil showAlertTip:@"支付结果" tip:@"成功购买"];
            break;
            
        default:
            [SdkUtil showAlertTip:@"支付结果" tip:@"购买失败"];
            break;
    }
}

//2.银联支付回调函数
-(void)UPPayPluginResult:(UNIPAYTYPE)result{
    switch (result) {
        case USER_UNIPAY_SUCCESS:
            [SdkUtil showAlertTip:@"支付结果" tip:@"购买成功"];
            break;
        case USER_UNIPAY_CANCEL:
            [SdkUtil showAlertTip:@"支付结果" tip:@"购买取消"];
            break;
        default:
            [SdkUtil showAlertTip:@"支付结果" tip:@"购买失败"];
            break;
    }
    
}
-(BOOL)switchSDK:(NSString*)switchMsg {
    [[KYSDK instance]setUpUser];
    return YES;
}

-(BOOL)paySDK:(NSDictionary*)payDict {
    NSString *goodsPrice = [payDict objectForKey:@"goods_price"];
    NSString *goodsName = [payDict objectForKey:@"goods_name"];
    NSString * billNO= [SdkUtil applyOrderNo:payDict] ;
    if(!billNO){
        //订单获取失败
        NSLog(@"订单获取失败");
        return NO;
    }
    NSLog(@"订单号为：%@",billNO);
    /**
     1.支付信息填写
     dealseq：  订单号，唯一透传参数，最大64位，不可重复；
     fee：      金额，保留两位小数，系统默认6位小数
     game：     http://payquery.bppstore.com开发者后台查询对应的game值，一般为4位数字
     gamesvr：  多个通告地址的设置。只区分不同的通告地址，不一定是区服。若只有一个通告地址，则填空@"",若有多个，@技术支持进行后台录入
     subject:   道具名称，比如“60金币”
     md5Key：   http://payquery.bppstore.com开发者后台查询对应的"签名密钥"
     userid:    账户名，单机游戏必须传入值,网游填空@""
     appScheme：支付宝钱包客户端对应的回调参数，要与targets-》info-》url types中的 url schemes中设置的一模一样，建议使用bundle identifier
     **/
    [[KYSDK instance]showPayWith:billNO fee:goodsPrice game:@"7064" gamesvr:@"" subject:goodsName md5Key:@"v6dMBkeJMsEsaRoYE9GaZanY1XGxkOgP" userId:@"" appScheme:@"com.onekes.mszg.ky"];
    return YES;
}

-(BOOL)exitSDK:(NSString*)exitMsg {
    return YES;
}

-(NSString*)getChannelId {
    return [[NSString alloc] initWithString:@"20061"];
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

@end
