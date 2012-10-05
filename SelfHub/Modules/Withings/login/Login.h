//
//  Login.h
//  SelfHub
//
//  Created by Anton on 04.10.12.
//
//

#import <UIKit/UIKit.h>
#import "Withings.h"

@class Withings;
@interface Login : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *headerLabel;

@property (retain, nonatomic) IBOutlet UIView *passwordView;
@property (retain, nonatomic) IBOutlet UILabel *passwordLabel;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;

@property (retain, nonatomic) IBOutlet UIView *loginView;
@property (retain, nonatomic) IBOutlet UILabel *loginLabel;
@property (retain, nonatomic) IBOutlet UITextField *loginTextField;

@property (retain, nonatomic) IBOutlet UIView *actView;
@property (retain, nonatomic) IBOutlet UILabel *actLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activity;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)registrButtonClick:(id)sender;

@property (nonatomic, assign) Withings *delegate;


@end
