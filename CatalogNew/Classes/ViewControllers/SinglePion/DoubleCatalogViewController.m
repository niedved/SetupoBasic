#import "DoubleCatalogViewController.h"
#import "AppDelegate.h"
#import "PageViewPdf.h"
#import <UIKit/UIKit.h>
#import "NHelper.h"
#import "CatalogHelper.h"
#import "IssuesManager.h"

@implementation DoubleCatalogViewController{
    
    AppDelegate* appDelegate;
}


-(void)preaparePagesFirstPage: (int)index{
    self.firstPage = YES;
    self.current_left_page = 0;
    
    if( [NHelper isLandscapeInReal] ){
        if( appDelegate.currentIshue->forceOnePagePerView){
            self.pageleft = [[Page alloc] initWithPageNum:(index*1)+1 issue:appDelegate.currentIshue];
            self.pageright = nil;
        }
        else{
            self.pageleft = [[Page alloc] initWithPageNum:(index*2)+1 issue:appDelegate.currentIshue];
            self.pageright = nil;
        }
    }
    else{
        self.pageleft = [[Page alloc] initWithPageNum:(index*1)+1 issue:appDelegate.currentIshue];
        self.pageright = nil;
    }
}


-(void)preaparePagesNotFirst: (int)index{
    self.firstPage = NO;
    self.current_left_page = 0;
    
    self.firstPage = NO;
    self.current_left_page = 0;
    
    self.lastPage = NO;
    
    if ( ![NHelper isLandscapeInReal] || appDelegate.currentIshue->forceOnePagePerView ){
        self.current_left_page = (int)(index);
        self.pageleft = [[Page alloc] initWithPageNum:index+1 issue:appDelegate.currentIshue];
    }
    else{ //poziom
        if( [NHelper isIphone]){
            self.current_left_page = (int)(index);
            self.pageleft = [[Page alloc] initWithPageNum:index+1 issue:appDelegate.currentIshue];
        }
        else{
            self.current_left_page = ((int)index*2)+0;
            self.pageleft = [[Page alloc] initWithPageNum:(int)(index*2)+0 issue:appDelegate.currentIshue];
            if ( (index*2)+1 <= [appDelegate.currentIshue.pages count]){
                self.pageright = [[Page alloc] initWithPageNum:(int)(index*2)+1 issue:appDelegate.currentIshue];
            }
            else{
                self.lastPage = YES;
                self.pageright = nil;
            }
        }
    }
}

- (id)initWithNibNameIndex:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil index:(int)index{
    //index page-1 if 1 view per view
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self->nibName = nibNameOrNil;
    if (self) {
        self.pageIndex = index;
        NSLog(@"initWithNibNameIndex: index: %lu ", (unsigned long)self.pageIndexNew );
        if( index == 0 ){
            [self preaparePagesFirstPage: index];
        }
        else{
            [self preaparePagesNotFirst:index];
            
        }
    }
    
//    [appDelegate setNav:[self navigationController]];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self->nibName = nibNameOrNil;
    if (self) {
    
    
    }
//    [appDelegate setNav:[self navigationController]];
    
    return self;
}

-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"viewDidDisappear");
}

-(void)viewDidAppear:(BOOL)animated{
    [CatalogHelper animateButtons:self];
    
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"Double VIEW WILL APPEAR");
    [self hardcoreFixLocal:@"DVCV:52 (viewWillAppear)"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    page_prop = self.pageleft.page_prop;
    buttonsForPageUIBUTTONS = [[NSMutableArray alloc] init];
    buttonsForPageUIBUTTONSToBGAnimate = [[NSMutableArray alloc] init];
    [self prepareOffsets];
    
    [self.myZoomableView addSubview:self.myImage];
    [self makeKorekcjaPoZmianie:[UIDevice currentDevice].orientation];
    [self placeButtons];
    self.zoomedLeft = NO;
    self.zoomedRight = NO;
    self.view.backgroundColor = appDelegate.presetBackgroundColor;
    self.view.backgroundColor = [UIColor blackColor];
    [CatalogHelper colorBorders:self];
}

-(void)prepareOffsets{
    if ( [NHelper isLandscapeInReal] ){
        [self preapreOffestsBasedOnSizeScreenOrientLand];
    }
    else{
        [self preapreOffestsBasedOnSizeScreenOrientPortrait];
    }
    
}

-(void)preapreOffestsBasedOnSizeScreenOrientPortrait{
    NSLog(@"preapreOffestsBasedOnSizeScreenOrientPortrait");
    
    offset_y = self.pageleft.offset_y_port;
    pageW = self.pageleft.width;
    pageH = self.pageleft.height;
    double propW = self.view.frame.size.width / pageW;
    double propH = self.view.frame.size.height / pageH;
    prop = (propW < propH) ? propW : propH;
    self.scrollView.delegate = self;
    self.myImage = [[UIImageView alloc] initWithFrame:CGRectMake([self.pageright getOrientedOffsetX], self.pageleft.offset_y_port, pageW*prop, pageH*prop)];
    [self setMinMaxCurrentZoomScale];
}

-(void)preapreOffestsBasedOnSizeScreenOrientLand{
    NSLog(@"preapreOffestsBasedOnSizeScreenOrientLand");
    offset_y = self.pageleft.offset_y_land;
    pageW = self.pageleft.width;
    pageH = self.pageleft.height;
    double propW = self.view.frame.size.width/2 / pageW;
    double propH = self.view.frame.size.height / pageH;
    prop = (propW < propH) ? propW : propH;
    self.scrollView.delegate = self;
    self.myImage = [[UIImageView alloc] initWithFrame:CGRectMake([self.pageleft getOrientedOffsetX], [self.pageleft getOrientedOffsetY], pageW*prop, floor(pageH*prop))];
    [self setMinMaxCurrentZoomScale];
}

-(void) setRightPage : (CGRect) rect{
    self.rmyImagePdf = [[PageViewPdf alloc] initWithFrameAndFile:rect pathToPdfPage:[self.pageright pathToPdfPageFile]];
    self.rmyImagePdf.delegate = self;
    self.rmyImagePdf.tag = 1;
    self.rmyImagePng = [[UIImageView alloc] initWithFrame:rect];
    self.rmyImagePng.hidden = NO;
    [self.rmyImagePng setImage:[UIImage imageWithContentsOfFile:[self.pageright pathToJPGPageFile]]];
    self.rmyImagePng.contentMode = UIViewContentModeScaleAspectFit;
    appDelegate.currentIshue.curentImageR = [UIImage imageWithContentsOfFile:[self.pageright pathToJPGPageFile]];
}

-(void) setLeftPage : (CGRect) rect{
    [self.view layoutIfNeeded];
   
    self.lmyImagePdf = [[PageViewPdf alloc] initWithFrameAndFile:rect pathToPdfPage:[self.pageleft pathToPdfPageFile]];
    self.lmyImagePdf.delegate = self;
    self.lmyImagePdf.tag = 0;
    
//    x = [CatalogHelper getImageSizeForMyImagePion_iPhone:self];
    
    self.lmyImagePng = [[UIImageView alloc] initWithFrame:rect];
    self.lmyImagePng.hidden = NO;
    self.lmyImagePng.contentMode = UIViewContentModeScaleAspectFit;
    [self.lmyImagePng setImage:[UIImage imageWithContentsOfFile:[self.pageleft pathToJPGPageFile]]];
    appDelegate.currentIshue.curentImage = [UIImage imageWithContentsOfFile:[self.pageleft pathToJPGPageFile]];
    
    
}




-(void)setImageForMyImagePion{
    NSLog(@"setImageForMyImagePion");
    CGRect x;
    lrdy = YES;
    
    if( [NHelper isIphone]){
        x = [CatalogHelper getImageSizeForMyImagePion_iPhone:self];
    }
    else{
        if( self.pageleft.page_prop > 1.0){
             x = CGRectMake(0, 0, 1024/self.pageleft.page_prop, 1024);
        }
        else{
             x = CGRectMake(0, 0, 768, 768*self.pageleft.page_prop);
        }
    }
    
    [self setLeftPage:x];
    [self.myImage addSubview: self.lmyImagePdf];
    [self.myImage addSubview: self.lmyImagePng];
    [self.myImage bringSubviewToFront:self.lmyImagePng];
    
}


-(void)setImageForMyImagePoziom{
    
    if( [NHelper isIphone]){
        [CatalogHelper setImageForMyImageIphoneLandscape:self];
    }
    else{
        
        NSLog(@"setImageForMyImagePoziom");
        [self setLeftPage:CGRectMake(0, 0, 512.0, 512.0*page_prop)];
        [self.myImage addSubview: self.lmyImagePdf];
        [self.myImage addSubview: self.lmyImagePng];
        [self.myImage bringSubviewToFront:self.lmyImagePng];
        
        if ( !self.firstPage && !self.lastPage ){
            [self setRightPage:CGRectMake(512.0, 0, 512.0, (512.0*(page_prop)))];
            [self.myImage addSubview: self.rmyImagePdf];
            [self.myImage addSubview: self.rmyImagePng];
            [self.myImage bringSubviewToFront:self.rmyImagePng];
        }
        
        if ( self.firstPage || self.lastPage ) {
        }
        else if( self.current_left_page == [appDelegate.currentIshue.pages count] ){
        }
        else{
            [self hardcoreFixLocal: @"DCVC209"];
            CGRect myZoomableViewRect = self.myZoomableView.frame;
            double propW = self.view.frame.size.width/2 / pageW;
            double propH = self.view.frame.size.height / pageH;
            prop = (propW < propH) ? propW : propH;
            myZoomableViewRect.origin.y = myZoomableViewRect.origin.y + (offset_y/1);
            myZoomableViewRect.size.height = 512*self.pageleft.page_prop-2;
            self.myImage.frame = myZoomableViewRect;
            [self.lmyImagePdf setFrame:[CatalogHelper leftPdfCropSizeLandscape:self.pageleft forcedOnePage:self.pageleft.forceonepage]];
            [self.rmyImagePdf setFrame:[CatalogHelper rightPdfCropSizeLandscape:self.pageright]];
        }
        
    }
}

-(void)setImageForMyImage{
    NSLog(@"setImageForMyImage");
    lrdy = NO;
    rrdy = NO;
    
    appDelegate.currentLeftPageNameFile = [NSString stringWithFormat:@"%d",self.pageleft.pageid];
    appDelegate.currentRightPageNameFile = [NSString stringWithFormat:@"%d",self.pageright.pageid];

    
    //TEST IS THAT A FIRST PAGE
    appDelegate.firstPage = NO;
    if ( self.current_left_page == 0 ){
        self.firstPage = YES;
        appDelegate.firstPage = YES;
    }
    
    if ( ![NHelper isLandscapeInReal] ){ //PION
        [self setImageForMyImagePion];
    }
    else{ //LANDSCAPE
        if( appDelegate.currentIshue->forceOnePagePerView )
            [CatalogHelper setImageForMyImagePoziomForcedOnePage: self];
        else
            [self setImageForMyImagePoziom];
    }
    [self hardcoreFixLocal:@"DVCV:245 "];
}


-(void)hardcoreFixFirstPage: (float)widthOfPage{
    if ( self.firstPage && !appDelegate.currentIshue->forceOnePagePerView ) {
        CGRect frame = self.myImage.frame;
        frame.origin.x = frame.origin.x + widthOfPage/2;
        [self.myImage setFrame:frame];
    }
}

-(void)hardcoreFixLastPage: (float)widthOfPage{
    if( self.current_left_page == [appDelegate.currentIshue.pages count] ){
        CGRect frame = self.myImage.frame;
        frame.origin.x = frame.origin.x + widthOfPage/2;
        [self.myImage setFrame:frame];
    }
}





-(void)hardcoreFixLocal: (NSString*)x{
    if( [NHelper isLandscapeInReal] ){
        if ( [NHelper isIphone]){
            [CatalogHelper hardcoreFixLocalPoziomIphone:self];
        }
        else{
            if( appDelegate.currentIshue->forceOnePagePerView )
                self.myImage.frame = CGRectMake(0, [self.pageleft getOrientedOffsetY], 1024, 1024*page_prop);
            else
                self.myImage.frame = CGRectMake(0, [self.pageleft getOrientedOffsetY], 1024, 512*page_prop);
            
            if( !appDelegate.currentIshue->forceOnePagePerView )
            {
                [self hardcoreFixFirstPage:512];
                [self hardcoreFixLastPage:512];
            }
            
            [self.rmyImagePdf setFrame:[CatalogHelper rightPdfCropSizeLandscape:self.pageright]];
            [self.lmyImagePdf setFrame:[CatalogHelper leftPdfCropSizeLandscape:self.pageleft forcedOnePage:appDelegate.currentIshue->forceOnePagePerView]];
            
        }
    }
    else{ //PION
        [CatalogHelper hardcoreFixLocalPion:x dcvc:self];
    }
}



-(void) corectwebViewClearBackground :(UIView*)v isright:(BOOL)isright {
    [v setBackgroundColor:[UIColor blackColor]];
    CGRect x = v.frame;
    
    if( [NHelper isLandscapeInReal] ){
        x.origin.x = [[[NHelper appSettings] objectForKey:@"correct_pdfweb_poziom_x"] floatValue];
        x.origin.y = [[[NHelper appSettings] objectForKey:@"correct_pdfweb_poziom_y"] floatValue]; //pionowe
        
        if( isright ){
            //TODO
            x.origin.x += 0.0f;
            x.origin.y += 0.0f;
            x.origin.x += self.pageright.pagesizex;
        }
        else{
            x.origin.x -= 0.5f;
            x.origin.x += self.pageleft.pagesizex;
        }
        
        
    }
    else{ //PION
        if( [NHelper isIphone]){
            x.origin.x -= 4.0f;
            x.origin.y -= 7.0f;
        }
        else{
            x.origin.x += [[[NHelper appSettings] objectForKey:@"correct_pdfweb_pion_x"] floatValue];// 2.0f;
            x.origin.y += [[[NHelper appSettings] objectForKey:@"correct_pdfweb_pion_y"] floatValue];//5.0f; //pionowe
        }
    }
    
    v.frame = x;
}

- (void)clearBackgroundLeft {
    UIView *v = self.lmyImagePdf;
    int i = 0;
    while (v) {
        v = [v.subviews firstObject];
        if ([NSStringFromClass([v class]) isEqualToString:@"UIWebPDFView"]) {
            i++;
            CGRect ftest = v.frame;
            ftest.size.height = 669.0f;
            [v setFrame:ftest];
            [self corectwebViewClearBackground:v isright:NO];
            
            return;
        }
    }
}


- (void)clearBackgroundRight {
    UIView* v = self.rmyImagePdf;
    int i =0;
    while (v) {
        v = [v.subviews firstObject];
        if ([NSStringFromClass([v class]) isEqualToString:@"UIWebPDFView"]) {
            i++;
            CGRect ftest = v.frame;
            ftest.size.height = 669.0f;
            [v setFrame:ftest];
            [self corectwebViewClearBackground:v isright:YES];
            return;
        }
    }
}


-(void)webViewDidStartLoad:(UIWebView *)webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"webViewDidFinishLoad");
    //Check if file still loading
    if(!webView.isLoading)
    {
        webView.scalesPageToFit = YES;
        webView.contentMode = UIViewContentModeScaleAspectFit;
        [self zoomToFit:webView];
        if ( webView.tag == 0 )
            [self performSelector:@selector(clearBackgroundLeft) withObject:nil afterDelay:0.1];
        else if ( webView.tag == 1 )
            [self performSelector:@selector(clearBackgroundRight) withObject:nil afterDelay:0.1];
        
        webView.backgroundColor = [UIColor blackColor];
        
        [self hardcoreFixLocal:@"DVCV:362 (webViewDidFinishLoad)"];
        
        if ( webView.tag == 0 ){
            lrdy = YES;
        }
        else if ( webView.tag == 1 )
        {
            rrdy = YES;
            
            
        }
        NSLog(@"l: %d r:%d", lrdy, rrdy );
        if( lrdy && rrdy ){
            appDelegate->alldone = YES;
           [CatalogHelper performSelector:@selector(changepngtopdf:) withObject:self afterDelay:1.0];
        }
        else if( lrdy && [NHelper isIphone]){
            appDelegate->alldone = YES;
            [CatalogHelper performSelector:@selector(changepngtopdf:) withObject:self afterDelay:1.0];
        }
        else if( lrdy && ![NHelper isLandscapeInReal]){
            appDelegate->alldone = YES;
            [CatalogHelper performSelector:@selector(changepngtopdf:) withObject:self afterDelay:1.0];
        }
        else{
            appDelegate->alldone = NO;
        }
        
    }
    
}

-(void)zoomToFit:(UIWebView *)webView
{
    
    if ([webView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[webView scrollView];
        
        float zoom=webView.bounds.size.width/scroll.contentSize.width;
        [scroll setZoomScale:zoom animated:YES];
    }
}



-(void)ustawFrameMyImageView: (CGRect)rect{
    self.myImage.frame = rect;
    if( NO ){
        [AppDelegate showRectParams:rect label:@"ustawFrameMyImageView:"];
    }
}



-(void)setMinMaxCurrentZoomScale{
    [[self scrollView] setMinimumZoomScale:1.0];
    if ( appDelegate->orientPion ){
        if( [NHelper isIphone])
            [[self scrollView] setMaximumZoomScale:6.0];
        else
            [[self scrollView] setMaximumZoomScale:5.0];
        
    }
    else{
        if( [NHelper isIphone])
            [[self scrollView] setMaximumZoomScale:6.0];
        else
            [[self scrollView] setMaximumZoomScale:5.0];
    }
    [[self scrollView] setZoomScale:1.0];
}


-(void)makeKorekcjaPoZmianieIphone:(UIDeviceOrientation) deviceOrientation{
    NSLog(@"makeKorekcjaPoZmianieIphone");
    [CatalogHelper makeKorekcjaPoZmianie:deviceOrientation dcvc:self];
}
-(void)makeKorekcjaPoZmianie:(UIDeviceOrientation) deviceOrientation{
    [CatalogHelper makeKorekcjaPoZmianie:deviceOrientation dcvc:self];
}

-(void)removeAllButtonsFromView{
    for (int i=0; i < [buttonsForPageUIBUTTONS count]; i++) {
        UIView* button = [buttonsForPageUIBUTTONS objectAtIndex:i];
        [button removeFromSuperview];
    }
    
    [buttonsForPageUIBUTTONS removeAllObjects];
    [buttonsForPageUIBUTTONSToBGAnimate removeAllObjects];
}


-(void)placeButtons{
//    NSLog(@"placeButtons start left: %@", self.pageleft.buttons);
    if( [NHelper isIphone]){
        for (ContentButton* button in  self.pageleft.buttons) {
            [self placeButtonIphone:button];
        }
    }
    else{
        if ( !appDelegate->orientPion && !self.firstPage ){
            for (ContentButton* button in self.pageright.buttons) {
                [CatalogHelper placeButtonOnPage:button left:false dcvc:self];
            }
        }
        
        for (ContentButton* button in self.pageleft.buttons) {
            [CatalogHelper placeButtonOnPage:button left:true dcvc:self];
        }
    }
//    NSLog(@"placeButtons end");
}

-(void)placeButtonIphone: (ContentButton*)button  {
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    float realW = size.width;
    float realH = size.width*page_prop;
    float x = (button.position_left/100)*realW;
    float y = (button.position_top/100)*realH;
    float width = (button.position_width/100)*realW;
    float height = (button.position_height/100)*realH;
    
    CGRect frameForView = CGRectMake( x+[self.pageleft getOrientedOffsetX], y+[self.pageleft getOrientedOffsetY], width, height );
    [CatalogHelper placeYYYButton:button frame:frameForView dcvc:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView.zoomScale == 2.0 ){
        float x = self.zoomedLeft ? 0.0 : 1024.0;
        if ( self.current_left_page == 0 && !appDelegate->orientPion ){
            x = 1024/2;
        }
        else if ([appDelegate.currentIshue.pages count] == self.current_left_page ){
            x = 1024/2;
        }
        else{
            x = self.zoomedLeft ? 0.0 : 1024.0;
        }
        scrollView.contentOffset = CGPointMake(x, scrollView.contentOffset.y);
    }
    
    if( [NHelper isIphone] && ![NHelper isLandscapeInReal] ){
        CGSize screct = [NHelper getSizeOfCurrentDevicePortrait];
        float offset_yy = (screct.height - screct.width*page_prop) / 2;
        //        NSLog(@"height after zoom: %f", screct.width*page_prop*scrollView.zoomScale );
        float offset_pion = offset_yy * scrollView.zoomScale;
        if( screct.width*page_prop*scrollView.zoomScale > screct.height ){
            float heightX = offset_pion + (self.myImage.frame.size.height*scrollView.zoomScale)-screct.height + 20.0f;
            
            if( scrollView.contentOffset.y <= offset_pion && scrollView.zoomScale > 1.0 ){
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, offset_pion );
            }
            else if( scrollView.contentOffset.y > heightX  ){
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, heightX );
            }
            
            else{
                ;
            }
            
        }
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

-(void)openGallery: (int)g_id{
    NSLog(@"openGallery");
    GalleryPageViewController* gvc = [[GalleryPageViewController alloc] init];
    gvc.gid = g_id;
    gvc.photos = [appDelegate.currentIshue getPhotosForGallery:g_id];
    [self.navigationController pushViewController:gvc animated:YES];
}


-(void) handleBTap:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"handleBTap");
    [appDelegate disableThumbViewShow:YES czas:1];
    UIView *clickedView = gestureRecognizer.view;
    NSLog(@"clickedView: %@", clickedView );
    if([NHelper isIphone]){
        [CatalogHelper handleBTapHelperIphone:self clickedView:clickedView];
    }
    else{
        [CatalogHelper handleBTapHelper:self clickedView:clickedView];
    }
}


//MOVIE START
-(void)playMovie: (NSString*)url_string{ //helper
    NSLog(@"playMovie: %@", url_string );
    appDelegate.allowAllOrients = YES;
    [_moviePlayer.view removeFromSuperview];
    NSString* path = [NHelper pathToVideoFile:url_string];
    NSString* myImagePath = [[NSBundle mainBundle]
                             pathForResource:[CatalogHelper video_filename:url_string] ofType:@"mp4"];
    if (myImagePath != nil) {
        NSURL *url = [NSURL fileURLWithPath:myImagePath];
        
        _moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:_moviePlayer];
        
        _moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        _moviePlayer.controlStyle = MPMovieControlStyleDefault;
        _moviePlayer.shouldAutoplay = YES;
        [self.view addSubview:_moviePlayer.view];
        [_moviePlayer setFullscreen:YES animated:YES];
    }
    else if (![url_string isEqual:[NSNull null]] && url_string.length > 0 ){
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        NSLog(@"path: %@", path);
        //        BOOL fileExistBundle = [[NSFileManager defaultManager] fileExistsAtPath:path];
        
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
            [_moviePlayer.view removeFromSuperview];
            if (![url_string isEqual:[NSNull null]] && url_string.length > 0 ){
                NSLog(@"PLay online");
                NSLog(@"urlstring: %@", url_string );
                _moviePlayer =  [[MPMoviePlayerController alloc]
                                 initWithContentURL:[NSURL URLWithString: url_string]];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(moviePlayBackDidFinish:)
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                                           object:_moviePlayer];
                
                _moviePlayer.controlStyle = MPMovieControlStyleDefault;
                _moviePlayer.shouldAutoplay = YES;
                [self.view addSubview:_moviePlayer.view];
                [_moviePlayer setFullscreen:YES animated:YES];
            }
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
        appDelegate.playMovie = NO;
        [player.view removeFromSuperview];
        
        
        
    }
}

//MOVIE END


//odpalane chyabtyko po spisie tresci
- (DoubleCatalogViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >=  appDelegate.currentIshue->pagesNum/2 && !appDelegate->orientPion) {
        return nil;
    }
    if (index >=  appDelegate.currentIshue->pagesNum && appDelegate->orientPion) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DoubleCatalogViewController* dupa;
    
    
        dupa = [[DoubleCatalogViewController alloc]
                initWithNibNameIndex:[NHelper isIphone] ?  @"DoubleCatalogViewControllerIphone" : @"DoubleCatalogViewController" bundle:nil index:index];
    
    
    //TEST
    self.current_left_page = dupa.current_left_page;
    
    self.imageFile = dupa.imageFile;
    self.imageFileRight = dupa.imageFileRight;
    
    self.pageIndex = index;
    
    return dupa;
}

-(void) setPageLeftPageNum: (int)left{
    __weak UIPageViewController* pvcw = (UIPageViewController*)self.parentViewController;
    DoubleCatalogViewController* page = [self viewControllerAtIndex:left-0];
    [pvcw setViewControllers:@[page]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES completion:^(BOOL finished) {
                        UIPageViewController* pvcs = pvcw;
                        if (!pvcs) return;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [pvcs setViewControllers:@[page]
                                           direction:UIPageViewControllerNavigationDirectionForward
                                            animated:NO completion:nil];
                        });
                    }];
}

-(void)gotopage:(int)left{
    NSLog(@"gotopage setPage : %d", left );
    self.firstPage = NO;
    [appDelegate.rootViewController hideThumbAndNav];
    Page* pagetoshow = [[Page alloc] initWithPageId:left issue:appDelegate.currentIshue];
    [self setPageLeftPageNum:[pagetoshow getPageViewNum]-1];
    
    [[IssuesManager sharedInstance] logIssuePageSpisTresc:pagetoshow];
}

- (void)playAudio:(ContentButton*)contentButton {
    NSString* filename = contentButton.action;
    NSString* path = [NHelper pathToVideoFile:filename];
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
            url = [NSURL URLWithString:
                   [NSString stringWithFormat:@"http://ygd13959497c.arfixer.eu/setupo_cms/%@", filename]];
            
            if ( [self.webAudioPlayer rate] == 0.0 ){
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


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.myZoomableView;
}

-(void)zoomEndsIphone:(UIScrollView *)scrollView{
    if ([[NHelper platformSpeed] isEqualToString:@"ivs"]){
        self.lmyImagePdf.hidden = NO;
        self.rmyImagePdf.hidden = NO;
        self.lmyImagePdf.alpha = 1.0f;
        self.rmyImagePdf.alpha = 1.0f;
        [CatalogHelper performSelector:@selector(changepngtopdfIphone:) withObject:self afterDelay:1.5];
    }
    else if ([[NHelper platformSpeed] isEqualToString:@"is"]){
        [CatalogHelper performSelector:@selector(changepngtopdfIphone:) withObject:self afterDelay:1.1];
    }
    else{
        [CatalogHelper performSelector:@selector(changepngtopdfIphone:) withObject:self afterDelay:0.5];
    }
}

-(void)zoomEnds:(UIScrollView *)scrollView{
    if ( [NHelper isIphone] ){
        [self zoomEndsIphone:scrollView];
    }
    else{
        if( scrollView.zoomScale == 1.0 && ![NHelper isIphone] && YES ){
            NSLog(@"PNG");
            self.lmyImagePdf.hidden = YES;
            self.rmyImagePdf.hidden = YES;
            self.lmyImagePdf.alpha = 0.0f;
            self.rmyImagePdf.alpha = 0.0f;
            self.lmyImagePng.hidden = NO;
            self.rmyImagePng.hidden = NO;
        }
        else{
            NSLog(@"PDF");
            
            if ([[NHelper platformSpeed] isEqualToString:@"vvs"]){
                self.lmyImagePdf.hidden = NO;
                self.rmyImagePdf.hidden = NO;
                self.lmyImagePdf.alpha = 1.0f;
                self.rmyImagePdf.alpha = 1.0f;
                
                [CatalogHelper performSelector:@selector(changepngtopdf:) withObject:self afterDelay:1.75];
            }
            else if ([[NHelper platformSpeed] isEqualToString:@"vs"]){
                self.lmyImagePdf.hidden = NO;
                self.rmyImagePdf.hidden = NO;
                self.lmyImagePdf.alpha = 1.0f;
                self.rmyImagePdf.alpha = 1.0f;
                [CatalogHelper performSelector:@selector(changepngtopdf:) withObject:self afterDelay:1.5];
            }
            else if ([[NHelper platformSpeed] isEqualToString:@"s"]){
                [CatalogHelper performSelector:@selector(changepngtopdf:) withObject:self afterDelay:1.5];
            }
            else{
                [CatalogHelper performSelector:@selector(changepngtopdf:) withObject:self afterDelay:0.5];
            }
        }
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if ( scrollView.zoomScale <= 1.05 && [NHelper isIphone] ){
        [scrollView setZoomScale:1.0f];
    }
    
//    [self zoomEnds:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if( [NHelper isIphone]){
        scrollView.scrollEnabled = YES;
    }
    else{
        if ( scrollView.zoomScale <= 1.05 )
            scrollView.scrollEnabled = NO;
        else
            scrollView.scrollEnabled = YES;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end