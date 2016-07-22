//
//  StartController.m
//  wSieci
//
//  Created by Marcin Niedźwiecki on 01.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import "StartController.h"
#import "AppDelegate.h"
#import "NHelper.h"
#import "AFHTTPRequestMaker.h"

@interface StartController ()

@end

@implementation StartController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tlo"]]];
    
    UIImage* bgimage = [UIImage imageNamed:@"tut.jpg"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgimage]];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    [self.view setBackgroundColor:[NHelper colorFromHexString:@"#e6e6e6"]];
    
    [self preapreIssuesCovers];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setShadow:(UIButton*)btn{
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 1.0f;
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowRadius = 2.0f;
    btn.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    btn.layer.shadowOpacity = 0.5f;
}

-(void)setButtonPosiotionIpad{
}

-(void)setButtonPosiotionIphone{

}

-(void)preapreIssuesCovers{
//    [self setShadow:self.buttonIss1];
//    [self setShadow:self.buttonIss2];
    [self setButtonPosiotionIpad];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
    
//    [textField setHidden:YES];
    if ( [self shouldPerformSegueWithIdentifier:@"segueCode" sender:nil]){
        [self performSegueWithIdentifier: @"segueCode" sender: self];
    }
    else{
        textField.text = @"";
//        [textField setPlaceholder:@"Wrong password"];
//        [self performSegueWithIdentifier: @"segueCode" sender: self];
    }
    return YES;
}


//
- (void)orientationChanged:(NSNotification *)notification{
    if( [NHelper isIphone] ){
        [self setButtonPosiotionIphone];
    }
    else{
        [self setButtonPosiotionIpad];
    }
//
//    
}



-(IBAction)issueClicked:(id)sender{
    UIButton* btn = (UIButton*)sender;
    NSLog(@"tg: %d", btn.tag);
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate->app_id = btn.tag;
    [appDelegate reSetup];
    [self performSegueWithIdentifier: @"segueSelectedIssue" sender: self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segueCode"]) {
        NSLog(@"segueCode GO1" );
        [appDelegate setupIshuesCollection];
    }
    
    else{
        NSLog(@"segueSelectKiosk ???:" );
        //send info that user open issue
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInt:appDelegate->app_id] forKey:@"issue_id"];
        [dict setObject:appDelegate.mobileuser.mu_id forKey:@"mu_id"];
        UIDevice *device = [UIDevice currentDevice];
        NSString *currentDeviceId = [[device identifierForVendor]UUIDString];
        [dict setObject:currentDeviceId forKey:@"currentDeviceId"];
        
        [AFHTTPRequestMaker sendGETRequestToAddress:@"/ajax/Common/Logs/addOpenAppLog"
                                           withDict:dict
                                       successBlock:^(NSInteger statusCode, id responseObject) {
//                                           NSLog(@"STATS SUCCES");
                                       } failureBlock:^(NSInteger statusCode, NSError *error) {
                                           //OFFLINE
//                                           NSLog(@"STATS FAILED");
                                       }
         ];
        

        
    }
    
}


@end
