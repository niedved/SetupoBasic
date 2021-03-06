//
//  MNPhotoAlbumLayout.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "MNPhotoAlbumLayout.h"
#import "AppDelegate.h"
#import "NHelper.h"

//IPAD

static NSString * const MNPhotoAlbumLayoutPhotoCellKind = @"PhotoCell";
static NSUInteger const PhotoCellBaseZIndex = 100;
NSString * const MNPhotoAlbumLayoutAlbumTitleKind = @"AlbumTitle";
@interface MNPhotoAlbumLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSArray *rotations;

@end

@implementation MNPhotoAlbumLayout
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
    float pageprops = 50.0f / 63.0f;// [[[NHelper appSettings] objectForKey:@"pagewidth"] floatValue] / [[[NHelper appSettings] objectForKey:@"pageheight"] floatValue];
    
    self.itemInsets = UIEdgeInsetsMake(35.0f, 60.0f, 5.0f, 5.0f);
    self.itemSize = CGSizeMake(172, 172/(50.0f / 63.0f));
    self.interItemSpacingY = 50.0f;
    self.numberOfColumns = 1;
    self.titleHeight = 25.0f;
}

- (CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
    frame.size.height = self.titleHeight - 0;
    frame.origin.y += 172/(50.0f / 63.0f);
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
            if( [NHelper isIphone])
                frame.origin.y += 15;
            else
                frame.origin.y += 0;
            
            itemAttributes.frame = frame;
            itemAttributes.zIndex = PhotoCellBaseZIndex + itemCount - item;
            cellLayoutInfo[indexPath] = itemAttributes;
            
            if (indexPath.item == 0) {
                UICollectionViewLayoutAttributes *titleAttributes = [UICollectionViewLayoutAttributes
                                                                     layoutAttributesForSupplementaryViewOfKind:MNPhotoAlbumLayoutAlbumTitleKind
                                                                     withIndexPath:indexPath];
                titleAttributes.frame = [self frameForAlbumTitleAtIndexPath:indexPath];
               
                
                titleLayoutInfo[indexPath] = titleAttributes;
            }
        }
    }
    
    newLayoutInfo[MNPhotoAlbumLayoutPhotoCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
    newLayoutInfo[MNPhotoAlbumLayoutAlbumTitleKind] = titleLayoutInfo;
}

#pragma mark - Private

- (CGRect)frameForAlbumPhotoAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger column = indexPath.section;
    CGFloat spacingX = self.collectionView.bounds.size.width -
    self.itemInsets.left -
    self.itemInsets.right -
    (self.numberOfColumns * self.itemSize.width);
    spacingX = 80.0f;
//    CGFloat originX = floorf(self.itemInsets.left + (self.itemSize.width + spacingX) * column);
    CGFloat originX = floorf(self.itemInsets.left );
    CGFloat originY = floorf(self.itemInsets.top + (self.itemSize.height + 50) * column );
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
    NSInteger rowCount = [self.collectionView numberOfSections];
    if ([self.collectionView numberOfSections] % self.numberOfColumns) rowCount++;
    CGFloat height = self.itemInsets.top +
    rowCount * self.itemSize.height + (rowCount) * self.interItemSpacingY +
    rowCount * self.titleHeight +
    self.itemInsets.bottom;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)){
        
    }
    else{
        height = self.itemInsets.top +
        rowCount * self.itemSize.height + (rowCount) * self.interItemSpacingY *2 +
        rowCount * self.titleHeight*2 +
        self.itemInsets.bottom;
    }
    
    CGFloat width = self.itemInsets.left +
    (([self.collectionView numberOfSections]) * (self.itemSize.width + 60)  +
    self.itemInsets.right);
    
    if( [NHelper isIphone] )
        width = 122;
    else
        width = 289;
    
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
    return self.layoutInfo[MNPhotoAlbumLayoutAlbumTitleKind][indexPath];
}



@end


