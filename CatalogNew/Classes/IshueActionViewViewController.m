//
//  IshueActionViewViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 18.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "IshueActionViewViewController.h"
#import "IshueImageView.h"

@interface IshueActionViewViewController ()

@end

@implementation IshueActionViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.85f];
    
    
    self.view.layer.borderColor = [UIColor whiteColor].CGColor;
    self.view.layer.borderWidth = 3.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius = 3.0f;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.view.layer.shadowOpacity = 0.5f;
    // make sure we rasterize nicely for retina
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.view.layer.shouldRasterize = YES;
    
    
    IshueImageView* iiv = [[IshueImageView alloc] initWithFrame:CGRectMake(20, 60, 220, 300)];
    [iiv setImage:[UIImage imageNamed:@"1_thumb"]];
    [self.view addSubview:iiv];
    
    
    buttonBuy.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonBuy.layer.borderWidth = 1.0f;
    buttonBuy.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonBuy.layer.shadowRadius = 1.0f;
    buttonBuy.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    buttonBuy.layer.shadowOpacity = 0.5f;
    
    buttonPreview.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonPreview.layer.borderWidth = 1.0f;
    buttonPreview.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonPreview.layer.shadowRadius = 1.0f;
    buttonPreview.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    buttonPreview.layer.shadowOpacity = 0.5f;
    
    buttonFav.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonFav.layer.borderWidth = 1.0f;
    buttonFav.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonFav.layer.shadowRadius = 1.0f;
    buttonFav.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    buttonFav.layer.shadowOpacity = 0.5f;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
