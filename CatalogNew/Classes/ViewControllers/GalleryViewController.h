#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "Catalog.h"
#import "LTransitionImageView.h"


@interface GalleryViewController : UIViewController<UIAlertViewDelegate,NSURLSessionDelegate, NSURLSessionDownloadDelegate>{
    AppDelegate *appDelegate;
    LTransitionImageView *_transitionImageView;
    
    NSMutableArray* filesToDownload;
    NSMutableArray* filesForIssue;
    
    NSMutableArray* galleryImages;
    int current_image_num;
    NSString* currentlyDownloadingFile;
    NSString* currentlyDownloadingFileDestination;
    
    
    @public
    int current_gallery_id;
}


@end
