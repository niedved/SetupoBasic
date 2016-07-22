//
//  GalleryPhoto.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 07.06.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "GalleryPhoto.h"

@implementation GalleryPhoto


-(id)initWithDBDatas:(NSDictionary*)data{
    self = [super init];
    if (self){
        
        self.name =
            [NSString stringWithFormat:@"%@.%@",
            [data objectForKey:@"gf_id"],[data objectForKey:@"type"]];
    
        self.gallery_id = [[data objectForKey:@"gd_id"] intValue];
        
        self.link = [NSString stringWithFormat:@"%@/Resources/gallery/%d/%@",STAGING_URL_NOINDEX,
                     self.gallery_id, self.name ];
        
        NSString *documentsDirectory =
            [NSSearchPathForDirectoriesInDomains(
                NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.locallink = [documentsDirectory stringByAppendingPathComponent:self.name];
        self.fileexist = [[NSFileManager defaultManager] fileExistsAtPath:self.locallink];
        
        
    }
    return self;
}


-(void)checkagain{
    NSString *documentsDirectory =
    [NSSearchPathForDirectoriesInDomains(
                                         NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.locallink = [documentsDirectory stringByAppendingPathComponent:self.name];
    self.fileexist = [[NSFileManager defaultManager] fileExistsAtPath:self.locallink];
}



@end
