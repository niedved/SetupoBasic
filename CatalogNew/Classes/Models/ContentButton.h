//
//  MobileUser.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 21.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentButton : NSObject

@property (nonatomic, assign) int button_id;
@property (nonatomic, assign) BOOL icon_hided;
@property (nonatomic, assign) int type_id;
@property (nonatomic, assign) double position_left;
@property (nonatomic, assign) float position_top;
@property (nonatomic, assign) float position_right;
@property (nonatomic, assign) float position_bottom;
@property (nonatomic, assign) float position_width;
@property (nonatomic, assign) float position_height;
@property (nonatomic, assign) float ico_position_left;
@property (nonatomic, assign) float ico_position_top;
@property (nonatomic, strong, readwrite) NSString *action;
@property (nonatomic, strong, readwrite) NSString *btnico;


- (id)initWithDatasId: (NSMutableDictionary*)datas;

@end
