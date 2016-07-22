
#import "IssuesManager.h"
#import "AFHTTPRequestMaker.h"
#import "NHelper.h"
#import "BookMark.h"
#import "AppDelegate.h"
//#import <Valet/VALValet.h>

@implementation IssuesManager

static IssuesManager *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[IssuesManager alloc] init];
}

- (id)mutableCopy
{
    return [[IssuesManager alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    if (self) {
        self.currentIssue = [[Ishue alloc] init];
        self.logsWaitingForSave = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setCurrentIssueObject:(Ishue *)currentIssue{
    self.currentIssue = currentIssue;
    self.currentPageSlideIndex = [NSNumber numberWithInt:0];
}

-(void)logIssueOpened{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:self.currentIssue->ishue_id] forKey:@"issue_id"];
    [dict setObject:appDelegate.mobileuser.mu_id forKey:@"mu_id"];
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor]UUIDString];
    [dict setObject:currentDeviceId forKey:@"currentDeviceId"];
    //send info that user open issue
    [AFHTTPRequestMaker sendGETRequestToAddress:@"/ajax/Common/Logs/addOpenIssueLog"
                                       withDict:dict
                                   successBlock:^(NSInteger statusCode, id responseObject) {
                                       //                                           NSLog(@"STATS SUCCES");
                                   } failureBlock:^(NSInteger statusCode, NSError *error) {
                                       [self addLogToWaiting:dict link:@"/ajax/Common/Logs/addOpenIssueLog"];
                                        NSLog(@"STATS FAILED");
                                   }
     ];
}

-(void)logIssuePageSlidedPage:(Page*)pageleft pageright:(Page*)pageright {
    
    NSLog(@"xx: %@ => %d", pageleft, pageleft.pageid);
    NSLog(@"xx: %@ => %d", pageright, pageright.pageid);
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:self.currentIssue->ishue_id] forKey:@"issue_id"];
    [dict setObject:appDelegate.mobileuser.mu_id forKey:@"mu_id"];
    NSMutableArray* tablicaWyswietlonychStron = [[NSMutableArray alloc] init];
    [tablicaWyswietlonychStron addObject:[NSNumber numberWithInteger:pageleft.pageid]];
    if( pageright.pageid > 0 ){
        [tablicaWyswietlonychStron addObject:[NSNumber numberWithInteger:pageright.pageid]];
    }
    [dict setObject:tablicaWyswietlonychStron forKey:@"pages"];
    [dict setObject:[NSNumber numberWithBool:[NHelper isLandscapeInReal]] forKey:@"isLandscape"];
    [dict setObject:[NHelper platformString] forKey:@"device"];
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor]UUIDString];
    [dict setObject:currentDeviceId forKey:@"currentDeviceId"];
//    //send info that user open issue
    [AFHTTPRequestMaker sendGETRequestToAddress:@"/ajax/Common/Logs/addPageSlidedLog"
                                       withDict:dict
                                   successBlock:^(NSInteger statusCode, id responseObject) {
                                                                                  NSLog(@"STATS SUCCES");
                                   } failureBlock:^(NSInteger statusCode, NSError *error) {
                                       //OFFLINE
                                       [self addLogToWaiting:dict link:@"/ajax/Common/Logs/addPageSlidedLog"];
                                       NSLog(@"STATS FAILED");
                                   }
     ];
}


-(void)checkOnlineAndIfYesSendLogs{
    NSLog(@"checkOnlineAndIfYesSendLogs: %d", [self.logsWaitingForSave count]);
    if( [self.logsWaitingForSave count] > 0 ){
        NSMutableDictionary* log = [self.logsWaitingForSave lastObject];
        [self.logsWaitingForSave removeLastObject];
        
        [AFHTTPRequestMaker sendGETRequestToAddress:[log objectForKey:@"link"]
                   withDict:[log objectForKey:@"dict"]
               successBlock:^(NSInteger statusCode, id responseObject) {
                   NSLog(@"STATS SUCCES");
                   
                   [self performSelector:@selector(checkOnlineAndIfYesSendLogs) withObject:nil afterDelay:5];
                   
               } failureBlock:^(NSInteger statusCode, NSError *error) {
                   //OFFLINE
                   NSLog(@"STATS FAILED");
                   [self.logsWaitingForSave addObject:log];
                   [self performSelector:@selector(checkOnlineAndIfYesSendLogs) withObject:nil afterDelay:5];
                }
         ];
    }
    else{
        NSLog(@"nologs");
        [self performSelector:@selector(checkOnlineAndIfYesSendLogs) withObject:nil afterDelay:15];
    }
    
    
}



-(void)logIssueActionClicked:(int)action_id {
    
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:self.currentIssue->ishue_id] forKey:@"issue_id"];
    [dict setObject:appDelegate.mobileuser.mu_id forKey:@"mu_id"];
    [dict setObject:[NSNumber numberWithInteger:action_id] forKey:@"action_id"];
    
    [dict setObject:[NSNumber numberWithBool:[NHelper isLandscapeInReal]] forKey:@"isLandscape"];
    [dict setObject:[NHelper platformString] forKey:@"device"];
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor]UUIDString];
    [dict setObject:currentDeviceId forKey:@"currentDeviceId"];
    //    //send info that user open issue
    [AFHTTPRequestMaker sendGETRequestToAddress:@"/ajax/Common/Logs/addActionLog"
                                       withDict:dict
                                   successBlock:^(NSInteger statusCode, id responseObject) {
                                       NSLog(@"STATS SUCCES");
                                   } failureBlock:^(NSInteger statusCode, NSError *error) {
                                       //OFFLINE
                                       NSLog(@"STATS FAILED");
                                       [self addLogToWaiting:dict link:@"/ajax/Common/Logs/addActionLog"];
                                   }
     ];
}

-(void)addLogToWaiting:(NSMutableDictionary*) dict link:(NSString*)link {
    NSMutableDictionary* log = [[NSMutableDictionary alloc] init];
    [log setValue:link forKey:@"link"];
    [log setValue:dict forKey:@"dict"];
    [self.logsWaitingForSave addObject:log];
}


-(void)logIssuePageSpisTresc:(Page*)pageleft {
    
    NSLog(@"xx: %@ => %d", pageleft, pageleft.pageid);
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:self.currentIssue->ishue_id] forKey:@"issue_id"];
    [dict setObject:appDelegate.mobileuser.mu_id forKey:@"mu_id"];
    NSMutableArray* tablicaWyswietlonychStron = [[NSMutableArray alloc] init];
    [tablicaWyswietlonychStron addObject:[NSNumber numberWithInteger:pageleft.pageid]];
    if( ![NHelper isIphone] && [NHelper isLandscapeInReal] ){
        [tablicaWyswietlonychStron addObject:[NSNumber numberWithInteger:pageleft.pageid+1]];
    }
    [dict setObject:tablicaWyswietlonychStron forKey:@"pages"];
    [dict setObject:[NSNumber numberWithBool:[NHelper isLandscapeInReal]] forKey:@"isLandscape"];
    [dict setObject:[NHelper platformString] forKey:@"device"];
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor]UUIDString];
    [dict setObject:currentDeviceId forKey:@"currentDeviceId"];
    //    //send info that user open issue
    [AFHTTPRequestMaker sendGETRequestToAddress:@"/ajax/Common/Logs/addPageSpisLog"
                                       withDict:dict
                                   successBlock:^(NSInteger statusCode, id responseObject) {
                                       NSLog(@"STATS SUCCES");
                                   } failureBlock:^(NSInteger statusCode, NSError *error) {
                                       //OFFLINE
                                       NSLog(@"STATS FAILED");
                                       [self addLogToWaiting:dict link:@"/ajax/Common/Logs/addPageSpisLog"];
                                       
                                   }
     ];
}





@end
