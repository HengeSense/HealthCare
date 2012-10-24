//
//  DataLoadWithingsViewController.h
//  SelfHub
//
//  Created by Igor Barinov on 10/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Withings.h"
#import "QuartzCore/QuartzCore.h"
#import "WorkWithWithings.h"

@class Withings;

@interface DataLoadWithingsViewController : UIViewController{
    WorkWithWithings *workWithWithings ;
    NSDictionary *dataToImport;
   
}

@property (nonatomic, assign) Withings *delegate;
@property (retain, nonatomic) IBOutlet UIView *mainLoadView;
@property (retain, nonatomic) IBOutlet UIView *loadWView;
@property (retain, nonatomic) IBOutlet UIImageView *loadingImage;
@property (retain, nonatomic) IBOutlet UILabel *receiveLabel;



- (void)resultImportSend;
- (void) cleanup;

@end
