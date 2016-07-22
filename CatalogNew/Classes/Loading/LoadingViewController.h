//
//  TuiCatalogCatalogListController.h
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/mediaplayer.h>
#import "AppDelegate.h"
#import "Catalog.h"
#import <Social/Social.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <StoreKit/StoreKit.h>

#define MONOTONY_DELAY 30.0
@interface TuiCatalogGalleryController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate,
SKStoreProductViewControllerDelegate, SKProductsRequestDelegate, SKRequestDelegate, SKPaymentTransactionObserver>{
    AppDelegate *appDelegate;
    IBOutlet UIToolbar *toolbar;
    Catalog *catalog;
    NSMutableArray *categoriesArray;
    UIImage *image_tmp;
    IBOutlet UIButton* buttonShare;
    IBOutlet UIButton* buttonBuy;
    IBOutlet UIButton* buttonAddToFav;
    IBOutlet UILabel* ishueTopic;
    
    IBOutlet UIActivityIndicatorView *indView;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    @public
    //for tui
    NSString *sessionId;
    NSString *mapLocation;
    int active_catalog_id;
    NSMutableData *receivedData;
	NSMutableData *responseData;
	NSNumber* filesize;
    int connection_num;
    NSString* log_user_id;
    Catalog *current_catalog;
    NSMutableArray* filesToDownload;
    NSMutableArray* ulubioneArray;
    NSString* connection_filepath;
    int currentFileId;
    bool connection_inprogress;
    NSURLConnection* connection;
    NSString* url_to_show;
    
    UIProgressView* progressViewSmall;
    
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;  
@property (nonatomic, retain) UIImageView *imageView;   
@property (strong, nonatomic) IBOutlet UITextView *postText;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property (strong, nonatomic) IBOutlet UILabel *pageLabel;


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, strong) UIView*  _hudView;

+(NSMutableArray*)getTabliceDanychKatalogowych;
- (void)changePage:(int)animType;
-(void)setPageButtonValue;


-(IBAction)addToFav:(id)sender;
-(IBAction)shareOnFb:(id)sender;
-(IBAction)shareOnTwitter:(id)sender;
-(IBAction)selectIshueToView:(id)sender;

-(void)sprawdzCzyPobranoPlusMinus :(int)delta;
-(void)pobierzBrakujacyPlik:(int)strona_num;

-(void)downloadFileExtra;
-(void)downloadFile;

@end
