//
//  MNAlbumTitleReusableView.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "MNAlbumTitleReusableView.h"
#import "AppDelegate.h"
#import "NHelper.h"
@interface MNAlbumTitleReusableView ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@end

@implementation MNAlbumTitleReusableView

- (id)initWithFrame:(CGRect)frame
{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        if([NHelper isIphone]){
            self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:[[[NHelper appSettings] objectForKey:@"kioskthumbtextsize"] floatValue] ];
            self.titleLabel.numberOfLines = 10;
        }
        else{
            self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:[[[NHelper appSettings] objectForKey:@"kioskthumbtextsize"] floatValue] ];
        }
        [NHelper setColorLabelFromPlistForView:self.titleLabel key:@"kiosktextcover"];
        
        self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
        
        self.titleLabel.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.layer.borderWidth = 0.0f;
        self.titleLabel.layer.borderColor = appDelegate.presetColorFiolet.CGColor;
        
//        UIImage *img = [UIImage imageNamed:@"tp@2x.png"];
//        CGSize imgSize = self.titleLabel.frame.size;
//        UIGraphicsBeginImageContext( imgSize );
//        [img drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
//        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        self.titleLabel.backgroundColor = [UIColor colorWithPatternImage:newImage];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.titleLabel.text = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
