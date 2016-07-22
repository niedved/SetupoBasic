//
//  AFHTTPRequestMaker.m

#import "AFHTTPRequestMaker.h"

@interface AFHTTPRequestMaker ()

@end

@implementation AFHTTPRequestMaker


+ (void)sendPOSTRequestToAddress:(NSString *)urlString withDict:(NSDictionary *)dict successBlock:(void (^)(NSInteger statusCode, NSDictionary *responseObject))success failureBlock:(void (^)(NSInteger statusCode, NSError *error, NSDictionary *responseObject))failure {
    
    NSLog(@"POST: urlString: %@ dict: %@", urlString, dict);
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:[NSURL URLWithString:STAGING_URL]];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url.absoluteString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *key in dict) {
            NSString *value = dict[key];
            [formData appendPartWithFormData:[value dataUsingEncoding:NSUTF8StringEncoding] name:key];
        }

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if (success) {
            NSLog(@"succes");
            success(statusCode, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
            
        }
        if (failure) {
            failure(statusCode, error, nil );
        }
    }];
}

+ (void)sendGETRequestToAddress:(NSString *)urlString withDict:(NSDictionary *)dict successBlock:(void (^)(NSInteger, id))success failureBlock:(void (^)(NSInteger, NSError *))failure {
    
    NSString *sUrl = [STAGING_URL stringByAppendingString:urlString];
    NSURL *url = [NSURL URLWithString:[sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog(@"GET: urlString: %@ withDict: %@ man: %@", url.absoluteString, dict, manager);
    [manager GET:url.absoluteString parameters:dict
success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    if (success) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
            
        }
        NSLog(@"success: %@", responseObject );
        success(statusCode, responseObject);
    }
} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSInteger statusCode = 0;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = httpResponse.statusCode;
    }
    if (failure) {
//        NSLog(@"failure: %@ error: %@ ", operation.responseObject, error );
        failure(statusCode, error);
    }
}];
    
  
    
}

@end
