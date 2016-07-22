//  AppDelegate.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 11.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.

#import <UIKit/UIKit.h>
#import "MobileUser.h"
#import "CoreLocationController.h"
#import "Catalog.h"
#import "ViewController.h"
#import "RootViewControllerL1a.h"
#import "BookMarksVC.h"
#import "LoadViewController.h"
#import "Ishue.h"
#import "BookMark.h"
#import <CoreData/CoreData.h>
#import <StoreKit/StoreKit.h>
#import "RageIAPHelper.h"

//#import "SampleGLResourceHandler.h"

#define appStageKiosk 1
#define appStageUlubione 2
#define appStageBookmarks 3
#define appStagePreview 4
#define appStageKatalog 5
#define appStageLoading 6


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



@interface AppDelegate : UIResponder <UIApplicationDelegate,CoreLocationControllerDelegate, SKProductsRequestDelegate>{
    @public
    int app_id;
    NSArray* app_subs;
    bool orientPion;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString *curentlyProcesssingProductIdentifier;
    BOOL animallowed;
    int arlaunchedinposition;
    int pageNumberIndex;
    bool blockThumbs;
    ViewController *viewController;
    @public
    UIPageControl *pageControl;
    UIImageView* uiva;
    UIActivityIndicatorView* uaivc;
    bool alldone;
    bool arlaunhcing;
    
}



@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) MobileUser *mobileuser;
@property (retain, nonatomic) CoreLocationController *CLController;
@property (retain, nonatomic) ViewController *viewController;
@property (retain, nonatomic) RootViewControllerL1a *rootViewController;
@property (retain, nonatomic) LoadViewController *loadViewController;
@property (retain, nonatomic) BookMarksVC *bmViewController;
@property (strong, nonatomic) NSDictionary* appSettingFromNet;
@property BOOL bookmarksActive;
@property BOOL bookmarksActivePro;
@property int currentlyTargetedMarkerId;
@property (strong, nonatomic) UINavigationController *nc;
@property BOOL navShow;
@property BOOL allowAllOrients, loadingInProgress, offlineMode;

//@property (nonatomic, weak) id<SampleGLResourceHandler> glResourceHandler;

@property (strong, nonatomic) NSMutableArray* ishuesForThisFolder;

@property BOOL tutorialHided, extraAkcjaBlokujacaRotate, reloadViewAfterReturn, firstPage;
@property int appStage;
@property (strong, nonatomic) UIColor *presetColorFiolet;
@property (strong, nonatomic) UIColor *presetColorSzary;
@property (strong, nonatomic) UIColor *presetBackgroundColor;

@property (strong, nonatomic) NSString* currentLeftPageNameFile;
@property (strong, nonatomic) NSString* currentRightPageNameFile;
@property (strong, nonatomic) SKProductsRequest* products;

@property (strong, nonatomic) Ishue* currentIshue;
@property (strong, nonatomic) NSMutableArray* ishuesColection;
@property (strong, nonatomic) NSMutableArray* favIshuesColection;
@property (strong, nonatomic) NSMutableArray* bookmarksColection;
@property (strong, nonatomic) DBController* DBC;
@property (strong, nonatomic) NSMutableArray* alreadyBought;


@property(nonatomic, strong) UIImage   *currentGalleryImage;




@property (strong, nonatomic) UIPageViewController *pageViewController;

//test
@property(nonatomic, strong) UIView   *xxxSlideUpView; // Contains thumbScrollView and a label giving credit for the images.
@property bool thumbBlocked, pageCurlAnimationInProgress, playMovie;
@property int forcePageNum;

@property (strong, nonatomic) UIButton* bTopShare;
@property (strong, nonatomic) UIButton* bTopBookMark;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
-(NSMutableArray*) getCollectionOfIssuesForFolderId:(int)folder_id;

-(NSString*)getMuId;
//-(void)hideThumbView;
-(void)enableThumbViewShow;
-(void)setMuId: (NSNumber*)mu_id;
-(void)disableThumbViewShow:(BOOL)bval czas:(int)czas;
-(void)addToFav:(int)ishue_id;
-(void)removeFromFav:(int)ishue_id;
-(void)getFromFav;
+(void) LogIt:(NSString*)msg;
-(BOOL)checkBookmarkExist: (int)bookmark_id;

-(BOOL)isFav:(int)ishue_id;
//CATALOG TU
-(void)fixNav;
-(void)reloadBookmarks;
-(void)setupBookmarkButton: (BOOL)addBook pageid:(int)pageid;
-(void)setController:(ViewController*)vc;

-(void)setNav:(UINavigationController*)nc;

-(void)setBackButtonImage;

+(void)showRectParams: (CGRect)rect label:(NSString *)label;
+(void)showSizeParams: (CGSize)rect label:(NSString *)label;

-(void)reSetup;

-(void) setupIshuesCollection;

+(BOOL)isIphone;
+(void)borderView: (UIView*)xview color:(UIColor*)color width:(float)width;


-(void)showNavig;
-(void)hideNavig;

-(void)showNavigNoAnim;
-(void)hideNavigNoAnim;


-(void)createLoginFadeBackground;
-(void)hideFadeAnim:(float)duration delay:(float)delay;


@end
