//
//  WeightControlTestClass.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeightControl.h"
#import "WeightControlPlotScrollView.h"
#import "WeightControlQuartzPlotContent.h"
#import "WeightControlVerticalAxisView.h"
#import "WeightControlHorizontalAxisView.h"
#import "WeightControlQuartzPlotPointer.h"
#import "WeightControlQuartzPlotZoomer.h"

@class WeightControl;
@class WeightControlPlotScrollView;
@class WeightControlQuartzPlotContent;
@class WeightControlVerticalAxisView;
@class WeightControlHorizontalAxisView;
@class WeightControlQuartzPlotPointer;
@class WeightControlQuartzPlotPointerScrolerView;
@class WeightControlQuartzPlotZoomer;

@interface WeightControlQuartzPlot : UIView {
    WeightControlPlotScrollView *scrollView;
    WeightControlQuartzPlotContent *contentView;
    WeightControlVerticalAxisView *yAxis;
    WeightControlHorizontalAxisView *xAxis;
    WeightControlQuartzPlotPointer *pointerView;
    WeightControlQuartzPlotZoomer *zoomerView;
    
    CGFloat lastContentOffset;
    CGFloat lastContentX;
    CGFloat lastPointerX;
    
}

@property (nonatomic, assign) WeightControl *delegateWeight;

@property (nonatomic, retain) WeightControlPlotScrollView *scrollView;
@property (nonatomic, retain) WeightControlQuartzPlotContent *contentView;
@property (nonatomic, retain) WeightControlVerticalAxisView *yAxis;
@property (nonatomic, retain) WeightControlHorizontalAxisView *xAxis;
@property (nonatomic, retain) WeightControlQuartzPlotPointer *pointerView;
@property (nonatomic, retain) WeightControlQuartzPlotPointerScrolerView *pointerScroller;
@property (nonatomic, retain) WeightControlQuartzPlotZoomer *zoomerView;

@property (nonatomic, retain) UILabel *normWeightLabel;
@property (nonatomic, retain) UILabel *aimWeightLabel;


- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate;

- (void)redrawPlot;

- (void)testPixel;

- (float)getWeightByY:(float)yCoord;
- (float)getTimeIntervalByX:(float)xCoord;
- (void)handleTapGesture:(UITapGestureRecognizer *)sender;
- (void)showPointerForContentViewPoint:(CGFloat)xContentView atPosition:(CGFloat)xPointer;
- (void)updatePointerDuringScrolling;
- (void)updatePointerDuringSelfScrolling:(float)curPointX;
- (void)showZoomer;
- (void)hidePointer;
- (void)hideZoomer;

- (void)zoomIn;
- (void)zoomOut;

- (void)scrollToDate:(NSDate *)needDate;

- (void)updateAimAndNormLabelsPosition;

@end

