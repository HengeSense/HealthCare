//
//  WeightControlQuartzPlot.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControl.h"
#import "WeightControlVerticalAxisView.h"
#import "WeightControlHorizontalAxisView.h"
#import "WeightControlQuartzPlot.h"

#import <QuartzCore/QuartzCore.h>

@class WeightControl;
@class WeightControlQuartzPlot;
@class WeightControlVerticalAxisView;
@class WeightControlHorizontalAxisView;

@interface WeightControlQuartzPlotContent : UIView <UIScrollViewDelegate> {
    float drawingOffset;
    float verticalGridLinesWidth;
    float verticalGridLinesInterval;
    NSTimeInterval timeDimension;       // msec/px
    NSTimeInterval timeStep;            // time interval betveen vertical grid lines
    
    float horizontalGridLinesWidth;
    float horizontalGridLinesInterval;
    
    NSUInteger plotXOffset;     // start drawing plot from vertical grid line with this number
    float plotYExpandFactor;    // expand y axis by this factor
    float weightLineWidth;
    float weightPointRadius;
    
    float previousScale;
    
    
    float yAxisFrom, yAxisTo;
}

@property (nonatomic, assign) WeightControlQuartzPlot *delegate;
@property (nonatomic, assign) WeightControl *delegateWeight;
@property (nonatomic, assign) WeightControlVerticalAxisView *weightGraphYAxisView;
@property (nonatomic, assign) WeightControlHorizontalAxisView *weightGraphXAxisView;

- (void)updateXYRangesValues;
- (NSArray *)calcYRangeFromDates:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (float)convertWeightToY:(float)weight;
- (float)convertYToWeight:(float)yCoord;
- (NSUInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (void)performUpdatePlot;

- (NSTimeInterval)getTimeIntervalSince1970ForX:(float)xCoord;
- (float)getXCoordForTimeIntervalSince1970:(NSTimeInterval)timeInt;

- (void)zoomContentByFactor:(float)factor;

- (float)calcOccupiedAreaWidth;

//- (void)setTransformWithoutScaling:(CGAffineTransform)newTransform;

@end
