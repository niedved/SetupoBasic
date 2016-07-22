//
//  SingleLandPageCatalogViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 31.05.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "ContentButton.h"
#import "SingleLandPageCatalogViewController.h"


@implementation SingleLandPageCatalogViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"SLPCVC: viewDidLoad: %@", self.imageFile);
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    self.myZoomableView = [[ZoomableView alloc] initWithFrame:self.view.frame];
//    self.myZoomableView.frame = self.view.frame;
//    self.myZoomableView.userInteractionEnabled = YES;
//    [self.view addSubview:self.myZoomableView];
    
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    if ( orient == UIInterfaceOrientationLandscapeLeft ){
        NSLog(@"landscape");
//        [self goLand];
    }
    else{
        NSLog(@"portrait");
//        [self goPortrait];
    }
    
    
    [self preapreOffestsBasedOnSizeScreenOrient];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = appDelegate.currentIshue->bg;
    self.myZoomableView.backgroundColor = appDelegate.currentIshue->bg;
    
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.imageFile] ];
//    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath];

//    
    self.myImage = [[UIImageView alloc] initWithFrame:CGRectMake(offset_x, offset_y, pageW*prop, pageH*prop)];
    [self.myImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",self.imageFile] ]];
    [[self myZoomableView] addSubview:self.myImage];
    
    
    [[self scrollView] setMinimumZoomScale:1.0];
    [[self scrollView] setMaximumZoomScale:6.0];
    
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    self.myImage.layer.borderColor = [UIColor yellowColor].CGColor;
    self.myImage.layer.borderWidth = 16.0f;
    self.scrollView.layer.borderColor = [UIColor greenColor].CGColor;
    self.scrollView.layer.borderWidth = 4.0f;
    self.myZoomableView.layer.borderColor = [UIColor blueColor].CGColor;
    self.myZoomableView.layer.borderWidth = 10.0f;
    
    CGRect sr = [[UIScreen mainScreen] bounds];
    self.scrollView.frame = CGRectMake(0, 0, sr.size.height, sr.size.width);
    float newScale = self.scrollView.frame.size.width / self.myImage.frame.size.width;
    [[self scrollView] setMinimumZoomScale:newScale];
    [self.scrollView setZoomScale:newScale];
    
   
//    [self handleOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    
    [self placeButtons];
    
}




-(void)preapreOffestsBasedOnSizeScreenOrient{
    Ishue* ishue = appDelegate.currentIshue;
    int pageid = [self.imageFile intValue];
    NSDictionary* pageInfo = [ishue getPageInfoById:pageid];
    pageW = [[pageInfo objectForKey:@"width"] intValue];
    pageH = [[pageInfo objectForKey:@"height"] intValue];
    double propW = self.view.frame.size.width / pageW;
    double propH = self.view.frame.size.height / pageH;
    prop = (propW < propH) ? propW : propH;
    offset_y = (self.view.frame.size.height - pageH*prop) / 2;
    offset_x = (self.view.frame.size.width - pageW*prop) / 2;
    
    NSLog(@"preapreOffestsBasedOnSizeScreenOrient: pagesize(%d,%d)=> props(%f,%f)", pageW,pageH, propW, propH);
}



-(void)removeAllButtonsFromView{
    NSLog(@"removeAllButtonsFromView");
    for (int i=0; i < [buttonsForPageUIBUTTONS count]; i++) {
        UIView* button = [buttonsForPageUIBUTTONS objectAtIndex:i];
        [button removeFromSuperview];
    }
    
    [buttonsForPageUIBUTTONS removeAllObjects];
    [buttonsForPage removeAllObjects];
}



-(NSMutableArray*)prepareButtons{
    buttonsForPage = [[NSMutableArray alloc] init];
    
    [self removeAllButtonsFromView];
    Ishue* ishue = appDelegate.currentIshue;
    NSDictionary* buttons = ishue.buttonsForCurrentIshue;
//    NSLog( @"prepareButtons => %lu", (unsigned long)[buttons count] );
    //    if
    if ( [buttons count] == 0 ){
        return buttonsForPage;
    }
    else{
        NSMutableArray* buttonsForThisPage = [ishue getButtonsForPage:[self.imageFile intValue] ];
//        NSLog(@"buttonsForThisPage :%@", buttonsForThisPage );

        for (NSDictionary* buttonData in buttonsForThisPage) {
            NSMutableDictionary* buttonInfo = [[NSMutableDictionary alloc] init];
            [buttonInfo setObject:[buttonData objectForKey:@"ia_id"] forKey:@"button_id"];
            [buttonInfo setObject:[buttonData objectForKey:@"action_type_id"] forKey:@"type_id"];
            [buttonInfo setObject:[buttonData objectForKey:@"full_link"] forKey:@"action"];
            [buttonInfo setObject:[buttonData objectForKey:@"posX"] forKey:@"position_left"];
            [buttonInfo setObject:[buttonData objectForKey:@"posY"] forKey:@"position_top"];
            [buttonInfo setObject:[buttonData objectForKey:@"ico_posX"] forKey:@"ico_position_left"];
            [buttonInfo setObject:[buttonData objectForKey:@"ico_posY"] forKey:@"ico_position_top"];
            [buttonInfo setObject:[buttonData objectForKey:@"width"] forKey:@"position_width"];
            [buttonInfo setObject:[buttonData objectForKey:@"height"] forKey:@"position_height"];
            switch ( [[buttonData objectForKey:@"icon_id"] integerValue] ) {
                case 1:
                    [buttonInfo setObject:@"ICO_2_A_000000" forKey:@"btnico"];break;
                case 2:
                    [buttonInfo setObject:@"ICO_2_G_000000" forKey:@"btnico"];break;
                case 3:
                    [buttonInfo setObject:@"ICO_2_L_000000" forKey:@"btnico"];break;
                case 4:
                    [buttonInfo setObject:@"ICO_2_V_000000" forKey:@"btnico"];break;
                    
                default:
                    [buttonInfo setObject:@"btn_pdf" forKey:@"btnico"];break;
                    
                    break;
            }
            
            [buttonsForPage insertObject:
             [[ContentButton alloc] initWithDatasId:buttonInfo] atIndex:buttonsForPage.count];
//
        }
        
        
        return buttonsForPage;
    }
}




-(void)placeButtons{
    
    NSMutableArray* buttonsL = [self prepareButtons];
    for (ContentButton* button in buttonsL) {
        [self placeButton:button];
    }
}


-(void)placeButton: (ContentButton*)button  {
//    NSLog(@"CB: %@ height: %f", button, self.myZoomableView.frame.size.height );
//    float x = (button.position_left/100)*self.myZoomableView.frame.size.width;
    float x = (button.position_left/100)*self.myImage.frame.size.width;
    //    float y = (button.position_top/100)*self.myZoomableView.frame.size.height;
    float y = (button.position_top/100)*self.myImage.frame.size.height;
    
    float width = (button.position_width/100)*self.myImage.frame.size.width;
    float height = (button.position_height/100)*self.myImage.frame.size.height;
    CGRect frameForView = CGRectMake( x+offset_x, y+offset_y, width, height );
    [self placeXXXButton:button frame:frameForView];
}


- (void)openBrowser: (NSString*)url_string{
    NSURL *URL = [NSURL URLWithString:url_string];
    DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:URL];
    webBrowser.showProgress = YES;
    webBrowser.allowSharing = YES;
    
    UINavigationController *webBrowserNC = [[UINavigationController alloc] initWithRootViewController:webBrowser];
    [self presentViewController:webBrowserNC animated:YES completion:NULL];
}



-(void)openGallery: (int)g_id{
    NSLog(@"openGallery");
    
    GalleryPageViewController* gvc = [[GalleryPageViewController alloc] init];
//    gvc set
    gvc.gid = g_id;
    [self.navigationController pushViewController:gvc animated:YES];
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




-(void) handleBTap:(UITapGestureRecognizer *)gestureRecognizer {
    UIView *clickedView = gestureRecognizer.view; //cast pointer to the derived class if needed
    NSLog(@"Button Taped:%ld", (long)clickedView.tag);
    for (ContentButton* button in buttonsForPage) {
        if ( button.button_id == clickedView.tag ){
            //if audio
            if ( button.type_id == 1){
                NSLog(@"ACTION AUDIO");
                bool isPlaing = [self.audioPlayer isPlaying];
                if ( isPlaing )
                    [self stopAudio:nil];
                else
                    [self playAudio:button];
            }
            else if ( button.type_id == 2 ){
                NSLog(@"ACTION GALLERY");
                [self openGallery:[button.action intValue]];
            }
            else if ( button.type_id == 3 ){
                NSLog(@"ACTION WWW");
                [self openBrowser: button.action];
            }
            else if ( button.type_id == 4 ){
                NSLog(@"ACTION MOVIE");
                [self playMovie: button.action];
            }
            else{
                
            }
        }
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





-(void)placeXXXButton: (ContentButton*)button frame:(CGRect)frameForView{
    UIView* b = [[UIView alloc] initWithFrame:frameForView ];
    b.layer.borderColor = [UIColor grayColor].CGColor;
    b.tag = button.button_id;
    b.layer.borderWidth = 0.5f;
    b.layer.cornerRadius = 5;
    b.layer.backgroundColor = [UIColor clearColor].CGColor;
//    NSLog(@"ico pos: %f %f", button.ico_position_left, button.ico_position_top );
    
    float ico_left = (button.ico_position_left/100) * frameForView.size.width;
    float ico_top = (button.ico_position_top/100) * frameForView.size.height;
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:button.btnico ]];
    image.frame = CGRectMake(ico_left, ico_top, 64, 64);
    [b addSubview:image];
    [self.myZoomableView addSubview:b];
    [self.myZoomableView bringSubviewToFront:b];
    b.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBTap:)];
    tap.delegate = self;
    [tap setNumberOfTapsRequired:1];
    [b addGestureRecognizer:tap];
   
    
    
//    [UIView animateWithDuration:2.0 delay:2.0 options: UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
//        b.backgroundColor = [UIColor colorWithRed:1.0f green:215.0/255.0f blue:0.0f alpha:0.15f];
//
//    } completion:nil];
    
    
    [buttonsForPageUIBUTTONS addObject:b];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.myZoomableView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
