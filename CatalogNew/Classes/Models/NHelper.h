//
//  NHelper.h
//  ViessmannPDF
//
//  Created by Marcin Niedźwiecki on 01.01.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NHelper : NSObject

+(UIImage*)imagedColorized: (NSString*)imgname withColor:(UIColor *)color;

+(BOOL)isIphone6;
+(BOOL)isIphone;
+(UIImage*)imagedBorderedImage: (UIImage*)img withColor:(UIColor *)color;

+(UIImage*)imagedColorizedImage: (UIImage*)img withColor:(UIColor *)color;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
+(UIFont*)getFontDefault:(float)size bold:(BOOL)bold;

+(void)borderView: (UIView*)xview color:(UIColor*)color width:(float)width;
+(void)setColorFromPlistForView: (UIView*)view key:(NSString*)key;
+(void)setColorLabelFromPlistForView: (UILabel*)view key:(NSString*)key;
+(UIColor *)colorFromHexString:(NSString *)hexString;
+(UIColor *)colorFromPlist: (NSString*)key;
+(NSDictionary*)appSettings;
+(void)showRectParams: (CGRect)rect label:(NSString *)label;
+(void)showSizeParams: (CGSize)rect label:(NSString *)label;

+(BOOL)isLandscapeInReal;
+(NSString*)pathToDocumentsDict;


+ (UIImage*)imageWithImageResizeToRectSize:(UIImage*)image scaledToSize:(CGSize)newSize;
+(NSString*)pathToVideoFile:(NSString*)fulllink;
+(CGSize)getSizeOfCurrentDeviceOrient;
+(CGSize)getSizeOfCurrentDeviceLandscape;
+(CGSize)getSizeOfCurrentDevicePortrait;
+ (CGSize) platformScreenIgnoreRetina;
+ (NSString *) platformString;
+ (NSString *) platformSpeed;

@end
