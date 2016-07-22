//
//  GalleryContentViewController.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 25.05.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryContentViewController : UIViewController<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;


@end



