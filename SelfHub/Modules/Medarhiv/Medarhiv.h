//
//  Medarhiv.h
//  SelfHub
//
//  Created by Elena Trishina on 7/10/12.
//  Copyright (c) 2012 __HintSolutions__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import "Htppnetwork.h"
#import "LoadViewController.h"
#import "SignUpMedarhivViewController.h"
#import <QuartzCore/QuartzCore.h>

//, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
@interface Medarhiv : UIViewController <ModuleProtocol>{
    NSArray *viewControllers;
    
    NSString *user_fio;
    NSString *user_id;
    NSString *auth;
    NSString *user_login;
    NSString *user_pass;
    NSMutableDictionary *moduleData;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;

- (void)fillAllFieldsLocalized;

@property (nonatomic, retain) IBOutlet UIView *moduleView;
@property (nonatomic, retain) IBOutlet UIView *hostView;
@property (nonatomic, retain) NSString *user_fio;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *auth;
@property (nonatomic, retain) NSString *user_login;
@property (nonatomic, retain) NSString *user_pass;


// view Medarhiv.nib

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIImageView *brendImageView;
@property (retain, nonatomic) IBOutlet UINavigationItem *navItemTitle;

@property (retain, nonatomic) IBOutlet UIButton *slideButton;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;
//@property (nonatomic, retain) IBOutlet UITableView *tableViewSingin;
@property (nonatomic, retain) IBOutlet UILabel *medarhivLabel;
@property (nonatomic, retain) IBOutlet UILabel *signOutLabel;

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UIImageView *tableViewImageView;
@property (retain, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic, retain) IBOutlet UIButton *signInButton;
@property (nonatomic, retain) IBOutlet UIButton *signOutButton;

- (IBAction)pressSignInButton:(UIButton *)sender;
- (IBAction)PressSignOutButton:(UIButton *)sender;
- (IBAction)textFieldShouldReturn:(id)sender;
- (IBAction)showSlidingMenu:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)hideSlidingMenu:(id)sender;
- (NSString *)getBaseDir;



@end