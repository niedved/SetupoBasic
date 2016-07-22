//
//  IAPHelper.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 05.03.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "IAPHelper.h"

@import StoreKit;
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
// To receive a list of products from StoreKit, you need to implement the SKProductsRequestDelegate protocol.
// Here you mark the class as implementing this protocol in the class extension.
// For purchasing: modify the class extension to mark the class as implementing the SKPaymentTransactionObserver:

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end
@implementation IAPHelper
{
    // You create an instance variable to store the SKProductsRequest you will issue to retrieve a list of products, while it is active.
    SKProductsRequest *_productsRequest;
    // You also keep track of the completion handler for the outstanding products request, ...
    RequestProductsCompletionHandler _completionHandler;
    // ... the list of product identifiers passed in, ...
    NSSet *_productIdentifiers;
    // ... and the list of product identifiers that have been previously purchased.
    NSMutableSet * _purchasedProductIdentifiers;
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@...", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    self = [super init];
    if (self) {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
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
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    // a copy of the completion handler block inside the instance variable
    _completionHandler = [completionHandler copy];
    // Create a new instance of SKProductsRequest, which is the Apple-written class that contains the code to pull the info from iTunes Connect
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded products...");
    _productsRequest = nil;
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ – Product: %@ – Price: %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Failed to load list of products."
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    _completionHandler(NO, nil);
    _completionHandler = nil;
}


@end
