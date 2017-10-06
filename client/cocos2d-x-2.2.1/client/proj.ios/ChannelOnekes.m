/****************************************************************************
 *** 自有
 ****************************************************************************/
#import "ChannelOnekes.h"
#include "Channel.h"

@implementation ChannelOnekes
   NSDictionary *payInfo =  nil;
   bool isAddListen = FALSE;  //linster只添加一次
   bool isWaiting = FALSE;     //是否在等待

-(BOOL)initSDK:(NSString*)initMsg {
    [Channel runScripts:NO isShowLoginFlag:NO];
    return YES;
}


-(BOOL)paySDK:(NSDictionary*)payDict {
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"失败，用户禁止应用内付费购买.");
        return false;
    }
    
    if (isWaiting == TRUE) {
        NSLog(@"正在等待中 请骚等");
        return false;
    }
    
    if (isAddListen == FALSE) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        isAddListen = TRUE;
    }
    
    //addLoad
    [SdkUtil showLoadingCirle];
    isWaiting = TRUE;
    
    // 处理未完成的交易
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
   
    if (transactions.count > 0)
    {
        printf("存在处理未完成的交易 \n");
        //检测是否有未完成的交易
        SKPaymentTransaction* transaction = [transactions firstObject];
        if (transaction.transactionState == SKPaymentTransactionStatePurchased)
        {
            [self completeTransaction:transaction];
            return YES;
        }
    }
 
    payInfo = payDict;
    [payInfo retain];
    
    NSString* goods_id = [payDict objectForKey:@"goods_id"];
    
    NSString *iosGoodid = [NSString stringWithFormat:@"com.onekes.mszgid%@", goods_id];
    
    NSLog(@"GOODIS=%@",iosGoodid);
    //NSSet * set = [NSSet setWithArray:@[@"com.buytest.one"]];//goods_id --fix by sl
    NSSet * productIdentifiers = [NSSet setWithObject:iosGoodid];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
    return YES;
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        NSLog(@"无法获取产品信息，购买失败。");
        [self payEnd];
        return;
    }
    for(SKProduct *product in myProduct)
    {
        NSLog(@"product info");
        NSLog(@"product title:%@",product.localizedTitle);
        NSLog(@"product price:%@",product.price);
        NSLog(@"product id%@",product.productIdentifier);
    }
    
    //发送购买商品请求
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)payEnd {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [payInfo release];
    payInfo = nil;
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"商品添加进列表");
                break;
            default:
                break;
            
        }
    }
    //[self payEnd];
}
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    // Your application should implement these two methods.
    NSString * productIdentifier = transaction.payment.productIdentifier;
    NSString * receipt = [transaction.transactionReceipt base64Encoding];
    //NSString * receipt  = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    
    
    [SdkUtil closeLoadingCirle];
    isWaiting = false;
    
    if ([productIdentifier length] > 0) {
        NSError *error;
        NSMutableDictionary *sendDict =[[NSMutableDictionary alloc]initWithDictionary:payInfo];
        
        //NSMutableDictionary *sendDict =[[NSMutableDictionary alloc]init];
        

        
        [sendDict setObject:[self getAppId] forKey:@"app_id"];
        [sendDict setObject:[self getAppKey] forKey:@"app_key"];
        
        [sendDict setObject:receipt forKey:@"receipt"];
         //NSLog(@"%@",receipt);
        [sendDict setObject:@"sanbox_false" forKey:@"verifyStatus"];
        //[sendDict setObject:[self getUid] forKey:@"uid"];
        
        [sendDict removeObjectForKey:@"role_name"];
        [sendDict removeObjectForKey:@"goods_name"];
        
        [SdkUtil showAlertTip:@"购买结果" tip:@"购买成功："];
        //NSLog(@"购买验证：%@",receipt) ;
        //测试请求
        NSString *urlstr = [Config getString:@"pay_url"];
        [SdkUtil postParameterToServer:sendDict url:urlstr error:error];
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}


- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        [SdkUtil showAlertTip:@"购买结果" tip:@"购买失败"];
    } else {
         [SdkUtil showAlertTip:@"购买结果" tip:@"购买取消"];
    }
    [SdkUtil closeLoadingCirle];
    isWaiting = false;
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 对于已购商品，处理恢复购买的逻辑
    [SdkUtil closeLoadingCirle];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
-(NSString*)getChannelId {
    return [[NSString alloc] initWithString:@"20111"];
}

-(NSString *)getAppId{
    return @"30001";
}

-(NSString *)getAppKey{
    return @"8a808023468dd22001468dd220270000";
}

@end
