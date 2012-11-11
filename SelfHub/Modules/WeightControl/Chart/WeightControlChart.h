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
#import "WeightControlChartSmoothLabel.h"

@class WeightControl;
@class WeightControlQuartzPlot;
//@protocol WeightControlAddRecordProtocol;
@class WeightControlAddRecordView;


@interface WeightControlChart : UIViewController <WeightControlAddRecordProtocol>{
    
};

@property (nonatomic, assign) WeightControl *delegate;

@property (nonatomic, retain) IBOutlet WeightControlQuartzPlot *weightGraph;

//first stat line
@property (nonatomic, retain) IBOutlet UILabel *statusBarTrendLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusBarBMILabel;
@property (nonatomic, retain) IBOutlet WeightControlChartSmoothLabel *statusBarBMIStatusSmoothLabel;

//second stat line
@property (nonatomic, retain) IBOutlet UILabel *statusBarWeekTrendLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusBarWeekTrendValueLabel;

//third stat line
@property (nonatomic, retain) IBOutlet UILabel *statusBarForecastLabel;
@property (nonatomic, retain) IBOutlet WeightControlChartSmoothLabel *statusBarForecastSmoothLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusBarKcalDayLabel;

//fourth stat line
@property (nonatomic, retain) IBOutlet UILabel *statusBarAimLabel;
@property (nonatomic, retain) IBOutlet WeightControlChartSmoothLabel *statusBarAimValueSmoothLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusBarExpectedAimLabel;

@property (nonatomic, retain) IBOutlet UIView *plotView;


@property (nonatomic, retain) IBOutlet WeightControlAddRecordView *addRecordView;

- (IBAction)pressDefault;

- (IBAction)pressScaleButton:(id)sender;

- (float)getTodaysWeightState;
- (IBAction)pressNewRecordButton:(id)sender;

- (float)getRecordValueAtTimeInterval:(NSTimeInterval)needInterval forKey:(NSString *)key;
- (void)updateGraphStatusLines;

@end
