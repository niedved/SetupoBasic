

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface TKioskHelper : NSObject


+(void) setTopBarViewInfoIphonePortrait:(ViewController*)vc;
+(void) setTopBarViewInfoIphoneLand: (ViewController*)vc;

+(void) setColoredImages: (ViewController*)viewController;

+(void) setTopBarViewInfoIpadPortrait: (ViewController*)viewController;
+(void) setTopBarViewInfoIpadLand: (ViewController*)viewController;


+(void)setSegmentControllerColors:(UISegmentedControl*)segment;
@end
