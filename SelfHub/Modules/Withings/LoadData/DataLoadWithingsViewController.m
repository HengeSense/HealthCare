//
//  DataLoadWithingsViewController.m
//  SelfHub
//
//  Created by Igor Barinov on 10/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataLoadWithingsViewController.h"

@interface DataLoadWithingsViewController ()

@end

@implementation DataLoadWithingsViewController
@synthesize delegate;
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
    // добавить условие на залогиненность ??
    getImportData = [[[WorkWithWithings alloc] init] autorelease];
    dataToImport = [getImportData getUserMeasuresWithCategory:1];
    NSLog(@"dataToImport %@", dataToImport);
    if (dataToImport==nil){
        //[resultView setHidden:false];
        //[loadWView setHidden:true];
        [resultTryagainButton setHidden:false];
        receiveLabel.text = NSLocalizedString(@"No data", @"");
    }else{
        resultTitleLabel.text = NSLocalizedString(@"Recieve", @"");
        resultCountLabel.text = (NSString*) dataToImport.count;
        resultWordLabel.text = [self endWordForResult: dataToImport.count];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadMesData];
   
};


- (void)viewWillDisappear:(BOOL)animated{
    
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
}
- (IBAction)resultImportButtonClick:(id)sender {
    if([delegate.authOfImport isEqual:@"0"]){
        
         NSArray *importData = (NSArray *)[dataToImport objectForKey:@"data"];
         NSMutableArray *weightModuleData = (NSMutableArray*)[delegate.delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
        if (weightModuleData.count > 1){
           [weightModuleData addObject:[importData objectAtIndex:0]];
            [delegate.delegate setValue:(NSArray*)weightModuleData forName:@"database" forModuleWithID:@"selfhub.weight"];
        }else {
            [delegate.delegate setValue:importData forName:@"database" forModuleWithID:@"selfhub.weight"];
        }
        
        resultTitleLabel.text = NSLocalizedString(@"Imported", @"");
        resultCountLabel.text = (NSString*) importData.count;
        resultWordLabel.text = [self endWordForResult: importData.count];
    } else {
        //
    }
    
    
}

- (IBAction)resultShowButtonClick:(id)sender {
    [delegate.delegate switchToModuleWithID:@"selfhub.weight"];
}

- (IBAction)resultTryagainButtonClick:(id)sender {
    [self loadMesData];
    
}
@end
