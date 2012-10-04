//
//  AgreementView.m
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AgreementView.h"

@interface AgreementView ()

@end

@implementation AgreementView
@synthesize delegate;
@synthesize agreeView;
@synthesize acceptButton;
@synthesize notacceptButton;
@synthesize agrScrollView;
@synthesize agreeLabell;

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
    agreeView.layer.cornerRadius = 10.0;
}

- (void)viewDidUnload
{
    [self setAgreeView:nil];
    [self setAcceptButton:nil];
    [self setNotacceptButton:nil];
    [self setAgrScrollView:nil];
    [self setAgreeLabell:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [agreeView release];
    [acceptButton release];
    [notacceptButton release];
    [agrScrollView release];
    [agreeLabell release];
    [super dealloc];
}

- (IBAction)acceptButtonClick:(id)sender {
    UIButton *button = [[[UIButton alloc] init]autorelease];
    button.tag = 0;
    AuthView *auth = [self.delegate.viewControllers objectAtIndex:0];
    auth.registrView.hidden = NO;
    auth.authView.hidden = YES;
    [delegate selectScreenFromMenu:(id)button];
    delegate.agreement = @"0";
}

- (IBAction)notacceptButtonClick:(id)sender {
    UIButton *button = [[[UIButton alloc] init]autorelease];
    button.tag = 2;
    [delegate selectScreenFromMenu:(id)button];
    delegate.agreement = @"1";
    
}
@end
