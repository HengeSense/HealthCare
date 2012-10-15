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
    
    NSString *auth;
    int lastuser;
    int lastTime;
    int userID;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, retain) NSString *auth;
@property (readwrite, nonatomic) int lastuser;
@property (readwrite, nonatomic) int lastTime;
@property (readwrite, nonatomic) int userID;

@property (retain, nonatomic) IBOutlet UIView *moduleView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;
@property (retain, nonatomic) IBOutlet UIView *hostView;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;

- (IBAction)selectScreenFromMenu:(id)sender;
- (IBAction)logoutButtonClick:(id)sender;



//- (void)fillAllFieldsLocalized;

@end
