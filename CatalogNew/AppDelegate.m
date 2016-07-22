//
//  AppDelegate.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 11.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "AppDelegate.h"
#import "LogsController.h"
#import "TuiCatalogGalleryController.h"
#import <NewsstandKit/NewsstandKit.h>
#import <StoreKit/StoreKit.h>
#import "VideoViewController.h"
#import <sys/sysctl.h>


#import "NHelper.h"
@implementation AppDelegate

//@synthesize CLController;


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


+(void) LogIt:(NSString*)msg{
    if ( NO ){
        NSLog( @"%@", msg );
    }
}


-(void) setupAppViewOnlineSettings{
    self.appSettingFromNet = [self.DBC getAppSetting:app_id];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    NSUInteger orientations = UIInterfaceOrientationMaskLandscape;
    
    UIViewController *currentViewController = [self topViewController];
    
    if ([currentViewController respondsToSelector:@selector(dontRotate)]) {
        if ( arlaunchedinposition == 1 )
            return UIInterfaceOrientationMaskLandscape;
        else{
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    
//    currentViewController
    if ([currentViewController respondsToSelector:@selector(canRotate)]) {
        return UIInterfaceOrientationMaskAll;
    }
    if ( self.allowAllOrients ){
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskAll;
    
    return orientations;
}


- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}



- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}



- (void)disableThumbViewShow:(BOOL)bval czas:(int)czas{
    self.thumbBlocked = bval;
    [self performSelector:@selector(enableThumbViewShow) withObject:nil afterDelay:czas];

}

-(void)enableThumbViewShow{
    self.thumbBlocked = NO;
}


//Explicitly write Core Data accessors
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"database.sqlite"]];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle error
    }
    
    return persistentStoreCoordinator;
}


- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}


- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


-(void)setController:(ViewController*)vc{
    self.viewController = vc;
}

-(void)checksharable{
    BOOL sharable = NO;
    if ( [[[NHelper appSettings] objectForKey:@"sharablebydb"] boolValue] ){
        
    
        for (NSDictionary* page in self.currentIshue.pages ) {
            if ( [[page objectForKey:@"id"] intValue] == [self.currentLeftPageNameFile intValue] ||
                [[page objectForKey:@"id"] intValue] == [self.currentRightPageNameFile intValue] ){
                NSLog(@"pagecurr: %@ %@", page, self.currentLeftPageNameFile );
                if ( [[page objectForKey:@"sharable"] boolValue] ){
                    sharable = YES;
                }
            }
            
        }
    }
    else{
        sharable = YES;
    }
    
    if( sharable ){
        [self.bTopShare setEnabled:YES];
    }
    else{
        [self.bTopShare setEnabled:NO];
    }
    
}

-(void)setNav:(UINavigationController*)nav{
    self.nc = nav;
    [self.nc.navigationBar setBarStyle:UIBarStyleDefault];
    [self.nc.navigationBar setTintColor:
     [UIColor colorWithRed:29.0f/255.0f green:29.0f/255.0f blue:29.0f/255.0f alpha:1.0]];
    [self.nc.navigationBar setAlpha:1.0f];
    self.nc.navigationBar.barTintColor = [UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
    
    
    
    [self.bTopShare removeFromSuperview];
    [self.bTopBookMark removeFromSuperview];
    self.bTopShare = [[UIButton alloc] initWithFrame:
                      CGRectMake(self.nc.navigationBar.frame.size.width/2 - 44-10 , 0, 44, 44)];
    [self.bTopShare setImage:[UIImage imageNamed:@"top_social.png"] forState:UIControlStateNormal];
    
    [self.bTopShare setImage:[NHelper imagedColorized:@"Share" withColor:[NHelper colorFromPlist:@"catalog_topbar_icon_color"]] forState:UIControlStateNormal];
    
    [self.nc.navigationBar addSubview:self.bTopShare];
    
    [self.bTopShare addTarget:self action:@selector(shareIt) forControlEvents:UIControlEventTouchUpInside];
    self.bTopBookMark = [[UIButton alloc] initWithFrame:
                         CGRectMake(self.nc.navigationBar.frame.size.width/2 +0+ 10, 0, 44, 44)];
    [self.bTopBookMark setImage:[UIImage imageNamed:@"bookmarks_plus"] forState:UIControlStateNormal];
    [self.nc.navigationBar addSubview:self.bTopBookMark];
    
    [self.bTopBookMark addTarget:self action:@selector(bookIt:) forControlEvents:UIControlEventTouchUpInside];
    [self setupBookmarkButton: NO pageid:0];
    
    
    //    self.nc.navigatio
    [self setBackButtonImage];
}

-(void)setBackButtonImage{
    
    UIImage* img = [NHelper imagedColorized:@"backbutton2" withColor:[UIColor greenColor]];
    [[UINavigationBar appearance] setBackIndicatorImage:img];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:img];
    
    
}


-(void)fixNavIphone{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    if( ![NHelper isLandscapeInReal] ){
        if ( self.appStage == 8 ){
            [self.bTopShare setFrame:CGRectMake( size.width/2 - 22, 0, 44, 44)];
        }
        else{
            [self.bTopShare setFrame:CGRectMake( size.width/2 - 44-10, 0, 44, 44)];
            [self.bTopBookMark setFrame:CGRectMake(size.width/2 + 0 + 10, 0, 44, 44)];
        }
        
    }
    else{
        if ( self.appStage == 8 ){
            [self.bTopShare setFrame:CGRectMake( size.width/2-16, 0, 32, 32)];
        }
        else{
            [self.bTopShare setFrame:CGRectMake( size.width/2 - 16-20, 0, 32, 32)];
            [self.bTopBookMark setFrame:CGRectMake(size.width/2 + 0 + 20, 0, 32, 32)];
        }
    }
}


-(void)fixNav{
    [self setBackButtonImage];
    
    if ([NHelper isIphone]) {
        [self fixNavIphone];
    }
    else{
    
        if( [NHelper isLandscapeInReal] ){
            if ( self.appStage == 8 ){
                [self.bTopShare setFrame:CGRectMake( 1024/2 - 22, 0, 44, 44)];
            }
            else{
                [self.bTopShare setFrame:CGRectMake( 1024/2 - 44-10, 0, 44, 44)];
                [self.bTopBookMark setFrame:CGRectMake(1024/2 + 0 + 10, 0, 44, 44)];
            }
            
        }
        else{
            if ( self.appStage == 8 ){
                //G
                [self.bTopShare setFrame:CGRectMake( 768/2 - 22, 0, 44, 44)];
            }
            else{
               [self.bTopShare setFrame:CGRectMake( 768/2 - 44-10, 0, 44, 44)];
                [self.bTopBookMark setFrame:CGRectMake(768/2 + 0 + 10, 0, 44, 44)];
            }
        }
    }
}



-(void)setupBookmarkButton: (BOOL)addBook pageid:(int)pageid{
    if ( addBook ){
        [self.bTopBookMark setImage:[NHelper imagedColorized:@"bookmarks_plus" withColor:[NHelper colorFromPlist:@"catalog_topbar_icon_color"]] forState:UIControlStateNormal];NSLog(@"set tag: %d", pageid );
        self.bTopBookMark.tag = pageid;
    }
    else{
        [self.bTopBookMark setImage:[NHelper imagedColorized:@"bookmarks_minus" withColor:[NHelper colorFromPlist:@"catalog_topbar_icon_color"]] forState:UIControlStateNormal];
        self.bTopBookMark.tag = pageid;
    }
    
}

-(void)bookIt:(UIButton*)button{
    if ( ![self checkBookmarkExist:(int)self.bTopBookMark.tag] ){
        
        [self addToBookMark:(int)self.bTopBookMark.tag issue_id:self.currentIshue->ishue_id coverThumbUrl:@"http:/fdsf.pl" name:@"LUTY"];
        
        [self.bTopBookMark setImage:[NHelper imagedColorized:@"bookmarks_minus" withColor:[NHelper colorFromPlist:@"catalog_topbar_icon_color"]] forState:UIControlStateNormal];
    }
    else{
        [self.bTopBookMark setImage:[NHelper imagedColorized:@"bookmarks_plus" withColor:[NHelper colorFromPlist:@"catalog_topbar_icon_color"]] forState:UIControlStateNormal];
        
        [self removeFromBookmark:(int)self.bTopBookMark.tag];
    }
    
}


+(void)showRectParams: (CGRect)rect label:(NSString *)label{
    if( YES )
    NSLog(@"%@: x: %f y:%f width:%f height: %f", label,
          rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

+(void)showSizeParams: (CGSize)rect label:(NSString *)label{
    if( YES )
    NSLog(@"%@: width:%f height: %f", label,
          rect.width, rect.height);
}



-(void)shareIt{
    NSArray *activityItems;
    
    if( self.appStage == 8 ){
        activityItems = @[@"Polecam artykuł w wydaniu mobilnym.", self.currentGalleryImage ];
    }
    else{
        if ( self.currentIshue.curentImage == NULL || self.currentIshue.curentImage == nil ){
            activityItems = @[@"Polecam artykuł w wydaniu mobilnym.", self.currentIshue.curentImageR ];
        }
        else if ( self.currentIshue.curentImageR == NULL || self.currentIshue.curentImageR == nil ){
            activityItems = @[@"Polecam artykuł w wydaniu mobilnym.", self.currentIshue.curentImage ];
        }
        else{
            activityItems = @[@"Polecam artykuł w wydaniu mobilnym.", self.currentIshue.curentImage, self.currentIshue.curentImageR ];
        }
        
        
        
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:activityItems
                                                    applicationActivities:nil];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL done){
        if (done) {
            NSLog(@"Success");
        }
        else {
            NSLog(@"Error/Cancel");
        }
        
    }];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        activityController.popoverPresentationController.sourceView = self.viewController.view;
    }
    
    
    [self.viewController presentViewController:activityController
                                      animated:YES completion:nil];
    
    
}






-(void)showNavigNoAnim{
    [self setBackButtonImage];
    [self.nc setNavigationBarHidden:NO animated:NO];
    self.nc.navigationBar.topItem.title = @"";
    
    self.navShow = YES;
}
-(void)hideNavigNoAnim{
    [self setBackButtonImage];
    [self.nc setNavigationBarHidden:YES animated:NO];
    self.navShow = NO;
}


-(void)showNavig{
    [self setBackButtonImage];
    [self.nc setNavigationBarHidden:NO animated:animallowed];
   self.nc.navigationBar.topItem.title = @"";
    [self checksharable];
    
   
    
    self.navShow = YES;
}
-(void)hideNavig{
    [self setBackButtonImage];
    [self.nc setNavigationBarHidden:YES animated:animallowed];
    self.navShow = NO;
}



-(void)createLoginFadeBackground{
    
    [uiva removeFromSuperview];
    [uaivc removeFromSuperview];
    
    NSLog(@"createLoginFadeBackground");
//    CGRect r = [[UIScreen mainScreen] bounds];
    //    if( r.size.width > r.size.height ){
//    [NHelper showRectParams:r label:@"r"];
    [NHelper showRectParams:self.viewController.view.frame label:@"self.viewController.view"];
    
    CGSize s = [NHelper getSizeOfCurrentDeviceOrient];
    
    NSLog(@"createLoginFadeBackground FULL");
    uiva = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024,  1024)];
    [uiva setContentMode:UIViewContentModeScaleAspectFit];
    
    if( [NHelper isLandscapeInReal] ){
        [NHelper showSizeParams:s label:@"dupa"];
        NSLog(@"createLoginFadeBackground POZIOM: ");
        [uiva setImage:[UIImage imageNamed:@"splashPion.png"]];
    }
    else{
        NSLog(@"createLoginFadeBackground PION");
        [uiva setImage:[UIImage imageNamed:@"splashPion.png"]];
    }
    uaivc = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if( [NHelper isLandscapeInReal ]){
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
            uaivc.center = CGPointMake(s.width/2, s.height/2);
        }
        else{
            uaivc.center = CGPointMake(s.height/2, s.width/2);
        }
    }
    else{
        uaivc.center = CGPointMake(s.width/2, s.height/2);
    }
    [uaivc startAnimating];
    
    [uiva setAlpha:1.0];
    //    [self.viewController.view addSubview:uiva];
    [[UIApplication sharedApplication].keyWindow addSubview:uiva];
    [[UIApplication sharedApplication].keyWindow addSubview:uaivc];
    
}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSLog(@"path is %@",documentsDirectory);
   
  
    // Do initial setup
    int cacheSizeMemory = 16*1024*1024; // 16MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    self.alreadyBought = [[NSMutableArray alloc] init];
    //Check on local
    
    animallowed = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
    self.allowAllOrients = NO;
    self.playMovie = NO;
    self.reloadViewAfterReturn = NO;
    self.appStage = 0;
    self.thumbBlocked = NO;
    self.DBC = [[DBController alloc] init];
    self.presetColorFiolet = [UIColor colorWithRed:7.0f/255.0f green:60.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    self.presetColorSzary = [UIColor colorWithRed:241.0f/255.0f green:242.0f/255.0f blue:243.0f/255.0f alpha:1.0f];
    self.presetBackgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    self.tutorialHided = NO;
    self.extraAkcjaBlokujacaRotate = NO;
    self.pageCurlAnimationInProgress = NO;
    blockThumbs = NO;
    self.forcePageNum = -1;
    app_id = [((NSNumber*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APP_appID"]) intValue];
    app_subs = (NSArray*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APP_subs"];
    
    NSString* mu_id = [self getMuId];
    self.mobileuser = [[MobileUser alloc] initWithMuId:[mu_id intValue]];
    
    if( mu_id == NULL){
        [self setMuId:self.mobileuser.mu_id];
    }

    [self reSetup];
//    
//    [self setupAppViewOnlineSettings];
//    [self setupIshuesCollection];
//    [self setupBookmarksCollection];
    
//    _CLController = [[CoreLocationController alloc] init];
//    _CLController.delegate = self;
//    [_CLController.locMgr startUpdatingLocation];
    
    
    orientPion = NO;
    
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
       
//    [RageIAPHelper sharedInstance];
    
    return YES;
}

-(void)reSetup{
    [self setupAppViewOnlineSettings];
    [self setupIshuesCollection];
    [self setupBookmarksCollection];
}

-(void)hideFadeAnim:(float)duration delay:(float)delay{
    [UIImageView animateWithDuration:duration delay:delay options: (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews) animations:^{
        uiva.alpha = 0.0f;
    }
                          completion:^ (BOOL finished)
     {
         if (finished) {
             [uiva removeFromSuperview];
             [uaivc removeFromSuperview];
         }
     }
     ];
 
//    UIViewAnimationOptionLayoutSubviews
}




-(BOOL)isFav:(int)ishue_id{
    [self getFromFav];
    BOOL isFav = NO;
    for (NSNumber* favid in self.favIshuesColection) {
        NSLog(@"favs: %@", favid);
        if ( ishue_id == [favid integerValue] ){
            isFav = YES;
            break; //break for ;]
        }
    }
    return isFav;
}

-(void)addToBookMark: (int)page_id issue_id:(int)issue_id coverThumbUrl:(NSString*)coverThumbUrl name:(NSString*)name {
    if ( ![self checkBookmarkExist:page_id] ){
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        
        NSManagedObject *newContact;
        newContact = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Bookmarks"
                      inManagedObjectContext:context];
        [newContact setValue: [NSNumber numberWithInt:page_id] forKey:@"bookmark_id"];
        [newContact setValue: [NSNumber numberWithInt:issue_id] forKey:@"issue_id"];
        [newContact setValue: coverThumbUrl forKey:@"coverThumbUrl"];
        [newContact setValue: name forKey:@"name"];
        [newContact setValue: [NSDate date] forKey:@"set_time"];
        
        NSError *error;
        [context save:&error];
    }
    
}



-(void)removeFromBookmark: (int)bookmark_id{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Bookmarks"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(bookmark_id = %d)",
     bookmark_id];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    for ( int i=0; i<[objects count]; i++ ) {
        NSManagedObject *matches = objects[i];
        NSLog(@"delete :%@", matches );
        [context deleteObject:matches];
        break;
    }
    
    
//    [self getFromBooks];
    
}


-(void)reloadBookmarks {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Bookmarks"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    NSLog(@"getFromBookmarks -  matches count: %lu", (unsigned long)[objects count] );
    
    [self.bookmarksColection removeAllObjects];
    if ([objects count] == 0) {
        //        return false;
        
    }
    else{
        for ( int i=0; i<[objects count]; i++ ) {
            NSManagedObject *matches = objects[i];
            NSNumber* bookmark_id = [matches valueForKey:@"bookmark_id"];
            BookMark* bbbm = [[BookMark alloc] initWithPageId:[bookmark_id intValue]];
            if( bbbm->app_id == app_id ){
                [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:[bookmark_id intValue]] ];
            }
        }
    }
}



-(BOOL)checkBookmarkExist: (int)bookmark_id{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Bookmarks"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(bookmark_id = %d)", bookmark_id];
    [request setPredicate:pred];
    
    NSLog(@"pred for: %@", pred);
    
//    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    NSLog(@"getFromBookmarks -  matches count: %lu", (unsigned long)[objects count] );
    
    if ([objects count] == 0) {
        return false;
    }
    return true;
}





-(void)addToFav: (int)ishue_id{
    if ( ![self checkFavExist:ishue_id] ){
    
        NSManagedObjectContext *context = [self managedObjectContext];
        
        
        NSManagedObject *newContact;
        newContact = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Fav"
                      inManagedObjectContext:context];
        [newContact setValue: [NSNumber numberWithInt:ishue_id] forKey:@"ishue_id"];
        [newContact setValue: [NSDate date] forKey:@"set_time"];
        
        NSError *error;
        [context save:&error];
        NSLog(@"Fav Saved");
        [self getFromFav];
    }
    
}



-(void)removeFromFav: (int)ishue_id{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Fav"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(ishue_id = %d)",
     ishue_id];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    for ( int i=0; i<[objects count]; i++ ) {
        NSManagedObject *matches = objects[i];
        NSLog(@"delete :%@", matches );
        [context deleteObject:matches];
        break;
    }
    
    
    [self getFromFav];
    
}

-(BOOL)checkFavExist: (int)ishue_id{
    NSLog(@"ckeck for: %d", ishue_id);
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Fav"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(ishue_id = %d)",
     ishue_id];
    [request setPredicate:pred];
//    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    NSLog(@"getFromFav -  matches count: %lu", (unsigned long)[objects count] );
    
    if ([objects count] == 0) {
        return false;
    }
    return true;
}

-(void)getFromFav{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Fav"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];

    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    self.favIshuesColection = [[NSMutableArray alloc] init];
    [self.favIshuesColection removeAllObjects];
    if ([objects count] == 0) {
        NSLog(@"getFromFav - No matches");
    } else {
        NSLog(@"getFromFav -  matches count: %lu", (unsigned long)[objects count] );
        
        for ( int i=0; i<[objects count]; i++ ) {
             NSManagedObject *matches = objects[i];
            NSNumber* ishue_id = [matches valueForKey:@"ishue_id"];
//            NSDate* set_time = [matches valueForKey:@"set_time"];
            [self.favIshuesColection addObject:ishue_id];
        }
        
    }
    
}


-(NSMutableArray*) getCollectionOfIssuesForFolderId:(int)folder_id{
    NSMutableArray* marray = [[NSMutableArray alloc] init];
    for (Ishue* issue in self.ishuesColection) {
        if ( issue->parent_folder == folder_id ){
            [marray addObject:issue];
        }
    }
    return marray;
}

-(void) setupIshuesCollection{
    self.ishuesColection = [[NSMutableArray alloc] init];
    NSDictionary* xxx = [self.DBC getIshuesForAppId:app_id];
    
    
    for (NSDictionary* ishueDB in xxx) {
        Ishue* ish = [[Ishue alloc] initWithDBBAsicInfo:ishueDB];
        [self.ishuesColection addObject:ish];
    }
}

-(void) setupBookmarksCollection{
    self.bookmarksColection = [[NSMutableArray alloc] init];

    //    for (NSDictionary* ishueDB in xxx) {
//    BookMark* bm = [[BookMark alloc] initWithDBBAsicInfo:nil];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2568]];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2707]];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2708]];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2709]];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2578]];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2711]];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2712]];
//    [self.bookmarksColection addObject:[[BookMark alloc] initWithPageId:2715]];
    
//    }
}


-(void)setMuId: (NSNumber*)mu_id{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:mu_id forKey:@"mu_id"];
    [prefs synchronize];
}

-(NSString*)getMuId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* mu_id = [prefs stringForKey:@"mu_id"];
    return mu_id;
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceToken2 = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken2 = [deviceToken2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self.mobileuser updateUserToken:deviceToken2 appId:app_id];
}



- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog( @" self.loadViewController: %@",  self.loadViewController);
    if ( self.loadViewController != [NSNull null] && self.loadViewController != nil  ){
        
        self.loadViewController->splitPDFAndMakeprevsProcessAllow = NO;
        NSLog(@"applicationWillResignActive");
        [self.loadViewController.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            if (!resumeData) return;
            //        [self setResumeData:resumeData];
            [self.loadViewController setDownloadTask:nil];
            
        }];
        
        self.loadViewController->splitPDFAndMakeprevsProcessAllow = NO;
    
    }
    NSLog(@"sleep s");
    [NSThread sleepForTimeInterval:3];
    NSLog(@"sleep e");
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"appDidEnterBack");
    if ( self.loadViewController != [NSNull null] && self.loadViewController != nil  ){
        self.loadViewController->splitPDFAndMakeprevsProcessAllow = NO;
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive: %d", self.appStage );
    if ( self.appStage == 6){
//        if ( !self.loadViewController->downloadPaused ){
            [self.loadViewController actionTest: NO pobudka:YES];
//        }
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)locationUpdate:(CLLocation *)location {
    [self.mobileuser updateUserLocation:location];
}

- (void)locationError:(NSError *)error {
    NSLog(@"locationError: %@", [error description] );
}



//static





+(void)borderView: (UIView*)xview color:(UIColor*)color width:(float)width{
    xview.layer.borderColor = color.CGColor;
    xview.layer.borderWidth = width;
}


@end
