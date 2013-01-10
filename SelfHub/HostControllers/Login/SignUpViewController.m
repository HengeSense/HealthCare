//
//  MySignUpViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation SignUpViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *loginBackgroundImageBig = [UIImage imageNamed:@"DesktopBackgroundPortrait.png"];
    UIImage *loginBackgroundImage = [[UIImage alloc] initWithCGImage:[loginBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    self.signUpView.backgroundColor = [UIColor colorWithPatternImage:loginBackgroundImage];
    [loginBackgroundImage release];
    
    UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIImage *navBarBackgroundImageBig = [UIImage imageNamed:@"DesktopNavBarBackground@2x.png"];
    UIImage *navBarBackgroundImage = [[UIImage alloc] initWithCGImage:[navBarBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    [naviBarObj setBackgroundImage:navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [navBarBackgroundImage release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];    
    backButton.frame = CGRectMake(0.0, 0.0, 62.0, 32.0);
    [backButton setImage:[UIImage imageNamed:@"DesktopBackButton.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"DesktopBackButton_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *backButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 6.0, 50.0, 20.0)];
    backButtonLabel.textAlignment = UITextAlignmentCenter;
    backButtonLabel.text = NSLocalizedString(@"Back", @"");
    backButtonLabel.backgroundColor = [UIColor clearColor];
    [backButtonLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    [backButtonLabel setHighlighted:YES];
    [backButtonLabel setHighlightedTextColor:[UIColor colorWithRed:175.0f/255.0f green:177.0f/255.0f blue:181.0f/255.0f alpha:1.0]];
    backButtonLabel.textColor = [UIColor whiteColor];
    backButtonLabel.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    backButtonLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [backButton addSubview:backButtonLabel];
    [backButtonLabel release];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@""];   
    navigItem.leftBarButtonItem = leftBarButtonItem;
    naviBarObj.items = [NSArray arrayWithObjects: navigItem,nil];
    [leftBarButtonItem release];
    
    [self.signUpView addSubview:naviBarObj];
    [navigItem release];
    [naviBarObj release];
    
    [self.signUpView.dismissButton setHidden:true];
    [self.signUpView.logo setHidden:true];
    
   
    UILabel *signupLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 12.0, 180.0, 20.0)];
    signupLabel.textAlignment = UITextAlignmentCenter;
    signupLabel.text = NSLocalizedString(@"SignUp", @"");
    signupLabel.backgroundColor = [UIColor clearColor];
    [signupLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0]];
    signupLabel.textColor = [UIColor whiteColor];
    signupLabel.shadowColor = [UIColor colorWithRed:26.0f/255.0f green:98.0f/255.0f blue:11.0f/255.0f alpha:1.0];
    signupLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.signUpView.signUpButton addSubview:signupLabel];
    [signupLabel release];
       
    [self.signUpView.usernameField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:104.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    self.signUpView.usernameField.backgroundColor = [UIColor whiteColor];
    self.signUpView.usernameField.placeholder = NSLocalizedString(@"Login", @"");
    
    [self.signUpView.passwordField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:104.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    self.signUpView.passwordField.backgroundColor = [UIColor whiteColor];
    self.signUpView.passwordField.returnKeyType = UIReturnKeyDefault;
    self.signUpView.passwordField.placeholder = NSLocalizedString(@"Password", @"");
    
    [self.signUpView.additionalField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.additionalField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:104.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    
    [self.signUpView.additionalField setPlaceholder:NSLocalizedString(@"Confirm Password",@"")];
    //[self.signUpView.additionalField 
    self.signUpView.additionalField.returnKeyType = UIReturnKeyDefault;
    self.signUpView.additionalField.secureTextEntry = TRUE;
    
    [self.signUpView.emailField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:104.0f/255.0f green:104.0f/255.0f blue:104.0f/255.0f alpha:1.0]];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; 
    return true;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
 
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x, 112.0 , fieldFrame.size.width, fieldFrame.size.height)];
    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x, 160.0 , fieldFrame.size.width, fieldFrame.size.height)];
    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x, 208.0 , fieldFrame.size.width, fieldFrame.size.height)];
    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x, 256.0, fieldFrame.size.width,fieldFrame.size.height)];
    [self.signUpView.signUpButton setFrame:CGRectMake(self.signUpView.signUpButton.frame.origin.x, 364.0, self.signUpView.signUpButton.frame.size.width, self.signUpView.signUpButton.frame.size.height)];
    
    [self.signUpView.signUpButton setImage:[UIImage imageNamed:@"signUpButton_norm@2x.png"] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setImage:[UIImage imageNamed:@"signUpButton_press@2x.png"] forState:UIControlStateHighlighted];
}

- (void) backButtonAction {
    [self dismissModalViewControllerAnimated:true];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
