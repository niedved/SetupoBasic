
#import <UIKit/UIKit.h>
#import "TiledScrollView.h"
#import "ThumbImageView.h"
#import "TapDetectingView.h"
#import "DBController.h"
#import "ICETutorialController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SingleLandscapePageCatalogViewController : UIViewController<TiledScrollViewDataSource, ThumbImageViewDelegate, TapDetectingViewDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate,AVAudioPlayerDelegate>
{
    
    DBController* DBC;
    NSString        *currentImageNameLeft;
    
    UIScrollView    *thumbScrollView;
    CGRect leftOriginal;
    
    CGSize smallestSizeImg;
    
}

-(void) reloadPageView;

- (void)pickImageNamedLeft:(NSString *)name;
- (bool)prepareLeftRightNum: (int)left_num;
- (void)placeButtons;
-(void)setImageScrollViewLandscape;

//@property(nonatomic, strong) UIScrollView    *thumbScrollView;
//@property(nonatomic, strong) UIView          *slideUpView; // Contains thumbScrollView and a label giving credit for the images.

@property(nonatomic, strong) TiledScrollView *imageScrollViewLeft;
@property(nonatomic, strong) IBOutlet UIView *viewForGestures;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet UISlider *volumeControl;
@property (strong, nonatomic) ICETutorialController *iceViewController;
@property (nonatomic, assign) int current_left_page;
@property (nonatomic, assign) int current_right_page;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) AVURLAsset* webAvAsset;
@property (strong, nonatomic) AVPlayerItem* webPlayerItem;
@property (strong, nonatomic) AVPlayer* webAudioPlayer;


@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;


@end
