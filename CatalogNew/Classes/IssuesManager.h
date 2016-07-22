
@import UIKit;
#import "Ishue.h"
#import "Page.h"
#import <CoreData/CoreData.h>
#import <StoreKit/StoreKit.h>

@interface IssuesManager : NSObject{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    
}

/**
 * gets singleton object.
 * @return singleton
 */
+ (IssuesManager*)sharedInstance;
-(void)logIssueOpened;
-(void)logIssuePageSlidedPage:(Page*)pageleft pageright:(Page*)pageright;
-(void)logIssuePageSpisTresc:(Page*)pageleft;
-(void)logIssueActionClicked:(int)action_id;
-(void)checkOnlineAndIfYesSendLogs;

@property (strong, nonatomic) Ishue *currentIssue;
@property (strong, nonatomic) NSNumber *currentPageSlideIndex;
@property (strong, nonatomic) NSMutableArray *logsWaitingForSave;



//@property (strong, nonatomic) NSMutableArray *issuesColection;
//@property (strong, nonatomic) NSMutableArray *issuesColectionBasic;
//@property (strong, nonatomic) NSMutableArray *galerryCollectionBasic;
//@property (strong, nonatomic) NSMutableArray *filesNeeedToDownload;
//@property (strong, nonatomic) NSMutableArray* bookmarksColection;
//@property (strong, nonatomic) NSMutableDictionary *arrayGaleries;
//@property (strong, nonatomic) NSString *hashContent;
//@property (strong, nonatomic) NSString *hashLayout;
//
//
//@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//@property (strong, nonatomic) NSDictionary *layoutDatas;

//- (void)getAllIssuesForAppAndUser:(int)app_id user_id:(int)user_id completionBlock:(void (^)(BOOL success, BOOL hashChanged))completionBlock;
//- (void)getAllBasicIssuesForAppAndUser:(int)app_id group_id:(int)group_id completionBlock:(void (^)(BOOL success, BOOL hashChanged))completionBlock;
//-(int)okreslNumerStronyNaPodstawieSlidePage;
//-(int)okreslIdStronyNaPodstawieSlidePage;
//-(void)setCurrentIssueObject:(Ishue *)currentIssue;
//-(NSMutableArray*)filtrCurrentIssuesForPDFonly;
//- (void)getMainUserWithKeychainDataCompletionBlock:(void (^)(BOOL success, NSDictionary *responseObject))completionBlock;
//-(void)clearUserModel;
//
//- (void)loginUser:(NSString *)userName password:(NSString *)password completionBlock:(void (^)(BOOL success, NSDictionary *responseObject))completionBlock;
//- (void)loginUserWithKeychainDataCompletionBlock:(void (^)(BOOL success, NSDictionary *responseObject))completionBlock;
//- (void)logoutWithCompletionBlock:(void (^)(BOOL success))completionBlock;
//-(BOOL)checkUserLogedIn; 
//- (void)registerUser:(NSString *)userName password:(NSString *)password email:(NSString *)email completionBlock:(void (^)(BOOL success, NSDictionary *responseObject))completionBlock;
//
//
//-(Ishue*)getIssueFromCollectionById:(int)issue_id;
//-(NSMutableArray*) getCollectionOfIssuesForFolderId:(int)folder_id;
//-(BOOL)checkFolderExistInCollection:(int)folder_id;
//
//-(BOOL)checkBookmarkExistByIssueID: (int)issue_id page_num:(int)page_num;
//-(void)actionBookmarkCurrentPageAndChangeIconOfButton:(UIButton*)buttonClicked;
//-(void)reloadBookmarks;
@end
