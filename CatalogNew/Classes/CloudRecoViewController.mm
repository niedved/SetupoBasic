/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import "CloudRecoViewController.h"
#import <QCAR/QCAR.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ObjectTracker.h>
#import <QCAR/ImageTarget.h>
#import <QCAR/DataSet.h>
#import <QCAR/Trackable.h>
#import <QCAR/TargetFinder.h>
#import <QCAR/TargetSearchResult.h>
#import "AppDelegate.h"
#import "ContentButton.h"
#import "NHelper.h"

// ----------------------------------------------------------------------------
// Credentials for authenticating with the CloudReco service
// These are read-only access keys for accessing the image database
// specific to this sample application - the keys should be replaced
// by your own access keys. You should be very careful how you share
// your credentials, especially with untrusted third parties, and should
// take the appropriate steps to protect them within your application code
// ----------------------------------------------------------------------------
static const char* const kAccessKey = "665caf8c871a4bf19825ee4652c5da25a5e51c26";
static const char* const kSecretKey = "6de8de420bd6e93ed5adf3644b112b77860e2a1b";

@interface CloudRecoViewController ()

@end

@implementation CloudRecoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        vapp = [[SampleApplicationSession alloc]initWithDelegate:self];
        // Custom initialization
        self.title = @"wPlus";
        // Create the EAGLView with the screen dimensions
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        viewFrame = screenBounds;
        
        // If this device has a retina display, scale the view bounds that will
        // be passed to QCAR; this allows it to calculate the size and position of
        // the viewport correctly when rendering the video background
        if (YES == vapp.isRetinaDisplay) {
            viewFrame.size.width *= 2.0;
            viewFrame.size.height *= 2.0;
        }
        
        scanningMode = YES;
        isVisualSearchOn = NO;
        
        // single tap will trigger focus
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autofocus:)];
        
        // we use the iOS notification to pause/resume the AR when the application goes (or comeback from) background
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(pauseAR)
         name:UIApplicationWillResignActiveNotification
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(resumeAR)
         name:UIApplicationDidBecomeActiveNotification
         object:nil];
        
        blockARHard = NO;
        
        offTargetTrackingEnabled = NO;
        isShowingAnAlertView = NO;
        
//        CGRect scrBounds = [[UIScreen mainScreen] bounds];
        
        
        [self setButtons];
        
        
        
        
    }
    return self;
}


-(BOOL)isIpad{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

-(NSMutableArray*) getButtonsPositionsFrames: (int)type nums:(int)nums{
    NSMutableArray* masks = [[NSMutableArray alloc] init];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float biger = screenBounds.size.width > screenBounds.size.height ? screenBounds.size.width : screenBounds.size.height;
    float shorter = screenBounds.size.width > screenBounds.size.height ? screenBounds.size.height : screenBounds.size.width;
    float buttonWidth = 0;
    float margin = 25;
    if ( type == 1 ){
        buttonWidth = ((biger-(nums*margin*2)) / nums);
        NSLog(@"%f = ((%f-(%d*%f*2)) / %d)", buttonWidth, biger, nums, margin, nums);
        for (int i=0; i<nums; i++) {
            UIView* v = [[UIView alloc] initWithFrame: CGRectMake( ( i * (buttonWidth + margin ) ) + margin ,
                       shorter - buttonWidth - margin, buttonWidth, buttonWidth)];
            v.layer.borderWidth = 0.0f;
            v.layer.borderColor = [UIColor blackColor].CGColor;
            
            [masks addObject:v];
        }
        
     //przecza - tomczak - z zagi
    }
    
    return masks;
}

-(void)setButtons{
    NSMutableArray* masks = [self getButtonsPositionsFrames:1 nums:6];
    int nums= 6;
    self.bArray = [[NSMutableArray alloc] initWithCapacity:9];
    for( int i=0; i<nums; i++ ){
        [self.bArray addObject:[masks objectAtIndex:i]];
        [self.view addSubview:[masks objectAtIndex:i]];
    }
    
    [self hideAllButtons];
}

-(void)hideAllButtons{
    dispatch_async( dispatch_get_main_queue(), ^{
        for (UIView* b in self.bArray) {
            [b setHidden:YES];
        }
    });
}


-(void)handleBTap:(UITapGestureRecognizer *)gestureRecognizer {
//    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    UIView* v = gestureRecognizer.view;;
//    NSLog(@"ma_id: %d", v.tag );
//    for (ContentButton* cb in self.buttonsColection) {
//        if ( cb.ma_id == v.tag ){
//            NSLog(@"action_type_id: %d", cb.action_type_id );
//            
//            switch ( cb.action_type_id ) {
//                case 1:
//                    appDelegate->cb = cb;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kShowBrowser" object:nil];
//                    break;
//                case 2:
//                    appDelegate->cb = cb;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kShowVideo" object:nil];
//                    break;
//                case 3:
//                    appDelegate->cb = cb;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kShowGallery" object:nil];
//                    break;
//                case 4:
//                    appDelegate->cb = cb;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kShowAudio" object:nil];
//                    break;
//                case 5:
//                    appDelegate->cb = cb;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kShowMap" object:nil];
//                    break;
//                case 6:
//                    appDelegate->cb = cb;
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kShowPDF" object:nil];
//                    break;
//                default:
//                    break;
//            }
//        }
//    }

    
//    ContentButton* btn = (ContentButton*)sender;
//
//    NSLog(@"tapped: %@",  );
}

-(NSDictionary*)getMarkerDataForMarkerId: (int)m_id{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary* currentMarkerInfo = [[NSDictionary alloc] init];
//    for (NSDictionary* marker in appDelegate.markersColection ) {
//        if ( [[marker objectForKey:@"m_id"] intValue] == m_id ){
//            currentMarkerInfo = marker;
//            break;
//        }
//    }
    return currentMarkerInfo;
}

- (void)detectedNewMarker{
//    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self hideAllButtons];
   
//    appDelegate.currentMarkerInfo = [self getMarkerDataForMarkerId:appDelegate.currentlyTargetedMarkerId];
    
//    NSMutableArray* actionForMarker = [self getActionsForMarker:appDelegate.currentlyTargetedMarkerId ];
    
//    self.buttonsColection = [[NSMutableArray alloc] initWithCapacity:9];
//    //prep buttons
//    for (NSDictionary* action in actionForMarker) {
//        ContentButton* button = [[ContentButton alloc] initWithDatasId:action];
//        [self.buttonsColection addObject:button];
//    }
//    
//    [self hideAllButtons];
//    
//    
//    int num = 0;
//    NSMutableArray *zajetepozycje = [[NSMutableArray alloc] init];
  
//    for (ContentButton* cb in self.buttonsColection) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIView* b = nil;
//            if ( cb.btn_position > 0 ){
//                b = [self.bArray objectAtIndex:cb.btn_position-1];
//                [b setHidden:NO];
//                UIImage* image = [UIImage imageWithContentsOfFile:cb.icon.linklocal];
//                UIGraphicsBeginImageContext(b.frame.size);
//                [image drawInRect:b.bounds];
//                image = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//                
//                b.backgroundColor = [UIColor colorWithPatternImage:image];
//                [zajetepozycje addObject:[NSString stringWithFormat:@"%d", cb.btn_position-1]];
//                
//                b.tag = cb.ma_id;
//                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBTap:)];
//                tap.delegate = self;
//                [b addGestureRecognizer:tap];
//            }
//        });
//        
//    }
    //w pierwszej kolejnosci pokazujemy te z unset positiun
    
//    for (ContentButton* cb in self.buttonsColection) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIView* b = nil;
//            if ( cb.btn_position == 0 ){
//                int numForThisButton = 0;
//                bool czyZnalezionoSlot = NO;
//                for (numForThisButton = 0; numForThisButton<9; numForThisButton++) {
//                    bool czyZajete = false;
//                    //test czy dany numforthisbu jest wolny
//                    for (NSString* str in zajetepozycje) {
//                        if ( numForThisButton == [str intValue] ){
//                            czyZajete = YES;
//                            break;
//                        }
////                        NSLog(@"str: %@",  str );
//                        
//                    }
//                    NSLog(@"pozycja: %d czy zajete: %d",  numForThisButton, czyZajete );
//                    if ( czyZajete == NO ){
//                        czyZnalezionoSlot = YES;
//                        [zajetepozycje addObject:[NSString stringWithFormat:@"%d", numForThisButton]];
//                        
//                        break;
//                    }
//                }
//                
//                NSLog(@"pozycja pierwsza wolna: %d",  numForThisButton );
//                
//                
//                
////                 NSLog(@"pierwsza wolna pozycja: %d",  numForThisButton );
//                
//                b = [self.bArray objectAtIndex:numForThisButton];
////
//                [b setHidden:NO];
//                UIImage* image = [UIImage imageWithContentsOfFile:cb.icon.linklocal];
//                UIGraphicsBeginImageContext(b.frame.size);
//                [image drawInRect:b.bounds];
//                image = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//                
//                b.backgroundColor = [UIColor colorWithPatternImage:image];
//                
//                b.tag = cb.ma_id;
//                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBTap:)];
//                tap.delegate = self;
//                [b addGestureRecognizer:tap];
//            }
//        });
//        
//    }
    
    
    
    
    
    
}


+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}



- (NSMutableArray*)getActionsForMarker: (int)marker_id{
//    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray* markerActions = [[NSMutableArray alloc] init];
//    for (NSDictionary* action in appDelegate.actionColection ) {
//        if ( [[action objectForKey:@"m_id"] intValue] == marker_id  ){
//            if ( [action objectForKey:@"action_id"] != [NSNull null] ){
//                [markerActions addObject: action];
//                
//            }
//        }
//    }
    
    return markerActions;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [vapp release];
    [eaglView release];
    [super dealloc];
}


- (void) setNavigationController:(UINavigationController *) theNavController {
    navController = theNavController;
}





- (BOOL) isVisualSearchOn {
    return isVisualSearchOn;
}

- (void) setVisualSearchOn:(BOOL) isOn {
    isVisualSearchOn = isOn;
}

- (void)loadView
{
    // Create the EAGLView
    eaglView = [[CloudRecoEAGLView alloc] initWithFrame:viewFrame  appSession:vapp viewController:self];
    [self setView:eaglView];
    
    
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect indicatorBounds = CGRectMake(mainBounds.size.width / 2 - 12,
                                        mainBounds.size.height / 2 - 12, 24, 24);
    UIActivityIndicatorView *loadingIndicator = [[[UIActivityIndicatorView alloc]
                                                  initWithFrame:indicatorBounds]autorelease];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [eaglView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // initialize the AR session
    if( [NHelper isLandscapeInReal]){
        appDelegate->arlaunchedinposition = 1;
//    [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationPortrait];
        [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationLandscapeLeft];
    
    }
    else{
         appDelegate->arlaunchedinposition = 0;
        [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationPortrait];
        
    }
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseAR)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeAR)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];

    
}






- (void) pauseAR {
    [eaglView dismissPlayers];
    NSError * error = nil;
    if (![vapp pauseAR:&error]) {
        NSLog(@"Error pausing AR:%@", [error description]);
    }
}

- (void) resumeAR {
    [eaglView preparePlayers];
    NSError * error = nil;
    if(! [vapp resumeAR:&error]) {
        NSLog(@"Error resuming AR:%@", [error description]);
    }
    // on resume, we reset the flash and the associated menu item
    QCAR::CameraDevice::getInstance().setFlashTorchMode(false);
    SampleAppMenu * menu = [SampleAppMenu instance];
    [menu setSelectionValueForCommand:C_FLASH value:false];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [eaglView prepare];
    
    [self prepareMenu];
    self.navigationController.navigationBar.translucent = YES;

    
    UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleDoubleTap:)] autorelease];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]autorelease];
    tap.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:tap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // last error seen - used to avoid seeing twice the same error in the error dialog box
    lastErrorCode = 99;
    
    

    
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!self.presentedViewController && !fullScreenPlayerPlaying) {
        // cleanup menu
        [[SampleAppMenu instance]clear];
        
        [eaglView dismiss];
        
        [vapp stopAR:nil];
        // Be a good OpenGL ES citizen: now that QCAR is paused and the render
        // thread is not executing, inform the root view controller that the
        // EAGLView should finish any OpenGL ES commands
        [eaglView finishOpenGLESCommands];
    }
}

- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  Inform the EAGLView
    [eaglView finishOpenGLESCommands];
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Inform the EAGLView
    [eaglView freeOpenGLESResources];
}



//------------------------------------------------------------------------------
#pragma mark - Autorotation
- (NSUInteger)supportedInterfaceOrientations
{
    // iOS >= 6
    return UIInterfaceOrientationMaskLandscapeLeft;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

//- (BOOL)shouldAutorotate {
//    
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    
//    if (orientation == UIInterfaceOrientationPortrait) {
//        // your code for portrait mode
//        return NO;
//        
//    }
//    
//    return YES;
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// double tap handler
- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"show_menu" object:self];
}

// tap handler
- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        CGPoint touchPoint = [sender locationInView:eaglView];
        [eaglView handleTouchPoint:touchPoint];
    }
}

- (void) dimissController:(id) sender {
    self.navigationController.navigationBar.translucent = NO;
    [vapp stopAR:nil];
    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [eaglView finishOpenGLESCommands];
    [self.navigationController popViewControllerAnimated:YES];
}


// Present a view controller using the root view controller (eaglViewController)
- (void)rootViewControllerPresentViewController:(UIViewController*)viewController inContext:(BOOL)currentContext
{
    //    if (YES == currentContext) {
    //        // Use UIModalPresentationCurrentContext so the root view is not hidden
    //        // when presenting another view controller
    //        [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    //    }
    //    else {
    //        // Use UIModalPresentationFullScreen so the presented view controller
    //        // covers the screen
    //        [self setModalPresentationStyle:UIModalPresentationFullScreen];
    //    }
    //
    //    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
    //        // iOS > 4
    //        [self presentViewController:viewController animated:NO completion:nil];
    //    }
    //    else {
    //        // iOS 4
    //        [self presentModalViewController:viewController animated:NO];
    //    }
    
    NSLog(@"navigationController is:%@", [navController description]);
    fullScreenPlayerPlaying = YES;
    [navController pushViewController:viewController animated:YES];
}

// Dismiss a view controller presented by the root view controller
// (eaglViewController)
- (void)rootViewControllerDismissPresentedViewController
{
    //    // Dismiss the presented view controller (return to the root view
    //    // controller)
    //    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
    //        // iOS > 4
    //        [self dismissViewControllerAnimated:NO completion:nil];
    //    }
    //    else {
    //        // iOS 4
    //        [self dismissModalViewControllerAnimated:NO];
    //    }
    //
    NSLog(@"navigationController is:%@", [navController description]);
    fullScreenPlayerPlaying = NO;
    [navController popViewControllerAnimated:YES];
    
}




-(void)showUIAlertFromErrorCode:(int)code
{
    
    if (!isShowingAnAlertView)
    {
        if (lastErrorCode == code)
        {
            // we don't want to show twice the same error
            return;
        }
        lastErrorCode = code;
        
        NSString *title = nil;
        NSString *message = nil;
        
        if (code == QCAR::TargetFinder::UPDATE_ERROR_NO_NETWORK_CONNECTION)
        {
            title = @"Network Unavailable";
            message = @"Please check your internet connection and try again.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_REQUEST_TIMEOUT)
        {
            title = @"Request Timeout";
            message = @"The network request has timed out, please check your internet connection and try again.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_SERVICE_NOT_AVAILABLE)
        {
            title = @"Service Unavailable";
            message = @"The cloud recognition service is unavailable, please try again later.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_UPDATE_SDK)
        {
            title = @"Unsupported Version";
            message = @"The application is using an unsupported version of Vuforia.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_TIMESTAMP_OUT_OF_RANGE)
        {
            title = @"Clock Sync Error";
            message = @"Please update the date and time and try again.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_AUTHORIZATION_FAILED)
        {
            title = @"Authorization Error";
            message = @"The cloud recognition service access keys are incorrect or have expired.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_PROJECT_SUSPENDED)
        {
            title = @"Authorization Error";
            message = @"The cloud recognition service has been suspended.";
        }
        else if (code == QCAR::TargetFinder::UPDATE_ERROR_BAD_FRAME_QUALITY)
        {
            title = @"Poor Camera Image";
            message = @"The camera does not have enough detail, please try again later";
        }
        else
        {
            title = @"Unknown error";
            message = [NSString stringWithFormat:@"An unknown error has occurred (Code %d)", code];
        }
        
        //  Call the UIAlert on the main thread to avoid undesired behaviors
        dispatch_async( dispatch_get_main_queue(), ^{
            if (title && message)
            {
                UIAlertView *anAlertView = [[[UIAlertView alloc] initWithTitle:title
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil] autorelease];
                anAlertView.tag = 42;
                [anAlertView show];
                isShowingAnAlertView = YES;
            }
        });
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // we go back to the about page
    isShowingAnAlertView = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMenuDismissViewController" object:nil];
}



#pragma mark - loading animation

- (void) showLoadingAnimation {
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect indicatorBounds = CGRectMake(mainBounds.size.width / 2 - 12,
                                        mainBounds.size.height / 2 - 12, 24, 24);
    UIActivityIndicatorView *loadingIndicator = [[[UIActivityIndicatorView alloc]
                                                  initWithFrame:indicatorBounds]autorelease];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [eaglView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}

- (void) hideLoadingAnimation {
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [loadingIndicator removeFromSuperview];
}

#pragma mark - SampleApplicationControl

- (bool) doInitTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ObjectTracker::getClassType());
    // Set the visual search credentials:
    QCAR::TargetFinder* targetFinder = static_cast<QCAR::ObjectTracker*>(trackerBase)->getTargetFinder();
    if (targetFinder == NULL)
    {
        NSLog(@"Failed to get target finder.");
        return NO;
    }
    
    NSLog(@"Successfully initialized ObjectTracker.");
    return YES;
}

- (bool) doLoadTrackersData {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* imageTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    if (imageTracker == NULL)
    {
        NSLog(@">doLoadTrackersData>Failed to load tracking data set because the ObjectTracker has not been initialized.");
        return NO;
        
    }
    
    // Initialize visual search:
    QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
    if (targetFinder == NULL)
    {
        NSLog(@">doLoadTrackersData>Failed to get target finder.");
        return NO;
    }
    
    NSDate *start = [NSDate date];
    
    // Start initialization:
    if (targetFinder->startInit(kAccessKey, kSecretKey))
    {
        targetFinder->waitUntilInitFinished();
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
        
        NSLog(@"waitUntilInitFinished Execution Time: %f", executionTime);

        
    }
    
    int resultCode = targetFinder->getInitState();
    if ( resultCode != QCAR::TargetFinder::INIT_SUCCESS)
    {
        NSLog(@">doLoadTrackersData>Failed to initialize target finder.");
        if (resultCode == QCAR::TargetFinder::INIT_ERROR_NO_NETWORK_CONNECTION) {
            NSLog(@"CloudReco error:QCAR::TargetFinder::INIT_ERROR_NO_NETWORK_CONNECTION");
        } else if (resultCode == QCAR::TargetFinder::INIT_ERROR_SERVICE_NOT_AVAILABLE) {
            NSLog(@"CloudReco error:QCAR::TargetFinder::INIT_ERROR_SERVICE_NOT_AVAILABLE");
        } else {
            NSLog(@"CloudReco error:%d", resultCode);
        }
        
        int initErrorCode;
        if(resultCode == QCAR::TargetFinder::INIT_ERROR_NO_NETWORK_CONNECTION)
        {
            initErrorCode = QCAR::TargetFinder::UPDATE_ERROR_NO_NETWORK_CONNECTION;
        }
        else
        {
            initErrorCode = QCAR::TargetFinder::UPDATE_ERROR_SERVICE_NOT_AVAILABLE;
        }
        [self showUIAlertFromErrorCode: initErrorCode];
        return NO;
    } else {
        NSLog(@">doLoadTrackersData>target finder initialized");
    }
    
    return YES;
}

- (bool) doStartTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    
    QCAR::ObjectTracker* imageTracker = static_cast<QCAR::ObjectTracker*>(
                                                                        trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    assert(imageTracker != 0);
    imageTracker->start();
    
    // Start cloud based recognition if we are in scanning mode:
    if (scanningMode)
    {
        QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
        assert (targetFinder != 0);
        isVisualSearchOn = targetFinder->startRecognition();
    }
    return YES;
}

- (void) onInitARDone:(NSError *)initError {
    // remove loading animation
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [loadingIndicator removeFromSuperview];

    if (initError == nil) {
        NSError * error = nil;
        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];
        
        // by default, we try to set the continuous auto focus mode
        // and we update menu to reflect the state of continuous auto-focus
        bool isContinuousAutofocus = QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
        SampleAppMenu * menu = [SampleAppMenu instance];
        [menu setSelectionValueForCommand:C_AUTOFOCUS value:isContinuousAutofocus];
        

    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
    }
}

- (bool) doStopTrackers {
    // Stop the tracker
    // Stop the tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* imageTracker = static_cast<QCAR::ObjectTracker*>(
                                                                        trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    assert(imageTracker != 0);
    imageTracker->stop();
    
    // Stop cloud based recognition:
    QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
    assert (targetFinder != 0);
    isVisualSearchOn = !targetFinder->stop();
    return YES;
}

- (bool) doUnloadTrackersData {
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* imageTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    
    if (imageTracker == NULL)
    {
        NSLog(@"Failed to unload tracking data set because the ObjectTracker has not been initialized.");
        return NO;
    }
    
    // Deinitialize visual search:
    QCAR::TargetFinder* finder = imageTracker->getTargetFinder();
    finder->deinit();
    return YES;
}

- (bool) doDeinitTrackers {
    return YES;
}

// enable auto-focus mode
- (void)autofocus:(UITapGestureRecognizer *)sender
{
    [self performSelector:@selector(cameraPerformAutoFocus) withObject:nil afterDelay:.4];
}

- (void)cameraPerformAutoFocus
{
    QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
}


- (void) onQCARUpdate: (QCAR::State *) state {
    // Get the tracker manager:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    
    // Get the image tracker:
    QCAR::ObjectTracker* imageTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    
    // Get the target finder:
    QCAR::TargetFinder* finder = imageTracker->getTargetFinder();
    
    // Check if there are new results available:
    const int statusCode = finder->updateSearchResults();
    if (statusCode < 0)
    {
        // Show a message if we encountered an error:
        NSLog(@"update search result failed:%d", statusCode);
        if (statusCode == QCAR::TargetFinder::UPDATE_ERROR_NO_NETWORK_CONNECTION) {
            [self showUIAlertFromErrorCode:statusCode];
        }
    }
    else if (statusCode == QCAR::TargetFinder::UPDATE_RESULTS_AVAILABLE)
    {
        
        // Iterate through the new results:
        for (int i = 0; i < finder->getResultCount(); ++i)
        {
            const QCAR::TargetSearchResult* result = finder->getResult(i);
            
            // Check if this target is suitable for tracking:
            if (result->getTrackingRating() > 0)
            {
                // Create a new Trackable from the result:
                QCAR::Trackable* newTrackable = finder->enableTracking(*result);
                if (newTrackable != 0)
                {
                    //  Avoid entering on ContentMode when a bad target is found
                    //  (Bad Targets are targets that are exists on the CloudReco database but not on our
                    //  own book database)
                    NSLog(@"Successfully created new trackable '%s' with rating '%d'.",
                          newTrackable->getName(), result->getTrackingRating());
                    if (offTargetTrackingEnabled) {
                        newTrackable->startExtendedTracking();
                    }
                }
                else
                {
                    NSLog(@"Failed to create new trackable.");
                }
            }
        }
    }
    
}

- (void) toggleVisualSearch {
    
    [self toggleVisualSearch:isVisualSearchOn];
}

- (void) toggleVisualSearch:(BOOL)visualSearchOn
{
    if ( blockARHard ){
        NSLog(@"HARD BLOCK");
        return;
    }
    
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* imageTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    assert(imageTracker != 0);
    QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
    assert (targetFinder != 0);
    if (visualSearchOn == NO)
    {
        if ( blockARHard ){
            NSLog(@"HARD BLOCK");
            
        }
        else{
            NSLog(@"Starting target finder");
            targetFinder->startRecognition();
            isVisualSearchOn = YES;
        }
    }
    else
    {
        NSLog(@"Stopping target finder");
        targetFinder->stop();
        isVisualSearchOn = NO;
    }
}

- (void) setOffTargetTracking:(BOOL) isActive {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* imageTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    assert(imageTracker != 0);
    QCAR::TargetFinder* targetFinder = imageTracker->getTargetFinder();
    int nbTargets = targetFinder->getNumImageTargets();
    for(int idx = 0; idx < nbTargets ; idx++) {
        QCAR::ImageTarget * it = targetFinder->getImageTarget(idx);
        if (it != NULL) {
            if (isActive) {
                it->startExtendedTracking();
            } else {
                it->stopExtendedTracking();
            }
        }
    }
}


#pragma mark - left menu

typedef enum {
    C_EXTENDED_TRACKING,
    C_AUTOFOCUS,
    C_FLASH,
    C_VIDEO_FULLSCREEN,
    C_CAMERA_FRONT,
    C_CAMERA_REAR
} I_COMAMND;

- (void) prepareMenu {
    
    SampleAppMenu * menu = [SampleAppMenu prepareWithCommandProtocol:self title:@"USTAWIENIA"];
    SampleAppMenuGroup * group;
    
    group = [menu addGroup:@""];
    [group addTextItem:@"Opuść tryb kamery" command:-1];
    
    group = [menu addGroup:@""];
//    [group addSelectionItem:@"Extended Tracking" command:C_EXTENDED_TRACKING isSelected:NO];
    [group addSelectionItem:@"Autofocus" command:C_AUTOFOCUS isSelected:NO];
    [group addSelectionItem:@"Flash" command:C_FLASH isSelected:NO];
//    [group addSelectionItem:@"Play Fullscreen" command:C_VIDEO_FULLSCREEN isSelected:false];
    
//    group = [menu addSelectionGroup:@"CAMERA"];
//    [group addSelectionItem:@"Front" command:C_CAMERA_FRONT isSelected:NO];
//    [group addSelectionItem:@"Rear" command:C_CAMERA_REAR isSelected:YES];
}

- (bool) menuProcess:(SampleAppMenu *) menu command:(int) command value:(bool) value{
    bool result = YES;
    NSError * error = nil;

    switch(command) {
        case C_FLASH:
            if (!QCAR::CameraDevice::getInstance().setFlashTorchMode(value)) {
                result = NO;
            }
            break;
            
        case C_EXTENDED_TRACKING:
            offTargetTrackingEnabled = value;
            [self setOffTargetTracking:offTargetTrackingEnabled];
            break;
            
        case C_VIDEO_FULLSCREEN:
            [eaglView willPlayVideoFullScreen:value];
            break;
        
        case C_CAMERA_FRONT:
        case C_CAMERA_REAR: {
            if ([vapp stopCamera:&error]) {
                result = [vapp startAR:(command == C_CAMERA_FRONT) ? QCAR::CameraDevice::CAMERA_FRONT:QCAR::CameraDevice::CAMERA_BACK error:&error];
            } else {
                result = NO;
            }
            if (result) {
                // if the camera switch worked, the flash will be off
                [menu setSelectionValueForCommand:C_FLASH value:false];
            }

        }
            break;
            
        case C_AUTOFOCUS: {
            int focusMode = (YES == value) ? QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO : QCAR::CameraDevice::FOCUS_MODE_NORMAL;
            result = QCAR::CameraDevice::getInstance().setFocusMode(focusMode);
        }
            break;
            
        default:
            result = NO;
            break;
    }
    return result;
}



@end
