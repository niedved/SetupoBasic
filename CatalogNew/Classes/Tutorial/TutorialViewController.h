#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface TutorialViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    AppDelegate *appDelegate;

}

@property bool dontshow;
@property (strong, nonatomic) IBOutlet UITextField *codeText;
@property (strong, nonatomic) IBOutlet UIButton *buttonClose;
@property (strong, nonatomic) IBOutlet UIButton *dontshowButton;
@property (weak, nonatomic) IBOutlet UISwitch *switchPokazuj;

-(IBAction)hide:(id)sender;

-(IBAction)dontShowAction:(id)sender;

@end
