//
//  SubTableViewController.m
//  SetupoAVT
//
//  Created by Marcin Niedźwiecki on 13.02.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import "SubTableViewController.h"
#import "RageIAPHelper.h"
#import "ChatTopicTableViewCell.h"
#import "NHelper.h"

@interface SubTableViewController ()
{
    NSMutableArray* rowdata;
    NSMutableArray* rowdata2;
    NSMutableArray* rowdata3;
}
@end

@implementation SubTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    rowdata = [[NSMutableArray alloc] init];
    rowdata2 = [[NSMutableArray alloc] init];
    rowdata3 = [[NSMutableArray alloc] init];
    
    [self.view setBackgroundColor:[NHelper colorFromPlist:@"topbarbg"]];
    [self.tableView setBackgroundColor:[NHelper colorFromPlist:@"topbarbg"]];
    [self.tableView setSeparatorColor:[NHelper colorFromPlist:@"catalog_topbar_icon_color"]];
    
    
    NSMutableDictionary* row1 = [[NSMutableDictionary alloc] init];
    [row1 setValue:@"$3" forKey:@"price"];
    [row1 setValue:@"Darmowa subskrypcja" forKey:@"label"];
    
    if ( [[[NHelper appSettings] objectForKey:@"useSub"] boolValue] ){
        [rowdata addObject:row1];
    }
    
    NSMutableDictionary* row4 = [[NSMutableDictionary alloc] init];
    [row4 setValue:@"" forKey:@"price"];
    [row4 setValue:@"Przywracanie zakupów" forKey:@"label"];
    [rowdata3 addObject:row4];
    
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    
    if( [NHelper isIphone]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.view setBackgroundColor:[NHelper colorFromPlist:@"kioskbg"]];
        [self.tableView setBackgroundColor:[NHelper colorFromPlist:@"kioskbg"]];
        [self.tableView setSeparatorColor:[NHelper colorFromPlist:@"catalog_topbar_icon_color"]];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
        [self.navigationController.navigationBar setTintColor:
         [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:2555.0f/255.0f alpha:1.0]];
    }
}
//FFD105

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,244)];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
    tempLabel.backgroundColor=[UIColor clearColor];
//    tempLabel.shadowColor = [UIColor blackColor];
//    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = [NHelper colorFromPlist:@"catalog_topbar_icon_color"]; //here you can change the text color of header.
    tempLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    
    NSString * sectionName = @"";
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Prenumeraty", @"Prenumeraty");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Inne", @"Inne");
            break;
        default:
            sectionName = @"";
            break;
    }
    tempLabel.text = sectionName;
    
    
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}



-(void)viewWillDisappear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if( section == 0 ){
        return [rowdata count];
    }
//    else if( section == 1 ){
//        return [rowdata2 count];
//    }
    else{
        return [rowdata3 count];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"myCell";
    
    NSString* nibName = @"ChatTopicTableViewCell";
    ChatTopicTableViewCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    
    NSLog(@"indexPath.section: %d => %d", indexPath.section, indexPath.row);
    if ( indexPath.section == 0 ){
        cell.labelOne.text = [[rowdata objectAtIndex:indexPath.row] objectForKey:@"price"];
        cell.labelTwo.text = [[rowdata objectAtIndex:indexPath.row] objectForKey:@"label"];
        NSLog(@"cell.labelTwo.text: %@", cell.labelTwo.text);
        [cell setBackgroundColor:[NHelper colorFromHexString:@"#eeeeee"]];
        if( [NHelper isIphone]){
            [cell setBackgroundColor:[NHelper colorFromHexString:@"#dddddd"]];
            [cell.labelTwo setTextColor:[NHelper colorFromHexString:@"#333333"]];
        }
    }
    else{
        cell.labelOne.text = [[rowdata3 objectAtIndex:indexPath.row] objectForKey:@"price"];
        cell.labelTwo.text = [[rowdata3 objectAtIndex:indexPath.row] objectForKey:@"label"];
        NSLog(@"cell.labelTwo.text: %@", cell.labelTwo.text);
        
        [cell setBackgroundColor:[NHelper colorFromHexString:@"#eeeeee"]];
        if( [NHelper isIphone]){
            [cell setBackgroundColor:[NHelper colorFromHexString:@"#dddddd"]];
            [cell.labelTwo setTextColor:[NHelper colorFromHexString:@"#333333"]];
        }
    }
    
    return cell;
    
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( section == 2 ){
        return 25;
    }
    return 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Prenumeraty", @"Prenumeraty");
            break;
//        case 1:
//            sectionName = NSLocalizedString(@"Prenumeraty", @"Prenumeraty - wSieci Historii");
//            break;
        case 1:
            sectionName = NSLocalizedString(@"Inne", @"Inne");
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"%d=>%@", indexPath.section, [appDelegate->app_subs objectAtIndex:0] );
    
    if( indexPath.section == 0 ){
        if( indexPath.row == 0 )
            [appDelegate.viewController buyProductIdentifier:[appDelegate->app_subs objectAtIndex:0]];
//        if( indexPath.row == 1 )
//            [appDelegate.viewController buyProductIdentifier:@"com.setupo.rynekzoologiczny.6m"];
//        if( indexPath.row == 2 )
//            [appDelegate.viewController buyProductIdentifier:@"com.setupo.rynekzoologiczny.1m"];
        
    }
    else{
        [appDelegate.alreadyBought removeAllObjects];
        [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
    }
    
    if ( [NHelper isIphone]){
        //        [self pop÷]
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
