//
//  KioskHelper.m
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 03.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//
#import "AppDelegate.h"
#import "NHelper.h"
#import "IssuesManager.h"
#import "KioskHelper.h"

@implementation KioskHelper



+(CGRect)getLargeCoverSize{
    float pageprops = [[[NHelper appSettings] objectForKey:@"pagewidth"] floatValue] / [[[NHelper appSettings] objectForKey:@"pageheight"] floatValue];
    
    NSDictionary* dict = [[NHelper appSettings] objectForKey:@"coverSizeLandscape"];
    return CGRectMake([[dict objectForKey:@"x"] doubleValue], [[dict objectForKey:@"y"] doubleValue], [[dict objectForKey:@"width"] doubleValue], [[dict objectForKey:@"width"] doubleValue]/pageprops);
}



+(void)setKioskLarge: (ViewController*)viewController{
    Ishue* issueToPresent = [IssuesManager sharedInstance].currentIssue;
    NSString *fullFilePath = [issueToPresent getLocalPathToPageCover];
    
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath];
    UIImage *image;
    if ( fileExist )
        image = [UIImage imageWithContentsOfFile:fullFilePath];
    else{
        image = [issueToPresent getImagePageCoverFromUrl];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:fullFilePath atomically:YES];
    }
    
    [viewController.kioskLargeOkladka setImage:image forState:UIControlStateNormal];
//    [viewController.kioskLargeOkladkaOko setHidden:NO];
    
    viewController.kioskLargeOkladka.imageView.contentMode = UIViewContentModeScaleAspectFit;
    viewController.kioskLargeOkladka.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    viewController.kioskLargeOkladka.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [viewController.kioskLargeOkladka setBackgroundColor:[UIColor clearColor]];
    [viewController.kioskLargeOkladka setBackgroundImage:nil forState:UIControlStateNormal];
    
    
    // update the Newsstand icon
    if(image) {
        [[UIApplication sharedApplication] setNewsstandIconImage:image];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    
    
    if ( issueToPresent.name.length > 0 ){
        [viewController.kioskLargeStrzalkaLabel setText:[issueToPresent.name uppercaseString]];
        [viewController.kioskLargeStrzalkaCena setText:[issueToPresent.price_text uppercaseString]];
    }
    else{
        [viewController.kioskLargeStrzalkaLabel setText:[@"offline mode" uppercaseString]];
        [viewController.kioskLargeStrzalkaCena setText:[@"offline mode" uppercaseString]];
    }
    
    
    [viewController.kioskLargeStrzalkaView setBackgroundColor:[UIColor clearColor]];
    
    
    [KioskHelper changeTopicsValues:viewController];
}



+(void)setColorsFromPlist: (ViewController*)viewController{
    
    [NHelper setColorFromPlistForView:viewController.topBarViewLineBottom key:@"topbarlinebg"];
    [NHelper setColorFromPlistForView:viewController.bottomBarViewLineBottom key:@"topbarlinebg"];
    
    [NHelper setColorFromPlistForView:viewController.pionLineKiosk key:@"kiosklinepion"];
    [viewController.pionLineKiosk setAlpha:1.0f];
    [NHelper setColorLabelFromPlistForView:viewController.kioskLargeStrzalkaLabel key:@"kiosktextstrzalka"];

    [viewController.kioskLargeStrzalkaCena setTextColor:[UIColor blackColor]];
    [viewController.kioskLargeStrzalkaLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [viewController.kioskLargeStrzalkaCena setFont:[UIFont systemFontOfSize:12.0f]];
    
    
    [NHelper setColorLabelFromPlistForView:viewController.kioskL1 key:@"kiosktext"];
    [NHelper setColorLabelFromPlistForView:viewController.kioskL2 key:@"kiosktext"];
    [NHelper setColorLabelFromPlistForView:viewController.kioskL3 key:@"kiosktext"];
    [NHelper setColorLabelFromPlistForView:viewController.kioskL4 key:@"kiosktext"];
    [NHelper setColorLabelFromPlistForView:viewController.kioskLT1 key:@"kiosktexttitle"];
    [NHelper setColorLabelFromPlistForView:viewController.kioskLT2 key:@"kiosktexttitle"];
    [NHelper setColorLabelFromPlistForView:viewController.kioskLT3 key:@"kiosktexttitle"];
    [NHelper setColorLabelFromPlistForView:viewController.kioskLT4 key:@"kiosktexttitle"];
    
    [NHelper setColorFromPlistForView:viewController.topBarView key:@"topbarbg"];
//    [NHelper setColorFromPlistForView:viewController.bottomViewBar key:@"topbarbg"];
//    [NHelper setColorFromPlistForView:viewController.bottomViewBar key:@"topbarbg"];
    
}


+(NSString*)getLocalPathToBaner{
    NSString* banerUrl = [[NHelper appSettings] objectForKey:@"banerurl"];
    NSArray *chunks = [banerUrl componentsSeparatedByString: @"/"];
    NSString* filewithext = [chunks lastObject];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:filewithext];
    
    
}
+(void)preapreBannerButton: (ViewController*)vc{
    NSLog(@"baner URL: %@", [[NHelper appSettings] objectForKey:@"banerurl"]);
    NSURL *url = [NSURL URLWithString: [[NHelper appSettings] objectForKey:@"banerurl"] ];
    bool exist = [[NSFileManager defaultManager] fileExistsAtPath:[self getLocalPathToBaner]];
    vc.banner.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if ( exist ){
        NSLog(@"exist");
        UIImage* bannerImage = [UIImage imageWithContentsOfFile:[self getLocalPathToBaner]];
        [vc.banner setImage:bannerImage forState:UIControlStateNormal];
    }
    else{
        UIImage* bannerImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        [UIImagePNGRepresentation(bannerImage) writeToFile:[self getLocalPathToBaner] atomically:YES];
        
        NSLog(@"bannerImage: %@", bannerImage );
        [vc.banner setBackgroundColor:[UIColor clearColor]];
        [vc.banner setImage:bannerImage forState:UIControlStateNormal];
    }
    
}


+(void)setTopBarLogo:(ViewController*)viewController{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:viewController action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [viewController.toplogo setUserInteractionEnabled:YES];
    [viewController.toplogo addGestureRecognizer:singleTap];
    
    if( [[[NHelper appSettings] objectForKey:@"toplogo_online"] boolValue] ){
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* logolocalurl = [NSString stringWithFormat:@"toplogo_online_%d.png", appDelegate->app_id];
        NSString* pathLocal = [documentsDirectory stringByAppendingPathComponent:logolocalurl];
        bool exist = [[NSFileManager defaultManager] fileExistsAtPath:pathLocal];
        if ( exist ){
            UIImage* imageOrg = [UIImage imageWithContentsOfFile:pathLocal];
            [viewController.toplogo setImage: imageOrg];
        }
        else{
            NSString* stringForBanerUrl = [NSString stringWithFormat:@"%@/Resources/topbaners/toplogo_online_%d.png", STAGING_URL_NOINDEX, appDelegate->app_id];
            NSLog(@"string url: %@", stringForBanerUrl );
            UIImage* imageDL = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:stringForBanerUrl]]];
            NSLog(@"image top: %@", imageDL );
            [viewController.toplogo setImage: imageDL];
        }
        
    }
    else{
        [viewController.toplogo setImage:[UIImage imageNamed:[[NHelper appSettings] objectForKey:@"toplogo"]]];
    }
}


+(void)setKioskLargeTopicsIpad:(ViewController*)viewController{
    [viewController.kioskL1 setHidden:NO];
    [viewController.kioskL2 setHidden:NO];
    [viewController.kioskL3 setHidden:NO];
    [viewController.kioskL4 setHidden:NO];
    
    float fontSize = 12.0f;

    [viewController.kioskLT1 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskLT2 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskLT3 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskLT4 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskLT5 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskL1 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskL2 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskL3 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskL4 setFont:[UIFont italicSystemFontOfSize:fontSize]];
    [viewController.kioskL5 setFont:[UIFont italicSystemFontOfSize:fontSize]];

    
    
    [viewController.kioskLT1 setNumberOfLines:16];
    [viewController.kioskLT2 setNumberOfLines:16];
    [viewController.kioskLT3 setNumberOfLines:16];
    [viewController.kioskLT4 setNumberOfLines:16];
    [viewController.kioskLT5 setNumberOfLines:16];
    [viewController.kioskL1 setNumberOfLines:16];
    [viewController.kioskL2 setNumberOfLines:16];
    [viewController.kioskL3 setNumberOfLines:16];
    [viewController.kioskL4 setNumberOfLines:16];
    [viewController.kioskL5 setNumberOfLines:16];
    
    [KioskHelper changeTopicsValues:viewController];
}

+(float)getBottomCordsOfView: (UIView*)v{
    return v.frame.origin.y + v.frame.size.height;
}






+(void)setKioskLargeOfflineIphone: (ViewController*)viewController{
    for (UIView* X in [viewController.kioskLargeView subviews]) {
        [X setHidden:YES];
    }
    
    [viewController.banner setHidden:YES];
    [viewController.pionLineKiosk setHidden:YES];
    
    [viewController->oflineimageview removeFromSuperview];
    viewController->oflineimageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 170, 222)];
    [viewController->oflineimageview setImage:[UIImage imageNamed:@"loading960_offline.png"]];
    [viewController.view addSubview:viewController->oflineimageview];
    [viewController.view bringSubviewToFront:viewController->oflineimageview];
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    viewController->oflineimageview.center = CGPointMake(size.width/2, 10+(size.height/2));
}

+(void) setCollectionViewInfoIphonePortrait: (ViewController*)viewController{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    [viewController.bottomViewBar setHidden:NO];
    [viewController.kioskLargeView setHidden:YES];
    viewController.viewForCollectionWidth.constant = size.width;
    [viewController prepareKolekcjaIshuesView];
}


+(void) setCollectionViewInfoIphoneLandscape: (ViewController*)viewController{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    
    viewController.viewForCollectionWidth.constant = size.width/4;
    [viewController.kioskLargeView setHidden:NO];
    [viewController.bottomViewBar setHidden:YES];
    [viewController prepareKolekcjaIshuesView];
}


+(void) setCollectionViewInfoIpadLandscape: (ViewController*)viewController{
    viewController.viewForCollectionWidth.constant = 293.0f;
    viewController.viewForCollectionHeight.constant = 683.0f;
    viewController.kioskLargeViewWidth.constant = 730.0f;
    viewController.kioskLargeViewHEight.constant = 683.0f;
    
    
    [viewController.kioskLargeView setHidden:NO];
    [viewController.bottomViewBar setHidden:YES];
    [viewController prepareKolekcjaIshuesView];
    [viewController->mnCollectionViewController setLandscape:viewController->viewForCollection.frame];
}

+(void) setCollectionViewInfoIpadPortrait: (ViewController*)viewController{
    CGSize size = [NHelper getSizeOfCurrentDevicePortrait];
    [viewController.bottomViewBar setHidden:NO];
    [viewController.kioskLargeView setHidden:NO];
    viewController.viewForCollectionWidth.constant = size.width;
    viewController.kioskLargeViewWidth.constant = size.width;
    viewController.viewForCollectionHeight.constant = 255.0f;
    viewController.kioskLargeViewHEight.constant = 650.0f;
    [viewController prepareKolekcjaIshuesView];
    [viewController->mnCollectionViewController setPortrait:viewController->viewForCollection.frame];
}


+(void)setEyeButtonPosition: (ViewController*)viewController{
    CGRect fr = viewController.kioskLargeOkladka.frame;
    viewController.kioskLargeOkladkaOko.alpha = 0.9;
    float widthOfEye = fr.size.width / 6;
    [viewController.kioskLargeOkladkaOko setFrame:CGRectMake(fr.origin.x + fr.size.width - widthOfEye - 10, fr.origin.y + fr.size.height - widthOfEye - 10, widthOfEye, widthOfEye)];
    
}


+(void)setShadowOverCoverLarge: (ViewController*)viewController{
    
    viewController.kioskLargeOkladka.layer.shadowColor = [NHelper colorFromPlist:@"kiosk_shadow_color"].CGColor;
    viewController.kioskLargeOkladka.layer.shadowRadius = 3.0f;
    viewController.kioskLargeOkladka.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    viewController.kioskLargeOkladka.layer.shadowOpacity = 0.5f;
    
}


+(void)changeTopicsValues:(ViewController*)viewController{
    NSMutableDictionary* topics = [IssuesManager sharedInstance].currentIssue.issueTopics;
    [viewController.kioskLT1 setText:[topics objectForKey:@"t1"]];
    [viewController.kioskL1 setText:[topics objectForKey:@"d1"]];
    [viewController.kioskLT2 setText:[topics objectForKey:@"t2"]];
    [viewController.kioskL2 setText:[topics objectForKey:@"d2"]];
    [viewController.kioskLT3 setText:[topics objectForKey:@"t3"]];
    [viewController.kioskL3 setText:[topics objectForKey:@"d3"]];
    [viewController.kioskLT4 setText:[topics objectForKey:@"t4"]];
    [viewController.kioskL4 setText:[topics objectForKey:@"d4"]];
  
    
    viewController.labelDescription1Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"d1"] label:viewController.kioskL1];
    viewController.labelDescription2Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"d2"] label:viewController.kioskL2];
    viewController.labelDescription3Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"d3"] label:viewController.kioskL3];
    viewController.labelDescription4Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"d4"] label:viewController.kioskL4];
    
    viewController.labelTopic1Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"t1"] label:viewController.kioskLT1];
    viewController.labelTopic2Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"t2"] label:viewController.kioskLT2];
    viewController.labelTopic3Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"t3"] label:viewController.kioskLT3];
    viewController.labelTopic4Height.constant = [KioskHelper calculateDescHeight:[topics objectForKey:@"t4"] label:viewController.kioskLT4];
    
}

+ (float)calculateDescHeight:(NSString*)bio label:(UILabel*)label{
    float fontSize = label.font.pointSize;
    float width = label.frame.size.width;
    float fontWeight = UIFontWeightSemibold;
    
//}fontSize:(float)fontSize fontWeight:(float)fontWeight{
    float descriptionLabelHeight = 0;
    if (bio.length > 0) {
        CGRect labelRect = [bio
                            boundingRectWithSize:CGSizeMake(width, 0)
                            options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{
                                         NSFontAttributeName : [UIFont systemFontOfSize:fontSize weight:fontWeight],
                                         }
                            context:nil];
        descriptionLabelHeight = CGRectGetHeight(labelRect);
    }
    
    return ceilf(descriptionLabelHeight);
}
//
//+ (float)calculateTopicHeight:(NSString*)bio width:(float)width {
//    float descriptionLabelHeight = 0;
//    if (bio.length > 0) {
//        CGRect labelRect = [bio
//                            boundingRectWithSize:CGSizeMake(width, 0)
//                            options:NSStringDrawingUsesLineFragmentOrigin
//                            attributes:@{
//                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:9.0],
//                                         }
//                            context:nil];
//        descriptionLabelHeight = CGRectGetHeight(labelRect);
//    }
//    
//    return ceilf(descriptionLabelHeight);
//}





@end
