//
//  WeightControlQuartzPlotZoomer.h
//  SelfHub
//
//  Created by Mac on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControlQuartzPlot.h"

@class WeightControlQuartzPlot;

@interface WeightControlQuartzPlotZoomer : UIView {
    UIButton *btnIn, *btnOut;
    
    NSTimer *hideZoomTimer;
}

@property (nonatomic, assign) WeightControlQuartzPlot *delegate;

- (void)showZoomView;
- (void)hideZoomView;
- (void)setHideTimerForATime:(NSTimeInterval)timerInterval;
- (void)hideZoomerTimerRoutine:(NSTimer *)theTimer;

- (IBAction)pressIn:(id)sender;
- (IBAction)pressOut:(id)sender;

- (void)setInEnabled:(BOOL)enabled;
- (void)setOutEnabled:(BOOL)enabled;

@end
