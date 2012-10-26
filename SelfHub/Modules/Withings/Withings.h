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

@interface Withings : UIViewController <ModuleProtocol>{
    NSMutableDictionary *moduleData;
    NSArray *viewControllers;
    NSUInteger currentlySelectedViewController;
        
    int lastuser;
    int lastTime;
    int userID;
    NSString *auth;
    NSString *notify;
    NSString *userPublicKey;
    NSString *user_login;
    NSString *user_pass;
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
@property (nonatomic, retain) NSString *notify;
@property (nonatomic, retain) NSDictionary *listOfUsers;

@property (retain, nonatomic) IBOutlet UIView *moduleView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;
@property (retain, nonatomic) IBOutlet UIView *hostView;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;
@property (retain, nonatomic) IBOutlet UIButton *synchNotificationButton;

- (IBAction)selectScreenFromMenu:(id)sender;
- (IBAction)logoutButtonClick:(id)sender;
- (IBAction)synchNotificationButtonClick:(id)sender;



//- (void)fillAllFieldsLocalized;

@end
