#import <QuartzCore/QuartzCore.h>
#import "RootViewControllerL1.h"
#import "TapDetectingView.h"
#import "Ishue.h"


#define THUMB_HEIGHT 120
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 2

#define AUTOSCROLL_THRESHOLD 30



@interface RootViewControllerL1 (ViewHandlingMethods)
- (void)toggleThumbView;
- (void)pickImageNamed:(NSString *)name size:(CGSize)size;
- (NSDictionary*)imageData;
- (void)createThumbScrollViewIfNecessary;
- (void)createSlideUpViewIfNecessary;
@end

@interface RootViewControllerL1 (AutoscrollingMethods)
- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb;
- (void)autoscrollTimerFired:(NSTimer *)timer;
- (void)legalizeAutoscrollDistance;
- (float)autoscrollDistanceForProximityToEdge:(float)proximity;
@end


@implementation RootViewControllerL1

@synthesize ishue_params;

- (void)loadView {
    [super loadView];
    [self hideNavigationController];
    lastOrientation = -1;
    DBC = [[DBController alloc] init];
    
    
    //PAGE MAIN
    twoPageCatalogView = [[SingleLandscapePageCatalogViewController alloc]
                          initWithNibName:@"SingleLandscapePageCatalogViewController" bundle:nil];
    twoPageCatalogView.current_left_page = 1;
    [[self view] addSubview: twoPageCatalogView.view];
    [[self view] setBackgroundColor:[UIColor blackColor]];
    [twoPageCatalogView.view bringSubviewToFront:twoPageCatalogView.viewForGestures];
    
    
    //NEXT PAGE
    twoPageCatalogViewNext = [[SingleLandscapePageCatalogViewController alloc]
                            initWithNibName:@"SingleLandscapePageCatalogViewController" bundle:nil];
    twoPageCatalogViewNext.current_left_page = 2;
    [[self view] addSubview: twoPageCatalogViewNext.view];
    [[self view] setBackgroundColor:[UIColor blackColor]];
    [twoPageCatalogViewNext.view bringSubviewToFront:twoPageCatalogViewNext.viewForGestures];
    
    
    
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setNav:[self navigationController]];

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else { // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
}

// Add this method
- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    ishue_id = appDelegate.currentIshue->ishue_id;
    // Do any additional setup after loading the view.
    // Create the data model
    _pageTitles = @[@"Over 200 Tips and Tricks", @"Discover Hidden Features", @"Bookmark Favorite Tip", @"Free Regular Update"];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];
    //    // Create page view controller
    UIStoryboard *storyboard;
// Create a new view controller and pass suitable data.
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    self.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    NSArray *viewControllers = @[twoPageCatalogView];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
   
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
    self.pageViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.pageViewController.view.layer.borderWidth = 2.0f;
    

    [self prepareTap];
    
    for (UIGestureRecognizer *recognizer in self.pageViewController.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }
    
}




-(void) prepareTap{
    [AppDelegate LogIt:@"prepareTap RootViewController"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}


-(void) handleTap:(UITapGestureRecognizer *)gestureRecognizer {    
    [AppDelegate LogIt:@"TAPED RVC!!!!"];
    [self toggleThumbView];
    
}


- (void)toggleThumbView {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    CGRect frame = [self.slideUpView frame];
    if (thumbViewShowing) {
        //        frame.origin.y += frame.size.height;
        frame.origin.y = self.view.frame.size.height;
        [appDelegate showNav];
    } else {
        //        frame.origin.y -= frame.size.height;
        frame.origin.y = self.view.frame.size.height - frame.size.height + 5;
        [appDelegate hideNav];
    }
    
    [self.view bringSubviewToFront:self.slideUpView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.slideUpView setFrame:frame];
    [UIView commitAnimations];
    
    
    thumbViewShowing = !thumbViewShowing;
}

- (void)createSlideUpViewIfNecessary {
    
    if (!self.slideUpView) {
        
        // create thumb scroll view
        [self createThumbScrollViewIfNecessary];
        
        CGRect bounds = [[self view] bounds];
        float thumbHeight = [self.thumbScrollView frame].size.height;
        float labelHeight = CREDIT_LABEL_HEIGHT;
        
        // create container view that will hold scroll view and label
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, thumbHeight + labelHeight);
        self.slideUpView = [[UIView alloc] initWithFrame:frame];
        [self.slideUpView setBackgroundColor:[UIColor whiteColor]];
        [self.slideUpView setOpaque:NO];
        [self.slideUpView setAlpha:0.85];
        [[self view] addSubview:self.slideUpView];
        
        // add subviews to container view
        [self.slideUpView addSubview:self.thumbScrollView];
        //        [self.slideUpView addSubview:creditLabel];
        //        [creditLabel release];
    }
}


- (void)createThumbScrollViewIfNecessary {
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!self.thumbScrollView) {
        
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [[self view] bounds].size.width;
        self.thumbScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        [self.thumbScrollView setBackgroundColor:nil];
        [self.thumbScrollView setCanCancelContentTouches:NO];
        [self.thumbScrollView setClipsToBounds:NO];
        
        self.thumbScrollView.layer.borderWidth = 0.5f;
        self.thumbScrollView.layer.borderColor = appDelegate.presetColorFiolet.CGColor;
        
        // now place all the thumb views as subviews of the scroll view
        // and in the course of doing so calculate the content width
        float xPosition = THUMB_H_PADDING;
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSDictionary* array = (NSDictionary*)appDelegate.currentIshue.pages;
        for (NSDictionary* page in array) {
            int page_id = [[page objectForKey:@"id"] integerValue];
            
            NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:
                                      [NSString stringWithFormat:@"thumb_%d.png", page_id]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
                NSData *imageData = [NSData dataWithContentsOfFile:fullFilePath];
                UIImage *thumbImage = [UIImage imageWithData:imageData];
                
                ThumbImageView *thumbView = [[ThumbImageView alloc] initWithImage:thumbImage];
                thumbView->imageId = page_id;
                [thumbView setDelegate:self];
                
                thumbView.layer.borderWidth = 0.5f;
                thumbView.layer.borderColor = [appDelegate presetColorFiolet].CGColor;
                
                float prop = [[page objectForKey:@"height"] floatValue] / [[page objectForKey:@"width"] floatValue];
                
                [thumbView setFrame:CGRectMake(0, 0, (THUMB_HEIGHT - THUMB_V_PADDING) / prop, (THUMB_HEIGHT - THUMB_V_PADDING) )];
                [thumbView setImageSize:CGSizeMake(200*prop, 200)];
                
                
                
                CGRect frame = [thumbView frame];
                frame.origin.y = THUMB_V_PADDING;
                frame.origin.x = xPosition;
                [thumbView setFrame:frame];
                [thumbView setHome:frame];
                [self.thumbScrollView addSubview:thumbView];
                //                [thumbView release];
                xPosition += (frame.size.width + THUMB_H_PADDING);
            }
            else{
                NSLog(@"no file");
            }
        }
        [self.thumbScrollView setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    }
}




#pragma mark Autoscrolling
/************************************** NOTE **************************************/
/* For comments on the Autoscrolling methods, please see the Autoscroll project   */
/* in this sample code suite.                                                     */
/**********************************************************************************/

- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb {
    
    autoscrollDistance = 0;
    
    if (CGRectIntersectsRect([thumb frame], [self.thumbScrollView bounds])) {
        
        CGPoint touchLocation = [thumb convertPoint:[thumb touchLocation] toView:self.thumbScrollView];
        float distanceFromLeftEdge  = touchLocation.x - CGRectGetMinX([self.thumbScrollView bounds]);
        float distanceFromRightEdge = CGRectGetMaxX([self.thumbScrollView bounds]) - touchLocation.x;
        
        if (distanceFromLeftEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromLeftEdge] * -1;
        } else if (distanceFromRightEdge < AUTOSCROLL_THRESHOLD) {
            autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromRightEdge];
        }
    }
    
    if (autoscrollDistance == 0) {
        [autoscrollTimer invalidate];
        autoscrollTimer = nil;
    }
    else if (autoscrollTimer == nil) {
        autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0)
                                                           target:self
                                                         selector:@selector(autoscrollTimerFired:)
                                                         userInfo:thumb
                                                          repeats:YES];
    }
}

- (float)autoscrollDistanceForProximityToEdge:(float)proximity {
    return ceilf((AUTOSCROLL_THRESHOLD - proximity) / 5.0);
}

- (void)legalizeAutoscrollDistance {
    float minimumLegalDistance = [self.thumbScrollView contentOffset].x * -1;
    float maximumLegalDistance = [self.thumbScrollView contentSize].width - ([self.thumbScrollView frame].size.width + [self.thumbScrollView contentOffset].x);
    autoscrollDistance = MAX(autoscrollDistance, minimumLegalDistance);
    autoscrollDistance = MIN(autoscrollDistance, maximumLegalDistance);
}

- (void)autoscrollTimerFired:(NSTimer*)timer {
    [self legalizeAutoscrollDistance];
    
    CGPoint contentOffset = [self.thumbScrollView contentOffset];
    contentOffset.x += autoscrollDistance;
    [self.thumbScrollView setContentOffset:contentOffset];
    
    ThumbImageView *thumb = (ThumbImageView *)[timer userInfo];
    [thumb moveByOffset:CGPointMake(autoscrollDistance, 0)];
}


#pragma mark ThumbImageViewDelegate
/************************************** NOTE **************************************/
/* For comments on the ThumbImageViewDelegate methods, please see the Autoscroll  */
/* project in this sample code suite.                                             */
/**********************************************************************************/
-(void) setPageLeftPageNumSpec: (int)left {
    NSLog(@"setPage : %d", left );
    //check page num for pageid
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int pagenum = 1;
    for (NSDictionary* pageInfo in appDelegate.currentIshue.pages) {
        int pageId = [[pageInfo objectForKey:@"id"] integerValue];
        if ( pageId == left ){
            break;
        }
        
        pagenum++;
    }
    
    NSLog(@"pagenum: %d", pagenum);
    
//    [self setPageLeftPageNum:pagenum right:pagenum+1];
    
}

- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv {
    NSLog(@"thumbImageViewWasTapped");
    [self pickImageNamed:[tiv imageName] size:[tiv imageSize]];
    [self toggleThumbView];
}

- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv {
    [self.thumbScrollView bringSubviewToFront:tiv];
}

- (void)thumbImageViewMoved:(ThumbImageView *)draggingThumb {
    
    [self maybeAutoscrollForThumb:draggingThumb];
    
    if (CGRectIntersectsRect([draggingThumb frame], [self.thumbScrollView bounds])) {
        BOOL draggingRight = [draggingThumb frame].origin.x > [draggingThumb home].origin.x;
        
        NSMutableArray *thumbsToShift = [[NSMutableArray alloc] init];
        
        CGPoint touchLocation = [draggingThumb convertPoint:[draggingThumb touchLocation] toView:self.thumbScrollView];
        float minX = draggingRight ? CGRectGetMaxX([draggingThumb home]) : touchLocation.x;
        float maxX = draggingRight ? touchLocation.x : CGRectGetMinX([draggingThumb home]);
        
        for (ThumbImageView *thumb in [self.thumbScrollView subviews]) {
            if (thumb == draggingThumb) continue;
            if (! [thumb isMemberOfClass:[ThumbImageView class]]) continue;
            
            float thumbMidpoint = CGRectGetMidX([thumb home]);
            if (thumbMidpoint >= minX && thumbMidpoint <= maxX) {
                [thumbsToShift addObject:thumb];
            }
        }
        
        float otherThumbShift = ([draggingThumb home].size.width + THUMB_H_PADDING) * (draggingRight ? -1 : 1);
        float draggingThumbShift = 0.0;
        
        for (ThumbImageView *otherThumb in thumbsToShift) {
            CGRect home = [otherThumb home];
            home.origin.x += otherThumbShift;
            [otherThumb setHome:home];
            [otherThumb goHome];
            draggingThumbShift += ([otherThumb frame].size.width + THUMB_H_PADDING) * (draggingRight ? 1 : -1);
        }
        
        
        
        CGRect home = [draggingThumb home];
        home.origin.x += draggingThumbShift;
        [draggingThumb setHome:home];
    }
}

- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv {
    autoscrollDistance = 0;
    [autoscrollTimer invalidate];
    autoscrollTimer = nil;
}

- (void)hideThumbView {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    CGRect frame = [self.slideUpView frame];
    
    frame.origin.y = self.view.frame.size.height;
    [appDelegate showNav];
    
    
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.slideUpView setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = NO;
}






- (NSDictionary *)imageData {
    NSDictionary* imageData = [DBC getPagesForIshue:1];
    return imageData;
}








//-(void)show{
//    NSLog(@"show");
//    [twoPageCatalogView.view bringSubviewToFront:twoPageCatalogView.viewForGestures];
//    [twoPageCatalogView viewDidAppear:YES];
//}




#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSUInteger index = ((SingleLandscapePageCatalogViewController*) viewController).pageIndex;
//    NSLog(@"index: %d", index);
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    NSLog(@"BEFORE: index: %d", index);
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    NSUInteger index = ((SingleLandscapePageCatalogViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == appDelegate.currentIshue->pagesNum/2) {
        return nil;
    }
    
    NSLog(@"AFTER: index: %lu", (unsigned long)index);
    return [self viewControllerAtIndex:index];
}


- (SingleLandscapePageCatalogViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    NSLog(@"viewControllerAtIndex: %lu / %d", (unsigned long)index, appDelegate.currentIshue->pagesNum );
 
    if (([self.pageTitles count] == 0) || (index >=  appDelegate.currentIshue->pagesNum/2)) {
        return nil;
    }
    
    UIStoryboard *storyboard;
    // Create a new view controller and pass suitable data.
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        storyboard =
        [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        storyboard =
        [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    SingleLandscapePageCatalogViewController* dupa = [[SingleLandscapePageCatalogViewController alloc]
                         initWithNibName:@"SingleLandscapePageCatalogViewController" bundle:nil];
    
//    [dupa reloadPageView];
//    [dupa setImageScrollViewLandscape];
    
    dupa.current_left_page = (index)+1;
    
    dupa.pageIndex = index;
    
    return dupa;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
//    return [self.pageTitles count];
    
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}





-(void)hideNavigationController{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)showNavigationController{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self handleOrientation: [[UIApplication sharedApplication] statusBarOrientation]];
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppera L1");
}



- (void)orientationChanged:(NSNotification *)notification{
    [self handleOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) handleOrientation:(UIInterfaceOrientation) orientation {
    NSLog(@"handleOrient");
    if ( lastOrientation == orientation ){
        return;
    }
    lastOrientation = orientation;
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
    }
}

@end