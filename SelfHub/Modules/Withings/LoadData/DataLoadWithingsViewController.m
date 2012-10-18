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
@synthesize resultView, resstatusView;
@synthesize resultTitleLabel, resultCountLabel, resultWordLabel;
@synthesize resultImportButton, resultShowButton;
@synthesize resultTryagainButton, showLabel;

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
//    NSLog(@"kkk %@", (NSString *)[NSDate dateWithTimeIntervalSince1970:1345185914]);
    [super viewDidLoad];
    resstatusView.layer.cornerRadius = 10.0;
    
    [mainLoadView addSubview:resultView];
    [resultView setHidden:true];
    [loadWView setHidden:false];
    [resultTryagainButton setTitle:NSLocalizedString(@"Try again", @"") forState:UIControlStateNormal];
    receiveLabel.text = NSLocalizedString(@"Loading data", @"");
    //workWithWithings  = [[[WorkWithWithings alloc] init] autorelease];//?? нужна ли инициализацмя
    
}


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
    if(delegate.lastTime == 0  || delegate.lastuser!=delegate.userID || delegate.lastuser==0){
        self.workWithWithings  = [[WorkWithWithings alloc] init];
        self.workWithWithings.user_id = delegate.userID;
        self.workWithWithings.user_publickey = delegate.userPublicKey;
        self.dataToImport = [workWithWithings getUserMeasuresWithCategory:1];
       
    }else{
        int time_Now = [[NSDate date] timeIntervalSince1970];
        dataToImport = [workWithWithings getUserMeasuresWithCategory:1 StartDate:delegate.lastTime AndEndDate:time_Now];
    }
     
    if (dataToImport==nil){
        //[resultView setHidden:false];
        //[loadWView setHidden:true];
        [resultTryagainButton setHidden:false];
        receiveLabel.text = NSLocalizedString(@"No data", @"");
    }else{
        [resultView setHidden:false];
        [loadWView setHidden:true];
        resultTitleLabel.text = NSLocalizedString(@"Recieve", @"");
        resultCountLabel.text = [NSString stringWithFormat:@"%d", [[self.dataToImport objectForKey:@"data"] count]];
        resultWordLabel.text = [self endWordForResult: [[self.dataToImport objectForKey:@"data"] count]];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadMesData];
   
};


- (void)viewWillDisappear:(BOOL)animated{
    // TODO: очищение формы?
   
}

-(void) cleanup {  
    [resultView setHidden:true];
    [loadWView setHidden:false];
    [resultTryagainButton setHidden:true];
    receiveLabel.text = NSLocalizedString(@"Loading data", @"");
    resultTitleLabel.text = NSLocalizedString(@"Recieve", @"");
    resultCountLabel.text =@"0";
    resultWordLabel.text = NSLocalizedString(@"Results", @"");
    [resultImportButton setHidden:false];
    [resultShowButton setHidden:true];
}

- (IBAction)testImport:(id)sender {
    
    // It
    
    NSArray *importData = (NSArray *)[self.dataToImport objectForKey:@"data"];
    
    NSMutableArray *weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
    BOOL checkImport;
    if (weightModuleData.count > 1){
        for (int k=0; k<6; k++) {
             [weightModuleData addObject:[importData objectAtIndex:k]];
        }
       
        checkImport = [delegate.delegate setValue:(NSArray*)weightModuleData forName:@"database" forModuleWithID:@"selfhub.weight"];
    }else {
        NSMutableArray *testImp = [[NSMutableArray alloc] init];
        for (int k=0; k<6; k++) {
            [testImp addObject:[importData objectAtIndex:k]];
        }
        checkImport = [delegate.delegate setValue:(NSArray*)testImp forName:@"database" forModuleWithID:@"selfhub.weight"];
        [testImp release];
    }
    if (checkImport==YES){ 
//        NSDate *lastDate = [(NSDictionary*)[importData objectAtIndex:importData.count-1] objectForKey:@"date"]; 
//        int time_Last = [lastDate timeIntervalSince1970];
//        delegate.lastTime = time_Last;
        
        resultTitleLabel.text = NSLocalizedString(@"Imported", @"");
        //resultCountLabel.text = (NSString*) importData.count;
        resultWordLabel.text = [self endWordForResult: importData.count];
        //[resultImportButton setHidden:true];
        //[resultShowButton setHidden:false];
    }else {
        resultTitleLabel.text = NSLocalizedString(@"Imported", @"");
        resultCountLabel.text = @"0";
        resultWordLabel.text = [self endWordForResult: 0];
    } 
}


- (IBAction)resultImportButtonClick:(id)sender {
    NSLog(@"dataToImport %@", self.dataToImport);
    NSArray *importData = (NSArray *)[self.dataToImport objectForKey:@"data"];

    
    NSMutableArray *weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
    BOOL checkImport;
    if (weightModuleData.count > 1){
        [weightModuleData addObject:importData];
        checkImport = [delegate.delegate setValue:(NSArray*)weightModuleData forName:@"database" forModuleWithID:@"selfhub.weight"];
    }else {
        checkImport = [delegate.delegate setValue:importData forName:@"database" forModuleWithID:@"selfhub.weight"];
    }
    if (checkImport==YES){ 
        NSDate *lastDate = [(NSDictionary*)[importData objectAtIndex:importData.count-1] objectForKey:@"date"]; 
        int time_Last = [lastDate timeIntervalSince1970];
        delegate.lastTime = time_Last;
        
        resultTitleLabel.text = NSLocalizedString(@"Imported", @"");
        resultCountLabel.text = (NSString*) importData.count;
        resultWordLabel.text = [self endWordForResult: importData.count];
        [resultImportButton setHidden:true];
        [resultShowButton setHidden:false];
    }else {
        resultTitleLabel.text = NSLocalizedString(@"Imported", @"");
        resultCountLabel.text = @"0";
        resultWordLabel.text = [self endWordForResult: 0];
    }   
}

- (IBAction)resultShowButtonClick:(id)sender {
    [delegate.delegate switchToModuleWithID:@"selfhub.weight"];
}

- (IBAction)resultTryagainButtonClick:(id)sender {
    [self loadMesData];
    
}

- (void)viewDidUnload
{
    delegate = nil;
    [self setMainLoadView:nil];
    [self setLoadWView:nil];
    [self setLoadingImage:nil];
    [self setReceiveLabel:nil];
    [self setResultView:nil];
    [self setResstatusView:nil];
    [self setResultTitleLabel:nil];
    [self setResultCountLabel:nil];
    [self setResultWordLabel:nil];
    [self setResultImportButton:nil];
    [self setResultShowButton:nil];
    [self setResultTryagainButton:nil];
    [self setShowLabel:nil];
    workWithWithings = nil;
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
    [resultView release];
    [resstatusView release];
    [resultTitleLabel release];
    [resultCountLabel release];
    [resultWordLabel release];
    [resultImportButton release];
    [resultShowButton release];
    [resultTryagainButton release];
    [showLabel release];
    [super dealloc];
    [workWithWithings release];
}
@end
