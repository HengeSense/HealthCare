//
//  LoadDataController.h
//  SelfHub
//
//  Created by Igor Barinov on 10/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Withings.h"
#import "QuartzCore/QuartzCore.h"

@class Withings;
@interface LoadDataWithingsController : UIViewController{
   // NSString *username;  
}

@property (nonatomic, assign) Withings *delegate;

@property (retain, nonatomic) IBOutlet UIView *resultView;
@property (retain, nonatomic) IBOutlet UIView *resstatusView;
@property (retain, nonatomic) IBOutlet UILabel *resultTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *resultCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *resultWordLabel;
@property (retain, nonatomic) IBOutlet UIButton *resultShowButton;
@property (retain, nonatomic) IBOutlet UIButton *resultImportButton;
@property (retain, nonatomic) IBOutlet UILabel *receiveLabel;
@property (retain, nonatomic) IBOutlet UIButton *resultTryagainButton;
@property (retain, nonatomic) IBOutlet UIView *mainLoadView;
@property (retain, nonatomic) IBOutlet UIView *loadView;

- (IBAction)resultTryagainButtonClick:(id)sender;
- (IBAction)resultImportButtonClick:(id)sender;
- (IBAction)resultShowButtonClick:(id)sender;

@end
