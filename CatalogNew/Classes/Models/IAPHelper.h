//
//  IAPHelper.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 05.03.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);


@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

@end
