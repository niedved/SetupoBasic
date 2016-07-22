//
//  MNCollectionViewController.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNPhotoAlbumLayout.h"
#import "BHAlbum.h"
#import "BHPhoto.h"

@interface MNCollectionViewController : UICollectionViewController <UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    
    
     
}





-(void)setLandscape:(CGRect)parentFrameSize;
-(void)setPortrait:(CGRect)parentFrameSize;

@end
