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
    
    // Set text colol
   
    [self.signUpView.usernameField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.usernameField setBackgroundColor: [UIColor whiteColor]];
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [self.signUpView.passwordField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.passwordField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [self.signUpView.emailField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.emailField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [self.signUpView.additionalField setBorderStyle: UITextBorderStyleRoundedRect];
    [self.signUpView.additionalField setBackgroundColor:[UIColor whiteColor]];
    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    // Change "Additional" to match our use
    [self.signUpView.additionalField setPlaceholder:@"Phone number"];
    
}

//- (void)viewDidLayoutSubviews {
//    // Set frame for elements
//    [self.signUpView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
//    [self.signUpView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
//    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, 134.0f+30.0f, 250.0f, 174.0f)];
//    
//    // Move all fields down
//    float yOffset = 0.0f;
//    CGRect fieldFrame = self.signUpView.usernameField.frame;
//    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x+5.0f, 
//                                                       fieldFrame.origin.y+30.0f+yOffset, 
//                                                       fieldFrame.size.width-10.0f, 
//                                                       fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x+5.0f, 
//                                                       fieldFrame.origin.y+30.0f+yOffset, 
//                                                       fieldFrame.size.width-10.0f, 
//                                                       fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x+5.0f, 
//                                                    fieldFrame.origin.y+30.0f+yOffset, 
//                                                    fieldFrame.size.width-10.0f, 
//                                                    fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x+5.0f, 
//                                                         fieldFrame.origin.y+30.0f+yOffset, 
//                                                         fieldFrame.size.width-10.0f, 
//                                                         fieldFrame.size.height)];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
