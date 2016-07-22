//  LogsController.m
//
//  Created by Marcin Niedźwiecki on 21.06.2012.
//  Copyright (c) 2012 XCITY Game Development Studio. All rights reserved.
//
#import "DBController.h"
#import "AppDelegate.h"


@implementation DBController

-(NSDictionary*)addLog :(int)mu_id action:(int)action_id param1:(NSString*)param1 param2:(NSString*)param2
{
    [AppDelegate LogIt:[NSString stringWithFormat:@"AddLog"]];
    return nil;
}



-(NSDictionary*)getAppSettingByCode: (NSString*)code{
    [AppDelegate LogIt:[NSString stringWithFormat:@"getAppSetting"]];
    NSString* url_string =
    [NSString stringWithFormat:@"%@/ajax/Common/Aplikacje/getAppSettingsByCode?code=%@", STAGING_URL , code ];
    NSLog(@"getAppSettingByCode: %@", url_string);
    NSData* data = [self getResponseDataFromPostHTML:url_string];
    NSDictionary* ret = [DBController jsonSerialize:data];
    
    return ret;
    
    
}



-(NSDictionary*)getAppSetting: (int)app_id{
    [AppDelegate LogIt:[NSString stringWithFormat:@"getAppSetting"]];
    NSString* url_string =
    [NSString stringWithFormat:@"%@/ajax/Common/Aplikacje/getAppSettings?app_id=%d", STAGING_URL , app_id ];
    NSLog(@"getAppSetting: %@", url_string);
    NSData* data = [self getResponseDataFromPostHTML:url_string];
    NSDictionary* ret = [DBController jsonSerialize:data];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if ( !ret ){
        NSLog(@"OFFLINE MODE");
        appDelegate.offlineMode = YES;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* string = [prefs stringForKey:@"lastdata_app_sets"];
        NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* retold = [DBController jsonSerialize:data];
        
        return retold;
    }
    else
    {
        appDelegate.offlineMode = NO;
        NSString* respd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:respd forKey:@"lastdata_app_sets"];
        [prefs synchronize];
        return ret;
    }
}


-(NSDictionary*)getPagesForIshue :(int)ishue_id {
    [AppDelegate LogIt:[NSString stringWithFormat:@"getPagesForIshue"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/Ishue/_mobileGetIshuePages?ishue_id=%d", STAGING_URL , ishue_id ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}

-(NSDictionary*)getButtonsForIshue :(int)ishue_id {
    [AppDelegate LogIt:[NSString stringWithFormat:@"getButtonsForIshue"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/Ishue/_mobileGetActionsForIshue?ishue_id=%d", STAGING_URL , ishue_id ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}

-(NSDictionary*)getSettingsForIshue :(int)ishue_id {
    [AppDelegate LogIt:[NSString stringWithFormat:@"getSettingsForIshue"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/Ishue/_mobileGetSettingsForIshue?ishue_id=%d", STAGING_URL , ishue_id ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}

-(NSDictionary*)getButtonsForPages :(NSString*)pages {
    [AppDelegate LogIt:[NSString stringWithFormat:@"getButtonsForPages"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/Ishue/_mobileGetPagesButtons?pages=%@", STAGING_URL , pages ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}

-(NSDictionary*)setMobileUserToken :(int)mu_id token:(NSString*)token  appId:(int)appId{
    [AppDelegate LogIt:[NSString stringWithFormat:@"setMobileUserToken"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/MobileUsers/setTokenForUser?mu_id=%d&token=%@&app_id=%d", STAGING_URL , mu_id, token, appId ];
    
    NSLog(@"url_string: %@", url_string );
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}

-(NSDictionary*)getMobileUser :(int)mu_id{
    [AppDelegate LogIt:[NSString stringWithFormat:@"getMobileUser"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/MobileUsers/getUserOrCreateNewOne?mu_id=%d", STAGING_URL , mu_id ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}

-(NSDictionary*)getIshuesForAppId :(int)app_id{
    [AppDelegate LogIt:[NSString stringWithFormat:@"getIshuesForAppId"]];
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor]UUIDString];
    
    NSString* url_string =
    [NSString stringWithFormat:@"%@/ajax/Common/Ishue/_mobileGetIshuesForAppIdNewStatic?app_id=%d&uniqeDeviceId=%@", STAGING_URL , app_id, currentDeviceId];
    NSLog(@"getIshuesForAppId: %@", url_string);
    NSData* data = [self getResponseDataFromPostHTML:url_string];
    NSDictionary* ret = [DBController jsonSerialize:data];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if ( !ret ){
        NSLog(@"OFFLINE MODE");
        appDelegate.offlineMode = YES;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* string = [prefs stringForKey:@"lastdata"];
        NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* retold = [DBController jsonSerialize:data];
        
        return retold;
    }
    else
    {
        appDelegate.offlineMode = NO;
        NSString* respd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:respd forKey:@"lastdata"];
        [prefs setObject:@"testa" forKey:@"test"];
        [prefs synchronize];
        return ret;
    }
}

//
//-(NSDictionary*)getIshuesForAppId :(int)app_id{
//    [AppDelegate LogIt:[NSString stringWithFormat:@"getIshuesForAppId"]];
//    NSString* url_string =
//    [NSString stringWithFormat:@"%@/ajax/Common/Ishue/_mobileGetIshuesForAppIdWithTopics?app_id=%d", CMS_URL , app_id ];
//    NSLog(@"getIshuesForAppId: %@", url_string);
//    NSData* data = [self getResponseDataFromPostHTML:url_string];
//    NSDictionary* ret = [DBController jsonSerialize:data];
//    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//
//
//    NSString* key = [NSString stringWithFormat:@"lastdata_%d", app_id];
//
//    if ( !ret ){
//        NSLog(@"OFFLINE MODE");
//        appDelegate.offlineMode = YES;
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSString* string = [prefs stringForKey:key];
//        NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary* retold = [DBController jsonSerialize:data];
//
//        return retold;
//    }
//    else
//    {
//        appDelegate.offlineMode = NO;
//        NSString* respd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        [prefs setObject:respd forKey:key];
//        [prefs synchronize];
//        return ret;
//    }
//}


-(NSDictionary*)getPageFilesForIssue: (int)issue_id{
    [AppDelegate LogIt:[NSString stringWithFormat:@"getPageFilesForIssue"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/Pages/getFileListForIssueAllFolder?issue_id=%d", STAGING_URL , issue_id ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}
-(NSDictionary*)getPageThumbsForIssue: (int)issue_id{
    [AppDelegate LogIt:[NSString stringWithFormat:@"getFileListForIssueThumbs"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/Pages/getFileListForIssueThumbs?issue_id=%d", STAGING_URL , issue_id ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}


-(NSDictionary*)getFileListForGallery: (int)g_id{
    [AppDelegate LogIt:[NSString stringWithFormat:@"getFileListForGallery"]];
    NSString* url_string = [NSString stringWithFormat:@"%@/ajax/Common/Pages/getFileListForGalleryFolder?g_id=%d", STAGING_URL , g_id ];
    return [DBController jsonSerialize:[self getResponseDataFromPostHTML:url_string]];
}




-(NSData*)getResponseDataFromPostHTML :(NSString*)url_string {
    [AppDelegate LogIt:[NSString stringWithFormat:@"sendPostHTML: %@", url_string]];
    NSURL *url2 = [NSURL URLWithString:url_string];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:url2];
    [request2 setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse  *response2 = nil;
    NSError *error2 = nil;
    NSData *responseData2;
    responseData2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&response2 error:&error2];
    //    NSString *responseString =
    //    [[[NSString alloc] initWithData:responseData2 encoding:NSUTF8StringEncoding] autorelease];
    
    if ([response2 statusCode] == 200 && error2 == nil) {
        return responseData2;
    }
    else{
        return nil;
    }
}

+(NSDictionary*)jsonSerialize: (NSData*)data{
    NSError *error2 = nil;
    
    if ( data.length <= 0 ){
        return nil;
    }
    else{
        NSDictionary* returnDataDict =  [NSJSONSerialization
                                         JSONObjectWithData: data//1
                                         options:kNilOptions
                                         error:&error2];
        
        return returnDataDict;
    }
    
}

@end
