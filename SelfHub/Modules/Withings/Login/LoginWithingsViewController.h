//
//  LoginWithingsViewController.h
//  SelfHub
//
//  Created by Anton on 10.10.12.
//
//

#import <UIKit/UIKit.h>
#import "Withings.h"
#import "WorkWithWithings.h"
#import "CustomCell.h"

//#import "TestViewController.h"

@class Withings;
@interface LoginWithingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    NSArray *Userlist;
}

@property (nonatomic, assign) Withings *delegate;

@property (retain, nonatomic) IBOutlet UILabel *headerLabel;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;

@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;

@property (retain, nonatomic) IBOutlet UIView *actView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (retain, nonatomic) IBOutlet UILabel *actLabel;

@property (retain, nonatomic) IBOutlet UILabel *loginLabel;
@property (retain, nonatomic) IBOutlet UITextField *loginTextField;
@property (retain, nonatomic) IBOutlet UIControl *mainLoginView;
@property (retain, nonatomic) IBOutlet UIButton *exitButton;
@property (retain, nonatomic) IBOutlet UITableView *usersTableView;
@property (retain, nonatomic) IBOutlet UIView *mainSelectionUserView;
@property (retain, nonatomic) IBOutlet UIView *mainHostLoginView;
@property (retain, nonatomic) IBOutlet UILabel *ErrorLabel;



- (IBAction)hideKeyboard:(id)sender;
- (IBAction)registrButtonClick:(id)sender;
- (IBAction)exitButtonClick:(id)sender;
-(void) cleanup;

@end
