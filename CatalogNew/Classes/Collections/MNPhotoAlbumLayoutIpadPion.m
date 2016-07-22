//
//  MNPhotoAlbumLayout.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "MNPhotoAlbumLayout22.h"
#import "AppDelegate.h"
#import "NHelper.h"

static NSString * const MNPhotoAlbumLayoutPhotoCellKind = @"PhotoCell";
static NSUInteger const PhotoCellBaseZIndex = 100;
NSString * const MNPhotoAlbumLayoutAlbumTitleKind22 = @"AlbumTitle";


@interface MNPhotoAlbumLayout22 ()


@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSArray *rotations;

@end

@implementation MNPhotoAlbumLayout22
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

-(void)setupSizes{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]){
        self.itemInsets = UIEdgeInsetsMake(10.0f, 20.0f, 20.0f, 0.0f);
        self.itemSize = CGSizeMake(120.0f, 160.0f);
        self.spacing = 35.0f;
        self.interItemSpacingY = 25.0f;
        self.numberOfColumns = 2;
        self.titleHeight = 25.0f;
        self.topMarginOfCollection = 30.0f;
    }
    else{
        if( [NHelper isLandscapeInReal] ){
            self.itemInsets = UIEdgeInsetsMake(10.0f, 270.0f, 5.0f, 5.0f);
            self.itemSize = CGSizeMake(200.0f, 200.0f);
            self.spacing = 100.0f;
            self.interItemSpacingY = 60.0f;
            self.numberOfColumns = 2;
            self.titleHeight = 25.0f;
            self.topMarginOfCollection = 30.0f;
        }
        else{
            self.itemInsets = UIEdgeInsetsMake(10.0f, 100.0f, 5.0f, 5.0f);
            self.itemSize = CGSizeMake(200.0f, 200.0f);
            self.spacing = 100.0f;
            self.interItemSpacingY = 60.0f;
            self.numberOfColumns = 2;
            self.titleHeight = 25.0f;
            self.topMarginOfCollection = 150.0f;
        }
    }

}


- (void)setup
{
    [self setupSizes];
    
}

- (CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
    frame.size.height = self.titleHeight - 0;
    return frame;
}

#pragma mark - Layout

- (void)prepareLayout
{
    NSLog(@"prepareLayout");
    [self setupSizes];
    
    
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
             frame.origin.y += self.topMarginOfCollection;
            itemAttributes.frame = frame;
            
            itemAttributes.zIndex = PhotoCellBaseZIndex + itemCount - item;

            cellLayoutInfo[indexPath] = itemAttributes;
            
            if (indexPath.item == 0) {
                UICollectionViewLayoutAttributes *titleAttributes = [UICollectionViewLayoutAttributes
                                                                     layoutAttributesForSupplementaryViewOfKind:MNPhotoAlbumLayoutAlbumTitleKind22
                                                                     withIndexPath:indexPath];
                titleAttributes.frame = [self frameForAlbumTitleAtIndexPath:indexPath];
               
                titleAttributes.hidden = NO;
                titleLayoutInfo[indexPath] = titleAttributes;
            }
        }
    }
    
    newLayoutInfo[MNPhotoAlbumLayoutPhotoCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
    newLayoutInfo[MNPhotoAlbumLayoutAlbumTitleKind22] = titleLayoutInfo;
    
}


#pragma mark - Private
- (CGRect)frameForAlbumPhotoAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.section / self.numberOfColumns;
    NSInteger column = indexPath.section % self.numberOfColumns;
    
    CGFloat originX = floorf(self.itemInsets.left + (self.itemSize.width + self.spacing) * column);
    
    
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
    NSLog(@"collectionViewContentSize");
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger rowCount = ceil((float)[appDelegate.ishuesForThisFolder count] / self.numberOfColumns);
    CGFloat height = self.itemInsets.top +
    rowCount * self.itemSize.height + (rowCount - 1) * self.interItemSpacingY +
    rowCount * self.titleHeight +
    self.itemInsets.bottom;
    CGFloat width = 320;
    height = 1000;
    NSLog(@"collectionViewContentSize: %f %f", width, height);
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
    return self.layoutInfo[MNPhotoAlbumLayoutAlbumTitleKind22][indexPath];
}


@end