#import "DBController.h"
#import "GalleryContentViewController.h"

@interface GalleryPageViewController : UIViewController <UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, UIPageViewControllerDataSource> {
   
    DBController* DBC;
    
    
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indView;

@property (strong, nonatomic) UIPageViewController *pageViewController;
//@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSMutableArray *pageImages;
@property (strong, nonatomic) NSMutableArray *pageNeedToBeDownload;


@property int gid;
@property bool gallery_from_kiosk;
@property (strong, nonatomic) NSMutableArray* photos;

- (GalleryContentViewController *)viewControllerAtIndex:(NSUInteger)index;

- (void)canRotate;

@end