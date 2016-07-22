#import "VideoViewController.h"

@implementation VideoViewController{
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"VIDEO init");
    }
    return self;
}


-(void) viewDidAppear:(BOOL)animated{
    if ( [self.movieUrl length] > 1 )
        [self playMovie:self.movieUrl];
}

-(void)playMovie: (NSString*)url_string {
    self.movieUrl = @"";
    [_moviePlayer.view removeFromSuperview];
    NSLog(@"PLay online");
    NSLog(@"urlstring: %@", url_string );
    NSURL *url = [NSURL URLWithString: url_string];
    
    _moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonClick:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.shouldAutoplay = YES;
    [_moviePlayer.view setFrame:CGRectMake(0, 0, 1024, 768)];
    [self.view addSubview:_moviePlayer.view];
    [self.view bringSubviewToFront:_moviePlayer.view];
    [_moviePlayer play];
//    [_moviePlayer setFullscreen:NO animated:YES];
    
    
}




-(void)goAfterWill{
    NSLog(@"goAfterWill");
    if ( [[UIApplication sharedApplication] isIgnoringInteractionEvents] ){
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self goAfterWill];
        });
        
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


-(void)doneButtonClick:(NSNotification*)aNotification{
//    NSNumber *reason = [aNotification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    appDelegate.playMovie = NO;
    
    //    if ([reason intValue] == MPMovieFinishReasonUserExited) {
    // Your done button action here
//    NSLog(@"FULSLCREEN CLOSED: %ld ?? %ld", [UIDevice currentDevice].orientation, [UIApplication sharedApplication].statusBarOrientation  );
//    [twoPageCatalogView makeKorekcjaPoZmianie: [UIDevice currentDevice].orientation ];
    NSLog(@"FULSLCREEN CLOSED: %d", [[UIApplication sharedApplication] isIgnoringInteractionEvents] );
    [self goAfterWill];
    
    //    }
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
        appDelegate.playMovie = NO;
        [player.view removeFromSuperview];
        
        
        
    }
}




- (void)canRotate{};


@end
