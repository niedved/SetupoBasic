#import "TutorialViewController.h"

@implementation TutorialViewController

@synthesize buttonClose, switchPokazuj;


- (void)viewDidLoad{
    [super viewDidLoad];
    
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
    return self;
}


-(IBAction)hide:(id)sender{
    
    bool blocktutorial = self.switchPokazuj.on;
//    NSLog(@"value: %d", blocktutorial );
//    self.switchPokazuj
    appDelegate.tutorialHided = YES;
    if ( blocktutorial ){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:@"YES" forKey:@"tutorialblocked"];
        [prefs synchronize];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
