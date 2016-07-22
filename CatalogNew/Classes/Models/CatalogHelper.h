//
//  CatalogHelper.h
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 04.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoubleCatalogViewController.h"
#import "Page.h"

@interface CatalogHelper : NSObject

+(void)hardcoreFixLocalPion: (NSString*)x dcvc:(DoubleCatalogViewController*)dcvc;
+(void)hardcoreFixLocalPionIphone:(DoubleCatalogViewController*)dcvc;
+(void)hardcoreFixLocalPoziomIphone:(DoubleCatalogViewController*)dcvc;

+(CGRect)getImageSizeForMyImagePion_iPhone:(DoubleCatalogViewController*)dcvc;




+(void)placeButtonOnPage: (ContentButton*)button left:(bool)left dcvc:(DoubleCatalogViewController*)dcvc;
+(void)placeYYYButton: (ContentButton*)button frame:(CGRect)frameForView dcvc:(DoubleCatalogViewController*)dcvc;

+(void)setImageForMyImagePoziomForcedOnePage: (DoubleCatalogViewController*)dcvc;
+(void)changepngtopdf:(DoubleCatalogViewController*)dcvc;
+(void)changepdftopng:(DoubleCatalogViewController*)dcvc;
+(void)changepngtopdfIphone:(DoubleCatalogViewController*)dcvc;
+(void)changepdftopngIphone:(DoubleCatalogViewController*)dcvc;

+ (DoubleCatalogViewController *)viewControllerAtIndexIphonePoziomRoot:(NSUInteger)index dupa:(DoubleCatalogViewController *)dupa;
+(void)ustawFrameView:(UIView*)view rect:(CGRect)rect msg:(NSString*)msg;
+(CGRect)rightPdfCropSizeLandscape: (Page*)rightpage;
+(CGRect)leftPdfCropSizeLandscape:  (Page*)leftpage    forcedOnePage:(BOOL)forcedOnePage;
+(void)animateButtons: (DoubleCatalogViewController*)dcvc;
+(void)colorBorders: (DoubleCatalogViewController*)dcvc;
+(NSString*)video_filename:(NSString*)fulllink;
+(Page*)getCurrentPageInfo: (DoubleCatalogViewController*)dcvc;
+(Page*)getPageInfo: (DoubleCatalogViewController*)dcvc pageid:(int)pageid;

+(void)handleBTapHelperIphone:(DoubleCatalogViewController*)dcvc  clickedView:(UIView*)clickedView;
+(void)handleBTapHelper:(DoubleCatalogViewController*)dcvc clickedView:(UIView*)clickedView;
+(void)setImageForMyImageIphoneLandscape: (DoubleCatalogViewController*)dcvc;

+(void)makeKorekcjaPoZmianie:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc;
+(void)makeKorekcjaPoZmianieIpad:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc;
+(void)makeKorekcjaPoZmianieIpadForceOnePage:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc;

+(void)makeKorekcjaPoZmianieIpadPoziom:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc;
+(void)makeKorekcjaPoZmianieIpadForceOnePagePoziom:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc;
+(CGRect)iPhonePdfCropSizePortrait:(float)page_prop;

@end
