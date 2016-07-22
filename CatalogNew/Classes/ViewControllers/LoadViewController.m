#import "LoadViewController.h"
#import "AppDelegate.h"
#import "YLProgressBar.h"
#import "NHelper.h"
#import "SSZipArchive.h"

//if( [link rangeOfString:@".pdf"].location != NSNotFound ){


@interface LoadViewController(){
    AppDelegate* appDelegate;
    NSURLSession *session;
    unsigned long numberOfFiles;
    unsigned long numberOfVideos;
    unsigned long numberOfAudios;
    unsigned long numberOfImages;
    float step1;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
// Configure progress bars
- (void)initFlatRainbowProgressBar;

@end

@implementation LoadViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    NSString* ident = [NSString stringWithFormat:@"com.gomega.optimal2_%f", [[NSDate date] timeIntervalSince1970] ];
    NSURLSessionConfiguration *sessionConfiguration;
    step1 = 40.0f;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:ident];
    }
    else{
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:ident];
    }
    
    
    session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self initFlatRainbowProgressBar];
    [self setProgress:0.0f animated:YES];
}

- (void)initFlatRainbowProgressBar
{
    self.progressBarFlatRainbowView.layer.cornerRadius = self.progressBarFlatRainbowView.frame.size.height / 2;
    self.progressBarFlatRainbow.layer.cornerRadius = 1.0f;
    
    
    self.progressBarFlatRainbowView.layer.cornerRadius = 0.0f;
    self.progressBarFlatRainbow.layer.cornerRadius = 0.0f;
    
//    self.progressBarFlatRainbowView
    
//    NSArray *tintColors = @[[UIColor yellowColor],
////                            [UIColor colorWithRed:3/255.0f green:137/255.0f blue:166/255.0f alpha:1.0f],
////                            [UIColor colorWithRed:228/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
////                            [UIColor colorWithRed:228/255.0f green:9/255.0f blue:139/255.0f alpha:1.0f],
////                            [UIColor colorWithRed:128/255.0f green:169/255.0f blue:39/255.0f alpha:1.0f],
//                            //                            [UIColor colorWithRed:28/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
//                        //    [UIColor colorWithRed:187/255.0f green:16/255.0f blue:34/255.0f alpha:1.0f]];
//    [UIColor colorWithRed:238/255.0f green:39/255.0f blue:36/255.0f alpha:1.0f]];
//    
    
    NSArray *tintColors = @[[NHelper colorFromPlist:@"preview_loader_start"],
//                            [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.5f],
                            //                            [UIColor colorWithRed:3/255.0f green:137/255.0f blue:166/255.0f alpha:1.0f],
                            //                            [UIColor colorWithRed:228/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
                            //                            [UIColor colorWithRed:228/255.0f green:9/255.0f blue:139/255.0f alpha:1.0f],
                            //                            [UIColor colorWithRed:128/255.0f green:169/255.0f blue:39/255.0f alpha:1.0f],
                            //                            [UIColor colorWithRed:28/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
                            [NHelper colorFromPlist:@"preview_loader_end"]];
    _progressBarFlatRainbow.type               = YLProgressBarTypeFlat;
    _progressBarFlatRainbow.progressTintColors = tintColors;
    _progressBarFlatRainbow.hideStripes        = YES;
    _progressBarFlatRainbow.hideTrack          = YES;
    _progressBarFlatRainbow.behavior           = YLProgressBarBehaviorDefault;
}

- (void)viewDidUnload
{
    self.progressBarFlatRainbow       = nil;
    [super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        videoDownloaded = NO;
        galeriesDownloaded = NO;
        audioDownloaded = NO;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    splitPDFAndMakeprevsProcessAllow = NO;
    NSLog(@"viewWillDisapeear");
    
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.appStage = 6;
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidApear");
    if ( !downloadPaused ){
        dispatch_async(dispatch_get_main_queue(), ^{
            filesToDownload = [[NSMutableArray alloc] init];
            [self actionTest: YES pobudka:NO];
        });
    }
    
    downloadPaused = NO;
    
    
//    if ( downloadTask st )
    
}

-(void)viewDidDisappear:(BOOL)animated{
    downloadPaused = YES;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        if (!resumeData) return;
//        [self setResumeData:resumeData];
        [self setDownloadTask:nil];
    }];
    [self dismissViewControllerAnimated:appDelegate->animallowed completion:nil];
}


-(UIImage *)imageForPageIphone:(int)pageNumber document:(CGPDFDocumentRef)document {
    @autoreleasepool {
        CGPDFPageRef pdfPageRef = CGPDFDocumentGetPage(document, pageNumber);
        CGRect pageRect = CGPDFPageGetBoxRect(pdfPageRef, kCGPDFMediaBox);
        // Which you can convert to size as
        CGSize size = pageRect.size;
    
        CGSize size2 = [NHelper getSizeOfCurrentDeviceLandscape];
        [NHelper showSizeParams:size label:@"size"];
        [NHelper showSizeParams:size2 label:@"size"];
        
        
        if ( size2.width < 568.0f ){
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.75);
        }
        else{
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.75);
        }
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        
        CGContextTranslateCTM(context, 0.0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSaveGState(context);
        
        CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(pdfPageRef, kCGPDFCropBox, CGRectMake(0, 0, size.width, size.height), 0, true);
        CGContextConcatCTM(context, pdfTransform);
        
        CGContextDrawPDFPage(context, pdfPageRef);
        CGContextRestoreGState(context);
        
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultingImage;
    }
}



-(UIImage *)imageForPageN:(int)pageNumber document:(CGPDFDocumentRef)document {
    @autoreleasepool {
        CGPDFPageRef pdfPageRef = CGPDFDocumentGetPage(document, pageNumber);
        CGRect pageRect = CGPDFPageGetBoxRect(pdfPageRef, kCGPDFMediaBox);
        // Which you can convert to size as
        
        
        CGSize size = pageRect.size;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
        CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill
        
        
        CGContextSetInterpolationQuality(context, kCGInterpolationLow);
        
        CGContextTranslateCTM(context, 0.0, size.height);
        CGContextScaleCTM(context, 1.0015f, -1.0015f);
        
        CGContextSaveGState(context);

        CGContextDrawPDFPage(context, pdfPageRef);
        CGContextRestoreGState(context);
        
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        return resultingImage;
    }
}


-(void)setLoaderProgress:(NSNumber *)number
{
//    NSLog(@"progress: %f", number.floatValue );
    [_progressBarFlatRainbow setProgress:number.floatValue  animated:YES];
    
}
-(void)splitPDFtoTMPJpg :(CGPDFDocumentRef)document{
    int pagenum = (int)CGPDFDocumentGetNumberOfPages(document);
    NSLog(@"SPLIT PDF TO TMP JPGS: %d", pagenum);
   

    
    if ( pagenum > 1 ){
        for( int i=1; i<=pagenum; i++ ){
            @autoreleasepool {
                if( !splitPDFAndMakeprevsProcessAllow ){
                    return;
                }
                UIImage *image;
                if([NHelper isIphone]){
                    image = [self imageForPageIphone:i document:document];
                    
                }
                else{
                    image = [self imageForPageN:i document:document];
                    
                }
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%d.jpg", ishue_id, i]];
                
                [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
                image = nil;
                [self rescalePage:filePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setProgValue:step1 + (i*(40.0f/pagenum)) text:@"Postęp:"];
                });
            }
        }
    }
}

-(void)splitPDFtoPDFS :(CGPDFDocumentRef)document pathToFile:(NSString*)pathToFile{
    int pagenum = (int)CGPDFDocumentGetNumberOfPages(document);
    NSLog(@"splitPDFtoPDFS: %d", pagenum);
    if ( pagenum > 1 ){
        NSInteger pages = CGPDFDocumentGetNumberOfPages(document);
        
        for (int page = 1; page <= pages; page++)
        {
            if( !splitPDFAndMakeprevsProcessAllow ){
                NSLog(@"break thread");
                return;
            }
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"page_%d_%d.pdf",ishue_id ,page]];
            NSURL *pdfUrlNew = [NSURL fileURLWithPath:pdfPath];
            CGContextRef context = CGPDFContextCreateWithURL((__bridge_retained CFURLRef)pdfUrlNew, NULL, NULL);
            CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:pathToFile];
            CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL(url);
            CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDoc, page);
            CGRect pdfCropBoxRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
            // Copy the page to the new document
            CGContextBeginPage(context, &pdfCropBoxRect);
            CGContextDrawPDFPage(context, pdfPage);
            // Close the source files
            CGContextEndPage(context);
            CGPDFDocumentRelease(pdfDoc);
            CGContextRelease (context);
            NSLog(@"split pdf page: %d", page);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setProgValue:80.0f + (page*(20.0f/pagenum)) text:@"Postęp:"];
            });

        }
    }
}


-(void) splitPDFAndMakeprevs: (NSString*)pathToFile{
  
    
    //
    
    NSLog(@"splitPDFAndMakeprevs: %d %d", splitPDFAndMakeprevsProcessAllow, appDelegate.currentIshue->pagesNum);
    for (int i=1; i<= appDelegate.currentIshue->pagesNum; i++) {
        NSString* pathToFile2 = [NSString stringWithFormat:@"page_%d_%d.pdf", appDelegate.currentIshue->ishue_id, i];
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* pathToFilePdf = [documentsDirectory stringByAppendingPathComponent:pathToFile2];
        if( [[NSFileManager defaultManager] fileExistsAtPath:pathToFilePdf]){
            CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:pathToFilePdf];
            CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(url);
            
            @autoreleasepool {
                if( !splitPDFAndMakeprevsProcessAllow ){
                    return;
                }
                UIImage *image;
                if([NHelper isIphone]){
                    image = [self imageForPageIphone:1 document:document];
                    
                }
                else{
                    image = [self imageForPageN:1 document:document];
                    
                }
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%d.jpg", ishue_id, i]];
                
                [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
                image = nil;
                [self rescalePage:filePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setProgValue:step1 + (i*(60.0f/appDelegate.currentIshue->pagesNum)) text:@"Postęp:"];
                });
            }
        }
    }
    
    /*
    
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:pathToFile];
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(url);
   
    [self splitPDFtoTMPJpg:document];
    
    //downaload zip with splited pdf
    
    */
//    [self splitPDFtoPDFS:document pathToFile:pathToFile];
    
    if( !splitPDFAndMakeprevsProcessAllow ){
        NSLog(@"break thread");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( appDelegate->arlaunhcing ){
            appDelegate->arlaunhcing = NO;
            NSLog(@"allDownloaded: C 351"); //HERE
        }
        else{
            [appDelegate.viewController ishueButtonClicked];
            NSLog(@"allDownloaded: C 355"); //HERE
        }
    });
    
}



-(void) splitPDFOnly: (NSString*)pathToFile{
    NSLog(@"splitPDFOnly: %d", splitPDFAndMakeprevsProcessAllow);
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:pathToFile];
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(url);
    
    [self splitPDFtoPDFS:document pathToFile:pathToFile];
    
    if( !splitPDFAndMakeprevsProcessAllow ){
        NSLog(@"break thread");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate.viewController ishueButtonClicked];
        NSLog(@"allDownloaded: C 371"); //HERE
    });
    
}



- (void)setProgress:(NSNumber*)num
{
    
    CGFloat progress = [num floatValue];
    NSLog(@"progress: %f", progress);
    [_progressBarFlatRainbow setProgress:progress animated:YES];
    
}




-(void)setProgValue:(float)p text:(NSString*)text{
    NSString *txt = [NSString stringWithFormat:@"%@ %.1f0 %@", text, p, @"%"];
    [label1 setText: txt];
//    NSLog(@"%@", txt);
    [self setProgress:p/100 animated:YES];
}

#pragma mark YLViewController Private Methods

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
//    NSLog(@"progress: %f", progress);
    [_progressBarFlatRainbow setProgress:progress animated:animated];
    
}

-(void)downloadFile:(NSString*)url destinationFolder:(NSString*)destinationFolder{
    @autoreleasepool {
        currentlyDownloadingFile = url;
        currentlyDownloadingFileDestination = destinationFolder;
        self.downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:url]];
        [self.downloadTask resume];
    }
}

-(NSString*)pathToIssuePagesFile{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFilePath = documentsDirectory;
    return fullFilePath;
}

-(void)downloadFileForIssue: (NSString*)resourceLink{
    [self downloadFile:
     [NSString stringWithFormat:@"%@/%@",STAGING_URL_NOINDEX, resourceLink ]
     destinationFolder:[self pathToIssuePagesFile] ];
}

-(bool)fileExistForIssue: (NSString*)resourceLink{
    NSString* fileVideo = [self pathToVideoFile:resourceLink];
    return [[NSFileManager defaultManager] fileExistsAtPath:fileVideo];
}

-(void)actionTest:(BOOL)firstTime  pobudka:(BOOL)pobudka{
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    if( pobudka ){
        NSLog(@"POBUDKA");
        [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            if (!resumeData) return;
            [self setDownloadTask:nil];
        }];
        firstTime = YES;
    }
    
    if ( firstTime ){
        [appDelegate.currentIshue loadAllIssueFiles];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setProgValue:0.0f text:@"Postęp:"];
        });
        //add video fiels
        NSMutableArray* videoFilesUnloaded = [appDelegate.currentIshue newVideoFilesForIssue];
        numberOfVideos = [videoFilesUnloaded count];
        for (NSString* link in videoFilesUnloaded) {
            [appDelegate.currentIshue.filesToDownload addObject:link];
        }
        
        NSMutableArray* audioFilesUnloaded = [appDelegate.currentIshue newAudioFilesForIssue];
        numberOfAudios = [audioFilesUnloaded count];
        for (NSString* link in audioFilesUnloaded) {
            [appDelegate.currentIshue.filesToDownload addObject:link];
        }
        
        NSMutableArray* galleriesFilesUnloaded = [appDelegate.currentIshue newGaleriesFilesForIssue:YES];
        numberOfImages = [galleriesFilesUnloaded count];
        for (NSString* link in galleriesFilesUnloaded) {
            [appDelegate.currentIshue.filesToDownload addObject:link];
        }

        numberOfFiles = [appDelegate.currentIshue.filesToDownload count];
    }
    
    unsigned long _count = [appDelegate.currentIshue.filesToDownload count];
    
    if ( [appDelegate.currentIshue.filesToDownload count] > 0 ){
        @autoreleasepool {
            //download next file
            NSString* url = [appDelegate.currentIshue.filesToDownload lastObject];
            [self downloadFile:url destinationFolder:[self pathToIssuePagesFile] ];
        };
    }
    else{
        [appDelegate.currentIshue setPhotos ];
        //all downlaod ale check thumbs ok inf no remake them
        BOOL thumbsCorrectDownloaded = [appDelegate.currentIshue checkThumbsCorrectDownloaded];
        NSLog(@"thumbsCorrectDownloaded: %d", thumbsCorrectDownloaded);
        if( !thumbsCorrectDownloaded ){
            @autoreleasepool {
                
                NSString* fileName = [NSString stringWithFormat:@"%d.pdf",appDelegate.currentIshue->ishue_id];
                NSString* pathToPdfFile = [[appDelegate.currentIshue pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setProgValue:step1 text:@"Postęp:"];
                });
                
                
                splitPDFAndMakeprevsProcessAllow = YES;
                [self performSelectorInBackground:@selector(splitPDFAndMakeprevs:) withObject:pathToPdfFile];
            }
        }
        else{
            BOOL pdfCorrectSplited = [appDelegate.currentIshue checkPdfCorrectSplited];
            
            
            if( !pdfCorrectSplited ){
                NSLog(@"pdfCorrectSplited: %d", pdfCorrectSplited);
                
                @autoreleasepool {
                    NSString* fileName = [NSString stringWithFormat:@"%d.pdf",appDelegate.currentIshue->ishue_id];
                    NSString* pathToPdfFile = [[appDelegate.currentIshue pathToIssuePagesFile] stringByAppendingPathComponent:fileName];
                
                    splitPDFAndMakeprevsProcessAllow = YES;
                    [self performSelectorInBackground:@selector(splitPDFOnly:) withObject:pathToPdfFile];
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if( appDelegate->arlaunhcing ){
                        appDelegate->arlaunhcing = NO;
                        NSLog(@"allDownloaded: C 524"); //HERE
                    }
                    else{
                            [appDelegate.viewController ishueButtonClicked];
                            NSLog(@"allDownloaded: C 528"); //HERE
                    }
                        });
            }
        }
        
    }
}

-(NSString*)pathToVideoFile:(NSString*)fulllink{
    NSArray *chunks = [fulllink componentsSeparatedByString: @"/"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* videoNameFile = [chunks lastObject];
    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:videoNameFile];
    return fullFilePath;
}

//#DOWNLOAD
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSArray *chunks = [currentlyDownloadingFile componentsSeparatedByString: @"/"];
        NSString* pathToFile = [currentlyDownloadingFileDestination stringByAppendingPathComponent:[chunks lastObject]];
        [data writeToFile:pathToFile atomically:YES];
        [appDelegate.currentIshue.filesToDownload removeLastObject];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setProgValue:[self progessa]*step1 text:@"Postęp:"];
        });

        if ([pathToFile rangeOfString:@"Resources/pages/"].location == NSNotFound) {
            if ([pathToFile rangeOfString:@".jpg"].location == NSNotFound && [pathToFile rangeOfString:@".mp4"].location == NSNotFound){
                NSLog(@"pathToFile No Gallery: %@",pathToFile);
                if ( [pathToFile rangeOfString:@".zip"].location != NSNotFound ){
                    NSLog(@"ZIP DOWNLAODED");
                    NSLog(@"UNZIP S");
                    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    [SSZipArchive unzipFileAtPath:pathToFile toDestination:documentsDirectory delegate:self];
                    NSLog(@"UNZIP E");
                }
//                [self splitPDFAndMakeprevs: pathToFile];
            }
            else{
//                NSLog(@"pathToFile Gallery: %@",pathToFile);
            }
        }
        
        NSURL* url = [NSURL fileURLWithPath: pathToFile ];
        [self addSkipBackupAttributeToItemAtURL:url];
        
        downloadTask = nil;
        data = nil;
    }
        if( !downloadPaused )
            [self actionTest: NO pobudka:NO];
    
}
//
//-(IBAction)wstrzymaj:(id)sender{
//    downloadPaused = YES;
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSLog( @"path: %@", [URL path] );
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    else{
//        NSLog(@"addSkipBackupAttributeToItemAtURL SUCCESSS");
    }
    return success;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"RESUME");
}

-(float)progessa{
    int ximg = 1;
    int xaudio = 3;
    int xvideo = 5;
    int xpdf = 5;
    unsigned long sumax = numberOfImages*ximg + numberOfAudios*xaudio + numberOfVideos*xvideo + xpdf;
    
    int sumaa = 0;
    for (NSString* link in appDelegate.currentIshue.filesToDownload ) {
        NSArray *chunks = [link componentsSeparatedByString:@"."];
        NSString* extName = [chunks lastObject];
        if ( [extName isEqualToString:@"mp4"] )
            sumaa += xvideo;
        if ( [extName isEqualToString:@"mp3"] )
            sumaa += xaudio;
        if ( [extName isEqualToString:@"jpg"] )
            sumaa += ximg;
        if ( [extName isEqualToString:@"png"] )
            sumaa += ximg;
        if ( [extName isEqualToString:@"zip"] )
            sumaa += xpdf;
    }
    
    float prog = (float)(sumax - sumaa) / (float)sumax;
    return  prog;    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
//    NSLog(@"progress: %@ %f", currentlyDownloadingFile, progress );
    
    float pr = [self progessa];
    int ximg = 1;
    int xaudio = 3;
    int xvideo = 5;
    int xpdf = 5;
    unsigned long sumax = numberOfImages*ximg + numberOfAudios*xaudio + numberOfVideos*xvideo + xpdf;
    
    NSArray *chunks = [currentlyDownloadingFile componentsSeparatedByString:@"."];
    NSString* extName = [chunks lastObject];

    float showprogess = 0.0f;
    if ( [extName isEqualToString:@"mp4"] )
        showprogess = pr + (progress * xvideo/sumax );
    else if ( [extName isEqualToString:@"mp3"] )
        showprogess = pr + (progress * xaudio/sumax );
    else if ( [extName isEqualToString:@"jpg"] )
        showprogess = pr + (progress * ximg/sumax );
    else if ( [extName isEqualToString:@"png"] )
        showprogess = pr + (progress * ximg/sumax );
    else if ( [extName isEqualToString:@"zip"] )
        showprogess = pr + (progress * xpdf/sumax );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setProgValue:showprogess*step1 text:@"Postęp:"];
    });
}


//to jest
-(void)rescalePage:(NSString*)path{
    //filesToDownloadLocalPathForOthers
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    bool exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if ( exist ){
        UIImage* imageOrg = [UIImage imageWithContentsOfFile:path];
        NSArray *chunks = [path componentsSeparatedByString: @"/"];
        NSString* imageOrgName = [chunks lastObject];
        NSString* imageThumbsName = [NSString stringWithFormat:@"thumb_%@", imageOrgName];
        NSString* imageThumbsLink = [documentsDirectory stringByAppendingPathComponent:imageThumbsName];
        bool exist2 = [[NSFileManager defaultManager] fileExistsAtPath:imageThumbsLink];
        
        if( !exist2 ){
            NSLog(@"imageThumbsLink: %@ %d == %d", imageThumbsLink, splitPDFAndMakeprevsProcessAllow, exist2 );
            CGSize thumbSize = CGSizeMake(512, 512);
            UIImage* imageThumbs = [NHelper imageWithImageResizeToRectSize:imageOrg scaledToSize:thumbSize];
            [UIImageJPEGRepresentation(imageThumbs, 1.0) writeToFile:imageThumbsLink atomically:YES];
            imageThumbs = nil;
            imageOrg = nil;
            
        }
    }
}


@end
