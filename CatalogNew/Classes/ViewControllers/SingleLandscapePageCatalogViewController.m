//
//  TwoPageCatalogViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 07.02.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SingleLandscapePageCatalogViewController.h"
#import "TapDetectingView.h"
#import "ContentButton.h"
#import "DZWebBrowser.h"
#import "AppDelegate.h"
#import "GalleryViewController.h"
#import "GalleryPageViewController.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define THUMB_HEIGHT 120
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 2

#define AUTOSCROLL_THRESHOLD 30


@interface SingleLandscapePageCatalogViewController (UtilityMethods)
- (CGRect)zoomRectForScaleLeft:(float)scale withCenter:(CGPoint)center;
@end


@interface SingleLandscapePageCatalogViewController ()

@end

@implementation SingleLandscapePageCatalogViewController

@synthesize  webAudioPlayer, webAvAsset, webPlayerItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        }
    return self;
}

-(void)setLeftSV{
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    CGRect frameForUIS;
    frameForUIS.size.height = height;
    frameForUIS.size.width = width;
    frameForUIS.origin.x = 0;
    frameForUIS.origin.y = 0;
    self.view.layer.borderWidth = 0.0f;
    self.view.layer.borderColor = [UIColor greenColor].CGColor;
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = appDelegate.currentIshue->bg;
    
    [self.imageScrollViewLeft setTileSize:CGSizeMake(250, 250)];
    [self.imageScrollViewLeft setBouncesZoom:YES];
    [self.imageScrollViewLeft setMaximumResolution:0];
    [self.imageScrollViewLeft setMinimumResolution:-1];
    self.imageScrollViewLeft.backgroundColor = [UIColor clearColor];
    self.imageScrollViewLeft.frame = frameForUIS;
    self.imageScrollViewLeft.tag = 1;
        //@todo img size here
    [self pickImageNamedLeft:[NSString stringWithFormat:@"%d", self.current_left_page]];
}

-(void)setImageScrollViewLandscape{
    [self setLeftSV];
    //dostosuj height
    int hL = self.imageScrollViewLeft.tileContainerView.frame.size.height;
    CGRect sr = [[UIScreen mainScreen] bounds];
//    int hX = self.view.frame.size.height;
    
    int dif = sr.size.width - hL;
    
    CGRect frame =
        CGRectMake(self.imageScrollViewLeft.frame.origin.x, (int)(dif/2), self.imageScrollViewLeft.frame.size.width, hL);
    [self.imageScrollViewLeft setFrame:frame];
    
    
}



-(void)placeButtons{
    
    NSMutableArray* buttonsL = [self.imageScrollViewLeft prepareButtons:@"left" ];
    for (ContentButton* button in buttonsL) {
        [self.imageScrollViewLeft placeButton:button leftOrRight:@"left"];
    }
}


-(void) prepareTap{
    NSLog(@"prepareTap");
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}


- (UIView*)pointInsideActiveView:(CGPoint)point{
    NSArray* subV = [self.imageScrollViewLeft subviews];
    for (UIView* vtemp in subV) {
        if ( vtemp.tag > 0 ){
            if( CGRectContainsPoint(vtemp.frame, point) ){
                return  vtemp;
            }
        }
    }

    
    if ( self.imageScrollViewLeft.isInReadyToResizeMode == 0 ){
        if (
            ( [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft )
            ||
            ( [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight )
            )
        {
            NSLog(@"2 page mode landscape");
            if ( point.x >= self.imageScrollViewLeft.frame.origin.x )
                point = CGPointMake(point.x - self.imageScrollViewLeft.frame.origin.x, point.y);
            
            
        }
    
        

    }
    
    
   
    
    
    
    return nil;
}

- (IBAction)adjustVolume:(id)sender {
    if (_audioPlayer != nil)
    {
        _audioPlayer.volume = _volumeControl.value;
    }
}

-(NSString*)pathToVideoFile:(NSString*)fulllink{
    //    "Resources/video/21/20.mp4" => 20.mp4
    NSArray *chunks = [fulllink componentsSeparatedByString: @"/"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* videoNameFile = [chunks lastObject];
    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:videoNameFile];
    return fullFilePath;
}


- (void)playAudio:(ContentButton*)contentButton {
    NSString* filename = contentButton.action;
    NSString* path = [self pathToVideoFile:filename];
    NSLog(@"PLAY AUDIO: %@", path);
    if (![filename isEqual:[NSNull null]] && filename.length > 0 ){
        NSURL *url = nil;
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        NSLog(@"PLAY AUDIO OFFLINE: exist: %d", fileExist);
        if ( fileExist){
            url = [NSURL fileURLWithPath:path];
    
            //LOCAL FILE
            NSError *error;
            _audioPlayer = [[AVAudioPlayer alloc]
                            initWithContentsOfURL:url
                            error:&error];
            if (error)
            {
                NSLog(@"Error in audioPlayer: %@",
                      [error localizedDescription]);
            } else {
                _audioPlayer.delegate = self;
                [_audioPlayer prepareToPlay];
            }
            
            [_audioPlayer play];
            
        }
        else{
            NSLog(@"PLAY AUDIO ONLINE");
            
            url = [NSURL URLWithString:
                   [NSString stringWithFormat:@"http://ygd13959497c.arfixer.eu/setupo_cms/%@", filename]];
        
            NSLog(@"PLAY AUDIO: url %@",
              [NSString stringWithFormat:@"http://ygd13959497c.arfixer.eu/setupo_cms/%@", filename]);
            if ( [self.webAudioPlayer rate] == 0.0 ){
//            NSURL *url = [NSURL URLWithString:url];
                self.webAvAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                self.webPlayerItem = [AVPlayerItem playerItemWithAsset:self.webAvAsset];
                self.webAudioPlayer = [AVPlayer playerWithPlayerItem:self.webPlayerItem];
                [self.webAudioPlayer play];
            }
            else{
                [self.webAudioPlayer pause];
            }
        }
        
        
    }
    else{
        NSLog(@"Audio have no data");
    }
}


- (IBAction)stopAudio:(id)sender {
    [_audioPlayer stop];
}


-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag{
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player{
}


-(void)playMovie: (NSString*)url_string{
    [_moviePlayer.view removeFromSuperview];
    
//    NSString* filename = contentButton.action;
    NSString* path = [self pathToVideoFile:url_string];
    NSLog(@"PLAY VIDEO: %@", path);
    if (![url_string isEqual:[NSNull null]] && url_string.length > 0 ){
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
        if ( fileExist ){
            NSLog(@"PLAY VIDEO OFFLINE: %@", url_string );
            NSURL *url = [NSURL fileURLWithPath:path];
            
            _moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(moviePlayBackDidFinish:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:_moviePlayer];
            
            _moviePlayer.controlStyle = MPMovieControlStyleDefault;
            _moviePlayer.shouldAutoplay = YES;
            [self.view addSubview:_moviePlayer.view];
            [_moviePlayer setFullscreen:YES animated:YES];
        }
        else{
            NSLog(@"PLay online");
            
//            NSLog(@"urlstring: %@", url_string );
//            NSURL *url = [NSURL URLWithString:
//                          [NSString stringWithFormat:@"http://ygd13959497c.arfixer.eu/setupo_cms/%@", url_string]
//                          ];
//            
//            _moviePlayer =  [[MPMoviePlayerController alloc]
//                             initWithContentURL:url];
//            
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(moviePlayBackDidFinish:)
//                                                         name:MPMoviePlayerPlaybackDidFinishNotification
//                                                       object:_moviePlayer];
//            
//            _moviePlayer.controlStyle = MPMovieControlStyleDefault;
//            _moviePlayer.shouldAutoplay = YES;
//            [self.view addSubview:_moviePlayer.view];
//            [_moviePlayer setFullscreen:YES animated:YES];
        }

    
    }
    
    
}




- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}

- (void)openBrowser: (NSString*)url_string{
    NSURL *URL = [NSURL URLWithString:url_string];
    DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:URL];
    webBrowser.showProgress = YES;
    webBrowser.allowSharing = YES;
    
    UINavigationController *webBrowserNC = [[UINavigationController alloc] initWithRootViewController:webBrowser];
    [self presentViewController:webBrowserNC animated:YES completion:NULL];
}


-(void)hideGallery{
    NSLog(@"hide GGG");
}

-(void) handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    NSLog(@"SLPCV: handlePinch: %d", self.imageScrollViewLeft.isInReadyToResizeMode);
    
    
    
    
    if([(UIPinchGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateEnded){
        NSLog(@"GEST PINCH DOWN ENDED: %f", self.imageScrollViewLeft.tileContainerView.frame.size.width);
        NSLog(@"GEST PINCH DOWN ENDED: %d", self.imageScrollViewLeft.isInReadyToResizeMode);
        if ( self.imageScrollViewLeft.tileContainerView.frame.size.width > 800 && self.imageScrollViewLeft.tileContainerView.frame.size.width <= 1024 && self.imageScrollViewLeft.isInReadyToResizeMode ){
            [self.imageScrollViewLeft setZoomScale:1024.0f / self.imageScrollViewLeft.imgSize.width];
            
        }
        else if ( self.imageScrollViewLeft.tileContainerView.frame.size.width <= 800 && self.imageScrollViewLeft.isInReadyToResizeMode ){
            self.imageScrollViewLeft.isInReadyToResizeMode = false;
            NSLog(@"Go to 2 page view");
            [self makeSmall:self.imageScrollViewLeft];
        }
        
    }
    
    if ( self.imageScrollViewLeft.isInReadyToResizeMode ){
        [self.imageScrollViewLeft correctButtonsFrames];
    }
    
    
}

-(void) prepareOrRefreshGesturesRecognizerForView:(SingleLandscapePageCatalogViewController*)twoPage{
    NSLog(@"prepareOrRefreshGesturesRecognizerForView");
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch1:)];
    pinchGesture.delegate = self;
    [twoPage.viewForGestures addGestureRecognizer:pinchGesture];
}

-(void) handlePinch1:(UIPinchGestureRecognizer *)gestureRecognizer {
    if ( [gestureRecognizer scale] > 1.2 ){
        CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
        if ( ( touchPoint.x < self.view.frame.size.width/2 ) && ( !self.imageScrollViewLeft.isInReadyToResizeMode ) ){
            self.imageScrollViewLeft.isInReadyToResizeMode = true;
            [self makeFull: self.imageScrollViewLeft];
        }
       
    }
    
    if([(UIPinchGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateEnded){
//        NSLog(@"GEST PINCH ENDED");
          }
}

- (void)makeFull: (TiledScrollView*)convertedTiledView {
    NSLog(@"make Full");
   
    
//    [self hideThumbView];
    [self.view bringSubviewToFront:convertedTiledView];
    convertedTiledView.isInReadyToResizeMode = YES;
    leftOriginal = convertedTiledView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75];
    
    CGRect frameForUIS;
    frameForUIS.size.height = self.view.frame.size.height;
    frameForUIS.size.width = self.view.frame.size.width;
    frameForUIS.origin.x = 0;
    frameForUIS.origin.y =0;
    convertedTiledView.backgroundColor = [UIColor whiteColor];
    convertedTiledView.frame = frameForUIS;
    
    
    [UIView commitAnimations];
    self.imageScrollViewLeft.tag = 1;
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchGesture.delegate = self;
    [self.imageScrollViewLeft addGestureRecognizer:pinchGesture];
    
    
    double scalestartinfull = 1024.0f / convertedTiledView.imgSize.width;
    NSLog(@"scale full: %f = %f/%f", scalestartinfull , 1024.0f , convertedTiledView.imgSize.width );
    
    [convertedTiledView setZoomScale:2.0];
    if ( /*convertedTiledView.frame.size.width > 800 &&*/ convertedTiledView.isInReadyToResizeMode ){
        [convertedTiledView setZoomScale:1024.0f / convertedTiledView.imgSize.width];
    }
    
    [convertedTiledView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}



- (void)makeSmall:(TiledScrollView*)convertedTiledView {
    NSLog(@"make SMall");
    convertedTiledView.isInReadyToResizeMode = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [convertedTiledView setFrame:leftOriginal];
    [convertedTiledView setFrame:CGRectMake( leftOriginal.origin.x, leftOriginal.origin.y, leftOriginal.size.width, leftOriginal.size.height)];
    [convertedTiledView correctButtonsFrames];
    float minScale =  convertedTiledView.frame.size.width / 1024.0;
  
    [convertedTiledView setZoomScale:minScale animated:YES];
    [convertedTiledView setZoomScale:convertedTiledView->start_minscale animated:YES];
    
    [UIView commitAnimations];
    
    [self.view bringSubviewToFront:self.viewForGestures];
    
    
    
}

//
//-(void) rightSwipe:(UIPinchGestureRecognizer *)gestureRecognizer {
//    NSLog(@"rightSwipePPPP");
//    [self swipeRight];
//}
//
//-(void) leftSwipe:(UIPinchGestureRecognizer *)gestureRecognizer {
//    NSLog(@"leftSwipePPPP");
//    [self swipeLeft];
//}
//
//-(void)swipeLeft{
//    if( [self prepareLeftRightNum:self.current_left_page+2] ){
//        NSLog(@"left:%d right:%d", self.current_left_page, self.current_right_page );
//        
//        [self pickImageNamedLeft:[NSString stringWithFormat:@"%d", self.current_left_page] ];
//        [self pickImageNamedRight:[NSString stringWithFormat:@"%d", self.current_right_page] ];
//        
//        [self placeButtons];
//        
//        self.view.center = CGPointMake(self.view.center.x+1024, self.view.center.y);
//        [UIView beginAnimations:@"aniamteDupaHide" context:nil];
//        [UIView setAnimationDuration:0.4];
//        self.view.center = CGPointMake(self.view.center.x - 1024, self.view.center.y);
//        [UIView commitAnimations];
//    }
//}

//
//-(void)swipeRight{
//    if( [self prepareLeftRightNum:self.current_left_page-2] ){
//        
//        CGSize size = CGSizeMake(620, 877);
//        [self pickImageNamedLeft:[NSString stringWithFormat:@"%d", self.current_left_page]];
//        [self pickImageNamedRight:[NSString stringWithFormat:@"%d", self.current_right_page]];
//        [self placeButtons];
//        
//        self.view.center = CGPointMake(self.view.center.x-1024, self.view.center.y);
//        [UIView beginAnimations:@"aniamteDupaHide" context:nil];
//        [UIView setAnimationDuration:0.4];
//        self.view.center = CGPointMake(self.view.center.x + 1024, self.view.center.y);
//        [UIView commitAnimations];
//    }
//}

-(void) setPageLeftPageNum: (int)left right:(int)right
{
    self.current_left_page = left;
    self.current_right_page = right;
    NSLog(@"left:%d right:%d", self.current_left_page, self.current_right_page );
    [self pickImageNamedLeft:[NSString stringWithFormat:@"%d", self.current_left_page] ];
    
    [self placeButtons];
}


-(bool)prepareLeftRightNum: (int)left_num{
    if ( left_num <= 0 ){
        left_num = 1;
        return NO;
    }
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSLog(@"change to page nums: %d %d", self.current_left_page, appDelegate.currentIshue->pagesNum );
    if ( left_num < appDelegate.currentIshue->pagesNum ){
        self.current_left_page = left_num;
        self.current_right_page = self.current_left_page + 1;
        [self.imageScrollViewLeft setPageId:self.current_left_page];
    }
    else{
        NSLog(@"left to far");
        return NO;
    }
    
    
    
    return YES;
}

#pragma mark View handling methods
- (void)pickImageNamedLeft:(NSString *)name {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray* pages = (NSMutableArray*)appDelegate.currentIshue.pages;
    
    NSDictionary* pageInfo = [pages objectAtIndex:self.current_left_page-1];
    long w = [[pageInfo objectForKey:@"width"] integerValue];
    long h = [[pageInfo objectForKey:@"height"] integerValue];
    CGSize size = CGSizeMake(w, h);
    
    currentImageNameLeft = name;
    
    name = [NSString stringWithFormat:@"katalog_%@", name];
    [self pickImageNamed:name size:size tiledScrollViewX:self.imageScrollViewLeft];
}


- (void)pickImageNamed:(NSString *)name size:(CGSize)size tiledScrollViewX:(TiledScrollView*)tiledScrollView {
    if ( true ){
//        tiledScrollView.alpha = 1.0;
//        [UIView beginAnimations:@"aniamteDupaHide" context:nil];
//        [UIView setAnimationDuration:0.4];
        tiledScrollView.alpha =0.0f;
//        [UIView commitAnimations];
    }
    
    
    
    
    // change the content size and reset the state of the scroll view
    // to avoid interactions with different zoom scales and resolutions.
//    NSLog(@"pickImageNamed 3: w:%f h:%f", size.width, size.height );
    
    tiledScrollView.imgSize = size;
    [tiledScrollView reloadDataWithNewContentSize:size];
    [tiledScrollView setContentOffset:CGPointZero];
   
    float minScale1 =  tiledScrollView.frame.size.width / size.width;
    float minScale2 =  tiledScrollView.frame.size.height / size.height;
//    NSLog(@"prop1: %f 2:%f", minScale1, minScale2 );
    double minScale = minScale1 < minScale2 ? minScale1 : minScale2;
//    NSLog(@"minscale: %f", minScale );
    tiledScrollView->start_minscale = minScale;
    
    
    [tiledScrollView setMinimumZoomScale:minScale];
    [tiledScrollView setZoomScale:minScale];
    
    if( true ){
//    tiledScrollView.alpha = 0.0;
//    [UIView beginAnimations:@"aniamteDupaShow" context:nil];
//    [UIView setAnimationDuration:0.4];
    tiledScrollView.alpha =1.0f;
//    [UIView commitAnimations];
    }
//    
//    tiledScrollView.center = CGPointMake(tiledScrollView.center.x + 1000, tiledScrollView.center.y);
//    [UIView beginAnimations:@"aniamteDupaHide" context:nil];
//    [UIView setAnimationDuration:0.4];
//    tiledScrollView.center = CGPointMake(tiledScrollView.center.x - 1000, tiledScrollView.center.y);
//    [UIView commitAnimations];
    
}


-(void) reloadPageView{
    self.imageScrollViewLeft = [[TiledScrollView alloc] initWithFrame:[[self view] bounds] pagenum:self.current_left_page];
    [self.imageScrollViewLeft setDataSource:self];
    [[self.imageScrollViewLeft tileContainerView] setDelegate:self];
    
    [self.view addSubview:self.imageScrollViewLeft];

}



-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear  - Two PAge Catalog View ");
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"SLPCV viewDidLoad");
    // Do any additional setup after loading the view from its nib.
    DBC = [[DBController alloc] init];
    [self reloadPageView];
    [self setImageScrollViewLandscape];
    
    
    [self.view bringSubviewToFront:self.viewForGestures];
    [self prepareOrRefreshGesturesRecognizerForView:self];
    [self placeButtons];
    [self prepareTap];

//    [self placeButtons];
    
//    [dupa placeButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void) handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.imageScrollViewLeft];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"TAPED!!!!");
    UIView* clickedView = [self pointInsideActiveView:location ];
    if ( clickedView != nil ){
//        NSLog(@"inside: %d", clickedView.tag);
        appDelegate->blockThumbs = YES;
        
        
    if( !self.imageScrollViewLeft.isInReadyToResizeMode ){
        NSMutableArray* buttons = [self.imageScrollViewLeft returnButtonsForPage];
        for (ContentButton* button in buttons) {
            if ( button.button_id == clickedView.tag ){
                //if audio
                if ( button.type_id == 1){
                    bool isPlaing = [self.audioPlayer isPlaying];
                    if ( isPlaing )
                        [self stopAudio:nil];
                    else
                        [self playAudio:button];
                }
                else if ( button.type_id == 2 ){
                    [self openGallery:[button.action intValue]];
                }
                else if ( button.type_id == 3 ){
                    [self openBrowser: button.action];
                }
                else if ( button.type_id == 4 ){
                    [self playMovie: button.action];
                }
                else{
                    
                }
            }
        }
    }
        
        
        
        
        //look for buttons with tag == id
        
        
        //
        //
    }
    else{
        NSLog(@"TPCVC not inside action %f,%f", location.x, location.y  );
        appDelegate->blockThumbs = NO;
        
//        [self toggleThumbView];
        
        
    }
    
    
}


-(void)openGallery: (int)g_id{
    NSLog(@"openGallery");
//    GalleryViewController* gvc = [[GalleryViewController alloc] init];
//    gvc->current_gallery_id=g_id;
    
    GalleryPageViewController* gvc = [[GalleryPageViewController alloc] init];
    gvc.gid = 666;
//    [self performSegueWithIdentifier:@"segueShowG" sender:nil];
    
    [self.navigationController pushViewController:gvc animated:YES];
//    [self presentViewController:gvc animated:YES completion:nil];
}



#pragma mark TiledScrollViewDataSource method
- (UIView *)tiledScrollView:(TiledScrollView *)tiledScrollView tileForRow:(int)row column:(int)column resolution:(int)resolution {
    //NSLog(@"Root:tiledScrollView: %d", tiledScrollView.tag);
    // re-use a tile rather than creating a new one, if possible
    UIImageView *tile = (UIImageView *)[tiledScrollView dequeueReusableTile];
    
    
    if (!tile) {
        // the scroll view will handle setting the tile's frame, so we don't have to worry about it
        tile = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        // Some of the tiles won't be completely filled, because they're on the right or bottom edge.
        // By default, the image would be stretched to fill the frame of the image view, but we don't
        // want this. Setting the content mode to "top left" ensures that the images around the edge are
        // positioned properly in their tiles.
        [tile setContentMode:UIViewContentModeTopLeft];
    }
    
    //    NSDictionary *imageDict = [self imageData];
    
//    NSLog(@"resolution: %d", resolution );
    // The resolution is stored as a power of 2, so -1 means 50%, -2 means 25%, and 0 means 100%.
    // We've named the tiles things like BlackLagoon_50_0_2.png, where the 50 represents 50% resolution.
    int resolutionPercentage = 100 * pow(2, resolution);
    
    
    
//    currentIshue
    
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   
    Ishue* ishue = appDelegate.currentIshue;
    
    NSDictionary* pages = ishue.pages;
    NSMutableArray* pagesA = (NSMutableArray*)pages;
    NSDictionary* pageLeft = [pagesA objectAtIndex:[currentImageNameLeft integerValue] - 1];
    
    
    
    NSString* extra = @"";
    NSString* pathLeft = [NSString stringWithFormat:@"%@_%d%@_%d_%d.png", [pageLeft objectForKey:@"id"], resolutionPercentage, extra, row+1, column+1];
    
    
    
//    NSLog(@"pathRight: %@", pathRight );
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFilePathLeft = [documentsDirectory stringByAppendingPathComponent:pathLeft];
    NSData *imageDataLeft = [NSData dataWithContentsOfFile:fullFilePathLeft];
    UIImage *originalImageLeft = [UIImage imageWithData:imageDataLeft];
    
    
//     NSLog(@"fullFilePathLeft: %@", fullFilePathLeft );
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePathLeft];
    NSError *attributesError = nil;
    
//    NSLog(@"pathLeft: %@=>%d", pathLeft, fileExists );
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePathLeft error:&attributesError];
    unsigned long long fileSize = [fileAttributes fileSize];
//    NSLog(@"left exist: ? %@ %d %@ %@ => %llu", fullFilePathLeft, fileExists, imageDataLeft,originalImageLeft, fileSize );
    
    
//    [UIImage image
//    NSLog(@"left: %@ right: %@", fullFilePath, pathRight );
    switch ( tiledScrollView.tag ) {
        case 1:
            [tile setImage:originalImageLeft];
            break;
        case 2:
//            [tile setImage:originalImageRight];
            break;
            
            
        default:
            break;
    }
    
    return tile;
}

- (CGRect)zoomRectForScaleLeft:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollViewLeft's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.imageScrollViewLeft frame].size.height / scale;
    zoomRect.size.width  = [self.imageScrollViewLeft frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    NSLog(@"zoomRectForScaleLeft: %f,%f", zoomRect.origin.x, zoomRect.origin.y );
    return zoomRect;
}

@end