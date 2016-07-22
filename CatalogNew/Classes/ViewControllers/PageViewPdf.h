//
//  PageViewPdf.h
//  Setupo
//
//  Created by Marcin Niedźwiecki on 01.12.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewPdf : UIWebView{
    NSTimer *BackgroundIntervalTimer;

}



-(id)initWithFrameAndFile:(CGRect)frame pathToPdfPage:(NSString*)pathToPdfPage;
    
@end
