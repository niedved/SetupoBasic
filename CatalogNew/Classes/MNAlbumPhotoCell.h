//
//  MNAlbumPhotoCell.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MNAlbumPhotoCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIImageView *imageViewSaved;
@property (nonatomic, strong, readonly) UILabel *labelViewOtworz;

@end
