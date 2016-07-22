//
//  KioskHelper.h
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 03.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuiCatalogGalleryController.h"
@interface PreviewHelper : NSObject


+(void)setTapAndSwipeDetails:(TuiCatalogGalleryController*)previewViewController;
+(void)setViewDetails:(TuiCatalogGalleryController*)previewViewController;

+(BOOL)czyMaszSubskrypcjeObejmujacaWydanie: (Ishue*)is;
+(BOOL)czyMaszSubskrypcje;
+(void)setButtons:(TuiCatalogGalleryController*)previewViewController;
+(void)buttonNormal:(UIButton*)button;
+(void)buttonHighlight:(UIButton*)button;
+(void)setButtonStyle:(UIButton*)button size:(float)size;
@end

