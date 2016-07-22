#import <Foundation/Foundation.h>

@class YLProgressBar;

@interface LoadViewController : UIViewController<NSURLSessionDelegate, NSURLSessionDownloadDelegate>{
    @public
    IBOutlet UILabel* label1;
    int ishue_id;
    BOOL videoDownloaded;
    BOOL audioDownloaded;
    BOOL galeriesDownloaded;
    BOOL downloadPaused;
    NSString* currentlyDownloadingFile;
    NSString* currentlyDownloadingFileDestination;
    NSMutableArray* filesToDownload;
    BOOL splitPDFAndMakeprevsProcessAllow;
}

@property (nonatomic, strong) IBOutlet UIView      *progressBarFlatRainbowView;
@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarFlatRainbow;
@property (nonatomic, strong) IBOutlet NSURLSessionDownloadTask *downloadTask;

-(void)actionTest:(BOOL)firstTime pobudka:(BOOL)pobudka;
-(IBAction)wstrzymaj:(id)sender;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end