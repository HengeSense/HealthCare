//
//  CustomCell.h
//  SelfHub
//
//  Created by Anton on 08.10.12.
//
//

#import <UIKit/UIKit.h>
#import "WBSAPIUser.h"
#import "LoginWithingsViewController.h"


@class LoginWithingsViewController;

@interface CustomCell : UITableViewCell
@property (nonatomic, assign) LoginWithingsViewController *selectUserTarget;

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) WBSAPIUser *inf;
@property (retain, nonatomic) IBOutlet UIButton *ImortButton;
@property (retain, nonatomic) IBOutlet UIButton *selectButton;

- (IBAction)selectButtonClick:(id)sender;
- (IBAction)importButtonClick:(id)sender;

@end
