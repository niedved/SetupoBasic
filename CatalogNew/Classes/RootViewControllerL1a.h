#import "TiledScrollView.h"
#import "TapDetectingView.h"
#import "DBController.h"
#import "SingleLandscapePageCatalogViewController.h"
#import "SlideAnimation.h"
#import "AppDelegate.h"


@interface RootViewControllerL1 : UIViewController <UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, UIPageViewControllerDataSource> {
    int lastOrientation;
    SingleLandscapePageCatalogViewController* twoPageCatalogView;
    SingleLandscapePageCatalogViewController* twoPageCatalogViewNext;
    
    UIProgressView* progressV;
    UILabel* progressLabel;
    DBController* DBC;
    
    AppDelegate *appDelegate;
    
    IBOutlet UIView *loadingView;
    
    
    int ishue_id;
    
    
    //SLIDE START
    NSTimer *autoscrollTimer;  // Timer used for auto-scrolling.
    float autoscrollDistance;  // Distance to scroll the thumb view when auto-scroll timer fires.
    BOOL thumbViewShowing;
    //SLIDE END
    
}

@property (nonatomic, assign) NSDictionary* ishue_params;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indView;


//SLIDE START
@property(nonatomic, strong) UIScrollView    *thumbScrollView;
@property(nonatomic, strong) UIView          *slideUpView; // Contains thumbScrollView and a label giving credit for the images.
//SLIDE END

//@property (weak, nonatomic) IBOutlet UIView *loadingView;



@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;


- (SingleLandscapePageCatalogViewController *)viewControllerAtIndex:(NSUInteger)index;


@end