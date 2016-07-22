
#import "TuiCatalogGalleryController.h"
#import "FruitIAPHelper.h"
#import "STabBarControler.h"
#define ZOOM_STEP 2.0  


@interface TuiCatalogGalleryController (UtilityMethods)  
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;  
@end  

@implementation TuiCatalogGalleryController

@synthesize imageScrollView, imageView;
@synthesize fetchedResultsController, managedObjectContext;


+(NSMutableArray*)getTabliceDanychKatalogowych{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Advisor" ofType:@"plist"];
    NSDictionary *texts = [NSDictionary dictionaryWithContentsOfFile:path];	
    NSMutableArray* _categoriesArray = [[NSMutableArray alloc] initWithArray:[texts objectForKey:@"Catalogs"]];
    return _categoriesArray;
}




-(void)preapreLoadingIndicatorView{
    self._hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self._hudView.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:28.0f/255.0f blue:75.0f/255.0f alpha:0.85f];
    self._hudView.clipsToBounds = YES;
    self._hudView.layer.cornerRadius = 10.0;
    self._hudView.layer.borderWidth = 1.0f;
    self._hudView.layer.borderColor = [UIColor blackColor].CGColor;
    
    indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indView.frame = CGRectMake(65, 65, indView.bounds.size.width, indView.bounds.size.height);
    indView.center = CGPointMake(50, 50);
    [self._hudView addSubview:indView];
    [indView startAnimating];
    
    progressViewSmall = [[UIProgressView alloc] initWithFrame:CGRectMake(5, 90, 90, 20)];
//    progressViewSmall.center = CGPointMake(50, 90);
    progressViewSmall.progress = 0.25;
    [self._hudView addSubview:progressViewSmall];
    
    CGPoint centerImageView = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self._hudView.center = centerImageView;
   
    
    
    [self.view addSubview:self._hudView];
    self._hudView.hidden = YES;
}




- (void)viewDidLoad{
    [super viewDidLoad];
    [self preapreLoadingIndicatorView];
    self._hudView.hidden = NO;
    [self.view bringSubviewToFront:self._hudView];
    
    active_catalog_id = 1;
    NSLog(@"TUI VIEW DID DLOAD");
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    imageScrollView.bouncesZoom = YES;
    imageScrollView.delegate = self;  
    imageScrollView.clipsToBounds = YES;
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xx_thumb"]];
    imageView.userInteractionEnabled = YES;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth );
    [imageView setFrame:CGRectMake( 0.0f, 0.0f, imageScrollView.frame.size.width, imageScrollView.frame.size.height)]; //notice this
    [imageScrollView addSubview:imageView];  
    imageScrollView.contentSize = [imageView frame].size;
    imageScrollView.layer.cornerRadius = 5;
    imageScrollView.layer.masksToBounds = YES;
    imageScrollView.layer.borderColor = [UIColor blackColor].CGColor;
    imageScrollView.layer.borderWidth = 0.5f;
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [imageScrollView frame].size.height  / [imageView frame].size.height;
    //imageScrollView.maximumZoomScale = 1.0;
    imageScrollView.minimumZoomScale = minimumScale;
    imageScrollView.zoomScale = minimumScale;
    [self setButtons];
    
    [self setTapAndSwipeDetails];
    [self setViewDetails];
    [self.view addSubview:imageScrollView];
    
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [self.view bringSubviewToFront:self._hudView];
    self._hudView.hidden = YES;
}





-(void)downloadFileExtra
{
    NSLog(@"downloadFileExtra: %@", filesToDownload );
    if ( [filesToDownload count] ){
        NSString* filename = [filesToDownload objectAtIndex:0];
        NSString* url = [current_catalog przygotujUrlDoPlikuZdjeciaCatalogu:filename];
        connection_filepath = [current_catalog przygotujPathDoPlikuZdjeciaCatalogu:filename];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:connection_filepath forKey:@"connection_filepath"];
        [prefs setObject:[NSString stringWithFormat:@"%d",666] forKey:@"downloading_page"];

        if ( ![[NSFileManager defaultManager] fileExistsAtPath: connection_filepath ] ){
            connection_num = 666;
            NSURL * url_to_download = [NSURL URLWithString:url];
            responseData = [[NSMutableData alloc] init];
            NSURLRequest* updateRequest = [NSURLRequest requestWithURL: url_to_download];
            NSLog(@"downloadFileExtra::url_to_download: %@", url_to_download);
            connection = [[NSURLConnection alloc] initWithRequest:updateRequest delegate:self];
            [connection start];
        }
        else {
            NSLog(@"fileexist");
            if ( [filesToDownload count] ){
                [filesToDownload removeObjectAtIndex:0];
                [self downloadFileExtra];
            }
            else{
                connection_inprogress = NO;
            }
        }
    }
    else {
        connection_inprogress = NO;
    }
}

-(void)downloadFile
{
    currentFileId = 0;
    NSLog(@"connection_inprogress: %d", connection_inprogress );
    if ( !connection_inprogress ){
        NSLog(@"downloadFile::filesToDownload: %@", filesToDownload );
        if ( [filesToDownload count] ){
            connection_inprogress = YES;
            NSString* filename = [filesToDownload objectAtIndex:currentFileId];
            NSString* url = [current_catalog przygotujUrlDoPlikuZdjeciaCatalogu:filename];
            connection_filepath = [current_catalog przygotujPathDoPlikuZdjeciaCatalogu:filename];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:connection_filepath forKey:@"connection_filepath"];
            [prefs setObject:[NSString stringWithFormat:@"%d",currentFileId] forKey:@"downloading_page"];
            
            NSLog(@"filename: %@", filename );
            NSLog(@"url: %@", url );
            
            if ( ![[NSFileManager defaultManager] fileExistsAtPath: connection_filepath ] ){
                connection_num = 666;
                
                responseData = [[NSMutableData alloc] init];
                
                NSURL * url_to_download = [NSURL URLWithString:url];
                
                
                NSURLRequest* updateRequest = [NSURLRequest requestWithURL: url_to_download];
                NSLog(@"downloadFile::url_to_download:%@",url_to_download);
                connection = [[NSURLConnection alloc] initWithRequest:updateRequest delegate:self];
                [connection start];
            }
            else {
                NSLog(@"fileexist");
                if ( [filesToDownload count] ){
                    [filesToDownload removeObjectAtIndex:0];
                    [self downloadFileExtra];
                }
                else{
                    connection_inprogress = NO;
                }
            }
        }//count
        //        else{
        //            connection_inprogress = NO;
        //        }
    }
}

-(void)pobierzBrakujacyPlik:(int)strona_num
{
    
    Ishue* i = current_catalog.ishue;
    NSMutableArray* pages = (NSMutableArray*)i.pages;
    NSDictionary* page = [pages objectAtIndex:strona_num-1];
    NSLog(@"Ishue: %d",  [[page objectForKey:@"id"] integerValue] );
    
    NSString* filename = [NSString stringWithFormat:@"%d.png",  [[page objectForKey:@"id"] integerValue] ];
    NSString* filePath = [current_catalog przygotujPathDoPlikuZdjeciaCatalogu:filename];
    
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath: filePath ] ){
        NSString* current_url = [current_catalog przygotujUrlDoPlikuZdjeciaCatalogu: filename];
        BOOL already_in_array = NO;
        for ( NSString* test in filesToDownload){
            if ( [test isEqualToString:filename] ){
                already_in_array = YES;
            }
        }
        if ( !already_in_array ){
            NSLog(@"nie istnieje i nie ma w tablicy do pobrania: %@ => filename: %@", current_url, filename);
            [filesToDownload addObject:filename];
            NSLog(@" addObject: %@", filename);
            NSLog(@" filesToDownload: %@", filesToDownload);
            NSLog(@"");
        }
    }
    else{
        //        NSLog(@" istnieje");
    }
}


-(void)sprawdzCzyPobranoPlusMinus :(int)delta{
    [self.pageLabel setText:[NSString stringWithFormat:@"%d / %d", current_catalog->current_page+1, current_catalog->page_count ]];
    
    
    int strona_start = ( current_catalog->current_page - delta );
    strona_start = (strona_start<1) ? 1 : strona_start;
    int strona_end = ( current_catalog->current_page + delta );
    int liczba_stron = current_catalog->page_count;
    strona_end = (strona_end>liczba_stron) ? liczba_stron : strona_end;
    NSLog(@"strony do testu: %d - %d", strona_start, strona_end );
    for ( int i=strona_start; i<=strona_end; i++){
        [self pobierzBrakujacyPlik :i];
    }
    [self downloadFile];
}


-(void)setTapAndSwipeDetails{
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    //Add a left swipe gesture recognizer
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [imageScrollView addGestureRecognizer:recognizer];
    //    [recognizer release];
    //Add a right swipe gesture recognizer
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleSwipeRight:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [imageScrollView addGestureRecognizer:recognizer];
    
    //    [recognizer release];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];
    [imageView addGestureRecognizer:twoFingerTap];
    
}

-(void)setViewDetails{
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.9f];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0]];
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
//    self.view.layer.borderColor = [UIColor colorWithRed:0.93 green:146.0/255.0 blue:16.0/255.0 alpha:1.0].CGColor;
    self.view.layer.borderColor = appDelegate.presetColorFiolet.CGColor;
    self.view.layer.borderWidth = 1.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius = 1.0f;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.view.layer.shadowOpacity = 0.5f;
    // make sure we rasterize nicely for retina
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.view.layer.shouldRasterize = YES;

}


-(void)setButtonStyle:(UIButton*)button size:(float)size{
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:size];
    button.titleLabel.textColor = [UIColor colorWithRed:0.93 green:146.0/255.0 blue:16.0/255.0 alpha:1.0];
    
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 0.5f;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    
}

-(void)setButtons{
    
    switch (appDelegate.currentIshue->price) {
        case 0: [buttonBuy setTitle:@"FREE" forState:UIControlStateNormal];
            [self setButtonStyle:buttonBuy size:16.0];
            break;
        case 1:
            [buttonBuy setTitle:@"$0.99" forState:UIControlStateNormal];
            [buttonBuy setTitle: [@"ALREADY PAID" capitalizedString] forState:UIControlStateNormal];
            
            break;
        case 2: [buttonBuy setTitle:@"$1.99" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    
    
    [buttonShare setTitle: [@"Share" capitalizedString] forState:UIControlStateNormal];
    [self setButtonStyle:buttonShare size:15.0];
    
    
    if ( [appDelegate isFav:appDelegate.currentIshue->ishue_id] ){
        [buttonAddToFav setTitle: [@"REMOVE FROM FAVOURITE" capitalizedString] forState:UIControlStateNormal];
    }
    else{
        [buttonAddToFav setTitle: [@"ADD TO FAVOURITE" capitalizedString] forState:UIControlStateNormal];
    }
    [self setButtonStyle:buttonAddToFav size:15.0];
    
    
//    buttonAddToFav.layer.shadowRadius = 0.0f;
//    buttonAddToFav.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    buttonAddToFav.layer.shadowOpacity = 0.5f;
    
    [ishueTopic setFont:[UIFont fontWithName:@"System" size:10.0f]];
    ishueTopic.textColor = [UIColor blackColor];
    NSLog(@"label:%@", ishueTopic.text);
}



-(void)setPageButtonValue{
    NSArray *buttonBarItems = toolbar.items;
    UIBarItem* bPageCount = [buttonBarItems objectAtIndex:4];
    
    [bPageCount setTitle:[NSString stringWithFormat:@"%d / %d", 
                          [current_catalog getCurrentPage], [current_catalog getPageCount]]];
}


-(IBAction)addToFav:(id)sender{
    if ( [appDelegate isFav:appDelegate.currentIshue->ishue_id] ){
        [appDelegate removeFromFav: current_catalog.ishue->ishue_id];
    }
    else{
        [appDelegate addToFav: current_catalog.ishue->ishue_id];
    }
    [self setButtons];
}


-(IBAction)shareOnFb:(id)sender{
    NSArray *activityItems;
    activityItems = @[@"Test test just test", [UIImage imageNamed:@"2_thumb"] ];
    appDelegate.viewController.modalView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
    STabBarControler* sttab = (STabBarControler*)appDelegate.viewController.tabBarController;
    [sttab hideIt];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:nil];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL done){
         if (done) {
             NSLog(@"Success");
             STabBarControler* sttab = (STabBarControler*)appDelegate.viewController.tabBarController;
             [sttab showIt];
         }
         else {
             NSLog(@"Error/Cancel");
             STabBarControler* sttab = (STabBarControler*)appDelegate.viewController.tabBarController;
             [sttab showIt];
         }
         
     }];
    
    
    [appDelegate.viewController presentViewController:activityController
                       animated:YES completion:nil];
    
    
}

//
//-(void)setPr:(
//
//-(void)incProgess{
//    double starttime = [[NSDate date] timeIntervalSince1970];
//    double curentime = starttime;
//    double endtime = starttime+60;
//    int licznik = 0;
//    double pr = 0.0f;
//    while ( curentime < endtime ) {
//        
//        curentime = [[NSDate date] timeIntervalSince1970];
//        double xxx = curentime - starttime;
//        double prN = round(10*(xxx/ 60))/10;
//        
//        if ( prN > pr ){
//            pr = prN;
//            NSLog(@"progress: %f", pr );
////            progressViewSmall.progress = pr;
//            [progressViewSmall setProgress:pr animated:YES];
////            [NSThread detachNewThreadSelector:@selector(setProgress:) toTarget:progressViewSmall withObject:pr];
//        }
//        
//    }
////    float prog = count / limit;
//    
////    count++;
//    
////    [self incProgess];
//}


-(IBAction)selectIshueToView:(id)sender{
    NSLog(@"selectIshueToView");
    self._hudView.hidden = NO;
    progressViewSmall.progress = 0.05f;
    [self.view bringSubviewToFront:self._hudView];
    //alert
    
    
    
    [NSThread detachNewThreadSelector:@selector(qwerty) toTarget:self withObject:nil];
    
//self
    
//    [appDelegate unpackSelectedIshue:current_catalog.ishue->ishue_id];
    //teraz poinien sprawdzic czy plik zip istnieje jak tak to rozpakowac jak nie to powiedziec ile mb
    
    

    
//    [[FruitIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
//        if (success) {
//            NSLog(@"products: %@", products);
//            
//            SKProduct *product = [products objectAtIndex:0];
//            
//            NSLog(@"Buying %@...", product.productIdentifier);
//            [[FruitIAPHelper sharedInstance] buyProduct:product];
//            
//        }
////        [self.refreshControl endRefreshing];
//    }];
    
    
    //
//    
//    if([SKPaymentQueue canMakePayments]){
//        NSLog(@"SKPaymentQueue canMakePayments => YES");
//        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:
//                                      [NSSet setWithObject:@"com.marcin.setupo"]];
//        request.delegate = self;
//        
//        
//        [request start];
//    }
//    else{
//        NSLog(@"SKPaymentQueue canMakePayments => NO");
//    }
    
//    [appDelegate.viewController ishueButtonClicked];
    
}

-(void)qwerty{
    [appDelegate.viewController ishueButtonClicked];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    NSLog(@"products: %@", products );
    
    for (SKProduct *product in products)
    {
        // Display the a “buy product” screen containing details
        // from product object
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        // Handle invalid product IDs if required
    }
}






- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)changePage:(int)animType {
    imageView.alpha =0.0f;
    NSLog(@"--->%d/%d", current_catalog->current_page, current_catalog->page_count );
    UIImage* newImage = [current_catalog getCurrentImgFromPages];
//    [self.pageLabel setText:[NSString stringWithFormat:@"%d / %d", current_catalog->current_page, current_catalog->page_count ]];
    
    
    
    NSLog(@"newImage: %@", newImage );
    [imageView setImage:newImage];
    NSLog(@"newImage sizes: h:%f", newImage.size.height );
    switch (animType) {
        case 0:
            [imageView setFrame:CGRectMake( 15.0f, 0.0f, imageView.frame.size.width, imageView.frame.size.height)];
            break;
        case 1:
            [imageView setFrame:CGRectMake( -320.0f, 0.0f, imageView.frame.size.width, imageView.frame.size.height)];
            break;
        case 2:
            [imageView setFrame:CGRectMake( 320.0f, 0.0f, imageView.frame.size.width, imageView.frame.size.height)];
            break;
        case 3:
            [imageView setFrame:CGRectMake( 15.0f, 500.0f, imageView.frame.size.width, imageView.frame.size.height)];
            break;
        default:
            [imageView setFrame:CGRectMake( 15.0f, 0.0f, imageView.frame.size.width, imageView.frame.size.height)];
            break;
    }
        [UIView beginAnimations:@"animateTableView" context:nil];
        [UIView setAnimationDuration:0.4];
//        [imageView setFrame:CGRectMake( 15.0f, 0.0f, imageView.frame.size.width, imageView.frame.size.height)];
        imageView.alpha =1.0f;
        
    NSLog(@"newImage sizes: h:%f", newImage.size.height );
    
    double scale_out = 0.0f;
    double height = imageView.frame.size.height;
    scale_out = (height / newImage.size.height);
    double new_width = newImage.size.width*scale_out;
    double margin = ( imageScrollView.frame.size.width - new_width ) / 2;
//    [imageView setFrame:CGRectMake( margin, 0.0f, new_width, height)];
    [imageView setFrame:CGRectMake( margin, 0.0f, 260, 370)];
    
//    [imageView setFrame:CGRectMake( 10, 0.0f, 100, 200)];
    
   
    [UIView commitAnimations];
    
    
    newImage = nil;
    
}  




- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {  
    NSLog(@"swipeLeft: %d < %d", [current_catalog getCurrentPage], [current_catalog getPageCount]);
   
    if ( [current_catalog getCurrentPage] < [current_catalog getPageCount]-1 ){ //to -1 mnie martwi
        [current_catalog incCurrentPage];
    
        [self changePage:2];
//        [self setPageButtonValue];
        [self sprawdzCzyPobranoPlusMinus:3];
        
        
        
        
    }
}  



- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer { 
    NSLog(@"swipeRight: %d > 1", [current_catalog getCurrentPage] );
    if ( [current_catalog getCurrentPage] >= 1 ){
        [current_catalog decCurrentPage];
        
        [self changePage:1];
        [self setPageButtonValue];
        [self sprawdzCzyPobranoPlusMinus:3];
        
    }
}  


#pragma mark UIScrollViewDelegate methods  

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {  
    return imageView;  
}  

#pragma mark TapDetectingImageViewDelegate methods  

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {  
    // single tap does nothing for now  
}  

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {  
    // zoom in  
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;  
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
    [imageScrollView zoomToRect:zoomRect animated:YES];  
}  

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {  
    // two-finger tap zooms out  
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;  
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
    [imageScrollView zoomToRect:zoomRect animated:YES];  
}  

#pragma mark Utility methods  

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {  
    
    CGRect zoomRect;  
    
    // the zoom rect is in the content view's coordinates.   
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.  
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.  
    zoomRect.size.height = [imageScrollView frame].size.height / scale;  
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;  
    
    // choose an origin so as to get the right center.  
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);  
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);  
    
    return zoomRect;  
}  








#pragma mark -
#pragma mark NSURLConnectionDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
    filesize = [NSNumber numberWithLongLong: [response expectedContentLength] ];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ( connection_num == 0 ){
        NSLog(@"Download 0 connectionDidFinishLoading...");
    }
    else if ( connection_num == 666 ){
        NSLog(@"Download 666 connectionDidFinishLoading... " );
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* filepath = [prefs stringForKey:@"connection_filepath"];
        int downloaded_page = [current_catalog getPageNumFromFileName:filepath];
        UIImage *image = [UIImage imageWithData:responseData];
        
        if ( image == nil ){
            NSLog(@"ERRRRRRROOOOOOOR IADVISERAPPDELEGATE: 445 %@", filepath);
        }
        else {
            NSNumber* curLength = [NSNumber numberWithLong:[responseData length] ];
            if ( [curLength intValue] != [filesize intValue] ){
                NSLog(@"ERROR INCORECT SIZES: %i ? %i %@", [curLength intValue],[filesize intValue], filepath );
            }
            else {
                NSLog(@"filepath: %@ => downloaded_page:%d ", filepath, downloaded_page );
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:image];
                [current_catalog->imagesNames replaceObjectAtIndex:downloaded_page withObject:filepath];
                
                
            NSLog(@"downloaded_page: %d ?? current_catalog->current_page: %d", downloaded_page, current_catalog->current_page );
                
                if ( downloaded_page == current_catalog->current_page ){
                    UIImage* current_image = [current_catalog przygotujImageAktywnejStrony];
                    [self.imageView setImage:current_image];
                }
                
                NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                if ( imageData == nil ){
                    NSLog(@"ERROR KURWA");
                }
                bool writed = [imageData writeToFile:filepath atomically:NO];
                NSLog(@"filepath: %@ writed ? %d", filepath, writed);
                NSLog(@"filesToDOw:%@", filesToDownload);
                
                
                if ( [filesToDownload count] ){
                    [filesToDownload removeObjectAtIndex:0];
                    //jezeli current page jest loading960_0
                    if ( [[current_catalog->imagesNames objectAtIndex:current_catalog->current_page] isEqual:@"loading960_0.png"] ){
                        //tzn ze trzeba znalezc go na liscie to download i przeniesc na gore
                        //dla ulatwienia po prostu dodaje go na poxatku
                        NSString* filename = [current_catalog przygotujFileNameStrony:current_catalog->current_page];
                        [filesToDownload insertObject:filename atIndex:0];
                    }
                }
            }
        }
        image = nil;
        
        [self downloadFileExtra];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    connection_inprogress = YES;
	[responseData appendData:data];
	NSNumber* curLength = [NSNumber numberWithLong:[responseData length] ];
    
    if ( [filesize floatValue] > 0 ){
        float progress = [curLength floatValue] / [filesize floatValue] ;
        if ( progress < 0.02 || progress > 0.98 ){
            NSLog(@"[filesize floatValue]...  %f",  [filesize floatValue] );
            NSLog(@"Download progress...  %f",  progress );
        }
        
        UIImage* img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:0] ];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* filepath = [prefs stringForKey:@"connection_filepath"];
        int downloaded_page = [current_catalog getPageNumFromFileName:filepath];
        NSLog(@"downloaded_page: %d ?? current_catalog->current_page: %d", downloaded_page, current_catalog->current_page );
        if ( downloaded_page == current_catalog->current_page ){
            
            if ( progress < 0.2 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:1] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 0.4 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:2] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 0.6 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:3] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 0.8 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:4] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 1.0 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:5] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else {
                NSLog(@"downloaded_page %d",  downloaded_page );
            }
            
            [self.imageView setImage:img];
            img = nil;
        }
    }
    else{
        NSLog(@"Download progress... dupa");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection_inprogress = NO;
	NSLog(@"Download failed");
}



@end
