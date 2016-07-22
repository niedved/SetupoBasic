
#import "AppDelegate.h"
#import "NHelper.h"
#import "TKioskHelper.h"

#import <FAKFontAwesome.h>

@implementation TKioskHelper

+(void)setFolderLevelBackButton: (ViewController*)vc{
    FAKFontAwesome *backIcon = [FAKFontAwesome arrowCircleOLeftIconWithSize:27];
    [vc.folderLevelBackButton setImage:[backIcon imageWithSize:CGSizeMake(25, 25)] forState:UIControlStateNormal ];
    [vc.folderLevelBackButton setTintColor:[NHelper colorFromPlist:@"topbar_icon_color"]];
  //  [vc.folderLevelBackButton setHidden:NO];

}


+(void)setSegmentControllerColors:(UISegmentedControl*)segment{
    [segment setTintColor:[NHelper colorFromPlist:@"segmenttint"]];
    UIFont *font = [UIFont fontWithName:@"Verdana" size:10.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                [NHelper colorFromPlist:@"segmenttintactive"], NSForegroundColorAttributeName,
                                nil];
    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 font, NSFontAttributeName,
                                 [NHelper colorFromPlist:@"segmenttint"], NSForegroundColorAttributeName,
                                 nil];
    
    if( ![NHelper isLandscapeInReal] ){
        [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    else{
        [segment setTitleTextAttributes:attributes2 forState:UIControlStateNormal];
    }
    
    [segment setTitleTextAttributes:attributes
                                                   forState:UIControlStateHighlighted];
    [segment setTitleTextAttributes:attributes
                                                   forState:UIControlStateSelected];
    
    
    UIImage* img = [NHelper imagedColorizedImage:[UIImage imageNamed:@"selectedWydania"] withColor:[NHelper colorFromPlist:@"segmentbgactive"]];
    img = [NHelper imagedBorderedImage:img withColor:[NHelper colorFromPlist:@"segmentbgactiveborder"]];
    
    
    [segment setBackgroundImage:img
                                               forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
    [segment setBackgroundImage:[UIImage imageNamed:@"normalWydania"]
                                               forState:UIControlStateNormal
                                             barMetrics:UIBarMetricsDefault];
    
}




+(void)setSegmentControllerColorsIphone: (ViewController*)viewController segment:(UISegmentedControl*)segment{
    [segment setTintColor:[NHelper colorFromPlist:@"segmenttint"]];
    UIFont *font = [UIFont fontWithName:@"Verdana" size:6.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                [NHelper colorFromPlist:@"segmenttintactive"], NSForegroundColorAttributeName,
                                nil];
    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 font, NSFontAttributeName,
                                 [NHelper colorFromPlist:@"segmenttint"], NSForegroundColorAttributeName,
                                 nil];
    
    if( ![NHelper isLandscapeInReal] ){
        [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    else{
        [segment setTitleTextAttributes:attributes2 forState:UIControlStateNormal];
    }
    
    [segment setTitleTextAttributes:attributes
                                                   forState:UIControlStateHighlighted];
    [segment setTitleTextAttributes:attributes
                                                   forState:UIControlStateSelected];
    
    UIImage* img = [NHelper imagedColorizedImage:[UIImage imageNamed:@"selectedWydania"] withColor:[NHelper colorFromPlist:@"segmentbgactive"]];
    img = [NHelper imagedBorderedImage:img withColor:[NHelper colorFromPlist:@"segmentbgactiveborder"]];
    
    [segment setBackgroundImage:img
                                               forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
    [segment setBackgroundImage:[UIImage imageNamed:@"normalWydania"]
                                               forState:UIControlStateNormal
                                             barMetrics:UIBarMetricsDefault];
    
}

+(void) setColoredImages: (ViewController*)viewController{
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController.butonSubsciption setImage:[NHelper imagedColorized:@"subs" withColor:[NHelper colorFromPlist:@"topbar_icon_color"]] forState:UIControlStateNormal];
        [viewController.butonBookmarks setImage:[NHelper imagedColorized:@"bookmarks_kiosk" withColor:[NHelper colorFromPlist:@"topbar_icon_color"]] forState:UIControlStateNormal];
    });
}






+(void) setTopBarViewInfoIphonePortrait:(ViewController*)vc{
    vc.segmentControlWidth.constant = 0.0f;
    [vc.segmentedControlBottom setHidden:NO];
    [vc.segmentedControl setHidden:YES];
  //  [vc.folderLevelBackButton setHidden:NO];
    [vc.topBarView setBackgroundColor:[UIColor clearColor]];
    [NHelper setColorFromPlistForView:vc.topBarView key:@"topbarbg"];
    [vc.pionLineKiosk setHidden:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TKioskHelper setSegmentControllerColorsIphone:vc segment:vc.segmentedControlBottom];
        [TKioskHelper setFolderLevelBackButton:vc];
    });
}

+(void) setTopBarViewInfoIphoneLand: (ViewController*)vc {
    vc.segmentControlWidth.constant = 160.0f;
  //  [vc.folderLevelBackButton setHidden:NO];
    [vc.segmentedControlBottom setHidden:YES];
    [vc.segmentedControl setHidden:NO];
    [vc.pionLineKiosk setHidden:NO];
    [NHelper setColorFromPlistForView:vc.topBarView key:@"topbarbg"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TKioskHelper setSegmentControllerColorsIphone:vc segment:vc.segmentedControl];
        [TKioskHelper setFolderLevelBackButton:vc];
    });
    
}

+(void) setTopBarViewInfoIpadLand: (ViewController*)vc{
    vc.segmentControlWidth.constant = 270.0f;
    vc.topLogoCenterHorizontalDelta.constant = -146.0f;
    
    [vc.segmentedControlBottom setHidden:YES];
    [vc.segmentedControl setHidden:NO];
    [vc.pionLineKiosk setHidden:NO];
    [NHelper setColorFromPlistForView:vc.topBarView key:@"topbarbg"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TKioskHelper setSegmentControllerColors: vc.segmentedControl];
        [TKioskHelper setFolderLevelBackButton:vc];
    });
}

+(void) setTopBarViewInfoIpadPortrait: (ViewController*)vc{
    vc.segmentControlWidth.constant = 0.0f;
    vc.topLogoCenterHorizontalDelta.constant = 0.0f;
    [vc.segmentedControlBottom setHidden:NO];
    [vc.segmentedControl setHidden:YES];
  //  [vc.folderLevelBackButton setHidden:NO];
    [vc.topBarView setBackgroundColor:[UIColor clearColor]];
    [NHelper setColorFromPlistForView:vc.topBarView key:@"topbarbg"];
    [vc.pionLineKiosk setHidden:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TKioskHelper setSegmentControllerColors :vc.segmentedControlBottom];
        [TKioskHelper setFolderLevelBackButton:vc];
    });
    
    
}


@end