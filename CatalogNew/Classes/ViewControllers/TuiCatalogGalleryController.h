//
//  TuiCatalogCatalogListController.h
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Catalog.h"
#import <Social/Social.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <StoreKit/StoreKit.h>

#define MONOTONY_DELAY 30.0
@interface TuiCatalogGalleryController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>{
    AppDelegate *appDelegate;
    IBOutlet UIToolbar *toolbar;
    Catalog *catalog;
    NSMutableArray *categoriesArray;
    UIImage *image_tmp;
    IBOutlet UILabel* ishueTopic;
    
    
    
    IBOutlet UIView* viewForInd;
    IBOutlet UIActivityIndicatorView *indView;
        
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
@public
    IBOutlet UIButton* buttonBuy;
    IBOutlet UIButton* buttonPrenumerata;
    IBOutlet UIButton* buttonShare,* buttonDelete, *buttonAR, *buttonKod;
    IBOutlet UIButton* buttonAddToFav;
    
    IBOutlet UILabel* issueName;
    
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
    ViewController* vvcc;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, retain) IBOutlet UIView *loadViewExtra;
@property (nonatomic, retain) IBOutlet UIView *aplaView;
@property (nonatomic, retain) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *postText;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property (strong, nonatomic) IBOutlet UILabel *pageLabel;
@property (strong, nonatomic) IBOutlet UIButton *extra1;
@property (strong, nonatomic) IBOutlet UIButton *extra2;
@property (strong, nonatomic) IBOutlet UIButton *extra3;
@property (strong, nonatomic) IBOutlet UIButton *extra4;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonKodHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonPrenumerataHeight;


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (void)changePage:(int)animType;
-(void)setPageButtonValue;


- (IBAction)startARTapped:(id)sender;
-(IBAction)deleteFiles:(id)sender;
-(IBAction)addToFav:(id)sender;
-(IBAction)shareOnFb:(id)sender;
-(IBAction)selectIshueToView:(id)sender;

-(void)sprawdzCzyPobranoPlusMinus :(int)delta;
-(void)pobierzBrakujacyPlik:(int)strona_num;

-(void)downloadFileExtra;
-(void)downloadFile;

@end
