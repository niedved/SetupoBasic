//
//  MNCollectionViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "BMCollectionViewController.h"
#import "BMPhotoAlbumLayout.h"
#import "BMPhotoAlbumLayoutIphone.h"
#import "BMPhotoAlbumLayoutIphonePion.h"
#import "BMPhotoAlbumLayoutIpadPion.h"
#import "MNAlbumPhotoCell.h"
#import "MNAlbumTitleReusableView.h"
#import "AppDelegate.h"
#import "STabBarControler.h"
#import "NHelper.h"

static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@interface BMCollectionViewController ()


@property (nonatomic, weak) IBOutlet MNPhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) NSMutableArray *albums;

@end

@implementation BMCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"BMCollectionViewController");
        if( [NHelper isLandscapeInReal] ){
            if ( [NHelper isIphone] ){
                UICollectionViewFlowLayout *flowLayout = [[BMPhotoAlbumLayoutIphone alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
            }
            else{
                UICollectionViewFlowLayout *flowLayout = [[BMPhotoAlbumLayout alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
            }
        }
        else{
            if ( [NHelper isIphone] ){
                UICollectionViewFlowLayout *flowLayout = [[BMPhotoAlbumLayoutIphonePion alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
            }
            else{
                UICollectionViewFlowLayout *flowLayout = [[BMPhotoAlbumLayoutIpadPion alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
            }
        }
        
        
        
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [AppDelegate setColorFromPlistForView:self.collectionView key:@""];
//    [AppDelegate setColorFromPlistForView:self.view key:@"kiosklargebg"];
//    [AppDelegate setColorFromPlistForView:self.collectionView key:@"kiosklargebg"];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    
    [self.collectionView registerClass:[MNAlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    [self.collectionView registerClass:[MNAlbumTitleReusableView class]
            forSupplementaryViewOfKind:BMPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    //
    
    
    
}


-(void)setLandscape:(CGRect)parentFrameSize{
    self.view.frame = CGRectMake(0,0,parentFrameSize.size.width,parentFrameSize.size.height);
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]){
        self.photoAlbumLayout.numberOfColumns = 14;
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(11.0f, 11.0f, 7.0f, 11.0f);
    }
    else{
        self.photoAlbumLayout.numberOfColumns = 14;
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(2.0f, 30.0f, 23.0f, 22.0f);
    }
    
}

-(void)setPortrait:(CGRect)parentFrameSize{
    NSLog(@"MN:setPort");
    self.view.frame = CGRectMake(0,0,parentFrameSize.size.width,parentFrameSize.size.height);
    self.photoAlbumLayout.numberOfColumns = 14;
    self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"BM: viewDidAppear");
    
    STabBarControler* sttab = (STabBarControler*)appDelegate.viewController.tabBarController;
    [sttab hideIt];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
