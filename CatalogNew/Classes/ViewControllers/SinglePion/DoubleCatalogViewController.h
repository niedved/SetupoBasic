#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ThumbImageView.h"
#import "DBController.h"
//#import "ICETutorialController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZoomableView.h"
#import "DZWebBrowser.h"
#import "GalleryPageViewController.h"
#import "ContentButton.h"
#import "Page.h"
#import "PageViewPdf.h"

@interface DoubleCatalogViewController : UIViewController
< ThumbImageViewDelegate, UIViewControllerTransitioningDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate, UIWebViewDelegate >
{
    DBController* DBC;
    NSString        *currentImageNameLeft;
    UIScrollView    *thumbScrollView;
    CGRect leftOriginal;
    CGSize smallestSizeImg;
    
@public
    NSMutableArray* buttonsForPageUIBUTTONS;
    NSMutableArray* buttonsForPageUIBUTTONSToBGAnimate;
    NSString* nibName;
    double prop, offset_y;
    int pageW,pageH;
    
    BOOL lrdy, rrdy;
    
    float page_prop;
}

- (id)initWithNibNameIndex:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil index:(int)index;

-(void)preaparePagesFirstPage: (int)index;
-(void)preaparePagesNotFirst: (int)index;

-(void) setLeftPage : (CGRect) rect;

-(void) setRightPage : (CGRect) rect;

- (IBAction)stopAudio:(id)sender;
- (void)playAudio:(ContentButton*)contentButton;
-(void)openGallery: (int)g_id;
-(void)gotopage:(int)left;
- (void)openBrowser: (NSString*)url_string;
-(void)playMovie: (NSString*)url_string;

-(void) handleBTap:(UITapGestureRecognizer *)gestureRecognizer;

-(void)zoomEnds:(UIScrollView *)scrollView;

-(void)makeKorekcjaPoZmianieIphone:(UIDeviceOrientation) deviceOrientation;
-(void)makeKorekcjaPoZmianie:(UIDeviceOrientation) deviceOrientation;

-(void)hardcoreFixLocal: (NSString*)x;
-(void)placeButtons;

-(void)removeAllButtonsFromView;
-(void)setImageForMyImage;


-(void)ustawFrameMyImageView: (CGRect)rect;
-(void)setMinMaxCurrentZoomScale;



@property (retain, nonatomic) IBOutlet NSLayoutConstraint *myZoomViewHeight;

//- (void)canRotate;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet ZoomableView *myZoomableView;
@property (retain, nonatomic) UIImageView *myImage;
@property (retain, nonatomic) PageViewPdf *lmyImagePdf, *rmyImagePdf;
@property (retain, nonatomic) UIImageView *lmyImagePng, *rmyImagePng;

//AUDIO
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) AVURLAsset* webAvAsset;
@property (strong, nonatomic) AVPlayerItem* webPlayerItem;
@property (strong, nonatomic) AVPlayer* webAudioPlayer;
@property bool firstPage, lastPage;
@property bool zoomedLeft, zoomedRight;
@property (nonatomic, assign) int current_left_page;
@property NSUInteger pageIndex, pageIndexNew;
@property NSString *titleText;
@property NSString *imageFile, *imageFileRight;
@property Page* pageleft, *pageright;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end
