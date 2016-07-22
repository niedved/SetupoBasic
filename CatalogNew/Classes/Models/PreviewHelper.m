//
//  KioskHelper.m
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 03.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//
#import "AppDelegate.h"
#import "NHelper.h"

#import "PreviewHelper.h"

@implementation PreviewHelper

+(void)setTapAndSwipeDetails:(TuiCatalogGalleryController*)previewViewController{
    //Add a left swipe gesture recognizer
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:previewViewController
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [previewViewController.imageScrollView addGestureRecognizer:recognizer];
    //Add a right swipe gesture recognizer
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:previewViewController
                                                           action:@selector(handleSwipeRight:)];
    recognizer.delegate = previewViewController;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [previewViewController.imageScrollView addGestureRecognizer:recognizer];
}


+(void)setViewDetails:(TuiCatalogGalleryController*)previewViewController{
    previewViewController.view.layer.borderColor = [NHelper colorFromPlist:@"previewborder"].CGColor;
    [previewViewController.view setBackgroundColor:[NHelper colorFromPlist:@"previewbg"]];
    
    previewViewController.view.layer.cornerRadius = [[[NHelper appSettings] objectForKey:@"previewrounded"] floatValue];
    previewViewController.view.layer.masksToBounds = YES;
    
    previewViewController.view.layer.borderWidth = 1.0f;
    previewViewController.view.layer.shadowColor = [NHelper colorFromPlist:@"preview_shadow_color"].CGColor;
    previewViewController.view.layer.shadowRadius = 2.0f;
    previewViewController.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    previewViewController.view.layer.shadowOpacity = 0.7f;
    // make sure we rasterize nicely for retina
    previewViewController.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    previewViewController.view.layer.shouldRasterize = YES;
    
}



+(void)buttonNormal:(UIButton*)button{
    [button setTitleColor:[NHelper colorFromPlist:@"previewbuttontint"] forState:UIControlStateNormal];
    [button setTitleColor:[NHelper colorFromPlist:@"previewbuttontintH"] forState:UIControlStateSelected];
    [button setTitleColor:[NHelper colorFromPlist:@"previewbuttontintH"] forState:UIControlStateHighlighted];
    [button setBackgroundColor:[NHelper colorFromPlist:@"previewbuttonbg"]];
    
    button.layer.borderColor = [NHelper colorFromPlist:@"previewbuttonborder"].CGColor;
}
+(void)buttonHighlight:(UIButton*)button{
    [button setBackgroundColor:[NHelper colorFromPlist:@"previewbuttonbgH"] ];
    button.layer.borderColor = [NHelper colorFromPlist:@"previewbuttonborderH"].CGColor;
}

+(void)setButtonStyle:(UIButton*)button size:(float)size{
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [NHelper getFontDefault:size bold:NO];
    
    button.layer.cornerRadius = [[[NHelper appSettings] objectForKey:@"previewbuttonrounded"] floatValue];
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [NHelper colorFromPlist:@"previewbuttonborder"].CGColor;
    button.layer.borderWidth = 1.0f;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    [button setAlpha:0.7f];
    [button addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    
    [PreviewHelper buttonNormal:button];
}



+(BOOL)czyMaszSubskrypcje{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //check active subscription
    NSLog(@"AppId: %d", appDelegate->app_id );
    
    BOOL alreadyBoughtSubscription = NO;
    BOOL alreadyBoughtSubscriptionY = NO;
    BOOL alreadyBoughtSubscription6 = NO;
    BOOL alreadyBoughtSubscription3M = NO;
    BOOL alreadyBoughtSubscriptionM = NO;
    

    alreadyBoughtSubscriptionY = [IAPHelper wasBought:[appDelegate->app_subs objectAtIndex:0]];
    alreadyBoughtSubscription6 = [IAPHelper wasBought:@"com.setupo.rynekzoologiczny.6m"];
    alreadyBoughtSubscriptionM = [IAPHelper wasBought:@"com.setupo.rynekzoologiczny.1m"];

    NSLog(@"AppalreadyBoughtSubscription: %d/%d/%d/%d",alreadyBoughtSubscriptionY, alreadyBoughtSubscription6, alreadyBoughtSubscriptionM, alreadyBoughtSubscription3M );
    alreadyBoughtSubscription = alreadyBoughtSubscriptionY || alreadyBoughtSubscription6 || alreadyBoughtSubscriptionM || alreadyBoughtSubscription3M;
    
    
    
    
    NSLog(@"alreadyBoughtSubscription: %d", alreadyBoughtSubscription );
    return alreadyBoughtSubscription;
}




+(BOOL)czyMaszSubskrypcjeObejmujacaWydanie: (Ishue*)is{
    
    BOOL alreadyBoughtSubscription = NO;
    alreadyBoughtSubscription = [PreviewHelper czyMaszSubskrypcje];
    NSLog(@"alreadyBoughtSubscription: %d", alreadyBoughtSubscription );
    
    if ( alreadyBoughtSubscription ){
        NSLog(@"mamy subscription testnijmy czy aktualna");
        NSLog(@"jest: st:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"subStart"]);
        NSLog(@"jest: end:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"subEnd"]);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // this is imporant - we set our input date format to match our input string
        // if format doesn't match you'll get nil from your string, so be careful
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateFromString = [[NSDate alloc] init];
        // voila!
        dateFromString = [dateFormatter dateFromString:is->cdate];
        NSLog(@"wydanie z dnia: %@", dateFromString );
        
        if ([dateFromString compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"subStart"]] == NSOrderedDescending) {
            NSLog(@"wydanie po start");
            
            if ([dateFromString compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"subEnd"]] == NSOrderedAscending) {
                NSLog(@"wydanie przed end");
                return YES;
            }
            else{
                NSLog(@"wydanie po end");
                return NO;
            }
            
        }
        else{
            NSLog(@"wydanie przed start");
            return NO;
        }
        
        
    }
    else{
        return NO;
    }
}

+(void)setButtonKodShowHide:(bool)show previewViewController:(TuiCatalogGalleryController*)previewViewController{
    if ( [[[NHelper appSettings] objectForKey:@"useCodes"] boolValue] ){
        
    }
    else{
        show = NO;
    }
    
    if( [NHelper isIphone])
        previewViewController.buttonKodHeight.constant =  show ? 25.0f : 0.0f;
    else
        previewViewController.buttonKodHeight.constant =  show ? 40.0f : 0.0f;
    
    [previewViewController->buttonKod setEnabled:show];
    
}


+(void)setButtonPrenumerataShowHide:(bool)show previewViewController:(TuiCatalogGalleryController*)previewViewController{
    if ( [[[NHelper appSettings] objectForKey:@"useSub"] boolValue] ){
        
    }
    else{
        show = NO;
    }
    
    if( [NHelper isIphone])
        previewViewController.buttonPrenumerataHeight.constant =  show ? 25.0f : 0.0f;
    else
        previewViewController.buttonPrenumerataHeight.constant =  show ? 40.0f : 0.0f;
    
    [previewViewController->buttonPrenumerata setEnabled:show];
}

+(void)setButtons:(TuiCatalogGalleryController*)previewViewController{
    [previewViewController->buttonKod setTitle:@"WYKORZYSTAJ KOD" forState:UIControlStateNormal];
    [previewViewController->buttonKod setEnabled:YES];
    [PreviewHelper setButtonKodShowHide:YES previewViewController:previewViewController];
    
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if( appDelegate.currentIshue->price > 0 ){
        [previewViewController->buttonPrenumerata setTitle:@"KUP PRENUMERATĘ" forState:UIControlStateNormal];
        [PreviewHelper setButtonPrenumerataShowHide:YES previewViewController:previewViewController];
        
        NSString* stringtofind =
        [NSString stringWithFormat:@"com.setupo.issue%d", appDelegate.currentIshue->ishue_id ];
        BOOL alreadyBought = [IAPHelper wasBought:stringtofind];//        [
        if ( !alreadyBought ){
            //check active subscription
            alreadyBought = [PreviewHelper czyMaszSubskrypcjeObejmujacaWydanie:appDelegate.currentIshue];
        }
        else{ NSLog(@"ALREADY BOUGHT WITH one paid"); }
        
        if ( [[appDelegate.currentIshue.payments objectForKey:@"bought"] intValue] > 0 ){
            alreadyBought = YES;
        }
        
        previewViewController->buttonBuy.tag = 0;
        if ( alreadyBought ){
            [previewViewController->buttonBuy setTitle:@"OTWÓRZ" forState:UIControlStateNormal];
            previewViewController->buttonBuy.tag = 666;
            [PreviewHelper setButtonKodShowHide:NO previewViewController:previewViewController];
            [PreviewHelper setButtonPrenumerataShowHide:NO previewViewController:previewViewController];
            
        }
        else{
            [previewViewController->buttonBuy setTitle:@"KUP" forState:UIControlStateNormal];
            previewViewController->buttonBuy.tag = 0;
            [PreviewHelper setButtonKodShowHide:YES previewViewController:previewViewController];
        }
    }
    else{
        if( ![appDelegate.currentIshue checkThumbsCorrectDownloaded] ){
            [previewViewController->buttonBuy setTitle:@"POBIERZ" forState:UIControlStateNormal];
        }
        else{
            [previewViewController->buttonBuy setTitle:@"OTWÓRZ" forState:UIControlStateNormal];
        }
        [previewViewController->buttonPrenumerata setTitle:@"KUP PRENUMERATĘ" forState:UIControlStateNormal];
        [PreviewHelper setButtonPrenumerataShowHide:NO previewViewController:previewViewController];
        [PreviewHelper setButtonKodShowHide:NO previewViewController:previewViewController];
    }
    
    
    
    float fontSize = 12.0f;
    [previewViewController->buttonBuy setHidden:NO];
    if ([NHelper isIphone]) {
        fontSize = 9.0f;
    }
    
    [self setButtonStyle:previewViewController->buttonPrenumerata size:fontSize];
    [previewViewController->buttonShare setTitle: [@"PRENUMERATA" uppercaseString] forState:UIControlStateNormal];
    
    
    [self setButtonStyle:previewViewController->buttonBuy size:fontSize];
    [previewViewController->buttonShare setTitle: [@"UDOSTĘPNIJ" uppercaseString] forState:UIControlStateNormal];
    [self setButtonStyle:previewViewController->buttonShare size:fontSize];
    [previewViewController->buttonAR setTitle: [@"AUGMENTED REALITY" uppercaseString] forState:UIControlStateNormal];
    [self setButtonStyle:previewViewController->buttonAR size:fontSize];
    [previewViewController->buttonKod setTitle: [@"Wykorzystaj KOD" uppercaseString] forState:UIControlStateNormal];
    [self setButtonStyle:previewViewController->buttonKod size:fontSize];
    [previewViewController->buttonDelete setTitle: [@"SKASUJ PLIKI OFFLINE" uppercaseString] forState:UIControlStateNormal];
    [self setButtonStyle:previewViewController->buttonDelete size:fontSize];
        
    if ( [appDelegate isFav:appDelegate.currentIshue->ishue_id] ){
        [previewViewController->buttonAddToFav setTitle: [@"USUŃ Z ULUBIONYCH" uppercaseString] forState:UIControlStateNormal];
        previewViewController->buttonAddToFav.titleLabel.textColor = appDelegate.presetColorFiolet;
        
    }
    else{
        [previewViewController->buttonAddToFav setTitle: [@"DODAJ DO ULUBIONYCH" uppercaseString] forState:UIControlStateNormal];
        previewViewController->buttonAddToFav.titleLabel.textColor = appDelegate.presetColorFiolet;
    }
    
    [self setButtonStyle:previewViewController->buttonAddToFav size:fontSize];
    
    if( [NHelper isIphone ]){
        [previewViewController->issueName setFont:[NHelper getFontDefault:[[[NHelper appSettings] objectForKey:@"previewnamelabelsize"] floatValue] bold:NO]];
    }
    else{
        [previewViewController->issueName setFont:[NHelper getFontDefault:[[[NHelper appSettings] objectForKey:@"previewnamelabelsize"] floatValue] bold:NO]];
    }
        [previewViewController->issueName setTextColor:[NHelper colorFromPlist:@"previewnamelabel"]];
        [previewViewController->issueName setText:appDelegate.currentIshue.name];
        
        [previewViewController.pageLabel setTextColor:[NHelper colorFromPlist:@"previewpagelabel"]];
        
        
        if( appDelegate.offlineMode){
            if( [appDelegate.currentIshue.filesToDownload count] > 0 ){
                [previewViewController->buttonBuy setEnabled:NO];
                previewViewController->buttonBuy.enabled=NO;
                previewViewController->buttonBuy.userInteractionEnabled = NO;
                [previewViewController->buttonBuy setEnabled:NO];
                [previewViewController->buttonBuy setAlpha:0.35];
            }
            
            [previewViewController->buttonAR setEnabled:NO];
            [previewViewController->buttonAR setAlpha:0.35];
            
            [previewViewController->buttonDelete setEnabled:NO];
            [previewViewController->buttonDelete setAlpha:0.35];
            
            
            
            [previewViewController.pageLabel setText:@""];
        }
        else{
            [previewViewController->buttonShare setEnabled:YES];
            [previewViewController.view bringSubviewToFront:previewViewController->buttonShare];
        }
        
        
    
        [previewViewController->buttonBuy setAlpha:0.95];
    }




@end
