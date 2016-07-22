//
//  SingleLandPageCatalogViewController.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 31.05.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbImageView.h"
#import "DBController.h"
#import "ICETutorialController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "ZoomableView.h"
#import "DZWebBrowser.h"
#import "GalleryPageViewController.h"





@interface SingleLandPageCatalogViewController : UIViewController
< ThumbImageViewDelegate, UIViewControllerTransitioningDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate >
{
    
    DBController* DBC;
    NSString        *currentImageNameLeft;
    
    UIScrollView    *thumbScrollView;
    CGRect leftOriginal;
    
    
    CGSize smallestSizeImg;
    int pageW,pageH;
    double prop, offset_y, offset_x;
    
    
@public
    NSMutableArray* buttonsForPageUIBUTTONS;
    NSMutableArray* buttonsForPage;
    AppDelegate* appDelegate;
    
    
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet ZoomableView *myZoomableView;

@property (retain, nonatomic) ZoomableView *myZoomableView2;
@property (retain, nonatomic) UIImageView *myImage;


//AUDIO
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) AVURLAsset* webAvAsset;
@property (strong, nonatomic) AVPlayerItem* webPlayerItem;
@property (strong, nonatomic) AVPlayer* webAudioPlayer;


@property (nonatomic, assign) int current_left_page;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;



@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
