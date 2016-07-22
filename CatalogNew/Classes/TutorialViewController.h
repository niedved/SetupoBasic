//
//  TutorialViewController.h
//  ArfixerTV
//
//  Created by Marcin Niedźwiecki on 12.05.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//
#import "TutorialContentViewController.h"

@interface TutorialViewController : UIViewController <UIPageViewControllerDataSource>


@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;


- (TutorialContentViewController *)viewControllerAtIndex:(NSUInteger)index;

@end