//
//  AgreementView.h
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "Vitaportal.h"

@class Vitaportal;
@interface AgreementView : UIViewController

@property (nonatomic, assign) Vitaportal *delegate;
@property (retain, nonatomic) IBOutlet UIView *agreeView;
@property (retain, nonatomic) IBOutlet UIButton *acceptButton;
@property (retain, nonatomic) IBOutlet UIButton *notacceptButton;
@property (retain, nonatomic) IBOutlet UIScrollView *agrScrollView;
@property (retain, nonatomic) IBOutlet UILabel *agreeLabell;


- (IBAction)acceptButtonClick:(id)sender;
- (IBAction)notacceptButtonClick:(id)sender;



@end

