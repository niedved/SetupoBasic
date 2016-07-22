#import "RootViewControllerL1a.h"
#import "AppDelegate.h"
#import "CatalogHelper.h"
#import "NHelper.h"
#import "IssuesManager.h"

#define THUMB_HEIGHT 105
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 10
#define AUTOSCROLL_THRESHOLD 30

@interface RootViewControllerL1a (ViewHandlingMethods)
- (void)toggleThumbView;
- (void)pickImageNamed:(NSString *)name size:(CGSize)size;
- (NSDictionary*)imageData;
- (void)createThumbScrollViewIfNecessary;
- (void)createSlideUpViewIfNecessary;
@end

@interface RootViewControllerL1a (AutoscrollingMethods)
- (void)maybeAutoscrollForThumb:(ThumbImageView *)thumb;
- (void)autoscrollTimerFired:(NSTimer *)timer;
- (void)legalizeAutoscrollDistance;
- (float)autoscrollDistanceForProximityToEdge:(float)proximity;
@end

@implementation RootViewControllerL1a

@synthesize ishue_params;

- (void)canRotate{};

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.pageViewController.view setNeedsLayout];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    NSLog(@"viewWillTransitionToSize Root: %f,%f", size.width, size.height );
    if( [NHelper isIphone] ){
        [self orientationChangedIphone];
    }
    else if( [IssuesManager sharedInstance].currentIssue->forceOnePagePerView ){
        [self orientationChangedIpadOnePage];
    }
    else{
        [self orientationChangedIpad];
    }
}


-(void)orientationChangedIpadOnePage{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    DoubleCatalogViewController *theCurrentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [theCurrentViewController makeKorekcjaPoZmianie:[UIDevice currentDevice].orientation];
    [self correctThumb:appDelegate->orientPion];
    [appDelegate fixNav];
    appDelegate->orientPion = ![NHelper isLandscapeInReal];
}

-(void)orientationChangedIphone{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    DoubleCatalogViewController *theCurrentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [theCurrentViewController hardcoreFixLocal: @"RVC121"];
    [theCurrentViewController removeAllButtonsFromView];
    [theCurrentViewController placeButtons];
    [self correctThumb:appDelegate->orientPion];
    [appDelegate fixNav];
    appDelegate->orientPion = ![NHelper isLandscapeInReal];
}

-(void)orientationChangedIpad{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    DoubleCatalogViewController *theCurrentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [theCurrentViewController makeKorekcjaPoZmianie:[UIDevice currentDevice].orientation];
    
    CGRect myZoomableViewRect = theCurrentViewController.myZoomableView.frame;
    float prop = 0;
    
    if ( appDelegate->orientPion ){
        double propW = myZoomableViewRect.size.width / theCurrentViewController->pageW;
        double propH = myZoomableViewRect.size.height / theCurrentViewController->pageH;
        prop = (propW < propH) ? propW : propH;
    }
    else{
        double propW = myZoomableViewRect.size.width/2 / theCurrentViewController->pageW;
        double propH = myZoomableViewRect.size.height / theCurrentViewController->pageH;
        prop = (propW < propH) ? propW : propH;
        
    }
    
    float offset_y = (myZoomableViewRect.size.height - theCurrentViewController->pageH*prop) / 2;
    
    myZoomableViewRect.origin.y = offset_y;
    theCurrentViewController.myImage.frame = myZoomableViewRect;
    
    if ( theCurrentViewController.firstPage && !appDelegate->orientPion ) {
        CGRect frame = theCurrentViewController.myImage.frame;
        frame.origin.x = frame.origin.x - 1024/4;
        theCurrentViewController.myImage.frame = frame;
        [theCurrentViewController.myImage setFrame:frame];
    }
    else if( theCurrentViewController.current_left_page == [appDelegate.currentIshue.pages count] && !appDelegate->orientPion ){
        CGRect frame = theCurrentViewController.myImage.frame;
        frame.origin.x = frame.origin.x + 1024/4;
        [theCurrentViewController.myImage setFrame:frame];
    }
    else{
        
    }
    
    //appDelegate
    NSLog(@"orientpion: %d", appDelegate->orientPion );
    [self correctThumb:appDelegate->orientPion];
    
    [theCurrentViewController placeButtons];
    [appDelegate fixNav];
    [theCurrentViewController hardcoreFixLocal: @"RVC121"];
}


-(void)correctThumb :(bool)is_port{
    CGRect frame = [self.slideUpView frame];
    
    if (!thumbViewShowing) {
        frame.origin.y = 1024;
        [self.slideUpView setFrame:frame];
    }
    else{
        NSLog(@" THUMB SHOWED: port:%d", is_port );
        CGRect rect = self.thumbScrollView.frame;
        
        if( is_port ){
            frame.origin.y = 1024 - frame.size.height + 5;
            frame.size.width = 768.0f;
            rect.size.width = 768.0f;
        }
        else{
            frame.origin.y = 768 - frame.size.height + 5;
            frame.size.width = 1024.0f;
            rect.size.width = 1024.0f;
        }
        [self.thumbScrollView setFrame:rect];
        [self.slideUpView setFrame:frame];
    }
    
    int currentIndex = (int)((DoubleCatalogViewController *)[self.pageViewController.viewControllers objectAtIndex:0]).pageIndex;
    
    [self oznaczThumbsa:currentIndex];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        NSLog(@"go back");
        [appDelegate hideNavigNoAnim];
        
        [self hideThumbAndNav];
        appDelegate.appStage = 1;
    }
    
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavigNoAnim];
    [appDelegate hideNavigNoAnim];

    [appDelegate.bTopShare setHidden:NO];
    [appDelegate.bTopBookMark setHidden:NO];
    [appDelegate fixNav];
    [self hideThumbAndNav];
    if ( appDelegate.reloadViewAfterReturn ){
        appDelegate.reloadViewAfterReturn = NO;
        DoubleCatalogViewController *theCurrViewController =
            [self.pageViewController.viewControllers objectAtIndex:0];
        [theCurrViewController makeKorekcjaPoZmianie:[UIDevice currentDevice].orientation];
    }
    
    
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    appDelegate.appStage = 4;
    [appDelegate fixNav];
    if ( appDelegate.forcePageNum > 0 ){
        [self setPageLeftPageNumSpec:appDelegate.forcePageNum];
        appDelegate.forcePageNum = -1;
    }
    
    int currentIndex = (int)((DoubleCatalogViewController *)[self.pageViewController.viewControllers objectAtIndex:0]).pageIndex;
    [self oznaczThumbsa:currentIndex];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowAllOrients = NO;
    
    [appDelegate hideFadeAnim:.25 delay:0.0];
    if( appDelegate.bookmarksActive ){
        appDelegate.bookmarksActivePro = YES;
    }
    
    [twoPageCatalogView hardcoreFixLocal: @"Root295"];
    [appDelegate setBackButtonImage];
    
    
}

- (void)loadView {
    [super loadView];
    [self hideNavigationController];
    DBC = [[DBController alloc] init];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [self goLand];
}




-(void)fitSizeAutoViewInsideView: (UIView*)addedView mainView: (UIView*)mainView {
    //Using autolayout to position the modal view
    NSArray *_constraints;
    addedView.translatesAutoresizingMaskIntoConstraints = NO;
    [mainView  addSubview:addedView];
    NSDictionary *views = NSDictionaryOfVariableBindings(mainView, addedView);
    _constraints = [[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[addedView]-0-|" options:0 metrics:nil views:views] arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[addedView]-0-|" options:0 metrics:nil views:views]];
    [mainView  addConstraints:_constraints];
}



-(void)goLand{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate->orientPion = ![NHelper isLandscapeInReal];
    
    
    
   
        twoPageCatalogView = [[DoubleCatalogViewController alloc]
                              initWithNibNameIndex:[NHelper isIphone] ?  @"DoubleCatalogViewControllerIphone" : @"DoubleCatalogViewController" bundle:nil index:0];
    

    [appDelegate setNav:[self navigationController]];
}

// Add this method
- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"RootViewControllerL1a: viewDidLoad A");
    self.view.backgroundColor = appDelegate.presetBackgroundColor;
    ishue_id = appDelegate.currentIshue->ishue_id;
    NSLog(@"RootViewControllerL1a: viewDidLoad B");
    
    
    
    
    
    UIPageViewControllerTransitionStyle style = UIPageViewControllerTransitionStylePageCurl;
    switch( appDelegate.currentIshue->swipe_type ){
        case 1: style = UIPageViewControllerTransitionStylePageCurl; break;
        case 2: style = UIPageViewControllerTransitionStyleScroll; break;
        default: style = UIPageViewControllerTransitionStyleScroll; break;
    }
    
    
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:style navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    appDelegate.pageViewController = self.pageViewController;
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    NSArray *viewControllers = @[twoPageCatalogView];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:_pageViewController];
    [self fitSizeAutoViewInsideView:_pageViewController.view mainView:self.view];
  
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    
    [self prepareTap];
    for (UIGestureRecognizer *recognizer in self.pageViewController.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }
    
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    NSLog(@"RootViewControllerL1a: viewDidLoad END");
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    pageAnimationFinished = YES;
    appDelegate.rootViewController = self;
    
    
}



-(void) prepareTap{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delegate = self;
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
   [singleTap requireGestureRecognizerToFail:doubleTap];
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *view = touch.view;
    while (view.class != UIView.class) {
        // Check if superclass is of type dropdown
        if ( view.tag == 666 ) { // dropDown is an ivar; replace with your own
            NSLog(@"Is of type dropdown; returning NO");
            return NO;
        } else {
            view = view.superview;
        }
    }
    return YES;
}

-(void)zoomToLeftPage{
    twoPageCatalogView.zoomedLeft = YES;
    twoPageCatalogView.zoomedRight = NO;
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ){
        
    [UIView animateWithDuration:0.5 delay:0.0 options:
     UIViewAnimationOptionAllowUserInteraction animations:^{
         [twoPageCatalogView.scrollView setZoomScale:2.0 animated:NO];
         if ( twoPageCatalogView.current_left_page == 0 )
             twoPageCatalogView.scrollView.contentOffset = CGPointMake(1024/2, 0);
         else{
             twoPageCatalogView.scrollView.contentOffset = CGPointMake(0, 0);
         }
     }
                     completion:nil];
    }
    else{
        [twoPageCatalogView.scrollView setZoomScale:2.0 animated:YES];
        if ( twoPageCatalogView.current_left_page == 0 )
            twoPageCatalogView.scrollView.contentOffset = CGPointMake(1024/2, 0);
        else{
            twoPageCatalogView.scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
}

-(void)zoomToRightPage{
    twoPageCatalogView.zoomedLeft = NO;
    twoPageCatalogView.zoomedRight = YES;
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ){
        [UIView animateWithDuration:0.5 delay:0.0 options:
         UIViewAnimationOptionAllowUserInteraction animations:^{
             [twoPageCatalogView.scrollView setZoomScale:2.0 animated:NO];
             if ( twoPageCatalogView.current_left_page == 0 )
                 twoPageCatalogView.scrollView.contentOffset = CGPointMake(1024/2, 0);
             else{
                 twoPageCatalogView.scrollView.contentOffset = CGPointMake(1024, 0);
             }
             
         }
        completion:nil];
    }
    else{
        [twoPageCatalogView.scrollView setZoomScale:2.0 animated:YES];
        if ( twoPageCatalogView.current_left_page == 0 )
            twoPageCatalogView.scrollView.contentOffset = CGPointMake(1024/2, 0);
        else{
            twoPageCatalogView.scrollView.contentOffset = CGPointMake(1024, 0);
        }
    }
}

-(void)handleDoubleTapZoomIn: (float)point{
    float prop = point / twoPageCatalogView.scrollView.contentSize.width;
    
    if ( prop <= 0.5 ){
        [self zoomToLeftPage];
    }
    else{
        [self zoomToRightPage];
    }
    
    [twoPageCatalogView zoomEnds:twoPageCatalogView.scrollView];
}
-(void)handleDoubleTapZoomOut{
    [twoPageCatalogView.scrollView setZoomScale:1.0 animated:YES];
    twoPageCatalogView.zoomedLeft = NO;
    twoPageCatalogView.zoomedRight = NO;
    [twoPageCatalogView zoomEnds:twoPageCatalogView.scrollView];
}

-(void) handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    if( !pageAnimationFinished ){
        return;
    }
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[NHelper platformSpeed] isEqualToString:@"vs"]){
        if( !appDelegate->alldone ){
            return;
        }
        NSLog(@"alldone: %d", appDelegate->alldone  );
    }
    
    if ([[NHelper platformSpeed] isEqualToString:@"vvs"]){
        if( !appDelegate->alldone ){
            return;
        }
        NSLog(@"alldone: %d", appDelegate->alldone  );
    }
    
    
    
    if ( appDelegate->orientPion ){
        return;
    }
    
    if ( [NHelper isIphone] ){
        return;
    }
    
    
    
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint offset = twoPageCatalogView.scrollView.contentOffset;
    
    if ( twoPageCatalogView.scrollView.zoomScale < 2.0 ){
        [self handleDoubleTapZoomIn:location.x + offset.x];
    }
    else{
        [self handleDoubleTapZoomOut];
    }
}

-(void) handleTap:(UITapGestureRecognizer *)gestureRecognizer {    
    [AppDelegate LogIt:@"TAPED RVC!!!!"];
    [self toggleThumbView];
}

-(void) thumbExtra{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ( [appDelegate checkBookmarkExist:twoPageCatalogView.pageleft.pageid ] ){
        [appDelegate setupBookmarkButton: NO pageid:twoPageCatalogView.pageleft.pageid];
    }
    else{
        [appDelegate setupBookmarkButton: YES pageid:twoPageCatalogView.pageleft.pageid];
    }
    
    int currentIndex = (int)((DoubleCatalogViewController *)[self.pageViewController.viewControllers objectAtIndex:0]).pageIndex;
    [self oznaczThumbsa:currentIndex];
}

- (void)toggleThumbView {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ( !appDelegate.thumbBlocked ){
        [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
        
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [[self view] bounds].size.width;
        [self.slideUpView setFrame:CGRectMake(self.slideUpView.frame.origin.x, self.slideUpView.frame.origin.y, scrollViewWidth, scrollViewHeight)];
        [self.thumbScrollView setBackgroundColor:[UIColor greenColor]];
        
        [self.thumbScrollView setFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        [self.thumbScrollView setBackgroundColor:[UIColor clearColor]];
        [self.thumbScrollView setCanCancelContentTouches:NO];
        [self.thumbScrollView setClipsToBounds:NO];
        
        CGRect frame = [self.slideUpView frame];
        if (thumbViewShowing) {
            frame.origin.y = 1024;//self.view.frame.size.height;
            [appDelegate hideNavig];
        } else {
            frame.origin.y = self.view.frame.size.height - frame.size.height + 5;
            [appDelegate showNavig];
            
            [self thumbExtra];
        }
        
        [self.view bringSubviewToFront:self.slideUpView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [self.slideUpView setFrame:frame];
        [UIView commitAnimations];
        
        thumbViewShowing = !thumbViewShowing;
    }
}

-(void)oznaczThumbsa:(int)index{
    NSLog(@"oznaczThumbsa START");
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    DoubleCatalogViewController* dcvc = ((DoubleCatalogViewController *)[self.pageViewController.viewControllers objectAtIndex:0]);
    
    NSArray* subs = [self.thumbScrollView subviews];
    int vNum = 0;
    for (ThumbImageView *thumbView in subs) {
        if( thumbView.frame.size.height == 95 && thumbView.frame.size.width >= 40 ){
            
            //            if ( )
            if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                ([UIScreen mainScreen].scale == 2.0)) {
                // Retina display
                thumbView.layer.borderWidth = 0.5f;
            } else {
                // non-Retina display
                thumbView.layer.borderWidth = 1.0f;
            }
            
            
            thumbView.layer.borderColor = [NHelper colorFromPlist:@"thumbborder"].CGColor;
            
            if ( appDelegate->orientPion ){
                [self setPositionPion:dcvc thumbView:thumbView vNum:vNum];
            }
            else{
                [self setPositionPoziom: dcvc thumbView:thumbView vNum:vNum];
            }
            
            vNum++;
        }
    }
    NSLog(@"oznaczThumbsa END");
}


-(void)setPositionPion: (DoubleCatalogViewController*)dcvc thumbView:(ThumbImageView*)thumbView vNum:(int)vNum{
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    
    if ( dcvc.pageleft.pageid == thumbView->imageId ){
        thumbView.layer.borderWidth = 2.0f;
        NSLog( @"vnum: %d", vNum );
        if( vNum < 2 ){
            [self.thumbScrollView setContentOffset:CGPointMake(0 ,0) animated:YES];
        }
        else if( vNum >  [appDelegate.currentIshue.pages count] - 5 ){
            float x = (self.thumbScrollView.contentSize.width - CGRectGetWidth(self.thumbScrollView.frame));
            [self.thumbScrollView setContentOffset:CGPointMake(x ,0) animated:YES];
        }
        else{
            [self.thumbScrollView setContentOffset:CGPointMake((thumbView.frame.origin.x-size.width/2+35) ,0) animated:YES];
        }
    }
}


-(void)setPositionPoziom: (DoubleCatalogViewController*)dcvc thumbView:(ThumbImageView*)thumbView vNum:(int)vNum{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
   
    
    if ( dcvc.pageright.pageid == thumbView->imageId ){
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            // Retina display
            thumbView.layer.borderWidth = 2.5f;
        } else {
            // non-Retina display
            thumbView.layer.borderWidth = 2.0f;
        }
        
    }
    if ( dcvc.pageleft.pageid == thumbView->imageId ){
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            // Retina display
            thumbView.layer.borderWidth = 2.5f;
        } else {
            // non-Retina display
            thumbView.layer.borderWidth = 2.0f;
        }
        NSLog( @"vnum: %d", vNum );
        if( vNum < 7 ){
            [self.thumbScrollView setContentOffset:CGPointMake(0 ,0) animated:YES];
        }
        else if( vNum >  [appDelegate.currentIshue.pages count] - 7 ){
            float x = (self.thumbScrollView.contentSize.width - CGRectGetWidth(self.thumbScrollView.frame));
            [self.thumbScrollView setContentOffset:CGPointMake(x ,0) animated:YES];
        }
        else{
            
            [self.thumbScrollView setContentOffset:CGPointMake((thumbView.frame.origin.x-size.width/2+75) ,0) animated:YES];
        }
    }
}

-(void)hideThumbAndNav{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self createSlideUpViewIfNecessary]; // no-op if slideUpView has already been created
    CGRect frame = [self.slideUpView frame];
    if (thumbViewShowing) {
        frame.origin.y = 1024;
        [appDelegate hideNavig];
    }
    [self.view bringSubviewToFront:self.slideUpView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.slideUpView setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = NO;
}

- (void)createSlideUpViewIfNecessary {
//    NSLog(@"createSlideUpViewIfNecessary START");
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!self.slideUpView) {
        appDelegate.xxxSlideUpView = self.slideUpView;
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
        [self.slideUpView setAlpha:0.95];
        [[self view] addSubview:self.slideUpView];
        // add subviews to container view
        [self.slideUpView addSubview:self.thumbScrollView];
    }
//    NSLog(@"createSlideUpViewIfNecessary END");
}

-(void)setThumbsImagesForVisibleThumbs: (int)currentPage delta:(int)delta myScrollView:(UIScrollView *)myScrollView{
    for( int i=0; i<delta; i++){
        if ( [myScrollView viewWithTag:(currentPage+i)] ) {
            ThumbImageView* thv = (ThumbImageView*)[myScrollView viewWithTag:(currentPage+i)];
            if( !thv->imaged ){
                if( [thv isKindOfClass:[ThumbImageView class]] ){
                    [thv setThumbWithImage:currentPage+i ishue_id:ishue_id];
                }
            }
        }
        else {
            NSLog(@"no thum with tag");
            // view is missing, create it and set its tag to currentPage+1
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)myScrollView {
    // calculate the current page that is shown
    int currentPage = (myScrollView.contentOffset.x / 80 )+1;
    [self setThumbsImagesForVisibleThumbs:currentPage delta:15 myScrollView:myScrollView];
    
    for ( int i = 1; i <= currentPage; i++ ) {
        if (  (i < (currentPage-10) || i > (currentPage+16)) ) {
            if ( [myScrollView viewWithTag:(i)] ) {
                ThumbImageView* thv = (ThumbImageView*)[myScrollView viewWithTag:(i)];
                if( thv->imaged ){
                    thv->imaged = NO;
                    thv.image = nil;
                }
            }
        }
    }
}

- (void)createThumbScrollViewIfNecessary {
    NSLog(@"createThumbScrollViewIfNecessary START");
    if (!self.thumbScrollView) {
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [[self view] bounds].size.width;
        self.thumbScrollView = [[ThumbScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        self.thumbScrollView.delegate = self;
        
        [self.thumbScrollView preapreColectionOfEmptyThumbViews];
        [self scrollViewDidScroll:self.thumbScrollView];
    }
    NSLog(@"createThumbScrollViewIfNecessary END");
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


-(void) setPageLeftPageNum: (int)left
{
    __weak UIPageViewController* pvcw = self.pageViewController;
    DoubleCatalogViewController* page = [self viewControllerAtIndex:left-1];
    twoPageCatalogView = page;
    [self.pageViewController setViewControllers:@[page]
                  direction:UIPageViewControllerNavigationDirectionForward
                   animated:NO completion:^(BOOL finished) {
                       UIPageViewController* pvcs = pvcw;
                       if (!pvcs) return;
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [pvcs setViewControllers:@[page]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO completion:nil];
                       });
                   }];
    
}

-(void) setPageLeftPageNumSpec: (int)left {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Page* pagetoshow = [[Page alloc] initWithPageId:left issue:appDelegate.currentIshue];
    [self setPageLeftPageNum:[pagetoshow getPageViewNum]];
    [self thumbExtra];
}

//CZY TU WCHODZIMY
- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv {
    NSLog(@"thumbImageViewWasTapped");
    
    NSLog(@"=>%@ size: %f %f", [tiv imageName], [tiv imageSize].width, [tiv imageSize].height );
    if ( [tiv imageName] != nil && [tiv imageName] != [NSNull null] ){
        [self pickImageNamed:[tiv imageName] size:[tiv imageSize]];
        [self toggleThumbView];
        [self thumbExtra];
    }
    else{
        NSLog(@"dupa");
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
    
    frame.origin.y = 1024;//self.view.frame.size.height;
    [appDelegate hideNavig];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.slideUpView setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = NO;
}

#pragma mark - Page View Controller Data Source
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.pageCurlAnimationInProgress = YES;
    pageAnimationFinished = NO;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *vc = [pageViewController.viewControllers lastObject];
    twoPageCatalogView = (DoubleCatalogViewController*)vc;
    pageAnimationFinished = YES;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    if( !pageAnimationFinished ){
        NSLog(@"ANIMACJA WCIAZ TRWA");
        return nil;
    }
    
    if ( ((DoubleCatalogViewController*)viewController).scrollView.zoomScale >= 1.05000 ){
        NSLog(@"NIE MA !!!!! KUZWA ZOOM EJST");
        return nil;
    }
    
    NSLog(@"scale: %f", ((DoubleCatalogViewController*)viewController).scrollView.zoomScale );
    ((DoubleCatalogViewController*)viewController).scrollView.contentSize = ((DoubleCatalogViewController*)viewController).myImage.frame.size;
    
    if ( ((DoubleCatalogViewController*)viewController).scrollView.zoomScale <= 1.05000 ){
        [self hideThumbAndNav];
    }
    
    NSUInteger index = ((DoubleCatalogViewController*) viewController).pageIndex;
    NSLog(@"index:%lu", index );
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    NSLog(@"BEFORE: index: %lu", (unsigned long)index);
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.currentIshue->orientation = 0;
    if ( appDelegate.currentIshue->orientation == 0 ){
        return [self viewControllerAtIndex:index];
    }
//    else if ( appDelegate.currentIshue->orientation == 1 ){
//        return [self viewControllerAtIndexTwo:index];
//    }
    else{
        return [self viewControllerAtIndex:index];
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    if( !pageAnimationFinished ){
        NSLog(@"ANIMACJA WCIAZ TRWA AFTER");
        return nil;
    }

    if ( ((DoubleCatalogViewController*)viewController).scrollView.zoomScale >= 1.05000 ){
        NSLog(@"NIE MA !!!!! KUZWA ZOOM EJST AFTER");
        return nil;
    }
    if ( ((DoubleCatalogViewController*)viewController).scrollView.zoomScale <= 1.05000 ){
        [self hideThumbAndNav];
    }
    NSUInteger index = ((DoubleCatalogViewController*) viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if (index == appDelegate.currentIshue->pagesNum) {
        return nil;
    }
    
    NSLog(@"AFTER: index: %lu", (unsigned long)index);
    
    appDelegate.currentIshue->orientation = 0;
    if ( appDelegate.currentIshue->orientation == 0 ){
        return [self viewControllerAtIndex:index];
    }
    else{
        return [self viewControllerAtIndex:index];
    }
}

- (DoubleCatalogViewController *)viewControllerAtIndex:(NSUInteger)index
{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (index >=  appDelegate.currentIshue->pagesNum && appDelegate->orientPion) {
        return nil;
    }
    if( index >= appDelegate.currentIshue->pagesNum &&  appDelegate.currentIshue->forceOnePagePerView ){
        return nil;
    }
    
    if (index >  appDelegate.currentIshue->pagesNum/2 && !appDelegate->orientPion) {
        return nil;
    }
    
    UIStoryboard *storyboard;
    // Create a new view controller and pass suitable data.
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) {
        storyboard =
            [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        storyboard =
        [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    //    logIssuePageSlidedPageId
    
    DoubleCatalogViewController* dupa = [[DoubleCatalogViewController alloc] initWithNibNameIndex:
                                         [NHelper isIphone] ?  @"DoubleCatalogViewControllerIphone" : @"DoubleCatalogViewController" bundle:nil index:index];
    
    NSLog(@"DODAJ DO LOGSA: %d slide palcem", index);
    [[IssuesManager sharedInstance] logIssuePageSlidedPage:dupa.pageleft pageright:dupa.pageright];
    return dupa;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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
@end
