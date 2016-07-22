//
//  MNAlbumPhotoCell.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "MNAlbumPhotoCell.h"
#import "NHelper.h"
#import <QuartzCore/QuartzCore.h>


@interface MNAlbumPhotoCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) UIImageView *imageViewSaved;
@property (nonatomic, strong, readwrite) UILabel *labelViewOtworz;


@end

@implementation MNAlbumPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    frame.origin.y += 5;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.90f alpha:1.0f];
        
        self.layer.borderColor = [NHelper colorFromPlist:@"kioskthumbbordercolor"].CGColor;
        self.layer.borderWidth = [[[NHelper appSettings] objectForKey:@"kioskthumbborder"] floatValue];
        self.layer.shadowColor = [NHelper colorFromPlist:@"kiosk_shadow_color"].CGColor;
        
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.layer.shadowOpacity = 0.3f;
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.imageView];
        
        
        self.labelViewOtworz = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height/2 - 15, self.bounds.size.width, 30)];
        [self.labelViewOtworz setBackgroundColor:[NHelper colorFromHexString:@"#111A5F"]];
        [self.labelViewOtworz setText:@"POBIERZ"];
        [self.labelViewOtworz setTextColor:[UIColor whiteColor]];
        [self.labelViewOtworz setTextAlignment:NSTextAlignmentCenter];
        [self.labelViewOtworz setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [self.labelViewOtworz setAlpha:0.69];
        [self.labelViewOtworz setHidden:YES];
        [self.contentView addSubview:self.labelViewOtworz];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}




@end