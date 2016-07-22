//
//  LogsController.h
//  Opolgraf
//
//  Created by Marcin Niedźwiecki on 21.06.2012.
//  Copyright (c) 2012 XCITY Game Development Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHelper.h"

enum _logType {
    LOG_TYPE_LAUNCH = 0,
    LOG_TYPE_TRACKABLE = 10,
    LOG_TYPE_BUTTON = 20,
};

const static int APP_ID = 666;
static NSString* URL_ADD_LOG =
@"http://ygd13959497c.nazwa.pl/ar_opolgraf/index.php/ajax/Common/ArLogs/dodaj_log?u_id=%@&type=%i&trackable_id=%@&app_id=%d&posx=%f&posy=%f&button_id=%@&button_type=%@";

@interface LogsController : NSObject
{
    bool gpsSaved;
    double posx, posy;
}

-(void)addLogAtLaunch :(int)user_id;
@end
