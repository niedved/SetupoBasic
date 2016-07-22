//
//  IshuePreviewViewController.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 24.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "IshuePreviewViewController.h"
#import "IshueImageView.h"

@interface IshuePreviewViewController ()

//@property (readonly) NSArray *images;

@property (nonatomic, strong) NSArray *images;


@end

@implementation IshuePreviewViewController
@synthesize images;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.9f];
//    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    
    
    self.view.layer.borderColor = [UIColor colorWithRed:0.93 green:146.0/255.0 blue:16.0/255.0 alpha:1.0].CGColor;
    self.view.layer.borderWidth = 3.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius = 3.0f;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.view.layer.shadowOpacity = 0.5f;
    // make sure we rasterize nicely for retina
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.view.layer.shouldRasterize = YES;
    
    
    buttonBuy.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonBuy.layer.borderWidth = 1.0f;
    buttonBuy.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonBuy.layer.shadowRadius = 1.0f;
    buttonBuy.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    buttonBuy.layer.shadowOpacity = 0.5f;
    
    
//    IshueImageView* iiv = [[IshueImageView alloc] initWithFrame:CGRectMake(20, 60, 220, 300)];
    [imageViewCOntainer setImage:[UIImage imageNamed:@"1_thumb"]];
    imageViewCOntainer.layer.borderColor = [UIColor whiteColor].CGColor;
    imageViewCOntainer.layer.borderWidth = 1.0f;
    
}


-(IBAction)swipeRight:(id)sender
{
    NSLog(@"swR");
    [UIView transitionWithView:imageViewCOntainer
duration:1.5
options: UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
        imageViewCOntainer.frame = CGRectMake(-320, 0, 10, 10);
    }
completion:^(BOOL finished){
    [imageViewCOntainer removeFromSuperview];
    //animCompleteHandlerCode..
}
    ];
    
}

-(IBAction)swipeLeft:(id)sender
{
    NSLog(@"swL");
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
