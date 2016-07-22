//
//  BMPhotoAlbumLayout.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "BMPhotoAlbumLayoutIphone.h"
#import "AppDelegate.h"

static NSString * const MNPhotoAlbumLayoutPhotoCellKind = @"PhotoCell";
static NSUInteger const RotationCount = 8;
static NSUInteger const RotationStride = 3;
static NSUInteger const PhotoCellBaseZIndex = 100;
NSString * const BMPhotoAlbumLayoutAlbumTitleKindIphoneLand = @"AlbumTitle";


@interface BMPhotoAlbumLayoutIphone ()


@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSArray *rotations;

@end

@implementation BMPhotoAlbumLayoutIphone
@synthesize itemSize;

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.itemInsets = UIEdgeInsetsMake(20.0f, 20.0f, 0.0f, 0.0f);
    self.itemSize = CGSizeMake(100.0f, 135.0f);
    self.interItemSpacingY = 15.0f;
    self.interItemSpacingX = 80.0f;
    self.numberOfColumns = 40;
    self.titleHeight = 15.0f;
    
    // create rotations at load so that they are consistent during prepareLayout
    NSMutableArray *rotations = [NSMutableArray arrayWithCapacity:RotationCount];

    CGFloat percentage = 0.0f;
    for (NSInteger i = 0; i < RotationCount; i++) {
        // ensure that each angle is different enough to be seen
        CGFloat newPercentage = 0.0f;
        do {
            newPercentage = ((CGFloat)(arc4random() % 220) - 110) * 0.0001f;
        } while (fabsf(percentage - newPercentage) < 0.006);
        percentage = newPercentage;
        percentage = 0;
        
        CGFloat angle = 2 * M_PI * (1.0f + percentage);
        CATransform3D transform = CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
        
        [rotations addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    self.rotations = rotations;

    
}
- (CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
//    frame.origin.y += frame.size.height;
//    frame.origin.y = 0;
    frame.size.height = self.titleHeight - 0;
    
    return frame;
}

#pragma mark - Layout

- (void)prepareLayout
{
//    self.collectionView setD
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *titleLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

            CGRect frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
             frame.origin.y += 30;
            itemAttributes.frame = frame;
            itemAttributes.transform3D = [self transformForAlbumPhotoAtIndex:indexPath];
            itemAttributes.zIndex = PhotoCellBaseZIndex + itemCount - item;
            cellLayoutInfo[indexPath] = itemAttributes;
            
            if (indexPath.item == 0) {
                UICollectionViewLayoutAttributes *titleAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:BMPhotoAlbumLayoutAlbumTitleKindIphoneLand withIndexPath:indexPath];
                titleAttributes.frame = [self frameForAlbumTitleAtIndexPath:indexPath];
                titleLayoutInfo[indexPath] = titleAttributes;
            }
        }
    }
    
    newLayoutInfo[MNPhotoAlbumLayoutPhotoCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
    newLayoutInfo[BMPhotoAlbumLayoutAlbumTitleKindIphoneLand] = titleLayoutInfo;
    
}

#pragma mark - Private

- (CGRect)frameForAlbumPhotoAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.section / self.numberOfColumns;
//    NSInteger column = indexPath.section;
    NSInteger column = indexPath.section % self.numberOfColumns;

    CGFloat originX = floorf(self.itemInsets.left + (self.itemSize.width + self.interItemSpacingX) * column);
        
    CGFloat originY = floor(self.itemInsets.top +
                            (self.itemSize.height + self.titleHeight + self.interItemSpacingY) * row);

    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[MNPhotoAlbumLayoutPhotoCellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger rowCount = ceil((float)[appDelegate.bookmarksColection count] / 4.0f);
    // make sure we count another row if one is only partially filled
    if ([self.collectionView numberOfSections] % self.numberOfColumns) rowCount++;
    
    CGFloat width = self.itemInsets.left +
    [self.collectionView numberOfSections] * self.itemSize.width + [self.collectionView numberOfSections] * self.interItemSpacingX +
    self.itemInsets.right;
    
    NSLog(@"self.collectionView numberOfSections: %d %f", [self.collectionView numberOfSections], width) ;
    
    CGFloat height = 220;
    return CGSizeMake(width, height);
}

#pragma mark - Properties

- (void)setItemInsets:(UIEdgeInsets)itemInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(_itemInsets, itemInsets)) return;
    
    _itemInsets = itemInsets;
    
    [self invalidateLayout];
}

- (void)setItemSize:(CGSize)aitemSize
{
//    if (CGSizeEqualToSize(_itemSize, itemSize)) return;
    
    itemSize = aitemSize;
    
    [self invalidateLayout];
}

- (void)setInterItemSpacingY:(CGFloat)interItemSpacingY
{
    if (_interItemSpacingY == interItemSpacingY) return;
    
    _interItemSpacingY = interItemSpacingY;
    
    [self invalidateLayout];
}


- (void)setInterItemSpacingX:(CGFloat)interItemSpacingX
{
    if (_interItemSpacingX == interItemSpacingX) return;
    
    _interItemSpacingX = interItemSpacingX;
    
    [self invalidateLayout];
}

- (void)setNumberOfColumns:(NSInteger)numberOfColumns
{
    if (_numberOfColumns == numberOfColumns) return;
    
    _numberOfColumns = numberOfColumns;
    
    [self invalidateLayout];
}

- (void)setTitleHeight:(CGFloat)titleHeight
{
    if (_titleHeight == titleHeight) return;
    
    _titleHeight = titleHeight;
    
    [self invalidateLayout];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[BMPhotoAlbumLayoutAlbumTitleKindIphoneLand][indexPath];
}


- (CATransform3D)transformForAlbumPhotoAtIndex:(NSIndexPath *)indexPath
{
    
    NSInteger offset = (indexPath.section * RotationStride + indexPath.item);
    return [self.rotations[offset % RotationCount] CATransform3DValue];
}

@end


