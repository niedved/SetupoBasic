//
//  AFHTTPRequestMaker.h

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define STAGING_URL_NOINDEX @"http://books.gomega.biz"
#define STAGING_URL @"http://books.gomega.biz/mobile.php"


@interface AFHTTPRequestMaker : NSObject




+ (void)sendPOSTRequestToAddress:(NSString *)urlString withDict:(NSDictionary *)dict successBlock:(void (^)(NSInteger statusCode, NSDictionary *responseObject))success failureBlock:(void (^)(NSInteger statusCode, NSError *error, NSDictionary *responseObject))failure;

+ (void)sendGETRequestToAddress:(NSString *)urlString withDict:(NSDictionary *)dict successBlock:(void (^)(NSInteger statusCode, id responseObject))success failureBlock:(void (^)(NSInteger statusCode, NSError *error))failure;

@end
