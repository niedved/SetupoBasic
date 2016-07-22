#import "GalleryViewController.h"
#import "SSZipArchive.h"

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"xxxx");
    
    filesToDownload = [[NSMutableArray alloc] init];
    CGRect rect = [[UIScreen mainScreen] bounds];
    _transitionImageView = [[LTransitionImageView alloc] initWithFrame: CGRectMake(0, 0, rect.size.height, rect.size.width)];
    _transitionImageView.animationDuration = 0.5;
    [self.view addSubview:_transitionImageView];
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [leftSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [rightSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    tap.delegate = self;

    
    
    [self.view addGestureRecognizer:tap];
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
//    current_gallery_id = 43;
    current_image_num = 0;
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"current gallery id: %d", current_gallery_id );
    [self prepareImagesForGallery];
}



- (void)showMessage {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Close Galery"
                                                      message:@"Close this galery and come back to Issue view?"
                                                     delegate:self
                                            cancelButtonTitle:@"NO"
                                            otherButtonTitles:@"YES", nil];
    
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"NO"])
    {
        NSLog(@"NO was selected.");
    }
    else if([title isEqualToString:@"YES"])
    {
        NSLog(@"YES was selected.");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void) handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    
    
    NSLog(@"TAPED!!!!: %f,%f", location.x,location.y);
    [self showMessage];
    
}

-(void)prepareImagesForGallery{
    galleryImages = [[NSMutableArray alloc] init];
    //unzip
    [self updateGalleryFilesToDownload];
    
    NSLog(@"files to downaload: %@", filesToDownload );
    
    
    for (NSString* imgName in filesToDownload) {
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgName]]];
        [galleryImages addObject:img];
    }
    
    //a te
    
    _transitionImageView.image = [galleryImages objectAtIndex:0];
    
}



-(NSString*)pathToIssuePagesFile{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFilePath = documentsDirectory;//[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",ishue_id] ];
    return fullFilePath;
}

-(void)updateGalleryFilesToDownload{
    filesToDownload = [[NSMutableArray alloc] init];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    filesForIssue = (NSMutableArray*)[appDelegate.DBC getFileListForGallery:current_gallery_id];
    //    NSLog(@"filesForGallery: %@", filesForIssue );
    for (NSString* fileName in filesForIssue) {
        NSString* urltotest = [[self pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
        
        BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:urltotest];
//        NSLog(@"fileForGallery: %@ %@ %d", filesForIssue, urltotest, pageFileExists );
        
        if ( !pageFileExists ){
            [filesToDownload addObject:
             [NSString stringWithFormat:@"http://cms.blipar.pl/Resources/gallery/%d/%@", current_gallery_id, fileName]
             ];
        }
        else{
            NSData *imageData = [NSData dataWithContentsOfFile:urltotest];
    
            
            UIImage *img = [UIImage imageWithData:imageData];
            [galleryImages addObject:img];
        }
    }
}



-(void) leftSwipe:(UIPinchGestureRecognizer *)gestureRecognizer {
    NSLog(@"rightSwipePPPP");
    if ( current_image_num < [galleryImages count]-1 ){
        current_image_num++;
        [self moveright];
    }
}

-(void) rightSwipe:(UIPinchGestureRecognizer *)gestureRecognizer {
    NSLog(@"leftSwipePPPP");
    if ( current_image_num > 0 ){
        current_image_num--;
        [self moveleft];
    }
}


-(NSString*)pathToGalleryZipFile:(int)g_id{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* zipNameFile = [NSString stringWithFormat:@"%d_ipad.zip", g_id];
    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:zipNameFile];
    return fullFilePath;
}





-(BOOL)unpackSelectedGallery{
    NSLog(@"gallery to unpack: %d", current_gallery_id);
    NSString *fullFilePath = [self pathToGalleryZipFile:current_gallery_id];
    BOOL zipFileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath];
    NSLog(@"unzip file exist: %@ %d", fullFilePath, zipFileExists );
    
    if ( !zipFileExists ){
        return NO;
    }
    else{
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath error:&attributesError];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *xxx = [documentsDirectory stringByAppendingPathComponent:@"galeria/"];
//        NSString* zipNameFile = @"43";
        
        NSLog(@"link: %@", xxx);
        unsigned long long fileSize = [fileAttributes fileSize];
        BOOL isunziped = [SSZipArchive unzipFileAtPath:fullFilePath toDestination:xxx];
        if ( isunziped ){
            NSLog(@"unziped");
            NSError* error;
            NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:xxx error:&error];
            
            NSLog(@"files unziped: %@", directoryContents );
            for (NSString* imgName in directoryContents) {
                NSString *pathtofileimg = [xxx stringByAppendingPathComponent:imgName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:pathtofileimg]) {
                    NSData *imageData = [NSData dataWithContentsOfFile:pathtofileimg];
                    UIImage *img = [UIImage imageWithData:imageData];
                    [galleryImages addObject:img];
                }
            }
            
            _transitionImageView.image = [galleryImages objectAtIndex:0];
            
        }
        else{
            NSLog(@"ERROR WHENE UNZIPED");
        }
        return YES;
    }
};




//-(UIImage*)

-(void)moveleft{
    CGFloat delay = 0.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        _transitionImageView.animationDirection = AnimationDirectionLeftToRight;
        _transitionImageView.image = [galleryImages objectAtIndex:current_image_num];
    });
}
-(void)moveright{
    CGFloat delay = 0.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        _transitionImageView.animationDirection = AnimationDirectionRightToLeft;
        _transitionImageView.image = [galleryImages objectAtIndex:current_image_num];
    });
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}



//
//
////#DOWNLOAD
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
//    NSData *data = [NSData dataWithContentsOfURL:location];
//    
//    
//    NSArray *chunks = [currentlyDownloadingFile componentsSeparatedByString: @"/"];
//    NSString* pathToFile = [currentlyDownloadingFileDestination stringByAppendingPathComponent:[chunks lastObject]];
//    //    [AppDelegate LogIt:[NSString stringWithFormat:
//    //                       @"DOWNLOADED: %@ => %@ => %@", currentlyDownloadingFile, currentlyDownloadingFileDestination, pathToFile ]];
//    [data writeToFile:pathToFile atomically:YES];
//    
//    BOOL czek = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile];
//    [self actionTest];
//}
//
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
//    NSLog(@"RESUME");
//}
//
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    
//
//    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
//    NSArray *chunks = [currentlyDownloadingFile componentsSeparatedByString:@"."];
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* extName = [chunks lastObject];
//    
//}



@end