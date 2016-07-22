//
//  PageViewPdf.m
//  Setupo
//
//  Created by Marcin Niedźwiecki on 01.12.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "PageViewPdf.h"
#import "AppDelegate.h"

@implementation PageViewPdf


-(id)initWithFrameAndFile:(CGRect)frame pathToPdfPage:(NSString*)pathToPdfPage{
    
    self =  [super initWithFrame:frame];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.alpha = 0.0;
    self.opaque = NO;
    self.backgroundColor = [UIColor blackColor];
    
    // we don't want interaction, full size
    self.scalesPageToFit = NO;
    self.userInteractionEnabled = NO;
    
    NSURL *pdfUrl = [NSURL fileURLWithPath:pathToPdfPage];
    //fileURL is an NSURL to a PDF file
    NSLog(@"loadReuest");
    [self loadRequest:[NSURLRequest  requestWithURL:pdfUrl]];
    
    
    return self;
}





@end