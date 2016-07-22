//
//  MNCollectionViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 17.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "MNCollectionViewController.h"
#import "MNPhotoAlbumLayout.h"
#import "MNPhotoAlbumLayout22.h"
#import "MNPhotoAlbumLayoutIpadPion.h"
#import "MNAlbumPhotoCell.h"
#import "MNAlbumTitleReusableView.h"
#import "MNPhotoAlbumLayoutIphonePoziom.h"
#import "AppDelegate.h"
#import "STabBarControler.h"
#import "NHelper.h"

static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@interface MNCollectionViewController ()

@property (nonatomic, weak) IBOutlet MNPhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) NSMutableArray *albums;

@end

@implementation MNCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"MNCollectionViewController");
        if( [NHelper isLandscapeInReal] ){
            if ( [NHelper isIphone] ){
                UICollectionViewFlowLayout *flowLayout = [[MNPhotoAlbumLayoutIphonePoziom alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
                
            }
            else{
                UICollectionViewFlowLayout *flowLayout = [[MNPhotoAlbumLayout alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
                
                CGRect f = self.view.frame;
                f.size.width = 1024.0f;
                [self.view setFrame:f];
            }
            
            
        }
        else{
            if ( [NHelper isIphone] ){
                UICollectionViewFlowLayout *flowLayout = [[MNPhotoAlbumLayout22 alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
                
                
                CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
                CGRect f = self.view.frame;
                f.size.height = size.height - 48*2;
                [self.view setFrame:f];
                
            }
            else{
                UICollectionViewFlowLayout *flowLayout = [[MNPhotoAlbumLayoutIpadPion alloc]init];
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [self.collectionView setCollectionViewLayout:flowLayout];
                [self.collectionView setShowsVerticalScrollIndicator:YES];
                [self.collectionView setShowsHorizontalScrollIndicator:YES];
                [self.collectionView flashScrollIndicators];
                
                CGRect f = self.view.frame;
                f.size.width = 768.0f;
                f.size.height = 1024.0f - 1532/2;
                [self.view setFrame:f];
                [self.collectionView setBackgroundColor:[UIColor clearColor]];
                
                

            }
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
//    [AppDelegate setColorFromPlistForView:self.collectionView key:@"kioskbg"];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    
    [self.collectionView registerClass:[MNAlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    [self.collectionView registerClass:[MNAlbumTitleReusableView class]
            forSupplementaryViewOfKind:MNPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    

    
    
    
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}


//@TODO
-(void)setLandscape:(CGRect)parentFrameSize{
    self.view.frame = CGRectMake(0,0,parentFrameSize.size.width,parentFrameSize.size.height);
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]){
        self.photoAlbumLayout.numberOfColumns = 2;
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
    
    
    self.photoAlbumLayout.numberOfColumns = 2;
    self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    STabBarControler* sttab = (STabBarControler*)appDelegate.viewController.tabBarController;
    [sttab hideIt];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
