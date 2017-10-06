/****************************************************************************
 *** 百度
 ****************************************************************************/
#import "ChannelBaidu.h"
#import "Buffer.h"
#import "cocos2d.h"
#import <CommonCrypto/CommonDigest.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include "Config.h"
#include "Channel.h"

@implementation ChannelBaidu

-(void)dealloc {
    [super dealloc];
    [_uid release];
    [_token release];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNdCPBuyResultNotification object:nil];
}

-(BOOL)initSDK:(NSString*)initMsg {
//    [[NdComPlatform defaultPlatform] NdSetDebugMode:0]; //测试模式,此模式只有在"越狱机"才有效(正式版要注释掉该行)
    NdInitConfigure *cfg = [[[NdInitConfigure alloc] init] autorelease];
    cfg.appid = 116105;
    cfg.appKey = @"554ebfea21c1e3de3d1689db34ab6cdbc4364971cf3e94d2";
    cfg.versionCheckLevel = ND_VERSION_CHECK_LEVEL_NORMAL;  //非强制更新
    cfg.orientation = UIInterfaceOrientationPortrait;   //竖屏
    cfg.autoRotate = NO;    //禁止自动旋转
    [[NdComPlatform defaultPlatform] NdInit:cfg];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSInitResult:) name:(NSString *)kNdCPInitDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:)
                                                 name:(NSString *)kNdCPLoginNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SNSSessionInvalid:)
                                                 name:(NSString *)kNdCPSessionInvalidNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NdUniPayResult:)
                                                 name:kNdCPBuyResultNotification
                                               object:nil]; 

    //...write you code here
    return YES;
}

-(BOOL)pauseSDK:(NSString*)pauseMsg {
    [[NdComPlatform defaultPlatform] NdPause];  //此接口只有在"越狱机"才有效
    return YES;
}

-(BOOL)resumeSDK:(NSString*)resumeMsg {
    [[NdComPlatform defaultPlatform] NdPause];  //此接口只有在"越狱机"才有效
    return YES;
}

- (void)SNSInitResult:(NSNotification *)notify
{
    [Channel runScripts:NO isShowLoginFlag:YES];
//    [self loginSDK:@""];
}
-(BOOL)loginSDK:(NSString*)loginMsg {
    [[NdComPlatform defaultPlatform] NdLogin:0];

    return YES;
}

-(BOOL)switchSDK:(NSString*)switchMsg {
    [[NdComPlatform defaultPlatform] NdEnterAccountManage];
    return YES;
}

-(BOOL)paySDK:(NSDictionary*)payDict {
    NdBuyInfo *buyInfo = [[NdBuyInfo new] autorelease];
    NSString *goodsPrice = [payDict objectForKey:@"goods_price"];
    NSString *goodsName = [payDict objectForKey:@"goods_name"];
    NSString *goods_id = [payDict objectForKey:@"goods_id"];
    NSString *billNO= [self getApplyOrderNoCheckParams:payDict] ;
    if(!billNO){
        //订单号获取失败
        NSLog(@"订单获取失败");
        return NO;
    }
    buyInfo.cooOrderSerial = billNO;//订单号
    buyInfo.productId = goods_id ; //自定义的产品ID
    buyInfo.productName = goodsName; //产品名称
    buyInfo.productPrice = [goodsPrice floatValue] ; //产品现价，价格大等于0.01,支付价格以此为准
    buyInfo.productOrignalPrice = [goodsPrice floatValue]; //产品原价，同现价保持一致
    buyInfo.productCount = 1; //产品数量
    buyInfo.payDescription = @"gamezoon1"; //服务器分区，不超过20个字符，只允许英文或数字
    //发起请求并检查返回值。注意！该返回值并不是交易结果！
    int res = [[NdComPlatform defaultPlatform] NdUniPayAsyn:buyInfo];
    if (res < 0)
    { 
        //输入参数有错！无法提交购买请求 
    }

    return YES;
}
- (void)NdUniPayResult:(NSNotification*)notify
{
    NSDictionary *dic = [notify userInfo];
    BOOL bSuccess = [[dic objectForKey:@"result"] boolValue];
    NSString* str = bSuccess ? @"购买成功" : @"购买失败";
    if (!bSuccess) {
        //TODO: 购买失败处理
        NSString* strError = nil;
        int nErrorCode = [[dic objectForKey:@"error"] intValue];
        switch (nErrorCode) {
            case ND_COM_PLATFORM_ERROR_USER_CANCEL:
                strError = @"用户取消操作";
                break;
            case ND_COM_PLATFORM_ERROR_NETWORK_FAIL:
                strError = @"网络连接错误"; 
                break; 
            case ND_COM_PLATFORM_ERROR_SERVER_RETURN_ERROR: 
                strError = @"服务端处理失败";
                break;
            case ND_COM_PLATFORM_ERROR_ORDER_SERIAL_SUBMITTED:
                //!!!: 异步支付，用户进入充值界面了
                strError = @"支付订单已提交";
                break; 

            default:
                strError = @"购买过程发生错误";
                break;
        }
        str = [str stringByAppendingFormat:@"\n%@", strError];
    }
    else {
        //TODO: 购买成功处理
    }
    //本次购买的请求参数
    NdBuyInfo* buyInfo = (NdBuyInfo*)[dic objectForKey:@"buyInfo"];
    str = [str stringByAppendingFormat:@"\n<productId = %@, productCount = %d, cooOrderSerial = %@>",
           buyInfo.productId, buyInfo.productCount, buyInfo.cooOrderSerial];
    NSLog(@"NdUiPayResult: %@", str);
}
-(NSString *)getApplyOrderNoCheckParams:(NSDictionary*)payDict{
    NSString *uid = [payDict objectForKey:@"uid"];
    NSString *server_id = [payDict objectForKey:@"server_id"];
    NSString *role_id = [payDict objectForKey:@"role_id"];
    NSString *goods_id = [payDict objectForKey:@"goods_id"];
    NSString *goods_price = [payDict objectForKey:@"goods_price"];
    NSString *goods_count = [payDict objectForKey:@"goods_count"];
    //第一步，创建URL
    
    NSURL *url = [NSURL URLWithString:[Config getString:@"pay_order_url"]];
    
    //第二步，创建请求
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSMutableString * buff = [[NSMutableString alloc] init];
    [buff appendString:[self getAppId]];
    [buff appendString:[self getAppKey]];
    [buff appendString:goods_count];
    [buff appendString:goods_id];
    [buff appendString:goods_price];
    [buff appendString:role_id];
    [buff appendString:server_id];
    [buff appendString:uid];
    NSLog(@"加密参数%@",buff);
    unsigned char result[16];
    const char *cStr = [buff UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        
        [Mstr appendFormat:@"%02X",result[i]];
        
    }
    
    NSString * params = [[NSString alloc]
                         initWithFormat:@"app_id=%@&app_key=%@&uid=%@&role_id=%@&server_id=%@&goods_id=%@&goods_count=%@&goods_price=%@&sign=%@",[self getAppId],[self getAppKey],uid,role_id,server_id,goods_id,goods_count,goods_price,Mstr];
    NSData * data =[params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];;
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    NSError *error;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(!received){
        NSLog(@"请求失败%@",[error description]);
        return @"-1";
    }
    
    //NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *responsejson = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    // NSDictionary * responsedata =[responsejson objectForKey:@"data"];
    return [[responsejson objectForKey:@"data"] objectForKey:@"OrderNo"];
    //
}


-(BOOL)exitSDK:(NSString*)exitMsg {
    return YES;
}

-(NSString*)getChannelId {
    return [[NSString alloc] initWithString:@"20021"];
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
-(void)reLogin:(NSString *)mes
{
    _token =nil;
    _uid = nil;
    NSLog(@"重新登入：%@",mes);
    [Channel runScripts:NO isShowLoginFlag:NO];
}
-(void)SNSSessionInvalid:(NSNotification *)notify
{
    [self reLogin:@"session过期"];
}

- (void)SNSLoginResult:(NSNotification *)notify
{
    NSDictionary *dict = [notify userInfo];
    BOOL success = [[dict objectForKey:@"result"] boolValue];
    //NdGuestAccountStatus* guestStatus = (NdGuestAccountStatus*)[dict objectForKey:@"NdGuestAccountStatus"];
    //登录成功后处理
    if([[NdComPlatform defaultPlatform] isLogined] && success) {
    //登入成功
        [self LoginSuccess];
    }else {
        int error = [[dict objectForKey:@"error"] intValue];
        NSString* strTip = [NSString stringWithFormat:@"登录失败, error=%d", error];
        switch (error) {
            case ND_COM_PLATFORM_ERROR_USER_CANCEL://用户取消登录
                if (([[NdComPlatform defaultPlatform] getCurrentLoginState] == ND_LOGIN_STATE_GUEST_LOGIN)) {
                    strTip = @"当前仍处于游客登录状态";
                }
                else {
                    [self reLogin:@"用户未登录"];
                }
                break;
            case ND_COM_PLATFORM_ERROR_APP_KEY_INVALID://appId未授权接入, 或appKey 无效
                strTip = @"登录失败, 请检查appId/appKey";
                break;
            case ND_COM_PLATFORM_ERROR_CLIENT_APP_ID_INVALID://无效的应用ID
                strTip = @"登录失败, 无效的应用ID"; 
                break; 
            case ND_COM_PLATFORM_ERROR_HAS_ASSOCIATE_91: 
                strTip = @"有关联的91账号，不能以游客方式登录"; 
                break; 
            default: 
                 [self reLogin:@"其他"];
                break; 
        } 
    }
}
-(void)LoginSuccess{
    [[NdComPlatform defaultPlatform] NdShowToolBar:NdToolBarAtMiddleRight];
    //第一步，创建URL
    
    NSURL *url = [NSURL URLWithString:[Config getString:@"account_server_url"]];
    //第二步，创建请求
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSData *data = [self getLoginCheckParam:[[NdComPlatform defaultPlatform] loginUin] SessionId:[[NdComPlatform defaultPlatform] sessionId]] ;
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    NSError *error;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(!received){
        NSLog(@"请求失败%@",[error description]);
        [[NdComPlatform defaultPlatform] NdSwitchAccount];
        return;
    }
    
    //NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *responsejson = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    if(0 == [[responsejson objectForKey:@"success"] integerValue]){
        NSLog(@"验证失败");
        [[NdComPlatform defaultPlatform] NdSwitchAccount];
        return;
    }
    NSDictionary *datajson =[responsejson objectForKey:@"data"];
    _uid = [datajson objectForKey:@"uid"];
    [_uid retain];
    _token = [datajson objectForKey:@"token"];
    [_token retain];
    [Channel runScripts:YES isShowLoginFlag:NO];
   // [[NdComPlatform defaultPlatform] NdShowToolBar:NdToolBarAtMiddleRight];
}
/**
 *合成服务器验证数据 getLoginCheckParam
 */
-(NSData *)getLoginCheckParam:(NSString*)Uin SessionId:(NSString *)SessionId
{
       NSString *encodeSessionId = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)SessionId, NULL, NULL, kCFStringEncodingUTF8);
        NSString *encodeUin = (NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)Uin, NULL, NULL, kCFStringEncodingUTF8);
    
    NSString * buff =[[NSString alloc]initWithFormat:@"%@%@%@%@%@",
                      [self getAppId],[self getAppKey],[self getChannelId],encodeSessionId,encodeUin];
    NSLog(@"加密参数%@",buff);
    unsigned char result[16];
    const char *cStr = [buff UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        
        [Mstr appendFormat:@"%02X",result[i]];
        
    }
    NSString * param = [[NSString alloc] initWithFormat:@"app_id=%@&app_key=%@&channel_id=%@&sessionid=%@&sign=%@&uin=%@",
                        [self getAppId],[self getAppKey],[self getChannelId],encodeSessionId,Mstr,encodeUin];
    NSLog(@"请求信息：%@",param );
    return [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
}
@end
