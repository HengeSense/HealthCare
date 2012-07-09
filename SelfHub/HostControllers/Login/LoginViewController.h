//
//  ViewController.h
//  SelfHub
//
//  Created by Mac on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <Parse/PFLogInViewController.h>

@class AppDelegate;
//UIViewController
@interface LoginViewController : PFLogInViewController  <PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate>

@property (nonatomic, assign) AppDelegate *applicationDelegate;

@end
