//
//  ViewController.m
//  SelfHub
//
//  Created by Mac on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize applicationDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setFields: PFLogInFieldsDefault | PFLogInFieldsTwitter | PFLogInFieldsFacebook];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDelegate:self];
    
    
    UILabel *selfHubLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 50, 200, 40)];
    selfHubLabel.text = @"SelfHub";
    [selfHubLabel setFont:[UIFont systemFontOfSize:28]];
    [self.logInView addSubview:selfHubLabel];
    [selfHubLabel release];
    
    [self.logInView setBackgroundColor:[UIColor whiteColor]];
    [self.logInView.logo setHidden:true];
    // Change button apperance
    [self.logInView.dismissButton setHidden:true];
    [self.logInView.passwordForgottenButton setHidden:true];
    [self.logInView.usernameField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.logInView.usernameField setTextColor:[UIColor blackColor]];
    [self.logInView.passwordField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.logInView.passwordField setTextColor:[UIColor blackColor]];
    self.logInView.passwordField.returnKeyType = UIReturnKeyDefault;
    

    
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    [signUpViewController setFields:PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsAdditional  |PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton | PFSignUpFieldsEmail]; 
    [self setSignUpController:signUpViewController]; 
    [signUpViewController release]; 
        
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   [textField resignFirstResponder]; 
    return true;
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:self shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
    return NO; // Interrupt login process
}


-(void) logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
   NSLog(@"log in..."); 
   [applicationDelegate performSuccessLogin];
   [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:self didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:self {
   // [self.navigationController popViewControllerAnimated:YES];
     NSLog(@"log in screen is dismissed...");
}


#pragma mark - PFSignUpViewControllerDelegate
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    NSString *password = [info objectForKey:@"password"];
    NSString *confpassword = [info objectForKey:@"additional"];
    NSLog(@"pass:%@", password);
    NSLog(@"conf_pass:%@", confpassword);
    if(![password isEqualToString: confpassword]){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill correctly fields Password and Confirm Password.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
    } else if (!informationComplete) {
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
     [applicationDelegate performSuccessLogin];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
