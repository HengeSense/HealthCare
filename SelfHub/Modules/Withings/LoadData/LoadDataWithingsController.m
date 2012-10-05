//
//  LoadDataController.m
//  SelfHub
//
//  Created by Igor Barinov on 10/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadDataWithingsController.h"


@interface LoadDataWithingsController ()

@end

@implementation LoadDataWithingsController

@synthesize mainLoadView;
@synthesize resultView, delegate;
@synthesize resstatusView;
@synthesize resultTitleLabel, resultCountLabel, resultWordLabel;
@synthesize resultShowButton, resultImportButton;
@synthesize receiveLabel, resultTryagainButton;
@synthesize loadView;

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
    //resstatusView.layer.cornerRadius = 10.0;
   
    //[mainLoadView addSubview:resultView];
    //[resultView setHidden:true];
    //[registrView setFrame:CGRectMake(5.0, 6.0, 310.0, 404.0)];
    //[loadView setHidden:false];
    
}

- (void)viewDidUnload
{
    [self setResultView:nil];
    [self setResstatusView:nil];
    [self setResultTitleLabel:nil];
    [self setResultCountLabel:nil];
    [self setResultWordLabel:nil];
    [self setResultShowButton:nil];
    [self setResultImportButton:nil];
    [self setReceiveLabel:nil];
    [self setResultTryagainButton:nil];
    [self setMainLoadView:nil];
    [self setLoadView:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [resultView release];
    [resstatusView release];
    [resultTitleLabel release];
    [resultCountLabel release];
    [resultWordLabel release];
    [resultShowButton release];
    [resultImportButton release];
    [receiveLabel release];
    [resultTryagainButton release];
    [mainLoadView release];
    [loadView release];
    [super dealloc];
}
- (IBAction)resultTryagainButtonClick:(id)sender {
}

- (IBAction)resultImportButtonClick:(id)sender {
}

- (IBAction)resultShowButtonClick:(id)sender {
}
@end
