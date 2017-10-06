
 
#include "AppStoreIap.h"
//#include "../scripting/lua-bindings/manual/CCLuaEngine.h"
//#include "../scripting/lua-bindings/manual/CCLuaBridge.h"
 
@implementation AppStoreIapLayer

NSString *m_strProductID = @"com.onekes.mszg.appstore";

 
//支付
-(BOOL)paySDK:(NSDictionary*)payDict {
    
    if ([SKPaymentQueue canMakePayments]) {
        
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:(m_strProductID)];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        return TRUE;
    }else{
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"不允许程序内付费购买"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        [alerView show];
        [alerView release];
        return FALSE;
    }
}

//查询
-(void)RequestProductData
{
    NSLog(@"--------请求对应的产品信息-----------------");
    // 查询产品信息：使用传入的产品id。调用SKProductsRequest方法，传入待查询的产品identifier。
    NSArray *product = nil;
    product = [[NSArray alloc] initWithObjects:m_strProductID, nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate = self;
    [request start];
    [product release];
}

-(void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"--------收到产品的信息反馈-----------------");
    NSArray *myProduct = response.products;
    if (myProduct.count==0)
    {
        NSLog(@"无效的产品Product ID:%@",response.invalidProductIdentifiers);
        NSLog(@"无法获取产品信息，购买失败！");
        return;
    }
    
    // 返回了正确的产品信息：
    
    NSLog(@"产品付费数量: %d", [myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }
    
    // 支付，购买该产品。
    if ([self restoreCompletedTransactions])
        return;
    
    //    SKPayment *payment = nil;
    //    payment  = [SKPayment paymentWithProductIdentifier:@(m_strProductID.c_str())];
    //    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [self payToApp];
    
    [request autorelease];
}


//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions //交易结果
{
    NSLog(@"收到交易结果。");
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                //[self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
            }
                break;
            case SKPaymentTransactionStateFailed://交易失败
            {
                //[self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
 
            }
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                //[self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
            }
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
            {
                NSLog(@"-----商品添加进列表 --------");
            }
                break;
            default:
                break;
        }
    }
}


-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    // [transactions release];
}

- (void) completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction");
    //NSString *receipte = [transaction.transactionReceipt ]
    m_PayTranObj = transaction;
}


-(void)xgComplete
{
    // Remove the transaction from the payment queue.
    CCLog("到了这里，才能确定此单交易完成。");
    [[SKPaymentQueue defaultQueue] finishTransaction: m_PayTranObj];
    
    //cocos2d::CCNotificationCenter::sharedNotificationCenter()->postNotification("IapComplete");
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // 能打印出失败的原因么？
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // 告诉脚本完成事务，关闭菊花。
    //cocos2d::CCNotificationCenter::sharedNotificationCenter()->postNotification("IapComplete");
}
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction

{
    NSLog(@" 交易恢复处理");
}

- (bool)restoreCompletedTransactions
{
    CCLog("恢复交易处理。");
    
    [[SKPaymentQueue defaultQueue] addPayment:NULL];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    CCLog("看看还有几条事务未处理：%d", [SKPaymentQueue defaultQueue].transactions.count);
    NSLog(@"%d",[SKPaymentQueue defaultQueue].transactions.count);
    if( [SKPaymentQueue defaultQueue].transactions.count>0)
    {
        // m_bLeakage = true;
        CCLog("有事务未处理，逐一处理，取出事务，判断事务状态，继续后续操作。");
        NSArray *transactions = [SKPaymentQueue defaultQueue].transactions;
        for (SKPaymentTransaction *transaction in transactions)
        {
            NSLog(@"本次状态%d",(int)transaction.transactionState);
            switch (transaction.transactionState)
            {
                case SKPaymentTransactionStatePurchased:
                {
                    //[self completeTransaction:transaction];
                }
                    break;
                case SKPaymentTransactionStateFailed:
                {
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                }
                    break;
                case SKPaymentTransactionStateRestored:
                {
                    [self restoreTransaction:transaction];
                }
                default:
                    break;
            }
        }
        return true;
        //        NSLog(@"队列大小%d",[SKPaymentQueue defaultQueue].transactions.count);
        //        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        //        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
    return false;
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----");
}


#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@",  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    switch([(NSHTTPURLResponse *)response statusCode]) {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"test");
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
    [super dealloc];
}

-(NSString*)getChannelId {
    return [[NSString alloc] initWithString:@"20111"];
}

-(NSString*)getUid {
    return @"uid";
}

-(NSString*)getToken {
    return @"token";
}

@end

