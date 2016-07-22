//
//  CatalogHelper.m
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 04.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import "CatalogHelper.h"
#import "NHelper.h"
#import "AppDelegate.h"
#import "IssuesManager.h"


@implementation CatalogHelper

+(CGRect)iPhonePdfCropSizePortrait:(float)page_prop{
    CGSize size = [NHelper getSizeOfCurrentDevicePortrait];
    return CGRectMake(0.0, 0.0f, size.width+7, ((size.width+7)*page_prop));
}

+(void)hardcoreFixLocalPionIphone:(DoubleCatalogViewController*)dcvc{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    float offset_y = (size.height - size.width*dcvc->page_prop) / 2;
    dcvc.myImage.frame = CGRectMake(0, offset_y, size.width, size.width*dcvc->page_prop);
    [dcvc.lmyImagePdf setFrame:[CatalogHelper iPhonePdfCropSizePortrait:dcvc->page_prop]];
    dcvc.scrollView.contentSize = dcvc.myImage.frame.size;
}

+(void)hardcoreFixLocalPoziomIphone:(DoubleCatalogViewController*)dcvc{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    [dcvc.myImage setFrame:CGRectMake(0, 0, size.width, size.width*dcvc->page_prop)];
    dcvc.myZoomViewHeight.constant = size.width*dcvc->page_prop;
    
    [NHelper showRectParams:dcvc.myImage.frame label:@"frame my"];
    [NHelper showRectParams:dcvc.myImage.bounds label:@"bound my"];
    dcvc.scrollView.contentSize = dcvc.myImage.frame.size;
    dcvc.scrollView.scrollEnabled = YES;
    [dcvc.lmyImagePdf setFrame:
        [CatalogHelper leftPdfCropSizeLandscape:dcvc.pageleft forcedOnePage:YES]];
}

+(CGRect)getImageSizeForMyImagePion_iPhone:(DoubleCatalogViewController*)dcvc{
    CGSize size = [NHelper getSizeOfCurrentDevicePortrait];
    return CGRectMake(0, 0, size.width, size.width*dcvc.pageleft.page_prop);
}



+(void)hardcoreFixLocalPion: (NSString*)x dcvc:(DoubleCatalogViewController*)dcvc{
    float page_prop = dcvc->page_prop;
    
    CGSize size = [NHelper getSizeOfCurrentDevicePortrait];
    
    dcvc.myZoomViewHeight.constant = size.height;
    
    
    if ( [NHelper isIphone]){
        [CatalogHelper hardcoreFixLocalPionIphone:dcvc];
    }
    else{
        if ( dcvc->page_prop > 1 ){
            dcvc.myImage.frame = CGRectMake([dcvc.pageleft getOrientedOffsetX],[dcvc.pageleft getOrientedOffsetY],  1024/page_prop, 1024);
        }
        else{ // PAGE IS LANDSCAPE
            dcvc.myImage.frame = CGRectMake([dcvc.pageleft getOrientedOffsetX],[dcvc.pageleft getOrientedOffsetY],  768, 768*page_prop);
        }
        
        
        if ( dcvc.pageleft.page_prop > 1.0){
            NSLog(@"page: %@", dcvc.pageleft);
            
            dcvc.lmyImagePdf.frame = CGRectMake(
                                                [[[NHelper appSettings] objectForKey:@"correct_pdf_pion_x"] floatValue],
                                                [[[NHelper appSettings] objectForKey:@"correct_pdf_pion_y"] floatValue],
                                                1024/page_prop+(-2*[[[NHelper appSettings] objectForKey:@"correct_pdf_pion_x"] floatValue]),
                                                ((1024+(-2*[[[NHelper appSettings] objectForKey:@"correct_pdf_pion_y"] floatValue]))) );
        }
        else{
            dcvc.lmyImagePdf.frame =
            CGRectMake(
                       [[[NHelper appSettings] objectForKey:@"correct_pdf_pion_x"] floatValue],
                       [[[NHelper appSettings] objectForKey:@"correct_pdf_pion_y"] floatValue],
                       768+(-2*[[[NHelper appSettings] objectForKey:@"correct_pdf_pion_x"] floatValue]),
                       ((768*dcvc.pageleft.page_prop+(-2*[[[NHelper appSettings] objectForKey:@"correct_pdf_pion_y"] floatValue]))) );
            
        }
    }
}


+(void)setImageForMyImagePoziomForcedOnePage: (DoubleCatalogViewController*)dcvc{
    if( [NHelper isIphone]){
        [CatalogHelper setImageForMyImageIphoneLandscape:dcvc];
    }
    else{
        NSLog(@"setImageForMyImagePoziomForcedOnePage");
        [dcvc setLeftPage:CGRectMake(0, 0, 1024, 1024.0*dcvc->page_prop)];
        [dcvc.myImage addSubview: dcvc.lmyImagePdf];
        [dcvc.myImage addSubview: dcvc.lmyImagePng];
        [dcvc.myImage bringSubviewToFront:dcvc.lmyImagePng];
    }
}


+(void)makeKorekcjaPoZmianie:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if( [NHelper isIphone]){
        [CatalogHelper makeKorekcjaPoZmianieIphone:deviceOrientation dcvc:dcvc];
    }
    else{
        if( appDelegate.currentIshue->forceOnePagePerView )
            [CatalogHelper makeKorekcjaPoZmianieIpad:deviceOrientation dcvc:dcvc];
        else
            [CatalogHelper makeKorekcjaPoZmianieIpad:deviceOrientation dcvc:dcvc];
        
        
    }
}

+(void)makeKorekcjaPoZmianieIphone:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentLeftPageNameFile = dcvc.imageFile;
    
    if( [NHelper isLandscapeInReal] ){
        NSLog(@"DCVC:orientationChanged:Landscape: %d", appDelegate->orientPion);
        [CatalogHelper makeKorekcjaPoZmianieIphonePion_Poziom:dcvc];
    }
    else if ( ![NHelper isLandscapeInReal] ){
        NSLog(@"DCVC:orientationChanged:Portrait");
        [CatalogHelper makeKorekcjaPoZmianieIpadPoziom_Pion:dcvc];
    }
    else{
        NSLog(@"DZIWNA POZCKA !!!!!!!!!!!");
    }
    
    [CatalogHelper colorBorders:dcvc];
}


+(void)makeKorekcjaPoZmianieIphonePion_Poziom:(DoubleCatalogViewController*)dcvc{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dcvc.scrollView.scrollEnabled = NO;
    
    if( dcvc.current_left_page > 0 ){
        dcvc.pageIndex = dcvc.current_left_page + 0;
        dcvc.current_left_page = dcvc.current_left_page + 0;
    }
    
    if( dcvc.firstPage ){
        NSLog(@"FIST PAGE - force 0,1 - reload image");
        dcvc.current_left_page = 0;
        NSDictionary* pageinfo = [(NSMutableArray*)appDelegate.currentIshue.pages objectAtIndex:0];
        dcvc.imageFile = [pageinfo objectForKey:@"id"]; //to i tak sie nei poakze
        dcvc.imageFileRight = [pageinfo objectForKey:@"id"];
        dcvc.pageIndex = 0;
    }
    
    appDelegate->orientPion = NO;
    [dcvc.scrollView setZoomScale:0.01];
    [dcvc.myZoomableView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //1. badaj proporcje orginalu
    
    double propW = (dcvc.view.frame.size.width/2) / dcvc->pageW;
    double propH = dcvc.view.frame.size.height / dcvc->pageH;
    
    dcvc->prop = (propW < propH) ? propW : propH;
    
    
    [dcvc.myImage removeFromSuperview];
    dcvc.myImage = [[UIImageView alloc] initWithFrame:CGRectMake([dcvc.pageright getOrientedOffsetX], [dcvc.pageright getOrientedOffsetY], dcvc->pageW*dcvc->prop, dcvc->pageH*dcvc->prop)];
    
    
    [dcvc setImageForMyImage];
    
    [dcvc.myZoomableView addSubview:dcvc.myImage];
    
    [dcvc placeButtons];
    [dcvc setMinMaxCurrentZoomScale];
    
}







+(void)makeKorekcjaPoZmianieIpadPoziom_Pion:(DoubleCatalogViewController*)dcvc{
    NSLog(@"makeKorekcjaPoZmianieIpadPion_Poziom");
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dcvc.scrollView.scrollEnabled = NO;
    appDelegate->orientPion = YES;
    
    if( dcvc.current_left_page > 0 ){
        NSLog(@"pageIndex: %d", dcvc.pageIndex );
        NSLog(@"leftPage: %d", dcvc.pageleft.pagenum );
        dcvc.pageIndex = dcvc.pageleft.pagenum-1;
    }
    else{
        dcvc.pageIndex = 0;
    }
    
    if ( dcvc.pageIndex > 999999){
        NSLog(@"PAGE INDEX ERRROR");
    }
    
    if( dcvc.firstPage ){
        NSLog(@"FIST PAGE - force 0,1 - reload image");
    }
    
    
    dcvc.scrollView.scrollEnabled = NO;
    
    [dcvc.myZoomableView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    double propW = dcvc.view.frame.size.width / dcvc->pageW;
    double propH = dcvc.view.frame.size.height / dcvc->pageH;
    
    dcvc->prop = (propW < propH) ? propW : propH;
    
    [dcvc.myImage removeFromSuperview];
    dcvc.myImage = [[UIImageView alloc] initWithFrame:CGRectMake([dcvc.pageright getOrientedOffsetX], [dcvc.pageright getOrientedOffsetY], dcvc->pageW*dcvc->prop, dcvc->pageH*dcvc->prop)];
    
    [dcvc setImageForMyImage];
    
    
    [dcvc.myZoomableView addSubview:dcvc.myImage];
    
    [dcvc placeButtons];
    [dcvc setMinMaxCurrentZoomScale];
    [dcvc hardcoreFixLocal: @"DCVC565"];//test
}


+(void)makeKorekcjaPoZmianieIpadPion_Poziom:(DoubleCatalogViewController*)dcvc{
    NSLog(@"makeKorekcjaPoZmianieIpadPion_Poziom");
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dcvc.scrollView.scrollEnabled = NO;
    
    if( dcvc.current_left_page > 0 ){
        if( [NHelper isIphone] ){
            dcvc.pageIndex = dcvc.current_left_page + 0;
            dcvc.current_left_page = dcvc.current_left_page + 0;
        }
        else{
            
            if( !dcvc.pageleft.forceonepage ){
                if (dcvc.pageIndex == 1) {
                    NSLog(@"left old index for secound page");
                }
                else{
                    dcvc.pageIndex = (int)floor(dcvc.current_left_page / 2);
                }
            }
            
            NSLog(@"pageIndex: %d", dcvc.pageIndex );
            [dcvc preaparePagesNotFirst:dcvc.pageIndex];
            
            NSLog(@"s");
            
        }
    }
    
    if( dcvc.firstPage ){
        NSLog(@"FIST PAGE - force 0,1 - reload image");
        dcvc.current_left_page = 0;
        NSDictionary* pageinfo = [(NSMutableArray*)appDelegate.currentIshue.pages objectAtIndex:0];
        dcvc.imageFile = [pageinfo objectForKey:@"id"]; //to i tak sie nei poakze
        dcvc.imageFileRight = [pageinfo objectForKey:@"id"];
        dcvc.pageIndex = 0;
    }
    
    appDelegate->orientPion = NO;
    [dcvc.scrollView setZoomScale:0.01];
    [dcvc.myZoomableView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //1. badaj proporcje orginalu
    
    double propW = (dcvc.view.frame.size.width/2) / dcvc->pageW;
    double propH = dcvc.view.frame.size.height / dcvc->pageH;
    
    dcvc->prop = (propW < propH) ? propW : propH;
    
    
    [dcvc.myImage removeFromSuperview];
    dcvc.myImage = [[UIImageView alloc] initWithFrame:CGRectMake([dcvc.pageright getOrientedOffsetX], [dcvc.pageright getOrientedOffsetY], dcvc->pageW*dcvc->prop, dcvc->pageH*dcvc->prop)];
    
    [dcvc setImageForMyImage];
   
    
    [dcvc.myZoomableView addSubview:dcvc.myImage];
    
    [dcvc placeButtons];
    [dcvc setMinMaxCurrentZoomScale];
    
}


+(void)makeKorekcjaPoZmianieIpad:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentLeftPageNameFile = dcvc.imageFile;

    if( [NHelper isLandscapeInReal] ){
        NSLog(@"DCVC:orientationChanged:Landscape: %d", appDelegate->orientPion);
        [CatalogHelper makeKorekcjaPoZmianieIpadPion_Poziom:dcvc];
        
    }
    //    else if (UIDeviceOrientationIsPortrait(deviceOrientation) ){
    else if ( ![NHelper isLandscapeInReal] ){
        NSLog(@"DCVC:orientationChanged:Portrait");
        [CatalogHelper makeKorekcjaPoZmianieIpadPoziom_Pion:dcvc];
    }
    else{
        
        NSLog(@"DZIWNA POZCKA !!!!!!!!!!!");
    }
    
    
    [CatalogHelper colorBorders:dcvc];
}





+(void)makeKorekcjaPoZmianieIpadPoziom:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc{
    NSLog(@"makeKorekcjaPoZmianieIpadPoziom");
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ( appDelegate->orientPion ){
        dcvc.scrollView.scrollEnabled = NO;
        //lewa musi byc parzysta
        
        if( dcvc.current_left_page > 0 ){
            dcvc.pageIndex = dcvc.current_left_page + 1;//TODO MARCIN;
            dcvc.current_left_page = dcvc.current_left_page + 1;
            
            if ( dcvc.current_left_page % 2 == 0 || dcvc.firstPage ){
                NSLog(@"lewa parzysta nic nie zmieniamy tylko kontrolujemy indexpage ;]");
                dcvc.pageIndex = (int)floor(dcvc.current_left_page / 2);
                NSLog(@" self.pageIndex : = %d ", (int)floor(dcvc.current_left_page / 2));
            }
            else{
                NSLog(@"lewa nieparzysta zmieniamy!!!!");
                dcvc.current_left_page = dcvc.current_left_page-1;
                NSDictionary* pageinfo = [(NSMutableArray*)appDelegate.currentIshue.pages objectAtIndex:dcvc.current_left_page-1];
                dcvc.imageFile = [pageinfo objectForKey:@"id"];
                pageinfo = [(NSMutableArray*)appDelegate.currentIshue.pages objectAtIndex:dcvc.current_left_page];
                dcvc.imageFileRight = [pageinfo objectForKey:@"id"];
                dcvc.pageIndex = (int)floor(dcvc.current_left_page / 2);
            }
            
            dcvc.pageleft = [CatalogHelper getPageInfo:dcvc pageid:[dcvc.imageFile intValue]];
            dcvc.pageright = [CatalogHelper getPageInfo:dcvc pageid:[dcvc.imageFile intValue]+1];
        }
        
        if( dcvc.firstPage ){
            NSLog(@"FIST PAGE - force 0,1 - reload image");
            dcvc.current_left_page = 0;
            NSDictionary* pageinfo = [(NSMutableArray*)appDelegate.currentIshue.pages objectAtIndex:0];
            dcvc.imageFile = [pageinfo objectForKey:@"id"]; //to i tak sie nei poakze
            dcvc.imageFileRight = [pageinfo objectForKey:@"id"];
            dcvc.pageIndex = 0;
        }
        
        appDelegate->orientPion = NO;
        [dcvc.scrollView setZoomScale:0.01];
        [dcvc.myZoomableView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        
        //1. badaj proporcje orginalu
        
        double propW = (dcvc.view.frame.size.width/2) / dcvc->pageW;
        double propH = dcvc.view.frame.size.height / dcvc->pageH;
        
        dcvc->prop = (propW < propH) ? propW : propH;
        
        
        [dcvc.myImage removeFromSuperview];
        dcvc.myImage = [[UIImageView alloc] initWithFrame:CGRectMake([dcvc.pageright getOrientedOffsetX], [dcvc.pageright getOrientedOffsetY], dcvc->pageW*dcvc->prop, dcvc->pageH*dcvc->prop)];
        
        
        [dcvc setImageForMyImage];
        
        
        [dcvc.myZoomableView addSubview:dcvc.myImage];
        
        [dcvc placeButtons];
        [dcvc setMinMaxCurrentZoomScale];
    }//changed
    
}



+(void)makeKorekcjaPoZmianieIpadForceOnePage:(UIDeviceOrientation) deviceOrientation dcvc:(DoubleCatalogViewController*)dcvc{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.currentLeftPageNameFile = dcvc.imageFile;
    
    if( [NHelper isLandscapeInReal] ){
        NSLog(@"DCVC:orientationChanged:Landscape: %d", appDelegate->orientPion);
        [CatalogHelper makeKorekcjaPoZmianieIpadForceOnePagePoziom:deviceOrientation dcvc:dcvc];
    }
    //    else if (UIDeviceOrientationIsPortrait(deviceOrientation) ){
    else if ( ![NHelper isLandscapeInReal] ){
        NSLog(@"DCVC:orientationChanged:Portrait");
        
        if ( !appDelegate->orientPion ){
            
        }
        
    }
    else{
        
        NSLog(@"DZIWNA POZCKA !!!!!!!!!!!");
    }
    
    
    [CatalogHelper colorBorders:dcvc];
}





+(void)changepngtopdfIphone:(DoubleCatalogViewController*)dcvc{
    if( dcvc->lrdy ){
        dcvc.lmyImagePdf.hidden = NO;
        dcvc.lmyImagePng.hidden = YES;
        dcvc.lmyImagePdf.alpha = 1.0f;
    }
}

+(void)changepdftopngIphone:(DoubleCatalogViewController*)dcvc{
    dcvc.lmyImagePdf.hidden = YES;
    dcvc.lmyImagePng.hidden = NO;
    dcvc.lmyImagePdf.alpha = 0.0f;
}



+(void)changepngtopdf:(DoubleCatalogViewController*)dcvc{
//    if( dcvc.lmyImagePdf.hidden == NO ){
    dcvc.lmyImagePdf.hidden = NO;
        dcvc.lmyImagePng.hidden = YES;
        dcvc.lmyImagePdf.alpha = 1.0f;
//    }
    
    dcvc.rmyImagePdf.hidden = NO;
    dcvc.rmyImagePng.hidden = YES;
    dcvc.rmyImagePdf.alpha = 1.0f;
}

+(void)changepdftopng:(DoubleCatalogViewController*)dcvc{
    dcvc.lmyImagePng.hidden = NO;
    dcvc.lmyImagePdf.hidden = YES;
    dcvc.lmyImagePdf.alpha = 0.0f;
    
    dcvc.rmyImagePng.hidden = NO;
    dcvc.rmyImagePdf.hidden = YES;
    dcvc.rmyImagePdf.alpha = 0.0f;
}






+(void)placeButtonOnPage: (ContentButton*)button left:(bool)left dcvc:(DoubleCatalogViewController*)dcvc  {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if ( [NHelper isLandscapeInReal] ){
        
        float widthOfPage = 1024.0/2.0;
        if ( [NHelper isIphone]){
            widthOfPage = 568/2;
        }
        else{
            if( appDelegate.currentIshue->forceOnePagePerView ){
                widthOfPage = 1024.0;
            }
            else{
                widthOfPage = 1024/2;
            }
        }
        
        float realW = widthOfPage;
        float realH = widthOfPage*dcvc->page_prop;
        float x = (button.position_left/100)*realW;
        if (!left){
            x = x + widthOfPage;
        }
        
        float y = (button.position_top/100)*realH;
        
        float width = (button.position_width/100)*realW;
        float height = (button.position_height/100)*realH;
        //poziom ipad mniejszy guzik
        
        
        float extraoff_x = 0;
        float extraoff_y = -1;
        
        if ( dcvc.firstPage && !appDelegate.currentIshue->forceOnePagePerView ){
            extraoff_x += widthOfPage/2;
        }
        
        
        CGRect frameForView = CGRectMake( x+[dcvc.pageleft getOrientedOffsetX]+extraoff_x, y+[dcvc.pageleft getOrientedOffsetY]+extraoff_y, width, height );
        
        
        
        [CatalogHelper placeYYYButton:button frame:frameForView dcvc:dcvc];
    }
    else{
        
        float widthOfPage = 1024/dcvc->page_prop;
        if ( [NHelper isIphone]){
            widthOfPage = 320;
        }
        else{
            if ( dcvc.pageleft.page_prop > 1.0){
                widthOfPage = 1024/dcvc->page_prop;
            }
            else{
                widthOfPage = 768;
            }
        }
        
        float realW = widthOfPage;
        float realH = widthOfPage*dcvc->page_prop;
        
        float x = (button.position_left/100)*realW;
        float y = (button.position_top/100)*realH;
        
        
        float width = (button.position_width/100)*realW;
        float height = (button.position_height/100)*realH;
        NSLog(@"realW/H: %f/%f", realW, realH);
        CGRect frameForView = CGRectMake( x+[dcvc.pageleft getOrientedOffsetX], y+[dcvc.pageleft getOrientedOffsetY], width, height );
        
        [NHelper showRectParams:frameForView label:@"frame for button"];
        [CatalogHelper placeYYYButton:button frame:frameForView dcvc:dcvc];
    }
}



+(void)placeYYYButton: (ContentButton*)button frame:(CGRect)frameForView dcvc:(DoubleCatalogViewController*)dcvc{
    if ( button.action == [NSNull null] || button.action == nil  ){
        return;
    }
    UIView* b = [[UIView alloc] initWithFrame:frameForView ];
    b.layer.borderColor = [UIColor greenColor].CGColor;
    b.tag = button.button_id;
    b.layer.borderWidth = 0.0f;
    if ( button.action != [NSNull null] && button.action != nil  ){
        if ( button.type_id == 3 ){ //link only
            if ( [button.action intValue] > 0 ){
                b.layer.borderWidth = 0.0f;
            }
            else{
                b.layer.borderWidth = 0.0f;
                
            }
            
        }
    }
    else{
        return;
    }
    
    b.layer.cornerRadius = 0;
    b.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    float ico_left = (button.ico_position_left/100) * frameForView.size.width;
    float ico_top = (button.ico_position_top/100) * frameForView.size.height;
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:button.btnico ]];
    UIView *circleView;
    
    float size = dcvc.lmyImagePdf.frame.size.width * 0.06;
    
    image.frame = CGRectMake(0, 0, size, size);
    circleView = [[UIView alloc] initWithFrame:CGRectMake(ico_left,ico_top,size,size)];
    circleView.alpha = [[[NHelper appSettings] objectForKey:@"icon_alfa"] floatValue] / 100.0f;
    circleView.layer.cornerRadius = size/2;
    circleView.backgroundColor = [NHelper colorFromPlist:@"icon_bgcolor"];
    
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* color = @"#FFFFFF";
    switch (button.type_id) {
        case 1:
            color = [NSString stringWithFormat:@"#%@", appDelegate.currentIshue->audio_rgb];
            break;
        case 3:
            color = [NSString stringWithFormat:@"#%@", appDelegate.currentIshue->link_rgb];
            break;
        case 4:
            color = [NSString stringWithFormat:@"#%@", appDelegate.currentIshue->video_rgb];
            break;
        case 2:
            color = [NSString stringWithFormat:@"#%@", appDelegate.currentIshue->gallery_rgb];
            break;
            
        default:
            break;
    }
    
    [image setImage:
     [NHelper imagedColorizedImage:[UIImage imageNamed:button.btnico]
                         withColor:[NHelper colorFromHexString:color]
      ] ];
    
    
    
    if( button.type_id == 3  && [button.action intValue] > 0 ){
    }
    else if(button.icon_hided){
        
    }
    else {
        //        [b addSubview:image];
        [b addSubview:circleView];
        [circleView addSubview:image];
    }
    
    
    if ( [NHelper isLandscapeInReal] ){
        [dcvc.myZoomableView addSubview:b];
        [dcvc.myZoomableView bringSubviewToFront:b];
    }
    else{
        [dcvc.myZoomableView addSubview:b];
        [dcvc.myZoomableView bringSubviewToFront:b];
    }
    
    b.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:dcvc action:@selector(handleBTap:)];
    tap.delegate = dcvc;
    [b addGestureRecognizer:tap];
    
    
    [dcvc->buttonsForPageUIBUTTONS addObject:b];
    if( button.type_id == 3 ){
        [dcvc->buttonsForPageUIBUTTONSToBGAnimate addObject:b];
        b.layer.borderColor = [UIColor redColor].CGColor;
        b.layer.borderWidth = 0.0f;
    }
    else if(button.icon_hided){
        [dcvc->buttonsForPageUIBUTTONSToBGAnimate addObject:b];
        b.layer.borderColor = [UIColor redColor].CGColor;
        b.layer.borderWidth = 0.0f;
    }
    
}

+(Page*)getCurrentPageInfo: (DoubleCatalogViewController*)dcvc{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Ishue* ishue = appDelegate.currentIshue;
    int pageid = [dcvc.imageFile intValue];
    Page* page = [[Page alloc] initWithPageId:pageid issue:ishue];
    return page;
}

+(Page*)getPageInfo: (DoubleCatalogViewController*)dcvc pageid:(int)pageid{
    NSLog(@"getPageInfo: %d", pageid );
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Ishue* ishue = appDelegate.currentIshue;
    Page* page = [[Page alloc] initWithPageId:pageid issue:ishue];
    return page;
}

+(Page*)getFirstPageInfo:(Ishue*)ishue {
    NSLog(@"getFirstPageInfo: %d", ishue->ishue_id );
    Page* page = [[Page alloc] initWithPageNum:1 issue:ishue];
    return page;
}



+ (DoubleCatalogViewController *)viewControllerAtIndexIphonePoziomRoot:(NSUInteger)index dupa:(DoubleCatalogViewController *)dupa{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dupa.current_left_page = ((int)(index))+0;
    NSDictionary* pageinfo = [(NSMutableArray*)appDelegate.currentIshue.pages objectAtIndex:index];
    dupa.imageFile = [pageinfo objectForKey:@"id"];
    if (index+1 >=  [appDelegate.currentIshue.pages count]) {
        dupa.imageFileRight = @"";
    }
    else{
        pageinfo = [(NSMutableArray*)appDelegate.currentIshue.pages objectAtIndex:index+0]; //MARCIN
        dupa.imageFileRight = [pageinfo objectForKey:@"id"];
    }
    
    
    return dupa;
}

+(void)setImageForMyImageIphoneLandscape: (DoubleCatalogViewController*)dcvc {
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    [dcvc setLeftPage:CGRectMake(0, 0, size.width, (size.width*dcvc->page_prop))];
    [dcvc.myImage addSubview: dcvc.lmyImagePng];
    [dcvc.myImage addSubview: dcvc.lmyImagePdf];
    [dcvc.myImage bringSubviewToFront:dcvc.lmyImagePng];
}


+(CGRect)rightPdfCropSizeLandscape: (Page*)rightpage{
    CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
    
    if( [NHelper isIphone]){
        return CGRectMake(0, 0, size.width+rightpage.pageupsize, ((size.width+rightpage.pageupsize)*rightpage.page_prop) );
    }
    else{
        return CGRectMake(1024/2-0, 0, 512+rightpage.pageupsize, (512*rightpage.page_prop) );
    }
}



+(CGRect)leftPdfCropSizeLandscape: (Page*)leftpage  forcedOnePage:(BOOL)forcedOnePage{
    if( [NHelper isIphone]){
        CGSize size = [NHelper getSizeOfCurrentDeviceOrient];
        
        return CGRectMake(0, 0, size.width+leftpage.pageupsize, (size.width*leftpage.page_prop) - 3 );
    }
    else{
        if( forcedOnePage ){
            return CGRectMake(0, 0, 1024+leftpage.pageupsize, (1024*leftpage.page_prop) );
        }
        else{
            
            return CGRectMake(0, 0, 512+leftpage.pageupsize, (512*leftpage.page_prop) );
        }
    }
}


+(void)ustawFrameView:(UIView*)view rect:(CGRect)rect msg:(NSString*)msg{
    view.frame = rect;
    if( YES ){
        [AppDelegate showRectParams:rect label:[NSString stringWithFormat:@"ustawFrameView: %@", msg] ];
    }
}




+(void)animateButtons: (DoubleCatalogViewController*)dcvc{
    for (UIView* view in dcvc->buttonsForPageUIBUTTONSToBGAnimate) {
        view.layer.cornerRadius = 2.0f;
        view.backgroundColor =  [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:0.0f];
        [UIView animateWithDuration:0.8 delay:0.0 options: UIViewAnimationOptionAllowUserInteraction animations:^{
            view.backgroundColor =  [UIColor colorWithRed:0.0/255.0 green:94.0/255.0 blue:104.0/255.0 alpha:0.4f];
            
        }
                         completion:^ (BOOL finished)
         {
             if (finished) {
                 [UIView animateWithDuration:0.7 delay:0.0 options:
                  UIViewAnimationOptionAllowUserInteraction animations:^{
                      view.backgroundColor =  [UIColor colorWithRed:0.0/255.0 green:94.0/255.0 blue:104.0/255.0 alpha:0.0f];
                  }
                                  completion:nil];
             }
         }
         ];
    }
}


+(void)colorBorders: (DoubleCatalogViewController*)dcvc{
    dcvc.view.layer.borderColor = [UIColor orangeColor].CGColor;
    dcvc.myImage.layer.borderColor = [UIColor redColor].CGColor;
    dcvc.myZoomableView.layer.borderColor = [UIColor blueColor].CGColor;
    dcvc.scrollView.layer.borderColor = [UIColor yellowColor].CGColor;
    dcvc.view.layer.borderWidth = 0.0f;
    dcvc.myZoomableView.layer.borderWidth = 0;
    dcvc.scrollView.layer.borderWidth = 0;
    
    dcvc.myImage.layer.borderWidth = 0.0f;
    
    dcvc.lmyImagePng.layer.borderColor = [UIColor magentaColor].CGColor;
    dcvc.lmyImagePng.layer.borderWidth = 0.0f;
    dcvc.rmyImagePng.layer.borderColor = [UIColor magentaColor].CGColor;
    dcvc.rmyImagePng.layer.borderWidth = 0.0f;
    dcvc.lmyImagePdf.layer.borderColor = [UIColor greenColor].CGColor;
    dcvc.lmyImagePdf.layer.borderWidth = 0.0f;
    dcvc.rmyImagePdf.layer.borderColor = [UIColor greenColor].CGColor;
    dcvc.rmyImagePdf.layer.borderWidth = 0.0f;
    
}
+(void)handleBTapHelperIphone:(DoubleCatalogViewController*)dcvc  clickedView:(UIView*)clickedView{
    for (ContentButton* button in dcvc.pageleft.buttons) {
        if ( button.button_id == clickedView.tag ){
            NSLog(@"button type: %d", button.type_id );
            
            [[IssuesManager sharedInstance] logIssueActionClicked:button.button_id];
            
            
            //if audio
            if ( button.type_id == 1){
                NSLog(@"ACTION AUDIO");
                bool isPlaing = [dcvc.audioPlayer isPlaying];
                if ( isPlaing )
                    [dcvc stopAudio:nil];
                else
                    [dcvc playAudio:button];
            }
            else if ( button.type_id == 2 ){
                NSLog(@"ACTION GALLERY");
                [dcvc openGallery:[button.action intValue]];
            }
            else if ( button.type_id == 3 ){
                NSLog(@"ACTION WWW: %d", [button.action intValue]);
                if ( [button.action intValue] > 0 ){
                    
                    [dcvc gotopage:[button.action intValue]];
                }
                else{
                    
                    [dcvc openBrowser: button.action];
                }
            }
            else if ( button.type_id == 4 ){
                NSLog(@"ACTION MOVIE: %@", button.action);
                [dcvc playMovie: button.action];
            }
            else if ( button.type_id == 5 ){
                NSLog(@"ACTION PDF WWW: %@", button.action);
                [dcvc openBrowser: button.action];
            }
            else{
                
            }
        }
    }
    
}

+(void)handleBTapHelper:(DoubleCatalogViewController*)dcvc  clickedView:(UIView*)clickedView{
    
    if( [NHelper isLandscapeInReal]){
        for (ContentButton* button in dcvc.pageright.buttons) {
            if ( button.button_id == clickedView.tag ){
                NSLog(@"button type: %d", button.type_id );
                [[IssuesManager sharedInstance] logIssueActionClicked:button.button_id];
            
                
                //if audio
                if ( button.type_id == 1){
                    NSLog(@"ACTION AUDIO");
                    bool isPlaing = [dcvc.audioPlayer isPlaying];
                    if ( isPlaing )
                        [dcvc stopAudio:nil];
                    else
                        [dcvc playAudio:button];
                }
                else if ( button.type_id == 2 ){
                    NSLog(@"ACTION GALLERY");
                    [dcvc openGallery:[button.action intValue]];
                }
                else if ( button.type_id == 3 ){
                    NSLog(@"ACTION WWW: %d", [button.action intValue]);
                    if ( [button.action intValue] > 0 ){
                        [dcvc gotopage:[button.action intValue]];
                    }
                    else{
                        
                        [dcvc openBrowser: button.action];
                    }
                }
                else if ( button.type_id == 4 ){
                    NSLog(@"ACTION MOVIE: %@", button.action);
                    [dcvc playMovie: button.action];
                }
                else if ( button.type_id == 5 ){
                    NSLog(@"ACTION PDF WWW: %@", button.action);
                    [dcvc openBrowser: button.action];
                }
                else{
                    
                }
            }
        }
    }
    
    
    for (ContentButton* button in dcvc.pageleft.buttons) {
        if ( button.button_id == clickedView.tag ){
            [[IssuesManager sharedInstance] logIssueActionClicked:button.button_id];
            
            //if audio
            if ( button.type_id == 1){
                NSLog(@"ACTION AUDIO");
                bool isPlaing = [dcvc.audioPlayer isPlaying];
                if ( isPlaing )
                    [dcvc stopAudio:nil];
                else
                    [dcvc playAudio:button];
            }
            else if ( button.type_id == 2 ){
                NSLog(@"ACTION GALLERY RIGHT");
                [dcvc openGallery:[button.action intValue]];
            }
            else if ( button.type_id == 3 ){
                NSLog(@"ACTION WWW:: %d", [button.action intValue]);
                if ( [button.action intValue] > 0 ){
                    
                    [dcvc gotopage:[button.action intValue]];
                }
                else{
                    [dcvc openBrowser: button.action];
                }
            }
            else if ( button.type_id == 4 ){
                NSLog(@"ACTION MOVIE");
                [dcvc playMovie: button.action];
            }
            else{
                
            }
        }
    }
}

+(NSString*)video_filename:(NSString*)fulllink{
    NSArray *chunks = [fulllink componentsSeparatedByString: @"/"];
    NSString* filewithext = [chunks lastObject];
    NSArray *chunks2 = [filewithext componentsSeparatedByString: @"."];
    return [chunks2 firstObject];
}



@end
