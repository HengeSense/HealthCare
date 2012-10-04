//
//  AgrmAndAuthViewController.h
//  SelfHub
//
//  Created by Igor Barinov on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "Vitaportal.h"
#import "Htppnetwork.h"
#import "VitaParse.h"

@class Vitaportal;

@interface AuthView : UIViewController <VitaParseDelegate>

@property (nonatomic, assign) Vitaportal *delegate;

@property (retain, nonatomic) IBOutlet UIView *mainauthView;

@property (retain, nonatomic) IBOutlet UIView *authView;
@property (retain, nonatomic) IBOutlet UILabel *authLabel;
@property (retain, nonatomic) IBOutlet UITextField *loginField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UIButton *signinButton;
@property (retain, nonatomic) IBOutlet UIButton *registrButton;
@property (retain, nonatomic) IBOutlet UIButton *exitButton;
@property (retain, nonatomic) IBOutlet UIButton *exitAuthButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activity;


@property (retain, nonatomic) IBOutlet UIView *registrView;
@property (retain, nonatomic) IBOutlet UILabel *registrLabel;
@property (retain, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;


- (IBAction)hideKeyboard:(id)sender;
- (IBAction)registrButtonClick:(id)sender;
- (IBAction)backToAuthButtonClick:(id)sender;
- (IBAction)signinButtonClick:(id)sender;
- (IBAction)regsendButtonClick:(id)sender;
- (IBAction)exitButtonClick:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)forgotPassPressed:(id)sender;

- (void)regEmailSend;

@end
