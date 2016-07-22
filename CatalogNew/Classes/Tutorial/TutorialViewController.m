#import "TutorialViewController.h"

@implementation TutorialViewController

@synthesize buttonClose, switchPokazuj;


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.dontshow = NO;
    [self.dontshowButton setBackgroundImage:[UIImage imageNamed:@"checkboxOff.png"] forState:UIControlStateNormal];
    
        NSLog(@"TutorialViewController VIEW DID DLOAD");
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    

    UIImage* bgimage = [UIImage imageNamed:@"tut.jpg"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgimage]];
    
    
    [self.codeText becomeFirstResponder];
}

-(IBAction)dontShowAction:(id)sender{
    self.dontshow = ! self.dontshow;
    if ( self.dontshow)
        [self.dontshowButton setBackgroundImage:[UIImage imageNamed:@"checkboxOn"] forState:UIControlStateNormal];
    else
        [self.dontshowButton setBackgroundImage:[UIImage imageNamed:@"checkboxOff"] forState:UIControlStateNormal];
    
    
}

// Add this method
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"Tutorial init");
    }
    
    [self.codeText becomeFirstResponder];
    return self;
}


-(IBAction)hide:(id)sender{
    
//    bool blocktutorial = self.switchPokazuj.on;
//    NSLog(@"value: %d", blocktutorial );
//    self.switchPokazuj
    
    NSDictionary* ret = [appDelegate.DBC getAppSettingByCode:self.codeText.text];
    if ( !ret ){
        NSLog(@"NULL");
    }
    else{
        NSLog(@"NOT NULL");
        appDelegate->app_id = [[ret objectForKey:@"app_id"] intValue];
        [appDelegate reSetup];
        appDelegate.tutorialHided = YES;
//    if ( self.dontshow ){
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        [prefs setObject:@"YES" forKey:@"tutorialblocked"];
//        [prefs synchronize];
//    }
//    
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}



@end
