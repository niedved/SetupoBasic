//
//  StartController.h
//  wSieci
//
//  Created by Marcin Niedźwiecki on 01.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartController : UIViewController<UITextFieldDelegate>{
    
}

@property bool dontshow;
@property (strong, nonatomic) IBOutlet UIView *codeTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeText;
@property (strong, nonatomic) IBOutlet UIButton *buttonIss1,*buttonIss2;


@end
