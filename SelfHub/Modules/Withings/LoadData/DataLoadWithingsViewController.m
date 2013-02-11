//
//  DataLoadWithingsViewController.m
//  SelfHub
//
//  Created by Igor Barinov on 10/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataLoadWithingsViewController.h"

@interface DataLoadWithingsViewController ()  <UIAlertViewDelegate>
@property (nonatomic, retain) NSDictionary *dataToImport;
@property (nonatomic, retain) WorkWithWithings *workWithWithings;
@end

@implementation DataLoadWithingsViewController
@synthesize delegate, dataToImport, workWithWithings;
@synthesize mainLoadView,loadWView,loadingImage;
@synthesize receiveLabel, usernameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void)initialize
{
    self.workWithWithings  = [[WorkWithWithings alloc] init]; 
    receiveLabel.text = NSLocalizedString(@"Loading data", @"");
    usernameLabel.text = @"";
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    receiveLabel.text = NSLocalizedString(@"Loading data", @"");
    UIImage *BackgroundImageBig = [UIImage imageNamed:@"withings_background-568h.png"];
    self.mainLoadView.backgroundColor = [UIColor colorWithPatternImage:BackgroundImageBig];
    self.loadWView.backgroundColor = [UIColor colorWithPatternImage: BackgroundImageBig];
    usernameLabel.text = delegate.user_firstname;
}

- (void)viewDidUnload
{
    delegate = nil;
    dataToImport = nil;
    workWithWithings = nil;
    [self setMainLoadView:nil];
    [self setLoadWView:nil];
    [self setLoadingImage:nil];
    [self setReceiveLabel:nil];
    [self setUsernameLabel:nil];
    [super viewDidUnload];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    usernameLabel.text = delegate.user_firstname;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    usernameLabel.text = delegate.user_firstname;
    [self loadMesData];    
}

#pragma mark - helpFunctions for importing data
- (NSString*) endWordForResult: (int) count
{
    int val = count % 100;
    if (val > 10 && val < 20) return NSLocalizedString(@"Results", @"");
    else {
        val = count % 10;
        if (val == 1) return NSLocalizedString(@"Result", @"");
        else if (val > 1 && val < 5) return NSLocalizedString(@"Resulta", @"");
        else return NSLocalizedString(@"Results", @"");
    }
}

-(NSMutableArray*) distinctArrayByDate: (NSMutableArray*) convertArray
{
    NSMutableSet *uniqueDates = [[NSMutableSet alloc] init];
    NSMutableArray *uniqueArray = [NSMutableArray array];
    for (id item in convertArray)
    {
        if (![uniqueDates containsObject:[item valueForKey:@"date"]])
        {
            [uniqueDates addObject:[item valueForKey:@"date"]];
            [uniqueArray addObject:item];
        }
    }
    [uniqueDates release];
    return uniqueArray;
}

-(BOOL) addDataToWeightControlModule: (NSMutableArray *)whatToAdd andArrayToAdding: (NSMutableArray *)whereToAdd
{
    NSMutableSet *setOfDates = [NSMutableSet setWithArray:[whereToAdd valueForKey:@"date"]];
    for (id item in whatToAdd)
    {
        if (![setOfDates containsObject:[item valueForKey:@"date"]]){
            [whereToAdd addObject:item];
        }
    }
    return [delegate.delegate setValue:whereToAdd
                               forName:@"database" forModuleWithID:@"selfhub.weight"];
}


#pragma mark - load data for importing
-(void) loadMesData
{
    NSMutableArray *weightModuleData;  
    self.workWithWithings.user_id = delegate.userID;
    self.workWithWithings.user_publickey = delegate.userPublicKey;
    
    int time_Now = [[NSDate date] timeIntervalSince1970];      
    weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database"
                                                          fromModuleWithID:@"selfhub.weight"];
    
    self.dataToImport = (delegate.lastTime == 0 || delegate.lastuser!=delegate.userID || delegate.lastuser==0 || [weightModuleData count] == 0) ? [workWithWithings getUserMeasuresWithCategory:1] : [workWithWithings getUserMeasuresWithCategory:1 StartDate:delegate.lastTime AndEndDate:time_Now];
    
    if (dataToImport==nil)
    {
        receiveLabel.text = NSLocalizedString(@"No data", @"");
        [UIAlertView createAndShowAlertViewWithTitle:@"Error" message:@"No data" titleOtherButton:@"Try again" delegate:self andTag:1];
    }else{
        [self resultImportSend];
    }
}


- (void)resultImportSend
{
    NSMutableArray *importData;
    NSMutableArray *weightModuleData;
    BOOL checkImport;
    
    receiveLabel.text = NSLocalizedString(@"Import_data", @"");
   
    importData = [self distinctArrayByDate: (NSMutableArray *)[self.dataToImport objectForKey:@"data"]];    
    weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database"
                                                          fromModuleWithID:@"selfhub.weight"];
    checkImport = NO;
    if (weightModuleData.count > 0)
    {
        if(delegate.lastuser==0 || delegate.lastuser==delegate.userID)
        {
            checkImport = [self addDataToWeightControlModule:importData andArrayToAdding:weightModuleData];
        }else if(delegate.lastuser!=delegate.userID)
        {
            checkImport = [self addDataToWeightControlModule:weightModuleData andArrayToAdding:importData];
        }
    }else {
        checkImport = [delegate.delegate setValue:importData
                                          forName:@"database" forModuleWithID:@"selfhub.weight"];
    }
    
    if (checkImport)
    {
        int time_Last = [[NSDate date] timeIntervalSince1970];
        delegate.lastTime = time_Last;
        delegate.lastuser = delegate.userID;
        
        if([delegate.notify isEqualToString:@"0"])// send notifications
        {
            BOOL resultSubNotify = [self.workWithWithings getNotificationSibscribeWithComment:@"test" andAppli:1];
            if(resultSubNotify)
            {
                [UAPush shared].alias = [NSString stringWithFormat:@"%d", delegate.userID];
                [[UAPush shared] registerDeviceToken:(NSData*)[UAPush shared].deviceToken];
                delegate.notify = @"1";
                NSDictionary *resultOfCheck = [self.workWithWithings getNotificationStatus];
                if (resultOfCheck!=nil){
                    delegate.expNotifyDate = [[resultOfCheck objectForKey:@"date"] intValue];
                }
            }
        }
        
        [delegate saveModuleData];
        receiveLabel.text = NSLocalizedString(@"Import_ended", @"");
        UIAlertView *alertImportedData = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%d %@ %@", importData.count,[self endWordForResult: importData.count], NSLocalizedString(@"Imported",@"")]
                                                                   delegate:self
                                                          cancelButtonTitle: NSLocalizedString(@"Cancel",@"")
                                                          otherButtonTitles:NSLocalizedString(@"Show_results", @""), nil];
        [alertImportedData setTag:3];
        [alertImportedData show];
        [alertImportedData release];
        
    }else {
        receiveLabel.text = NSLocalizedString(@"Not_imported", @"");
        [UIAlertView createAndShowAlertViewWithTitle:@"" message:@"Not_imported" titleOtherButton:@"Try again" delegate:self andTag:2];
    }
}

#pragma mark - AlertViewDelegate 
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [delegate selectScreenProgrammatically:buttonIndex];
        [self cleanup];
    }else {
        if (alertView.tag == 1){
            [self loadMesData];
        } else if (alertView.tag == 2){
            [self resultImportSend];
        }else if (alertView.tag == 3){
            [delegate.delegate switchToModuleWithID:@"selfhub.weight"];
            [delegate selectScreenProgrammatically:0];
        }
    }
}

#pragma mark - method for updating after receiving notification
-(void) loadDataForPushNotify
{
    NSDictionary *dataToImportForPushNotify;
    NSMutableArray *weightModuleData;
    self.workWithWithings.user_id = delegate.userID;
    self.workWithWithings.user_publickey = delegate.userPublicKey;
        
    int time_Now = [[NSDate date] timeIntervalSince1970];
    weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database"
                                                          fromModuleWithID:@"selfhub.weight"];
    

    dataToImportForPushNotify = dataToImportForPushNotify = (delegate.lastTime == 0  || delegate.lastuser!=delegate.userID || delegate.lastuser==0 || [weightModuleData count] == 0) ? [workWithWithings getUserMeasuresWithCategory:1] : [workWithWithings getUserMeasuresWithCategory:1 StartDate:delegate.lastTime AndEndDate:time_Now];
    
    if (dataToImportForPushNotify!=nil)
    {        
        BOOL checkImport;
        NSMutableArray *importData = [self distinctArrayByDate: (NSMutableArray *)[dataToImportForPushNotify objectForKey:@"data"]];

        checkImport =  (weightModuleData.count > 1) ? [self addDataToWeightControlModule:importData andArrayToAdding:weightModuleData] : [delegate.delegate setValue:importData forName:@"database" forModuleWithID:@"selfhub.weight"];        
        if (checkImport)
        {
            delegate.lastTime = time_Now;
            [delegate saveModuleData];
        }
    }
}


-(void) cleanup
{
    receiveLabel.text = NSLocalizedString(@"Loading data", @"");
    usernameLabel.text = @"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mainLoadView release];
    [loadWView release];
    [loadingImage release];
    if (workWithWithings) [workWithWithings release];
    if (dataToImport) [dataToImport release];
    [receiveLabel release];
    [usernameLabel release];
    [super dealloc];
}
@end
