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
#import "WeightControlChartSmoothLabel.h"

@class WeightControl;
@class WeightControlAddRecordRulerScroll;
@class WeightControlChartSmoothLabel;

@interface WeightControlSettings : UIViewController <UIScrollViewDelegate>{
    
};

@property (nonatomic, assign) WeightControl *delegate;

@property (nonatomic, retain) IBOutlet UILabel *aimLabel;
@property (nonatomic, retain) IBOutlet WeightControlAddRecordRulerScroll *rulerScroll;
@property (nonatomic, retain) IBOutlet WeightControlChartSmoothLabel *moduleSmoothLabel;
@property (nonatomic, retain) IBOutlet UILabel *heightLabel;
@property (nonatomic, retain) IBOutlet UILabel *ageLabel;
@property (nonatomic, retain) IBOutlet ButtonWithLabel *goToProfileButton;

@property (nonatomic, retain) IBOutlet UILabel *showNormLabel;
@property (nonatomic, retain) IBOutlet UISwitch *showNormSwitch;

@property (nonatomic, retain) IBOutlet UILabel *parametersFromLabel;
@property (nonatomic, retain) IBOutlet UILabel *yourHeightLabel;
@property (nonatomic, retain) IBOutlet UILabel *yourAgeLabel;



- (IBAction)pressChangeAntropometryValues:(id)sender;
- (IBAction)onChangeShowNormParametr:(id)sender;


@end
