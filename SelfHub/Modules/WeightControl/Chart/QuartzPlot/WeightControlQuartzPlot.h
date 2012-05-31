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

@class WeightControl;
@class WeightControlPlotScrollView;
@class WeightControlQuartzPlotContent;
@class WeightControlVerticalAxisView;
@class WeightControlHorizontalAxisView;
@class WeightControlQuartzPlotPointer;

@interface WeightControlQuartzPlot : UIView {
    WeightControlPlotScrollView *scrollView;
    WeightControlQuartzPlotContent *contentView;
    WeightControlVerticalAxisView *yAxis;
    WeightControlHorizontalAxisView *xAxis;
    WeightControlQuartzPlotPointer *pointerView;
    
    CGFloat lastContentOffset;
    CGPoint lastContentPoint;
    CGFloat lastPointerX;
    
}

@property (nonatomic, assign) WeightControl *delegateWeight;

@property (nonatomic, retain) WeightControlPlotScrollView *scrollView;
@property (nonatomic, retain) WeightControlQuartzPlotContent *contentView;
@property (nonatomic, retain) WeightControlVerticalAxisView *yAxis;
@property (nonatomic, retain) WeightControlHorizontalAxisView *xAxis;
@property (nonatomic, retain) WeightControlQuartzPlotPointer *pointerView;
//@property (nonatomic, retain) WeightControl *xAxis;


- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate;

- (void)redrawPlot;

- (void)testPixel;

- (float)getWeightByY:(float)yCoord;
- (void)handleTapGesture:(UITapGestureRecognizer *)sender;
- (void)showPointerForContentViewPoint:(CGPoint)contentViewPoint atPosition:(CGFloat)xPointer;
- (void)updatePointerDuringScrolling;
- (void)hidePointer;

@end

