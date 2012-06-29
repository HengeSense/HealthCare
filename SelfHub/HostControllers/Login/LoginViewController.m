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
    
    
    [self.logInView setBackgroundColor:[UIColor whiteColor]];
    [self.logInView.logo setHidden:true];
    // Change button apperance
    [self.logInView.dismissButton setHidden:true];
    [self.logInView.passwordForgottenButton setHidden:true];
    [self.logInView.usernameField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.logInView.usernameField setTextColor:[UIColor blackColor]];
    [self.logInView.passwordField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.logInView.passwordField setTextColor:[UIColor blackColor]];
   
    
//    [self.logInView.logInButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
    [self setSignUpController:signUpViewController]; 
    [signUpViewController release];    
    
}


//-(IBAction)loginButtonPressed:(PFUser *)sender{
//    NSLog(@"bnnn");     
//   //      
//     
//}


#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:self shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}


-(void) logInViewController:self didLogInUser:(PFUser *)user{
   NSLog(@"log in..."); 
   [applicationDelegate performSuccessLogin];
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
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
