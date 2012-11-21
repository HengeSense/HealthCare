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

@interface WithingsCustomCell : UITableViewCell
@property (nonatomic, assign) LoginWithingsViewController *selectUserTarget;

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) WBSAPIUser *inf;
@property (retain, nonatomic) IBOutlet UIButton *ImortButton;
@property (retain, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic, readwrite) CGPoint startPosition;
@property (nonatomic, readwrite) CGPoint endPosition;
@property (retain, nonatomic) IBOutlet UIView *gestureView;
@property (retain, nonatomic) IBOutlet UIView *gestureViewhide;


- (IBAction)importButtonClick:(id)sender;
- (IBAction)touchSelectBut:(id)sender;
- (IBAction)touchImportBut:(id)sender;

@end
