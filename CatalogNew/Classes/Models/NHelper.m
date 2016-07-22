//
//  NHelper.m
//  ViessmannPDF
//
//  Created by Marcin Niedźwiecki on 01.01.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import "NHelper.h"
#import <sys/sysctl.h>
#import "AppDelegate.h"


@implementation NHelper




+(BOOL)isIphone{
    //    return YES;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]){
        return YES;
    }
    else{
        return NO;
    }
}


+(UIImage*)imagedBorderedImage: (UIImage*)img withColor:(UIColor *)color{
    // load the image
    
    CGRect rect = CGRectMake(0.0f, 0.0f, img.size.width, img.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([img respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = img.scale;
        UIGraphicsBeginImageContextWithOptions(img.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(img.size);
    }
    
    [img drawInRect:rect];
    
    [color setStroke];
    [color setFill];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextStrokeRect(context, rect);
    
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}




+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    else{
        //        NSLog(@"addSkipBackupAttributeToItemAtURL SUCCESSS");
    }
    return success;
}




+(UIImage*)imagedColorized: (NSString*)imgname withColor:(UIColor *)color{
    // load the image
    UIImage *img = [UIImage imageNamed:imgname];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, img.size.width, img.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([img respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = img.scale;
        UIGraphicsBeginImageContextWithOptions(img.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(img.size);
    }
    
    [img drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


+(UIImage*)imagedColorizedImage: (UIImage*)img withColor:(UIColor *)color{
    // load the image
    
    CGRect rect = CGRectMake(0.0f, 0.0f, img.size.width, img.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) {
        CGFloat imageScale = 1.0f;
        if ([img respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = img.scale;
        UIGraphicsBeginImageContextWithOptions(img.size, NO, imageScale);
    }
    else {
        UIGraphicsBeginImageContext(img.size);
    }
    
    [img drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}





+(UIFont*)getFontDefault:(float)size bold:(BOOL)bold{
    if( !bold )
        return [UIFont fontWithName:[[NHelper appSettings] objectForKey:@"fontNormal"] size:size];
    else
        return [UIFont fontWithName:[[NHelper appSettings] objectForKey:@"fontBold"] size:size];
    
}

+(NSString*)pathToDocumentsDict{
    NSString *documentsDirectory =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentsDirectory;
}

+(NSString*)pathToVideoFile:(NSString*)fulllink{
    NSArray *chunks = [fulllink componentsSeparatedByString: @"/"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* videoNameFile = [chunks lastObject];
    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:videoNameFile];
    return fullFilePath;
}



+(CGSize)getSizeOfCurrentDeviceOrient{
    if( [NHelper isLandscapeInReal]){
        return [NHelper getSizeOfCurrentDeviceLandscape];
    }
    else{
        return [NHelper getSizeOfCurrentDevicePortrait];
    }
}

+(CGSize)getSizeOfCurrentDeviceLandscape{
    CGSize land = [NHelper platformScreenIgnoreRetina];
    return land;
}
+(CGSize)getSizeOfCurrentDevicePortrait{
    CGSize land = [NHelper platformScreenIgnoreRetina];
    CGSize port = CGSizeMake(land.height, land.width);
    return port;
}

+(BOOL)isIphone6{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    if ([platform containsString:@"iPhone7"]){ //iphone 6
        return YES;
    }
    if ([platform containsString:@"iPhone8"]){ //iphone 6s
        return YES;
    }
    else{
        return NO;
    }
}

+ (CGSize) platformScreenIgnoreRetina{
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    CGSize sizeScreen = CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    
    if ([platform containsString:@"iPhone"]){
        return CGSizeMake(sizeScreen.width > sizeScreen.height ? sizeScreen.width : sizeScreen.height, sizeScreen.width > sizeScreen.height ? sizeScreen.height : sizeScreen.width);
    }
    
    
    if ([platform isEqualToString:@"iPad1,1"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad1,2"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad2,1"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad2,2"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad2,3"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad2,4"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad2,5"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad2,6"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad2,7"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad3,1"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad3,2"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad3,3"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad3,4"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad3,5"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad3,6"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad4,1"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad4,2"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad4,4"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad4,5"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad4,6"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad4,7"])      return CGSizeMake(1024.0f, 768.0f);
    if ([platform isEqualToString:@"iPad4,8"])      return CGSizeMake(1024.0f, 768.0f);// @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return CGSizeMake(1024.0f, 768.0f);
    
    if ([platform isEqualToString:@"iPad5,1"]) return CGSizeMake(1024.0f, 768.0f);//@"iPad Mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"]) return CGSizeMake(1024.0f, 768.0f);//@"iPad Mini 4 (LTE)";
    if ([platform isEqualToString:@"iPad5,3"]) return CGSizeMake(1024.0f, 768.0f);//@"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"]) return CGSizeMake(1024.0f, 768.0f);//@"iPad Air 2";
    
    if ([platform isEqualToString:@"iPad6,8"]) return CGSizeMake(1024.0f, 768.0f);//return @"iPad Pro";
    
    
    NSLog(@"platform: %@", platform);
    if ([platform isEqualToString:@"x86_64"]){
        [NHelper showRectParams: [[UIScreen mainScreen] bounds] label:@"mainScreen Sym"];
        //        return CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        if( [[UIScreen mainScreen] bounds].size.height == 480 || [[UIScreen mainScreen] bounds].size.width == 480 ){
            return CGSizeMake(480.0f, 320.0f); //iphone 4
        }
        if( [[UIScreen mainScreen] bounds].size.height == 1024 || [[UIScreen mainScreen] bounds].size.width == 1024 ){
            return CGSizeMake(1024.0f, 768.0f);//ipads
        }
        else{
            CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
            [NHelper showSizeParams:size label:@"size:"];
            
            return CGSizeMake(size.width > size.height ? size.width : size.height, size.width > size.height ? size.height : size.width); // i5+
        }
        
    }
    
    //else if ipad jakis nwoy ?
    if ([platform containsString:@"iPad"]){
        return CGSizeMake(1024.0f, 768.0f);
    }
    if ([platform containsString:@"iPhone"]){
        return CGSizeMake(568.0f, 320.0f);
    }
    
    //    return CGSizeMake(568.0f, 320.0f);
    return CGSizeMake(568.0f, 320.0f);
    
}




+(void)borderView: (UIView*)xview color:(UIColor*)color width:(float)width{
    xview.layer.borderColor = color.CGColor;
    xview.layer.borderWidth = width;
}



+(void)setColorFromPlistForView: (UIView*)view key:(NSString*)key{
    [view setBackgroundColor:
     [NHelper colorFromHexString:
      [[NHelper appSettings] objectForKey:key]]];
}
+(void)setColorLabelFromPlistForView: (UILabel*)view key:(NSString*)key{
    [view setTextColor:
     [NHelper colorFromHexString:
      [[NHelper appSettings] objectForKey:key]]];
}


+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if( hexString == nil || hexString == [NSNull null]){
        hexString = @"#000000";
        NSLog(@"hex NULL: %@", hexString );
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)colorFromPlist: (NSString*)key{
    NSString* val = [[NHelper appSettings] objectForKey:key];
    if ( [val isEqualToString:@"clearColor"] ){
        return [UIColor clearColor];
    }
    return [NHelper colorFromHexString:
            [[NHelper appSettings] objectForKey:key]];
}


+(NSMutableDictionary*)appSettings{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"appSet" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray* keys = [appDelegate.appSettingFromNet allKeys];
    for (NSString* key in keys) {
        NSString *keyt = [key stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
        
        [dict setObject:[appDelegate.appSettingFromNet objectForKey:keyt] forKey:keyt];
    }
    
    return dict;
}

+(void)showRectParams: (CGRect)rect label:(NSString *)label{
    if( YES )
        NSLog(@"%@: x: %f y:%f width:%f height: %f", label,
              rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

+(void)showSizeParams: (CGSize)rect label:(NSString *)label{
    if( YES )
        NSLog(@"%@: width:%f height: %f", label,
              rect.width, rect.height);
}



+(BOOL)isLandscapeInReal{
    switch ([NHelper getCorrectInterfaceOrientation])
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            //            NSLog(@"UIInterfaceOrientationPortraitUpsideDown");;
            return NO;
            break;
        case UIInterfaceOrientationLandscapeRight:
            //            NSLog(@"UIInterfaceOrientationLandscapeRight");
            return YES;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            //            NSLog(@"UIInterfaceOrientationLandscapeLeft");
            return YES;
            break;
        case UIInterfaceOrientationPortrait:
            return NO;
            break; //do nothing because it's fine
        default:
            NSLog(@"DEF");
            return NO;
            break;
    }
}


+(UIInterfaceOrientation)getCorrectInterfaceOrientation{
    UIInterfaceOrientation iOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation dOrientation = [UIDevice currentDevice].orientation;
    BOOL landscape;
    
    if (dOrientation == UIDeviceOrientationUnknown || dOrientation == UIDeviceOrientationFaceUp || dOrientation == UIDeviceOrientationFaceDown) {
        // If the device is laying down, use the UIInterfaceOrientation based on the status bar.
        landscape = UIInterfaceOrientationIsLandscape(iOrientation);
    } else {
        // If the device is not laying down, use UIDeviceOrientation.
        landscape = UIDeviceOrientationIsLandscape(dOrientation);
        
        // There's a bug in iOS!!!! http://openradar.appspot.com/7216046
        // So values needs to be reversed for landscape!
        if (dOrientation == UIDeviceOrientationLandscapeLeft) iOrientation = UIInterfaceOrientationLandscapeRight;
        else if (dOrientation == UIDeviceOrientationLandscapeRight) iOrientation = UIInterfaceOrientationLandscapeLeft;
        
        else if (dOrientation == UIDeviceOrientationPortrait) iOrientation = UIInterfaceOrientationPortrait;
        else if (dOrientation == UIDeviceOrientationPortraitUpsideDown) iOrientation = UIInterfaceOrientationPortraitUpsideDown;
    }
    
    return iOrientation;
}



+ (NSString *) platformSpeed{
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    //    NSLog(@"platform: %@", platform);
    if ([platform isEqualToString:@"iPad1,1"])      return @"vvs";
    if ([platform isEqualToString:@"iPad2,1"])      return @"vvs";
    if ([platform isEqualToString:@"iPad2,2"])      return @"vvs";
    if ([platform isEqualToString:@"iPad2,3"])      return @"vs";
    if ([platform isEqualToString:@"iPad2,4"])      return @"vs";
    if ([platform isEqualToString:@"iPad2,5"])      return @"vs";
    if ([platform isEqualToString:@"iPad2,6"])      return @"vs";
    if ([platform isEqualToString:@"iPad2,7"])      return @"vs";
    if ([platform isEqualToString:@"iPad3,1"])      return @"s";
    if ([platform isEqualToString:@"iPad3,2"])      return @"s";
    if ([platform isEqualToString:@"iPad3,3"])      return @"s";
    if ([platform isEqualToString:@"iPad3,4"])      return @"f";
    if ([platform isEqualToString:@"iPad3,5"])      return @"f";
    if ([platform isEqualToString:@"iPad3,6"])      return @"f";
    if ([platform isEqualToString:@"iPad4,1"])      return @"vf";
    if ([platform isEqualToString:@"iPad4,2"])      return @"vf";
    if ([platform isEqualToString:@"iPad4,4"])      return @"vf";
    if ([platform isEqualToString:@"iPad4,5"])      return @"vf";
    if ([platform isEqualToString:@"iPhone1,1"])    return @"ivvs";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"ivvs";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"ivvs";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"ivs";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"ivs";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"is";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"if";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"if";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"if";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"if";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"ivf";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"ivf";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"ivf";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"ivf";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"ivf";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"ivf";
    
    return platform;
    
}


+ (NSString *) platformString{
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}


+ (UIImage*)imageWithImageResizeToRectSize:(UIImage*)image scaledToSize:(CGSize)newSize{
    @autoreleasepool {
        CGSize newSizeDef = newSize;
        float props = image.size.width / image.size.height;
        if ( image.size.width > image.size.height){
            newSizeDef = CGSizeMake(newSize.width, newSize.height / props );
        }
        else{
            newSizeDef = CGSizeMake(newSize.width * props , newSize.height );
        }
        
        UIGraphicsBeginImageContext( newSizeDef );
        [image drawInRect:CGRectMake(0,0,newSizeDef.width,newSizeDef.height)];
        UIImage* newImage = nil;
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}



@end
