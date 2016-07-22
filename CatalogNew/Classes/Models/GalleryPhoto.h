//
//  GalleryPhoto.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 07.06.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestMaker.h"


@interface GalleryPhoto : NSObject


@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* link;
@property (strong, nonatomic) NSString* locallink;
@property int gallery_id;
@property bool fileexist;



-(id)initWithDBDatas:(NSDictionary*)data;

-(void)checkagain;
@end
