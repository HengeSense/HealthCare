//
//  VitaportalViewController.h
//  SelfHub
//
//  Created by Igor Barinov on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ModuleHelper.h"
#import "Htppnetwork.h"
#import "adviceParse.h"
#import "AuthView.h"
#import "AllAdvicesView.h"
#import "AgreementView.h"


@interface Vitaportal : UIViewController <ModuleProtocol>{
    
    NSString *user_fio;
    NSString *user_id;
    NSString *auth;
    NSString *user_login;
    NSString *user_pass;
    NSString *agreement;
    NSMutableDictionary *moduleData;
    
    NSArray *viewControllers;
    NSUInteger currentlySelectedViewController;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (retain, nonatomic) IBOutlet UIView *moduleView;
@property (retain, nonatomic) IBOutlet UIView *hostView;

@property (nonatomic, retain) NSString *user_fio;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *auth;
@property (nonatomic, retain) NSString *user_login;
@property (nonatomic, retain) NSString *user_pass;
@property (nonatomic, retain) NSString *agreement;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSArray *viewControllers;

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;
@property (retain, nonatomic) IBOutlet UIButton *authButton;

//////
@property (retain, nonatomic) IBOutlet NSString *user_string;

- (NSString *)getBaseDir;
- (IBAction)showSlidingMenu:(id)sender;
- (IBAction)hideSlidingMenu:(id)sender;
- (IBAction)selectScreenFromMenu:(id)sender;

@end
