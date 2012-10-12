//
//  SelectionUserView.h
//  SelfHub
//
//  Created by Anton on 08.10.12.
//
//

#import <UIKit/UIKit.h>
#import "Withings.h"
#import "CustomCell.h"
#import "WBSAPIUser.h"
#import <QuartzCore/QuartzCore.h> //;


@class Withings;
@interface SelectionUserView : UIViewController{
  NSArray *Userlist;
}

@property (retain, nonatomic) IBOutlet UIButton *exitButton;
@property (retain, nonatomic) IBOutlet UITableView *UsersTableView;
@property (retain, nonatomic) IBOutlet UIView *FooterView;

@property (nonatomic, retain) NSArray *Userlist;

@property (nonatomic, assign) Withings *delegate;

- (IBAction)clickExitButton:(id)sender;
@end
