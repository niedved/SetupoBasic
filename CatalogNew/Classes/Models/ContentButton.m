//
//  MobileUser.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 21.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "ContentButton.h"
#import "DBController.h"

@implementation ContentButton


- (id)initWithDatasId: (NSMutableDictionary*)datas{

    self.button_id = [[datas objectForKey:@"button_id"] intValue];
    self.type_id = [[datas objectForKey:@"type_id"] intValue];
    self.action = [datas objectForKey:@"action"];
    self.btnico = [datas objectForKey:@"btnico"];
    self.icon_hided = [[datas objectForKey:@"icon_hided"] boolValue];
    self.position_left = [[datas objectForKey:@"position_left"] doubleValue];
    self.position_top = [[NSString stringWithFormat:@"%.2f",[[datas objectForKey:@"position_top"] floatValue]]floatValue];
    self.position_width = [[datas objectForKey:@"position_width"] floatValue];
    self.position_height = [[datas objectForKey:@"position_height"] floatValue];
    self.ico_position_left = [[datas objectForKey:@"ico_position_left"] floatValue];
    self.ico_position_top = [[datas objectForKey:@"ico_position_top"] floatValue];
    
    return self;
}




@end
