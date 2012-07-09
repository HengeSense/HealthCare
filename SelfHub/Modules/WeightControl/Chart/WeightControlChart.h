//
//  WeightControlChart.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControl.h"
#import "WeightControlQuartzPlot.h"
#import "WeightControlAddRecordView.h"
#import <QuartzCore/CALayer.h>

@class WeightControl;
@class WeightControlQuartzPlot;
//@protocol WeightControlAddRecordProtocol;
@class WeightControlAddRecordView;

@interface WeightControlChart : UIViewController <WeightControlAddRecordProtocol>{
    
};

@property (nonatomic, assign) WeightControl *delegate;

@property (nonatomic, retain) IBOutlet WeightControlQuartzPlot *weightGraph;
@property (nonatomic, retain) IBOutlet UILabel *topGraphStatus;
@property (nonatomic, retain) IBOutlet UILabel *bottomGraphStatus;

@property (nonatomic, retain) IBOutlet WeightControlAddRecordView *addRecordView;

- (IBAction)pressDefault;

- (IBAction)pressScaleButton:(id)sender;

- (float)getTodaysWeightState;
- (IBAction)pressNewRecordButton:(id)sender;

@end
