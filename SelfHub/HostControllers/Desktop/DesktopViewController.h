//
//  ViewController.h
//  HealthCare
//
//  Created by Eugine Korobovsky on 16.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import "MainInformation.h"
#import "BottomPanelViewController.h"
#import "SelfhubNavigationController.h"
#import "AppDelegate.h"

@class AppDelegate;

@interface DesktopViewController : UIViewController <ServerProtocol, UITableViewDelegate, UITableViewDataSource>{
    NSArray *modulesArray;
    
    BOOL largeIcons;
}

//suporting slide-out navigation
@property (nonatomic, retain) UIImageView *slidingImageView;

@property (nonatomic, assign) AppDelegate *applicationDelegate;
@property (nonatomic, retain) IBOutlet UITableView *modulesTable;


- (void)initialize;

- (UIViewController *)getMainModuleViewController;
- (void)showSlideMenu;
- (void)hideSlideMenu;

@end
