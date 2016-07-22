// 1
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"

// Add to top of file
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";


// 2
@interface IAPHelper () <SKProductsRequestDelegate>
@end

@implementation IAPHelper {
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        NSLog(@"_productIdentifiers: %@", _productIdentifiers);
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}


// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}


// Add new method
- (void)provideSubsriptionDeadlines:(SKPaymentTransaction *)trans months:(int)months app_id:(int)app_id {
    
        NSLog(@"było: st:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"subStart"]);
        NSLog(@"było: end:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"subEnd"]);
        
        
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setMonth:months];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:trans.transactionDate options:0];
        
        NSLog(@"trans.transactionDate: %@", trans.transactionDate);
        NSDateComponents *dateComponentsD = [[NSDateComponents alloc] init];
    if( app_id == 16 ){
        [dateComponentsD setDay:-10];
    }
    else{
        [dateComponentsD setDay:-30];
    }
        NSDate *newBeginDateM6 = [calendar dateByAddingComponents:dateComponentsD toDate:trans.transactionDate options:0];
        NSLog(@"trans.transactionDate: -6 %@", newBeginDateM6 );
        
        
        [[NSUserDefaults standardUserDefaults] setValue:newBeginDateM6 forKey:@"subStart"];
        [[NSUserDefaults standardUserDefaults] setValue:newDate forKey:@"subEnd"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"jest: st:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"subStart"]);
        NSLog(@"jest: end:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"subEnd"]);
    
    
    
    
}




+ (BOOL)wasBought:(NSString *)productIdentifier {
    NSLog(@"check wasBought: %@ %@", productIdentifier, [[NSUserDefaults standardUserDefaults] objectForKey:productIdentifier]);
    return [[[NSUserDefaults standardUserDefaults] objectForKey:productIdentifier] boolValue];
}



- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}



#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
//        NSLog(@"Found product: %@ %@ %0.2f",
//              skProduct.productIdentifier,
//              skProduct.localizedTitle,
//              skProduct.price.floatValue);
    }
    
    
    //    skProducts.
    
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

- (void)restoreCompletedTransactions {
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"DUPA");
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        
        NSString *productID = transaction.payment.productIdentifier;
        NSLog(@"purchased: %@", productID );
        [purchasedItemIDs addObject:productID];
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                
                [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
                if ( [productID isEqual:@"com.setupo.rynekzoologiczny.y"]  ){
                    [self provideSubsriptionDeadlines:transaction months:12 app_id:94];
                }
                if ( [productID isEqual:@"com.setupo.rynekzoologiczny.6m"]  ){
                    [self provideSubsriptionDeadlines:transaction months:6 app_id:94];
                }
                
                if ( [productID isEqual:@"com.setupo.rynekzoologiczny.1m"]  ){
                    [self provideSubsriptionDeadlines:transaction months:1 app_id:94];
                }
                
                
                break;
                
            case SKPaymentTransactionStateRestored:
                [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
                
                if ( [productID isEqual:@"com.setupo.rynekzoologiczny.y"]  ){
                    [self provideSubsriptionDeadlines:transaction months:12 app_id:94];
                }
                if ( [productID isEqual:@"com.setupo.rynekzoologiczny.6m"]  ){
                    [self provideSubsriptionDeadlines:transaction months:6 app_id:94];
                }
                if ( [productID isEqual:@"com.setupo.rynekzoologiczny.1m"]  ){
                    [self provideSubsriptionDeadlines:transaction months:1 app_id:94];
                }
                
                
                if ( [productID containsString:@"com.setupo.issue"]){
                    NSLog(@"product do przywrocenia pojedynczy: %@", productID );
                }
                break;
                
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"failed restore");
                break;
            default:
                break;
                
        }
        
    }
    
    NSString* tresc = [NSString stringWithFormat:@"Twoje wcześniejsze zakupy zostały przywrócne."];
    
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:tresc
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"Zamknij"
                                            otherButtonTitles:nil];
    message.delegate = self;
    [message show];
    
}

- (void)paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error
{
    
    NSLog(@"canceled restore...");
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:nil];
    
    // [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}



- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"appDelegate->curentlyProcesssingProductIdentifier: %@", appDelegate->curentlyProcesssingProductIdentifier);
    if( [appDelegate->curentlyProcesssingProductIdentifier isEqual:@"(null)"] ||  (appDelegate->curentlyProcesssingProductIdentifier == [NSNull null] || appDelegate->curentlyProcesssingProductIdentifier == nil) ){
        NSLog(@"PRZERYWAM COS DZIWNEGO");
        return;
    }
    for (SKPaymentTransaction * transaction in transactions) {
        NSLog(@"transaction:%@=> %@ %ld %@", transaction.transactionIdentifier,transaction.transactionDate, transaction.transactionState, transaction.originalTransaction.transactionDate);
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                
                
                [self completeTransaction:transaction];
                NSLog(@"complete: %@", appDelegate->curentlyProcesssingProductIdentifier);
                NSLog(@"tr date: %@", transaction.transactionDate);
                
                if ( [appDelegate->curentlyProcesssingProductIdentifier isEqual:@"com.setupo.rynekzoologiczny.y"]){
                    [self provideSubsriptionDeadlines:transaction months:12 app_id:94];
                }
                
                if ( [appDelegate->curentlyProcesssingProductIdentifier isEqual:@"com.setupo.rynekzoologiczny.6m"]){
                    [self provideSubsriptionDeadlines:transaction months:6 app_id:94];
                }
                if ( [appDelegate->curentlyProcesssingProductIdentifier isEqual:@"com.setupo.rynekzoologiczny.1m"]){
                    [self provideSubsriptionDeadlines:transaction months:1 app_id:94];
                }
                
                
                [appDelegate hideFadeAnim:0.5 delay:0.0];
                [appDelegate.viewController refreshPreview];
                appDelegate->curentlyProcesssingProductIdentifier = @"";
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                NSLog(@"failed: %@", transaction.error);
                [appDelegate hideFadeAnim:0.5 delay:0.0];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                NSLog(@"restored: %@", transaction);
                [appDelegate.alreadyBought addObject: transaction.originalTransaction.payment.productIdentifier];
                
                [appDelegate hideFadeAnim:0.5 delay:0.0];
            default:
                break;
        }
        
    };
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction... %@", transaction.originalTransaction.payment.productIdentifier);
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


@end