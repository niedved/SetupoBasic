//
//  ViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 11.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "AFHTTPRequestMaker.h"
#import "PreviewHelper.h"
#import "NHelper.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "RootViewControllerL1a.h"
#import "MNCollectionViewController.h"
#import "MNPhotoAlbumLayout.h"
#import "MNAlbumPhotoCell.h"
#import "GalleryPageViewController.h"

#import "BHAlbum.h"
#import "BHPhoto.h"
#import "MNAlbumTitleReusableView.h"
#import <CoreData/CoreData.h>
#import "TuiCatalogGalleryController.h"
#import "TutorialViewController.h"
#import "STabBarControler.h"
#import "BookMarksVC.h"
#import "KioskHelper.h"
#import "TKioskHelper.h"
#import "RageIAPHelper.h"


#import "IssuesManager.h"



static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@interface ViewController (){
    AppDelegate* appDelegate;
    
    @public
    RootViewControllerL1a* destViewController;
    BOOL viewDidApearBool;
    
}

@property (nonatomic, strong) TuiCatalogGalleryController* TUIVC;
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) MNCollectionViewController* mnCollectionViewController;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;
@end

@implementation ViewController

@synthesize mnCollectionViewController,TUIVC;

-(void)tapDetected{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    appDelegate.appStage = 1;
    
    viewDidApearBool = YES;
    
    if( [NHelper isIphone]){
        [self handleOrientationIphone:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    else{
        [self handleOrientationIpad:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    
    viewDidApearBool = NO;
    [appDelegate setBackButtonImage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}
- (BOOL)shouldAutorotate{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (IBAction)buyButtonTapped:(id)sender {
    
}

-(void) refreshPreview{
   if ( TUIVC != [NSNull null] && TUIVC != nil  ){
       
       [self hideIshueActionView];
       [self showIshueActionView: appDelegate.currentIshue];
   }
}

- (void)buyProductIdentifier:(NSString *)productIdentifier
{
    SKMutablePayment *payment = [[SKMutablePayment alloc] init] ;
    payment.productIdentifier = productIdentifier;
    appDelegate->curentlyProcesssingProductIdentifier = productIdentifier;
    NSLog(@"buyProductIdentifier");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
//    NSString * productIdentifier = notification.object;
    NSLog(@"productPurchased: %@ %d", TUIVC, TUIVC.view.hidden );
    
    if ( TUIVC != [NSNull null] && TUIVC != nil  ){
        
        [self hideIshueActionView];
        [self showIshueActionView: appDelegate.currentIshue];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
//    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)test{
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            
        }
    }];
}

- (void)reload {
    _products = nil;
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray  *products) {
        if (success) {
            _products = products;
//            NSLog(@"prodddd: %@", _products );
        }
        [self.refreshControl endRefreshing];
    }];
}


- (IBAction)onStartButton:(id)sender
{
    [self performSegueWithIdentifier:@"StartItSegue" sender:self];
}


-(void)setCurrentIssueAsLastIssue{
    Ishue* lastIssue = [appDelegate.ishuesColection firstObject];
    [[IssuesManager sharedInstance] setCurrentIssue:lastIssue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [KioskHelper setTopBarLogo:self];
    self._hudView.hidden = NO;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    DBC = [[DBController alloc] init];
    [self kolekcjaLoad];
    
    
    [appDelegate setViewController:self];
    appDelegate.appStage = 1;
    [KioskHelper setColorsFromPlist:self];
    
    NSLog(@"[NHelper kioskbg: %@", [[NHelper appSettings] objectForKey:@"kioskbg"] );
    [self.kioskLargeView setBackgroundColor:[NHelper colorFromPlist:@"kioskbg"]];
    
    [self.view setBackgroundColor:[NHelper colorFromPlist:@"kioskbg"]];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [appDelegate setViewController:self];
    
    self._hudView.hidden = YES;
    curent_folder_id = 0;
    
    [TKioskHelper setColoredImages:self];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    
    [[IssuesManager sharedInstance] checkOnlineAndIfYesSendLogs];
    
}

-(void)destViewControllerDupa: (int)page{
    if ( appDelegate->orientPion ){
        page = page;
    }
    else{
        page = page*2;
    }
}

-(void)ogarnijTutorial{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* tutorialblocked = [prefs stringForKey:@"tutorialblocked"];
    if ( [tutorialblocked isEqualToString:@"YES"] ){
    }
    else{
        TutorialViewController *modalViewController =
        [[TutorialViewController alloc] initWithNibName:@"Tutorial" bundle:nil];
        
        modalViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;

        [self presentViewController:modalViewController animated:YES completion:nil];
    }
}

-(IBAction)selectedLargeKiosk:(id)sender{
    [self showIshueActionView: [IssuesManager sharedInstance].currentIssue ];
}

-(void)setKioskLargeOffline{
    for (UIView* X in [self.kioskLargeView subviews]) {
        [X setHidden:YES];
    }
    
    [self.banner setHidden:YES];
    [self.pionLineKiosk setHidden:YES];
    
    oflineimageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 216, 285)];
    [oflineimageview setImage:[UIImage imageNamed:@"loading960_offline.png"]];
    [self.view addSubview:oflineimageview];
    [self.view bringSubviewToFront:oflineimageview];
    oflineimageview.center = self.view.center;
}

-(void)kolekcjaLoad{
    [self prepareKolekcjaIshuesView];
    [self preapreThumbsButtons: false boughtOnly:NO];
    
    [self setCurrentIssueAsLastIssue];
    
    if( appDelegate.offlineMode &&  [appDelegate.ishuesColection count] == 0 ){
        if( [NHelper isIphone]){
            [KioskHelper setKioskLargeOfflineIphone:self];
        }
        else{
            [self setKioskLargeOffline];
        }
    }
    else{
        [KioskHelper setKioskLarge:self];
    }
}

- (IBAction)folderLevelBackButtonAction:(id)sender{
    NSLog(@"clicked folderLevelBackButtonAction");
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (IBAction)segmentAction:(id)sender{
    UISegmentedControl* seg = (UISegmentedControl*)sender;
    NSLog(@"seg: %ld", (long)seg.selectedSegmentIndex );
    if ( seg.selectedSegmentIndex == 0 ){
        [self preapreThumbsButtons: false boughtOnly:NO];
    }
    else if( seg.selectedSegmentIndex == 1 ){
        [self preapreThumbsButtons: YES boughtOnly:NO];
    }
    else{
        [self preapreThumbsButtons: NO boughtOnly:YES];
    }
    
    [self.mnCollectionViewController.collectionView reloadData];
    
}

// Add this method
- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) prepareKolekcjaIshuesView{
    NSLog(@"prepareKolekcjaIshuesView");
    [mnCollectionViewController.view removeFromSuperview];
    mnCollectionViewController =
    [[MNCollectionViewController alloc] initWithNibName:@"MNCollectionViewController" bundle:nil];
    mnCollectionViewController.collectionView.dataSource = self;
    mnCollectionViewController.collectionView.delegate = self;
    [mnCollectionViewController.collectionView setDataSource:self];
    [mnCollectionViewController.collectionView setDelegate:self];
    
    
    if([NHelper isIphone]){
        if(  [NHelper isLandscapeInReal] ){
            CGSize size = [NHelper getSizeOfCurrentDeviceLandscape];
            self.viewForCollectionWidth.constant = size.width / 4;
        }
        else{
            CGSize size = [NHelper getSizeOfCurrentDevicePortrait];
            self.viewForCollectionWidth.constant = size.width;
        }
    }
    
    [viewForCollection addSubview:mnCollectionViewController.view]; //podejrzane ze wiele kioskwo na raz sei
}

-(void)reloadThumbs: (BOOL)fav{
    UISegmentedControl* seg = self.segmentedControl;
    NSLog(@"seg: %ld", (long)seg.selectedSegmentIndex );
    if ( seg.selectedSegmentIndex == 0 ){
        [self preapreThumbsButtons: false boughtOnly:NO];
    }
    else if( seg.selectedSegmentIndex == 1 ){
        [self preapreThumbsButtons: YES boughtOnly:NO];
    }
    else{
        [self preapreThumbsButtons: NO boughtOnly:YES];
    }
    [self.mnCollectionViewController.collectionView reloadData];
    NSLog(@"reloadThumbs");
}


-(void)preapreThumbsButtons:(BOOL)favOnly boughtOnly:(BOOL)boughtOnly{
    self.albums = [NSMutableArray array];
    if( favOnly ){//reload
        [appDelegate getFromFav];
    }
    
    NSInteger photoIndex = 0;
    
    for (Ishue* ishue in appDelegate.ishuesColection ) {
        if( favOnly ){
            BOOL isFav = NO;
            for (NSNumber* favid in appDelegate.favIshuesColection) {
                NSLog(@"favs: %@", favid);
                if ( ishue->ishue_id == [favid integerValue] ){
                    isFav = YES;
                    break; //break for ;]
                }
            }
            if ( !isFav ){
                continue;
            }
        }
        
        if( boughtOnly ){
            NSLog(@"boughtOnly: %d =>%d", ishue->ishue_id, [ishue checkIssheAlreadyBought]);
            
            if( ![ishue checkIssheAlreadyBought] ){
                    //check active subscription
                if( ![PreviewHelper czyMaszSubskrypcjeObejmujacaWydanie:ishue] ){
                    continue;
                }
            }
            
        }
        
        if ( ishue->parent_folder != curent_folder_id ){ //szukany parrent_id
            continue;
        }
        
        BHAlbum *album = [[BHAlbum alloc] init];
        album.name = ishue.name;
        album.issue = ishue;
        UIImage* imageForCover = nil;
        NSString *fullFilePath = [ishue getLocalPathToPageCover];
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath];
        if ( fileExist ){
            imageForCover = [UIImage imageWithContentsOfFile:fullFilePath];
        }
        else{
            imageForCover = [ishue getImagePageCoverFromUrl];
            NSLog(@"notexist");
            [UIImageJPEGRepresentation(imageForCover, 1.0) writeToFile:fullFilePath atomically:YES];
            if( [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath] ){
                NSURL* url = [NSURL fileURLWithPath: fullFilePath ];
                [NHelper addSkipBackupAttributeToItemAtURL:url];
            }
        }
        
        [album addPhoto2:[[UIImageView alloc] initWithImage:imageForCover]];
        photoIndex++;
        
        [self.albums addObject:album];
    }
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
}



-(void)setModal{
    self.modalView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.modalView.backgroundColor = [[NHelper colorFromPlist:@"previewmodalview"] colorWithAlphaComponent:0.90f];
//    CGRect sr = [[UIScreen mainScreen] bounds];
    self.modalView.frame = CGRectMake(0, 0, 1024, 1024);
    [self.view addSubview:self.modalView];
    [self.view bringSubviewToFront:self.modalView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleModalTap:)];
    tap.delegate = self;
    [self.modalView addGestureRecognizer:tap];
    
}


-(void) handleModalTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self hideIshueActionView];
}

-(void)hideIshueActionView{
    
    appDelegate.appStage = 1;
    [TUIVC.view removeFromSuperview];
    TUIVC = nil;
    [self.modalView removeFromSuperview];
}


// METODA ODPALANA KLIKNIECIEM ISHUE
-(void)showIshueActionView: (Ishue*)clickedIssue{
    self._hudView.hidden = NO;
    appDelegate.currentIshue = clickedIssue;
    appDelegate.appStage = 2;
    
    
    [self setModal];
    
    if ( [NHelper isIphone]){
        TUIVC = [[TuiCatalogGalleryController alloc] initWithNibName:@"PreviewIphone" bundle:nil];
        int widthTUIVC = 300;
        int heightTUIVC = 225;
        TUIVC.view.frame = CGRectMake(0, 0, widthTUIVC, heightTUIVC);
    }
    else{
        TUIVC = [[TuiCatalogGalleryController alloc] initWithNibName:@"TUITest" bundle:nil];
        int widthTUIVC = 520;
        int heightTUIVC = 420;
        TUIVC.view.frame = CGRectMake(0, 0, widthTUIVC, heightTUIVC);
    }
    
    TUIVC->vvcc = self;
    
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    TUIVC.view.center = CGPointMake(size.width/2, size.height/2);
    
    [self.view addSubview:TUIVC.view];
    [self showCatalogGallery: appDelegate.currentIshue ];
    
    self._hudView.hidden = YES;
}

- (void)showCatalogGallery: (Ishue*)ishue{
    TUIVC->current_catalog = [[Catalog alloc] initWithIshueDatas:ishue];
    TUIVC->filesToDownload = [[NSMutableArray alloc] init];
//    @TODO MARCIN
    [TUIVC changePage:2];
    [self.TUIVC sprawdzCzyPobranoPlusMinus:3];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate->orientPion = YES;
    
    
    [TKioskHelper setColoredImages:self];
    
    if( destViewController  == [NSNull null] || destViewController == nil ){
        NSLog(@"NULL");
    }
    else{
        NSLog(@"CZYSCIMY");
        [destViewController removeFromParentViewController];
        [destViewController.view removeFromSuperview];
        destViewController = nil;
        NSLog(@"viewWillAppear:destViewController:  %@", destViewController);
    }
    
    if( appDelegate.rootViewController  == [NSNull null] || appDelegate.rootViewController == nil ){
        NSLog(@"NULL");
    }
    else{
        NSLog(@"CZYSCIMY");
        [appDelegate.rootViewController removeFromParentViewController];
        [appDelegate.rootViewController.view removeFromSuperview];
        appDelegate.rootViewController = nil;
        NSLog(@"viewWillAppear:appDelegate.rootViewController:  %@", appDelegate.rootViewController);
    }
    
    if( appDelegate.loadViewController  == [NSNull null] || appDelegate.loadViewController == nil ){
        NSLog(@"NULL");
    }
    else{
        NSLog(@"CZYSCIMY");
        [appDelegate.loadViewController removeFromParentViewController];
        [appDelegate.loadViewController.view removeFromSuperview];
        appDelegate.loadViewController = nil;
        NSLog(@"viewWillAppear:appDelegate.rootViewController:  %@", appDelegate.loadViewController);
    }
    
    
//    if ( !appDelegate.tutorialHided )
//        [self ogarnijTutorial];
//    
    if( appDelegate.bookmarksActive && appDelegate.bookmarksActivePro ){
        [self.view setHidden:YES];
        [appDelegate createLoginFadeBackground];
    }
    else{
    
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        if( [NHelper isIphone]){
            [self handleOrientationIphone:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        else{
            [self handleOrientationIpad:[[UIApplication sharedApplication] statusBarOrientation]];
        }

        appDelegate.appStage = 1;
        appDelegate.allowAllOrients = YES;
        
        STabBarControler* sttab = (STabBarControler*)appDelegate.viewController.tabBarController;
        [sttab hideIt];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        
        if( [NHelper isIphone]){
            [self handleOrientationIphone:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        else{
            [self handleOrientationIpad:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        
        
    }
}



-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    NSLog(@"viewWillTransitionToSize VC: %f,%f", size.width, size.height );
    
    if( [NHelper isIphone])
        [self handleOrientationIphone:[[UIApplication sharedApplication] statusBarOrientation]];
    else
        [self handleOrientationIpad:[[UIApplication sharedApplication] statusBarOrientation]];
    
    TUIVC.view.center = CGPointMake(size.width/2, size.height/2);
}


- (void)orientationChanged:(NSNotification *)notification{
    if( [NHelper isIphone]){
        [self handleOrientationIphone:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    else{
        NSLog(@"orientland?: %d orientpion:%d", [NHelper isLandscapeInReal], appDelegate->orientPion );
        if( [NHelper isLandscapeInReal] && appDelegate->orientPion  ){
            [self handleOrientationIpad:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        if( ![NHelper isLandscapeInReal] && !appDelegate->orientPion ){
            [self handleOrientationIpad:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        
    }
}

-(void) setPreviewViewInfoIphonePortrait{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    TUIVC.view.center = CGPointMake(size.width/2, size.height/2);
}

- (void) handleOrientationIphone:(UIInterfaceOrientation) orientation {
    NSLog(@"handleOrientationIphone");
    if( [NHelper isLandscapeInReal]){
        appDelegate->orientPion = NO;
        [TKioskHelper setTopBarViewInfoIphoneLand:self];
        [self.kioskLargeView setHidden:NO];
        [self.bottomViewBar setHidden:YES];
        [self prepareKolekcjaIshuesView];
        
        CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
        self.TUIVC.view.center = CGPointMake(size.width/2, size.height/2);
        if( appDelegate.offlineMode &&  [appDelegate.ishuesColection count] == 0 ){
            [KioskHelper setKioskLargeOfflineIphone:self];
        }
    }
    else{
        appDelegate->orientPion = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [TKioskHelper setTopBarViewInfoIphonePortrait: self];
        });
        [KioskHelper setCollectionViewInfoIphonePortrait: self];
        [self setPreviewViewInfoIphonePortrait];
        if( appDelegate.offlineMode &&  [appDelegate.ishuesColection count] == 0 ){
            [KioskHelper setKioskLargeOfflineIphone:self];
        }
    }
}

- (void) handleOrientationIpad:(UIInterfaceOrientation) orientation {
    if( [NHelper isLandscapeInReal]){
        appDelegate->orientPion = NO;
        [TKioskHelper setTopBarViewInfoIpadLand:self];
        [KioskHelper setCollectionViewInfoIpadLandscape:self];
        [self setPreviewViewInfoIpadLandscape];
    }
    else{
        appDelegate->orientPion = YES;
        [TKioskHelper setTopBarViewInfoIpadPortrait:self];
        [KioskHelper setCollectionViewInfoIpadPortrait:self];
        [self setPreviewViewInfoIpadPortrait];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [KioskHelper preapreBannerButton:self];
    });
    CGSize s = [NHelper getSizeOfCurrentDeviceOrient];
    oflineimageview.center = CGPointMake(s.width/2, s.height/2);
}

-(void) setPreviewViewInfoIpadPortrait{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    TUIVC.view.center = CGPointMake(size.width/2, size.height/2);
}

-(void) setPreviewViewInfoIpadLandscape{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    TUIVC.view.center = CGPointMake(size.width/2, size.height/2);
    
}

-(IBAction)bannerClicked:(UIButton*)button{
    NSString* link = [NSString stringWithFormat:@"http://setupo.com/baners/redirect.php?appid=%d", appDelegate->app_id];
    NSLog(@"link: %@", link );
    NSURL *URL = [NSURL URLWithString:link];
    
    DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:URL];
    webBrowser.showProgress = YES;
    webBrowser.allowSharing = YES;
    
    UINavigationController *webBrowserNC = [[UINavigationController alloc] initWithRootViewController:webBrowser];
    [self presentViewController:webBrowserNC animated:YES completion:NULL];
}


/************************************
* COLECTION DATAS INFOS ETC - START *
************************************/
-(Ishue*)getIssueBasedOnPositionInList:(NSIndexPath *)indexPath{
    NSLog(@"getIssueBasedOnPositionInList: selected:%ld", (long)indexPath.section);
    //check type of clicked isshue
    NSMutableArray* ishuesForThisFolder = [appDelegate getCollectionOfIssuesForFolderId: curent_folder_id];
    
    long pozycja_kliknietego_issue_tablica = indexPath.section;
    
    UISegmentedControl* seg = self.segmentedControl;
    Ishue* clickedI;
    
    if ( seg.selectedSegmentIndex == 0 ){
        clickedI = [ishuesForThisFolder objectAtIndex:pozycja_kliknietego_issue_tablica];
    }
    else if ( seg.selectedSegmentIndex == 1 ){
        BHAlbum* bhalbum = (BHAlbum*)[self.albums objectAtIndex:pozycja_kliknietego_issue_tablica];
        clickedI = bhalbum.issue;
        
    }
    else if ( seg.selectedSegmentIndex == 2 ){
        BHAlbum* bhalbum = (BHAlbum*)[self.albums objectAtIndex:pozycja_kliknietego_issue_tablica];
        clickedI = bhalbum.issue;
        
    }
    else{
        NSNumber* clickedid = [appDelegate.favIshuesColection  objectAtIndex:pozycja_kliknietego_issue_tablica];
        for (Ishue* ishue in appDelegate.ishuesColection ) {
            if ( ishue->ishue_id == [clickedid integerValue] ){
                clickedI = ishue;
                break; //break for ;]
            }
        }
    }
    NSLog(@"getIssueBasedOnPositionInList return: %@ %d", clickedI, clickedI->ishue_id );
    return clickedI;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [[IssuesManager sharedInstance] setCurrentIssue: [self getIssueBasedOnPositionInList:indexPath]];
    if( [NHelper isIphone] && ![NHelper isLandscapeInReal] ){
        [self showIshueActionView: [self getIssueBasedOnPositionInList:indexPath] ];
    }
    else{
        [KioskHelper setKioskLarge:self];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath  *)indexPath{
//    NSLog(@"deselected:%ld", (long)indexPath.section);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return self.albums.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    BHAlbum *album = self.albums[section];
    return album.photos.count;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    MNAlbumTitleReusableView *titleView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:AlbumTitleIdentifier
                                              forIndexPath:indexPath];
    
    long section = indexPath.section;
    BHAlbum *album = self.albums[section];
    
    titleView.titleLabel.text = [album.name uppercaseString];
    if( [NHelper isIphone]){
        titleView.titleLabel.font = [UIFont systemFontOfSize:8.0f];
    }
    [titleView.titleLabel setTextAlignment:NSTextAlignmentCenter];
    return titleView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"CELL: %d,%d", indexPath.section, indexPath.row );
    MNAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
    
    long section = indexPath.section;
    
    BHAlbum *album = self.albums[section];
    BHPhoto *photo = album.photos[indexPath.item];
    
    UIImage *image = [photo image];
    photoCell.imageView.image = image;

    Ishue* presendedIssue = [self getIssueBasedOnPositionInList:indexPath];
    if ([presendedIssue.filesToDownload count] == 0 ) {
        [photoCell.labelViewOtworz setHidden:YES];
    }
    else{
        [photoCell.labelViewOtworz setHidden:NO];
    }
    
    return photoCell;
}

- (void) ishueButtonClicked {
    [self hideIshueActionView];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
 
    if( appDelegate.forcePageNum > 0 ){
        [appDelegate.bmViewController dismissViewControllerAnimated:NO completion:nil];
        appDelegate.bookmarksActive = YES;
    }
    else{
        appDelegate.bookmarksActive = NO;
    }
    
    [self performSegueWithIdentifier:@"segueShowIshue" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueShowIshue"]) {
        UIButton* button = (UIButton*)sender;
        [[IssuesManager sharedInstance] logIssueOpened];
        destViewController = segue.destinationViewController;
        
        //posuzkaj kliknietego ishue
        NSDictionary* passingData = nil;
        for (NSDictionary* ishue_params in ishues) {
            if( [[ishue_params objectForKey:@"id"] integerValue] == button.tag ){
                passingData = [ishue_params copy];
                break;
            }
        }
        destViewController.ishue_params = passingData;
    }
    else if( [segue.identifier isEqualToString:@"showBookmarksSegue"]){
        NSLog(@"bvc");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    NSLog(@"Product : %@", products);
    if (products.count != 0)
    {
    } else {
//        _productTitle.text = @"Product not found";
    }
    
    products = response.invalidProductIdentifiers;
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}

@end
