#import <StoreKit/StoreKit.h>

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;


- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
+ (BOOL)wasBought:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
