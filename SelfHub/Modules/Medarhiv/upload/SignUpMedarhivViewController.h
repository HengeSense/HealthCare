//
//  SignUpMedarhivViewController.h
//  SelfHub
//
//  Created by Igor Barinov on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Medarhiv.h"
#import "Cells/RegistrationCell.h"
#import "Htppnetwork.h"

@class Medarhiv;

@interface SignUpMedarhivViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>{
    
}


@property (nonatomic, assign) Medarhiv *delegate; 

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UITableView *tableViewReg;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityReg;
@property (retain, nonatomic) IBOutlet UILabel *registrationLabel;
@property (retain, nonatomic) IBOutlet UIView *birthdaySelectorView;
@property (retain, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@property (retain, nonatomic) IBOutlet UIButton *doneBirthButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelBirthButton;
@property (nonatomic, retain) NSDate *realBirthday;


- (IBAction)pressSelectBirthday;
- (IBAction)doneButtonPressed:(id)sender;
- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr;
- (IBAction)BackButtonAction;
- (IBAction)doneButtonClick:(id)sender;

@end
