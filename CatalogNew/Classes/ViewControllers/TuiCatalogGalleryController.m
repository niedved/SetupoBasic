
#import "TuiCatalogGalleryController.h"
//#import "FruitIAPHelper.h"
#import "STabBarControler.h"
#import "DZWebBrowser.h"
#import "NHelper.h"
#import "PreviewHelper.h"

#define ZOOM_STEP 2.0


@interface TuiCatalogGalleryController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation TuiCatalogGalleryController

@synthesize imageScrollView, imageView;
@synthesize fetchedResultsController, managedObjectContext;


-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"PREVIEW VIEW WILL APPEAR");
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"PREVIEW VIEW DID APPEAR");
    appDelegate.loadingInProgress = NO;
    
    
}
- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"PREVIEW VIEW DID LOAD");
    active_catalog_id = 1;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    imageScrollView.bouncesZoom = YES;
    imageScrollView.delegate = self;
    imageScrollView.clipsToBounds = YES;
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xx_thumb"]];
    imageView.userInteractionEnabled = YES;
    [imageView setFrame:CGRectMake( 0.0f, 0.0f, imageScrollView.frame.size.width, imageScrollView.frame.size.height)];
    [imageScrollView addSubview:imageView];
    
    imageScrollView.layer.cornerRadius = 1;
    imageScrollView.layer.masksToBounds = YES;
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [imageScrollView frame].size.height  / [imageView frame].size.height;
    imageScrollView.minimumZoomScale = minimumScale;
    imageScrollView.zoomScale = minimumScale;
    
    [PreviewHelper setButtons:self];
    
    [PreviewHelper setTapAndSwipeDetails:self];
    [PreviewHelper setViewDetails:self];
    
    
//    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowColor = [NHelper colorFromPlist:@"preview_shadow_color"].CGColor;
    
    imageView.layer.shadowRadius = 2.0f;
    imageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imageView.layer.shadowOpacity = 0.3f;
                                         
    [self.view addSubview:imageScrollView];
    
    viewForInd.layer.borderColor = [NHelper colorFromPlist:@"previewloaderbordercolor"].CGColor;
    viewForInd.layer.borderWidth = 0.0f;
    viewForInd.layer.cornerRadius = 5.0f;
    viewForInd.backgroundColor = [NHelper colorFromPlist:@"previewloaderbgcolor"];
    viewForInd.alpha = [[[NHelper appSettings] objectForKey:@"previewloaderbgalpha"] floatValue] / 100.0f;
    viewForInd.center = self.view.center;
    
    
    indView.color =[NHelper colorFromPlist:@"previewloadercolor"];
    [self.view bringSubviewToFront:viewForInd];
    [viewForInd setHidden:YES];
    
    [appDelegate.currentIshue loadAllIssueFiles];
    
    
    
    float filessize = [appDelegate.currentIshue getSizeOffAllDownlaodedFiles];
    if ( filessize > 0.0 )
        [buttonDelete setHidden:NO];
    else
        [buttonDelete setHidden:YES];
    
    
}

-(IBAction)actionKupPrenumerate:(id)sender{
    if([NHelper isIphone]){
        [appDelegate.viewController performSegueWithIdentifier:@"ShowSubscriptionSegue" sender:nil];
    }
    else{
        [appDelegate.viewController performSegueWithIdentifier:@"ShowSubscriptionSegue" sender:nil];
    }
}

-(void)downloadFileExtra
{
    NSLog(@"downloadFileExtra: %@", filesToDownload );
    if ( [filesToDownload count] ){
        NSString* filename = [filesToDownload objectAtIndex:0];
        NSString* url = [NSString stringWithFormat:@"%@/Resources/pages/%d/PREVIEWS/%@", STAGING_URL_NOINDEX,current_catalog->catalog_id, filename];
        
        
        connection_filepath = [current_catalog przygotujPathDoPlikuZdjeciaCatalogu:filename];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:connection_filepath forKey:@"connection_filepath"];
        [prefs setObject:[NSString stringWithFormat:@"%d",666] forKey:@"downloading_page"];
        
        if ( ![[NSFileManager defaultManager] fileExistsAtPath: connection_filepath ] ){
            connection_num = 666;
            NSURL * url_to_download = [NSURL URLWithString:url];
            responseData = [[NSMutableData alloc] init];
            NSURLRequest* updateRequest = [NSURLRequest requestWithURL: url_to_download];
            NSLog(@"downloadFileExtra::url_to_download: %@", url_to_download);
            connection = [[NSURLConnection alloc] initWithRequest:updateRequest delegate:self];
            [viewForInd setHidden:NO];
            [connection start];
        }
        else {
            NSLog(@"fileexist");
            [viewForInd setHidden:YES];
            if ( [filesToDownload count] ){
                [filesToDownload removeObjectAtIndex:0];
                [self downloadFileExtra];
            }
            else{
                connection_inprogress = NO;
            }
        }
    }
    else {
        connection_inprogress = NO;
    }
}

-(void)downloadFile
{
    currentFileId = 0;
    NSLog(@"connection_inprogress: %d", connection_inprogress );
    if ( !connection_inprogress ){
        if ( [filesToDownload count] ){
            connection_inprogress = YES;
            NSString* filename = [filesToDownload objectAtIndex:currentFileId];
            
            NSString* url = [NSString stringWithFormat:@"%@/Resources/pages/%d/PREVIEWS/%@", STAGING_URL_NOINDEX,current_catalog->catalog_id, filename];
            
            
            connection_filepath = [current_catalog przygotujPathDoPlikuZdjeciaCatalogu:filename];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:connection_filepath forKey:@"connection_filepath"];
            [prefs setObject:[NSString stringWithFormat:@"%d",currentFileId] forKey:@"downloading_page"];
            
            if ( ![[NSFileManager defaultManager] fileExistsAtPath: connection_filepath ] ){
                connection_num = 666;
                [viewForInd setHidden:NO];
                responseData = [[NSMutableData alloc] init];
                
                NSURL * url_to_download = [NSURL URLWithString:url];
                
                
                NSURLRequest* updateRequest = [NSURLRequest requestWithURL: url_to_download];
                NSLog(@"downloadFile::url_to_download:%@",url_to_download);
                connection = [[NSURLConnection alloc] initWithRequest:updateRequest delegate:self];
                [connection start];
            }
            else {
                NSLog(@"fileexist");
                [viewForInd setHidden:YES];
                if ( [filesToDownload count] ){
                    [filesToDownload removeObjectAtIndex:0];
                    [self downloadFileExtra];
                }
                else{
                    connection_inprogress = NO;
                }
            }
        }
    }
}




-(void)pobierzBrakujacyPlik:(int)strona_num
{
    
    Ishue* i = current_catalog.ishue;
    NSMutableArray* pages = (NSMutableArray*)i.pages;
    NSDictionary* page = [pages objectAtIndex:strona_num-1];
    NSLog(@"Page: %d",  [[page objectForKey:@"id"] intValue] );
    NSString* filename = [NSString stringWithFormat:@"thumb_%d_%d.jpg",  current_catalog->catalog_id ,strona_num ];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath: filePath ] ){
        NSString* current_url = [NSString stringWithFormat:@"%@/Resources/pages/%d/PREVIEWS/%@", STAGING_URL_NOINDEX, current_catalog->catalog_id, filename];
        
        
        BOOL already_in_array = NO;
        for ( NSString* test in filesToDownload){
            if ( [test isEqualToString:filename] ){
                already_in_array = YES;
            }
        }
        if ( !already_in_array ){
            NSLog(@"nie istnieje i nie ma w tablicy do pobrania: %@ => filename: %@", current_url, filename);
            [filesToDownload addObject:filename];
           }
    }
    else{
        NSLog(@" istnieje");
    }
}


-(void)sprawdzCzyPobranoPlusMinus :(int)delta{
    [self.pageLabel setText:[NSString stringWithFormat:@"%d", current_catalog->current_page+1]];
                             //, current_catalog->page_count ]];
    
    int strona_start = ( current_catalog->current_page - delta );
    strona_start = (strona_start<1) ? 1 : strona_start;
    int strona_end = ( current_catalog->current_page + delta );
    int liczba_stron = current_catalog->page_count;
    strona_end = (strona_end>liczba_stron) ? liczba_stron : strona_end;
    NSLog(@"strony do testu: %d - %d", strona_start, strona_end );
    for ( int i=strona_start; i<=strona_end; i++){
        [self pobierzBrakujacyPlik :i];
    }
    [self downloadFile];
}






- (IBAction)startARTapped:(id)sender {
    appDelegate.loadingInProgress = YES;
    [buttonBuy setEnabled:NO];
    buttonBuy.enabled=NO;
    buttonBuy.userInteractionEnabled = NO;
    [buttonBuy setEnabled:NO];
    [buttonBuy setAlpha:0.35];
    [buttonShare setEnabled:NO];
    [buttonShare setAlpha:0.35];
    [buttonAddToFav setEnabled:NO];
    [buttonAddToFav setAlpha:0.35];
    [buttonDelete setEnabled:NO];
    [buttonDelete setAlpha:0.35];
    
    [buttonBuy setTitle:@"POBIERANIE" forState:UIControlStateNormal];
    [self.pageLabel setHidden:YES];
    
    [self.aplaView setFrame:self.imageScrollView.frame];
    
    [self.view bringSubviewToFront:self.aplaView];
    [self.aplaView setAlpha:0.75];
    [self.aplaView setHidden:NO];
    [self.view bringSubviewToFront:self.loadViewExtra];
    
    appDelegate->arlaunhcing = YES;
    //    [self.imageScrollView setAlpha:0.10];
    
    LoadViewController *modalViewController =
    [[LoadViewController alloc] initWithNibName:@"LoadingView" bundle:nil];
    modalViewController->ishue_id = appDelegate.currentIshue->ishue_id;
//    CGRect fr = modalViewController.view.frame;
//    fr.size.width = imageView.frame.size.width;
//    
//    [modalViewController.view setFrame:fr];
    appDelegate.loadViewController = modalViewController;
    
    //    modalViewController.view.frame = self.loadViewExtra.frame;
    [self.loadViewExtra addSubview:modalViewController.view];
    CGRect f = modalViewController.view.frame;
    f.size.width = self.loadViewExtra.frame.size.width;
    
    [modalViewController.view setFrame:f];
    
    CGRect l1 = modalViewController->label1.frame;
    l1.size.width = self.loadViewExtra.frame.size.width;
    [modalViewController->label1 setFrame:l1];
    
    
}




-(void)setPageButtonValue{
    NSArray *buttonBarItems = toolbar.items;
    UIBarItem* bPageCount = [buttonBarItems objectAtIndex:4];
    
    [bPageCount setTitle:[NSString stringWithFormat:@"%d / %d",
                          [current_catalog getCurrentPage], [current_catalog getPageCount]]];
}


-(IBAction)deleteFiles:(id)sender{
    //    NSLog(@"");
    float filessize = [appDelegate.currentIshue getSizeOffAllDownlaodedFiles];
    NSString* tresc = [NSString stringWithFormat:@"Skasować cały kontent offline dla wydania ? Zwolnione zostanie około: %.2f Mb", filessize];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:tresc
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"TAK"
                                            otherButtonTitles:@"NIE",nil];
    message.delegate = self;
    [message show];
}



- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"alertView tag: %d", alertView.tag );
    if( alertView.tag == 9 ){
//        [self alertKodOk7];
    }
    else if( alertView.tag == 8 ){
  
    }
    else{
        //    NSLog(@"yes/no: %lu", buttonIndex );
        // 0 = Tapped yes
        if (buttonIndex == 0)
        {
            // ....
            [appDelegate.currentIshue removeAllIssueFilesFromDevice];
            [appDelegate.currentIshue loadAllIssueFiles];
            
            float filessize = [appDelegate.currentIshue getSizeOffAllDownlaodedFiles];
            if ( filessize > 0.0 )
                [buttonDelete setHidden:NO];
            else
                [buttonDelete setHidden:YES];
            
            [buttonBuy setTitle:@"POBIERZ" forState:UIControlStateNormal];
        }
        else{
            
        }
    }
}



-(IBAction)addToFav:(id)sender{
    if ( [appDelegate isFav:appDelegate.currentIshue->ishue_id] ){
        [appDelegate removeFromFav: current_catalog.ishue->ishue_id];
    }
    else{
        [appDelegate addToFav: current_catalog.ishue->ishue_id];
    }
    [PreviewHelper setButtons:self];
    
    [appDelegate.viewController reloadThumbs: YES];
}


-(IBAction)hidePreview:(id)sender{
    NSLog(@"hidePreview");
    [appDelegate.viewController hideIshueActionView];
    [appDelegate.loadViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)shareOnFb:(id)sender{
    NSArray *activityItems;
    //TODO TABLOY
    activityItems = @[@"Polecamy wydanie mobilne.", [current_catalog->images objectAtIndex:0] ];
    appDelegate.viewController.modalView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
    STabBarControler* sttab = (STabBarControler*)appDelegate.viewController.tabBarController;
    [sttab hideIt];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:activityItems
                                                    applicationActivities:nil];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL done){
        if (done) {
            NSLog(@"Success");
        }
        else {
            NSLog(@"Error/Cancel");
        }
        
    }];
    
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        activityController.popoverPresentationController.sourceView
        = appDelegate.viewController.modalView;
    }
    
    NSLog(@"anim: %d", appDelegate->animallowed);
    
    [appDelegate.viewController presentViewController:activityController
                                             animated:YES completion:nil];
    
    
}



-(void) openIssue{
    appDelegate.loadingInProgress = YES;
    [buttonBuy setEnabled:NO];
    buttonBuy.enabled=NO;
    buttonBuy.userInteractionEnabled = NO;
    [buttonBuy setEnabled:NO];
    [buttonBuy setAlpha:0.35];
    [buttonShare setEnabled:NO];
    [buttonShare setAlpha:0.35];
    [buttonAddToFav setEnabled:NO];
    [buttonAddToFav setAlpha:0.35];
    [buttonDelete setEnabled:NO];
    [buttonDelete setAlpha:0.35];
    
    [buttonKod setEnabled:NO];
    [buttonKod setAlpha:0.35];
    [buttonAR setEnabled:NO];
    [buttonAR setAlpha:0.35];
    
    BOOL pdfCorrectSplited = [appDelegate.currentIshue checkPdfCorrectSplited];
    BOOL thumbsCorrectDownloaded = [appDelegate.currentIshue checkThumbsCorrectDownloaded];
    
    if( [appDelegate.currentIshue.filesToDownload count] == 0 && pdfCorrectSplited && thumbsCorrectDownloaded ){
        [buttonBuy setTitle:@"OTWIERANIE" forState:UIControlStateNormal];
        [self.pageLabel setHidden:YES];
        [imageView setAlpha:0.75];
    }
    else{
        //        [self.aplaView setFrame:self.imageScrollView.frame];
        //        [self.view bringSubviewToFront:self.aplaView];
        //        [self.aplaView setAlpha:0.75];
        //        [self.aplaView setHidden:NO];
        [imageView setAlpha:0.75];
        [self.view bringSubviewToFront:self.loadViewExtra];
        [buttonBuy setTitle:@"POBIERANIE" forState:UIControlStateNormal];
        [self.pageLabel setHidden:YES];
    }
    
    if( [NHelper isIphone]){
        self.loadViewExtra.layer.borderWidth = 1.0f;
        self.loadViewExtra.layer.borderColor = [NHelper colorFromPlist:@"previewbuttonbuybg"].CGColor;
    }
    
    
    [viewForInd setHidden:NO];
    [indView startAnimating];
    [indView setHidden:NO];
    [self.imageScrollView bringSubviewToFront:viewForInd];
    
    
    LoadViewController *modalViewController =
    [[LoadViewController alloc] initWithNibName:@"LoadingView" bundle:nil];
    modalViewController->ishue_id = appDelegate.currentIshue->ishue_id;
    appDelegate.loadViewController = modalViewController;

    CGRect f = modalViewController.view.frame;
    f.size.width = 50;
    f.origin.x = 5;
    [NHelper showRectParams:f label:@"imageview"];
    [modalViewController.view setFrame:f];
    CGRect ff = modalViewController.progressBarFlatRainbowView.frame;
    ff.size.width = 50; //f.size.width;
    [modalViewController.progressBarFlatRainbowView setFrame:ff];
    
    [self.loadViewExtra addSubview:modalViewController.view];
    
    [NHelper showRectParams:modalViewController.view.frame label:@"modalViewController.view"];
    
    
    CGRect l1 = modalViewController->label1.frame;
    l1.size.width = self.loadViewExtra.frame.size.width;
    [modalViewController->label1 setFrame:l1];
    
    
    if( [appDelegate.currentIshue.filesToDownload count] == 0 && pdfCorrectSplited && thumbsCorrectDownloaded ){
        [modalViewController.view setHidden:YES];
    }
    
}


- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *login = alertController.textFields.lastObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 4;
    }
}


-(void)alertKod{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Kod jednorazowy"
                                          message:@"Jeżeli posiadasz jednorazowy kod, tutaj możesz go wykorzystać:"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Kod", @"Kod");
         textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *kod = alertController.textFields.firstObject;
                                   [self alertKodOk:kod.text] ;
                               }];
    okAction.enabled = NO;
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    NSLog(@"alertController: %@", alertController);
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

-(IBAction)useKod:(id)sender{
    [self alertKod];
    
}


-(void)wyslijZapytaniKod:(NSString*)kod{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:appDelegate.currentIshue->ishue_id] forKey:@"issue_id"];
    [dict setObject:kod forKey:@"code"];
    [dict setObject:appDelegate.mobileuser.mu_id forKey:@"mu_id"];
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor]UUIDString];
    [dict setObject:currentDeviceId forKey:@"currentDeviceId"];
    
    //send info that user open issue
    [AFHTTPRequestMaker sendGETRequestToAddress:@"/ajax/Common/IssuesCodes/useCodeIOS"
                                       withDict:dict
                                   successBlock:^(NSInteger statusCode, id responseObject) {
                                       int statusCodeResp = [[responseObject objectForKey:@"status"] intValue];
                                       NSLog(@"STATS SUCCES");
                                       
                                       NSString* msg = [responseObject objectForKey:@"msg"];
                                       if( statusCodeResp == 1 ){
                                           msg = [responseObject objectForKey:@"msg"];
                                           //                NSMutableDictionary* x = appDelegate.currentIshue.payments;
                                           
                                           NSMutableDictionary* x = [[NSMutableDictionary alloc] init];
                                           [x setValue:@"1" forKey:@"bought"];
                                           appDelegate.currentIshue.payments = [x copy];
                                           [PreviewHelper setButtons:self];
                                           //                [appDelegate setupIshuesCollection];
                                       }
                                       else{
                                           msg = [responseObject objectForKey:@"msg"];
                                       }
                                       
                                       UIAlertController *alertController = [UIAlertController
                                                                             alertControllerWithTitle:@"Kod jednorazowy"
                                                                             message:msg
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                       
                                       UIAlertAction *okAction = [UIAlertAction
                                                                  actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                                                  {
                                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                                  }];
                                       
                                       //    [alertController addAction:cancelAction];
                                       [alertController addAction:okAction];
                                       [self presentViewController:alertController animated:YES completion:nil];
                                   } failureBlock:^(NSInteger statusCode, NSError *error) {
                                       NSLog(@"STATS FAILED");
                                   }
     ];
    
    
}

-(void)alertKodOk: (NSString*)kod{
    
    [self wyslijZapytaniKod:kod];
    
    
}



- (BOOL)isiOS8OrAbove {
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0"
                                                                       options: NSNumericSearch];
    return (order == NSOrderedSame || order == NSOrderedDescending);
}

//-(void)alertKod{
//    if ([self isiOS8OrAbove]) {
//        
//        UIAlertController *alertController = [UIAlertController
//                                              alertControllerWithTitle:@"Kod jednorazowy"
//                                              message:@"Jeżeli posiadasz jednorazowy kod, tutaj możesz go wykorzystać:"
//                                              preferredStyle:UIAlertControllerStyleAlert];
//        
//        
//        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
//         {
//             textField.placeholder = NSLocalizedString(@"Kod", @"Kod");
//             [textField addTarget:self
//                           action:@selector(alertTextFieldDidChange:)
//                 forControlEvents:UIControlEventEditingChanged];
//         }];
//        
//        UIAlertAction *cancelAction = [UIAlertAction
//                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
//                                       style:UIAlertActionStyleCancel
//                                       handler:^(UIAlertAction *action)
//                                       {
//                                           NSLog(@"Cancel action");
//                                       }];
//        
//        UIAlertAction *okAction = [UIAlertAction
//                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
//                                   style:UIAlertActionStyleDefault
//                                   handler:^(UIAlertAction *action)
//                                   {
//                                       UITextField *email = alertController.textFields.firstObject;
//                                       UITextField *password = alertController.textFields.lastObject;
//                                       NSLog(@"email: %@ / %@", email.text, password.text );
//                                       [self alertKodOk];
//                                   }];
//        okAction.enabled = NO;
//        
//        [alertController addAction:cancelAction];
//        [alertController addAction:okAction];
//        
//        NSLog(@"alertController: %@", alertController);
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
//    
//    
//}

//-(IBAction)useKod:(id)sender{
//    if ([self isiOS8OrAbove]) {
//        [self alertKod];
//    }
//    else{
//        [self alertKod7];
//    }
//}

//-(void) alertKod7{
//    UIAlertView* dialog = [[UIAlertView alloc] init];
//    dialog.tag = 9;
//    [dialog setDelegate:self];
//    dialog.alertViewStyle=UIAlertViewStylePlainTextInput;
//    [dialog setTitle:@"Kod jednorazowy"];
//    [dialog setMessage:@"Jeżeli posiadasz jednorazowy kod, otrzymany przy okazji subskrypcji papierowej, tutaj możesz go wykorzystać:"];
//    
//    [dialog addButtonWithTitle:@"Cancel"];
//    [dialog addButtonWithTitle:@"Ok"];
//    
//    
//    UITextField *_UITextField  = [dialog textFieldAtIndex:0];
//    _UITextField.placeholder = @"******";
//    _UITextField.keyboardType = UIKeyboardTypeEmailAddress;
//    [dialog show];
//    
//    //uialertview delegate method
//    
//}


-(IBAction)selectIshueToView:(id)sender{
    if( appDelegate.currentIshue->price > 0 ){
        NSLog(@"KUP?: %d", buttonBuy.tag  );
        if( buttonBuy.tag == 666 ){
            if( appDelegate.loadingInProgress ){
            }
            else{
                [self openIssue];
            }
        }
        else{
            NSString* stringtofind = [NSString stringWithFormat:@"com.setupo.issue%d",appDelegate.currentIshue->ishue_id ];
            RageIAPHelper* rhelper = [RageIAPHelper sharedInstance];
            BOOL alreadyBought = [rhelper productPurchased:stringtofind];
            
            if( alreadyBought ){
                [self openIssue];
            }
            else{
                [appDelegate.viewController buyProductIdentifier:stringtofind];
            }
        }
    }
    else{
        
        if( appDelegate.loadingInProgress ){
            
        }
        else{
            [self openIssue];
        }
    }
    //    [self presentViewController:modalViewController animated:YES completion:nil];
    
}





-(void)qwerty{
    [appDelegate.viewController ishueButtonClicked];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    NSLog(@"products: %@", products );
    
    products = response.invalidProductIdentifiers;
}






- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)changePage:(int)animType {
    imageView.alpha =0.0f;
    UIImage* newImage = [current_catalog getCurrentImgFromPages];
    
    if (appDelegate.offlineMode){
        NSLog(@"newImage: %@", newImage );
    }
    
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [imageView setImage:newImage];
    //    NSLog(@"newImage sizes: h:%f w:%f", newImage.size.height,newImage.size.width );
    CGPoint scrollcenter = imageScrollView.center;
    
    double scale_out = 0.0f;
    double proporcje = newImage.size.height / newImage.size.width;
    CGRect rectForImageView;
    if ( proporcje > imageScrollView.frame.size.height / imageScrollView.frame.size.width ){
        //trzeba dopasowac do height
        double height = imageScrollView.frame.size.height;
        scale_out = (height / newImage.size.height);
        double new_width = imageScrollView.frame.size.width;//newImage.size.width*scale_out;
        rectForImageView = CGRectMake(0, 2, imageScrollView.frame.size.width, imageScrollView.frame.size.height-4);
    }
    else{
        //treba dopasowac do width
        double width = imageScrollView.frame.size.width;
        scale_out = (width / newImage.size.width);
        rectForImageView = CGRectMake(0, 2, imageScrollView.frame.size.width, imageScrollView.frame.size.height-4);
    }
    
    [NHelper showRectParams:rectForImageView label:@"rectForImageView"];
    
    
    [imageView setFrame:rectForImageView];
    switch (animType) {
        case 1:
            imageView.center = CGPointMake(scrollcenter.x-620, scrollcenter.y-45); break;
        case 2:
            imageView.center = CGPointMake(scrollcenter.x+620, scrollcenter.y-45); break;
        default:
            break;
    }
    
    [UIView beginAnimations:@"animateTableView" context:nil];
    [UIView setAnimationDuration:0.4];
    imageView.alpha =1.0f;
    
    [imageView setFrame:rectForImageView];
    
    [UIView commitAnimations];
    newImage = nil;
}




- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"swipeLeft: %d < %d", [current_catalog getCurrentPage], [current_catalog getPageCount]);
    if ( [current_catalog getCurrentPage] < [current_catalog getPageCount]-1 ){ //to -1 mnie martwi
        [current_catalog incCurrentPage];
        [self changePage:2];
        //        [self setPageButtonValue];
        [self sprawdzCzyPobranoPlusMinus:3];
    }
}



- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (appDelegate.offlineMode){
        return;
    }
    NSLog(@"swipeRight: %d > 1", [current_catalog getCurrentPage] );
    if ( [current_catalog getCurrentPage] >= 1 ){
        [current_catalog decCurrentPage];
        
        [self changePage:1];
        [self setPageButtonValue];
        [self sprawdzCzyPobranoPlusMinus:3];
        
    }
}


#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now
    NSLog(@"simgletap");
    [self selectIshueToView:nil];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // zoom in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}








#pragma mark -
#pragma mark NSURLConnectionDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
    filesize = [NSNumber numberWithLongLong: [response expectedContentLength] ];
}



- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    else{
    }
    return success;
}




- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ( connection_num == 0 ){
        NSLog(@"Download 0 connectionDidFinishLoading...");
    }
    else if ( connection_num == 666 ){
        NSLog(@"Download 666 connectionDidFinishLoading... " );
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* filepath = [prefs stringForKey:@"connection_filepath"];
        int downloaded_page = [current_catalog getPageNumFromFileName:filepath];
        UIImage *image = [UIImage imageWithData:responseData];
        
        [viewForInd setHidden:YES];
        
        if ( image == nil ){
            NSLog(@"ERRRRRRROOOOOOOR IADVISERAPPDELEGATE: 445 %@", filepath);
        }
        else {
            NSNumber* curLength = [NSNumber numberWithLong:[responseData length] ];
            if ( [curLength intValue] != [filesize intValue] ){
                NSLog(@"ERROR INCORECT SIZES: %i ? %i %@", [curLength intValue],[filesize intValue], filepath );
            }
            else {
                
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:image];
                [current_catalog->imagesNames replaceObjectAtIndex:downloaded_page withObject:filepath];
                
                
                if ( downloaded_page == current_catalog->current_page ){
                    [self changePage:1];
                }
                
                NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                if ( imageData == nil ){
                    NSLog(@"ERROR KURWA");
                }
                bool writed = [imageData writeToFile:filepath atomically:NO];
                
                if ( writed ){
                    NSURL* url = [NSURL fileURLWithPath: filepath ];
                    [self addSkipBackupAttributeToItemAtURL:url];
                }
                else{
                    NSLog(@"ERROR TCGC 735");
                }
                
                
                if ( [filesToDownload count] ){
                    [filesToDownload removeObjectAtIndex:0];
                    //jezeli current page jest loading960_0
                    if ( [[current_catalog->imagesNames objectAtIndex:current_catalog->current_page] isEqual:@"loading960_0.png"] ){
                        //tzn ze trzeba znalezc go na liscie to download i przeniesc na gore
                        //dla ulatwienia po prostu dodaje go na poxatku
                        NSString* filename = [current_catalog przygotujFileNameStrony:current_catalog->current_page];
                        [filesToDownload insertObject:filename atIndex:0];
                    }
                }
            }
        }
        image = nil;
        
        [self downloadFileExtra];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    connection_inprogress = YES;
    [responseData appendData:data];
    NSNumber* curLength = [NSNumber numberWithLong:[responseData length] ];
    
    if ( [filesize floatValue] > 0 ){
        float progress = [curLength floatValue] / [filesize floatValue] ;
        if ( progress < 0.02 || progress > 0.98 ){
            NSLog(@"[filesize floatValue]...  %f",  [filesize floatValue] );
            NSLog(@"Download progress...  %f",  progress );
        }
        
        UIImage* img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:0] ];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* filepath = [prefs stringForKey:@"connection_filepath"];
        int downloaded_page = [current_catalog getPageNumFromFileName:filepath];
        
        if ( downloaded_page == current_catalog->current_page ){
            
            if ( progress < 0.2 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:1] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 0.4 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:2] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 0.6 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:3] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 0.8 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:4] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else if ( progress < 1.0 ){
                img = [UIImage imageNamed:[current_catalog->loadingArray objectAtIndex:5] ];
                [current_catalog->images replaceObjectAtIndex:downloaded_page withObject:img];
            }
            else {
                NSLog(@"downloaded_page %d",  downloaded_page );
            }
            
            [self.imageView setImage:img];
            img = nil;
        }
    }
    else{
        NSLog(@"Download progress... dupa");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection_inprogress = NO;
    NSLog(@"Download failed");
    UIImage* loading = [UIImage imageNamed:@"loading960_offline"];
    [imageView setImage:loading];
    
    [self.pageLabel setText:@""];
    [viewForInd setHidden:YES];
    
}


@end
