//
//  ViewController.m
//  SelfHub
//
//  Created by Mac on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"

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
    
    UIImage *loginBackgroundImageBig = [UIImage imageNamed:@"DesktopBackgroundPortrait.png"];
    UIImage *loginBackgroundImage = [[UIImage alloc] initWithCGImage:[loginBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    self.logInView.backgroundColor = [UIColor colorWithPatternImage:loginBackgroundImage];
    [loginBackgroundImage release];
    
    UILabel *selfHubLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 50.0, 200.0, 40.0)];
    selfHubLabel.text = @"Healthcare";
    selfHubLabel.backgroundColor = [UIColor clearColor];
    [selfHubLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0]];
    selfHubLabel.textColor = [UIColor whiteColor];
    selfHubLabel.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    selfHubLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.logInView addSubview:selfHubLabel];
    [selfHubLabel release];
    
    [self.logInView.logo setHidden:true];
    // Change button apperance
    [self.logInView.dismissButton setHidden:true];
    [self.logInView.passwordForgottenButton setHidden:true];
    
    [self.logInView.usernameField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:104.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    self.logInView.usernameField.backgroundColor = [UIColor whiteColor];
    self.logInView.usernameField.placeholder = NSLocalizedString(@"Login", @"");
    
    
    [self.logInView.passwordField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:104.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    self.logInView.passwordField.backgroundColor = [UIColor whiteColor];
    self.logInView.passwordField.returnKeyType = UIReturnKeyDefault;
    self.logInView.passwordField.placeholder = NSLocalizedString(@"Password", @"");
    
    UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 12.0, 105.0, 20.0)];
    loginLabel.textAlignment = UITextAlignmentCenter;
    loginLabel.text = NSLocalizedString(@"SignIn", @"");
    loginLabel.backgroundColor = [UIColor clearColor];
    [loginLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0]];
    loginLabel.textColor = [UIColor whiteColor];
    loginLabel.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    loginLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.logInView.logInButton addSubview:loginLabel];
    [loginLabel release];
    
    self.logInView.externalLogInLabel.text = NSLocalizedString(@"parseFBTlabel", @"");
    self.logInView.signUpLabel.text = NSLocalizedString(@"SignOutLabel", @"");
    
    UILabel *signupLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 12.0, 180.0, 20.0)];
    signupLabel.textAlignment = UITextAlignmentCenter;
    signupLabel.text = NSLocalizedString(@"SignUp", @"");
    signupLabel.backgroundColor = [UIColor clearColor];
    [signupLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0]];
    signupLabel.textColor = [UIColor whiteColor];
    signupLabel.shadowColor = [UIColor colorWithRed:26.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0];
    signupLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.logInView.signUpButton addSubview:signupLabel];
    [signupLabel release];
    
    
    
    // add SignUpViewController
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    [signUpViewController setFields:PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsAdditional  |PFSignUpFieldsSignUpButton | PFSignUpFieldsEmail];
    [self setSignUpController:signUpViewController];
    [signUpViewController release];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect fieldFrame = self.logInView.usernameField.frame;
    [self.logInView.usernameField setFrame: CGRectMake(fieldFrame.origin.x, 120.0, fieldFrame.size.width, fieldFrame.size.height)];
    [self.logInView.passwordField setFrame: CGRectMake(fieldFrame.origin.x, 168.0, fieldFrame.size.width, fieldFrame.size.height)];
    [self.logInView.logInButton setFrame: CGRectMake(self.logInView.logInButton.frame.origin.x, 216.0, self.logInView.logInButton.frame.size.width, self.logInView.logInButton.frame.size.height)];
    
    [self.logInView.logInButton setImage:[UIImage imageNamed:@"logInButton_norm@2x.png"] forState:UIControlStateNormal];
    [self.logInView.logInButton setImage:[UIImage imageNamed:@"logInButton_press@2x.png"] forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setImage:[UIImage imageNamed:@"signUpButton_norm@2x.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setImage:[UIImage imageNamed:@"signUpButton_press@2x.png"] forState:UIControlStateHighlighted];
    
    [self.logInView.externalLogInLabel setFrame: CGRectMake(self.logInView.externalLogInLabel.frame.origin.x, 286.0, self.logInView.externalLogInLabel.frame.size.width, self.logInView.externalLogInLabel.frame.size.height)];
    
    [self.logInView.facebookButton setFrame: CGRectMake(self.logInView.facebookButton.frame.origin.x, 307.0, self.logInView.facebookButton.frame.size.width, self.logInView.facebookButton.frame.size.height)];
    
    [self.logInView.twitterButton setFrame: CGRectMake(self.logInView.twitterButton.frame.origin.x, 307.0, self.logInView.twitterButton.frame.size.width, self.logInView.twitterButton.frame.size.height)];
    
    [self.logInView.signUpLabel setFrame: CGRectMake(self.logInView.signUpLabel.frame.origin.x, 375.0, self.logInView.signUpLabel.frame.size.width, self.logInView.signUpLabel.frame.size.height)];
    
    [self.logInView.signUpButton setFrame: CGRectMake(self.logInView.signUpButton.frame.origin.x, 395.0, self.logInView.signUpButton.frame.size.width, self.logInView.signUpButton.frame.size.height)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
    return NO; // Interrupt login process
}


-(void) logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [applicationDelegate performSuccessLogin];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    //NSLog(@"error, %@", error);
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    // [self.navigationController popViewControllerAnimated:YES];
    
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
    
    if(![password isEqualToString: confpassword]){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill correctly fields Password and Confirm Password.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
        informationComplete = NO;
    } else if (!informationComplete) {
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [signUpController dismissViewControllerAnimated:YES completion:NULL];
    [self cleanFields:signUpController];
    [applicationDelegate performSuccessLogin];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) cleanFields: (PFSignUpViewController*)signUpController {
    signUpController.signUpView.usernameField.text = @"";
    signUpController.signUpView.passwordField.text = @"";
    signUpController.signUpView.additionalField.text = @"";
    signUpController.signUpView.emailField.text = @"";
}

@end
