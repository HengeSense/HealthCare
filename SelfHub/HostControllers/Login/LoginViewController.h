//
//  ViewController.h
//  SelfHub
//
//  Created by Mac on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class AppDelegate;

@interface LoginViewController : UIViewController

@property (nonatomic, assign) AppDelegate *applicationDelegate;

- (IBAction)pressEnterWithFacebook:(id)sender;
@end
