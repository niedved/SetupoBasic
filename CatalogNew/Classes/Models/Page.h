//
//  KioskHelper.h
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 03.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "Ishue.h"

@interface Page : NSObject{
    
}

@property BOOL forceonepage;

@property int pageid;
@property int pagenum;
@property int issue_id;

@property float width;
@property float pageupsize;
@property float pagesizex;

@property float height;
@property float page_prop;
@property float offset_x_land, offset_x_port;
@property float offset_y_land, offset_y_port;

@property NSMutableArray* buttons;


-(Page*)initWithPageNum:(int)pagenum issue:(Ishue*)issue;
-(Page*)initWithPageId:(int)pageid issue:(Ishue*)issue;
-(void)reloadOffsets;
-(float)getOrientedOffsetX;
-(float)getOrientedOffsetY;
-(void)prepareButtonsDictinaries;
-(int)getPageViewNum;


-(NSString*)pathToPdfPageFile;
-(NSString*)pathToJPGPageFile;
-(UIImage*)getImageJPGPageFile;

@end
