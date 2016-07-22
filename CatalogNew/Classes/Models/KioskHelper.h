//
//  KioskHelper.h
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 03.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface KioskHelper : NSObject


+(void)setKioskLarge: (ViewController*)viewController;
+(void)setTopBarLogo:(ViewController*)viewController;
+(void)setColorsFromPlist: (ViewController*)viewController;
+(void) setCollectionViewInfoIpadLandscape: (ViewController*)viewController;
+(void) setCollectionViewInfoIpadPortrait: (ViewController*)viewController;
+(void)setKioskLargeOfflineIphone: (ViewController*)viewController;
+(void) setCollectionViewInfoIphoneLandscape: (ViewController*)viewController;
+(void) setCollectionViewInfoIphonePortrait: (ViewController*)viewController;
+(void)preapreBannerButton: (ViewController*)vc;

@end
