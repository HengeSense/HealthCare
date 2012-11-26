//
//  RegistrationCell.h
//  SelfHub
//
//  Created by Igor Barinov on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignUpMedarhivViewController.h"

@class SignUpMedarhivViewController;

@interface RegistrationCell : UITableViewCell{
   //UITextField *regFiled;
}

@property (nonatomic, assign) SignUpMedarhivViewController *changeDateTarget;

@property (retain, nonatomic) IBOutlet UITextField *regFiled;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *birthLabel;

@end
