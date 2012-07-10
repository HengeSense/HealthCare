//
//  MySignUpViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation SignUpViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.signUpView setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.logo setHidden:true];
    // Change button apperance
    [self.signUpView.dismissButton setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.signUpButton setBackgroundColor:[UIColor grayColor]];
    [self.signUpView.signUpButton setTitle:@"Sign up" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"Sign up" forState:UIControlStateHighlighted];
    
    // Add background for fields
    [self.signUpView insertSubview:fieldsBackground atIndex:1];
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.additionalField.layer;
    layer.shadowOpacity = 0.0f;
    
       
    [self.signUpView.usernameField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.usernameField setBackgroundColor: [UIColor whiteColor]];
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [self.signUpView.passwordField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [self.signUpView.additionalField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.additionalField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [self.signUpView.additionalField setPlaceholder:@"Confirm password"];
    //[self.signUpView.additionalField 
    self.signUpView.additionalField.returnKeyType = UIReturnKeyDefault;
    self.signUpView.additionalField.secureTextEntry = TRUE;
    
   
    [self.signUpView.emailField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; 
    return true;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect fieldFrame = self.signUpView.usernameField.frame;    
    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x, 230 , fieldFrame.size.width, fieldFrame.size.height)];
    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x, 275, fieldFrame.size.width,fieldFrame.size.height)]; 
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
