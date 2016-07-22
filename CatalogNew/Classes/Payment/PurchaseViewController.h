#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface TutorialViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    AppDelegate *appDelegate;

}

@property (strong, nonatomic) IBOutlet UIButton *buttonClose;
@property (weak, nonatomic) IBOutlet UISwitch *switchPokazuj;

-(IBAction)hide:(id)sender;

@end
