#import <AVFoundation/AVFoundation.h>
#import "DBController.h"
#import "DoubleCatalogViewController.h"
#import "SlideAnimation.h"
#import "Ishue.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>

#import "ThumbScrollView.h"
#import <MediaPlayer/MediaPlayer.h>


@interface RootViewControllerL1a : UIViewController <UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    int lastOrientation;
    
    DoubleCatalogViewController* twoPageCatalogView;
    DBController* DBC;
    int ishue_id;
    
    BOOL pageAnimationFinished;
    
    //SLIDE START
    NSTimer *autoscrollTimer;  // Timer used for auto-scrolling.
    float autoscrollDistance;  // Distance to scroll the thumb view when auto-scroll timer fires.
    BOOL thumbViewShowing;
    //SLIDE END
}

@property (nonatomic, assign) NSDictionary* ishue_params;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indView;

//SLIDE START
@property(nonatomic, strong) ThumbScrollView    *thumbScrollView;
@property(nonatomic, strong) UIView          *slideUpView; // Contains thumbScrollView and a label giving credit for the images.
//SLIDE END

//@property (weak, nonatomic) IBOutlet UIView *loadingView;


//AUDIO
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) AVURLAsset* webAvAsset;
@property (strong, nonatomic) AVPlayerItem* webPlayerItem;
@property (strong, nonatomic) AVPlayer* webAudioPlayer;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;


- (void)canRotate;

-(void)hideThumbAndNav;
- (DoubleCatalogViewController *)viewControllerAtIndex:(NSUInteger)index;



-(void) setPageLeftPageNum: (int)left;
-(void) setPageLeftPageNumSpec: (int)left;


@end