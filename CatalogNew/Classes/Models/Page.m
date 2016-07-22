//
//  KioskHelper.m
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 03.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//
#import "AppDelegate.h"
#import "Page.h"
#import "NHelper.h"

@implementation Page

-(Page*)initWithPageNum:(int)pagenum issue:(Ishue*)issue{
    self = [super init];
    if (self){
        NSDictionary* _page = [(NSMutableArray*)issue.pages objectAtIndex:pagenum-1];
        self.width = [[_page objectForKey:@"w"] floatValue];
        self.issue_id = issue->ishue_id;
        self.height = [[_page objectForKey:@"h"] floatValue];
       
        self.page_prop = self.height / self.width;
        self.pageid = [[_page objectForKey:@"id"] intValue];
        self.pagenum = pagenum;
        self.pageupsize = issue->pagesizeup;
        self.pagesizex = issue->pagesizex;
        self.forceonepage = issue->forceOnePagePerView;
        [self reloadOffsets];
        [self prepareButtonsDictinaries];
    }
    return self;
}

-(Page*)initWithPageId:(int)pageid issue:(Ishue*)issue{
    self.pageid = pageid;
    self = [super init];
    self.pagenum = 0;
    if (self){
        for (NSDictionary* _page in issue.pages) {
            self.pagenum++;
            if ( [[_page objectForKey:@"id"] intValue] == pageid ){
                self.width = [[_page objectForKey:@"w"] floatValue];
                self.height = [[_page objectForKey:@"h"] floatValue];
                self.page_prop = self.height / self.width;
                self.issue_id = issue->ishue_id;
                
                self.pageupsize = issue->pagesizeup;
                self.pagesizex = issue->pagesizex;
                
                self.forceonepage = issue->forceOnePagePerView;
                [self reloadOffsets];
                [self prepareButtonsDictinaries];
                return self;
            }
        }
    }
    return nil;
}

-(void)reloadOffsetsForIphone{
    if( [NHelper isIphone]){
        self.offset_y_land = 0;
        self.offset_x_land = 0;
    }
    double propW = 0;
    double propH = 0;
    double prop = 0;
    
    CGSize sizeP = [NHelper getSizeOfCurrentDevicePortrait];
    propW = sizeP.width / self.width;
    propH = sizeP.height / self.height;
    prop = (propW < propH) ? propW : propH;
    self.offset_y_port = (sizeP.height - self.height*prop) / 2;
    self.offset_x_port = (sizeP.width - self.width*prop) / 2;
    
    CGSize sizeL = [NHelper getSizeOfCurrentDeviceLandscape];
    propW = sizeL.width/2 / self.width;
    propH = sizeL.height / self.height;
    prop = (propW < propH) ? propW : propH;
    
    self.offset_y_land = (sizeL.height - self.height*prop) / 2;
    self.offset_x_land = 0;
    
}
-(void)reloadOffsets{
    if( [NHelper isIphone]){
        self.offset_y_land = 0;
        self.offset_x_land = 0;
    }
    double propW = 0;
    double propH = 0;
    double prop = 0;
    if ( [NHelper isIphone] ){
        [self reloadOffsetsForIphone];
    }
    else if( !self.forceonepage ){
        CGSize sizeP = [NHelper getSizeOfCurrentDevicePortrait];
        propW = sizeP.width / self.width;
        propH = sizeP.height / self.height;
        prop = (propW < propH) ? propW : propH;
        self.offset_y_port = (sizeP.height - self.height*prop) / 2;
        self.offset_x_port = (sizeP.width - self.width*prop) / 2;
        
        CGSize sizeL = [NHelper getSizeOfCurrentDeviceLandscape];
        propW = sizeL.width/2 / self.width;
        propH = sizeL.height / self.height;
        prop = (propW < propH) ? propW : propH;
        
        self.offset_y_land= (sizeL.height - self.height*prop) / 2;
        self.offset_x_land = (sizeL.width/2 - self.width*prop) / 2;
        
    }
    else{ //poziomo
        CGSize sizeP = [NHelper getSizeOfCurrentDevicePortrait];
        propW = sizeP.width / self.width;
        propH = sizeP.height / self.height;
        prop = (propW < propH) ? propW : propH;
        self.offset_y_port = (sizeP.height - self.height*prop) / 2;
        self.offset_x_port = 0;
        
        CGSize sizeL = [NHelper getSizeOfCurrentDeviceLandscape];
        propW = sizeL.width / self.width;
        propH = sizeL.height / self.height;
        prop = (propW < propH) ? propW : propH;
        
        self.offset_y_land= (sizeL.height - self.height*prop) / 2;
        self.offset_x_land = (sizeL.width - self.width*prop) / 2;
    }
    
    
}

-(float)getOrientedOffsetX{
    [self reloadOffsets];
    if( [NHelper isLandscapeInReal])
        return self.offset_x_land;
    else
        return self.offset_x_port;
}
-(float)getOrientedOffsetY{
    [self reloadOffsets];
    if( [NHelper isLandscapeInReal])
        return self.offset_y_land;
    else
        return self.offset_y_port;
}

-(int)getPageViewNum{
    
    if( self.forceonepage){
        return self.pagenum;
    }
    else if( [NHelper isIphone]){
        return self.pagenum;
    }
    else{ //ipad noforce
        if ( [NHelper isLandscapeInReal]  ){
            return (self.pagenum+2) / 2;
        }
        else{
            return self.pagenum;
        }
    }
}


-(void)prepareButtonsDictinaries{
    self.buttons = [[NSMutableArray alloc] init];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Ishue* ishue = appDelegate.currentIshue;
    NSDictionary* buttons = ishue.buttonsForCurrentIshue;
    
    if ( [buttons count] > 0 ){
        NSMutableArray* buttonsForThisPage = [ishue getButtonsForPage:self.pageid];
        for (NSDictionary* buttonData in buttonsForThisPage) {
            NSMutableDictionary* buttonInfo = [[NSMutableDictionary alloc] init];
            [buttonInfo setObject:[buttonData objectForKey:@"ia_id"] forKey:@"button_id"];
            [buttonInfo setObject:[buttonData objectForKey:@"action_tid"] forKey:@"type_id"];
            [buttonInfo setObject:[buttonData objectForKey:@"full_link"] forKey:@"action"];
            [buttonInfo setObject:[buttonData objectForKey:@"posX"] forKey:@"position_left"];
            [buttonInfo setObject:[buttonData objectForKey:@"posY"] forKey:@"position_top"];
            [buttonInfo setObject:[buttonData objectForKey:@"ico_posX"] forKey:@"ico_position_left"];
            [buttonInfo setObject:[buttonData objectForKey:@"ico_posY"] forKey:@"ico_position_top"];
            [buttonInfo setObject:[buttonData objectForKey:@"width"] forKey:@"position_width"];
            [buttonInfo setObject:[buttonData objectForKey:@"height"] forKey:@"position_height"];
            [buttonInfo setObject:[buttonData objectForKey:@"icon_hided"] forKey:@"icon_hided"];
            
            
            switch ( [[buttonData objectForKey:@"icon_id"] integerValue] ) {
                case 1:
                    [buttonInfo setObject:
                     [appDelegate.currentIshue.iconSettings objectForKey:@"audio_icon_name"] forKey:@"btnico"];
                    break;
                case 2:
                    [buttonInfo setObject:
                     [appDelegate.currentIshue.iconSettings objectForKey:@"gallery_icon_name"] forKey:@"btnico"];
                    break;
                case 3:
                    [buttonInfo setObject:
                     [appDelegate.currentIshue.iconSettings objectForKey:@"link_icon_name"] forKey:@"btnico"];
                    break;
                case 4:
                    [buttonInfo setObject:
                     [appDelegate.currentIshue.iconSettings objectForKey:@"video_icon_name"] forKey:@"btnico"];
                    
                    
                    break;
            }
            
            
            [self.buttons insertObject:
             [[ContentButton alloc] initWithDatasId:buttonInfo] atIndex:self.buttons.count];
            
            
        }
        
        
    }
}


-(NSString*)pathToPdfPageFile{
    NSString *filePathPDF = [[NHelper pathToDocumentsDict] stringByAppendingPathComponent:[NSString stringWithFormat:@"page_%d_%d.pdf",self.issue_id ,self.pagenum]];
    NSLog(@"filePathPDF: %@", filePathPDF);
    return filePathPDF;
}
-(NSString*)pathToJPGPageFile{
    NSString *filePath = [[NHelper pathToDocumentsDict] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%d.jpg",self.issue_id ,self.pagenum]];
    return filePath;
}

-(UIImage*)getImageJPGPageFile{
    return [UIImage imageWithContentsOfFile: [self pathToJPGPageFile]];
}




@end
