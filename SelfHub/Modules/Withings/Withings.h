//
//  Withings.h
//  SelfHub
//
//  Created by Igor Barinov on 10/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import "Htppnetwork.h"
#import <QuartzCore/QuartzCore.h>
#import "DataLoadWithingsViewController.h"
#import "LoginWithingsViewController.h"
#import "Reachability.h"
#import "TTTAttributedLabel.h"

@interface Withings : UIViewController <ModuleProtocol>{
    NSMutableDictionary *moduleData;
    NSArray *viewControllers;
    NSUInteger currentlySelectedViewController;
    UIImage *tutorialBackgroundImages;
        
    int lastuser;
    int lastTime;
    int userID;
    int expNotifyDate;
    NSString *auth;
    NSString *notify;
    NSString *userPublicKey;
    NSString *user_firstname;
    NSDictionary *listOfUsers;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, retain) NSString *auth;
@property (nonatomic, retain) NSString *userPublicKey;
@property (readwrite, nonatomic) int lastuser;
@property (readwrite, nonatomic) int lastTime;
@property (readwrite, nonatomic) int userID;
@property (readwrite, nonatomic) int expNotifyDate;
@property (nonatomic, retain) NSString *notify;
@property (nonatomic, retain) NSString *user_firstname;
@property (nonatomic, retain) NSDictionary *listOfUsers;

@property (retain, nonatomic) IBOutlet UIView *moduleView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;
@property (retain, nonatomic) IBOutlet UIView *hostView;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;

@property (nonatomic, retain) UIButton *tutorialButton;

- (IBAction)selectScreenFromMenu:(id)sender;
- (IBAction)logoutButtonClick:(id)sender;
- (BOOL) checkAndTurnOnNotification;

//- (void)fillAllFieldsLocalized;

@end
