//
//  AppDelegate.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BottomPanelViewController.h"
#import "SelfhubNavigationController.h"
#import "InfoViewController.h"
#import "ModuleHelper.h"
#import "LoginViewController.h"

@class DesktopViewController;
@class InfoViewController;
@class ModuleProtocol;
@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) DesktopViewController *desktopViewController;
@property (nonatomic, retain) UIViewController *activeModuleViewController;

- (void)showSlideMenu;
- (void)updateMenuSliderImage;
- (void)hideSlideMenu;

- (void)performSuccessLogin;
- (void)performLogout;


@end
