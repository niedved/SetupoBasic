#import "AppDelegate.h"
#import "RootViewControllerL1a.h"
#import "BMCollectionViewController.h"
#import "MNPhotoAlbumLayout.h"
#import "MNAlbumPhotoCell.h"
#import "BHAlbum.h"
#import "BHPhoto.h"
#import "MNAlbumTitleReusableView.h"
#import <CoreData/CoreData.h>
#import "STabBarControler.h"
#import "BookMarksVC.h"
#import "NHelper.h"

static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@interface BookMarksVC (){
    IBOutlet UIView* viewForCollection;
    RootViewControllerL1a* destViewController;
    BMCollectionViewController* mnCollectionViewController;
    AppDelegate* appDelegate;
}

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) BMCollectionViewController* mnCollectionViewController;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;


@end

@implementation BookMarksVC

@synthesize mnCollectionViewController;



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tlo"]]];
    [self.view setBackgroundColor:[NHelper colorFromPlist:@"bookmarks_bg_color"]];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[self navigationController] setNavigationBarHidden:YES animated:appDelegate->animallowed];
    DBC = [[DBController alloc] init];
    
    [NHelper setColorFromPlistForView:self.topBarView key:@"topbarbg"];
    
    [NHelper setColorLabelFromPlistForView:self.labelTop key:@"bookmarkslabeltop"];
    [self.labelTop setFont:[NHelper getFontDefault:23.0f bold:YES] ];//[UIFont systemFontOfSize:24]];
    
    [self.labelTop setTextAlignment:NSTextAlignmentCenter];
    
    
    UIImage* img = [NHelper imagedColorized:@"backbutton2" withColor:[UIColor redColor]];
    [NHelper setColorFromPlistForView:self.topbarPoziomaLinia key:@"topbarlinebg"];
    
    [self.backButton setImage:img forState:UIControlStateNormal];
    self.backButton.tintColor = [NHelper colorFromPlist:@"bookmarkslabeltop"];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    
    if( [NHelper isIphone] ){
        [self correctIphone];
    }
    else{
        [self correct];
    }

    
    
}





-(void)viewDidAppear:(BOOL)animated{
    
    [appDelegate hideFadeAnim:0.2f delay:0.0f];
    appDelegate.appStage = 3;
    appDelegate.bookmarksActive = NO;
    appDelegate.bookmarksActivePro = NO;
//    [self correct];
    
}

-(IBAction)hide:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:NO completion:NULL];
}


// Add this method
- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) prepareKolekcjaIshuesView{
    NSLog(@"prepareKolekcjaIshuesView");
    [mnCollectionViewController.view removeFromSuperview];
    
    mnCollectionViewController = [[BMCollectionViewController alloc] initWithNibName:@"BMCollectionViewController" bundle:nil];
    CGSize iphoneSize = [NHelper getSizeOfCurrentDeviceOrient];
    
    mnCollectionViewController.view.frame = CGRectMake(0, 0, iphoneSize.width, iphoneSize.height);
    mnCollectionViewController.collectionView.dataSource = self;
    mnCollectionViewController.collectionView.delegate = self;
    [viewForCollection addSubview:mnCollectionViewController.view];
    
}

-(void)preapreThumbsButtons{
    self.albums = [NSMutableArray array];
    
    NSInteger photoIndex = 0;
    for (BookMark* bm in appDelegate.bookmarksColection ) {
        BHAlbum *album = [[BHAlbum alloc] init];
        album.name = bm.name;
        album.pagenum = [NSString stringWithFormat:@"%d", bm->pageNum];
        for (NSInteger p = 0; p <= 0; p++) {
            NSURL *photoURL = [NSURL URLWithString:bm.coverThumbUrl];
            BHPhoto *photo = [BHPhoto photoWithImageURL:photoURL];
            [album addPhoto:photo];
            photoIndex++;
        }
        
        [self.albums addObject:album];
    }
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [appDelegate reloadBookmarks];
    [self prepareKolekcjaIshuesView];
    [self preapreThumbsButtons];
    
    if( [NHelper isIphone] ){
        [self correctIphone];
    }

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)orientationChanged:(NSNotification *)notification{
    [self handleOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) handleOrientation:(UIInterfaceOrientation) orientation {
    if( [NHelper isIphone] ){
        [self correctIphone];
    }
    else{
        [self correct];
    }
}


-(void)correctIphone{
    if( [NHelper isLandscapeInReal] ){
        [self correctKioskSizeForLandIphone];
        [self correctTopSizeForLandIphone];
    }
    else{
        
        [self correctKioskSizeForPortIphone];
        [self correctTopSizeForPortIphone];
    }
}

-(void)correctTopSizeForPortIphone{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize iphoneSize = [NHelper getSizeOfCurrentDevicePortrait];
        float heightOfTop = 60;
        CGRect rect = CGRectMake(0, 0, iphoneSize.width, heightOfTop);
        self.topBarView.frame = rect;
        self.labelTop.center = self.topBarView.center;
    });
}

-(void)correctTopSizeForLandIphone{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize iphoneSize = [NHelper getSizeOfCurrentDeviceLandscape];
        float heightOfTop = 60;
        CGRect rect = CGRectMake(0, 0, iphoneSize.width, heightOfTop);
        self.topBarView.frame = rect;
        self.labelTop.center = self.topBarView.center;
    });
}

-(void)correctKioskSizeForPortIphone{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGSize iphoneSize = [NHelper getSizeOfCurrentDevicePortrait];
        
        
        float heightOfTop = 60;
        viewForCollection.frame =
        CGRectMake(0, heightOfTop, iphoneSize.width, iphoneSize.height-heightOfTop);
        mnCollectionViewController.view.frame =
            CGRectMake(0,0,viewForCollection.frame.size.width, viewForCollection.frame.size.height);
        [self prepareKolekcjaIshuesView];
    });
}

-(void)correctKioskSizeForLandIphone{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize iphoneSize = [NHelper getSizeOfCurrentDeviceLandscape];
        float heightOfTop = 60;
        viewForCollection.frame =
        CGRectMake(0, heightOfTop, iphoneSize.width, iphoneSize.height-heightOfTop);
        mnCollectionViewController.view.frame =
        CGRectMake(0,0,viewForCollection.frame.size.width, viewForCollection.frame.size.height);
        [self prepareKolekcjaIshuesView];
    });
}

-(void)correct{
    if( [NHelper isLandscapeInReal] ){
        [NHelper showRectParams:self.view.frame label:@"dupa lands"];
        
        //        [self.favLab setFrame:CGRectMake(0, 110, 1024, 20)];
        [self correctKioskSizeForLand];
        
    }
    else{
        [NHelper showRectParams:self.view.frame label:@"dupa portrait"];
        
        //        [self.favLab setFrame:CGRectMake(0, 110, 768, 20)];
        [self correctKioskSizeForPort];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize iphoneSize = [NHelper getSizeOfCurrentDeviceOrient];
        float heightOfTop = 84;
        CGRect rect = CGRectMake(0, 0, iphoneSize.width, heightOfTop);
        [self.topBarView setFrame:rect];
        self.labelTop.center = self.topBarView.center;
    });
    
    CGSize size = [NHelper getSizeOfCurrentDevicePortrait];
    CGRect frameTop = self.topBarView.frame;
    frameTop.size.width = size.width;
    [self.topBarView setFrame:frameTop];
}



-(void)correctKioskSizeForPort{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize iphoneSize = [NHelper getSizeOfCurrentDevicePortrait];
        float heightOfTop = 84;
        viewForCollection.frame =
        CGRectMake(0, heightOfTop, iphoneSize.width, iphoneSize.height-heightOfTop);
        mnCollectionViewController.view.frame =
        CGRectMake(0,0,viewForCollection.frame.size.width, viewForCollection.frame.size.height);
        [self prepareKolekcjaIshuesView];
    });
}


-(void)correctKioskSizeForLand{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize iphoneSize = [NHelper getSizeOfCurrentDeviceLandscape];
        float heightOfTop = 84;
        viewForCollection.frame =
        CGRectMake(0, heightOfTop, iphoneSize.width, iphoneSize.height-heightOfTop);
        mnCollectionViewController.view.frame =
        CGRectMake(0,0,viewForCollection.frame.size.width, viewForCollection.frame.size.height);
        [self prepareKolekcjaIshuesView];
    });
    
}





/************************************
* COLECTION DATAS INFOS ETC - START *
************************************/

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate createLoginFadeBackground];
    
        
        BookMark* bm = [appDelegate.bookmarksColection objectAtIndex:indexPath.section];

        
        appDelegate.forcePageNum = bm->bookmark_id;
        NSLog(@"bm: %d %d", appDelegate.forcePageNum, bm->bookmark_id );
        NSLog(@"bm: %d", bm->ishue_id );
        
        Ishue* clickedI;
        for (Ishue* issue in appDelegate.ishuesColection ) {
            if ( issue->ishue_id == bm->ishue_id ){
                clickedI = issue;
                appDelegate.currentIshue = clickedI;
                break;
            }
        }
        
        
        [self afterSelect];
    });
}


-(void)afterSelect{
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate.viewController ishueButtonClicked];
    NSLog(@"afterSelectafterSelectafterSelectafterSelectafterSelectafterSelectafterSelectafterSelectafterSelectafterSelect: C"); //HERE
    });
}




-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath  *)indexPath{
//    NSLog(@"deselected:%d", indexPath.section);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [appDelegate.bookmarksColection count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    BHAlbum *album = self.albums[section];
    return album.photos.count;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    MNAlbumTitleReusableView *titleView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:AlbumTitleIdentifier
                                              forIndexPath:indexPath];
    
    long section = indexPath.section;
    BHAlbum *album = self.albums[section];
    
    titleView.titleLabel.text = [NSString stringWithFormat:@"%@, s.%@", [album.name uppercaseString], album.pagenum];
    [titleView.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [NHelper setColorLabelFromPlistForView:titleView.titleLabel key:@"bookmarkslabelstext"];
    return titleView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
    BookMark* bm = [appDelegate.bookmarksColection objectAtIndex:indexPath.section];
    photoCell.imageView.image = bm.coverThumbImg;
    photoCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    photoCell.imageView.clipsToBounds = YES;
    return photoCell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end