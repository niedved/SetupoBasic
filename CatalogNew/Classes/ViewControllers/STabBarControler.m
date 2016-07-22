//
//  STabBarControler.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 01.03.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "STabBarControler.h"
#import "AppDelegate.h"

@interface STabBarControler ()

@end

@implementation STabBarControler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (BOOL)shouldAutorotate
{
    return YES;
}




-(void)hideIt{
    UITabBar *tabBar = self.tabBar;
    [tabBar setHidden:YES];
}
-(void)showIt{
    UITabBar *tabBar = self.tabBar;
    [tabBar setHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    [[UITabBar appearance] setTintColor:[appDelegate presetColorFiolet]];
    [[UITabBar appearance] setBarTintColor:[appDelegate presetColorSzary]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys:
                                                       [UIColor grayColor], NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateNormal];
    
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    
    tabBarItem1.title = @"Wydania PAR";
    
    [self.tabBar setHidden:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     self.tabBar.hidden = YES;
    [self hideIt];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
