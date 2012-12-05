//
//  CustomCell.h
//  SelfHub
//
//  Created by ET on 08.10.12.
//
//

#import <UIKit/UIKit.h>
#import "WBSAPIUser.h"
#import "LoginWithingsViewController.h"


@class LoginWithingsViewController;

@interface WithingsCustomCell : UITableViewCell
@property (nonatomic, assign) LoginWithingsViewController *selectUserTarget;

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) WBSAPIUser *inf;
@property (retain, nonatomic) IBOutlet UILabel *puchLabel;
@property (retain, nonatomic) IBOutlet UISwitch *pushSwitch;
- (IBAction)pushSwitchStateChanged:(id)sender;

@end
