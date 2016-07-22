#import "RageIAPHelper.h"
#import "AppDelegate.h"
@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RageIAPHelper * sharedInstance;
    NSMutableSet *x = [[NSMutableSet alloc] init];
    
    dispatch_once(&once, ^{
//        NSSet * productIdentifiers = x;
        sharedInstance = [[self alloc] initWithProductIdentifiers:x];
    });
    return sharedInstance;
}

@end