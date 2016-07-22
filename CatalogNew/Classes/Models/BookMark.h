//
//  Ishue.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 15.02.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"

@interface BookMark : NSObject{
    

@public
    int bookmark_id;
    int ishue_id;
    int pageNum;
    int app_id;
    
    
}


@property (strong, nonatomic) NSString* coverThumbUrl;
@property (strong, nonatomic) UIImage* coverThumbImg;
@property (strong, nonatomic) NSString* name;
@property (nonatomic,retain) DBController *DBC;


//- (id)initWithId:(int)bookmark_id;

- (id)initWithPageId:(int)pageId;
- (id)initWithDBBAsicInfo:(NSDictionary*)datas;
@end
