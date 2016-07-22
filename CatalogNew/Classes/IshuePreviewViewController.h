//
//  IshuePreviewViewController.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 24.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IshuePreviewViewController : UIViewController{
    IBOutlet UIImageView* imageViewCOntainer;
    
    IBOutlet UIButton* buttonBuy;
}




-(IBAction)swipeRight:(id)sender;
-(IBAction)swipeLeft:(id)sender;
@end
