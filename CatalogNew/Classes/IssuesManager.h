
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

@end
