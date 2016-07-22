//
//  Ishue.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 15.02.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"
#import "GalleryPhoto.h"

@interface Ishue : NSObject{
    

    @public
    int ishue_id;
    int pagesNum;
    
    UIColor *bg;
    int swipe_type;
    int orientation;
    bool forceOnePagePerView;
    float pagesizeup;
    float pagesizex;
    int price;
    NSString* video_rgb;
    NSString* audio_rgb;
    NSString* link_rgb;
    NSString* gallery_rgb;
    
    bool is_folder;
    int parent_folder;
    int type;
    NSString* cdate;
    
    int appid;
}

@property (strong, nonatomic) NSMutableDictionary *payments;

@property (strong, nonatomic) NSString* coverThumbUrl;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* price_text;
@property (strong, nonatomic) NSDictionary *buttonsForCurrentIshue;
@property (strong, nonatomic) NSMutableArray *photosForGaleries;
//@property (strong, nonatomic) NSDictionary *actions;
@property (strong, nonatomic) NSDictionary *pages;
@property (strong, nonatomic) NSMutableArray *pagesPrevs;
@property (strong, nonatomic) NSMutableArray *parButtons;

@property (strong, nonatomic) NSMutableDictionary *iconSettings;
@property (strong, nonatomic) NSMutableDictionary *issueTopics;

@property (strong, nonatomic) NSMutableArray* filesForIssue;
@property (strong, nonatomic) NSMutableArray* filesForThumbs;
@property (strong, nonatomic) NSMutableArray* filesAlreadyDownloaded;
@property (strong, nonatomic) NSMutableArray* filesToDownload;
@property (strong, nonatomic) NSMutableArray* extraPDFFiles;


@property (nonatomic,retain) DBController *DBC;

@property int currentPageId;
@property int par_tdid;

@property (strong, nonatomic) UIImage* curentImage;
@property (strong, nonatomic) UIImage* curentImageR;


@property UIPageViewControllerTransitionStyle transStyle;


-(float)getSizeOffAllDownlaodedFiles;
-(void)removeAllIssueFilesFromDevice;
-(void)loadAllIssueFiles;
-(void)reloadBasicInfo;
-(void)reloadButtonsInfo;
-(void)reloadPagesInfo;
- (id)initWithId:(int)ishue_id;
-(void) setPhotos;


-(NSString*)pathToPdfPageFile: (int)pageid;
-(NSString*)pathToJPGPageFile: (int)pageid;


-(NSString*)pathToIssuePagesFile;
-(BOOL)checkThumbsCorrectDownloaded;
-(BOOL)checkPdfCorrectSplited;
    
-(NSMutableArray*) getButtonsForPage: (int)page_id;

-(NSString*)getLocalPathToPageCover;

-(int)getPageNumberBasedOnId: (int)pageId;
-(UIImage*)getImagePageCoverFromUrl;
-(NSString*)getUrlToPageCover;
-(NSDictionary*) getPageInfoById: (int)page_id;
-(NSDictionary*) getButton: (int)buttonid;
-(NSMutableArray*) getPhotosForGallery:(int)gallery_id;

-(bool)fileExistForIssue: (NSString*)resourceLink;
-(NSMutableArray*)newVideoFilesForIssue;

-(NSMutableArray*)newAudioFilesForIssue;

-(NSMutableArray*)newGaleriesFilesForIssue :(BOOL)forcecheck;


-(BOOL)checkIssheAlreadyBought;
-(void)getParDatas;
- (id)initWithDBBAsicInfo:(NSDictionary*)datas;
@end
