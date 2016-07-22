//
//  MNPhotoAlbumLayout.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const BMPhotoAlbumLayoutAlbumTitleKind;

//
//@interface MNPhotoAlbumLayout : UICollectionViewLayout
@interface BMPhotoAlbumLayoutIphone : UICollectionViewFlowLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) CGFloat interItemSpacingX;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) CGFloat titleHeight;


@end
