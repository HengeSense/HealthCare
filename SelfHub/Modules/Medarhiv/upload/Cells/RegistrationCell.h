//
//  RegistrationCell.h
//  SelfHub
//
//  Created by Igor Barinov on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationCell : UITableViewCell{
   //UITextField *regFiled;
}

@property (retain, nonatomic) IBOutlet UITextField *regFiled;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *birthLabel;

@end
