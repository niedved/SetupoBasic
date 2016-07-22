//
//  GalleryContentViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 25.05.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//
#import "GalleryContentViewController.h"
#import "AppDelegate.h"
#import "NHelper.h"

@interface GalleryContentViewController ()
@end

@implementation GalleryContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* fullFilePath = [[self pathToIssuePagesFile] stringByAppendingPathComponent:self.imageFile];
//    BOOL pageFileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath];
    NSData *imageData = [NSData dataWithContentsOfFile:fullFilePath];
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.backgroundImageView.image = [UIImage imageWithData:imageData];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentGalleryImage = self.backgroundImageView.image;
    self.titleLabel.text = self.titleText;
    [self prepareTap];
    self.navigationController.navigationBar.topItem.title = @"";
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    self.navigationController.navigationBar.topItem.title = @"";
}

-(void) prepareTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

-(void) handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ( appDelegate.navShow )
        [appDelegate hideNavig];
    else
        [appDelegate showNavig];
}

-(NSString*)pathToIssuePagesFile{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFilePath = documentsDirectory;//[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",ishue_id] ];
    return fullFilePath;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end