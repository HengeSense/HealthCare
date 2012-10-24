//
//  DataLoadWithingsViewController.m
//  SelfHub
//
//  Created by Igor Barinov on 10/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataLoadWithingsViewController.h"

@interface DataLoadWithingsViewController ()
    @property (nonatomic, retain) NSDictionary *dataToImport;
    @property (nonatomic, retain) WorkWithWithings *workWithWithings;
@end

@implementation DataLoadWithingsViewController
@synthesize delegate, dataToImport, workWithWithings;
@synthesize mainLoadView;
@synthesize loadWView;
@synthesize loadingImage;
@synthesize receiveLabel;

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
    receiveLabel.text = NSLocalizedString(@"Loading data", @"");
    
    UIImage *BackgroundImageBig = [UIImage imageNamed:@"withings_background@2x.png"];
    UIImage *BackgroundImage = [[UIImage alloc] initWithCGImage:[BackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    self.mainLoadView.backgroundColor = [UIColor colorWithPatternImage:BackgroundImage];
    self.loadWView.backgroundColor = [UIColor colorWithPatternImage: BackgroundImage];
    [BackgroundImage release];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadMesData];
    
    
};


- (NSString*) endWordForResult: (int) count{
    int val = count % 100;
    if (val > 10 && val < 20) return NSLocalizedString(@"Results", @"");
    else {
        val = count % 10;
        if (val == 1) return NSLocalizedString(@"Result", @"");
        else if (val > 1 && val < 5) return NSLocalizedString(@"Resulta", @"");
        else return NSLocalizedString(@"Results", @"");
    }
}

-(void) loadMesData{
    self.workWithWithings  = [[WorkWithWithings alloc] init];
    self.workWithWithings.user_id = delegate.userID;
    self.workWithWithings.user_publickey = delegate.userPublicKey;
    if(delegate.lastTime == 0  || delegate.lastuser!=delegate.userID || delegate.lastuser==0){
        self.dataToImport = [workWithWithings getUserMeasuresWithCategory:1];       
    }else{
        int time_Now = [[NSDate date] timeIntervalSince1970];
        dataToImport = [workWithWithings getUserMeasuresWithCategory:1 StartDate:delegate.lastTime AndEndDate:time_Now];
    }
     
    if (dataToImport==nil){
        receiveLabel.text = NSLocalizedString(@"No data", @"");
         UIAlertView *alert1 = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"")  message:NSLocalizedString(@"No data",@"")  delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles: NSLocalizedString(@"Try again",@""), nil] autorelease];
        [alert1 show];
        [alert1 setTag:1];
    }else{
       [self resultImportSend];
        
        //resultCountLabel.text = [NSString stringWithFormat:@"%d", [[self.dataToImport objectForKey:@"data"] count]];
        //resultWordLabel.text = [self endWordForResult: [[self.dataToImport objectForKey:@"data"] count]];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
        UIButton *button = [[UIButton alloc] init];
        button.tag = buttonIndex;
        [delegate selectScreenFromMenu:button];
        [button release];
        
    }else {
        if (alertView.tag==1){
            [self loadMesData];
        } else if (alertView.tag==2){
            [self resultImportSend];
        }else if (alertView.tag==3){
            [delegate.delegate switchToModuleWithID:@"selfhub.weight"];
            UIButton *button = [[UIButton alloc] init];
            button.tag = 0;
            [delegate selectScreenFromMenu:button];
            [button release];
        }
    }
}

- (void)resultImportSend {
    NSLog(@"dataToImport %@", self.dataToImport);
    receiveLabel.text = NSLocalizedString(@"Import_data", @"");
    NSArray *importData = (NSArray *)[self.dataToImport objectForKey:@"data"];
    
    
    NSMutableArray *weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
    BOOL checkImport;
    if (weightModuleData.count > 1){
        for (int k=0; k<[importData count]; k++) {
            [weightModuleData addObject:[importData objectAtIndex:k]];
        }
        checkImport = [delegate.delegate setValue:(NSArray*)weightModuleData forName:@"database" forModuleWithID:@"selfhub.weight"];
    }else {
        checkImport = [delegate.delegate setValue:importData forName:@"database" forModuleWithID:@"selfhub.weight"];
    }
    if (checkImport==YES){ 
        NSDate *lastDate = [(NSDictionary*)[importData objectAtIndex:importData.count-1] objectForKey:@"date"]; 
        int time_Last = [lastDate timeIntervalSince1970];
        delegate.lastTime = time_Last;
        delegate.lastuser = delegate.userID;
        [delegate saveModuleData];
        
        receiveLabel.text = NSLocalizedString(@"Import_ended", @"");
        
        UIAlertView *alert3 = [[[UIAlertView alloc] initWithTitle:@""  message:[NSString stringWithFormat:@"%@ " @"%d" @" %@", NSLocalizedString(@"Imported",@""),importData.count, [self endWordForResult: importData.count]]  delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles:@"К просмотру", nil] autorelease];//NSLocalizedString(@"Try again",@""
        [alert3 show];
        [alert3 setTag:3];
              
    }else {
        receiveLabel.text = NSLocalizedString(@"Not_imported", @"");
        UIAlertView *alert2 = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"")  message:NSLocalizedString(@"Not_import",@"")  delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles: NSLocalizedString(@"Try again",@""), nil] autorelease];
        [alert2 show];
        [alert2 setTag:2];
    }  
}



-(void) cleanup {  
    receiveLabel.text = NSLocalizedString(@"Loading data", @"");
}

//- (IBAction)testImport:(id)sender {
//    
//    // It
//    
//    NSArray *importData = (NSArray *)[self.dataToImport objectForKey:@"data"];
//    
//    NSMutableArray *weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
//    BOOL checkImport;
//    if (weightModuleData.count > 1){
//        for (int k=0; k<6; k++) {
//             [weightModuleData addObject:[importData objectAtIndex:k]];
//        }
//       
//        checkImport = [delegate.delegate setValue:(NSArray*)weightModuleData forName:@"database" forModuleWithID:@"selfhub.weight"];
//    }else {
//        NSMutableArray *testImp = [[NSMutableArray alloc] init];
//        for (int k=0; k<6; k++) {
//            [testImp addObject:[importData objectAtIndex:k]];
//        }
//        checkImport = [delegate.delegate setValue:(NSArray*)testImp forName:@"database" forModuleWithID:@"selfhub.weight"];
//        [testImp release];
//    }
//    if (checkImport==YES){ 
////        NSDate *lastDate = [(NSDictionary*)[importData objectAtIndex:importData.count-1] objectForKey:@"date"]; 
////        int time_Last = [lastDate timeIntervalSince1970];
////        delegate.lastTime = time_Last;
//        
//        resultTitleLabel.text = NSLocalizedString(@"Imported", @"");
//        //resultCountLabel.text = (NSString*) importData.count;
//        resultWordLabel.text = [self endWordForResult: importData.count];
//        //[resultImportButton setHidden:true];
//        //[resultShowButton setHidden:false];
//    }else {
//        resultTitleLabel.text = NSLocalizedString(@"Imported", @"");
//        resultCountLabel.text = @"0";
//        resultWordLabel.text = [self endWordForResult: 0];
//    } 
//}


- (void)viewDidUnload
{
    delegate = nil;
    dataToImport = nil;
    workWithWithings = nil;
    [self setMainLoadView:nil];
    [self setLoadWView:nil];
    [self setLoadingImage:nil];
    [self setReceiveLabel:nil];
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mainLoadView release];
    [loadWView release];
    [loadingImage release];
    [receiveLabel release];    
    if (workWithWithings) [workWithWithings release];
    if (dataToImport) [dataToImport release];
    [super dealloc];
}
@end
