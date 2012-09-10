//
//  AgrmAndAuthViewController.m
//  SelfHub
//
//  Created by Igor Barinov on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AuthView.h"

@interface AuthView ()

@end

@implementation AuthView
@synthesize activity;
@synthesize  delegate;
@synthesize registrView, registrLabel, emailField, sendButton;
@synthesize mainauthView, authView;
@synthesize authLabel, loginField, passwordField;
@synthesize signinButton, registrButton, exitButton;

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
    [self fillAllFieldsLocalized];
    authView.layer.cornerRadius = 10.0;
   
    registrView.layer.cornerRadius = 10.0;
    [mainauthView addSubview:registrView];
    [registrView setFrame:CGRectMake(5.0, 6.0, 310.0, 404.0)];
    [authView setHidden:false];
    [registrView setHidden:true];
}

- (void)viewDidUnload
{
    delegate = nil;
    [self setAuthView:nil];
    [self setAuthLabel:nil];
    [self setLoginField:nil];
    [self setPasswordField:nil];
    [self setSigninButton:nil];
    [self setRegistrButton:nil];
    [self setExitButton:nil];
    [self setRegistrView:nil];
    [self setEmailField:nil];
    [self setSendButton:nil];
    [self setRegistrLabel:nil];
    [self setMainauthView:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}

- (void) fillAllFieldsLocalized {
    [activity setHidden: true];
    authLabel.text = NSLocalizedString(@"Auth", @"");
    loginField.placeholder = NSLocalizedString(@"Login", @"");
    passwordField.placeholder =  NSLocalizedString(@"Password", @"");
    registrLabel.text = NSLocalizedString(@"Registration", @"");
    
}

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [authView release];
    [authLabel release];
    [loginField release];
    [passwordField release];
    [signinButton release];
    [registrButton release];
    [exitButton release];
    [registrView release];
    [emailField release];
    [sendButton release];
    [registrLabel release];
    [mainauthView release];
    [activity release];
    [super dealloc];
}
- (IBAction)registrButtonClick:(id)sender {
    [registrView setHidden:NO];
    [authView setHidden:YES];
}

- (IBAction)backToAuthButtonClick:(id)sender {
    [registrView setHidden:YES];
    [authView setHidden:NO];
    
}


- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpr
                                                                           options:NSRegularExpressionSearch 
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive 
                                        range:NSMakeRange(0, str.length)]; 
    
    NSLog(@"match loc: %d", matches.count);
    
    if (error) {
        NSLog(@"%@", error);
        return NO;
    } else {    
        return (matches.count==0)? NO : YES;
    }    
}



- (IBAction)signinButtonClick:(id)sender {
    [self hideKeyboard:passwordField];
    [self hideKeyboard:loginField];
    if (![loginField.text isEqualToString:@""] && ![passwordField.text isEqualToString:@""] &&![self checkCorrFillField:emailField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]){
        
        [activity setHidden: false];
        [activity startAnimating];
        
        NSURL *signinrUrl = [NSURL URLWithString:@"https://vitaportal.ru"];
        id	context = nil;
        NSMutableURLRequest *requestSigninMedarhiv = [NSMutableURLRequest requestWithURL:signinrUrl 
                                                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                                         timeoutInterval:30.0];
        
       // TODO: change request 
       // [requestSigninMedarhiv setHTTPMethod:@"POST"];
       // [requestSigninMedarhiv setHTTPBody:[[NSString stringWithFormat:@"cmd=srv&action=auth&email=%@&pass=%@", usernameField.text, passwordField.text] dataUsingEncoding:NSWindowsCP1251StringEncoding]]; 
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                             action:@selector(handleResultOrError:withContext:)
                                                            context:context] autorelease];
        
        NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestSigninMedarhiv delegate:network];
        [conn start];
    } else{
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];   
    }        
}


- (IBAction)regsendButtonClick:(id)sender {    
    [self hideKeyboard:emailField];
   
    if (![emailField.text isEqualToString:@""] && ![self checkCorrFillField:emailField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"] ){
        [activity setHidden: false];
        [activity startAnimating];
        
        NSURL *signinrUrl = [NSURL URLWithString:@"https://vitaportal.ru"];
        id	context = nil;
        NSMutableURLRequest *requestSigninMedarhiv = [NSMutableURLRequest requestWithURL:signinrUrl 
                                                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                                         timeoutInterval:30.0];
        
        // TODO: change request 
        // [requestSigninMedarhiv setHTTPMethod:@"POST"];
        // [requestSigninMedarhiv setHTTPBody:[[NSString stringWithFormat:@"cmd=srv&action=auth&email=%@&pass=%@", usernameField.text, passwordField.text] dataUsingEncoding:NSWindowsCP1251StringEncoding]]; 
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                             action:@selector(handleResultOrError:withContext:)
                                                            context:context] autorelease];
        
        NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestSigninMedarhiv delegate:network];
        [conn start];
    } else{
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];   
    }     
}


- (void)handleResultOrError:(id)resultOrError withContext:(id)context
{    
    if ([resultOrError isKindOfClass:[NSError class]])
	{    
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
        [activity stopAnimating]; 
        [activity setHidden:true];
		return; 
	}
    
	//NSURLResponse* response = [resultOrError objectForKey:@"response"];
	NSData* data = [resultOrError objectForKey:@"data"];
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    NSLog(@"key: %@", res);
    // TODO: доделать парсинг
    if ([[res objectForKey:@"result"] intValue]==1){
        // TODO: add alert Welcome
        delegate.user_fio = [res objectForKey:@"fio"];
        delegate.user_id = [res objectForKey:@"userID"] ;
        delegate.auth = (NSString*)[[res objectForKey:@"result"] stringValue]; 
        delegate.user_login = loginField.text;
        delegate.user_pass = passwordField.text;
        delegate.agreement = @"0";
        [delegate saveModuleData];
        
       
       // TODO: open AdviceView
        
    } else {        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Wrong username or password. Check the entered data.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];        
    }
    [activity stopAnimating]; 
    [activity setHidden:true];
}

@end
