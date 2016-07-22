//
//  MNPhotoAlbumLayout.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>

//UIKIT_EXTERN NSString * const MNPhotoAlbumLayoutAlbumTitleKind;

//
//@interface MNPhotoAlbumLayout : UICollectionViewLayout
@interface MNPhotoAlbumLayout22 : UICollectionViewFlowLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) CGFloat spacing;
@property (nonatomic) CGFloat topMarginOfCollection;
@property (nonatomic) CGFloat titleHeight;


@end
