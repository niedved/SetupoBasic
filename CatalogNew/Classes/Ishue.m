//
//  Ishue.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 15.02.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "Ishue.h"
#import "NHelper.h"
#import "RageIAPHelper.h"
@implementation Ishue


-(void) setSettings{
    NSDictionary* settings = [self.DBC getSettingsForIshue:ishue_id];
    
    NSString * jsonString = [settings objectForKey:@"bg"];
    NSStringEncoding  encoding = 0;
    NSData * jsonData = [jsonString dataUsingEncoding:encoding];
    NSError * error=nil;
    if ( jsonData ){
        NSArray * parsedDataBG = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
        bg = [UIColor colorWithRed:[[parsedDataBG objectAtIndex:0] floatValue]/255.0
                             green:[[parsedDataBG objectAtIndex:1] floatValue]/255.0
                              blue:[[parsedDataBG objectAtIndex:2] floatValue]/255.0 alpha:1.0f];
        
        NSLog(@"settings: %@", settings);
        price = [[settings objectForKey:@"price"] intValue];
        swipe_type = [[settings objectForKey:@"swipe_type"] intValue];
        orientation = [[settings objectForKey:@"orientation"] intValue];
//        swipe_type = 2;
        switch( swipe_type ){
            case 1: self.transStyle = UIPageViewControllerTransitionStylePageCurl; break;
            case 2: self.transStyle = UIPageViewControllerTransitionStyleScroll; break;
            default: self.transStyle = UIPageViewControllerTransitionStyleScroll; break;
        }
        
        

    }
    
}





-(NSMutableArray*)getThumbsCorrectDownloadedCollection{
    NSMutableArray* thumbsCol = [[NSMutableArray alloc] init];
    for( int i=4; i <= [self.pages count]; i++ ){
        NSString* fileName = [NSString stringWithFormat:@"thumb_%d_%d.jpg", ishue_id, i];
        NSString* pathtotest = [[self pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
        BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathtotest];
        if ( !pageFileExists ){
//            NSLog(@"brakuje pliku: %@", pathtotest );
        }
        else{
            [thumbsCol addObject:pathtotest];
        }
        
    }
    return thumbsCol;
}

-(NSMutableArray*)getPrevCorrectDownloadedCollection{
    NSMutableArray* thumbsCol = [[NSMutableArray alloc] init];
    for( int i=4; i <= [self.pages count]; i++ ){
        NSString* fileName = [NSString stringWithFormat:@"%d_%d.jpg", ishue_id, i];
        NSString* pathtotest = [[self pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
        BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathtotest];
        if ( !pageFileExists ){
//            NSLog(@"brakuje pliku: %@", pathtotest );
        }
        else{
            [thumbsCol addObject:pathtotest];
        }
        
    }
    return thumbsCol;
}

-(NSMutableArray*)getPdfsCorrectDownloadedCollection{
    NSMutableArray* thumbsCol = [[NSMutableArray alloc] init];
    for( int i=1; i <= [self.pages count]; i++ ){
        NSString* fileName = [NSString stringWithFormat:@"page_%d_%d.pdf", ishue_id, i];
        NSString* pathtotest = [[self pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
        BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathtotest];
        if ( !pageFileExists ){
//            NSLog(@"brakuje pliku: %@", pathtotest );
        }
        else{
            [thumbsCol addObject:pathtotest];
        }
        
    }
    return thumbsCol;
}
//

-(float)getSizeOffAllDownlaodedFiles{
//    NSLog(@"delete files: %@", self.filesAlreadyDownloaded );
    float size = 0;
    
    //ZIP
    for (NSString* file in self.filesAlreadyDownloaded) {
        NSLog(@"file: %@", file);
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
        size += [fileDictionary fileSize];
    }
    //THUMBS
    for (NSString* file in [self getThumbsCorrectDownloadedCollection]) {
        NSLog(@"file: %@", file);
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
        size += [fileDictionary fileSize];
    }
    
    //PREVS
    for (NSString* file in [self getPrevCorrectDownloadedCollection]) {
        NSLog(@"file: %@", file);
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
        size += [fileDictionary fileSize];
    }

    //PDFS
    for (NSString* file in [self getPdfsCorrectDownloadedCollection]) {
        NSLog(@"file: %@", file);
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
        size += [fileDictionary fileSize];
    }
    
    size = size / 1024000.0;
//    NSLog(@"filesize: %f", size);
    return size;
}

-(void)removeAllIssueFilesFromDevice{
    //ZIP
    for (NSString* file in self.filesAlreadyDownloaded) {
        [self removeFile:file];
    }
    //THUMBS
    for (NSString* file in [self getThumbsCorrectDownloadedCollection]) {
        [self removeFile:file];
    }
    
    //PREVS
    for (NSString* file in [self getPrevCorrectDownloadedCollection]) {
        [self removeFile:file];
    }
    
    //PDFS
    for (NSString* file in [self getPdfsCorrectDownloadedCollection]) {
        [self removeFile:file];
    }
}


-(NSString*)pathToIssuePagesFile{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFilePath = documentsDirectory;
    return fullFilePath;
}


- (void)removeFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"deleted");
//        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removeSuccessFulAlert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}




-(void)loadAllIssueFiles{
    self.filesForIssue = [[NSMutableArray alloc] init];
    self.filesForThumbs = [[NSMutableArray alloc] init];
    self.filesToDownload = [[NSMutableArray alloc] init];
    self.filesAlreadyDownloaded = [[NSMutableArray alloc] init];
    
    [self.filesForIssue  addObject:[NSString stringWithFormat:@"%d.zip",ishue_id]];
    
    
    for (NSString* fileName in self.filesForIssue) {
        NSString* urltotest = [[self pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
        BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:urltotest];
        if ( !pageFileExists ){
            [self.filesToDownload addObject:
             [NSString stringWithFormat:@"%@/Resources/pages/%d/%@", STAGING_URL_NOINDEX, ishue_id, fileName]
             ];
        }
        else{
            [self.filesAlreadyDownloaded addObject:urltotest];
        }
    }
    
    
}

-(BOOL)checkThumbsCorrectDownloaded{
    BOOL corecct = YES;
   
    for( int i=1; i <= [self.pages count]; i++ ){
        NSString* fileName = [NSString stringWithFormat:@"thumb_%d_%d.jpg", ishue_id, i];
        NSString* pathtotest = [[self pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
        BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathtotest];
        if ( !pageFileExists ){
//            NSLog(@"brakuje pliku: %@", pathtotest );
            return NO;
        }
        
    }
    return corecct;
}


-(BOOL)checkPdfCorrectSplited{
    BOOL corecct = YES;
    
    for( int i=1; i <= [self.pages count]; i++ ){
        NSString *fileName = [NSString stringWithFormat:@"page_%d_%d.pdf",ishue_id ,i];
    
        
        NSString* pathtotest = [[self pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
        BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathtotest];
        if ( !pageFileExists ){
//            NSLog(@"brakuje pliku: %@", pathtotest );
            return NO;
        }
        
    }
    return corecct;
}



- (id)initWithId:(int)_ishue_id{
    self = [super init];
    if (self){
        ishue_id = _ishue_id;
        
        self.DBC = [[DBController alloc] init];
        [self setSettings];
        [self reloadPagesInfo];
        [self reloadButtonsInfo];
    }
    return self;
}




-(void) setSettingsWithData:(NSDictionary*)settings{
//    NSDictionary* settings = [self.DBC getSettingsForIshue:ishue_id];
    self.iconSettings = [[NSMutableDictionary alloc] init];
    [self.iconSettings setObject:[settings objectForKey:@"audio"] forKey:@"audio"];
    [self.iconSettings setObject:
        [NSString stringWithFormat:@"ICO_%@_A_%@.png",
            [settings objectForKey:@"audio"], @"FFFFFF"
//         ,   [[settings objectForKey:@"audio_rgb"] uppercaseString]
         ]
        forKey:@"audio_icon_name"];
    
    audio_rgb = [[settings objectForKey:@"audio_rgb"] uppercaseString];
    
    [self.iconSettings setObject:[settings objectForKey:@"gallery"] forKey:@"gallery"];
    NSString* icoGname = [NSString stringWithFormat:@"ICO_%@_G_%@.png",
                          [settings objectForKey:@"gallery"],
                          @"FFFFFF"];
    [self.iconSettings setObject: icoGname forKey:@"gallery_icon_name"];
    
    gallery_rgb = [[settings objectForKey:@"gallery_rgb"] uppercaseString];
    
    [self.iconSettings setObject:[settings objectForKey:@"video"] forKey:@"video"];
    [self.iconSettings setObject:
     [NSString stringWithFormat:@"ICO_%@_V_%@",
      [settings objectForKey:@"video"],
      @"FFFFFF" ]
                          forKey:@"video_icon_name"];
    link_rgb = [[settings objectForKey:@"link_rgb"] uppercaseString];
    video_rgb = [[settings objectForKey:@"video_rgb"] uppercaseString];
    
    
    
    [self.iconSettings setObject:[settings objectForKey:@"link"] forKey:@"link"];
    [self.iconSettings setObject:
     [NSString stringWithFormat:@"ICO_%@_L_%@",
      [settings objectForKey:@"link"],
      @"FFFFFF" ]
                          forKey:@"link_icon_name"];
    
    NSArray * jsonString = [settings objectForKey:@"bg"];
    
    bg = [UIColor colorWithRed:[[jsonString objectAtIndex:0] floatValue]/255.0
                             green:[[jsonString objectAtIndex:1] floatValue]/255.0
                              blue:[[jsonString objectAtIndex:2] floatValue]/255.0 alpha:1.0f];

    price = [[settings objectForKey:@"price"] intValue];
    orientation = [[settings objectForKey:@"orientation"] intValue];
    swipe_type = [[settings objectForKey:@"swipe_type"] intValue];
    forceOnePagePerView = [[settings objectForKey:@"force_one"] boolValue];
    pagesizeup= [[settings objectForKey:@"pagesizeup"] floatValue];
    pagesizex= [[settings objectForKey:@"pagesizex"] floatValue];
    
}


-(void)reloadPagesInfoWithData:(NSDictionary*)pages{
    self.pages = pages;
//    [self.DBC getPagesForIshue:ishue_id];
    NSLog(@"ishue id: %d pages: %@", ishue_id, self.pages );
}


-(void)preapreTopicsFromDBInfo:(NSDictionary*)datas{
    self.issueTopics = [[NSMutableDictionary alloc] init];
    
    [self.issueTopics setObject:[datas objectForKey:@"t1"] forKey:@"t1"];
    [self.issueTopics setObject:[datas objectForKey:@"t2"] forKey:@"t2"];
    [self.issueTopics setObject:[datas objectForKey:@"t3"] forKey:@"t3"];
    [self.issueTopics setObject:[datas objectForKey:@"t4"] forKey:@"t4"];
    [self.issueTopics setObject:[datas objectForKey:@"d1"] forKey:@"d1"];
    [self.issueTopics setObject:[datas objectForKey:@"d2"] forKey:@"d2"];
    [self.issueTopics setObject:[datas objectForKey:@"d3"] forKey:@"d3"];
    [self.issueTopics setObject:[datas objectForKey:@"d4"] forKey:@"d4"];
    
}


- (id)initWithDBBAsicInfo:(NSDictionary*)datas{
//    NSLog(@"initWithDBBAsicInfo: %@", datas);
//    double t_s = [[NSDate date] timeIntervalSince1970];
    self = [super init];
    if (self){
        self.DBC = [[DBController alloc] init];
        ishue_id = (int)[[datas objectForKey:@"id"] integerValue];
        [self preapreTopicsFromDBInfo:datas];
        
//        forceOnePagePerView = NO;
        
        NSDictionary* settings = [datas objectForKey:@"settings"];
        if ( ![settings isEqual:[NSNull null]] ){
            [self setSettingsWithData: settings];
        }
        else{
            NSLog(@"set def sets");
        }
        
        NSMutableDictionary* paymentsInfo = [datas objectForKey:@"payments"];
        if ( ![paymentsInfo isEqual:[NSNull null]] ){
            self.payments = paymentsInfo;
            //            [self setSettingsWithData: settings];
        }
        else{
            NSLog(@"set paymentsInfo def");
        }
        
        NSLog(@"datas: %@", datas);
        self.name = [datas objectForKey:@"name"];
        self.price_text = [datas objectForKey:@"price_text"];
        self.pages = [datas objectForKey:@"pages"];
        self.pagesPrevs = [[NSMutableArray alloc] init];
        for (int i=1; i<=[self.pages count]; i++ ) {
            [self.pagesPrevs addObject:[NSString stringWithFormat:@"thumb_%d_%d.jpg", ishue_id, i ] ];
        }
        appid = (int)[[datas objectForKey:@"app_id"] integerValue];
        
        cdate = [datas objectForKey:@"cdate"];
        pagesNum = (int)[self.pages count];
        parent_folder = [[datas objectForKey:@"p_folder"] intValue];
        is_folder = [[datas objectForKey:@"is_folder"] intValue];
        type = [[datas objectForKey:@"type"] intValue];
        self.buttonsForCurrentIshue = [datas objectForKey:@"actions"];
        [self setPhotos];
        
        [self loadAllIssueFiles];
    }
    return self;
}

-(void) setPhotos{
    self.photosForGaleries = [[NSMutableArray alloc] init];
    for (NSDictionary* action in self.buttonsForCurrentIshue ) {
        if ( [[action objectForKey:@"action_tid"] intValue] == 2 ){
            NSDictionary* galleryExtras = [action objectForKey:@"extras"];
            NSDictionary* photos = [galleryExtras objectForKey:@"photos"];
            for (NSDictionary* photo in photos) {
                GalleryPhoto* gp = [[GalleryPhoto alloc] initWithDBDatas:photo];
                [self.photosForGaleries addObject:gp];
            }
        }
    }

}


-(NSMutableArray*) getPhotosForGallery:(int)gallery_id{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    for (GalleryPhoto* gp in self.photosForGaleries) {
        if( gp.gallery_id == gallery_id ){
            [ret addObject:gp];
        }
    }
    return ret;
}


-(void)reloadBasicInfo{
//    self.pages = [self.DBC getPagesForIshue:ishue_id];
}

-(NSString*)getLocalPathToPageCover{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"thumb_%d_%d.jpg", ishue_id, 1 ]];
    return fullFilePath;
}

-(int)getPageNumberBasedOnId: (int)pageId{
    int num = 1;
    for (NSDictionary* string in self.pages) {
        int pid = [[string objectForKey:@"id"] intValue];
        if ( pid == pageId ){
            return num;
        }
        num++;
        
    }
    return -1;
}

-(NSString*)getUrlToPageCover{
    NSString* link =
    [NSString stringWithFormat:
     @"%@/Resources/pages/%d/PREVIEWS/thumb_%d_%d.jpg", STAGING_URL_NOINDEX,ishue_id,ishue_id, 1];
    return link;
}


-(UIImage*)getImagePageCoverFromUrl{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self getUrlToPageCover]]]];
}

-(void)reloadPagesInfo{
    self.pages = [self.DBC getPagesForIshue:ishue_id];
    NSLog(@"ishue id: %d pages: %@", ishue_id, self.pages );
}

-(void)reloadButtonsInfo{
    self.buttonsForCurrentIshue = [self.DBC getButtonsForIshue:ishue_id];
}

-(NSString*)pathToPdfPageFile: (int)pageid{
    NSString *filePathPDF = [[NHelper pathToDocumentsDict] stringByAppendingPathComponent:[NSString stringWithFormat:@"page_%d_%d.pdf",ishue_id ,pageid]];
    return filePathPDF;
}
-(NSString*)pathToJPGPageFile: (int)pageid{
    NSString *filePath = [[NHelper pathToDocumentsDict] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%d.jpg",ishue_id ,pageid]];
    return filePath;
}



-(NSMutableArray*) getButtonsForPage: (int)page_id{

    NSMutableArray* buttonsForThisPage = [[NSMutableArray alloc] init];
    for (NSDictionary* action in self.buttonsForCurrentIshue) {
        if ( [[action objectForKey:@"page_id"] intValue] == page_id ){
            [buttonsForThisPage addObject:action];
        }
    }
    return buttonsForThisPage;
}

-(NSDictionary*) getPageInfoById: (int)page_id{
    
    for (NSDictionary* page in self.pages) {
        if ( [[page objectForKey:@"id"] intValue] == page_id ){
            return page;
        }
    }
    return nil;
}

-(NSDictionary*) getButton: (int)buttonid{
//    NSMutableArray* buttonsForThisPage = [[NSMutableArray alloc] init];
    for (NSDictionary* action in self.buttonsForCurrentIshue) {
        if ( [[action objectForKey:@"action_id"] intValue] == buttonid ){
            return action;
        }
    }
    return nil;
}


-(bool)fileExistForIssue: (NSString*)resourceLink{
    NSString* fileVideo = [NHelper pathToVideoFile:resourceLink];
    return [[NSFileManager defaultManager] fileExistsAtPath:fileVideo];
}

-(NSMutableArray*)newVideoFilesForIssue{
    NSMutableArray* videoFiles = [[NSMutableArray alloc] init];
    
    NSDictionary* buttonsForIss = self.buttonsForCurrentIshue;
    if ( [buttonsForIss count] > 0 ){
        for (NSDictionary* button in buttonsForIss) {
            if ( [[button objectForKey:@"action_tid"] integerValue] == 4 ){
                NSLog(@"button: %@", [button objectForKey:@"full_link"]);
                
                NSString* movLink = @"Resources/video/";
                if ( [button objectForKey:@"full_link"] != [NSNull null] && [button objectForKey:@"full_link"] != nil  ){
                    if ( [[button objectForKey:@"full_link"] rangeOfString:movLink].location != NSNotFound ){
                        
                        if ( [button objectForKey:@"full_link"] != [NSNull null] ){
                            if ( ![self fileExistForIssue:[button objectForKey:@"full_link"]] ){
                                [videoFiles addObject:
                                 [NSString stringWithFormat:@"%@/%@",STAGING_URL_NOINDEX,[button objectForKey:@"full_link"]]];
                            }
                        }
                    }
                    else{
                        NSLog(@"string DON !contains Res/video");
                        
                    }
                }
                else{
                    NSLog(@"DUPA");
                }
                
            }
        }
    }
    return videoFiles;
}


-(NSMutableArray*)newAudioFilesForIssue{
    NSMutableArray* audioFiles = [[NSMutableArray alloc] init];
    
    NSDictionary* buttonsForIss = self.buttonsForCurrentIshue;
    if ( [buttonsForIss count] > 0 ){
        for (NSDictionary* button in buttonsForIss) {
            if ( [[button objectForKey:@"action_tid"] integerValue] == 1 ){
                if ( [button objectForKey:@"full_link"] != [NSNull null] ){
                    if ( ![self fileExistForIssue:[button objectForKey:@"full_link"]]){
                        [audioFiles addObject:[button objectForKey:@"full_link"]];
                    }
                }
            }
        }
    }
    
    return audioFiles;
    
}


-(NSMutableArray*)newGaleriesFilesForIssue  :(BOOL)forcecheck{
    NSMutableArray* galleriesFiles = [[NSMutableArray alloc] init];
    NSMutableArray* photos = self.photosForGaleries;
    
    for (GalleryPhoto* gp in photos) {
        if ( forcecheck ){
            [gp checkagain];
        }
        if ( !gp.fileexist ){
            
            
            [galleriesFiles addObject:gp.link];
        }
    }
    
    return galleriesFiles;
}


-(BOOL)checkIssheAlreadyBought{
    NSString* stringtofind = [NSString stringWithFormat:@"com.setupo.issue%d", ishue_id ];
    BOOL alreadyBought = [IAPHelper wasBought:stringtofind];
    NSLog(@"alreadyBought: %d", alreadyBought);
    return alreadyBought;
}


@end
