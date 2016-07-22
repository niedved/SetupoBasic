/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/


#import <UIKit/UIKit.h>
#import "CloudRecoEAGLView.h"
#import "SampleApplicationSession.h"
#import "SampleAppMenu.h"
#import <QCAR/DataSet.h>

@interface CloudRecoViewController : UIViewController <SampleApplicationControl, SampleAppMenuCommandProtocol, UIGestureRecognizerDelegate>{
    CGRect viewFrame;
    CloudRecoEAGLView* eaglView;
    UITapGestureRecognizer * tapGestureRecognizer;
    SampleApplicationSession * vapp;
    
    QCAR::DataSet*  dataSet;
   
    BOOL fullScreenPlayerPlaying;
    
    UINavigationController * navController;
    
    BOOL scanningMode;
    BOOL isVisualSearchOn;
    BOOL offTargetTrackingEnabled;
    BOOL blockARHard;
    
    BOOL isShowingAnAlertView;
    int lastErrorCode;
}


@property (strong, nonatomic) UIView* b1;
@property (strong, nonatomic) UIView* b2;
@property (strong, nonatomic) UIView* b3;
@property (strong, nonatomic) UIView* b4;
@property (strong, nonatomic) UIView* b5;
@property (strong, nonatomic) UIView* b6;
@property (strong, nonatomic) UIView* b7;
@property (strong, nonatomic) UIView* b8;
@property (strong, nonatomic) UIView* b9;

@property (strong, nonatomic) NSMutableArray* bArray;
@property (strong, nonatomic) NSMutableArray* buttonsColection;

- (BOOL) isVisualSearchOn ;
- (void) toggleVisualSearch;
- (void)detectedNewMarker;

-(void)handleBTap:(UITapGestureRecognizer *)gestureRecognizer;


- (void)rootViewControllerPresentViewController:(UIViewController*)viewController inContext:(BOOL)currentContext;
- (void)rootViewControllerDismissPresentedViewController;

- (void) setNavigationController:(UINavigationController *) navController;



@end
