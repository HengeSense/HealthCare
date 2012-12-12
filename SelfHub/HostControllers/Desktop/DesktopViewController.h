//
//  ViewController.h
//  HealthCare
//
//  Created by Eugine Korobovsky on 16.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import "AppDelegate.h"

@class AppDelegate;

@interface DesktopViewController : UIViewController <ServerProtocol, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>{
    NSArray *modulesArray;
    NSMutableArray *filteredModulesArray;
    
    BOOL largeIcons;
}

@property (nonatomic, retain) NSIndexPath *lastSelectedIndexPath;

//suporting slide-out navigation
@property (nonatomic, retain) UIView *slidingImageView;
@property (nonatomic, retain) UIImageView *screenshotImage;

@property (nonatomic, assign) AppDelegate *applicationDelegate;
@property (nonatomic, retain) IBOutlet UITableView *modulesTable;


- (void)initialize;

- (UIViewController *)getMainModuleViewController;
//- (NSUInteger)getRowForCurrentModuleInTebleView;
- (void)changeSelectionToIndexPath:(NSIndexPath *)needIndexPath;
- (void)showSlideMenu;
- (void)hideSlideMenu;

- (BOOL)isSearchModeForTable:(UITableView *)tableView;
- (void) recieveRemotePushNotification:(NSDictionary*) userInfo;

- (void)handleMemoryWarningNotification;

@end
