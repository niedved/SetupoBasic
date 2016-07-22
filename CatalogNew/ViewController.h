//
//  ViewController.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 11.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBController.h"
#import "LoadViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "Ishue.h"
#import "MNCollectionViewController.h"

#import <MediaPlayer/MediaPlayer.h>
//#import "PurchaseViewController.h"

@interface ViewController : UIViewController<UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
UICollectionViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate,SKPaymentTransactionObserver, SKProductsRequestDelegate>{
    DBController* DBC;
    NSDictionary* ishues;
    
    IBOutlet UIActivityIndicatorView *indView;
    
    @public
    IBOutlet UIView* viewForCollection;
    MNCollectionViewController* mnCollectionViewController;
    
    int curent_folder_id;
    UIImageView *oflineimageview;
    NSArray *_products;
    
    
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLogoCenterHorizontalDelta;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kioskLargeViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kioskLargeViewHEight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForCollectionWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForCollectionWidthiPhoneLandscape;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForCollectionWidthiPhonePortrait;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForCollectionHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelDescription1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelDescription2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelDescription3Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelDescription4Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelDescription5Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopic1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopic2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopic3Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopic4Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopic5Height;



@property (strong, nonatomic) IBOutlet UIButton *level2Button;


@property (weak, nonatomic) IBOutlet UIImageView *toplogo;

@property(nonatomic, strong) UIRefreshControl* refreshControl;
@property(nonatomic, strong) NSMutableDictionary *searchResults;
@property(nonatomic, strong) NSMutableArray *searches;
@property(nonatomic, strong) IBOutlet UITabBar *tabBar;
@property(nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl, *segmentedControlBottom;
@property(nonatomic, strong) IBOutlet UIButton *folderLevelBackButton;
@property(nonatomic, strong) IBOutlet UIButton *butonBookmarks, *butonSubsciption, *buttonAR;

@property(nonatomic, strong) IBOutlet UILabel *kioskL1, *kioskL2, *kioskL3, *kioskL4, *kioskL5, *kioskLL;
@property(nonatomic, strong) IBOutlet UILabel *kioskLT1, *kioskLT2, *kioskLT3, *kioskLT4, *kioskLT5;
@property(nonatomic, strong) IBOutlet UIView *topBarView, *topBarViewLineBottom;
@property(nonatomic, strong) IBOutlet UIView *bottomBarViewLineBottom, *bottomViewBar;


@property(nonatomic, strong) IBOutlet UIView *kioskLargeView, *pionLineKiosk;
@property(nonatomic, strong) IBOutlet UIView *kioskLargeStrzalkaView;
@property(nonatomic, strong) IBOutlet UILabel *kioskLargeStrzalkaLabel,*kioskLargeStrzalkaCena;
@property(nonatomic, strong) IBOutlet UIButton *kioskLargeOkladka, *kioskLargeOkladkaOko;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) AVURLAsset* webAvAsset;
@property (strong, nonatomic) AVPlayerItem* webPlayerItem;
@property (strong, nonatomic) AVPlayer* webAudioPlayer;

@property (strong, nonatomic) IBOutlet UIButton* banner;

@property (nonatomic, strong) UIView* modalView;
@property (nonatomic, strong) UIView*  _hudView;


-(void)bannerClicked:(UIButton*)button;
-(void) refreshPreview;

-(void)playMovie: (NSString*)url_string;

-(void)tapDetected;
-(void)reloadThumbs:(BOOL)fav;
-(void)hideIshueActionView;

-(void)showIshueActionView:(Ishue*)clickedIssue;
- (void) ishueButtonClicked;

- (void)buyProductIdentifier:(NSString *)productIdentifier;

-(void)destViewControllerDupa: (int)page;

- (IBAction)segmentAction:(id)sender;
- (IBAction)folderLevelBackButtonAction:(id)sender;
-(IBAction)selectedLargeKiosk:(id)sender;

-(void)prepareKolekcjaIshuesView;
@end
