//
//  WeightControlSettings.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControl.h"
#import "WeightControlAddRecordRulerScroll.h"

@class WeightControl;
@class WeightControlAddRecordRulerScroll;

@interface WeightControlSettings : UIViewController <UIScrollViewDelegate>{
    
};

@property (nonatomic, assign) WeightControl *delegate;

@property (nonatomic, retain) IBOutlet UILabel *aimLabel;
@property (nonatomic, retain) IBOutlet WeightControlAddRecordRulerScroll *rulerScroll;
@property (nonatomic, retain) IBOutlet UILabel *heightLabel;
@property (nonatomic, retain) IBOutlet UILabel *ageLabel;

- (IBAction)pressChangeAntropometryValues:(id)sender;

@end
