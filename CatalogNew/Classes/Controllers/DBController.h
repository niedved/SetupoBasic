//
//  LogsController.h
//
//  Created by Marcin Niedźwiecki on 21.06.2012.
//  Copyright (c) 2012 XCITY Game Development Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestMaker.h"


@interface DBController : NSObject{
    
}


-(NSDictionary*)getAppSettingByCode: (NSString*)code;
-(NSDictionary*)getAppSetting: (int)app_id;
-(NSDictionary*)addLog :(int)mu_id action:(int)action_id param1:(NSString*)param1 param2:(NSString*)param2;
-(NSDictionary*)getPagesForIshue :(int)ishue_id;
-(NSDictionary*)getButtonsForIshue :(int)ishue_id;
-(NSDictionary*)getSettingsForIshue :(int)ishue_id;
-(NSDictionary*)getButtonsForPages :(NSString*)pages;
-(NSDictionary*)getIshuesForAppId :(int)app_id;
-(NSDictionary*)getPageFilesForIssue: (int)issue_id;
-(NSDictionary*)getPageThumbsForIssue: (int)issue_id;
-(NSDictionary*)getFileListForGallery: (int)g_id;
-(NSDictionary*)setMobileUserToken :(int)mu_id token:(NSString*)token appId:(int)appId;
-(NSDictionary*)getMobileUser :(int)mu_id;


+(NSDictionary*)jsonSerialize: (NSData*)data;

@end
