//
//  LogsController.m
//  Opolgraf
//
//  Created by Marcin Niedźwiecki on 21.06.2012.
//  Copyright (c) 2012 XCITY Game Development Studio. All rights reserved.
//

#import "LogsController.h"
#import "DBController.h"

@implementation LogsController


-(void)addLogAtLaunch :(int)user_id {
    DBController* DB = [[DBController alloc] init];
    [DB addLog:user_id action:0 param1:@"0" param2:@"0"];
}



@end
