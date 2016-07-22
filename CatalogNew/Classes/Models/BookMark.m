//
//  Ishue.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 15.02.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "BookMark.h"
#import "Ishue.h"
#import "AppDelegate.h"


@implementation BookMark



- (id)initWithPageId:(int)pageId{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self = [super init];
    if (self){
        //looking for page
        for (Ishue* issue in appDelegate.ishuesColection) {
//            pageNum = 0;
            int pageNumTemp = 0;
            for (NSDictionary* page in issue.pages ) {
                pageNumTemp++;

                if ( pageId == [[page objectForKey:@"id"] intValue] ){
                    ishue_id = issue->ishue_id;
                    bookmark_id = pageId;
                    
                    app_id = issue->appid;
                    self.name = [NSString stringWithFormat:@"%@", issue.name];
                    int pagenum = [issue getPageNumberBasedOnId:bookmark_id];
                    
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:
                                              [NSString stringWithFormat:@"thumb_%d_%d.jpg", ishue_id, pagenum ]];
                    self.coverThumbImg = [UIImage imageWithContentsOfFile:fullFilePath];
                    
//                    self.coverThumbImg 
                    self.coverThumbUrl =
                        [NSString stringWithFormat:@"%@/Resources/pages/%d/PREVIEWS/thumb_%d_%d.jpg", STAGING_URL_NOINDEX, ishue_id,ishue_id, pagenum];
                    
                    pageNum = pageNumTemp;
                    break;
                }
            }
            
        }
        
    }
    
    return self;
}



- (id)initWithDBBAsicInfo:(NSDictionary*)datas{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self = [super init];
    if (self){
        ishue_id = 1;
        
        NSLog(@"bookmakrs: %d %@", appDelegate->app_id, datas);
        self.coverThumbUrl = [NSString stringWithFormat:@"http://ygd13959497c.arfixer.eu/setupo_cms%@", @"/Resources/clients/1/1/3/cover_thumb.jpeg" ];
        pageNum = (arc4random() % 220) + 1;
        self.name = [NSString stringWithFormat:@"Styczeń 2014 - page: %d", pageNum];
    }
    
    return self;
}



@end
