//
//  BHAlbum.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ishue.h"
@class BHPhoto;

@interface BHAlbum : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pagenum;
@property (nonatomic, strong) Ishue *issue;
@property (nonatomic, strong, readonly) NSArray *photos;

- (void)addPhoto:(BHPhoto *)photo;

- (void)addPhoto2:(UIImageView *)photo;
- (BOOL)removePhoto:(BHPhoto *)photo;

@end
