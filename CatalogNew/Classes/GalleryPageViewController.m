#import <QuartzCore/QuartzCore.h>
#import "GalleryPageViewController.h"
#import "GalleryPhoto.h"
#import "AppDelegate.h"
#import "NHelper.h"

@implementation GalleryPageViewController{
    
    AppDelegate *appDelegate;
}
@synthesize gid;
// Add this method
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)canRotate{};

-(void)setPhotos{
    _pageImages = [[NSMutableArray alloc] init];
//    NSLog(@"photos: %@", self.photos);
    for (GalleryPhoto* button in self.photos) {
 //       NSLog(@"name: %@ exist: %d", button.name, button.fileexist );
        [_pageImages addObject:button.name];
        if ( !button.fileexist ){
            [self.pageNeedToBeDownload addObject:button.name];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
    [appDelegate hideNavig];
}




-(void)viewWillAppear:(BOOL)animated{
    appDelegate.appStage = 8;
    
    NSLog(@"viewWillApear");
    [appDelegate setNav:[self navigationController]];
    [appDelegate.bTopShare setHidden:NO];
    [appDelegate.bTopBookMark setHidden:YES];
    [appDelegate fixNav];
    [self setPhotos];
    if ([self.pageNeedToBeDownload count] && NO ){
        NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Some photos need to by download.", nil)];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:msg
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"NO"
                                                otherButtonTitles:@"YES", nil];
        
        [message show];
        
        
    }
    else{
        if( [self.photos count] > 0){
            [self dupa];
        }
    }
    
    [appDelegate hideNavigNoAnim];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self handleOrientation: [[UIApplication sharedApplication] statusBarOrientation]];
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    ishue_id = appDelegate.currentIshue->ishue_id;
    // Do any additional setup after loading the view.
    // Create the data model
    
    //    // Create page view controller
    UIStoryboard *storyboard;
    // Create a new view controller and pass suitable data.
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        
        
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    
    self.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"GalleryPageController"];
    self.pageViewController.dataSource = self;
    self.pageNeedToBeDownload = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.topItem.title = @"";
    //    [self dupa];
    
}


-(void) dupa{
    GalleryContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSUInteger index = ((GalleryContentViewController*) viewController).pageIndex;
//    NSLog(@"index: %d", index);
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
//    NSLog(@"BEFORE: index: %d", index);
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    NSUInteger index = ((GalleryContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImages count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}


- (GalleryContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
//    NSLog(@"viewControllerAtIndex: %lu / %d", (unsigned long)index, appDelegate.currentIshue->pagesNum );
 
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    UIStoryboard *storyboard;
    // Create a new view controller and pass suitable data.
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    GalleryContentViewController* pageContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"GalleryContentViewController"];

    
    
    pageContentViewController.imageFile = self.pageImages[index];
//    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
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

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidApperaG");
    appDelegate.reloadViewAfterReturn = YES;
    
    
}

- (void)orientationChanged:(NSNotification *)notification{
        [self handleOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) handleOrientation:(UIInterfaceOrientation) orientation {
    NSLog(@"handleOrient");
    
}

@end